# 2026-05-31 - Codex - DraxosMobile Rpgsuave Visual Upgrade v1

## Resultado

Implementado o upgrade visual do Rpgsuave Bosque como minigame fullscreen mobile portrait: camera presa no personagem, movimento apenas por joystick, HUD dentro do jogo, mochila funcional com detalhes dev escondidos e assets procedurais Godot. Backend, reward rules, migrations e CTA publico do Refugio nao foram alterados.

## Branch e worktree

- Branch: `codex/draxos-mobile/rpgsuave-visual-upgrade-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--rpgsuave-visual-upgrade-v1`
- Base: `29be99f` (`codex/draxos-mobile/rpgsuave-integrated-alpha`)
- Commit de implementacao: `809c4dc`

## Entregue

- `minigame_shell` registrado como rota fullscreen gameplay sem app chrome.
- `boot_runtime.gd` monta `MinigameFullscreenOverlay` proprio para minigames.
- `RpgsuaveForestScreen` passou a orquestrar mundo/HUD/joystick/mochila.
- `RpgsuaveForestWorldView` desenha terreno, zonas, recursos, personagem e feedback via `_draw()`.
- `RpgsuaveVirtualJoystick` virou unico input player-facing.
- `RpgsuaveInventorySheet` concentra Bolso, Bau, Craft, Sessao e detalhes tecnicos recolhidos.
- Testes client cobrem fullscreen, joystick, HUD, mochila e detalhes dev escondidos.
- Smokes `smoke_rpgsuave_forest.gd` e `smoke_rpgsuave_visual_layout.gd` cobrem gameplay e layout visual.
- Docs atualizados: `docs/minigames/rpgsuave.md` e `docs/contracts/minigame-integration.md`.

## Validacao concluida antes da publicacao

- `git diff --check`: passou.
- `tools/validate.gd`: passou.
- GUT client: `144/144` testes, `2316` asserts.
- `tools/smoke_rpgsuave_forest.gd`: passou.
- `tools/smoke_rpgsuave_visual_layout.gd`: passou em `360x800`, `390x844`, `432x936`, `1280x720`.
- `tools/smoke_responsive_layout.gd`: passou.
- `tools/smoke_mobile_presentation.gd`: passou.
- `tools/validate_foundation.ps1 -Profile Client`: passou.
- Primeiro `tools/validate_foundation.ps1 -Profile Full -RequireClean`: codigo/client/release safety passaram; falhou apenas pelo guardrail operacional de Doing card aberta. Esta Done card fecha esse item.

## Proximo passo

Rerodar `tools/validate_foundation.ps1 -Profile Full -RequireClean` com o Kanban limpo; se passar, exportar e publicar `internal-alpha/v0-rpgsuave-visual-upgrade-v1-20260531-809c4dc`.
