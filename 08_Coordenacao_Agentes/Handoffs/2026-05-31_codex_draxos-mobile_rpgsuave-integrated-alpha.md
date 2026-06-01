# DraxosMobile - Rpgsuave Integrated Alpha

- Data: `2026-05-31`
- Agente: `codex`
- Branch: `codex/draxos-mobile/rpgsuave-integrated-alpha`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--rpgsuave-integrated-alpha`
- Base: `codex/draxos-mobile/foundation-final-polish` (`e4f3a11`)
- Objetivo: implementar o pacote completo Rpgsuave Bosque dev-only + plataforma minima de minigames + Reward Bridge v0 para alpha interno.

## Docs lidos

- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Arquivos pretendidos

- Contratos/docs de minigame e status do DraxosMobile.
- Shell/Labs Dev e tela local Rpgsuave Bosque em Godot.
- Cliente online e session store para endpoints de minigames.
- Edge Function `minigames`, migrations e mirrors `server/` + `supabase/`.
- Smokes/testes Godot e Deno para fluxo local, reward bridge e idempotencia.

## Validacao planejada

- `git diff --check`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick`
- Godot validate/GUT/smokes client quando o client estiver alterado.
- Deno checks/testes quando backend estiver alterado.
- `validate_foundation.ps1 -Profile Client` e, se o stack local permitir, `-Profile Full`.

## Proximo handoff

Registrar o estado final com arquivos alterados, comandos executados, bloqueios restantes e proximo passo seguro para revisao/publicacao.

## Estado final

- Implementado o contrato executavel de `rpgsuave`/`forest` com status `dev_only`, entrada `open_minigame_shell:rpgsuave`, progresso local separado e Reward Bridge desligado por default no cliente.
- Implementada entrada em Labs Dev e tela `RpgsuaveForestScreen` com movimento topdown, coleta parada, cancelamento por movimento/distancia, bolso com peso, bau local, crafting local e resultado local.
- Implementada plataforma backend `MINIGAME_PLATFORM_V0` com Edge Function `minigames`, registry/state/session start/session complete, schema minimo, idempotencia e RPCs service-role para Reward Bridge v0.
- Implementada integracao client/backend em `SupabaseClient` e `SessionStore`, com modo `dev_local` e modo futuro `integrated_alpha` preservando pending mutation em falha de rede.
- Atualizados contratos, documentacao, status local e portfolio; na retomada de publicacao o pacote foi publicado remotamente e agora aguarda playtest humano.

## Validacao executada

- `git diff --check` - OK.
- `npx -y deno task check` em `server/functions` - OK.
- `npx -y deno task check` em `supabase/functions` - OK.
- `npx -y deno test --allow-read server\tests\minigame_domain_test.ts server\tests\minigame_platform_schema_test.ts` - OK, 7 testes.
- `npx -y deno fmt --check` nos novos arquivos TS de minigame - OK.
- Godot `tools/smoke_rpgsuave_forest.gd` - OK.
- Godot `tools/smoke_responsive_layout.gd` - OK.
- Godot `tools/smoke_exports.gd` - OK.
- Godot `tools/validate.gd` - OK, 140 testes client.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile Quick` - OK.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile Client` - OK.

## Validacao inicialmente nao executada

- O primeiro handoff nao executou `validate_foundation.ps1 -Profile Full`
  porque o stack local Supabase ainda nao estava iniciado. Na retomada de
  publicacao, o stack local foi usado, a prova live de minigames entrou no Full
  gate e o Full gate passou antes da publicacao remota.

## Riscos e proximos passos

- Antes de habilitar `draxos_mobile/minigames/rpgsuave/integrated_alpha=true`, rodar migrations em stack local, servir a Edge Function `minigames` localmente e executar as provas live equivalentes para o novo fluxo de minigames.
- Fazer playtest humano de 2 minutos no shell para calibrar velocidade, peso, tempos de coleta e legibilidade do bau/crafting.
- Reward Bridge v0 esta pequeno, limitado e auditavel, mas ainda deve passar por smoke live com uma conta normal e uma save `normal`; `progression_lab` foi bloqueado para recompensa real.

## Publicacao retomada

- Pedido do usuario: executar todos os proximos passos ate exigir playtest humano e publicar a nova versao.
- Validacao adicionada: prova live local da Minigame Platform/Reward Bridge contra Supabase local, agora chamada pelo `validate_foundation.ps1 -Profile Full`.
- Estado antes da publicacao: pacote Rpgsuave segue em branch de integracao; publicacao remota deve usar os scripts protegidos de Track 13 com `-ConfirmRemoteMutation`, sem copiar secrets para o repositorio.
- Full gate local passou em `0aa3969`: `tools/validate_foundation.ps1 -ProjectDir . -Profile Full -RequireClean`.
- Migration remota aplicada: `202605310001_minigame_platform_v0.sql`.
- Edge Functions remotas publicadas: `minigames` e `release`.
- Release exportado, empacotado, enviado ao Supabase Storage e publicado no Cloudflare Pages.
- Release root: `internal-alpha/v0-rpgsuave-integrated-alpha-20260531-0aa3969`.
- Portal:
  `https://d1e73b74.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://d1e73b74.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-rpgsuave-integrated-alpha-20260531-0aa3969/downloads/draxos-mobile-alpha.apk`
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-rpgsuave-integrated-alpha-20260531-0aa3969/downloads/draxos-mobile-alpha.zip`

## Validacao final de publicacao

- `tools/validate_foundation.ps1 -ProjectDir . -Profile Full -RequireClean` - OK.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback` - OK; Android
  `debug_fallback`.
- `tools/publish_internal_alpha.ps1 -Mode Plan` - OK.
- `tools/publish_internal_alpha.ps1 -Mode Package` - OK.
- `tools/publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation` - OK.
- `tools/build_cloudflare_pages_package.ps1` - OK.
- `wrangler pages deploy` - OK.
- `tools/publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation` - OK.
- `server/tests/release_manifest_smoke.ts` remoto - OK.
- `server/tests/release_artifacts_remote_smoke.ts` remoto - OK.
- `server/tests/release_artifacts_remote_smoke.ts` remoto com
  `DRAXOS_RELEASE_FULL_HASH=1` - OK.
- `server/tests/internal_alpha_remote_smoke.ts` remoto com
  `DRAXOS_REMOTE_EMAIL_AUTH_SMOKE=1`,
  `DRAXOS_REMOTE_MINIGAME_SMOKE=1` e
  `DRAXOS_REMOTE_RELEASE_SMOKE=1` - OK.

## Proximo bloqueio humano

O trabalho automatico esta completo ate o ponto seguro. O proximo passo exige
playtest humano do pacote publicado:

- confirmar que o jogador entende em ate 2 minutos como andar, parar, coletar,
  encher bolso, voltar ao bau, depositar e craftar;
- sentir se `160 px/s`, raio de coleta, peso e tempos de coleta estao bons;
- validar se a UI separa progresso local do modo e recompensa real da
  Base/Conta;
- observar Android real, Windows e Web antes de qualquer CTA publico no
  Refugio.
