# Track 04 - Current Status

- Last Updated: `2026-05-27`
- Status: `ACTIVE_POST_ALPHA_EVOLUTION`
- Depends On: `T03-P18_COMPLETE - INTERNAL_ALPHA_V0_HANDOFF_READY`; `T04-P00_COMPLETE_BY_USER_CONFIRMATION`
- Next Action: executar T04-A coordenacao, T04-B Hub Scaffold, T04-G Progression/Economia e T04-H Account/Save Gate em worktrees separadas.

## Estado

Track 04 entrou em evolucao pos-alpha ativa. Fabio confirmou que os testes da Internal Alpha v0 com Fabio + tester passaram, entao o gate inicial da rodada fechada esta satisfeito. Nenhum bug bloqueante foi informado como impeditivo imediato.

O trabalho deve seguir em paralelo controlado: primeiro coordenacao e Hub Scaffold, depois extracoes render-only por superficie. Progression/Economia e Account/Save Gate podem andar em paralelo como documentacao/analise, sem alterar numeros de economia ou schema antes de decisao explicita.

## Ordem Atual

1. `T04-A` Coordenacao pos-alpha.
2. `T04-B` Hub Scaffold e plano de corte.
3. `T04-C` Shell/Login/Update.
4. `T04-D` Base/Loja, `T04-E` Social/Competicao e `T04-F` Batalha/Replay.
5. `T04-G` Progression/Economia.
6. `T04-H` Gate `account_profiles` + `game_saves`.

## Guardrails

- Nao misturar refatoracao de `boot.gd` com backend/schema.
- Nao mudar comportamento durante a primeira extracao de telas/presenters.
- `boot.gd` permanece como composicao fina ate as telas estarem estaveis.
- Cada extracao deve terminar com validacao Godot/GUT/smoke relevante.
- Migration de conta/save so depois do playtest inicial, salvo bug real de isolamento.
- Como o playtest inicial passou, migration continua proibida ate `T04-H` registrar decisao documentada.

## Fontes

- Escopo: `scope.md`
- Plano: `implementation-plan.md`
- Handoff T03-P18: `../../../docs/internal-alpha-v0-handoff.md`
- Visao longa: `../../../docs/product-vision.md`
