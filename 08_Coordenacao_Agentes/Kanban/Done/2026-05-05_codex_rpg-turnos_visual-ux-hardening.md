# RPG Turnos - Visual/UX Hardening

- Data: `2026-05-05`
- Agente: `codex`
- Projeto: `Projetos/rpg-turnos`
- Status: `done`

## Objetivo

Melhorar legibilidade do slice jogavel sem importar arte nova e sem expandir conteudo.

## Entregue

- HUD de batalha com barras de HP, pips de energia, contador de mao/deck e contador de descarte
- Cartas da mao com faixa lateral por tipo
- Slots com estados visuais mais claros para vazio, ocupado, fonte de ataque e alvo possivel
- Marcadores do mapa com trilha, status (`Disponivel`, `Bloqueado`, `Concluido`) e destaque do encontro ativo
- Tela de resultado com feedback explicito de recompensas
- Cobertura GUT para os novos elementos criticos de UI

## Validacao

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd
```

Resultado: `56/56` testes GUT passando.

## Proximo Passo Recomendado

Estrutura placeholder art-ready: `UiTokens`, nodes nomeados de arte e `AssetIds`.
