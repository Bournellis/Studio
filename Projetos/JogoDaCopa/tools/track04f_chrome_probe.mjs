import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import path from "node:path";
import { spawn } from "node:child_process";

const args = new Map();
for (const arg of process.argv.slice(2)) {
  const [key, ...rest] = arg.split("=");
  args.set(key.replace(/^--/, ""), rest.join("=") || "1");
}

const chromePath = args.get("chrome");
const webDir = path.resolve(args.get("web-dir") || "builds/web");
const outDir = path.resolve(args.get("out-dir") || "docs/playtest-reports/track-04f-data");
const route = args.get("route") || "/index.html?jdc_capture=play&jdc_perf=1";
const durationMs = Number(args.get("duration-ms") || "20000");
const httpPort = Number(args.get("http-port") || "8064");
const cdpPort = Number(args.get("cdp-port") || "9223");
const label = args.get("label") || "chrome-probe";
const headless = args.get("headless") !== "0";
const viewportWidth = Number(args.get("width") || "1920");
const viewportHeight = Number(args.get("height") || "1080");
const screenshotAtMs = Number(args.get("screenshot-at-ms") || "0");
const pressPlay = args.get("press-play") === "1";
const pressPlayStage = args.get("press-play-stage") || "menu.ready.end";
const pressPlayDelayMs = Number(args.get("press-play-delay-ms") || "400");
const resetFramesAfterStage = args.get("reset-frames-after-stage") || "";
const resetFramesDelayMs = Number(args.get("reset-frames-delay-ms") || "0");
const keyAfterStage = args.get("key-after-stage") || "";
const keyAfterDelayMs = Number(args.get("key-after-delay-ms") || "0");
const keyAfter = args.get("key-after") || "Enter";

if (!chromePath || !existsSync(chromePath)) {
  throw new Error(`Chrome executable not found: ${chromePath}`);
}
if (!existsSync(webDir)) {
  throw new Error(`Web export directory not found: ${webDir}`);
}
mkdirSync(outDir, { recursive: true });

const mimeByExt = new Map([
  [".html", "text/html; charset=utf-8"],
  [".js", "application/javascript; charset=utf-8"],
  [".wasm", "application/wasm"],
  [".pck", "application/octet-stream"],
  [".png", "image/png"],
  [".jpg", "image/jpeg"],
  [".jpeg", "image/jpeg"],
  [".svg", "image/svg+xml"],
]);

function serveFile(req, res) {
  const url = new URL(req.url, "http://127.0.0.1");
  let filePath = path.normalize(decodeURIComponent(url.pathname));
  if (filePath === path.sep) filePath = "index.html";
  if (filePath.startsWith("..")) {
    res.writeHead(403);
    res.end("forbidden");
    return;
  }
  const absolutePath = path.join(webDir, filePath);
  readFile(absolutePath)
    .then((data) => {
      res.writeHead(200, {
        "Content-Type": mimeByExt.get(path.extname(absolutePath).toLowerCase()) || "application/octet-stream",
        "Cache-Control": "no-store",
      });
      res.end(data);
    })
    .catch(() => {
      res.writeHead(404);
      res.end("not found");
    });
}

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForJson(url, timeoutMs = 10000) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    try {
      const response = await fetch(url);
      if (response.ok) return await response.json();
    } catch {
      // Retry while Chrome starts.
    }
    await delay(100);
  }
  throw new Error(`Timed out waiting for ${url}`);
}

function connectCdp(wsUrl) {
  const ws = new WebSocket(wsUrl);
  let nextId = 1;
  const pending = new Map();
  const listeners = new Map();
  ws.addEventListener("message", (event) => {
    const message = JSON.parse(event.data);
    if (message.id && pending.has(message.id)) {
      const { resolve, reject } = pending.get(message.id);
      pending.delete(message.id);
      if (message.error) reject(new Error(JSON.stringify(message.error)));
      else resolve(message.result || {});
      return;
    }
    if (message.method && listeners.has(message.method)) {
      for (const listener of listeners.get(message.method)) listener(message.params || {});
    }
  });
  return new Promise((resolve, reject) => {
    ws.addEventListener("open", () => {
      resolve({
        send(method, params = {}) {
          const id = nextId++;
          ws.send(JSON.stringify({ id, method, params }));
          return new Promise((resolveSend, rejectSend) => {
            pending.set(id, { resolve: resolveSend, reject: rejectSend });
          });
        },
        on(method, listener) {
          if (!listeners.has(method)) listeners.set(method, []);
          listeners.get(method).push(listener);
        },
        close() {
          ws.close();
        },
      });
    });
    ws.addEventListener("error", reject);
  });
}

