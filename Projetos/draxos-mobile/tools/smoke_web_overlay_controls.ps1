param(
    [Parameter(Mandatory = $true)]
    [string]$WebUrl,
    [string]$ExpectedReleaseRoot = "",
    [string]$ExpectedAppVersion = "0.0.22-alpha.0",
    [int]$ExpectedAppVersionCode = 22,
    [string]$ChromePath = "",
    [int]$TimeoutSeconds = 90,
    [string]$DiagnosticsDir = "",
    [switch]$AllowCloudflareAccess,
    [switch]$NoProjectWrites,
    [switch]$KeepDiagnostics
)

$ErrorActionPreference = "Stop"

$ProjectDir = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$diagnosticsWasDefaulted = [string]::IsNullOrWhiteSpace($DiagnosticsDir)
if ([string]::IsNullOrWhiteSpace($DiagnosticsDir)) {
    $stamp = (Get-Date).ToUniversalTime().ToString("yyyyMMdd-HHmmss")
    if ($NoProjectWrites.IsPresent) {
        $DiagnosticsDir = Join-Path ([System.IO.Path]::GetTempPath()) "draxos-mobile-web-overlay-controls-$stamp"
    } else {
        $DiagnosticsDir = Join-Path $ProjectDir "build\diagnostics\web-overlay-controls-$stamp"
    }
}
New-Item -ItemType Directory -Force -Path $DiagnosticsDir | Out-Null
$DiagnosticsDir = (Resolve-Path -LiteralPath $DiagnosticsDir).Path
if ($NoProjectWrites.IsPresent) {
    $resolvedProjectDir = [System.IO.Path]::GetFullPath($ProjectDir).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
    $resolvedProjectRoot = "$resolvedProjectDir$([System.IO.Path]::DirectorySeparatorChar)"
    $resolvedDiagnostics = [System.IO.Path]::GetFullPath($DiagnosticsDir)
    if ($resolvedDiagnostics.StartsWith($resolvedProjectRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "-NoProjectWrites refuses a DiagnosticsDir inside the project: $DiagnosticsDir"
    }
}

function Resolve-ChromePath {
    param([string]$RequestedPath)
    if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
        if (-not (Test-Path -LiteralPath $RequestedPath -PathType Leaf)) {
            throw "ChromePath not found: $RequestedPath"
        }
        return (Resolve-Path -LiteralPath $RequestedPath).Path
    }

    $candidates = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        "C:\Program Files\Microsoft\Edge\Application\msedge.exe",
        "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }
    throw "Chrome or Edge was not found. Pass -ChromePath to a Chromium-based browser."
}

function Get-FreeTcpPort {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
    try {
        $listener.Start()
        return $listener.LocalEndpoint.Port
    } finally {
        $listener.Stop()
    }
}

function Wait-ChromeCdp {
    param([int]$Port)
    $versionUrl = "http://127.0.0.1:$Port/json/version"
    for ($i = 0; $i -lt 80; $i++) {
        try {
            Invoke-RestMethod -Uri $versionUrl -UseBasicParsing | Out-Null
            return
        } catch {
            Start-Sleep -Milliseconds 250
        }
    }
    throw "Chrome DevTools Protocol did not become available on port $Port."
}

$chromeExe = Resolve-ChromePath -RequestedPath $ChromePath
$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    throw "Node.js is required for Chrome DevTools Protocol smoke execution."
}

