# Decisao: Promocao De Mobile-Universe Para DraxosMobile (registro retroativo)

## Metadata

- data: `2026-05-18` (registrado retroativamente em 2026-06-10)
- decisor: `Usuario`
- projeto: `estudio`
- prioridade_portfolio: `P2_IMPLEMENTACAO`

## Contexto

O conceito `Projetos/_conceitos/mobile-universe/` amadureceu o suficiente para virar implementacao.

## Decision

Criar `Projetos/draxos-mobile/` como projeto oficial implementavel; `_conceitos/mobile-universe/` vira `ARQUIVO_DESIGN` somente leitura. Nao criar codigo, cenas ou assets a partir do arquivo de design.

## Alternatives Considered

- Implementar dentro de `_conceitos/`: rejeitado; viola o criterio de projeto oficial (AGENTS + current-status + registro).

## Impact

DraxosMobile entra no portfolio com docs locais proprios (product-vision, GDD, contracts) e stack Godot + Supabase.

## Review When

Se partes da visao local forem promovidas ao canon compartilhado.
