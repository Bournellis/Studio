# DraxosMobile Done: Bosque Resume Exit Lifecycle v1

## Metadata

- data: `2026-06-08`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `platform-v1`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/bosque-resume-exit-lifecycle-v1`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-resume-exit-lifecycle-v1`

## Objetivo

Corrigir a retomada do Bosque apos `Voltar`, impedindo que uma sessao preservada vire um Bosque novo fora do save e garantindo que falhas de checkpoint nao prendam o jogador dentro do modo.

## Entrega

- Client Openworld agora preserva a sessao local viva quando `/modes/state` omite `active_session`, mas ainda ha um `session_id` local valido.
- Client tambem consegue retomar por `session_id` quando a sessao aparece na lista remota `sessions`, mesmo sem `active_session` principal.
- Botao `Voltar` com checkpoint pendente/falho preserva alteracoes pendentes, registra saida preservada e fecha o Bosque em vez de prender o jogador em "falha ao sair".
- Endpoint `/modes/session/start` agora pode devolver a sessao ativa existente quando o RPC retorna `MODE_SESSION_ALREADY_ACTIVE`, evitando que o shell caia em preview/estado novo durante reentrada.
- Versao preparada para `0.0.12-alpha.0` / version code `12`.

## Commits

- `86fdc51` - docs: register bosque resume exit lifecycle work
- `bc835a6` - fix: stabilize bosque resume exit lifecycle
- `a73a171` - release: prepare bosque resume exit lifecycle alpha
- `9a0f7c0` - test: align release smokes with alpha 12

## Validacao Local

- Targeted GUT Openworld/screen: PASS antes do commit de runtime.
- Targeted Deno Openworld/modes: PASS antes do commit de runtime.
- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick`: PASS, incluindo GUT client completo `248 tests / 3820 asserts`; warnings conhecidos de ObjectDB/orphans seguem sem falhar o gate.
- `validate_foundation.ps1 -Profile ServerQuick`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun`: PASS apos mover este card para Done.
- `npx -y deno check server/tests/release_manifest_smoke.ts server/tests/release_artifacts_remote_smoke.ts server/tests/internal_alpha_remote_smoke.ts`: PASS apos alinhar os smokes para alpha 12 e downloads protegidos por Access.

## Release

- Publicado como `Bosque Resume Exit Lifecycle v1`.
- Release root: `internal-alpha/v0-bosque-resume-exit-lifecycle-v1-20260608-9a0f7c0`.
- Preview evidence: `https://39128c59.draxos-mobile-internal-alpha.pages.dev`.
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`.
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`.
- APK/manifest: `0.0.12-alpha.0` / version code `12`.
- Remote functions: `modes` and `release` redeployed.
- Android APK SHA256: `546131c81c7bab0d43f04f4223b44ef7e5df7b25fb9877b743f4ff4c3622d0e3`.
- PC ZIP SHA256: `8bbd031d3e0b43c5a9b38c04509b1b7db0f0e8e372f427ba31634138c443c554`.
- Web Index SHA256: `fca57c810699ac80bd05a633905618ed569a3dbeb22850ce63af8b9b96390893`.
- `release_manifest_smoke.ts`: PASS remoto para `0.0.12-alpha.0` / version code `12`.
- `internal_alpha_remote_smoke.ts`: PASS remoto.
- `release_artifacts_remote_smoke.ts`: PASS remoto com `DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS=1`; Portal/Web oficiais continuam Cloudflare Access protected.
- `smoke_web_launch_remote.ps1` contra preview `39128c59`: PASS, outcome `game_loaded`, release root esperado confirmado.
