# Handoff - DraxosMobile Minigame Platform V1

- Data: `2026-06-01`
- Projeto: `Projetos/draxos-mobile`
- Branch: `codex/draxos-mobile/modes-integrated-alpha`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--modes-integrated-alpha`
- Commit publicado: `c0c1e9c`
- Release root: `internal-alpha/v0-minigame-platform-v1-modes-20260601-c0c1e9c`
- Status: publicado em Internal Alpha; aguardando playtest humano.

## O Que Mudou

- A plataforma de minigames virou Minigame Platform V1 com cinco modos oficiais:
  `basebuilder`, `autobattler`, `towerdefense`, `cardgame`, `openworld`.
- `rpgsuave` foi renomeado de verdade para `openworld`; o slice atual e
  `openworld/forest`, player-facing `Openworld Bosque`.
- O contrato ativo remoto mudou de `/minigames` para `/modes`.
- O client mudou de `minigame_shell/open_minigame_shell` para
  `mode_shell/open_mode_shell:<mode_id>`.
- O Refugio agora tem Hub de Modos com Basebuilder, Autobattler, Openworld,
  Towerdefense e Cardgame.
- Towerdefense/Cardgame ficam visiveis como staged/disabled.
- Labs Dev Ops e analytics por modo existem como superficie interna.

## Publicacao

- Portal: `https://d3a140a5.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web: `https://d3a140a5.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-minigame-platform-v1-modes-20260601-c0c1e9c/downloads/draxos-mobile-alpha.apk`
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-minigame-platform-v1-modes-20260601-c0c1e9c/downloads/draxos-mobile-alpha.zip`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

## Validacao

- Full gate local verde.
- Remote migrations aplicadas.
- Edge Function `modes` publicada.
- Edge Function `minigames` removida.
- Manifest/artifacts/internal alpha remote smokes verdes.
- Check manual: `/functions/v1/minigames/registry` retorna `404`.

## Atenção Para O Playtest

- Testar em mobile portrait primeiro.
- Verificar se o Hub comunica claramente que Basebuilder e Autobattler estao ativos.
- Verificar se Openworld nao mostra mais `Rpgsuave`.
- Confirmar que Towerdefense/Cardgame nao prometem data nem iniciam gameplay.
- Confirmar que usuario comum nao enxerga dados sensiveis em Labs Dev Ops.
- Android APK ainda usa `debug_fallback`; keystore release dedicada segue pendente para distribuicao ampla.
