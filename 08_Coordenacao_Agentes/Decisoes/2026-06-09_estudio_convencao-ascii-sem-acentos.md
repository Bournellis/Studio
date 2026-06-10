# Decisao: Convencao ASCII Sem Acentos Em Docs Operacionais (registro retroativo)

## Metadata

- data: `2026-06-09` (confirmada no ops doc hardening; registrado retroativamente em 2026-06-10)
- decisor: `Shared`
- projeto: `estudio`
- prioridade_portfolio: `-`

## Contexto

Docs operacionais ja sofreram corrupcao de encoding em fluxos multiagente (editores, shells e ferramentas com configuracoes distintas de codepage no Windows).

## Decision

Documentacao operacional do estudio (coordenacao, AGENTS, snapshots, cards, handoffs) e escrita em PT-BR sem acentos, ASCII-safe. Nomes tecnicos preservam o original em ingles. Conteudo de jogo player-facing pode usar acentuacao normal dentro dos projetos.

## Alternatives Considered

- UTF-8 com acentos em tudo: rejeitado por enquanto; ja causou linhas corrompidas que precisaram de correcao manual.

## Impact

Leitura levemente menos natural em troca de zero incidentes de encoding entre agentes.

## Review When

Quando toda a cadeia de ferramentas confirmar UTF-8 estavel de ponta a ponta.
