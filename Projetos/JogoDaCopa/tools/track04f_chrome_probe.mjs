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
const remoteUrl = (args.get("url") || args.get("remote-url") || "").trim();
const usingRemoteUrl = remoteUrl.length > 0;
const expectedReleaseRoot = args.get("expected-release-root") || "";
const expectedStage = args.get("expected-stage") || "";
const failOnRuntimeErrors = args.get("fail-on-runtime-errors") === "1";
const durationMs = Number(args.get("duration-ms") || "20000");
const sampleIntervalMs = Number(args.get("sample-interval-ms") || "1000");
const stabilityGate = args.get("stability-gate") === "1";
const stabilityWarmupMs = Number(args.get("stability-warmup-ms") || "60000");
const maxHeapGrowthRatio = Number(args.get("max-heap-growth-ratio") || "0.10");
const minFiveSecondAverageFps = Number(args.get("min-5s-avg-fps") || "30");
const firstMinuteGate = args.get("first-minute-gate") === "1";
const firstMinuteDurationMs = Number(args.get("first-minute-duration-ms") || "60000");
const firstMinuteHitchThresholdMs = Number(args.get("first-minute-hitch-threshold-ms") || "100");
const firstMinuteStartStage = args.get("first-minute-start-stage") || "event.visible_match_start";
const eventHitchWindowMs = Number(args.get("event-hitch-window-ms") || "2000");
const eventHitchPreWindowMs = Number(args.get("event-hitch-pre-window-ms") || "250");
const defaultFrameStorageLimit = stabilityGate && !firstMinuteGate ? "1200" : "0";
const frameStorageLimit = Math.max(0, Math.floor(Number(args.get("frame-storage-limit") || defaultFrameStorageLimit)));
const webFeedback = (args.get("web-feedback") || "").trim();
const godotStabilitySamplesEnabled = args.get("godot-stability-samples") !== "0";
const godotDetailEnabled = args.get("godot-detail") !== "0";
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
const finalHeapGc = args.get("final-heap-gc") !== "0";

