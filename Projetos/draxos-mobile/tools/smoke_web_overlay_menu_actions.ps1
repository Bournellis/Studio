param(
    [Parameter(Mandatory = $true)]
    [string]$WebUrl,
    [string]$ExpectedReleaseRoot = "",
    [string]$ExpectedAppVersion = "0.0.21-alpha.0",
    [int]$ExpectedAppVersionCode = 21,
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
        $DiagnosticsDir = Join-Path ([System.IO.Path]::GetTempPath()) "draxos-mobile-web-overlay-menu-actions-$stamp"
    } else {
        $DiagnosticsDir = Join-Path $ProjectDir "build\diagnostics\web-overlay-menu-actions-$stamp"
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
$profileDir = Join-Path $tempRoot ("draxos-web-overlay-menu-actions-" + [System.Guid]::NewGuid().ToString("N"))
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
    DRAXOS_WEB_OVERLAY_ACTIONS_URL = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_URL", "Process")
    DRAXOS_WEB_OVERLAY_ACTIONS_EXPECTED_RELEASE = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_EXPECTED_RELEASE", "Process")
    DRAXOS_WEB_OVERLAY_ACTIONS_EXPECTED_VERSION = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_EXPECTED_VERSION", "Process")
    DRAXOS_WEB_OVERLAY_ACTIONS_EXPECTED_CODE = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_EXPECTED_CODE", "Process")
    DRAXOS_WEB_OVERLAY_ACTIONS_DIAGNOSTICS_DIR = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_DIAGNOSTICS_DIR", "Process")
    DRAXOS_WEB_OVERLAY_ACTIONS_TIMEOUT_MS = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_TIMEOUT_MS", "Process")
    DRAXOS_WEB_OVERLAY_ACTIONS_CDP_PORT = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_CDP_PORT", "Process")
    DRAXOS_WEB_OVERLAY_ACTIONS_ALLOW_ACCESS = [Environment]::GetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_ALLOW_ACCESS", "Process")
}

try {
    $chrome = Start-Process -FilePath $chromeExe -ArgumentList $chromeArgs -WindowStyle Hidden -PassThru
    Wait-ChromeCdp -Port $port

    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_URL", $WebUrl, "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_EXPECTED_RELEASE", $ExpectedReleaseRoot, "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_EXPECTED_VERSION", $ExpectedAppVersion, "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_EXPECTED_CODE", ([string]$ExpectedAppVersionCode), "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_DIAGNOSTICS_DIR", $DiagnosticsDir, "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_TIMEOUT_MS", ([string]($TimeoutSeconds * 1000)), "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_CDP_PORT", ([string]$port), "Process")
    [Environment]::SetEnvironmentVariable("DRAXOS_WEB_OVERLAY_ACTIONS_ALLOW_ACCESS", ($(if ($AllowCloudflareAccess.IsPresent) { "1" } else { "0" })), "Process")

    $nodeScript = @'
import fs from 'node:fs';
import path from 'node:path';

const webUrl = process.env.DRAXOS_WEB_OVERLAY_ACTIONS_URL;
const expectedReleaseRoot = process.env.DRAXOS_WEB_OVERLAY_ACTIONS_EXPECTED_RELEASE || '';
const expectedAppVersion = process.env.DRAXOS_WEB_OVERLAY_ACTIONS_EXPECTED_VERSION || '';
const expectedAppVersionCode = Number(process.env.DRAXOS_WEB_OVERLAY_ACTIONS_EXPECTED_CODE || '0');
const diagnosticsDir = process.env.DRAXOS_WEB_OVERLAY_ACTIONS_DIAGNOSTICS_DIR;
const timeoutMs = Number(process.env.DRAXOS_WEB_OVERLAY_ACTIONS_TIMEOUT_MS || '90000');
const cdpPort = process.env.DRAXOS_WEB_OVERLAY_ACTIONS_CDP_PORT;
const allowCloudflareAccess = process.env.DRAXOS_WEB_OVERLAY_ACTIONS_ALLOW_ACCESS === '1';
const startedAt = Date.now();

if (typeof WebSocket !== 'function') {
	throw new Error('Node.js global WebSocket is unavailable.');
}

const cases = [
	{ label: 'account-check-update', smoke: 'overlay-account', route: 'account', button: 'Checar update', action: 'check_update', expectClosed: false },
	{ label: 'base-sync', smoke: 'overlay-base', route: 'base_management', button: 'Sincronizar Refugio', action: 'show_base', expectClosed: false },
	{ label: 'shop-refresh', smoke: 'overlay-shop', route: 'shop', button: 'Atualizar loja', action: 'show_shop', expectClosed: false },
	{ label: 'social-refresh', smoke: 'overlay-social', route: 'social', button: 'Atualizar social', action: 'show_social', expectClosed: false },
	{ label: 'arena-return-refuge', smoke: 'overlay-arena', route: 'arena_selection', button: 'Voltar ao Refugio', action: 'return_refuge', expectClosed: true },
];

const interactiveCases = [
	{
		label: 'social-type-add-friend',
		smoke: 'overlay-social-form',
		route: 'social',
		kind: 'social_text_action',
		lineEditPlaceholder: 'guest_12345678',
		text: 'web_smoke_friend',
		button: 'Adicionar amigo',
		action: 'add_friend',
	},
	{
		label: 'shop-confirm-buy-energy',
		smoke: 'overlay-shop-confirm',
		route: 'shop',
		kind: 'shop_confirm',
		button: 'Comprar Energia',
		action: 'shop_purchase:alpha_energy_pack_small',
	},
	{
		label: 'arena-resume-abandon-active',
		smoke: 'overlay-arena-active',
		route: 'arena_selection',
		kind: 'arena_resume_abandon',
		resumeButton: 'Retomar tentativa',
		resumeAction: 'arena_resume_attempt',
		abandonButton: 'Abandonar tentativa',
		abandonAction: 'arena_abandon_attempt',
	},
];

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
		if (!message.id || !this.pending.has(message.id)) {
			return;
		}
		const pending = this.pending.get(message.id);
		this.pending.delete(message.id);
		if (message.error) {
			pending.reject(new Error(`${pending.method}: ${message.error.message}`));
		} else {
			pending.resolve(message.result || {});
		}
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
	if (!evaluation || !evaluation.result) return null;
	if ('value' in evaluation.result) return evaluation.result.value;
	if (evaluation.result.type === 'undefined') return null;
	return evaluation.result.description || null;
}

