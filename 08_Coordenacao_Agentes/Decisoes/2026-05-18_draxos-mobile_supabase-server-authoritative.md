# Decisao: Supabase Como Backend Alpha E Servidor Autoritativo (registro retroativo)

## Metadata

- data: `2026-05-18` (registrado retroativamente em 2026-06-10)
- decisor: `Usuario`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`

## Contexto

DraxosMobile e multiplataforma (Android/PC/browser) com progressao compartilhada por conta, o que exige autoridade de servidor desde o primeiro slice.

## Decision

Backend alpha em Supabase (Auth, Postgres, Edge Functions, depois Realtime). O cliente Godot nunca simula resultado de batalha nem muta recursos diretamente. Mutations economicas/sociais usam `account_profiles/game_saves`, ruleset registry, idempotencia v1 (`request_hash`) e RPC transacional v1. Caminho de saida preferido a longo prazo: Backend Proprio + Postgres (`docs/backend-own-boundary.md`).

## Alternatives Considered

- Simulacao no cliente com validacao posterior: rejeitado; abre exploits e quebra PVP assincrono.
- Backend proprio desde o inicio: rejeitado para o alpha; Supabase entrega mais rapido.

## Impact

Espelhos `server/` e `supabase/functions` precisam ficar alinhados; secrets nunca entram no cliente/export.

## Review When

Quando custo/limites do Supabase apertarem ou o PVP exigir Realtime alem do plano atual.
