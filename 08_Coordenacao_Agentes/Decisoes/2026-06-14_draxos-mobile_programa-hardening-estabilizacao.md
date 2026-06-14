# Decisao: DraxosMobile programa de hardening e estabilizacao

## Metadata

- data: `2026-06-14`
- decisor: `Usuario + Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`

## Contexto

Duas analises independentes apontaram que a fundacao tecnica do DraxosMobile e
forte, mas o projeto acumulou risco operacional por estado de release replicado,
cadencia de micro-pacotes, hotspots grandes no client, backend espelhado
manualmente e foco recente no Bosque antes da Arena PVE estar provada por uso
humano.

## Decision

Executar um programa de hardening antes de novas expansoes. A fundacao
server-authoritative, RLS, idempotencia, ledger, account/save authority e
release safety devem ser preservados. O trabalho sera separado em lanes:
`coord-docs`, `backend-schema`, `client-shell`, `openworld` e `arena-pve-proof`.
Bosque/Openworld permanece slice Internal Alpha e launcher/shell integrado; Arena
PVE permanece o primeiro core aprovado a provar.

## Alternatives Considered

- Continuar publicando micro-hotfixes conforme bugs aparecem.
- Reabrir expansao de Openworld, PVP, economia, conteudo ou visual final antes
  da estabilizacao.
- Reescrever a fundacao tecnica.

## Impact

O proximo trabalho prioriza estabilidade, reducao de drift, decomposicao de
hotspots, clareza de contratos e prova humana do core Arena PVE. Publicacao
remota nao e automatica: Fabio decide e executa push via GitHub Desktop; remote
mutation continua exigindo aprovacao explicita e `-ConfirmRemoteMutation`.

## Review When

Revisar depois que `DocsOnly`, `ServerQuick`, `ClientQuick`, `ModePlatform` e o
roteiro de playtest Arena PVE estiverem verdes ou quando Fabio decidir uma nova
publicacao Internal Alpha.
