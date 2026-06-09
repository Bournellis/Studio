# DraxosMobile Done: Bosque Diegetic Launcher Foundation v1

## Metadata

- data: `2026-06-09`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `client-shell + mode-scaffolds`
- mode_scope: `openworld + multi-mode shell`
- branch: `codex/draxos-mobile/bosque-diegetic-launcher-foundation-v1`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-diegetic-launcher-foundation-v1`
- status: `DONE_LOCAL_VALIDATED`

## Resultado

Criada etapa local validada para transformar o Bosque em launcher diegetico estreito. O jogador interage com cinco construcoes procedurais no Bosque para abrir menus player-facing existentes por action router do shell:

- `arena_pve_gate` -> `open_arena`
- `refugio_workbench` -> `show_base`
- `shop_stall` -> `show_shop`
- `social_totem` -> `show_social`
- `profile_shrine` -> `show_account`

O pacote remoto atual permanece `Bosque Bootstrap Authority v1` com status `BOSQUE_BOOTSTRAP_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`. Esta entrega nao publicou, nao alterou backend/schema, nao mexeu em portal/manifest e nao abriu tuning/economia/recompensa/conteudo.

## Entregue

- Corrigido drift do smoke de coleta: mover dentro do raio mantem coleta; cancelamento ocorre por distancia.
- Adicionado catalogo local versionado `data/definitions/openworld/forest_launcher_v1.json`.
- Adicionado loader/validador client-side para o catalogo de launcher.
- Adicionado `show_account` ao contrato de actions e router do shell.
- Refugio passou a abrir Perfil pelo action router em vez de rota direta.
- Bosque instancia cinco landmarks procedurais nao bloqueantes; Tower/Card/dev tools ficam fora.
- HUD mostra um prompt contextual unico para o landmark mais proximo.
- Proximidade e tap/click resolvem o mesmo `action_id`.
- `OpenworldForestScreen` emite `shell_action_requested(action_id, entry_id)`.
- `ModeShellLauncher` conecta o signal ao `_trigger_action`, guarda snapshot local/preview em memoria e preserva retorno ao `mode_shell`.
- Saida para menu tenta flush/checkpoint de pendencias; em falha, preserva estado e mostra mensagem honesta antes de abrir o menu.
- Corrigido parse/load do `boot_runtime_flow_facade.gd` para `show_account` usar chamada dinamica de `_show_screen`.
- Docs vivos atualizados para separar pacote remoto atual da etapa local implementada.

## Commits

- `12cbc30` - `test: align openworld smoke collection cancellation`
- `e38f49d` - `feat: add bosque launcher catalog contracts`
- `14c3392` - `feat: wire bosque diegetic launcher navigation`
- `8d6dbba` - `test: cover bosque launcher foundation`
- `5365733` - `fix: keep account route facade loadable`
- fechamento documental/kanban neste commit final

## Validacao Executada

- `git diff --check` - PASS
- GUT focado com `-gconfig=`:
  `test_openworld_mode_dev.gd` + `test_foundation_shell_contracts.gd` - PASS, `62/62`
- `Godot --headless --path . -s res://tools/smoke_openworld_forest.gd` - PASS
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick` - PASS, incluindo GUT client `262/262` e smokes client
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ModePlatform` - PASS, incluindo contratos server/modes `49/49` e smokes de modo

## Docs Atualizados

- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-decision-pack.md`
- `Projetos/draxos-mobile/docs/design-pending.md`

## Escopo Preservado

- Sem backend, schema, migrations, RPCs ou Supabase.
- Sem tuning, recompensa, economia, PVP, armas, spells, conteudo novo ou visual final.
- Sem publicacao, deploy, portal, manifest ou release root remoto.
- Sem Tower/Card/dev tools no catalogo V1.

## Handoff

Proxima decisao viva: `DMOB-D077`. Fabio deve escolher explicitamente entre publicar um novo Internal Alpha, rodar playtest humano/export local, ajustar pontualmente o launcher ou abrir outro pacote de produto. Historicos em Done/Handoffs/reports antigos foram preservados por escopo.
