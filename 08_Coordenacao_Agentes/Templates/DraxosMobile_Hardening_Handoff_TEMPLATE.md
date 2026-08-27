# DraxosMobile Hardening Handoff: <lane> - <titulo>

Use `Handoff_TEMPLATE.md` metadata v3 plus:

- projeto: `draxos-mobile`
- lane: `coord-docs | backend-schema | session-data | client-shell | mode-scaffolds | platform-v1 | validation-release`
- mode_scope: `none | basebuilder | autobattler | openworld | towerdefense | cardgame | multi-mode`
- server_authority_preserved: `yes | no - blocker`
- remote_mutation_run: `no | yes - explicit authorization/evidence`
- git_sync_status: `pending_safe_push | pushed_verified@<oid> | blocked:<reason> | n/a`

## Required Outcome

- Separate technical completion, Arena/product proof and publication state.
- Reference release history instead of duplicating package/root/hash details.
- Record exact local validation profile and clean-tree result.
- Record `commit`, `merged_to`, `merge_strategy`, `post_merge_validation` and cleanup from the lifecycle receipt.
- Record `git_sync_status` after the delegated safe Git synchronization; this does not change product publication or remote-mutation gates.
