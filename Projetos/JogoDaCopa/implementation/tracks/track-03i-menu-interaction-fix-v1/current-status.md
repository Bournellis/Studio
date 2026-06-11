# Track 03I - Menu Interaction Fix V1

- Data: `2026-06-11`
- Status: `FIX_VALIDATED`
- Branch: `codex/JogoDaCopa/track03i-menu-interaction-fix-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03i-menu-interaction-fix-v1`

## Objetivo

Recuperar a interacao real do menu principal apos a regressao da 03G, usando primeiro um teste vermelho de clique real e depois simplificacao estrutural.

## Fase 2 - Vermelho Reproduzido

Teste adicionado em `tests/unit/test_bootstrap.gd`:

- `test_main_menu_real_mouse_clicks_reach_interactive_controls`
- Instancia `res://modes/menu/main_menu.tscn`.
- Cria um `SubViewport` de teste e injeta `InputEventMouseButton` press/release no centro global de cada controle via `Viewport.push_input`.
- Cobre: botao Futebol, botao Quit, setas de dificuldade, setas de modo e sliders Master/SFX/UI/Ambiente.
- O teste foi executado ativo antes do fix e falhou, entao ficou marcado como `pending()` no commit vermelho.

Resultado do vermelho:

- Todos os controles testados falharam em emitir o sinal esperado.
- `gui_get_hovered_control()` retornou `<none>` porque nenhum controle entrou no hit-test.
- Cadeia de ancestrais do clique mostrou:
  - `MainMenuRoot` com rect `[P: (0.0, 0.0), S: (0.0, 0.0)]`.
  - `MenuSafeArea` colapsado para altura `36.0`.
  - `MenuScroll` com altura `0.0`.
  - Os botoes/sliders existem e tem rect visivel, mas estao fora da area valida de hit-test dos ancestrais.

## Causa Raiz

O bloqueio nao e um botao especifico: a raiz `MainMenuRoot` fica com area de hit-test `0x0`, o que colapsa a cadeia `MenuSafeArea > MenuScroll` e impede que qualquer clique real atravesse o hit-test ate os controles filhos. Como varios containers intermediarios tambem estavam com `MOUSE_FILTER_IGNORE`, o teste antigo de presenca/visibilidade nao revelava a falha; ele verificava que os nodes existiam, nao que eram alcancaveis por input real.

## Fase 3 - Fix Por Simplificacao

O menu foi reescrito para a hierarquia minima:

- `MainMenuRoot` sincronizado ao tamanho do viewport e `MOUSE_FILTER_PASS`.
- `ArenaPreview` / `TextureRect` com `MOUSE_FILTER_IGNORE`.
- `MenuShade` com `MOUSE_FILTER_IGNORE`.
- `MenuCenter` full-rect.
- `MenuPanel`.
- `MenuBox` com os controles interativos.

`MenuSafeArea`, `MenuScroll` e `MenuMargin` foram removidos. A responsividade voltou a depender de anchors/containers nativos, sem margem segura custom nem posicionamento absoluto para o menu.

O teste `test_main_menu_real_mouse_clicks_reach_interactive_controls` foi reativado e parametrizado em:

- `1920x1080`
- `1366x768`
- `1280x720`

Cada resolucao instancia o menu em um `SubViewport`, injeta press/release real via `Viewport.push_input` no centro global dos controles e espera o sinal real de botao/slider.

## Fase 4 - Regra Permanente E Evidencia Visual

`docs/architecture-overview.md` ganhou a secao `UI Interaction Rule`: toda mudanca em UI/menu/HUD interativo exige teste de clique real via viewport, cobrindo todos os controles alterados em `1920x1080`, `1366x768` e `1280x720`. Teste de presenca/visibilidade nao conta como evidencia de UI funcional.

Screenshots gerados para inspecao humana:

- `docs/screenshots/track-03i-menu/menu-1920x1080.png`
- `docs/screenshots/track-03i-menu/menu-1366x768.png`
- `docs/screenshots/track-03i-menu/menu-1280x720.png`

## Validacao

- `gut_cmdln.gd -gconfig=res://.gutconfig.json`: PASS, `58/58` tests, `829` asserts.
- `tools/validate.gd`: PASS, source integrity `27` `.gd/.gdshader` files, `58/58` tests, `829` asserts.

## Proximo Passo

Fechar coordenacao: atualizar `implementation/current-status.md`, `Estado_Atual.md`, mover card para Done, merge em `main`, prune da worktree e `WORKTREE_VERIFIED`.
