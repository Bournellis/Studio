# Decisao: DraxosMobile Arena core precisa UX fix e ainda nao esta provado

## Metadata

- data: `2026-06-14`
- decisor: `Usuario`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`

## Contexto

O hardening tecnico consolidou a fundacao local do DraxosMobile, mas a prova de
produto da Arena PVE ainda nao confirmou que o core loop esta claro e forte o
suficiente para tuning ou expansao.

## Decision

Fabio registrou o veredito combinado: `ARENA_CORE_NEEDS_UX_FIX` e
`ARENA_CORE_NOT_PROVEN`.

Isso significa que a direcao Arena PVE first permanece, mas o core ainda nao
esta aprovado para tuning numerico, economia, conteudo, PVP, Openworld amplo ou
visual final. O proximo pacote de produto deve focar UX/readability/recovery da
Arena e provar novamente o loop tutorial -> primeira arena real -> buffs ->
resumo -> abandono/retomada.

## Alternatives Considered

- `ARENA_CORE_READY_FOR_TUNING`: rejeitado por enquanto.
- Abrir expansao de Bosque/Openworld, PVP, economia ou conteudo: rejeitado.
- Continuar apenas com higiene tecnica sem registrar o resultado de produto:
  rejeitado para evitar interpretacao ambigua por agentes.

## Impact

O trabalho permitido antes de um novo pacote de tuning e restrito a UX/client
flow/readability da Arena, higiene documental e hardening tecnico que reduza
risco sem mudar produto. Labs podem ser consultados, mas nao promovem tuning sem
nova prova humana.

## Review When

Revisar apos uma rodada de UX fix da Arena PVE e nova prova humana usando
`Projetos/draxos-mobile/docs/arena-pve-product-proof.md`.
