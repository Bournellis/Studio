# Portfolio Sync Queue

## Metadata

- status: `active`
- authority: `portfolio_snapshot`
- last_verified: `2026-08-27`
- review_when: `pending entry exceeds 48 hours or cutover rules change`
- supersedes: `none`
- superseded_by: `none`

Esta fila separa trabalho local de atualizacoes nos hot files globais. Ela nao e fonte de status: os status locais e `Prioridades_Estudio.md` continuam prevalecendo.

## Pending

Nenhuma entrada pendente.

## Reflected

| id | project | source | requested_at | reflected_at | fields | state |
|---|---|---|---|---|---|---|
| `governanca-v2-cutover` | `AllOfficial` | `2026-07-16_estudio-governanca-v2` | `2026-07-16` | `2026-07-16` | `baseline, validation, local coordination` | `reflected` |
| `governanca-v21-integrity-production` | `AllOfficial` | `2026-07-17_estudio-governanca-v21` | `2026-07-17` | `2026-07-17` | `documentation hygiene, closure, execution isolation, mobile QA, visual production, evidence and security` | `reflected` |

O conteudo refletido vive em `Estado_Atual.md`; esta fila registra somente o ato de sincronizacao.

## Rules

- Uma tarefa local que altere uma baseline pode somente acrescentar sua propria entrada `pending`; ela nao altera entradas existentes nem atualiza `Estado_Atual.md`.
- Somente tarefas `portfolio_sync`, `cross_project` ou `global_governance` consomem a fila: refletem, adiam, superam ou removem entradas e, quando aplicavel, atualizam `Estado_Atual.md`.
- `Prioridades_Estudio.md` muda apenas quando Fabio muda foco, status ou trabalho permitido.
- Uma entrada pode ser `pending`, `reflected`, `deferred` ou `superseded`.
