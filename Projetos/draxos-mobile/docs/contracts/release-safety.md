# DraxosMobile Release Safety Contract

## Metadata

- status: `living`
- authority: `technical_contract`
- last_verified: `2026-07-17`
- review_when: `release modes, candidate identity, artifact safety or publication authority changes`
- supersedes: `implementation/tracks/track-13-validation-release-safety/release-safety-contract.md as live authority`
- superseded_by: `none`

This contract separates local validation and packaging from external mutation. The Track 13 source remains historical evidence; `../release-ops-checklist.md` is the procedural runbook.

## Modes

| Mode | Effect | Authority |
|---|---|---|
| `Plan` | Generates a local release plan only. | Safe default; local automation allowed. |
| `Package` | Prepares local publish files under a fresh versioned release root. | Explicit local packaging task only. |
| `Upload` | Mutates remote artifact storage. | Separate Fabio-authorized publication task. |
| `DeployManifest` | Mutates the manifest/Edge deployment. | Separate Fabio-authorized publication task. |
| `FullPublish` | Combines remote upload, deploy and verification. | Outside validation runners; explicit Fabio execution only. |

`validate_foundation.ps1 -Profile FullPublish` is rejected intentionally. Green validation or packaging never authorizes upload, deploy, secret update, device QA or release promotion.

## Mandatory Guards

- `Plan` is the default and never invokes Storage, secrets, Edge deployment, Wrangler or upload.
- Every package uses a fresh `internal-alpha/v0-<slug>-YYYYMMDD-<shortsha>` root.
- Remote modes require both a versioned root and `-ConfirmRemoteMutation` after explicit authorization.
- Legacy flags without `-Mode` remain protected in `Plan`.
- Publishable client keys may be used only where the runbook permits; admin/service-role or secret-like values are refused.
- Current package facts belong only in `../release-history.md` and `../../implementation/current-status.md`.

## Candidate Identity

- Preparation, qualification, local promotion receipt and publication are separate acts.
- A candidate is identified by immutable SHA256; physical qualification must use that exact artifact without rebuild.
- Emulator evidence never substitutes physical-device proof.
- A local promotion receipt records a resolved human decision; it does not execute release mutation.
- Only Fabio can authorize physical validation, release promotion or publication.

## Automated Safety Proof

`tools/check_release_safety.ps1` must fail when:

- `Plan` stops being the publish-script default;
- `ConfirmRemoteMutation` or versioned-root guards disappear;
- mutating commands can run before mode/confirmation checks;
- the validation runner invokes publication directly or accepts `FullPublish`;
- release scripts fail PowerShell parse;
- release defaults diverge between server and Supabase mirrors.

`ReleaseDryRun` may generate temporary plan files, but it must not create a promoted package, upload, deploy, update a secret or query a physical device.

## Local Artifacts

`Plan` may generate:

- `build/internal-alpha/release-plan.json`
- `build/internal-alpha/release-plan.md`

An explicitly authorized local `Package` may additionally prepare manifest, portal, Web and download files under `build/internal-alpha/publish/`. Those files remain local candidates until a separate decision.

## Current Human Boundary

Arena remains `ARENA_CORE_NEEDS_UX_FIX` plus `ARENA_CORE_NOT_PROVEN`. Release safety work cannot approve Arena product proof, tuning, economy, PVP, content, final visuals, device readiness or a future release.
