# Decisao: Caminho Visual Hibrido Do JogoDaCopa (Track 02)

## Metadata

- data: `2026-06-10`
- decisor: `Usuario`
- projeto: `jogodacopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO`

## Contexto

O Track 02 Quality Upgrade precisa elevar o visual sem abandonar a regra editor-first de primitivas geradas por script.

## Decision

Caminho hibrido aprovado por Fabio em 2026-06-10: arena/luz/VFX continuam procedurais; assets CC0 autorizados somente para personagem animado e bola (Track 02C e a track de authored assets explicitamente autorizada). Licencas registradas em `docs/asset-licenses.md`. Sem logos oficiais FIFA/Copa.

## Alternatives Considered

- Tudo procedural: limita qualidade de personagem/animacao.
- Asset pack completo: aumenta binarios no repo e foge da identidade do lab.

## Impact

Define o escopo de 02C e mantem o resto da serie procedural. Os contratos vivos sao `Projetos/JogoDaCopa/docs/avatar-visual-contract.md` e `Projetos/JogoDaCopa/docs/asset-licenses.md`.

O plano original `Projetos/JogoDaCopa/docs/quality-upgrade-plan.md` saiu do `HEAD` no cutover Documentation Lite; sua proveniencia literal permanece no receipt do projeto e no baseline `52f52f7cd33d1711579f9cccbe4c848ab45a02e4`.

## Review When

Apos o playtest da serie Track 02, ou se a identidade visual virar produto publicavel (Track 02G).
