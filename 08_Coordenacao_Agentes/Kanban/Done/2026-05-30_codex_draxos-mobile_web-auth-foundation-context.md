# DraxosMobile - Web Auth Foundation Context Hotfix

- Status: `DONE_WITH_CLOUDFLARE_DEPLOY_BLOCKED`
- Agent: Codex
- Branch: `codex/draxos-mobile/web-auth-foundation-context`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-final-polish`
- Base commit: `1e6fc0e`
- Objective: fix the published Web login failures reported after Debug Clean Web Config.

## Reported Failures

- Guest path reports: `Essa rota e apenas para guest dev`.
- Email/password path reports:
  `FOUNDATION_CONTEXT_NOT_FOUND: Account/save foundation context was not created yet`.

## Guardrails

- No gameplay tuning.
- No new feature scope.
- Keep `account_profiles/game_saves` as authority.
- Remote mutation only if needed to repair Internal Alpha auth/bootstrap and with explicit command flags where scripts require them.

## Validation Plan

- Inspect account/auth bootstrap and foundation context resolution. Done.
- Reproduce remote guest/email path with smoke or focused script. Done.
- Add regression coverage for stale/non-foundation accounts. Done.
- Redeploy functions or apply remote migration/backfill if required. Remote DB
  migrations `202605300001`-`202605300004` were applied.
- Run Deno checks, targeted smokes, client validation where affected,
  `git diff --check`, commit and clean worktree. Done except final commit step
  at handoff time.

## Result

- Remote Internal Alpha database is aligned with local migrations through
  `202605300004_foundation_closeout.sql`.
- Remote smoke passes for anonymous auth, account state, email auth, release
  manifest, progression lab bootstrap and a battle request.
- Client guest entry now clears cached registered email sessions and forces a
  fresh anonymous Supabase session before calling `account/guest`.
- Regression coverage added in `tests/client/test_boot_mobile_ui.gd`.
- `validate_foundation.ps1 -Profile Client` passed with GUT `134/134` and
  `2274` asserts.
- Hotfix exported, packaged and uploaded to Supabase Storage at
  `internal-alpha/v0-web-auth-foundation-context-20260530`.
- Cloudflare Pages deploy is blocked by local Wrangler authentication error
  `10000`; rerun `wrangler login`/reauth, then deploy
  `build/internal-alpha/cloudflare-pages` to finish the Web shell update.
