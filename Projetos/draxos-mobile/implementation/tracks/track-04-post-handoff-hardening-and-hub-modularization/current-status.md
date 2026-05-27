# Track 04 - Current Status

- Last Updated: `2026-05-27`
- Status: `PLANNED_AFTER_CLOSED_PLAYTEST`
- Depends On: `T03-P18_COMPLETE - INTERNAL_ALPHA_V0_HANDOFF_READY`
- Next Action: rodada fechada Fabio + tester usando `../../../docs/internal-alpha-v0-handoff.md`.

## Estado

Track 04 esta planejada, mas nao iniciou implementacao. Nenhum codigo do Hub, backend, contratos ou schema deve ser alterado por esta track antes da rodada fechada inicial, salvo bug bloqueante real encontrado no pacote T03-P18.

## Ordem Atual

1. Rodada fechada Fabio + tester.
2. Backlog pos-handoff classificado.
3. Bugs bloqueantes.
4. UX Android/onboarding.
5. Modularizacao incremental do Hub.
6. Rodada humana do Progression Lab.
7. Gate `account_profiles` + `game_saves`, se necessario.

## Guardrails

- Nao misturar refatoracao de `boot.gd` com backend/schema.
- Nao mudar comportamento durante a primeira extracao de telas/presenters.
- `boot.gd` permanece como composicao fina ate as telas estarem estaveis.
- Cada extracao deve terminar com validacao Godot/GUT/smoke relevante.
- Migration de conta/save so depois do playtest inicial, salvo bug real de isolamento.

## Fontes

- Escopo: `scope.md`
- Plano: `implementation-plan.md`
- Handoff T03-P18: `../../../docs/internal-alpha-v0-handoff.md`
- Visao longa: `../../../docs/product-vision.md`
