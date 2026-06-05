# DraxosMobile - Arena PVE Season 1 Loop v1

- Status: `IMPLEMENTED_LOCAL`
- Data: `2026-06-05`
- Decisao-base: `ARENA_PVE_SEASON1_LOOP_V1`
- Escopo: tornar a Season 1 da Arena PVE jogavel como loop legivel, recuperavel e publicavel sem abrir PVP, economia final, novas armas/spells/pocoes ou tuning fino.

## Objetivo

Arena PVE Season 1 Loop v1 transforma o pacote de Arena ja publicado em uma leitura de temporada:

- selecao por arena e dificuldade, agrupada por comprimento;
- progresso S1 visivel;
- proximo desafio recomendado;
- recompensa prevista sem prometer claim autoritativo;
- resumo com proximo passo contextual;
- retomada segura de tentativa com buff pendente apos update;
- smoke remoto ampliado para tutorial + primeira arena real de 3 duelos.

## Entrega Client

- `modes/boot/surfaces/arena_surface_presenter.gd` renderiza `ArenaSeason1ProgressPanel`, grupos `ArenaSeason1Group_*` e `ArenaSeason1NextStepPanel`.
- A selecao nao mostra mais uma lista plana de botoes: cada arena mostra progresso, dificuldade proxima, dificuldades disponiveis/bloqueadas e motivo de bloqueio.
- O recomendado exibe status de primeiro clear/repeticao e recompensa prevista do tier.
- A tela ativa com buff pendente usa `ACTION_ARENA_RESUME_ATTEMPT` para abrir a tela de escolha, sem selecionar automaticamente o primeiro buff.
- O resumo troca copy generica por orientacao de Season 1 antes de retornar a lista atualizada.
- `arena_lifecycle_flow.gd` alinha o fallback legado da primeira arena real: `s1_d00_intro` usa tier `0`.

## Entrega Backend

- `/arena/pve/state` e o delta de `/arena/pve/claim` enriquecem `active_attempt` com `latest_step`, `last_step`, `state = "awaiting_buff"` e `buff_offer` quando a ultima step ativa possui opcoes de buff ainda nao escolhidas.
- O mirror `server/functions/arena/index.ts` e `supabase/functions/arena/index.ts` permanece identico.
- O contrato preserva fonte autoritativa de recompensa no ultimo `/arena/pve/duel/request`; `/arena/pve/claim` continua summary-only.

## Guards

Novos/atualizados:

- GUT cobre UI de Season 1, recompensa prevista, grupos por arena, resumo contextual, buff pendente sem auto-select e active attempt remoto com `buff_offer`.
- Deno cobre mirror server/supabase, active attempt enriquecido, botao de buff por retomada, progressao de unlock para arenas media/longa e smoke remoto S1 ampliado.
- `server/tests/internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_ARENA_SMOKE=1` passa a provar:
  - tutorial;
  - claim summary-only;
  - unlock da primeira arena real;
  - bloqueio de nova tentativa com uma tentativa ativa;
  - 3 duelos da primeira arena real;
  - buff pendente preservado em `/arena/pve/state`;
  - selecao de buff entre duelos;
  - recompensa final no terceiro duelo;
  - claim final summary-only.

## Fora De Escopo

- Tuning numerico fino.
- Novas arenas alem do catalogo S1 existente.
- Novos tipos de buff.
- Daily/weekly/season cap runtime novo.
- PVP, ranking PVP, guilda ou social expansion.
- Battle presentation/final art pass.
- Openworld expansion.

## Validacao Local Inicial

- `deno test --allow-read server/tests/arena_loop_unlock_friction_test.ts server/tests/pve_arena_catalog_test.ts`: PASS, 9 tests.
- `deno check server/tests/internal_alpha_remote_smoke.ts`: PASS.
- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- GUT client suite: PASS, 234 tests and 3690 asserts.
- `tools/validate.gd`: PASS, 234 tests and 3690 asserts.

## Publicacao

Pendente nesta fase ate commit, merge em `main`, export/package/upload/deploy e RemoteReadOnly.
