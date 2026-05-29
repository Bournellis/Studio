# DraxosMobile - Entry Dev Labs Export Hotfix

- Data: `2026-05-28`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/foundation-responsive-guardrails`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-app-v0-audit`
- Status: `DONE`

## Objetivo

Devolver Battle Lab e Progression Lab ao menu inicial da Internal Alpha exportada.

## Causa

Os botões existiam nos testes locais, mas os presets de exportacao excluiam `dev/**`. Como a tela inicial usa `ResourceLoader.exists()` para decidir se os Labs aparecem, o APK/Web/PC publicado não encontra os overlays em `res://dev/...` e remove os botões.

## Entrega

- `export_presets.cfg`: Android/PC/Web Alpha deixam de excluir `dev/**`.
- `tools/smoke_exports.gd`: passa a falhar se `dev/**` voltar ao `exclude_filter`.
- `tools/smoke_exports.gd`: exige os overlays `res://dev/battle_lab/battle_lab_screen.gd` e `res://dev/progression_lab/progression_lab_screen.gd`.
- Export local gerado com os overlays empacotados; o log de export mostrou `res://dev/battle_lab/battle_lab_screen.gdc` e `res://dev/progression_lab/progression_lab_screen.gdc` entrando no pacote.

## Validacao

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_exports.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\export_internal_alpha.ps1 -ProjectDir . -EnvFile D:\Estudio\Projetos\draxos-mobile\.env.internal-alpha.local -GodotExe D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe -AllowAndroidDebugFallback
```

Resultados:

- `smoke_exports.gd`: OK.
- `smoke_responsive_layout.gd`: OK.
- GUT client: `113/113` testes passando.
- `validate_foundation.ps1 -Profile Quick`: OK.
- Export Internal Alpha local: OK, Android em `debug_fallback`.

## Proximo Ponto

Publicar novo build Internal Alpha para que a correcao chegue ao APK/Web/PC remoto.
