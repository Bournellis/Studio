# Track 03 - Internal Alpha v0 - Current Status

- Last Updated: `2026-05-27`
- Status: `T03-P17A_DOWNLOADS_MANIFEST_GREEN - CLOUDFLARE_REDEPLOY_BLOCKED`
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
- Ordem local-first aprovada em 2026-05-26 e ja cumprida para release prep: o jogo foi implementado/validado no Godot/Supabase local primeiro; Supabase remoto foi inicializado em `T03-P13`; auth email/senha foi fechado em `T03-P14`; manifest de updates foi fechado em `T03-P15`; exports Android/PC/Web foram fechados em `T03-P16`; backend/downloads, Portal/Web e QA remoto automatizado foram fechados em `T03-P17`; falta signoff manual antes do handoff.
- `T03-P03A` completo: `SessionStore` possui save ativo `normal`/`progression_lab`, persiste no cache, limpa snapshots ao alternar contexto, marca snapshots local-only do Progression Lab como Lab, `SupabaseClient` prepara header `x-draxos-save-type` e o Hub mostra/troca save ativo com bloqueio claro quando o Lab esta em cache local-only.
- `T03-P03B` completo: schema local ganhou `players.save_type`, unicidade por `auth_user_id + save_type`, RPCs `create_guest_account`/`request_mvp_battle` recebem save, Edge Functions resolvem `x-draxos-save-type` para `account`, `battle`, `base`, `social`, `competition`, `monetization` e `telemetry`, o Hub libera acoes server-backed no Lab, e o save `progression_lab` fica isolado do normal e fora do ranking com motivo explicito.
- `T03-P03C` completo: `POST /account/saves/reset` e RPC `reset_player_save` reconstroem apenas o save ativo, preservam o outro save da mesma sessao Auth, limpam snapshots client-side do save resetado, mantem idempotencia por `request_id` e expoem botao perigoso "Resetar save ativo" no Hub.
- `T03-P04` completo: `POST /progression-lab/apply` e RPC `apply_progression_lab_save` aplicam healthy saves versionados apenas no save `progression_lab`, preservam o save `normal`, limpam snapshots/estado antigo do Lab, mantem idempotencia por `request_id`, atualizam o Progression Lab Dev com "Aplicar no Save Lab" e validam o fluxo em smoke server.
- `T03-P05` completo: Base Manager virou fluxo jogavel no Hub, com mapa de predios clicaveis, painel detalhado por estrutura, tooltips, upgrade por predio, compra alpha de Energia, custo/tempo/producao/status calculados pelo servidor e smoke cobrindo upgrade/fila.
- `T03-P06` completo: Social virou fluxo basico jogavel no Hub, com amigos por username, criar/entrar em guilda, lista de membros/estruturas, chat de guilda por polling, rate limit, erros amigaveis, tooltips, painéis de estado e identidade social de conta com marcador `lab`.
- `T03-P07` completo: Competicao virou leaderboard alpha jogavel; `battle/request` `FIRST_SLICE_SIM` pontua o save `normal` com modelo `alpha_v0_power_adjusted`, `progression_lab` permanece fora do ranking, `competition/ranking/current` retorna top 10 + posicao do jogador, bots ficam fora da leaderboard e o Hub mostra matchmaking, ultima batalha competitiva e ranking com tooltips.
- `T03-P08` completo: Loja virou proof-of-concept jogavel; `monetization/state` retorna `shop_summary` e produtos enriquecidos, redeems diarios entregam apenas Diamante por save com reset Sao Paulo, Battle Pass/fila dupla/pacotes usam Diamante, fila dupla altera a Base para 2 slots e o Hub mostra resumo, catalogo, recompensas, bloqueio visual e tooltips.
- `T03-P09` completo: Batalha recebeu polish visual pequeno sem assets externos; o palco 2D mostra readout compacto de replay/tempo/HP/status/cooldowns/aliados, labels incluem HP percentual e tooltips de evento humanizam fonte/alvo com leitura rapida.
- `T03-P11` local QA completo: ambiente local resetado, checks/lints Deno verdes, smokes Supabase locais verdes, Godot validate/GUT verde, smokes de app/labs/export presets verdes e relatorio `docs/internal-alpha-v0-qa-report.md` criado.
- `T03-P12` completo: plano de release `T03-P12` a `T03-P18` registrado, base do portal estatico criada em `portal/internal-alpha/`, manifest exemplo criado, tutorial detalhado de Supabase remoto documentado e ponto de partida remoto anotado (`armxgipvnbbshzqawklw`, `https://armxgipvnbbshzqawklw.supabase.co`).
- `T03-P13` completo: Supabase CLI logado/linkado ao projeto remoto `armxgipvnbbshzqawklw`, migrations aplicadas com `supabase db push`, Edge Functions `healthcheck`, `account`, `battle`, `base`, `social`, `competition`, `monetization`, `telemetry` e `progression-lab` publicadas, lista local/remota de migrations alinhada e smoke remoto minimo verde.
- `T03-P14` completo: cliente Godot recebeu fluxo de conta alpha com email/senha, username e convite; guest ficou como ferramenta dev; `SessionStore` persiste metodo/email/username/request id alpha; `SupabaseClient` suporta signup/login password e `/account/bootstrap`; schema/Edge Function adicionaram `create_alpha_account` para contas registradas e saves `normal`/`progression_lab`; Auth remoto foi alinhado com confirmacao de email desligada; smokes local/remoto de email/senha passaram.
- `T03-P15` completo: `ProjectInfo` define versao/canal/schema do manifest, `BackendConfig`/`SupabaseClient` resolvem URL de manifest, Hub checa update no boot e bloqueia acoes online quando `minimum_supported_version_code` exige, `GET /release/manifest` foi implementado/local/remoto sem JWT obrigatorio e smokes local/remoto passaram.
- `T03-P16` completo: presets Android/PC/Web foram corrigidos para export real, Android recebeu ETC2/ASTC, icone placeholder e permissoes de rede, `tools/export_internal_alpha.ps1` injeta config publica do Supabase apenas durante o build, gera APK/PC ZIP/Web e registra hashes em `docs/internal-alpha-v0-export-report.md`.
- `T03-P17` publicacao tecnica completa: migration `202605270002_internal_alpha_storage.sql` criou bucket publico unlisted `draxos-internal-alpha`, `tools/publish_internal_alpha.ps1` publicou APK/PC ZIP, `tools/build_cloudflare_pages_package.ps1` gerou pacote hibrido Cloudflare Pages, Portal/Web foram publicados em `https://draxos-mobile-internal-alpha.pages.dev`, `release/manifest` recebeu links finais e QA remoto automatizado passou.
- Correcao pos-publicacao: Supabase Storage retorna HTML como `text/plain` e Edge Functions tambem nao servem `text/html`; APK/PC ZIP e assets grandes continuam por Storage, enquanto Portal/Web HTML ficam no Cloudflare Pages.
- Correcao Cloudflare Pages: o pacote hibrido publica Portal em `/`, Web em `/web`, mantem redirects de `/portal/index.html` e `/web/index.html`, e evita o limite por arquivo do Pages.
- Hotfix gameplay email/senha: `battle`, `base`, `social`, `competition` e `monetization` removem o guard legado `AUTH_NOT_ANONYMOUS` do MVP e aceitam JWT registrado; `/account/guest` continua restrito a guest dev.
- `T03-P17A` aprovado: passada curta de usabilidade Android no Boot. O Hub/abas detectam Android ou `draxos_mobile/ui/force_compact_layout`, reduzem margens/fontes de chrome, mantem nav com alvo de toque maior, agrupam botoes de acao em grades, deixam o mapa da Base em 6 colunas no Android paisagem larga e trocam a linguagem visivel de "dev" do fluxo normal por "teste rapido". Foi adicionado GUT de regressao para o layout compacto, gerado rebuild local Android/PC/Web e Fabio aprovou a etapa como boa o suficiente para seguir.
- Republicacao `T03-P17A` parcial: APK/PC ZIP foram republicados no Supabase Storage, `release/manifest` foi atualizado via secret override e validado remoto. O pacote Cloudflare Pages atualizado foi gerado, mas o deploy automatico via Wrangler ficou bloqueado por falta de `CLOUDFLARE_API_TOKEN`; Web HTML remoto ainda carrega metadata antiga de `index.pck`, entao Web precisa de upload manual do pacote ou token antes do signoff Web final.

