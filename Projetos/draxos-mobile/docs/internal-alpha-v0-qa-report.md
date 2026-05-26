# DraxosMobile - Internal Alpha v0 Local QA Report

- Data: `2026-05-26`
- Escopo: `T03-P11` em modo local-first
- Baseline validado: commit anterior ao QA `577e0b1`
- Resultado: `PASS_LOCAL_AUTOMATED_QA`

## Reset Executado

- Cache local Godot removido: `C:\Users\Fabio\AppData\Roaming\Godot\app_userdata\DraxosMobile`.
- Scratch do Progression Lab removido: `.progression_lab_scratch/`.
- Supabase local resetado com `npx -y supabase db reset`.
- Healthcheck local respondeu `200` em `http://127.0.0.1:54321/functions/v1/healthcheck`.

## Validacao Server/Tooling

Passou:

- `npx -y deno task check` em `supabase/functions`.
- `npx -y deno task check` em `server/functions`.
- `npx -y deno task lint` em `supabase/functions`.
- `npx -y deno task lint` em `server/functions`.
- `npx -y deno check` para smokes de remoto local, dois saves, reset, Progression Lab apply, Social/Competicao e seeder.
- `npx -y deno test tools/battle_lab tools/progression_lab server/tests/first_slice_simulator_test.ts`: `20/20`.
- `npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all`: `25/25` saves selecionados.

Smokes Supabase locais passaram:

- `battle_request_smoke.ts`: batalha MVP gravada com `8` eventos, `xp=5`, `ossos=1`.
- `first_slice_battle_smoke.ts`: batalhas FIRST_SLICE com logs ricos; amostra de efeitos com `114` eventos e summon com `92` eventos.
- `two_save_context_smoke.ts`: saves `normal` e `progression_lab` criados isolados na mesma sessao Auth.
- `reset_save_context_smoke.ts`: reset isolado/idempotente por save.
- `progression_lab_apply_smoke.ts`: perfil `free_100_rewards_10h` aplicado no save Lab sem tocar o Normal.
- `base_manager_smoke.ts`: `6` estruturas, coleta, compra alpha de Energia, upgrade e fila dupla.
- `social_competition_smoke.ts`: dois testadores, amizade/guilda/chat/ranking; guilda com `2` membros e `2` mensagens.
- `monetization_rewards_smoke.ts`: redeems/Loja premium/fila dupla; saldo final validado com `1050` Diamantes e premium ativo.
- `client_telemetry_smoke.ts`: telemetria antes/depois de conta guest e RLS validado.

## Validacao Godot

Passou:

- `tools/validate.gd`: GUT `49/49`, `320` asserts.
- `tools/smoke_exports.gd`: presets `Android Alpha`, `PC Windows Alpha` e `PC Browser Alpha`.
- `tools/smoke_session_shell.gd`: Auth anonimo, guest e `account/state`.
- `tools/smoke_battle_replay.gd`: replay FIRST_SLICE com `114` eventos.
- `tools/smoke_alpha_loop.gd`: fluxo guest -> batalha -> base -> social -> competicao -> loja -> telemetria.
- `tools/smoke_dev_labs.gd`: Battle Lab bridge e Progression Lab generate.
- `tools/smoke_dev_lab_ui.gd`: telas dev em headless; screenshots pulados pelo renderer headless.

## Checklist Coberto Por Automacao

- Save normal server-backed funcional.
- Dois saves por conta isolados.
- Reset separado por save.
- Batalha server-authoritative com replay.
- Base com estado, coleta, compra de Energia, upgrade, fila cheia/fila dupla.
- Social com dois testadores, guilda e chat.
- Competicao com matchmaking/ranking local e Lab fora do ranking.
- Loja com redeems diarios, Diamante, premium e fila dupla.
- Progression Lab apply server-backed.
- Telemetria client nao autoritativa.
- Presets das tres plataformas presentes.

## Lacunas Intencionais Ainda Pendentes

- Supabase remoto real nao configurado nesta etapa local-first.
- Email/senha real nao foi executado; guest/local segue como fallback de desenvolvimento.
- APK, PC build e Web build nao foram exportados/publicados; apenas presets foram validados.
- Manifest remoto de updates nao foi publicado.
- Smoke remoto `internal_alpha_remote_smoke.ts` foi apenas type-checked; execucao real depende de `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY` remotos.
- Smoke visual headless nao captura screenshots reais; antes de compartilhar com outro testador, rodar uma passada nao-headless/manual para legibilidade.
- Balanceamento e UX final ainda precisam playtest humano no editor/app.

## Conclusao

`T03-P11` esta verde como QA local automatizado. O projeto esta pronto para uma passada manual no Godot com foco em UX/legibilidade antes de decidir se vale avancar para remoto/builds ou fazer mais ajustes locais.