if (!chromePath || !existsSync(chromePath)) {
  throw new Error(`Chrome executable not found: ${chromePath}`);
}
if (!usingRemoteUrl && !existsSync(webDir)) {
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

function parsePerfDetail(detail) {
	const values = {};
	for (const part of String(detail || "").split(/\s+/)) {
		if (!part.includes("=")) continue;
		const index = part.indexOf("=");
		const key = part.slice(0, index);
		const rawValue = part.slice(index + 1);
		const numeric = Number(rawValue);
		values[key] = Number.isFinite(numeric) ? numeric : rawValue;
	}
	return values;
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

function withQueryParam(urlText, key, value) {
  const url = new URL(urlText);
  url.searchParams.set(key, value);
  return url.toString();
}

function findFirstEvent(events, stage) {
  return events.find((event) => event.stage === stage) || null;
}

function buildFirstMinuteReport(frameStats, events) {
  const startEvent = findFirstEvent(events, firstMinuteStartStage) || findFirstEvent(events, "loading.overlay_hidden") || events[0] || null;
  const startWallTimeMs = startEvent?.wallTimeMs || 0;
  const endWallTimeMs = startWallTimeMs + firstMinuteDurationMs;
  const hitches = (frameStats.hitches || [])
    .filter((hitch) => hitch.dt > firstMinuteHitchThresholdMs)
    .filter((hitch) => startWallTimeMs <= 0 || (hitch.wallTimeMs >= startWallTimeMs && hitch.wallTimeMs <= endWallTimeMs))
    .sort((a, b) => b.dt - a.dt)
    .map((hitch) => ({
      ...hitch,
      elapsedFromStartMs: startWallTimeMs > 0 ? hitch.wallTimeMs - startWallTimeMs : null,
      nearestEvent: nearestEvent(hitch.wallTimeMs, events),
    }));
  return {
    enabled: firstMinuteGate,
    passed: hitches.length === 0,
    startStage: startEvent?.stage || "",
    startWallTimeMs,
    durationMs: firstMinuteDurationMs,
    thresholdMs: firstMinuteHitchThresholdMs,
    hitchCount: hitches.length,
    hitches,
  };
}

function isInterestingEventStage(stage) {
  return stage === "perf_scenario.step"
    || stage === "event.player_kick_request"
    || stage === "event.whistle"
    || stage === "event.countdown_tick"
    || stage === "event.kick_vfx"
    || stage === "event.goal_detected"
    || stage === "event.goal_vfx"
    || stage === "event.confetti_vfx"
    || stage === "event.jump_pad_vfx"
    || stage === "event.result"
    || stage === "event.round_end"
    || stage === "event.rematch"
    || stage === "event.restart_play";
}

function buildEventHitchReport(frameStats, events) {
  const interestingEvents = events
    .filter((event) => isInterestingEventStage(event.stage))
    .sort((a, b) => a.wallTimeMs - b.wallTimeMs);
  return interestingEvents.map((event) => {
    const windowStartMs = event.wallTimeMs - eventHitchPreWindowMs;
    const windowEndMs = event.wallTimeMs + eventHitchWindowMs;
    const frames = (frameStats.frames || [])
      .filter((frame) => frame.wallTimeMs >= windowStartMs && frame.wallTimeMs <= windowEndMs)
      .sort((a, b) => b.dt - a.dt);
    const hitches = (frameStats.hitches || [])
      .filter((hitch) => hitch.dt > firstMinuteHitchThresholdMs)
      .filter((hitch) => hitch.wallTimeMs >= windowStartMs && hitch.wallTimeMs <= windowEndMs)
      .sort((a, b) => b.dt - a.dt);
    return {
      stage: event.stage,
      detail: event.detail,
      wallTimeMs: event.wallTimeMs,
      windowMs: eventHitchWindowMs,
      preWindowMs: eventHitchPreWindowMs,
      thresholdMs: firstMinuteHitchThresholdMs,
      frameCount: frames.length,
      maxFrameMs: frames.length ? frames[0].dt : 0,
      hitchCount: hitches.length,
      maxHitchMs: hitches.length ? hitches[0].dt : 0,
      hitches,
    };
  });
}

async function waitForPerfStage(events, stage, timeoutMs) {
	const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    if (events.some((event) => event.stage === stage)) return true;
    await delay(50);
  }
	return false;
}

function buildGodotStabilitySamples(perfEvents) {
	return perfEvents
		.filter((event) => event.stage === "stability.sample")
		.map((event) => ({
			wallTimeMs: event.wallTimeMs,
			dtMs: event.dtMs,
			...parsePerfDetail(event.detail),
		}));
}

function getNumericSampleValue(sample, key) {
	const value = sample?.[key];
	return Number.isFinite(value) ? value : null;
}

function buildHeapGate(samples, warmupMs, maxGrowthRatio) {
	const usable = samples
		.map((sample) => ({
			...sample,
			totalHeapBytes: Number(sample.usedJSHeapSize || 0) + Number(sample.wasmHeapBytes || 0),
		}))
		.filter((sample) => sample.t >= warmupMs && sample.totalHeapBytes > 0);
	if (usable.length < 2) {
		return {
			name: "js_wasm_heap_growth",
			passed: false,
			reason: "insufficient heap samples after warmup",
			sampleCount: usable.length,
		};
	}
	const baseline = usable[0].totalHeapBytes;
	const final = usable[usable.length - 1].totalHeapBytes;
	const max = Math.max(...usable.map((sample) => sample.totalHeapBytes));
	const finalGrowthRatio = baseline > 0 ? (final - baseline) / baseline : Infinity;
	const peakGrowthRatio = baseline > 0 ? (max - baseline) / baseline : Infinity;
	return {
		name: "js_wasm_heap_growth",
		passed: finalGrowthRatio <= maxGrowthRatio,
		baselineBytes: baseline,
		finalBytes: final,
		maxBytes: max,
		growthRatio: finalGrowthRatio,
		peakGrowthRatio,
		limit: maxGrowthRatio,
		sampleCount: usable.length,
	};
}

function buildCounterGate(samples, warmupMs) {
	const keys = [
		{ key: "object_node_count", tolerance: 8, mode: "absolute" },
		{ key: "object_count", tolerance: 16, mode: "absolute" },
		{ key: "static_cache_total_entries", tolerance: 0, mode: "absolute" },
		{ key: "runtime_standard_material_cache", tolerance: 0, mode: "absolute" },
		{ key: "runtime_glass_material_cache", tolerance: 0, mode: "absolute" },
		{ key: "runtime_box_mesh_cache", tolerance: 0, mode: "absolute" },
		{ key: "field_halo_material_cache", tolerance: 0, mode: "absolute" },
		{ key: "render_video_mem_used", tolerance: 0.1, mode: "ratio" },
	];
	const usable = samples.filter((sample) => Number(sample.elapsed_s || 0) * 1000 >= warmupMs);
	if (usable.length < 2) {
		return {
			name: "godot_counter_stability",
			passed: false,
			reason: "insufficient Godot stability samples after warmup",
			sampleCount: usable.length,
			checks: [],
		};
	}
	const checks = [];
	for (const entry of keys) {
		const withKey = usable.filter((sample) => getNumericSampleValue(sample, entry.key) !== null);
		if (withKey.length < 2) {
			checks.push({ key: entry.key, passed: false, reason: "missing samples" });
			continue;
		}
		const baseline = getNumericSampleValue(withKey[0], entry.key);
		const final = getNumericSampleValue(withKey[withKey.length - 1], entry.key);
		const max = Math.max(...withKey.map((sample) => getNumericSampleValue(sample, entry.key)));
		let passed = true;
		let limit;
		if (entry.mode === "ratio") {
			limit = baseline * (1 + entry.tolerance) + 1024 * 1024;
			passed = final <= limit;
		} else {
			limit = baseline + entry.tolerance;
			passed = final <= limit;
		}
		checks.push({ key: entry.key, passed, baseline, final, max, limit, sampleCount: withKey.length });
	}
	return {
		name: "godot_counter_stability",
		passed: checks.every((check) => check.passed),
		sampleCount: usable.length,
		checks,
	};
}

function buildFiveSecondFpsGate(frameStats, warmupMs, minAverageFps) {
	const buckets = Array.isArray(frameStats?.fpsBuckets) ? frameStats.fpsBuckets : [];
	const usable = buckets
		.filter((bucket) => Number.isFinite(bucket.t) && Number.isFinite(bucket.count) && bucket.t >= warmupMs)
		.sort((a, b) => a.t - b.t);
	if (usable.length < 2) {
		return {
			name: "five_second_average_fps",
			passed: false,
			reason: "insufficient FPS buckets after warmup",
			minAverageFps: 0,
			limit: minAverageFps,
			windowCount: 0,
		};
	}
	const countByBucket = new Map(usable.map((bucket) => [bucket.t, bucket.count]));
	const firstWindowStart = Math.ceil(warmupMs / 1000) * 1000;
	const lastT = usable[usable.length - 1].t + 1000;
	let minAverage = Infinity;
	let worstWindow = null;
	let windowCount = 0;
	for (let start = firstWindowStart; start + 5000 <= lastT; start += 1000) {
		const end = start + 5000;
		let framesInWindow = 0;
		for (let bucketStart = start; bucketStart < end; bucketStart += 1000) {
			framesInWindow += Number(countByBucket.get(bucketStart) || 0);
		}
		const averageFps = framesInWindow / 5;
		windowCount += 1;
		if (averageFps < minAverage) {
			minAverage = averageFps;
			worstWindow = { startMs: start, endMs: end, averageFps, frames: framesInWindow };
		}
	}
	if (!Number.isFinite(minAverage)) minAverage = 0;
	return {
		name: "five_second_average_fps",
		passed: minAverage >= minAverageFps,
		minAverageFps: minAverage,
		limit: minAverageFps,
		windowCount,
		worstWindow,
	};
}

function buildStabilityGate({ frameStats, browserSamples, godotSamples }) {
	const checks = [
		buildHeapGate(browserSamples, stabilityWarmupMs, maxHeapGrowthRatio),
		buildCounterGate(godotSamples, stabilityWarmupMs),
		buildFiveSecondFpsGate(frameStats, stabilityWarmupMs, minFiveSecondAverageFps),
	];
	return {
		enabled: stabilityGate,
		warmupMs: stabilityWarmupMs,
		sampleIntervalMs,
		checks,
		passed: checks.every((check) => check.passed),
	};
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

async function collectPageGarbage(client) {
  try {
    await client.send("HeapProfiler.enable");
    await client.send("HeapProfiler.collectGarbage");
    await delay(250);
  } catch {
    // Keep the probe compatible with browsers that do not expose HeapProfiler.
  }
}

let server = null;
if (!usingRemoteUrl) {
  server = createServer(serveFile);
  await new Promise((resolve) => server.listen(httpPort, "127.0.0.1", resolve));
}

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
  const frameStorageLimit = ${Number.isFinite(frameStorageLimit) ? frameStorageLimit : 0};
  window.__jdcFrameStats = { frameCount: 0, dts: [], frames: [], hitches: [], fpsBuckets: {} };
  window.__jdcFrameStart = performance.now();
  let last = performance.now();
  function tick(now) {
    const dt = now - last;
    last = now;
    const stats = window.__jdcFrameStats || (window.__jdcFrameStats = { frameCount: 0, dts: [], frames: [], hitches: [], fpsBuckets: {} });
    stats.frameCount += 1;
    stats.dts.push(dt);
    stats.frames.push({ t: now, wallTimeMs: performance.timeOrigin + now, dt });
    if (frameStorageLimit > 0 && stats.frames.length > frameStorageLimit + 200) {
      stats.frames.splice(0, stats.frames.length - frameStorageLimit);
    }
    const bucketStart = Math.floor(now / 1000) * 1000;
    stats.fpsBuckets[bucketStart] = (stats.fpsBuckets[bucketStart] || 0) + 1;
    if (dt > 50) {
      stats.hitches.push({ t: now, wallTimeMs: performance.timeOrigin + now, dt });
      stats.hitches.sort((a, b) => b.dt - a.dt);
    }
    requestAnimationFrame(tick);
  }
  requestAnimationFrame(tick);
})()
`;
  const stabilityCollector = `