function percentile(sorted, p) {
  if (sorted.length === 0) return 0;
  const index = Math.min(sorted.length - 1, Math.max(0, Math.ceil((p / 100) * sorted.length) - 1));
  return sorted[index];
}

function parsePerfLine(text, wallTimeMs) {
  if (!text.includes("[JDC_PERF]")) return null;
  const stage = /stage=([^ ]+)/.exec(text)?.[1] || "";
  const dt = Number(/dt_ms=([0-9.]+)/.exec(text)?.[1] || "NaN");
  const detail = /detail=(.*)$/.exec(text)?.[1] || "";
  return { wallTimeMs, stage, dtMs: Number.isFinite(dt) ? dt : null, detail, text };
}

function nearestEvent(hitchWallTimeMs, events) {
  let best = null;
  let bestDistance = Infinity;
  for (const event of events) {
    const distance = Math.abs(event.wallTimeMs - hitchWallTimeMs);
    if (distance < bestDistance) {
      best = event;
      bestDistance = distance;
    }
  }
  return best ? { ...best, distanceMs: bestDistance } : null;
}

async function waitForPerfStage(events, stage, timeoutMs) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    if (events.some((event) => event.stage === stage)) return true;
    await delay(50);
  }
  return false;
}

async function dispatchKey(client, key) {
  const keyCodeByName = new Map([
    ["Enter", 13],
    ["Space", 32],
    ["Escape", 27],
  ]);
  const code = key === "Space" ? "Space" : key;
  const keyCode = keyCodeByName.get(key) || key.toUpperCase().charCodeAt(0);
  await client.send("Input.dispatchKeyEvent", {
    type: "keyDown",
    key,
    code,
    windowsVirtualKeyCode: keyCode,
    nativeVirtualKeyCode: keyCode,
  });
  await client.send("Input.dispatchKeyEvent", {
    type: "keyUp",
    key,
    code,
    windowsVirtualKeyCode: keyCode,
    nativeVirtualKeyCode: keyCode,
  });
}

const server = createServer(serveFile);
await new Promise((resolve) => server.listen(httpPort, "127.0.0.1", resolve));

const userDataDir = path.join(outDir, `.chrome-profile-${label}`);
mkdirSync(userDataDir, { recursive: true });
const chromeArgs = [
  `--remote-debugging-port=${cdpPort}`,
  `--user-data-dir=${userDataDir}`,
  "--no-first-run",
  "--disable-background-timer-throttling",
  "--disable-renderer-backgrounding",
  "--disable-backgrounding-occluded-windows",
  "--autoplay-policy=no-user-gesture-required",
  "--ignore-gpu-blocklist",
  `--window-size=${viewportWidth},${viewportHeight}`,
  "about:blank",
];
if (headless) chromeArgs.unshift("--headless=new");

