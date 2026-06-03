# DraxosMobile Latency Baseline

- Status: `RUNBOOK`
- Last updated: `2026-06-03`
- Scope: read-only latency diagnostics for request/action/surface responsiveness.

## Purpose

Use `tools/measure_latency_baseline.ps1` to capture local or remote read-only
latency snapshots without publishing, uploading, deploying, creating accounts or
creating saves. The tool writes diagnostics under `build/diagnostics/` by
default.

## Commands

Local and remote read-only snapshot:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\measure_latency_baseline.ps1 -ProjectDir . -Target Both -Label before
```

Remote-only snapshot with an approved existing account token:

```powershell
$env:DRAXOS_LATENCY_ACCESS_TOKEN = "<approved-existing-user-jwt>"
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\measure_latency_baseline.ps1 -ProjectDir . -Target Remote -Label before
```

After snapshot and comparison against a previous JSON artifact:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\measure_latency_baseline.ps1 -ProjectDir . -Target Remote -Label after -CompareWith .\build\diagnostics\<previous>\latency-baseline-before.json
```

## Inputs

The tool reads these optional values from parameters, process environment or
`.env.internal-alpha.local`:

- `SUPABASE_URL` or `DRAXOS_MOBILE_SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY` or `DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY`
- `DRAXOS_LATENCY_ACCESS_TOKEN`, `DRAXOS_OPS_ACCESS_TOKEN`, `DRAXOS_MOBILE_OPS_ACCESS_TOKEN` or `DRAXOS_MOBILE_SUPABASE_ACCESS_TOKEN`

Do not place service role credentials in this flow. Authenticated surface
endpoints are skipped when no approved existing user JWT is available.

## Artifact Format

JSON: `latency-baseline-<label>.json`

```json
{
  "schema_version": "latency_baseline_v1",
  "generated_at": "2026-06-03T00:00:00.0000000Z",
  "metadata": {
    "label": "before",
    "target": "Remote",
    "samples": 3,
    "remote_publishable_key_configured": true,
    "access_token_configured": false
  },
  "rows": [
    {
      "target": "remote",
      "surface": "release",
      "endpoint": "release/manifest",
      "method": "GET",
      "duration_ms": 120.5,
      "response_code": 200,
      "ok": true,
      "fail": false,
      "used_cache": false,
      "rendered_from_cache": false,
      "server_timing": { "duration_ms": 42 }
    }
  ],
  "summary": [],
  "comparison": [],
  "blockers": []
}
```

Markdown: `latency-baseline-<label>.md`

- Summary table by target, surface, endpoint and method.
- Optional comparison table with average and p95 delta when `-CompareWith` is used.
- Blockers such as missing approved account token or missing publishable key.

## Safe Remote Rule

This runbook allows only read-only requests. If a future latency measurement
needs a real mutation such as Arena start/duel or Base collect, document the
exact command and wait for coordination approval before running it.
