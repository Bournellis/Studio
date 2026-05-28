# DraxosMobile - T08-C Session/Save Boundary

- Data: `2026-05-27`
- Agente: `Codex`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/t08-session-save-boundary`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t08-session-save-boundary`
- Objetivo: endurecer invariantes de `SessionStore`/`SupabaseClient` para save normal vs `progression_lab`, cache local-only, runtime config fallback, snapshots por surface e reset/troca de save.
- Status: `COMPLETE_PENDING_INTEGRATION`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/implementation-plan.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/agent-registry.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/agent-prompts.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/online/session_store.gd`
- `Projetos/draxos-mobile/online/supabase_client.gd` somente se necessario
- `Projetos/draxos-mobile/tests/client/test_session_shell.gd`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/current-status.md`
- `Projetos/draxos-mobile/implementation/current-status.md` se o status observavel mudar
- Este Doing

## Guardrails

- Nao mudar Auth, contratos HTTP, schema, `players.save_type` ou payload publico.
- Nao adicionar endpoint, migration, tuning, gameplay, economia, ranking, rewards, assets finais ou publicacao remota.
- `diagnostics_snapshot`, se adicionado, deve ser interno e sem secrets.

## Validacao Planejada

- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t08-session-save-boundary\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client/test_session_shell.gd -gexit`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t08-session-save-boundary\Projetos\draxos-mobile -s res://tools/validate.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t08-session-save-boundary\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`
- `git diff --check`

## Proximo Handoff

T08-C pronta para integracao Track 08.

Entregas:

- `SessionStore` agora rastreia `surface_save_types` para account/base/social/competition/monetization/battle e rejeita resposta stale quando o save ativo mudou.
- Cache local-only do Progression Lab e carregado sem token valido; login real limpa snapshot local-only e volta ao save normal.
- Reset do save Progression Lab limpa metadados antigos do Lab.
- `SupabaseClient` anota respostas save-scoped com contexto interno `_client.save_type`, sem alterar payload HTTP publico.
- `diagnostics_snapshot()` adicionado em `SessionStore` e `SupabaseClient` sem access token, refresh token, email ou publishable key.
- Status local da Track 08 e `implementation/current-status.md` atualizados.

Validacao:

- `Godot --headless --import`: executado uma vez na worktree para registrar `class_name`/assets do GUT.
- `GUT -gtest=res://tests/client/test_session_shell.gd`: passou; a configuracao carregou a suite client com `90/90` testes e `1001` asserts.
- `tools/validate.gd`: passou; inclui GUT client `90/90` testes e `1001` asserts.
- `GUT -gdir=res://tests/client`: passou com `90/90` testes e `1001` asserts.
- `git diff --check`: passou.

Observacao: a primeira tentativa com `-gdir=res://tests/client/test_session_shell.gd` foi invalida porque GUT espera diretorio nesse parametro; a execucao focada foi refeita com `-gtest`.
