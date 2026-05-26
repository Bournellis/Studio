# Track 03 - Internal Alpha v0 - Current Status

- Last Updated: `2026-05-26`
- Status: `T03-P09_COMPLETE - BATTLE VISUAL POLISH SMALL`
- Baseline: Track 00 completa, Track 01 completa e Track 02 com Progression Lab/Battle Lab v1 implementados. O projeto ja possui Godot 4.6.2, Supabase local, conta guest, batalha server-authoritative, Base/Social/Competicao/Monetizacao v0, telemetria client nao autoritativa, exports Android/PC/Web, Battle Visual Mockup compartilhado e laboratorios internos. A Track 03 prepara a transicao para uma build fechada realista com email/senha, dois saves por conta, backend remoto, updates e playtest de 2 usuarios.

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
- `T03-P03C` completo: `POST /account/saves/reset` e RPC `reset_player_save` reconstroem apenas o save ativo, preservam o outro save da mesma sessao Auth, limpam snapshots client-side do save resetado, mantem idempotencia por `request_id` e expoem botao perigoso "Resetar save ativo" no Hub.
- `T03-P04` completo: `POST /progression-lab/apply` e RPC `apply_progression_lab_save` aplicam healthy saves versionados apenas no save `progression_lab`, preservam o save `normal`, limpam snapshots/estado antigo do Lab, mantem idempotencia por `request_id`, atualizam o Progression Lab Dev com "Aplicar no Save Lab" e validam o fluxo em smoke server.
- `T03-P05` completo: Base Manager virou fluxo jogavel no Hub, com mapa de predios clicaveis, painel detalhado por estrutura, tooltips, upgrade por predio, compra alpha de Energia, custo/tempo/producao/status calculados pelo servidor e smoke cobrindo upgrade/fila.
- `T03-P06` completo: Social virou fluxo basico jogavel no Hub, com amigos por username, criar/entrar em guilda, lista de membros/estruturas, chat de guilda por polling, rate limit, erros amigaveis, tooltips, painéis de estado e identidade social de conta com marcador `lab`.
- `T03-P07` completo: Competicao virou leaderboard alpha jogavel; `battle/request` `FIRST_SLICE_SIM` pontua o save `normal` com modelo `alpha_v0_power_adjusted`, `progression_lab` permanece fora do ranking, `competition/ranking/current` retorna top 10 + posicao do jogador, bots ficam fora da leaderboard e o Hub mostra matchmaking, ultima batalha competitiva e ranking com tooltips.
- `T03-P08` completo: Loja virou proof-of-concept jogavel; `monetization/state` retorna `shop_summary` e produtos enriquecidos, redeems diarios entregam apenas Diamante por save com reset Sao Paulo, Battle Pass/fila dupla/pacotes usam Diamante, fila dupla altera a Base para 2 slots e o Hub mostra resumo, catalogo, recompensas, bloqueio visual e tooltips.
- `T03-P09` completo: Batalha recebeu polish visual pequeno sem assets externos; o palco 2D mostra readout compacto de replay/tempo/HP/status/cooldowns/aliados, labels incluem HP percentual e tooltips de evento humanizam fonte/alvo com leitura rapida.

## Ainda Nao Implementado

- Auth email/senha remoto.
- Supabase remoto real criado/configurado na conta Supabase.
- Deploy remoto de migrations/functions e smoke contra URL real.
- Manifest de updates em Supabase Storage.
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

Preparar `T03-P11`: rodada local de QA/playtest no Godot para consolidar bugs e lacunas antes de remoto/builds. `T03-P10` continua adiado ate o gameplay local estar pronto para export/publicacao.

## Validacao Da Preparacao

