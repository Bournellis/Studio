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
- Atualizados contratos, documentacao, status local e portfolio para refletir que o pacote esta pronto para revisao/playtest local, sem deploy remoto.

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

## Nao executado

- `validate_foundation.ps1 -Profile Full` nao foi executado porque dispara provas live locais de Supabase/Edge/Admin RLS (`transactional_rpc_live_test.ts`, `transactional_edge_rpc_smoke.ts`, `foundation_admin_rls_live_smoke.ts`) contra `127.0.0.1:54321/54322`. O stack local nao foi iniciado neste handoff e nao houve deploy/mutacao remota por regra operacional.

## Riscos e proximos passos

- Antes de habilitar `draxos_mobile/minigames/rpgsuave/integrated_alpha=true`, rodar migrations em stack local, servir a Edge Function `minigames` localmente e executar as provas live equivalentes para o novo fluxo de minigames.
- Fazer playtest humano de 2 minutos no shell para calibrar velocidade, peso, tempos de coleta e legibilidade do bau/crafting.
- Reward Bridge v0 esta pequeno, limitado e auditavel, mas ainda deve passar por smoke live com uma conta normal e uma save `normal`; `progression_lab` foi bloqueado para recompensa real.

## Publicacao retomada

- Pedido do usuario: executar todos os proximos passos ate exigir playtest humano e publicar a nova versao.
- Validacao adicionada: prova live local da Minigame Platform/Reward Bridge contra Supabase local, agora chamada pelo `validate_foundation.ps1 -Profile Full`.
- Estado antes da publicacao: pacote Rpgsuave segue em branch de integracao; publicacao remota deve usar os scripts protegidos de Track 13 com `-ConfirmRemoteMutation`, sem copiar secrets para o repositorio.
- Ponto de handoff esperado: Full gate limpo, release exportado/empacotado/publicado ou bloqueio explicito de credenciais/servico registrado.
