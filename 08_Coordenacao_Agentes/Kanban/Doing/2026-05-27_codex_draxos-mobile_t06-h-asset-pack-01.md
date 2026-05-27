# T06-H Asset Pack 01 - Codex

- Data: `2026-05-27`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/t06-asset-pack-01`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t06-asset-pack-01`
- Projeto: `Projetos/draxos-mobile`
- Track: `Track 06 - Feature Installation Rails And First Feature Slices`
- Feature ID: `ASSET_PACK_01_SAFE`
- Status: `READY_FOR_INTEGRATION`

## Objetivo

Instalar o primeiro pacote visual seguro de T06-H usando ids estaveis de `AssetIds`, com PNGs leves para UI/batalha e fallback obrigatorio quando arte estiver ausente.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/assets/`
- `Projetos/draxos-mobile/core/asset_ids.gd`
- `Projetos/draxos-mobile/ui/battle_symbol_icon.gd`
- `Projetos/draxos-mobile/ui/battle_stage_2d.gd`
- `Projetos/draxos-mobile/tests/client/test_content_foundation.gd`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/current-status.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `canon/canon-brief.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/implementation-plan.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md`
- `Projetos/draxos-mobile/assets/README.md`
- `Projetos/draxos-mobile/core/asset_ids.gd`

## Validacao Planejada

- AssetIds/fallback GUT via `res://tests/client/test_content_foundation.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-asset-pack-01\Projetos\draxos-mobile -s res://tools/validate.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-asset-pack-01\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-asset-pack-01\Projetos\draxos-mobile -s res://tools/smoke_exports.gd`
- `git diff --check`

## Handoff

Entregar T06-H como `READY_FOR_INTEGRATION` com assets pequenos locais, hooks seguros, fallback testado e sem tocar backend, economia, gameplay, schema ou publicacao remota.

## Resultado

- `ASSET_PACK_01_SAFE` instalado com PNGs 128x128 leves para UI icons, portraits pequenos e `battle_icon_*`.
- `BattleSymbolIcon` usa textura via `AssetIds` quando o arquivo existe e preserva fallback nativo quando a arte falta.
- `boot_background`, `placeholder_card`, `battle_fx_*` e personagens de batalha continuam opcionais/missing.
- Nenhum backend, schema, economia, tuning, release remoto ou gameplay foi alterado.

## Validacao Executada

- Import headless inicial do Godot na worktree para reconstruir cache `.godot/` e imports locais ignorados pelo Git.
- `tools/validate.gd`: passou, 65 testes, 777 asserts.
- GUT client completo: passou, 65 testes, 777 asserts.
- `tools/smoke_exports.gd`: passou para Android Alpha, PC Windows Alpha e PC Browser Alpha.
- `git diff --check`: passou.
