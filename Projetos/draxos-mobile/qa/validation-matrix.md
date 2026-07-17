# DraxosMobile Validation Matrix

## Metadata

- status: `living`
- authority: `technical_contract`
- last_verified: `2026-07-17`
- review_when: `validation profiles, typed runners, environments or external boundaries change`
- supersedes: `52f52f7cd33d1711579f9cccbe4c848ab45a02e4:Projetos/draxos-mobile/implementation/tracks/track-13-validation-release-safety/validation-matrix.md as live authority`
- superseded_by: `none`

`qa_manifest.json` is the machine authority for studio runners. This matrix explains the project runner profiles, evidence boundary and exclusions. Track 13 is baseline-only historical evidence.

## Studio Profiles

| Studio profile | Typed runners | Boundary |
|---|---|---|
| `FastSuite` | `docs_contracts_fast`, `server_quick_local`, `client_gut_short_fast` | Local docs/server and selected client contracts. |
| `Runtime` | `client_quick_runtime`, `server_quick_local`, `mode_platform_runtime` | Local client/server/mode regression only. |
| `Build` | `release_dry_run_build` | Local release plan/safety proof; no package, upload or deploy. |
| `FullLocal` | All declared local runners | No remote service, device, publication or human decision. |

## Project Runner Profiles

| Profile | Contents | External effect |
|---|---|---|
| `DocsOnly` | Whitespace, PowerShell parse, docs/contracts, budgets, drift and secret scan. | None. |
| `ClientQuick` | DocsOnly plus Godot validation, client GUT and offline client smokes. | None. |
| `ServerQuick` | DocsOnly plus mirrors, registries, Deno checks and Arena/server contracts. | None. |
| `ModePlatform` | DocsOnly plus mode registry/session/reward and local Godot mode smokes. | None. |
| `DatabaseLocal` | Local Supabase/RPC/Edge/RLS proofs when the local stack exists. | Local stack only. |
| `ReleaseDryRun` | DocsOnly plus manifest typecheck, `Mode Plan`, secret scan and safety/readiness checks. | None. |
| `RemoteReadOnly` | Explicit read-only artifact/Web verification with publishable credentials. | External read only; excluded from routine studio automation. |
| `FullLocal` | Local server, client, mode, database and release dry-run stages. | None. |
| `FullPublish` | Rejected by the runner. | Publication must be a separate Fabio-authorized task. |

Legacy aliases remain project-runner compatibility only: `Quick -> ServerQuick`, `Client -> ClientQuick`, `Release -> ReleaseDryRun`, `Full -> FullLocal`.

## Commands

```powershell
.\tools\validate_foundation.ps1 -ProjectDir . -Profile DocsOnly
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ServerQuick
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ModePlatform
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun
```

Database and read-only remote profiles are opt-in and require their documented environment. They are never inferred from a general validation request.

## Evidence Rules

- Runtime and Build runners execute twice for closure and must leave tracked Git unchanged.
- A tracked validator diff is `VALIDATOR_SIDE_EFFECT`; do not auto-restore it.
- Reports under `build/validation/` are local generated diagnostics, not product approval.
- Remote read-only evidence does not authorize remote mutation.
- Emulator evidence does not prove a physical device; automation does not decide human gates.

## Supported Human Boundaries

Automated local evidence covers login, Refugio, Arena technical flow, resume, local Android/Web readiness and server authority.

Arena product proof, tuning, economy, PVP, final visual direction, external checks, physical-device qualification and release promotion remain human/manual capabilities. The current Arena verdict remains `ARENA_CORE_NEEDS_UX_FIX` plus `ARENA_CORE_NOT_PROVEN`.
