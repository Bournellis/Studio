# FpsPlayground Publication Readiness

## Metadata

- status: `not_configured`
- authority: `runbook`
- last_verified: `2026-07-16`
- review_when: `Fabio explicitly authorizes an export/build track`
- supersedes: `publication-readiness checklist before Governance v2`
- superseded_by: `none`

The project is an editor-first local laboratory. No export preset, Build runner, publication workflow or remote target is configured.

Before a future local export track can be opened:

- define the intended FPS product surface and platform;
- add product identity and an export preset through a dedicated commit;
- add a typed local Build runner and regression coverage;
- run full automated validation and a manual editor smoke;
- document limitations and preserve publication as a separate Fabio-owned decision.

This runbook does not authorize build, signing, upload, publication or remote mutation.
