# Track 06D - HUD Broadcast V1

Data: 2026-06-13
Branch: `codex/jogodacopa/track06d-hud-broadcast-v1`
Worktree: `D:\Estudio-worktrees\jogodacopa-track06d`

## Escopo

- Ajuste pre-merge da 06D para remover telemetria de dev do scorebug broadcast.
- `FlowLabel` e `ControlLabel` continuam existindo e recebendo texto via `update_snapshot`, mas ficam `visible=false` por padrao.
- `debug_set_telemetry_visible(bool)` permite reativar a telemetria em debug.
- Scorebug visivel preserva status, placar, relogio, `StateBadgeLabel`, STAMINA, SUPER e badge `PRONTO`.
- Captura 06D ganhou gate noturno com `WorldEnvironment`, tonemap `ACES`, `BG_SKY`, `ProceduralSkyMaterial` escuro e luma de ceu `< 90.0`.

## Evidencias

Geradas por `res://tools/capture_track06d_hud_broadcast.gd`.

| Shot | 1920x1080 | 1366x768 | 1280x720 |
|---|---:|---:|---:|
| Kickoff | `58.5` | `60.5` | `59.7` |
| Gol | `61.0` | `61.7` | `61.2` |
| Super | `58.5` | `60.5` | `59.7` |
| Result | `75.1` | `74.9` | `71.7` |

Todos os valores sao luma de ceu em escala `0-255`; gate aprovado porque todos ficaram `< 90.0`.

Arquivos principais:

- `docs/screenshots/track-06d/hud-broadcast-kickoff-1920x1080.png`
- `docs/screenshots/track-06d/hud-broadcast-goal-1920x1080.png`
- `docs/screenshots/track-06d/hud-broadcast-super-1920x1080.png`
- `docs/screenshots/track-06d/hud-broadcast-result-1920x1080.png`
- `docs/screenshots/track-06d/hud-broadcast-kickoff-1366x768.png`
- `docs/screenshots/track-06d/hud-broadcast-goal-1366x768.png`
- `docs/screenshots/track-06d/hud-broadcast-super-1366x768.png`
- `docs/screenshots/track-06d/hud-broadcast-result-1366x768.png`
- `docs/screenshots/track-06d/hud-broadcast-kickoff-1280x720.png`
- `docs/screenshots/track-06d/hud-broadcast-goal-1280x720.png`
- `docs/screenshots/track-06d/hud-broadcast-super-1280x720.png`
- `docs/screenshots/track-06d/hud-broadcast-result-1280x720.png`
- `docs/screenshots/track-06d/hud-broadcast-luma.json`
- `docs/screenshots/track-06d/06d-web-kickoff-boot.png`
- `docs/screenshots/track-06d/06d-web-kickoff-boot.json`

## Validacao

Comandos rodados de `Projetos/JogoDaCopa`:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --path . -s res://tools/capture_track06d_hud_broadcast.gd
```

Resultado: PASS, gate noturno aprovado em 12 capturas.

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Resultado: PASS, `98/98` testes, `1548` asserts, `test_pause_menu.gd` verde, source integrity em `43` arquivos.

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-release "Web" "builds/web/index.html"
```

Resultado: PASS, exit code `0`, preset Web single-threaded.

```powershell
node tools\track04f_chrome_probe.mjs --chrome="C:\Program Files\Google\Chrome\Application\chrome.exe" --web-dir=builds/web --out-dir=docs/screenshots/track-06d --label=06d-web-kickoff-boot --duration-ms=32000 --screenshot-at-ms=26000 --route="/index.html?jdc_capture=kickoff&jdc_perf=1" --http-port=8094 --cdp-port=9234 --fail-on-runtime-errors=1 --expected-stage=event.visible_match_start
```

Resultado: PASS para boot smoke local, `expectedStageSeen=true`, `pageErrors=0`, `consoleErrorCount=0`, screenshot salvo. O JSON registra `stabilityGate=false` porque este comando foi smoke curto, nao gate de estabilidade.

Avisos conhecidos: warnings de UID/text path do GUT durante validate/export e aviso ObjectDB no encerramento de captura/export, sem falha de gate.
