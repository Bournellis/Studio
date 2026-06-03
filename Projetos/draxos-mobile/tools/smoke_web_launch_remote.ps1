param(
    [Parameter(Mandatory = $true)]
    [string]$WebUrl,
    [string]$ExpectedReleaseRoot = "",
    [string]$ChromePath = "",
    [int]$TimeoutSeconds = 60,
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
        $DiagnosticsDir = Join-Path ([System.IO.Path]::GetTempPath()) "draxos-mobile-web-launch-remote-$stamp"
    } else {
        $DiagnosticsDir = Join-Path $ProjectDir "build\diagnostics\web-launch-remote-$stamp"
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
$profileDir = Join-Path $tempRoot ("draxos-web-launch-smoke-" + [System.Guid]::NewGuid().ToString("N"))
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
    DRAXOS_WEB_SMOKE_URL = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_SMOKE_URL", "Process")
    DRAXOS_WEB_SMOKE_EXPECTED_RELEASE = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_SMOKE_EXPECTED_RELEASE", "Process")
    DRAXOS_WEB_SMOKE_DIAGNOSTICS_DIR = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_SMOKE_DIAGNOSTICS_DIR", "Process")
    DRAXOS_WEB_SMOKE_TIMEOUT_MS = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_SMOKE_TIMEOUT_MS", "Process")
    DRAXOS_WEB_SMOKE_CDP_PORT = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_SMOKE_CDP_PORT", "Process")
    DRAXOS_WEB_SMOKE_ALLOW_ACCESS = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_SMOKE_ALLOW_ACCESS", "Process")
}

