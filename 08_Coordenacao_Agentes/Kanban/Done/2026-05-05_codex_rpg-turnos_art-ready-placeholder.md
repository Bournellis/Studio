# RPG Turnos - Art-Ready Placeholder Structure

- Data: `2026-05-05`
- Agente: `codex`
- Projeto: `Projetos/rpg-turnos`
- Status: `done`

## Objetivo

Preparar a estrutura de UI para receber arte depois, sem importar assets e sem expandir conteudo.

## Entregue

- `UiTokens` registrado como autoload com paleta, cores por tipo e nomes de tipo
- `AssetIds` registrado como autoload com IDs e caminhos planejados de arte
- Boot menu com `bg_visual`, `ambiance_layer`, `logo_container` e `logo_rect`
- Mundo com `map_environment`, `marker_nodes`, markers por encontro, `player_sprite` e `portrait_rect`
- CardToken com `art_rect`, `PipRowComponent` e `KeywordChipsComponent`
- BattleCardToken com `art_rect`, `type_stripe` e `KeywordChipsComponent`
- Battle HUD com `player_portrait_rect`, `enemy_portrait_rect`, `priority_dot`, `energy_pips`, `discard_bar` e lane panels nomeados
- Result screen com `bg_visual`, `ambiance_layer` e `result_icon_rect`
- Testes GUT para garantir que os placeholders e autoloads existem

## Validacao

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd
```

Resultado: `61/61` testes GUT passando.

## Proximo Passo Recomendado

Implementar o proximo modo oficial pequeno, preferencialmente `ondas`, usando dados e regras de encontro.
