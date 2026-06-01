# Codex - Modes Integrated Alpha

- Data: `2026-06-01`
- Projeto: `Projetos/draxos-mobile`
- Branch: `codex/draxos-mobile/modes-integrated-alpha`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--modes-integrated-alpha`
- Release root: `internal-alpha/v0-minigame-platform-v1-modes-20260601-c0c1e9c`
- Status: `PUBLISHED_INTERNAL_ALPHA - AWAITING_HUMAN_PLAYTEST`

## Objetivo Entregue

Implementar `Minigame Platform V1 + Modos Oficiais DraxosMobile`: registry unico com `basebuilder`, `autobattler`, `towerdefense`, `cardgame` e `openworld`; renomear `rpgsuave` para `openworld`; trocar `/minigames` por `/modes`; trocar `minigame_shell/open_minigame_shell` por `mode_shell/open_mode_shell`; criar Hub de Modos, Ops interno e analytics por modo.

## Resultado

- Docs, contratos e status atualizados para os cinco modos oficiais.
- Backend remoto recebeu migrations `202606010000_minigame_platform_v0.sql` e `202606010001_modes_platform_v1.sql`.
- Edge Function `modes` publicada.
- Edge Function antiga `minigames` removida do contrato remoto ativo.
- Client usa Hub de Modos, `mode_shell` e Openworld Bosque fullscreen.
- Openworld substitui `rpgsuave` em classes, docs, payloads, ruleset e smokes.
- Labs Dev Ops e analytics por modo implementados para a etapa interna.
- Pacote Internal Alpha publicado no Cloudflare Pages e Supabase Storage.

## URLs Publicadas

- Portal: `https://d3a140a5.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web: `https://d3a140a5.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-minigame-platform-v1-modes-20260601-c0c1e9c/downloads/draxos-mobile-alpha.apk`
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-minigame-platform-v1-modes-20260601-c0c1e9c/downloads/draxos-mobile-alpha.zip`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

## Validacao

- `tools/validate_foundation.ps1 -ProjectDir . -Profile Full -RequireClean`: verde.
- Export Android/PC/Web: verde, Android em `debug_fallback`.
- Remote migration push: verde.
- Edge Function `modes` deploy: verde.
- Cloudflare Pages deploy: verde.
- `release_manifest_smoke.ts`: verde.
- `release_artifacts_remote_smoke.ts`: verde.
- `internal_alpha_remote_smoke.ts` com release/email/mode: verde.
- `/functions/v1/minigames/registry`: `404`, contrato antigo fora do ar.

## Proximo Passo

Playtest humano do Hub de Modos: entrar em Basebuilder, Autobattler e Openworld Bosque; confirmar Towerdefense/Cardgame staged/disabled; validar Labs Dev Ops escondido para usuario comum.