try {
    $chrome = Start-Process -FilePath $chromeExe -ArgumentList $chromeArgs -WindowStyle Hidden -PassThru
    Wait-ChromeCdp -Port $port

    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_SMOKE_URL", $WebUrl, "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_SMOKE_EXPECTED_RELEASE", $ExpectedReleaseRoot, "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_SMOKE_DIAGNOSTICS_DIR", $DiagnosticsDir, "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_SMOKE_TIMEOUT_MS", ([string]($TimeoutSeconds * 1000)), "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_SMOKE_CDP_PORT", ([string]$port), "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_SMOKE_ALLOW_ACCESS", ($(if ($AllowCloudflareAccess.IsPresent) { "1" } else { "0" })), "Process")

    $nodeScript = @'
import fs from 'node:fs';
import path from 'node:path';

const webUrl = process.env.DRAXOS_WEB_SMOKE_URL;
const expectedReleaseRoot = process.env.DRAXOS_WEB_SMOKE_EXPECTED_RELEASE || '';
const diagnosticsDir = process.env.DRAXOS_WEB_SMOKE_DIAGNOSTICS_DIR;
const timeoutMs = Number(process.env.DRAXOS_WEB_SMOKE_TIMEOUT_MS || '60000');
const cdpPort = process.env.DRAXOS_WEB_SMOKE_CDP_PORT;
const allowCloudflareAccess = process.env.DRAXOS_WEB_SMOKE_ALLOW_ACCESS === '1';
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

function isKeyAsset(url) {
	return /\/index\.(js|pck|wasm)(\?|$)/.test(url);
}

function isCloudflareAccessState(state) {
	const text = `${state.title || ''}\n${state.bodyText || ''}`;
	return /Cloudflare Access/i.test(text) || /Sign in .* Cloudflare/i.test(text);
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

const target = await cdpFetch(`/json/new?${encodeURIComponent('about:blank')}`, { method: 'PUT' });
const client = new CdpClient(target.webSocketDebuggerUrl);
await client.connect();

const consoleEvents = [];
const networkEvents = [];
const runtimeErrors = [];
const keyAssetFailures = [];
const keyAssetLoadingFailures = [];
const successfulKeyAssets = new Set();
const requestUrls = new Map();

client.on('Runtime.consoleAPICalled', (params) => {
	const args = (params.args || []).map((arg) => arg.value ?? arg.description ?? arg.type).join(' ');
	consoleEvents.push({
		type: params.type,
		text: args,
		timestamp: Date.now() - startedAt,
	});
});
client.on('Runtime.exceptionThrown', (params) => {
	runtimeErrors.push({
		text: params.exceptionDetails?.text || 'Runtime exception',
		exception: params.exceptionDetails?.exception?.description || '',
		timestamp: Date.now() - startedAt,
	});
});
client.on('Log.entryAdded', (params) => {
	const entry = params.entry || {};
	if (entry.level === 'error') {
		runtimeErrors.push({
			text: entry.text || 'Log error',
			source: entry.source || '',
			timestamp: Date.now() - startedAt,
		});
	}
});
client.on('Network.responseReceived', (params) => {
	const response = params.response || {};
	const event = {
		url: response.url || '',
		status: response.status || 0,
		mimeType: response.mimeType || '',
		timestamp: Date.now() - startedAt,
	};
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
client.on('Network.requestWillBeSent', (params) => {
	if (params.requestId && params.request?.url) {
		requestUrls.set(params.requestId, params.request.url);
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
		keyAssetLoadingFailures.push(event);
	}
});

await client.send('Runtime.enable');
await client.send('Log.enable');
await client.send('Network.enable');
await client.send('Network.setCacheDisabled', { cacheDisabled: true });
await client.send('Page.enable');
await client.send('Page.setLifecycleEventsEnabled', { enabled: true });
await client.send('Page.navigate', { url: webUrl });

let lastState = null;
let outcome = 'timeout';
let loadedAfterMs = null;
let failureReason = '';

while (Date.now() - startedAt < timeoutMs) {
	await sleep(1000);
	const evaluation = await client.send('Runtime.evaluate', {
		returnByValue: true,
		expression: `(() => {
			const status = document.querySelector('#status');
			const statusStyle = status ? window.getComputedStyle(status) : null;
			const statusText = status ? status.innerText || status.textContent || '' : '';
			const release = window.DRAXOS_WEB_RELEASE || null;
			return {
				href: window.location.href,
				title: document.title || '',
				bodyText: document.body ? document.body.innerText.slice(0, 2000) : '',
				hasGodotConfig: document.documentElement ? document.documentElement.outerHTML.includes('GODOT_CONFIG') : false,
				release,
				canvasCount: document.querySelectorAll('canvas').length,
				hasStatus: !!status,
				statusVisible: !!status && statusStyle && statusStyle.display !== 'none' && statusStyle.visibility !== 'hidden',
				statusText,
			};
		})()`,
	});
	lastState = resultValue(evaluation);
	if (!lastState) {
		continue;
	}
	if (isCloudflareAccessState(lastState)) {
		if (allowCloudflareAccess) {
			outcome = 'cloudflare_access_expected';
			loadedAfterMs = Date.now() - startedAt;
			break;
		}
		failureReason = 'Cloudflare Access page was returned for an anonymous Web launch smoke.';
		break;
	}
	if (lastState.statusText && /nao conseguiu iniciar|following features required|unknown error/i.test(lastState.statusText)) {
		failureReason = `Godot status notice reported a launch failure: ${lastState.statusText}`;
		break;
	}
	const releaseRoot = lastState.release?.releaseRoot || '';
	if (expectedReleaseRoot && lastState.hasGodotConfig && !releaseRoot) {
		failureReason = `Expected release root ${expectedReleaseRoot}, but the Web shell did not expose window.DRAXOS_WEB_RELEASE.`;
		break;
	}
	if (expectedReleaseRoot && releaseRoot && releaseRoot !== expectedReleaseRoot) {
		failureReason = `Release root mismatch. Expected ${expectedReleaseRoot}, got ${releaseRoot}.`;
		break;
	}
	if (lastState.hasGodotConfig && !lastState.hasStatus && lastState.canvasCount > 0) {
		outcome = 'game_loaded';
		loadedAfterMs = Date.now() - startedAt;
		break;
	}
}

const screenshotPath = path.join(diagnosticsDir, 'web-launch-remote.png');
try {
	const screenshot = await client.send('Page.captureScreenshot', {
		format: 'png',
		captureBeyondViewport: false,
	});
	fs.writeFileSync(screenshotPath, Buffer.from(screenshot.data, 'base64'));
} catch (err) {
	console.error('Screenshot capture failed:', err);
}
client.close();

const unresolvedKeyAssetFailures = keyAssetFailures.concat(keyAssetLoadingFailures.filter((event) => {
	return !(outcome === 'game_loaded' && event.errorText === 'net::ERR_ABORTED' && successfulKeyAssets.has(event.url));
}));
const unresolvedRuntimeErrors = outcome === 'cloudflare_access_expected' ? [] : runtimeErrors;

const summary = {
	schema_version: 'draxos_mobile_web_launch_smoke_v1',
	web_url: webUrl,
	expected_release_root: expectedReleaseRoot,
	allow_cloudflare_access: allowCloudflareAccess,
	outcome,
	loaded_after_ms: loadedAfterMs,
	failure_reason: failureReason,
	screenshot_path: screenshotPath,
	last_state: lastState,
	key_asset_failures: unresolvedKeyAssetFailures,
	key_asset_loading_failures: keyAssetLoadingFailures,
	successful_key_assets: Array.from(successfulKeyAssets),
	runtime_errors: runtimeErrors,
	network_events: networkEvents,
	console_events: consoleEvents,
};

const summaryPath = path.join(diagnosticsDir, 'web-launch-remote-summary.json');
fs.writeFileSync(summaryPath, JSON.stringify(summary, null, 2));
console.log(JSON.stringify(summary, null, 2));

const failed = failureReason ||
	unresolvedKeyAssetFailures.length > 0 ||
	unresolvedRuntimeErrors.length > 0 ||
	(outcome !== 'game_loaded' && outcome !== 'cloudflare_access_expected');

if (failed) {
	process.exitCode = 1;
}
'@

    $nodeScriptPath = Join-Path $DiagnosticsDir "web-launch-remote-cdp.mjs"
    [System.IO.File]::WriteAllText($nodeScriptPath, $nodeScript, [System.Text.UTF8Encoding]::new($false))
    Push-Location -LiteralPath $ProjectDir
    try {
        & $node.Path $nodeScriptPath
        if ($LASTEXITCODE -ne 0) {
            throw "Remote Web launch smoke failed. Diagnostics: $DiagnosticsDir"
        }
    } finally {
        Pop-Location
    }
    Write-Host "Remote Web launch smoke passed."
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
