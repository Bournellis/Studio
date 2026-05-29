# DraxosMobile - Refuge Return And Dev Tools Hotfix

- Data: `2026-05-28`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/foundation-responsive-guardrails`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-app-v0-audit`
- Status: `DONE`

## Objetivo

Corrigir feedback pos-publicacao do Fabio: acoes abertas dentro do Refugio podem voltar para a entrada/login em vez de voltar/ficar no Refugio, e as ferramentas dev ainda nao estao visiveis o suficiente no fluxo interno.

## Escopo

- Fazer o Refugio virar raiz de navegacao apos login/continue/guest.
- Garantir que back de superficies abertas a partir do Refugio retorne ao Refugio, nao ao menu de login.
- Reexpor Battle Lab e Progression Lab dentro do Refugio para o fluxo Internal Alpha.
- Adicionar/ajustar testes client e smoke responsivo para cobrir esse contrato.

## Validacao Executada

```powershell
git diff --check
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_loop.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_agent_ops_foundation.ps1 -ProjectDir .
```

Resultado: passou. GUT client: `112/112` testes. `validate_foundation.ps1 -Profile Quick` e `check_agent_ops_foundation.ps1` OK.

## Handoff

Hotfix implementado localmente e nao publicado ainda. Publicar apenas se Fabio pedir nova publicacao depois de validar o APK atual.
