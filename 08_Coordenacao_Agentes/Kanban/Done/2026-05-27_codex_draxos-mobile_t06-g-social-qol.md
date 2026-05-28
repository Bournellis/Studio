# DraxosMobile - T06-G Social QoL

- Data: `2026-05-27`
- Agente: Codex
- Projeto: `Projetos/draxos-mobile/`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t06-social-qol`
- Branch: `codex/draxos-mobile/t06-social-qol`
- Status: `READY_FOR_INTEGRATION`

## Objetivo

Melhorar a legibilidade da surface Social para amigos, guilda e chat, cobrindo estados vazios, refresh e mensagens atuais sem criar endpoints, schema, realtime ou moderacao.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/implementation-plan.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/surfaces/social_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/boot.gd` se necessario para refresh/mensagem existente
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/tools/smoke_foundation_surfaces.gd`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/current-status.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Validacao Planejada

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-social-qol\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-social-qol\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-social-qol\Projetos\draxos-mobile -s res://tools/smoke_foundation_surfaces.gd
git diff --check
```

## Handoff

T06-G esta pronto para T06-I integrar. O pacote melhora apenas a leitura da surface Social:

- `social_surface_presenter.gd` ganhou painel de refresh/polling, resumo de snapshot, identidade social, amigos/guilda/chat com estados vazios e mensagens atuais formatadas.
- `test_boot_mobile_ui.gd` cobre polling, lab badges, timestamp de mensagem e estados vazios de amigos/guilda/chat.
- `smoke_foundation_surfaces.gd` agora valida membros/estruturas de guilda e que a mensagem atual do chat volta primeiro no polling.

## Validacao Executada

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-social-qol\Projetos\draxos-mobile --import
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-social-qol\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-social-qol\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-social-qol\Projetos\draxos-mobile -s res://tools/smoke_foundation_surfaces.gd
git diff --check
```

- GUT completo: `64/64` testes, `703` asserts.
- `validate.gd`: passou.
- `smoke_foundation_surfaces.gd`: passou com Social/guilda/chat.
- `git diff --check`: passou no fechamento.

## Pendencias

- T06-I deve revisar os textos novos junto com as demais branches T06.
- Guardrails preservados: sem endpoint novo, realtime, moderacao, schema, ranking behavior, backend, economia, contratos novos ou publicacao remota.
