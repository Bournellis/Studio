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

## Validacao Local

- Targeted GUT Openworld/screen: PASS antes do commit de runtime.
- Targeted Deno Openworld/modes: PASS antes do commit de runtime.
- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick`: PASS, incluindo GUT client completo `248 tests / 3820 asserts`; warnings conhecidos de ObjectDB/orphans seguem sem falhar o gate.
- `validate_foundation.ps1 -Profile ServerQuick`: PASS.

## Release

- Publicacao Web/APK segue no mesmo worktree e branch apos os gates de release.
- Release root planejado: `internal-alpha/v0-bosque-resume-exit-lifecycle-v1-20260608-<shortsha>`.
- Proximo passo operacional: repetir `ReleaseDryRun` sem cards em `Doing`, empacotar, publicar Storage/Cloudflare/manifest e registrar evidencias remotas em status/docs.

