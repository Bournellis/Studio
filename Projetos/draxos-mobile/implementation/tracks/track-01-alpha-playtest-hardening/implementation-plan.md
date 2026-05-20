# Track 01 - Implementation Plan

## Sequencia Executada

1. Separar a baseline Track 00 em commit proprio antes de tocar no hardening.
2. Implementar telemetria client no backend: Edge Function, mirror server e smoke Deno.
3. Persistir `session_id` local no Godot e expor envio de telemetria no `SupabaseClient`.
4. Hardenizar o hub alpha com feedback de primeira sessao, busy states, erros offline, pre-condicoes, refresh e reset local.
5. Criar smoke PC-local do loop alpha completo.
6. Atualizar contratos, docs de status, checklist de playtest e painel do estudio.
7. Rodar validacao client/server/local Supabase e commitar Track 01 separadamente.

## Validacao Esperada

- GUT client suite.
- Deno `check` e `lint` nos mirrors `supabase/functions` e `server/functions`.
- `server/tests/first_slice_simulator_test.ts`.
- Supabase local com `db reset`, smokes existentes e smoke novo de telemetry.
- `tools/validate.gd`, `tools/smoke_alpha_loop.gd`, `tools/smoke_battle_replay.gd`, `tools/smoke_session_shell.gd` e `tools/smoke_exports.gd`.

## Gate De Design

Nenhum item de Track 01 exigiu nova sessao de design. Qualquer expansao para modos, plataforma ou mecanicas fora da primeira fatia deve abrir sessao propria antes de implementacao.