$port = Get-FreeTcpPort
$tempRoot = [System.IO.Path]::GetTempPath()
$profileDir = Join-Path $tempRoot ("draxos-web-overlay-smoke-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
$chromeArgs = @(
    "--headless=new",
    "--disable-gpu",
    "--no-first-run",
    "--no-default-browser-check",
    "--disable-extensions",
    "--remote-debugging-port=$port",
    "--user-data-dir=$profileDir",
    "--window-size=1280,720",
    "about:blank"
)

$chrome = $null
$smokePassed = $false
$previousEnv = @{
    DRAXOS_WEB_OVERLAY_URL = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_URL", "Process")
    DRAXOS_WEB_OVERLAY_EXPECTED_RELEASE = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_EXPECTED_RELEASE", "Process")
    DRAXOS_WEB_OVERLAY_EXPECTED_VERSION = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_EXPECTED_VERSION", "Process")
    DRAXOS_WEB_OVERLAY_EXPECTED_CODE = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_EXPECTED_CODE", "Process")
    DRAXOS_WEB_OVERLAY_DIAGNOSTICS_DIR = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_DIAGNOSTICS_DIR", "Process")
    DRAXOS_WEB_OVERLAY_TIMEOUT_MS = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_TIMEOUT_MS", "Process")
    DRAXOS_WEB_OVERLAY_CDP_PORT = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_CDP_PORT", "Process")
    DRAXOS_WEB_OVERLAY_ALLOW_ACCESS = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ALLOW_ACCESS", "Process")
}

try {
    $chrome = Start-Process -FilePath $chromeExe -ArgumentList $chromeArgs -WindowStyle Hidden -PassThru
    Wait-ChromeCdp -Port $port

    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_URL", $WebUrl, "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_EXPECTED_RELEASE", $ExpectedReleaseRoot, "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_EXPECTED_VERSION", $ExpectedAppVersion, "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_EXPECTED_CODE", ([string]$ExpectedAppVersionCode), "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_DIAGNOSTICS_DIR", $DiagnosticsDir, "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_TIMEOUT_MS", ([string]($TimeoutSeconds * 1000)), "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_CDP_PORT", ([string]$port), "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ALLOW_ACCESS", ($(if ($AllowCloudflareAccess.IsPresent) { "1" } else { "0" })), "Process")

    $nodeScript = @'
import fs from 'node:fs';
import path from 'node:path';

const webUrl = process.env.DRAXOS_WEB_OVERLAY_URL;
const expectedReleaseRoot = process.env.DRAXOS_WEB_OVERLAY_EXPECTED_RELEASE || '';
const expectedAppVersion = process.env.DRAXOS_WEB_OVERLAY_EXPECTED_VERSION || '';
const expectedAppVersionCode = Number(process.env.DRAXOS_WEB_OVERLAY_EXPECTED_CODE || '0');
const diagnosticsDir = process.env.DRAXOS_WEB_OVERLAY_DIAGNOSTICS_DIR;
const timeoutMs = Number(process.env.DRAXOS_WEB_OVERLAY_TIMEOUT_MS || '90000');
const cdpPort = process.env.DRAXOS_WEB_OVERLAY_CDP_PORT;
const allowCloudflareAccess = process.env.DRAXOS_WEB_OVERLAY_ALLOW_ACCESS === '1';
const startedAt = Date.now();

if (typeof WebSocket !== 'function') {
	throw new Error('Node.js global WebSocket is unavailable.');
}

function sleep(ms) {
	return new Promise((resolve) => setTimeout(resolve, ms));
}

async function cdpFetch(pathname, options = {}) {
	const response = await fetch(`http://127.0.0.1:${cdpPort}${pathname}`, options);
	if (!response.ok) {
		throw new Error(`CDP ${pathname} returned HTTP ${response.status}`);
	}
	return response.json();
}

class CdpClient {
	constructor(webSocketUrl) {
		this.webSocketUrl = webSocketUrl;
		this.nextId = 1;
		this.pending = new Map();
		this.listeners = new Map();
	}

	async connect() {
		this.socket = new WebSocket(this.webSocketUrl);
		this.socket.addEventListener('message', (event) => this.handleMessage(event));
		await new Promise((resolve, reject) => {
			this.socket.addEventListener('open', resolve, { once: true });
			this.socket.addEventListener('error', reject, { once: true });
		});
	}

	handleMessage(event) {
		const message = JSON.parse(event.data);
		if (message.id && this.pending.has(message.id)) {
			const pending = this.pending.get(message.id);
			this.pending.delete(message.id);
			if (message.error) {
				pending.reject(new Error(`${pending.method}: ${message.error.message}`));
			} else {
				pending.resolve(message.result || {});
			}
			return;
		}
		const handlers = this.listeners.get(message.method) || [];
		for (const handler of handlers) {
			handler(message.params || {});
		}
	}

	on(method, handler) {
		const handlers = this.listeners.get(method) || [];
		handlers.push(handler);
		this.listeners.set(method, handlers);
	}

	send(method, params = {}) {
		const id = this.nextId++;
		this.socket.send(JSON.stringify({ id, method, params }));
		return new Promise((resolve, reject) => {
			this.pending.set(id, { method, resolve, reject });
		});
	}

	close() {
		if (this.socket) {
			this.socket.close();
		}
	}
}

function resultValue(evaluation) {
	if (!evaluation || !evaluation.result) {
		return null;
	}
	if ('value' in evaluation.result) {
		return evaluation.result.value;
	}
	if (evaluation.result.type === 'undefined') {
		return null;
	}
	return evaluation.result.description || null;
}

function smokeUrl(label) {
	const url = new URL(webUrl);
	url.searchParams.set('draxos_smoke', 'overlay-account');
	url.searchParams.set('draxos_smoke_case', label);
	url.searchParams.set('draxos_smoke_nonce', `${Date.now()}-${Math.random().toString(16).slice(2)}`);
	return url.toString();
}

function isCloudflareAccessState(state) {
	const text = `${state?.title || ''}\n${state?.bodyText || ''}`;
	return /Cloudflare Access/i.test(text) || /Sign in .* Cloudflare/i.test(text);
}

function isKeyAsset(url) {
	return /\/index\.(js|pck|wasm)(\?|$)/.test(url);
}

async function capture(client, name) {
	const screenshotPath = path.join(diagnosticsDir, `${name}.png`);
	try {
		const screenshot = await client.send('Page.captureScreenshot', {
			format: 'png',
			captureBeyondViewport: false,
		});
		fs.writeFileSync(screenshotPath, Buffer.from(screenshot.data, 'base64'));
		return screenshotPath;
	} catch (err) {
		return `capture_failed:${err.message || err}`;
	}
}

async function readState(client) {
	const evaluation = await client.send('Runtime.evaluate', {
		returnByValue: true,
		expression: `(() => {
			const canvas = document.querySelector('canvas');
			const rect = canvas ? canvas.getBoundingClientRect() : null;
			const state = window.DRAXOS_GODOT_STATE || null;
			const release = window.DRAXOS_WEB_RELEASE || null;
			return {
				href: window.location.href,
				title: document.title || '',
				bodyText: document.body ? document.body.innerText.slice(0, 2000) : '',
				canvasCount: document.querySelectorAll('canvas').length,
				canvasRect: rect ? { left: rect.left, top: rect.top, right: rect.right, bottom: rect.bottom, width: rect.width, height: rect.height } : null,
				activeElement: document.activeElement ? document.activeElement.tagName : '',
				state,
				release,
			};
		})()`,
	});
	return resultValue(evaluation);
}

function assertExpectedBuild(state, label) {
	if (!state) {
		throw new Error(`${label}: no browser state was returned.`);
	}
	if (isCloudflareAccessState(state)) {
		if (allowCloudflareAccess) {
			return 'cloudflare_access_expected';
		}
		throw new Error(`${label}: Cloudflare Access page was returned.`);
	}
	if (!state.state) {
		throw new Error(`${label}: window.DRAXOS_GODOT_STATE was not exposed.`);
	}
	if (expectedAppVersion && state.state.appVersion !== expectedAppVersion) {
		throw new Error(`${label}: expected app version ${expectedAppVersion}, got ${state.state.appVersion}.`);
	}
	if (expectedAppVersionCode && Number(state.state.appVersionCode) !== expectedAppVersionCode) {
		throw new Error(`${label}: expected app code ${expectedAppVersionCode}, got ${state.state.appVersionCode}.`);
	}
	const releaseRoot = state.release?.releaseRoot || '';
	if (expectedReleaseRoot && releaseRoot !== expectedReleaseRoot) {
		throw new Error(`${label}: expected release root ${expectedReleaseRoot}, got ${releaseRoot || '<missing>'}.`);
	}
	return 'ok';
}

async function waitFor(client, predicate, label) {
	const deadline = Date.now() + timeoutMs;
	let lastState = null;
	while (Date.now() < deadline) {
		lastState = await readState(client);
		if (isCloudflareAccessState(lastState)) {
			if (allowCloudflareAccess) {
				return { state: lastState, access: true };
			}
			throw new Error(`${label}: Cloudflare Access page was returned.`);
		}
		if (lastState && predicate(lastState)) {
			return { state: lastState, access: false };
		}
		await sleep(250);
	}
	throw new Error(`${label}: timed out. Last state: ${JSON.stringify(lastState, null, 2)}`);
}

async function waitForOverlayOpen(client, label) {
	return waitFor(client, (state) => {
		return state.canvasCount > 0 &&
			state.state &&
			state.state.currentScreen === 'mode_shell' &&
			state.state.overlayOpen === true &&
			state.state.overlayRoute === 'account';
	}, `${label}: overlay open`);
}

async function waitForOverlayClosed(client, label) {
	return waitFor(client, (state) => {
		return state.canvasCount > 0 &&
			state.state &&
			state.state.currentScreen === 'mode_shell' &&
			state.state.overlayOpen === false;
	}, `${label}: overlay close`);
}

function overlayChromePoint(state, control) {
	const rect = state.canvasRect;
	if (!rect) {
		throw new Error(`No canvas rect available for ${control}.`);
	}
	const y = rect.top + 48;
	if (control === 'close') {
		return { x: rect.right - 58, y };
	}
	const panelWidth = Math.min(640, Math.max(440, rect.width * 0.42));
	const panelLeft = rect.right - panelWidth - 24;
	return { x: panelLeft + 56, y };
}

async function clickPoint(client, point) {
	await client.send('Input.dispatchMouseEvent', {
		type: 'mousePressed',
		x: point.x,
		y: point.y,
		button: 'left',
		buttons: 1,
		clickCount: 1,
	});
	await client.send('Input.dispatchMouseEvent', {
		type: 'mouseReleased',
		x: point.x,
		y: point.y,
		button: 'left',
		buttons: 0,
		clickCount: 1,
	});
}

async function pressEscape(client) {
	await client.send('Input.dispatchKeyEvent', {
		type: 'keyDown',
		key: 'Escape',
		code: 'Escape',
		windowsVirtualKeyCode: 27,
		nativeVirtualKeyCode: 27,
	});
	await client.send('Input.dispatchKeyEvent', {
		type: 'keyUp',
		key: 'Escape',
		code: 'Escape',
		windowsVirtualKeyCode: 27,
		nativeVirtualKeyCode: 27,
	});
}

const target = await cdpFetch(`/json/new?${encodeURIComponent('about:blank')}`, { method: 'PUT' });
const client = new CdpClient(target.webSocketDebuggerUrl);
await client.connect();

const consoleEvents = [];
const runtimeErrors = [];
const networkEvents = [];
const successfulKeyAssets = new Set();
const keyAssetFailures = [];
const requestUrls = new Map();

client.on('Runtime.consoleAPICalled', (params) => {
	const args = (params.args || []).map((arg) => arg.value ?? arg.description ?? arg.type).join(' ');
	consoleEvents.push({ type: params.type, text: args, timestamp: Date.now() - startedAt });
});
client.on('Runtime.exceptionThrown', (params) => {
	runtimeErrors.push({
		text: params.exceptionDetails?.text || 'Runtime exception',
		exception: params.exceptionDetails?.exception?.description || '',
		timestamp: Date.now() - startedAt,
	});
});
client.on('Network.requestWillBeSent', (params) => {
	if (params.requestId && params.request?.url) {
		requestUrls.set(params.requestId, params.request.url);
	}
});
client.on('Network.responseReceived', (params) => {
	const response = params.response || {};
	const event = { url: response.url || '', status: response.status || 0, timestamp: Date.now() - startedAt };
	if (isKeyAsset(event.url) || event.status >= 400) {
		networkEvents.push(event);
	}
	if (isKeyAsset(event.url) && event.status >= 200 && event.status < 400) {
		successfulKeyAssets.add(event.url);
	}
	if (isKeyAsset(event.url) && event.status >= 400) {
		keyAssetFailures.push(event);
	}
});
client.on('Network.loadingFailed', (params) => {
	const url = requestUrls.get(params.requestId) || '';
	const event = {
		requestId: params.requestId,
		url,
		errorText: params.errorText,
		blockedReason: params.blockedReason || '',
		timestamp: Date.now() - startedAt,
	};
	networkEvents.push(event);
	if (isKeyAsset(url)) {
		keyAssetFailures.push(event);
	}
});

const screenshots = [];
const interactionResults = [];
let outcome = 'failed';
let failureReason = '';
let finalState = null;

try {
	await client.send('Runtime.enable');
	await client.send('Network.enable');
	await client.send('Network.setCacheDisabled', { cacheDisabled: true });
	await client.send('Page.enable');

	for (const control of ['close', 'back', 'escape']) {
		await client.send('Page.navigate', { url: smokeUrl(control) });
		const openResult = await waitForOverlayOpen(client, control);
		if (openResult.access) {
			outcome = 'cloudflare_access_expected';
			finalState = openResult.state;
			break;
		}
		assertExpectedBuild(openResult.state, control);
		screenshots.push(await capture(client, `overlay-${control}-open`));

		if (control === 'escape') {
			const focusPoint = overlayChromePoint(openResult.state, 'close');
			await clickPoint(client, { x: Math.max(4, focusPoint.x - 200), y: focusPoint.y });
			await sleep(150);
			await pressEscape(client);
		} else {
			await clickPoint(client, overlayChromePoint(openResult.state, control));
		}

		const closedResult = await waitForOverlayClosed(client, control);
		finalState = closedResult.state;
		screenshots.push(await capture(client, `overlay-${control}-closed`));
		interactionResults.push({
			control,
			opened_route: openResult.state.state.overlayRoute,
			closed_overlay_open: closedResult.state.state.overlayOpen,
			active_route_after_close: closedResult.state.state.activeRoute,
		});
	}
	if (outcome !== 'cloudflare_access_expected') {
		outcome = 'overlay_controls_passed';
	}
} catch (err) {
	failureReason = err.message || String(err);
	finalState = await readState(client).catch(() => finalState);
	screenshots.push(await capture(client, 'overlay-failure'));
} finally {
	client.close();
}

const unresolvedKeyAssetFailures = keyAssetFailures.filter((event) => {
	return !(event.errorText === 'net::ERR_ABORTED' && successfulKeyAssets.has(event.url));
});
const unresolvedRuntimeErrors = outcome === 'cloudflare_access_expected' ? [] : runtimeErrors;

const summary = {
	schema_version: 'draxos_mobile_web_overlay_controls_smoke_v1',
	web_url: webUrl,
	expected_release_root: expectedReleaseRoot,
	expected_app_version: expectedAppVersion,
	expected_app_version_code: expectedAppVersionCode,
	allow_cloudflare_access: allowCloudflareAccess,
	outcome,
	failure_reason: failureReason,
	elapsed_ms: Date.now() - startedAt,
	interaction_results: interactionResults,
	final_state: finalState,
	screenshots,
	key_asset_failures: unresolvedKeyAssetFailures,
	successful_key_assets: Array.from(successfulKeyAssets),
	runtime_errors: runtimeErrors,
	network_events: networkEvents,
	console_events: consoleEvents,
};

const summaryPath = path.join(diagnosticsDir, 'web-overlay-controls-summary.json');
fs.writeFileSync(summaryPath, JSON.stringify(summary, null, 2));
console.log(JSON.stringify(summary, null, 2));

const failed = failureReason ||
	unresolvedKeyAssetFailures.length > 0 ||
	unresolvedRuntimeErrors.length > 0 ||
	(outcome !== 'overlay_controls_passed' && outcome !== 'cloudflare_access_expected');

if (failed) {
	process.exitCode = 1;
}
'@

    $nodeScriptPath = Join-Path $DiagnosticsDir "web-overlay-controls-cdp.mjs"
    [System.IO.File]::WriteAllText($nodeScriptPath, $nodeScript, [System.Text.UTF8Encoding]::new($false))
    Push-Location -LiteralPath $ProjectDir
    try {
        & $node.Path $nodeScriptPath
        if ($LASTEXITCODE -ne 0) {
            throw "Web overlay controls smoke failed. Diagnostics: $DiagnosticsDir"
        }
    } finally {
        Pop-Location
    }
    Write-Host "Web overlay controls smoke passed."
    Write-Host "Diagnostics: $DiagnosticsDir"
    $smokePassed = $true
} finally {
    foreach ($key in $previousEnv.Keys) {
        [Environment]::SetEnvironmentVariable($key, $previousEnv[$key], "Process")
    }
    if ($chrome -and -not $chrome.HasExited) {
        Stop-Process -Id $chrome.Id -Force -ErrorAction SilentlyContinue
    }
    $resolvedTemp = [System.IO.Path]::GetFullPath($profileDir)
    $resolvedTempRoot = [System.IO.Path]::GetFullPath($tempRoot)
    if (-not $resolvedTempRoot.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $resolvedTempRoot += [System.IO.Path]::DirectorySeparatorChar
    }
    if ($resolvedTemp.StartsWith($resolvedTempRoot, [System.StringComparison]::OrdinalIgnoreCase) -and
        (Test-Path -LiteralPath $resolvedTemp -PathType Container)) {
        Remove-Item -LiteralPath $resolvedTemp -Recurse -Force -ErrorAction SilentlyContinue
    }
    if ($NoProjectWrites.IsPresent -and $diagnosticsWasDefaulted -and -not $KeepDiagnostics.IsPresent -and
        $smokePassed -and (Test-Path -LiteralPath $DiagnosticsDir -PathType Container)) {
        Remove-Item -LiteralPath $DiagnosticsDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
