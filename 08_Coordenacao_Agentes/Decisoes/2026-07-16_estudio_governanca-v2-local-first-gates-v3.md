# Decisao: Governanca Estudio v2 - local-first e gates v3

## Metadata

- data: `2026-07-16`
- escopo: `global_governance`
- decisor: `Fabio`
- status: `active`
- supersedes: `2026-06-10_estudio_fonte-unica-de-estado.md`

## Decisao

O Estudio adota coordenacao local-first sem criar uma segunda fonte de estado local. `Prioridades_Estudio.md` governa foco, status e trabalho permitido. Cada `implementation/current-status.md` governa baseline, gate, risco, validacao e proximo passo tecnico local. `Estado_Atual.md` e uma projecao curta de portfolio, atualizada somente por tarefas `portfolio_sync`.

Cards novos usam `agent_local_merge_v3`. `Review` contem apenas decisao humana pendente com `blocking_decision` explicita; `Done` nao aceita gate humano pendente. Trabalho tecnico verde pode ser integrado e limpo antes do gate humano, sem implicar aprovacao de produto, visual, dispositivo, release ou remoto.

## Impacto

- Trabalho local escreve no projeto e na coordenacao local.
- Trabalho global, cross-project e portfolio sync permanece no hub raiz.
- READMEs, AGENTS, indices e dashboards sao routers sem estado operacional.
- Historico fica em tracks, release history, Kanban Done e handoffs.
- Prioridades e gates humanos existentes nao mudam por causa do cutover.

## Guardrails

- Nao mover os cards/handoffs globais historicos para projetos.
- Nao criar `08_Coordenacao/Estado.md`; manter `implementation/current-status.md`.
- Nao importar mecanicas entre projetos.
- A sincronizacao Git rotineira segue a delegacao estreita de `2026-08-27_estudio_git_push_seguro_delegado_codex.md`; publicacao de produto e demais mutacoes remotas continuam exclusivas de Fabio.

## Review when

Revisar se a coordenacao local gerar duplicacao de estado, se o portfolio sync ficar recorrente atrasado ou se os gates v3 criarem falso bloqueio operacional.