const chrome = spawn(chromePath, chromeArgs, { stdio: "ignore" });
let client;
try {
  await waitForJson(`http://127.0.0.1:${cdpPort}/json/version`, 15000);
  const newPageResponse = await fetch(`http://127.0.0.1:${cdpPort}/json/new?about:blank`, { method: "PUT" });
  const pageTarget = await newPageResponse.json();
  client = await connectCdp(pageTarget.webSocketDebuggerUrl);

  const consoleLines = [];
  const perfEvents = [];
  const pageErrors = [];
  client.on("Runtime.consoleAPICalled", (params) => {
    const text = (params.args || []).map((entry) => entry.value ?? entry.description ?? "").join(" ");
    const wallTimeMs = Number(params.timestamp || Date.now());
    consoleLines.push({ wallTimeMs, type: params.type, text });
    const perf = parsePerfLine(text, wallTimeMs);
    if (perf) perfEvents.push(perf);
  });
  client.on("Runtime.exceptionThrown", (params) => {
    pageErrors.push(params.exceptionDetails || params);
  });

  await client.send("Runtime.enable");
  await client.send("Page.enable");
  await client.send("Emulation.setDeviceMetricsOverride", {
    width: viewportWidth,
    height: viewportHeight,
    deviceScaleFactor: 1,
    mobile: false,
  });

  const frameCollector = `
(() => {
  if (window.__jdcFrameCollectorInstalled) return;
  window.__jdcFrameCollectorInstalled = true;
  window.__jdcFrames = [];
  window.__jdcFrameStart = performance.now();
  let last = performance.now();
  function tick(now) {
    const dt = now - last;
    last = now;
    window.__jdcFrames.push({ t: now, dt });
    requestAnimationFrame(tick);
  }
  requestAnimationFrame(tick);
})()
`;
  await client.send("Page.addScriptToEvaluateOnNewDocument", { source: frameCollector });

  const targetUrl = `http://127.0.0.1:${httpPort}${route}`;
  await client.send("Page.navigate", { url: targetUrl });
  await delay(500);
  await client.send("Runtime.evaluate", {
    expression: frameCollector,
    awaitPromise: false,
  });

  if (pressPlay) {
    await waitForPerfStage(perfEvents, pressPlayStage, 20000);
    await delay(pressPlayDelayMs);
    await dispatchKey(client, "Enter");
  }

  if (resetFramesAfterStage) {
    await waitForPerfStage(perfEvents, resetFramesAfterStage, durationMs);
    if (resetFramesDelayMs > 0) await delay(resetFramesDelayMs);
    await client.send("Runtime.evaluate", {
      expression: `
(() => {
  window.__jdcFrames = [];
  window.__jdcFrameStart = performance.now();
  return true;
})()
`,
      awaitPromise: false,
    });
  }

  if (keyAfterStage) {
    await waitForPerfStage(perfEvents, keyAfterStage, durationMs);
    if (keyAfterDelayMs > 0) await delay(keyAfterDelayMs);
    await dispatchKey(client, keyAfter);
  }

  let screenshotPath = "";
  if (screenshotAtMs > 0 && screenshotAtMs < durationMs) {
    await delay(screenshotAtMs);
    const screenshot = await client.send("Page.captureScreenshot", { format: "png", captureBeyondViewport: false });
    screenshotPath = path.join(outDir, `${label}.png`);
    writeFileSync(screenshotPath, Buffer.from(screenshot.data, "base64"));
    await delay(durationMs - screenshotAtMs);
  } else {
    await delay(durationMs);
  }
  const result = await client.send("Runtime.evaluate", {
    expression: `
(() => {
  const frames = window.__jdcFrames || [];
  const timeOrigin = performance.timeOrigin;
  const dts = frames.map((f) => f.dt).filter((dt) => Number.isFinite(dt) && dt >= 0);
  const sorted = [...dts].sort((a, b) => a - b);
  const pct = (p) => {
    if (!sorted.length) return 0;
    const index = Math.min(sorted.length - 1, Math.max(0, Math.ceil((p / 100) * sorted.length) - 1));
    return sorted[index];
  };
  return {
    url: location.href,
    userAgent: navigator.userAgent,
    timeOrigin,
    frameCount: frames.length,
    p50: pct(50),
    p95: pct(95),
    p99: pct(99),
    max: sorted.length ? sorted[sorted.length - 1] : 0,
    hitches: frames.filter((f) => f.dt > 50).map((f) => ({ t: f.t, wallTimeMs: timeOrigin + f.t, dt: f.dt })).sort((a, b) => b.dt - a.dt).slice(0, 50),
  };
})()
`,
    returnByValue: true,
  });
  const frameStats = result.result.value;
  frameStats.hitches = frameStats.hitches.map((hitch) => ({
    ...hitch,
    nearestEvent: nearestEvent(hitch.wallTimeMs, perfEvents),
  }));

  if (!screenshotPath) {
    const screenshot = await client.send("Page.captureScreenshot", { format: "png", captureBeyondViewport: false });
    screenshotPath = path.join(outDir, `${label}.png`);
    writeFileSync(screenshotPath, Buffer.from(screenshot.data, "base64"));
  }

  const output = {
    label,
    route,
    targetUrl,
    durationMs,
    headless,
    viewport: { width: viewportWidth, height: viewportHeight },
    frameStats,
    perfEvents,
    consoleLines,
    pageErrors,
    screenshotPath,
  };
  const jsonPath = path.join(outDir, `${label}.json`);
  writeFileSync(jsonPath, JSON.stringify(output, null, 2));
  console.log(JSON.stringify({
    label,
    frameCount: frameStats.frameCount,
    p50: frameStats.p50,
    p95: frameStats.p95,
    p99: frameStats.p99,
    max: frameStats.max,
    hitchCount: frameStats.hitches.length,
    screenshotPath,
    jsonPath,
    pageErrors: pageErrors.length,
  }, null, 2));
} finally {
  if (client) client.close();
  chrome.kill();
  server.close();
}