function smokeUrl(smoke, label) {
	const url = new URL(webUrl);
	url.searchParams.set('draxos_smoke', smoke);
	url.searchParams.set('draxos_smoke_case', label);
	url.searchParams.set('draxos_smoke_nonce', `${Date.now()}-${Math.random().toString(16).slice(2)}`);
	return url.toString();
}

function isCloudflareAccessState(state) {
	const text = `${state?.title || ''}\n${state?.bodyText || ''}`;
	return /Cloudflare Access/i.test(text) || /Sign in .* Cloudflare/i.test(text);
}

async function readState(client) {
	const evaluation = await client.send('Runtime.evaluate', {
		returnByValue: true,
		expression: `(() => {
			const canvas = document.querySelector('canvas');
			const rect = canvas ? canvas.getBoundingClientRect() : null;
			return {
				href: window.location.href,
				title: document.title || '',
				bodyText: document.body ? document.body.innerText.slice(0, 2000) : '',
				canvasCount: document.querySelectorAll('canvas').length,
				canvasRect: rect ? { left: rect.left, top: rect.top, right: rect.right, bottom: rect.bottom, width: rect.width, height: rect.height } : null,
				state: window.DRAXOS_GODOT_STATE || null,
				release: window.DRAXOS_WEB_RELEASE || null,
			};
		})()`,
	});
	return resultValue(evaluation);
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

function assertBuild(state, label) {
	if (isCloudflareAccessState(state)) {
		if (allowCloudflareAccess) return 'cloudflare_access_expected';
		throw new Error(`${label}: Cloudflare Access page was returned.`);
	}
	if (!state?.state) {
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
			if (allowCloudflareAccess) return { state: lastState, access: true };
			throw new Error(`${label}: Cloudflare Access page was returned.`);
		}
		if (lastState && predicate(lastState)) {
			return { state: lastState, access: false };
		}
		await sleep(250);
	}
	throw new Error(`${label}: timed out. Last state: ${JSON.stringify(lastState, null, 2)}`);
}

function centerOf(rect) {
	return { x: rect.x + rect.width / 2, y: rect.y + rect.height / 2 };
}

function rectContains(rect, point) {
	return rect && point &&
		point.x >= rect.x &&
		point.x <= rect.x + rect.width &&
		point.y >= rect.y &&
		point.y <= rect.y + rect.height;
}