(() => {
  if (window.__jdcStabilityCollectorInstalled) return;
  window.__jdcStabilityCollectorInstalled = true;
  window.__jdcStabilitySamples = [];
  if (!window.__jdcWasmMemoryHookInstalled && window.WebAssembly && WebAssembly.Memory) {
    window.__jdcWasmMemoryHookInstalled = true;
    window.__jdcWasmMemories = [];
    const OriginalWasmMemory = WebAssembly.Memory;
    try {
      WebAssembly.Memory = new Proxy(OriginalWasmMemory, {
        construct(target, args) {
          const memory = Reflect.construct(target, args);
          window.__jdcWasmMemories.push(memory);
          return memory;
        },
      });
    } catch {
      window.__jdcWasmMemoryHookInstalled = false;
    }
  }
  const findWasmHeapBytes = () => {
    const memories = window.__jdcWasmMemories || [];
    let largestMemoryBytes = null;
    for (const memory of memories) {
      if (memory && memory.buffer && Number.isFinite(memory.buffer.byteLength)) {
        largestMemoryBytes = Math.max(largestMemoryBytes || 0, memory.buffer.byteLength);
      }
    }
    if (largestMemoryBytes !== null) return largestMemoryBytes;
    const directCandidates = [
      window.Module,
      window.GodotModule,
      window.GodotRuntime,
      window.Engine,
      window.engine,
    ];
    for (const candidate of directCandidates) {
      if (candidate && candidate.HEAP8 && candidate.HEAP8.buffer) return candidate.HEAP8.buffer.byteLength;
      if (candidate && candidate.Module && candidate.Module.HEAP8 && candidate.Module.HEAP8.buffer) return candidate.Module.HEAP8.buffer.byteLength;
    }
    for (const key of Object.keys(window)) {
      const value = window[key];
      if (!value || typeof value !== "object") continue;
      if (value.HEAP8 && value.HEAP8.buffer) return value.HEAP8.buffer.byteLength;
      if (value.asm && value.asm.memory && value.asm.memory.buffer) return value.asm.memory.buffer.byteLength;
    }
    return null;
  };
  const sample = () => {
    const memory = performance.memory || {};
    window.__jdcStabilitySamples.push({
      t: performance.now(),
      wallTimeMs: performance.timeOrigin + performance.now(),
      usedJSHeapSize: Number.isFinite(memory.usedJSHeapSize) ? memory.usedJSHeapSize : null,
      totalJSHeapSize: Number.isFinite(memory.totalJSHeapSize) ? memory.totalJSHeapSize : null,
      jsHeapSizeLimit: Number.isFinite(memory.jsHeapSizeLimit) ? memory.jsHeapSizeLimit : null,
      wasmHeapBytes: findWasmHeapBytes(),
    });
  };
  window.__jdcRecordStabilitySample = sample;
  sample();
  window.__jdcStabilityInterval = setInterval(sample, ${Math.max(250, sampleIntervalMs)});
})()
`;
  await client.send("Page.addScriptToEvaluateOnNewDocument", { source: frameCollector });
  await client.send("Page.addScriptToEvaluateOnNewDocument", { source: stabilityCollector });

  let targetUrl = usingRemoteUrl ? remoteUrl : `http://127.0.0.1:${httpPort}${route}`;
  if (!godotStabilitySamplesEnabled) {
    targetUrl = withQueryParam(targetUrl, "jdc_perf_stability", "0");
  }
  if (!godotDetailEnabled) {
    targetUrl = withQueryParam(targetUrl, "jdc_perf_detail", "0");
  }
  if (webFeedback.length > 0) {
    targetUrl = withQueryParam(targetUrl, "jdc_web_feedback", webFeedback);
  }
  await client.send("Page.navigate", { url: targetUrl });
  await delay(500);
  await client.send("Runtime.evaluate", {
    expression: frameCollector,
    awaitPromise: false,
  });
  await client.send("Runtime.evaluate", {
    expression: stabilityCollector,
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
  window.__jdcFrameStats = { frameCount: 0, dts: [], frames: [], hitches: [], fpsBuckets: {} };
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
  const stats = window.__jdcFrameStats || { frameCount: 0, dts: [], frames: [], hitches: [], fpsBuckets: {} };
  const timeOrigin = performance.timeOrigin;
  const dts = (stats.dts || []).filter((dt) => Number.isFinite(dt) && dt >= 0);
  const sorted = [...dts].sort((a, b) => a - b);
  const fpsBuckets = Object.entries(stats.fpsBuckets || {})
    .map(([t, count]) => ({ t: Number(t), count: Number(count) }))
    .filter((bucket) => Number.isFinite(bucket.t) && Number.isFinite(bucket.count))
    .sort((a, b) => a.t - b.t);
  const pct = (p) => {
    if (!sorted.length) return 0;
    const index = Math.min(sorted.length - 1, Math.max(0, Math.ceil((p / 100) * sorted.length) - 1));
    return sorted[index];
  };
  return {
    url: location.href,
    userAgent: navigator.userAgent,
    timeOrigin,
    frameCount: Number(stats.frameCount || 0),
    fpsBuckets,
    p50: pct(50),
    p95: pct(95),
    p99: pct(99),
    max: sorted.length ? sorted[sorted.length - 1] : 0,
    frames: (stats.frames || []).map((frame) => ({ t: frame.t, wallTimeMs: frame.wallTimeMs || (timeOrigin + frame.t), dt: frame.dt })),
    hitches: (stats.hitches || []).map((hitch) => ({ t: hitch.t, wallTimeMs: hitch.wallTimeMs || (timeOrigin + hitch.t), dt: hitch.dt })).sort((a, b) => b.dt - a.dt).slice(0, 50),
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
  const firstMinute = buildFirstMinuteReport(frameStats, perfEvents);
  const eventHitches = buildEventHitchReport(frameStats, perfEvents);
  if (stabilityGate && finalHeapGc) {
    await collectPageGarbage(client);
    await client.send("Runtime.evaluate", {
      expression: `
(() => {
  if (typeof window.__jdcRecordStabilitySample === "function") {
    window.__jdcRecordStabilitySample();
  }
  return true;
})()
`,
      returnByValue: true,
    });
  }
  const stabilitySamplesResult = await client.send("Runtime.evaluate", {
    expression: `
(() => {
  if (window.__jdcStabilityInterval) clearInterval(window.__jdcStabilityInterval);
  return window.__jdcStabilitySamples || [];
})()
`,
    returnByValue: true,
  });
  const browserStabilitySamples = stabilitySamplesResult.result.value || [];
  const godotStabilitySamples = buildGodotStabilitySamples(perfEvents);
  const stability = {
    browserSamples: browserStabilitySamples,
    godotSamples: godotStabilitySamples,
    gate: buildStabilityGate({
      frameStats,
      browserSamples: browserStabilitySamples,
      godotSamples: godotStabilitySamples,
    }),
  };
  const releaseResult = await client.send("Runtime.evaluate", {
    expression: "(() => window.JDC_WEB_RELEASE || null)()",
    returnByValue: true,
  });
  const releaseInfo = releaseResult.result.value || null;
  const consoleWarnings = consoleLines.filter((line) => {
    if (line.type !== "error") return false;
    return line.text.startsWith("WARNING:") || line.text.trimStart().startsWith("at: push_warning");
  });
  const consoleErrorLines = consoleLines.filter((line) => {
    if (line.type !== "error" && line.type !== "assert") return false;
    if (line.text.startsWith("WARNING:")) return false;
    if (line.text.trimStart().startsWith("at: push_warning")) return false;
    return true;
  });
  const expectedStageSeen = expectedStage === "" || perfEvents.some((event) => event.stage === expectedStage);
  const assertions = {
    expectedReleaseRoot,
    actualReleaseRoot: releaseInfo?.releaseRoot || "",
    releaseRootMatches: expectedReleaseRoot === "" || releaseInfo?.releaseRoot === expectedReleaseRoot,
    expectedStage,
    expectedStageSeen,
    noPageErrors: pageErrors.length === 0,
    noConsoleErrors: consoleErrorLines.length === 0,
  };

  if (!screenshotPath) {
    const screenshot = await client.send("Page.captureScreenshot", { format: "png", captureBeyondViewport: false });
    screenshotPath = path.join(outDir, `${label}.png`);
    writeFileSync(screenshotPath, Buffer.from(screenshot.data, "base64"));
  }

  const output = {
    label,
    route,
    webFeedback,
    targetUrl,
    durationMs,
    headless,
    viewport: { width: viewportWidth, height: viewportHeight },
    frameStats,
    firstMinute,
    eventHitches,
    perfEvents,
    stability,
    consoleLines,
    consoleWarnings,
    consoleErrorLines,
    pageErrors,
    releaseInfo,
    assertions,
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
    actualReleaseRoot: assertions.actualReleaseRoot,
    releaseRootMatches: assertions.releaseRootMatches,
    expectedStage,
    expectedStageSeen,
    pageErrors: pageErrors.length,
    consoleErrorCount: consoleErrorLines.length,
    consoleWarningCount: consoleWarnings.length,
    browserStabilitySamples: browserStabilitySamples.length,
    godotStabilitySamples: godotStabilitySamples.length,
    stabilityGate,
    stabilityPassed: stability.gate.passed,
    firstMinuteGate,
    firstMinutePassed: firstMinute.passed,
    firstMinuteHitches: firstMinute.hitchCount,
    webFeedback,
  }, null, 2));
  if (!assertions.releaseRootMatches) {
    throw new Error(`Release root mismatch. Expected ${expectedReleaseRoot}, got ${assertions.actualReleaseRoot}`);
  }
  if (!assertions.expectedStageSeen) {
    throw new Error(`Expected perf stage was not seen: ${expectedStage}`);
  }
  if (failOnRuntimeErrors && (!assertions.noPageErrors || !assertions.noConsoleErrors)) {
    throw new Error(`Remote runtime errors detected. pageErrors=${pageErrors.length}, consoleErrors=${consoleErrorLines.length}`);
  }
  if (stabilityGate && !stability.gate.passed) {
    throw new Error(`Stability gate failed: ${JSON.stringify(stability.gate.checks)}`);
  }
  if (firstMinuteGate && !firstMinute.passed) {
    throw new Error(`First-minute gate failed: ${JSON.stringify(firstMinute.hitches)}`);
  }
} finally {
  if (client) client.close();
  chrome.kill();
  if (server) server.close();
}
