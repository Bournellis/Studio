# QA Index — DraxosMobile

## Metadata

- status: `living`
- authority: `technical_contract`
- last_verified: `2026-07-16`
- review_when: `runner, journey, gate or supported environment changes`
- supersedes: `distributed validation matrices as the QA entrypoint`
- superseded_by: `none`

`qa_manifest.json` is the machine authority for commands. This index governs human reading, journeys, gates and evidence; IDs must match exactly.

## Runners

- runner_id: `docs_contracts_fast`
- runner_id: `server_quick_local`
- runner_id: `client_gut_short_fast`
- runner_id: `client_quick_runtime`
- runner_id: `mode_platform_runtime`
- runner_id: `release_dry_run_build`

## Journeys and gates

- capability_id: `login`
- capability_id: `refugio`
- capability_id: `arena_technical_flow`
- capability_id: `session_resume`
- capability_id: `android_local_readiness`
- capability_id: `web_local_readiness`
- capability_id: `server_authority`
- capability_id: `arena_product_proof`
- capability_id: `tuning_decision`
- capability_id: `economy_decision`
- capability_id: `pvp_decision`
- capability_id: `visual_decision`
- capability_id: `external_validation`
- capability_id: `release_promotion`

## Profile map

- FastSuite: `DocsOnly`, `ServerQuick` and three selected client GUT files.
- Runtime: `ClientQuick`, `ServerQuick` and `ModePlatform`.
- Build: `ReleaseDryRun` only; it prepares/checks local plans and never promotes a release.
- FullLocal: declared local runners only; database-backed and external profiles remain out of scope.

Login, Refúgio, Arena technical flow, resume, Android/Web local readiness and server authority have automated local evidence.

Arena product proof, tuning, economy, PVP, final visual direction, external checks and release promotion remain human gates.

Every Runtime and Build command must execute twice with identical tracked Git state. A changed tracked snapshot is `VALIDATOR_SIDE_EFFECT`.

Observed local baseline on 2026-07-16:

- FastSuite: selected GUT `13/13`, `170` asserts; DocsOnly and ServerQuick green.
- Runtime: client `287/287`, `4,208` asserts; server foundation `128` and Arena `23`; mode/platform `49`.
- Build: `ReleaseDryRun` green; plan-only guard confirmed no package, upload, secret update, deploy or remote verification.

New evidence bundles use `estudio_evidence_v1`; existing historical reports remain preserved in `docs/` and `implementation/tracks/`.
