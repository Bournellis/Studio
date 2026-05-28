# Track 15 - DraxosMobile Mobile UX Overhaul

- status: `Doing`
- projeto: `draxos-mobile`
- agente: `Codex`
- branch: `codex/draxos-mobile/track-15-mobile-ux-overhaul`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--track-15-mobile-ux-overhaul`
- base: `codex/draxos-mobile/agent-ops-foundation`
- data: `2026-05-28`

## Objetivo

Transformar o DraxosMobile de app alpha/dev funcional em um app interno Android portrait confortavel, premium e sustentavel, sem alterar gameplay, backend, schema, Supabase APIs, simulador ou economia.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/core/`
- `Projetos/draxos-mobile/assets/ux_overhaul/`
- `Projetos/draxos-mobile/modes/boot/`
- `Projetos/draxos-mobile/ui/`
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/tools/`
- `Projetos/draxos-mobile/docs/`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-15-mobile-ux-overhaul/`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- `Projetos/README.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-14-agent-ops-foundation/`

## Validacao Planejada

```powershell
git diff --check
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_hardening.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_exports.gd
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { .\tools\validate_foundation.ps1 -ProjectDir . -Profile Client -RequireClean:`$false }"
```

## Handoff

Checkpoint visual gerado em `Projetos/draxos-mobile/build/track15_mobile_ux_checkpoint/` e validacao Client verde. Proximo ponto: revisao humana de Entry, Refugio, Batalha/Summary, Base e Loja em Android portrait; manter a branch sem mudancas de gameplay/backend/economia.