- `git diff --check`: passou em 2026-05-26.
- `npx -y deno check server/tests/internal_alpha_remote_smoke.ts`: passou em 2026-05-26.
- `npx -y deno task check` em `supabase/functions`: passou em 2026-05-26.
- `npx -y deno task check` em `server/functions`: passou em 2026-05-26.
- `npx -y deno check server/tests/two_save_context_smoke.ts`: passou em 2026-05-26.
- `npx -y deno check server/tests/reset_save_context_smoke.ts`: passou em 2026-05-26.
- `npx -y deno check server/tests/progression_lab_apply_smoke.ts`: passou em 2026-05-26.
- `npx -y deno check server/tests/social_competition_smoke.ts`: passou em 2026-05-26.
- `npx -y deno check supabase/functions/monetization/index.ts supabase/functions/base/index.ts server/tests/monetization_rewards_smoke.ts server/tests/base_manager_smoke.ts server/tests/progression_lab_apply_smoke.ts server/tests/reset_save_context_smoke.ts`: passou em 2026-05-26.
- `npx -y deno lint supabase/functions/monetization/index.ts supabase/functions/base/index.ts server/functions/monetization/index.ts server/functions/base/index.ts server/tests/monetization_rewards_smoke.ts server/tests/base_manager_smoke.ts server/tests/progression_lab_apply_smoke.ts server/tests/reset_save_context_smoke.ts`: passou em 2026-05-26.
- `npx -y deno check tools/progression_lab/seed_supabase.ts`: passou em 2026-05-26.
- `npx -y supabase db reset`: passou em 2026-05-26 aplicando `202605260001_two_save_context.sql`, `202605260002_reset_save_context.sql` e `202605260003_progression_lab_apply.sql`.
- `npx -y deno run --allow-net --allow-env server/tests/two_save_context_smoke.ts`: passou em 2026-05-26, criando saves distintos `normal` e `progression_lab` na mesma sessao Auth.
- `npx -y deno run --allow-net --allow-env server/tests/reset_save_context_smoke.ts`: passou em 2026-05-26, validando reset separado, idempotencia e rejeicao de mismatch de `save_type`.
- `npx -y deno run --allow-net --allow-env server/tests/progression_lab_apply_smoke.ts`: passou em 2026-05-26, validando aplicacao server-backed do Progression Lab, preservacao do save normal, ranking bloqueado e batalha jogavel no Lab.
- `npx -y deno run --allow-net --allow-env server/tests/social_competition_smoke.ts`: passou em 2026-05-26, validando dois testadores, amizade por username, guilda create/join, membros enriquecidos, chat idempotente, rate limit, polling, top 10/self rank e RLS.
- Smokes existentes `battle_request_smoke.ts`, `first_slice_battle_smoke.ts`, `base_manager_smoke.ts`, `monetization_rewards_smoke.ts` e `client_telemetry_smoke.ts`: passaram em 2026-05-26 apos reset de save; `first_slice_battle_smoke.ts` agora valida arena/ranking idempotente.
- `npx -y deno test tools/progression_lab`: passou em 2026-05-26.
- `npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all`: passou em 2026-05-26.
- `npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts`: passou em 2026-05-26.
- `tools/validate.gd`: passou em 2026-05-26 com GUT `49/49` e `320` asserts.
- `npx -y deno run --allow-net --allow-env server/tests/base_manager_smoke.ts`: passou em 2026-05-26, validando payload jogavel da Base, compra alpha de Energia, upgrade por predio, fila cheia, compra da fila dupla e limite em 2 upgrades ativos.
- `npx -y deno run --allow-net --allow-env server/tests/monetization_rewards_smoke.ts`: passou em 2026-05-26, validando `shop_summary`, quatro redeems diarios, bloqueio de duplicacao diaria, compra premium por Diamante, fila dupla em `convenience_owned`, reward premium e RLS.
- `tools/smoke_session_shell.gd`: passou em 2026-05-26 com Auth anonimo, conta guest e `account/state`.
- `tools/smoke_alpha_loop.gd`: passou em 2026-05-26 com Auth anonimo, battle/base/social/competition/shop, redeem de Loja e telemetria final.
- `tools/smoke_dev_lab_ui.gd`: passou em 2026-05-26 no renderer headless.
- `tools/smoke_dev_labs.gd`: passou em 2026-05-26.
- `tools/smoke_exports.gd`: passou em 2026-05-26 para Android Alpha, PC Windows Alpha e PC Browser Alpha.
