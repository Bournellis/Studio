# DraxosMobile Done: conteudo aberto apos merge em master

## Metadata

- data: `2026-06-04`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch base revisada: `master` em `1c72399`
- objetivo: registrar o que ainda tem conteudo real apos o merge de `Openworld Collection Sync Local Fix` + `Main Menu Refactor`.

## Fechado Sem Revisao Adicional

Estes trabalhos foram incorporados ao `master` ou viraram lanes fonte do pacote integrado:

- `codex/draxos-mobile/merge-current-work`
- `codex/draxos-mobile/main-menu-refactor`
- `codex/draxos-mobile/openworld-local-validation`
- `codex/draxos-mobile/openworld-backend-contract`
- `codex/draxos-mobile/openworld-client-resync`
- `codex/draxos-mobile/bosque-v2-guidance`
- `codex/draxos-mobile/bosque-v2-backend`
- `codex/draxos-mobile/bosque-v2-docs`

Os quatro cartoes que ainda estavam em `Kanban/Doing/` foram movidos para `Kanban/Done/`.
As branches/worktrees ancestrais do `master` foram removidas sem force:
`bosque-v2-guidance`, `main-menu-refactor`, `merge-current-work` e
`openworld-local-validation`.
As worktrees duplicadas nao ancestrais tambem foram removidas, preservando os
refs de branch: `bosque-v2-backend`, `bosque-v2-docs`,
`openworld-backend-contract` e `openworld-client-resync`.

## Aberto De Verdade

### `codex/draxos-mobile/openworld-objectives-docs`

Conteudo real: proposta documental de produto para Openworld/Bosque, incluindo etapas futuras de casa/altar/cidade e monstro/NPC/quest como candidatos experimentais.

Risco: nao deve ser mergeado direto. A branch esta baseada em estado antigo, toca `AGENTS.md`, `canon/canon-brief.md`, docs de produto e status operacional, e parte do texto rebaixa o baseline publicado de Bosque v2 para marcadores anteriores.

Sugestao: fazer uma revisao humana curta e extrair apenas o valor de produto ainda util para `Projetos/draxos-mobile/docs/design-pending.md` ou para uma secao pequena em `Projetos/draxos-mobile/docs/minigames/openworld-objectives.md`. Nao trazer as alteracoes antigas de status, canon ou agent docs.

### `codex/draxos-mobile/publish-latest-main-url`

Conteudo real: registro historico de publicacao `latest main URL` e um ajuste de teste de Arena.

Risco: o ajuste de teste ja entrou no `master` como `1c72399`; o restante foi superado pela publicacao Bosque Mecanico Basico v2.

Sugestao: nao mergear no `master`. Se o historico de publicacao for importante, copiar manualmente apenas o handoff/Done como arquivo historico; caso contrario, fechar branch/worktree como superseded.

## Proxima Decisao Recomendada

1. Revisar `openworld-objectives-docs` como decisao de produto, nao como merge tecnico.
2. Decidir se o registro historico de `publish-latest-main-url` deve ser preservado em `Kanban/Done`/`Handoffs`.
3. Depois disso, remover worktrees e branches superseded.

## Resolucao - 2026-06-04

- Registros historicos de `publish-latest-main-url` preservados em
  `Handoffs/` e `Kanban/Done/`, marcados como superseded por Bosque Mecanico
  Basico v2.
- Handoff de `openworld-objectives-docs` preservado como historico, com aviso
  para nao mergear a branch literalmente.
- Conteudo util de produto extraido seletivamente para docs vivos:
  - `docs/minigames/openworld-objectives.md`;
  - `docs/minigames/openworld-decision-pack.md`;
  - `docs/design-pending.md`.
- Novas pendencias registradas:
  - `DMOB-D072` para menu-no-mundo;
  - `DMOB-D073` para conflito minimo.
- Nenhuma aprovacao foi dada para cidade, NPCs, quests, combate, mapa amplo,
  economia nova, PVP/social ou publicacao remota.

## Validacao

- Auditoria feita por `git worktree list`, `git branch --merged`, `git branch --no-merged`, `git diff --stat` e leitura dos cartoes/handoffs relevantes.
- Nenhuma validacao runtime foi necessaria; esta tarefa e de coordenacao.
