# Decisao: Arena PVE Como Primeiro Core Aprovado Do DraxosMobile (registro retroativo)

## Metadata

- data: `2026-06-10` (registro retroativo; decisao tomada no inicio de junho de 2026 com o Track 18)
- decisor: `Usuario`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`

## Contexto

Apos a fundacao tecnica (Tracks 00-17), o produto precisava de um primeiro core jogavel para o Internal Alpha em vez de expandir varias frentes ao mesmo tempo.

## Decision

Arena PVE e o primeiro core de produto aprovado, governado por `docs/pve-arena-initial-direction.md`: tentativa com loadout travado, lista de duelos com scaling, buffs temporarios entre duelos, sem cooldown de combate, recompensas via claim de resumo. Bosque/Openworld e slice integrado do Internal Alpha, nao aprovacao para expansao ampla. PVP, social amplo, tuning numerico e visual final ficam bloqueados ate decisao propria.

## Alternatives Considered

- Base builder primeiro: mantido como loop de suporte (Refugio), nao como core inicial.
- PVP assincrono direto: rejeitado; exige populacao e tuning que o PVE valida antes.

## Impact

Todos os pacotes publicados orbitam Arena PVE + Bosque slice; os Hard Stops do AGENTS local refletem esses limites.

## Review When

Apos playtests humanos consistentes do loop Arena PVE, ao decidir o proximo core (PVP/social/minigames).