## Ainda Nao Implementado

- Republicar Cloudflare Pages com `build/internal-alpha/draxos-mobile-cloudflare-pages.zip` ou configurar `CLOUDFLARE_API_TOKEN` para deploy CLI.
- Signoff manual de `T03-P17`: Fabio + 1 tester validam duas plataformas e registram bugs.
- `T03-P18`: handoff final da Internal Alpha v0.

## Decisoes Ja Travadas

- Supabase Free remoto primeiro.
- Email + senha.
- Email confirmation desligado no alpha interno.
- Dois saves por conta: `normal` e `progression_lab`.
- Reset separado por save.
- Progression Lab exportado apenas como ferramenta interna/gated.
- Loja com redeem alpha fixo para testar premium.
- Web link pode ser publico/unlisted, mas jogo exige login e acesso alpha.
- Android sera APK direto por link; PC Windows sera zip direto por link; Web sera unlisted via portal.
- Android usa keystore dedicada de Internal Alpha.

## Proximo Passo

Publicar o pacote Cloudflare Pages atualizado (`build/internal-alpha/draxos-mobile-cloudflare-pages.zip`) por upload manual ou configurar `CLOUDFLARE_API_TOKEN` e rodar `wrangler pages deploy`. Depois validar `/web`, concluir o signoff manual final com Fabio + 1 tester e seguir `T03-P18 - Handoff Da Internal Alpha v0`.

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
- `T03-P11 local QA`: passou em 2026-05-26 apos reset de cache Godot, scratch Progression Lab e Supabase local; ver `docs/internal-alpha-v0-qa-report.md`.
- `npx -y deno run --allow-net --allow-env server/tests/base_manager_smoke.ts`: passou em 2026-05-26, validando payload jogavel da Base, compra alpha de Energia, upgrade por predio, fila cheia, compra da fila dupla e limite em 2 upgrades ativos.
- `npx -y deno run --allow-net --allow-env server/tests/monetization_rewards_smoke.ts`: passou em 2026-05-26, validando `shop_summary`, quatro redeems diarios, bloqueio de duplicacao diaria, compra premium por Diamante, fila dupla em `convenience_owned`, reward premium e RLS.
- `tools/smoke_session_shell.gd`: passou em 2026-05-26 com Auth anonimo, conta guest e `account/state`.
- `tools/smoke_alpha_loop.gd`: passou em 2026-05-26 com Auth anonimo, battle/base/social/competition/shop, redeem de Loja e telemetria final.
- `tools/smoke_dev_lab_ui.gd`: passou em 2026-05-26 no renderer headless.
- `tools/smoke_dev_labs.gd`: passou em 2026-05-26.
- `tools/smoke_exports.gd`: passou em 2026-05-26 para Android Alpha, PC Windows Alpha e PC Browser Alpha.
- `T03-P12 docs/portal`: `git diff --check` passou em 2026-05-26.
- `npx -y supabase db push`: passou em 2026-05-27 contra `armxgipvnbbshzqawklw`, aplicando as 10 migrations da alpha.
- `npx -y supabase functions deploy healthcheck account battle base social competition monetization telemetry progression-lab`: passou em 2026-05-27.
- `npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts`: passou em 2026-05-27 contra `https://armxgipvnbbshzqawklw.supabase.co` com `healthcheck: true` em `T03-P13`.
- `npx -y supabase migration list`: passou em 2026-05-27 com as migrations locais e remotas alinhadas.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd`: passou em 2026-05-27 com GUT `50/50` e `335` asserts.
- `npx -y deno task check` e `npx -y deno task lint` em `supabase/functions`: passaram em 2026-05-27.
- `npx -y supabase db reset`: passou em 2026-05-27 aplicando `202605270001_alpha_email_account.sql`.
- `npx -y deno run --allow-net --allow-env server/tests/email_auth_alpha_smoke.ts`: passou em 2026-05-27, validando signup/login email, `/account/bootstrap`, save normal e save `progression_lab`.
- `npx -y deno run --allow-net --allow-env server/tests/two_save_context_smoke.ts`: passou em 2026-05-27 apos a migration nova.
- `npx -y supabase db push`: passou em 2026-05-27 aplicando `202605270001_alpha_email_account.sql` no remoto.
- `npx -y supabase functions deploy account`: passou em 2026-05-27.
- `npx -y supabase config push --yes`: passou em 2026-05-27, alinhando Auth remoto com `enable_confirmations = false`.
- `DRAXOS_REMOTE_EMAIL_AUTH_SMOKE=1 npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts`: passou em 2026-05-27 contra `https://armxgipvnbbshzqawklw.supabase.co`.
- `DRAXOS_REMOTE_ANON_AUTH_SMOKE=1 npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts`: passou em 2026-05-27 contra `https://armxgipvnbbshzqawklw.supabase.co`.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd`: passou em 2026-05-27 com GUT `53/53` e `359` asserts.
- `npx -y deno task check` e `npx -y deno task lint` em `supabase/functions`: passaram em 2026-05-27 incluindo `release/index.ts`.
- `npx -y deno task check` e `npx -y deno task lint` em `server/functions`: passaram em 2026-05-27 incluindo `release/index.ts`.
- `npx -y deno check server/tests/release_manifest_smoke.ts server/tests/internal_alpha_remote_smoke.ts`: passou em 2026-05-27.
- `npx -y deno run --allow-net --allow-env server/tests/release_manifest_smoke.ts`: passou em 2026-05-27 contra Supabase local apos reiniciar a Edge Runtime.
- `npx -y supabase functions deploy release --no-verify-jwt`: passou em 2026-05-27 contra `armxgipvnbbshzqawklw`.
- `DRAXOS_REMOTE_RELEASE_SMOKE=1 npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts`: passou em 2026-05-27 contra `https://armxgipvnbbshzqawklw.supabase.co`.
- `npx -y deno run --allow-net --allow-env server/tests/release_manifest_smoke.ts`: passou em 2026-05-27 contra `https://armxgipvnbbshzqawklw.supabase.co`.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_exports.gd`: passou em 2026-05-27 apos ajustes de Android/export.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\export_internal_alpha.ps1 -ProjectDir . -GodotExe "D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe" -AllowAndroidDebugFallback`: passou em 2026-05-27 gerando APK, PC ZIP, Web e hashes locais. Android mode: `debug_fallback`.
- `npx -y supabase db push`: passou em 2026-05-27 aplicando `202605270002_internal_alpha_storage.sql` no remoto.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -SkipUpload`: passou em 2026-05-27 apos upload inicial, validando APK/PC ZIP e manifest remoto; Portal/Web ficaram pendentes de host estatico externo apos confirmacao da limitacao de HTML na Supabase.
- `DRAXOS_REMOTE_RELEASE_SMOKE=1 DRAXOS_REMOTE_EMAIL_AUTH_SMOKE=1 npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts`: passou em 2026-05-27.
- `npx -y deno run --allow-net --allow-env server/tests/release_manifest_smoke.ts`: passou em 2026-05-27 contra o manifest publicado.
- `npx -y deno run --allow-net --allow-env server/tests/first_slice_battle_smoke.ts`: passou em 2026-05-27 contra remoto.
- `npx -y deno run --allow-net --allow-env server/tests/base_manager_smoke.ts`: passou em 2026-05-27 contra remoto.
- `npx -y deno run --allow-net --allow-env server/tests/monetization_rewards_smoke.ts`: passou em 2026-05-27 contra remoto.
- `npx -y deno run --allow-net --allow-env server/tests/social_competition_smoke.ts`: passou em 2026-05-27 contra remoto.
- `npx -y deno run --allow-net --allow-env server/tests/battle_request_smoke.ts`: passou em 2026-05-27 contra remoto.
- `npx -y deno run --allow-net --allow-env server/tests/client_telemetry_smoke.ts`: passou em 2026-05-27 contra remoto.
- Hotfix 2026-05-27: redeploy remoto de `battle`, `base`, `social`, `competition` e `monetization` passou; `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_EMAIL_AUTH_SMOKE=1` validou email/senha + `battle/request`; `email_auth_alpha_smoke.ts`, `first_slice_battle_smoke.ts`, `base_manager_smoke.ts`, `social_competition_smoke.ts`, `monetization_rewards_smoke.ts`, `battle_request_smoke.ts` e `client_telemetry_smoke.ts` passaram contra remoto.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd`: passou em 2026-05-27 com GUT `54/54` e `367` asserts apos adicionar `test_boot_mobile_ui.gd`.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_exports.gd`: passou em 2026-05-27 apos T03-P17A.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\export_internal_alpha.ps1 -ProjectDir . -GodotExe "D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe" -AllowAndroidDebugFallback`: passou em 2026-05-27 apos T03-P17A, gerando APK `debug_fallback`, PC ZIP e Web locais com hashes atualizados.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -StaticSiteBaseUrl "https://draxos-mobile-internal-alpha.pages.dev" -SkipUpload -UseManifestSecret`: passou em 2026-05-27 apos republicacao `T03-P17A`, atualizando manifest remoto e validando Portal/Web/downloads.
- `npx -y deno run --allow-net --allow-env server/tests/release_manifest_smoke.ts` com env remoto: passou em 2026-05-27.
- `DRAXOS_REMOTE_RELEASE_SMOKE=1 npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts` com env remoto: passou em 2026-05-27.
- HTTP final em 2026-05-27: Portal `200 text/html`, Web `200 text/html`, Manifest `200 application/json`, Android APK `200` com `27811908` bytes, PC ZIP `200` com `36331728` bytes.
- `npx -y wrangler pages deploy .\build\internal-alpha\cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: bloqueado em 2026-05-27 porque Wrangler exige `CLOUDFLARE_API_TOKEN` em ambiente nao interativo.
