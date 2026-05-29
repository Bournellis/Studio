# DraxosMobile - Battle Request Splash Hotfix

- Data: `2026-05-28`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/foundation-responsive-guardrails`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-app-v0-audit`
- Status: `DONE`

## Objetivo

Remover a previa visual de batalha exibida imediatamente apos solicitar uma batalha. Enquanto o backend prepara o log e antes do replay abrir, a tela deve mostrar apenas uma imagem de fundo estatica.

## Escopo

- Adicionar estado de `battle_entry` aguardando requisicao.
- Renderizar splash estatica com imagem de referencia do projeto, sem `BattleVisualMockup`, timeline ou botoes duplicados.
- Manter replay, resumo e historico inalterados.
- Cobrir com teste cliente e smoke responsivo quando aplicavel.

## Validacao Executada

```powershell
git diff --check
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_agent_ops_foundation.ps1 -ProjectDir .
```

Resultado: passou. GUT client: `113/113` testes. `validate_foundation.ps1 -Profile Quick` OK. `check_agent_ops_foundation.ps1` OK apos mover o card para Done.

## Handoff

Hotfix implementado localmente. Publicar somente quando Fabio pedir novo build.
