# Track 02G - Product Identity V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_02G_PRODUCT_IDENTITY_V1_COMPLETE`
- Series marker: `JOGO_DA_COPA_TRACK_02_QUALITY_UPGRADE_V1_COMPLETE`
- Branch: `codex/jogodacopa/track02-quality-upgrade-series-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track02-quality-upgrade-series-v1`

## Goal

Dar ao modulo Futebol uma identidade propria e gerar o primeiro smoke de export Windows apresentavel, mantendo o projeto PC Windows/editor-first.

## Delivered

- Nome do produto/modulo definido como `Copa Arena Futebol`.
- `project.godot` atualizado com nome, icone e boot splash.
- Icone autoral adicionado em `assets/branding/copa_arena_icon.svg`.
- Splash autoral PNG adicionado em `assets/branding/copa_arena_splash.png`.
- Menu principal e HUD passam a expor `Copa Arena Futebol`.
- `export_presets.cfg` criado com preset `Windows Desktop` para `builds/windows/CopaArenaFutebol.exe`.
- Preset exclui `addons/gut`, `tests`, `tools`, `docs` e `implementation` do pacote exportado.
- `docs/publication-readiness.md` atualizado com identidade, comando, resultado e limitacoes.
- `tools/validate.gd` atualizado para validar o novo nome e os assets/preset de marca.
- Licencas dos assets de marca registradas em `docs/asset-licenses.md`.

## Validation

- `tools/validate.gd`: PASS, 28 tests, 279 asserts.
- Windows debug export smoke: PASS, exit code `0`.
- Export command: `Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-debug "Windows Desktop" "builds/windows/CopaArenaFutebol.exe"`.
- Generated artifacts (ignored by git): `CopaArenaFutebol.exe` (`100889416` bytes), `CopaArenaFutebol.console.exe` (`84992` bytes), `export-02g.log`.
- Known noise: GUT UID/text-path warnings during validation; ObjectDB leak warning at editor shutdown during export smoke.

## Out Of Scope

- Signed release candidate.
- Distribution storefront setup.
- Web/mobile/multiplayer/backend.
- Official FIFA, World Cup, federation or club marks.
