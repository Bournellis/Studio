# Track 01 - Alpha Playtest Hardening

- Status: `COMPLETE - PC_LOCAL_ALPHA_PLAYTEST_READY`
- Data: `2026-05-20`
- Projeto: `draxos-mobile`

## Objetivo

Transformar o primeiro slice ja implementado em uma experiencia confiavel para playtest alpha local no PC, sem abrir novos modos, novas mecanicas ou balanceamento sem dados.

Track 01 assume Track 00 como baseline: Godot client, Supabase local, auth guest, batalha server-authoritative, Base, Social/Competicao, Monetizacao, pipeline de conteudo, exports e testes.

## Entregas

- Hub alpha preservando o Refugio/tab hub atual.
- Fluxo de primeira sessao mais claro, com feedback de refresh/recovery, erros offline e estados ocupados.
- Pre-condicoes visiveis para acoes que exigem sessao ou conta guest.
- Replay com telemetria de inicio, skip e fim.
- Acao segura de reset de cache/sessao local para recuperacao de teste.
- Endpoint `POST /telemetry/client-event` em `supabase/functions/telemetry` e espelho em `server/functions/telemetry`.
- `SessionStore` com `session_id` local persistido.
- `SupabaseClient.send_client_telemetry(...)` para eventos client-side nao autoritativos.
- Smoke PC-local alpha: guest -> state -> battle -> base -> social -> competition -> shop -> telemetry.
- Smoke server para telemetry insert, auth e expectativa de RLS.
- Checklist de playtest alpha e template de feedback.

## Fora Do Escopo

- Android export runtime e deploy browser como alvo obrigatorio de playtest Track 01.
- XP, Energia, pesos de poder, numeros de combate, bonus de guilda e economia de Diamante fora de ajustes manuais sem dados de playtest.
- PVE, cardgame roguelike, hero defense, open world, expansao de hierarquia/lore Draxos, iOS, mobile browser e chat global.
- Email/senha, Google Sign-In, migracao guest, `build/equip`, upgrades genericos, missoes/conquistas, ajuda/contribuicao, chat direto/block/report e mutacao real de ranking.

## Design Gates

Implementado sem sessao de design: hardening do alpha, telemetria, checklist de playtest, clareza de UX e smokes.

Exige sessao de design antes de implementacao: qualquer item `POS_SLICE`, novo modo, nova mecanica, balanceamento economico/combativo definitivo ou expansao de plataforma.
