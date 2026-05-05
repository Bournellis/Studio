# RPG Turnos - Minimum Save/Load

- Data: `2026-05-05`
- Agente: `codex`
- Projeto: `Projetos/rpg-turnos`
- Status: `done`

## Objetivo

Persistir o slice linear atual antes de expandir conteudo novo.

## Entregue

- Save local em JSON: `user://rpg_turnos_save.json`
- `GameSession.build_save_data()`, `apply_save_data()`, `save_game()` e `load_game()`
- Persistencia de cartas desbloqueadas, deck selecionado, encontro ativo, encontros completos, rewards reclamadas, recompensa NPC inicial e indice de recompensa NPC
- Fallback para novo jogo quando o save esta ausente, corrompido ou em versao incompativel
- Botao `Continuar` no boot quando existe save
- Save em pontos de fluxo: novo jogo, recompensa NPC, selecao de encontro, confirmacao de deck e vitoria
- Cobertura GUT para gravacao/restauracao, save ausente e save corrompido

## Validacao

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd
```

Resultado: `54/54` testes GUT passando.

## Proximo Passo Recomendado

Hardening visual/UX minimo para HUD de batalha, estados de slot/alvo, marcadores do mapa e feedback de recompensa.