function visibleControl(state, control) {
	const point = centerOf(control);
	const panel = state.state?.overlayPanel || null;
	const viewport = state.state?.viewportSize || {};
	const viewportWidth = Number(viewport.width || state.canvasRect?.width || 0);
	const viewportHeight = Number(viewport.height || state.canvasRect?.height || 0);
	return rectContains(panel, point) &&
		viewportWidth > 0 &&
		viewportHeight > 0 &&
		point.x >= 0 &&
		point.y >= 0 &&
		point.x <= viewportWidth &&
		point.y <= viewportHeight;
}

function visibleButton(state, button) {
	return visibleControl(state, button);
}

function scrollDeltaForControl(state, control) {
	if (!control) return 420;
	const point = centerOf(control);
	const panel = state.state?.overlayPanel || null;
	const viewport = state.state?.viewportSize || {};
	const viewportHeight = Number(viewport.height || state.canvasRect?.height || 0);
	const top = Math.max(Number(panel?.y || 0), 0) + 20;
	const bottom = Math.min(Number((panel?.y || 0) + (panel?.height || viewportHeight)), viewportHeight) - 20;
	if (point.y < top) return -420;
	if (point.y > bottom) return 420;
	return 0;
}

function scrollDeltaForButton(state, button) {
	return scrollDeltaForControl(state, button);
}

function controlPoint(state, control) {
	const point = centerOf(control);
	const canvasRect = state.canvasRect;
	const viewport = state.state?.viewportSize || {};
	const scaleX = canvasRect.width / Number(viewport.width || canvasRect.width);
	const scaleY = canvasRect.height / Number(viewport.height || canvasRect.height);
	return {
		x: canvasRect.left + point.x * scaleX,
		y: canvasRect.top + point.y * scaleY,
	};
}

function buttonPoint(state, button) {
	return controlPoint(state, button);
}

