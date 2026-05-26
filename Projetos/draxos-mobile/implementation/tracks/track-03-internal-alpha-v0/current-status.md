# Track 03 - Internal Alpha v0 - Current Status

- Last Updated: `2026-05-26`
- Status: `T03-P03B_COMPLETE - LOCAL SERVER SAVE_TYPE READY`
- Baseline: Track 00 completa, Track 01 completa e Track 02 com Progression Lab/Battle Lab v1 implementados. O projeto ja possui Godot 4.6.2, Supabase local, conta guest, batalha server-authoritative, Base/Social/Competicao/Monetizacao v0, telemetria client nao autoritativa, exports Android/PC/Web, Battle Visual Mockup compartilhado e laboratorios dev-only. A Track 03 prepara a transicao para uma build fechada realista com email/senha, dois saves por conta, backend remoto, updates e playtest de 2 usuarios.

## Implementado Nesta Preparacao

- Escopo da Track 03 criado.
- Plano de implementacao criado.
- Runbook operacional `docs/internal-alpha-v0.md` criado.
- Checklist de playtest `docs/playtest-internal-alpha-v0.md` criado.
- Worktree limpa de outputs gerados e ignore atualizado para novos `.uid`, `.translation` e `build/`.
- Design lock da Internal Alpha v0 registrado em `docs/internal-alpha-v0-design-lock.md`.
- Pendencias `DMOB-D048` a `DMOB-D055` resolvidas.
- Follow-ups de loja/social fechados: redeems entregam apenas Diamante, resetam a meia-noite `America/Sao_Paulo`, amigos usam username e usuarios no Lab aparecem com marcador vermelho `lab`.
- Estrategia backend registrada: Supabase para Internal Alpha v0, Backend Proprio + Postgres como plano de saida preferido e Nakama como alternativa futura apenas se realtime/social competitivo virar pilar.
- `T03-P02` preparado do lado do repo: `BackendConfig` no Godot, ambiente `internal_alpha_v0`, env vars seguras, `.env` reais ignorados, `.env.internal-alpha.example`, runbook remoto e smoke Deno remoto sem service role.
- Ordem local-first aprovada em 2026-05-26: implementar o jogo rodando no Godot/local primeiro; Supabase remoto, builds Android/PC/Web e manifest de updates ficam adiados ate o gameplay local estar pronto para compartilhar.
- `T03-P03A` completo: `SessionStore` possui save ativo `normal`/`progression_lab`, persiste no cache, limpa snapshots ao alternar contexto, marca snapshots local-only do Progression Lab como Lab, `SupabaseClient` prepara header `x-draxos-save-type` e o Hub mostra/troca save ativo com bloqueio claro quando o Lab esta em cache local-only.
- `T03-P03B` completo: schema local ganhou `players.save_type`, unicidade por `auth_user_id + save_type`, RPCs `create_guest_account`/`request_mvp_battle` recebem save, Edge Functions resolvem `x-draxos-save-type` para `account`, `battle`, `base`, `social`, `competition`, `monetization` e `telemetry`, o Hub libera acoes server-backed no Lab, e o save `progression_lab` fica isolado do normal e fora do ranking com motivo explicito.

## Ainda Nao Implementado

- Auth email/senha remoto.
- Reset separado por save.
- Progression Lab aplicado ao save `progression_lab`.
- Supabase remoto real criado/configurado na conta Supabase.
- Deploy remoto de migrations/functions e smoke contra URL real.
- Manifest de updates em Supabase Storage.
- Base/Social/Competicao/Loja refinados para build fechada.
- Export/publicacao das tres builds finais.

## Decisoes Ja Travadas

- Supabase Free remoto primeiro.
- Email + senha.
- Email confirmation desligado no alpha interno.
- Dois saves por conta: `normal` e `progression_lab`.
- Reset separado por save.
- Progression Lab exportado apenas como ferramenta interna/gated.
- Loja com redeem alpha fixo para testar premium.
- Web link pode ser publico/unlisted, mas jogo exige login e acesso alpha.
- Android usa keystore dedicada de Internal Alpha.

## Proximo Passo

Executar `T03-P03C`: implementar reset separado por save no runtime local, garantindo que resetar `normal` nao toque `progression_lab` e vice-versa.

## Validacao Da Preparacao

- `git diff --check`: passou em 2026-05-26.
- `npx -y deno check server/tests/internal_alpha_remote_smoke.ts`: passou em 2026-05-26.
- `npx -y deno task check` em `supabase/functions`: passou em 2026-05-26.
- `npx -y deno task check` em `server/functions`: passou em 2026-05-26.
- `npx -y deno check server/tests/two_save_context_smoke.ts`: passou em 2026-05-26.
- `npx -y supabase db reset`: passou em 2026-05-26 aplicando `202605260001_two_save_context.sql`.
- `npx -y deno run --allow-net --allow-env server/tests/two_save_context_smoke.ts`: passou em 2026-05-26, criando saves distintos `normal` e `progression_lab` na mesma sessao Auth.
- Smokes existentes `battle_request_smoke.ts`, `base_manager_smoke.ts`, `social_competition_smoke.ts`, `monetization_rewards_smoke.ts` e `client_telemetry_smoke.ts`: passaram em 2026-05-26 apos `save_type`.
- `tools/validate.gd`: passou em 2026-05-26 com GUT `46/46` e `280` asserts.
- `tools/smoke_session_shell.gd`: passou em 2026-05-26 com Auth anonimo, conta guest e `account/state`.
- `tools/smoke_dev_lab_ui.gd`: passou em 2026-05-26 no renderer headless.
- `tools/smoke_exports.gd`: passou em 2026-05-26 para Android Alpha, PC Windows Alpha e PC Browser Alpha.
