# Track 04 - Current Status

- Last Updated: `2026-05-27`
- Status: `ACTIVE_POST_ALPHA_EVOLUTION`
- Depends On: `T03-P18_COMPLETE - INTERNAL_ALPHA_V0_HANDOFF_READY`; `T04-P00_COMPLETE_BY_USER_CONFIRMATION`
- Next Action: revisar/publicar a branch de integracao `codex/draxos-mobile/t04-integration`; depois escolher entre tuning humano do Progression Lab, UX/onboarding Android ou nova rodada de modularizacao fina.
- Account Save Gate: `DECIDED_KEEP_PLAYERS_SAVE_TYPE_FOR_ALPHA` em `account-save-gate-decision.md`.

## Estado

Track 04 entrou em evolucao pos-alpha ativa. Fabio confirmou que os testes da Internal Alpha v0 com Fabio + tester passaram, entao o gate inicial da rodada fechada esta satisfeito. Nenhum bug bloqueante foi informado como impeditivo imediato.

O trabalho deve seguir em paralelo controlado: primeiro coordenacao e Hub Scaffold, depois extracoes render-only por superficie. Progression/Economia e Account/Save Gate podem andar em paralelo como documentacao/analise, sem alterar numeros de economia ou schema antes de decisao explicita.

Integracao 2026-05-27: as trilhas `T04-B` a `T04-F` foram consolidadas em uma branch unica de integracao com presenters render-only em `modes/boot/surfaces/`. `boot.gd` permanece orquestrador de sessao, navegacao, busy state, telemetria e chamadas Supabase. Tambem foram integrados o relatorio tecnico `T04-G` e a decisao `T04-H`, sem alteracao de economia, backend, schema ou contratos HTTP.

## Ordem Atual

1. `T04-A` Coordenacao pos-alpha: concluida.
2. `T04-B` Hub Scaffold e plano de corte: integrado.
3. `T04-C` Shell/Login/Update: integrado.
4. `T04-D` Base/Loja, `T04-E` Social/Competicao e `T04-F` Batalha/Replay: integrados.
5. `T04-G` Progression/Economia: rodada tecnica documentada; rodada humana real ainda recomendada antes de tuning numerico.
6. `T04-H` Gate `account_profiles` + `game_saves`: decidido manter `players.save_type` para alpha/Track 04 inicial.

## Guardrails

- Nao misturar refatoracao de `boot.gd` com backend/schema.
- Nao mudar comportamento durante a primeira extracao de telas/presenters.
- `boot.gd` permanece como composicao fina ate as telas estarem estaveis.
- Cada extracao deve terminar com validacao Godot/GUT/smoke relevante.
- Migration de conta/save so depois do playtest inicial, salvo bug real de isolamento.
- Como `T04-H` decidiu manter `players.save_type`, migration continua fora do pacote atual; se surgir gatilho real, abrir track/commit proprio antes de qualquer SQL.

## Fontes

- Escopo: `scope.md`
- Plano: `implementation-plan.md`
- Plano de modularizacao: `hub-modularization-plan.md`
- Decisao account/save: `account-save-gate-decision.md`
- Relatorio Progression/Economia: `../../../docs/progression-lab/2026-05-27-t04-progression-economia.md`
- Handoff T03-P18: `../../../docs/internal-alpha-v0-handoff.md`
- Visao longa: `../../../docs/product-vision.md`
