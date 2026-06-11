# Track 03I - Menu Interaction Fix V1

- Data: `2026-06-11`
- Status: `IN_PROGRESS`
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

## Proximo Passo

Fase 3: simplificar a hierarquia para `Control full-rect > TextureRect IGNORE > shade IGNORE > CenterContainer > PanelContainer > VBoxContainer`, remover `ScrollContainer`/safe area custom e reativar o teste nas tres resolucoes.