function panelPoint(state) {
	const panel = state.state?.overlayPanel || null;
	const canvasRect = state.canvasRect;
	if (!panel || !canvasRect) {
		throw new Error('Overlay panel diagnostics are missing.');
	}
	const viewport = state.state?.viewportSize || {};
	const viewportWidth = Number(viewport.width || canvasRect.width);
	const viewportHeight = Number(viewport.height || canvasRect.height);
	const scaleX = canvasRect.width / viewportWidth;
	const scaleY = canvasRect.height / viewportHeight;
	const visibleLeft = Math.max(panel.x, 0);
	const visibleTop = Math.max(panel.y, 0);
	const visibleRight = Math.min(panel.x + panel.width, viewportWidth);
	const visibleBottom = Math.min(panel.y + panel.height, viewportHeight);
	if (visibleRight <= visibleLeft || visibleBottom <= visibleTop) {
		throw new Error('Overlay panel has no visible intersection with the viewport.');
	}
	return {
		x: canvasRect.left + ((visibleLeft + visibleRight) * 0.5) * scaleX,
		y: canvasRect.top + ((visibleTop + visibleBottom) * 0.55) * scaleY,
	};
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

async function wheelOverlay(client, state, deltaY) {
	await client.send('Input.dispatchMouseEvent', {
		type: 'mouseWheel',
		...panelPoint(state),
		deltaX: 0,
		deltaY,
	});
}

function findControl(state, predicate) {
	const controls = Array.isArray(state.state?.overlayControls) ? state.state.overlayControls : [];
	return controls.find(predicate) || null;
}

function findButton(state, text) {
	const control = findControl(state, (item) => String(item.type || '') === 'button' && String(item.text || '') === text);
	if (control) return control;
	const buttons = Array.isArray(state.state?.overlayButtons) ? state.state.overlayButtons : [];
	return buttons.find((button) => String(button.text || '') === text) || null;
}

function findLineEdit(state, placeholder) {
	return findControl(state, (item) => {
		return String(item.type || '') === 'line_edit' &&
			(String(item.placeholder || '') === placeholder || String(item.placeholder || '').includes(placeholder));
	});
}

async function clickOverlayButton(client, label, text, expectedAction = '') {
	let beforeState = await readState(client);
	let candidate = null;
	for (let attempt = 0; attempt < 18; attempt += 1) {
		candidate = findButton(beforeState, text);
		if (candidate && visibleButton(beforeState, candidate)) {
			break;
		}
		const delta = scrollDeltaForButton(beforeState, candidate);
		if (delta === 0) {
			break;
		}
		await wheelOverlay(client, beforeState, delta);
		await sleep(150);
		beforeState = await readState(client);
	}
	if (!candidate) {
		throw new Error(`${label}: button '${text}' was not reported in overlayButtons.`);
	}
	if (!visibleButton(beforeState, candidate)) {
		throw new Error(`${label}: button '${text}' was reported but never became visible.`);
	}
	const beforeOverlaySequence = Number(beforeState.state?.overlayInput?.sequence || 0);
	const beforeActionSequence = Number(beforeState.state?.actionInput?.sequence || 0);
	await clickPoint(client, buttonPoint(beforeState, candidate));
	const clicked = await waitFor(client, (state) => {
		const overlayMatched = Number(state.state?.overlayInput?.sequence || 0) > beforeOverlaySequence &&
			String(state.state?.overlayInput?.last?.text || '') === text;
		const actionMatched = expectedAction &&
			Number(state.state?.actionInput?.sequence || 0) > beforeActionSequence &&
			String(state.state?.actionInput?.last?.action_id || '') === expectedAction &&
			Boolean(state.state?.actionInput?.last?.overlay_open) === true;
		return overlayMatched || actionMatched;
	}, `${label}: button '${text}' input`);
	return {
		button: candidate,
		before_overlay_sequence: beforeOverlaySequence,
		after_overlay_sequence: Number(clicked.state.state?.overlayInput?.sequence || 0),
		before_action_sequence: beforeActionSequence,
		after_action_sequence: Number(clicked.state.state?.actionInput?.sequence || 0),
		action_after_input: clicked.state.state?.actionInput?.last || null,
		state_after_input: clicked.state,
	};
}

async function focusOverlayLineEdit(client, label, placeholder) {
	let beforeState = await readState(client);
	let candidate = null;
	for (let attempt = 0; attempt < 18; attempt += 1) {
		candidate = findLineEdit(beforeState, placeholder);
		if (candidate && visibleControl(beforeState, candidate)) {
			break;
		}
		const delta = scrollDeltaForControl(beforeState, candidate);
		if (delta === 0) {
			break;
		}
		await wheelOverlay(client, beforeState, delta);
		await sleep(150);
		beforeState = await readState(client);
	}
	if (!candidate) {
		throw new Error(`${label}: line edit '${placeholder}' was not reported in overlayControls.`);
	}
	if (!visibleControl(beforeState, candidate)) {
		throw new Error(`${label}: line edit '${placeholder}' was reported but never became visible.`);
	}
	const beforeOverlaySequence = Number(beforeState.state?.overlayInput?.sequence || 0);
	await clickPoint(client, controlPoint(beforeState, candidate));
	const focused = await waitFor(client, (state) => {
		return Number(state.state?.overlayInput?.sequence || 0) > beforeOverlaySequence &&
			String(state.state?.focusedControl || '') === String(candidate.path || '');
	}, `${label}: focus line edit '${placeholder}'`);
	return {
		control: candidate,
		state_after_focus: focused.state,
	};
}

async function typeOverlayText(client, label, placeholder, text) {
	const focus = await focusOverlayLineEdit(client, label, placeholder);
	for (const char of text) {
		await client.send('Input.dispatchKeyEvent', {
			type: 'keyDown',
			key: char,
			text: char,
			unmodifiedText: char,
		});
		await client.send('Input.dispatchKeyEvent', {
			type: 'keyUp',
			key: char,
		});
		await sleep(20);
	}
	const typed = await waitFor(client, (state) => {
		const control = findLineEdit(state, placeholder);
		return control && String(control.text || '') === text;
	}, `${label}: type text '${text}'`);
	return {
		control: focus.control,
		state_after_text: typed.state,
	};
}

const target = await cdpFetch(`/json/new?${encodeURIComponent('about:blank')}`, { method: 'PUT' });
const client = new CdpClient(target.webSocketDebuggerUrl);
await client.connect();

const screenshots = [];
const results = [];
let outcome = 'failed';
let failureReason = '';
let finalState = null;

try {
	await client.send('Runtime.enable');
	await client.send('Network.enable');
	await client.send('Network.setCacheDisabled', { cacheDisabled: true });
	await client.send('Page.enable');

	for (const testCase of cases) {
		await client.send('Page.navigate', { url: smokeUrl(testCase.smoke, testCase.label) });
		const open = await waitFor(client, (state) => {
			return state.canvasCount > 0 &&
				state.state &&
				state.state.currentScreen === 'mode_shell' &&
				state.state.overlayOpen === true &&
				state.state.overlayRoute === testCase.route;
		}, `${testCase.label}: overlay open`);
		if (open.access) {
			outcome = 'cloudflare_access_expected';
			finalState = open.state;
			break;
		}
		assertBuild(open.state, testCase.label);
		screenshots.push(await capture(client, `${testCase.label}-open`));

		const click = await clickOverlayButton(client, testCase.label, testCase.button, testCase.action);
		const after = await waitFor(client, (state) => {
			if (!state.state) return false;
			if (testCase.expectClosed) {
				return state.state.currentScreen === 'mode_shell' && state.state.overlayOpen === false;
			}
			return state.state.currentScreen === 'mode_shell' &&
				state.state.overlayOpen === true &&
				state.state.overlayRoute === testCase.route;
		}, `${testCase.label}: post action state`);
		finalState = after.state;
		screenshots.push(await capture(client, `${testCase.label}-after`));
		results.push({
			label: testCase.label,
			smoke: testCase.smoke,
			route: testCase.route,
			button: testCase.button,
			action: testCase.action,
			before_overlay_sequence: click.before_overlay_sequence,
			after_overlay_sequence: click.after_overlay_sequence,
			before_action_sequence: click.before_action_sequence,
			after_action_sequence: click.after_action_sequence,
			action_after_input: click.action_after_input,
			overlay_open_after: Boolean(after.state.state?.overlayOpen),
			overlay_route_after: after.state.state?.overlayRoute || '',
			active_route_after: after.state.state?.activeRoute || '',
		});
	}
	for (const testCase of interactiveCases) {
		await client.send('Page.navigate', { url: smokeUrl(testCase.smoke, testCase.label) });
		const open = await waitFor(client, (state) => {
			return state.canvasCount > 0 &&
				state.state &&
				state.state.currentScreen === 'mode_shell' &&
				state.state.overlayOpen === true &&
				state.state.overlayRoute === testCase.route;
		}, `${testCase.label}: overlay open`);
		if (open.access) {
			outcome = 'cloudflare_access_expected';
			finalState = open.state;
			break;
		}
		assertBuild(open.state, testCase.label);
		screenshots.push(await capture(client, `${testCase.label}-open`));

		if (testCase.kind === 'social_text_action') {
			const typed = await typeOverlayText(client, testCase.label, testCase.lineEditPlaceholder, testCase.text);
			const click = await clickOverlayButton(client, testCase.label, testCase.button, testCase.action);
			const after = await waitFor(client, (state) => {
				return state.state &&
					state.state.currentScreen === 'mode_shell' &&
					state.state.overlayOpen === true &&
					state.state.overlayRoute === testCase.route &&
					String(state.state.actionInput?.last?.action_id || '') === testCase.action;
			}, `${testCase.label}: post social action state`);
			finalState = after.state;
			screenshots.push(await capture(client, `${testCase.label}-after`));
			results.push({
				label: testCase.label,
				smoke: testCase.smoke,
				route: testCase.route,
				kind: testCase.kind,
				line_edit_placeholder: testCase.lineEditPlaceholder,
				typed_text: testCase.text,
				button: testCase.button,
				action: testCase.action,
				focused_control_after_focus: typed.state_after_text.state?.focusedControl || '',
				action_after_input: click.action_after_input,
				overlay_route_after: after.state.state?.overlayRoute || '',
			});
		} else if (testCase.kind === 'shop_confirm') {
			const firstClick = await clickOverlayButton(client, testCase.label, testCase.button, '');
			const confirmOpen = await waitFor(client, (state) => {
				return state.state?.pendingConfirmation?.pending === true;
			}, `${testCase.label}: confirmation opens`);
			await clickOverlayButton(client, testCase.label, 'Voltar', '');
			await waitFor(client, (state) => {
				return state.state?.pendingConfirmation?.pending === false;
			}, `${testCase.label}: confirmation cancels`);
			await clickOverlayButton(client, testCase.label, testCase.button, '');
			await waitFor(client, (state) => {
				return state.state?.pendingConfirmation?.pending === true;
			}, `${testCase.label}: confirmation reopens`);
			const confirmClick = await clickOverlayButton(client, testCase.label, 'Confirmar', testCase.action);
			const after = await waitFor(client, (state) => {
				return state.state &&
					state.state.currentScreen === 'mode_shell' &&
					state.state.overlayOpen === true &&
					state.state.overlayRoute === testCase.route &&
					String(state.state.actionInput?.last?.action_id || '') === testCase.action;
			}, `${testCase.label}: post confirm action state`);
			finalState = after.state;
			screenshots.push(await capture(client, `${testCase.label}-after`));
			results.push({
				label: testCase.label,
				smoke: testCase.smoke,
				route: testCase.route,
				kind: testCase.kind,
				button: testCase.button,
				action: testCase.action,
				first_click_overlay_sequence: firstClick.after_overlay_sequence,
				confirm_message: confirmOpen.state.state?.pendingConfirmation?.message || '',
				action_after_input: confirmClick.action_after_input,
				overlay_route_after: after.state.state?.overlayRoute || '',
			});
		} else if (testCase.kind === 'arena_resume_abandon') {
			const resumeClick = await clickOverlayButton(client, testCase.label, testCase.resumeButton, testCase.resumeAction);
			const active = await waitFor(client, (state) => {
				return state.state &&
					state.state.currentScreen === 'mode_shell' &&
					state.state.overlayOpen === true &&
					state.state.overlayRoute === 'arena_active' &&
					String(state.state.actionInput?.last?.action_id || '') === testCase.resumeAction;
			}, `${testCase.label}: resume reaches active route`);
			const abandonClick = await clickOverlayButton(client, testCase.label, testCase.abandonButton, testCase.abandonAction);
			const after = await waitFor(client, (state) => {
				return state.state &&
					state.state.currentScreen === 'mode_shell' &&
					state.state.overlayOpen === true &&
					state.state.overlayRoute === 'arena_active' &&
					String(state.state.actionInput?.last?.action_id || '') === testCase.abandonAction;
			}, `${testCase.label}: abandon input records inside overlay`);
			finalState = after.state;
			screenshots.push(await capture(client, `${testCase.label}-after`));
			results.push({
				label: testCase.label,
				smoke: testCase.smoke,
				route: testCase.route,
				kind: testCase.kind,
				resume_button: testCase.resumeButton,
				resume_action: testCase.resumeAction,
				abandon_button: testCase.abandonButton,
				abandon_action: testCase.abandonAction,
				resume_action_after_input: resumeClick.action_after_input,
				abandon_action_after_input: abandonClick.action_after_input,
				overlay_route_after_resume: active.state.state?.overlayRoute || '',
				overlay_route_after_abandon: after.state.state?.overlayRoute || '',
			});
		} else {
			throw new Error(`${testCase.label}: unknown interactive case kind ${testCase.kind}.`);
		}
	}
	if (outcome !== 'cloudflare_access_expected') {
		outcome = 'overlay_menu_actions_passed';
	}
} catch (err) {
	failureReason = err.message || String(err);
	finalState = await readState(client).catch(() => finalState);
	screenshots.push(await capture(client, 'overlay-menu-actions-failure'));
} finally {
	client.close();
}

const summary = {
	schema_version: 'draxos_mobile_web_overlay_menu_actions_smoke_v2',
	web_url: webUrl,
	expected_release_root: expectedReleaseRoot,
	expected_app_version: expectedAppVersion,
	expected_app_version_code: expectedAppVersionCode,
	allow_cloudflare_access: allowCloudflareAccess,
	outcome,
	failure_reason: failureReason,
	elapsed_ms: Date.now() - startedAt,
	results,
	final_state: finalState,
	screenshots,
};

const summaryPath = path.join(diagnosticsDir, 'web-overlay-menu-actions-summary.json');
fs.writeFileSync(summaryPath, JSON.stringify(summary, null, 2));
console.log(JSON.stringify(summary, null, 2));

if (failureReason || (outcome !== 'overlay_menu_actions_passed' && outcome !== 'cloudflare_access_expected')) {
	process.exitCode = 1;
}
'@

    $nodeScriptPath = Join-Path $DiagnosticsDir "web-overlay-menu-actions-cdp.mjs"
    [System.IO.File]::WriteAllText($nodeScriptPath, $nodeScript, [System.Text.UTF8Encoding]::new($false))
    Push-Location -LiteralPath $ProjectDir
    try {
        & $node.Path $nodeScriptPath
        if ($LASTEXITCODE -ne 0) {
            throw "Web overlay menu actions smoke failed. Diagnostics: $DiagnosticsDir"
        }
    } finally {
        Pop-Location
    }
    Write-Host "Web overlay menu actions smoke passed."
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
