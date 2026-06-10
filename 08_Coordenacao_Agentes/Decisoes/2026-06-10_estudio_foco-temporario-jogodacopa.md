# Decisao: Foco Temporario Unico No JogoDaCopa

## Metadata

- data: `2026-06-10`
- decisor: `Usuario`
- projeto: `estudio`
- prioridade_portfolio: `P2_IMPLEMENTACAO`

## Contexto

Fabio decidiu pausar o estudio por alguns dias para criar o jogo da copa enquanto o evento esta vivo.

## Decision

`Projetos/JogoDaCopa/` e o foco operacional temporario unico. `draxos-roguelike-cardgame`, `draxos-mobile` e `FpsPlayground` ficam `PAUSADO_TEMPORARIO` com baselines preservadas; pedidos sem projeto explicito assumem JogoDaCopa.

## Alternatives Considered

- Manter o roguelike como P0 em paralelo: rejeitado; solo dev, foco unico entrega mais rapido.

## Impact

Agentes ignoram projetos pausados por padrao. Retomada esperada em poucos dias, sem perda de baseline.

## Review When

Ao encerrar o foco temporario - restaurar prioridades em `Prioridades_Estudio.md` e `Estado_Atual.md`.
