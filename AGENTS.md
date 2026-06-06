# AGENTS.md

This file governs agent behavior for the `D:\Estudio` workspace.

## Workspace Roles

- `08_Coordenacao_Agentes/Prioridades_Estudio.md` is the portfolio source of truth for focus, priority, project status, and allowed work.
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html` is the human-facing local dashboard for the same portfolio state.
- `canon/` is the shared source of truth for established product identity, lore context, gameplay contracts, progression, shared architecture, mode standard, and platform strategy.
- `Projetos/draxos-roguelike-cardgame/` is the current P0 implementation workspace for the menu-first Draxos roguelike cardgame.
- `Projetos/draxos-mobile/` is the P2 implementation workspace for DraxosMobile - PVE Arena-first async autobattler, base manager, later PVP, social; Godot 4.6.2 + Supabase; Android + PC + PC browser. Current operational stage: `BOSQUE_FOGUEIRA_POTION_CRAFTING_V1_PUBLISHED_INTERNAL_ALPHA`; the latest remote Internal Alpha package is Bosque Fogueira Potion Crafting v1 (`internal-alpha/v0-bosque-fogueira-potion-crafting-v1-20260606-cad6d2c`, preview evidence `https://08d00f24.draxos-mobile-internal-alpha.pages.dev`, official URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, APK/manifest `0.0.7-alpha.0`/version code `7`), preserving Bosque Durable Bau Mochila v1 as the previous durable Openworld progress package (`internal-alpha/v0-bosque-durable-bau-mochila-v1-20260606-6e7ca6b`, preview evidence `https://39198a35.draxos-mobile-internal-alpha.pages.dev`), Arena PVE Menu Flow Simplification v1 as the previous Arena menu package (`internal-alpha/v0-arena-pve-menu-flow-simplification-v1-20260606-5d03a68`, preview evidence `https://fdf44707.draxos-mobile-internal-alpha.pages.dev`), Bosque Offline-First Checkpoint v1 as the previous Openworld runtime policy package (`internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22`, preview evidence `https://fa84e109.draxos-mobile-internal-alpha.pages.dev`), Bosque Sync Responsiveness v1 as the previous Bosque sync package (`internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`, preview evidence `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`), Arena/Bosque Visible V2 as the previous visible package (`internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5`, preview evidence `https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev`), Arena/Bosque Regression Hotfix as the previous visibility hotfix package (`internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f`, preview evidence `https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev`), Arena PVE Season 1 Loop v1 as the previous Season 1 package (`internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32`, preview evidence `https://d7333659.draxos-mobile-internal-alpha.pages.dev`), Arena Duel Flow Hotfix as the previous duel-flow hotfix package (`internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174`, preview evidence `https://0536635b.draxos-mobile-internal-alpha.pages.dev`), Arena PVE First Real Run + Update Recovery as the previous Arena package (`internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a`, preview evidence `https://2c020d09.draxos-mobile-internal-alpha.pages.dev`), Bosque v3 UX/Feel as the previous content/polish package (`internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45`, preview evidence `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`), Technical Hardening as the previous technical package (`internal-alpha/v0-technical-hardening-20260605-8e54a1f`, preview evidence `https://2fe9393e.draxos-mobile-internal-alpha.pages.dev`) and Openworld Main Menu Sync as the previous Openworld content package (`internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`, preview evidence `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`), Bosque Mecanico Basico v2, First Access Runtime Fix, Foundation Hardening V2 as the previous hardening/live-doc enforcement baseline, Hardening Platform V1, Track 23 Arena PVE update recovery, Track 21 Arena Loop Unlock/Friction as Autobattler context, Track 20 Season 1 Arena Calibration, Remote Lab Runner, Track 13 validation/release safety and Track 14 `TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE`.
- `Projetos/_conceitos/mobile-universe/` is a design archive; it was promoted to `draxos-mobile/` on 2026-05-18 and is now read-only design reference.
- `Projetos/rpg-isometrico/` is paused indefinitely and preserved for historical/contextual consultation.
- `Projetos/rpg-turnos/` is paused indefinitely and preserved for historical/contextual consultation.
- `migration/` is a historical archive for cutover, relocation, and legacy comparison context.
- `08_Coordenacao_Agentes/` is the coordination hub: Kanban, Handoffs, Decisoes, Prioridades, Painel Visual, and Estado_Atual.
- `Projetos/README.md` is the lightweight project registry for active, conceptual, and paused projects.

## Multi-Agent Worktree And Git Rule

`D:\Estudio` is the main coordination/read workspace. By default, agents must not use it as an implementation worktree. Each agent working on implementation, documentation, contracts, backend, client, validation, release or portfolio changes must create or use a dedicated Git worktree outside the main root, unless the user explicitly asks for direct work in `D:\Estudio`.

Default worktree path:

```text
D:\Estudio-worktrees\<projeto>--<agente>--<slug>
```

Default branch names:

- Codex: `codex/<projeto>/<slug>`
- Other agents: `<agente>/<projeto>/<slug>`

Rules:

- Never edit another agent's worktree unless the user explicitly asks for intervention there.
- Before touching shared files (`AGENTS.md`, `canon/`, `08_Coordenacao_Agentes/`, `Projetos/README.md`) run `git status --short`, `git worktree list`, and read the current coordination docs.
- At the start of work, register branch, worktree, objective, intended files, base docs read, validation plan and next handoff point in `08_Coordenacao_Agentes/Kanban/Doing/` or `08_Coordenacao_Agentes/Handoffs/`.
- Commit by logical stage by default: documentation, contract, backend, client, validation, publication, and coordination updates should not be mixed into one mega commit.
- Keep commits coherent and explain the delivered state. If a stage cannot be committed yet, record the reason in the Doing/Handoff note.
- Keep the worktree clean at handoff whenever possible. If not clean, list every remaining changed file and why it remains changed.

## Portfolio Gate

Antes de abrir documentacao profunda de qualquer projeto, consulte:

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `Projetos/README.md`
3. `08_Coordenacao_Agentes/Estado_Atual.md`

Use esses documentos para identificar se o pedido e sobre implementacao ativa, conceito, projeto pausado, canon compartilhado ou coordenacao do estudio.

- Se o usuario nao citar projeto e pedir implementacao, validacao, playtest ou trabalho tecnico, assuma `Projetos/draxos-roguelike-cardgame/`.
- Projetos com `P0_IMPLEMENTACAO` podem receber codigo, validacao, playtest e documentacao local por padrao.
- Projetos com `P2_IMPLEMENTACAO` podem receber codigo, design, documentacao local e configuracao de infraestrutura por padrao.
- Projetos com `P1_CONCEITO` permitem somente conceito, pitch, design, referencias e documentacao conceitual.
- Projetos com `ARQUIVO_DESIGN` permitem apenas leitura e referencia de design â€” nao criar codigo, cenas ou assets.
- Projetos com `PAUSADO_INDEFINIDO` nao devem receber implementacao, expansao de escopo, novas gates ou selecao de track sem pedido explicito do usuario.
- Ao concluir qualquer tarefa que mude status observavel, atualize `Prioridades_Estudio.md`, `Estado_Atual.md` e o registro relevante em `Projetos/README.md`.

## Project Selection Gate

Depois do Portfolio Gate, escolha o projeto alvo usando o pedido do usuario, `Prioridades_Estudio.md`, `Projetos/README.md` e `Estado_Atual.md`.

- Se o usuario citar `draxos-roguelike-cardgame`, `Draxos roguelike`, `roguelike cardgame`, `ship hub`, `run map`, `mapa de run`, `10 mapas`, `almas`, `classe no hub`, `rota completa`, `sacrificio`, `Cinzas` ou `batalhas por lanes`, use `Projetos/draxos-roguelike-cardgame/`.
- Se o usuario citar `draxos-mobile`, `DraxosMobile`, `Draxos mobile`, `Bosque Fogueira Potion Crafting v1`, `BOSQUE_FOGUEIRA_POTION_CRAFTING_V1_PUBLISHED_INTERNAL_ALPHA`, `Bosque Durable Bau Mochila v1`, `BOSQUE_DURABLE_BAU_MOCHILA_V1_PUBLISHED_INTERNAL_ALPHA`, `Arena PVE Menu Flow Simplification v1`, `ARENA_PVE_MENU_FLOW_SIMPLIFICATION_V1_PUBLISHED_INTERNAL_ALPHA`, `Bosque`, `Bosque Offline-First Checkpoint v1`, `BOSQUE_OFFLINE_FIRST_CHECKPOINT_V1_PUBLISHED_INTERNAL_ALPHA`, `Bosque Sync Responsiveness v1`, `BOSQUE_SYNC_RESPONSIVENESS_V1_PUBLISHED_INTERNAL_ALPHA`, `Arena/Bosque Visible V2`, `ARENA_BOSQUE_VISIBLE_V2_PUBLISHED_INTERNAL_ALPHA`, `Arena/Bosque Regression Hotfix`, `ARENA_BOSQUE_REGRESSION_HOTFIX_PUBLISHED_INTERNAL_ALPHA`, `Bosque v3 UX/Feel`, `BOSQUE_V3_UX_FEEL_PUBLISHED_INTERNAL_ALPHA`, `Openworld`, `BOSQUE_MECANICO_BASICO_V2_PUBLISHED_INTERNAL_ALPHA`, `autobattler`, `base manager`, `Arena PVE`, `ARENA_PVE_SEASON1_LOOP_V1_PUBLISHED_INTERNAL_ALPHA`, `Arena PVE Season 1 Loop v1`, `ARENA_PVE_FIRST_REAL_RUN_PUBLISHED_INTERNAL_ALPHA`, `Arena PVE First Real Run`, `Track 23`, `FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA`, `Foundation Hardening V2`, `HARDENING_PLATFORM_V1_PUBLISHED_INTERNAL_ALPHA`, `Hardening Platform V1`, `REMOTE_LAB_RUNNER_PUBLISHED_INTERNAL_ALPHA`, `LAB_WEB_EXPORT_GUARD_PUBLISHED_INTERNAL_ALPHA`, `ARENA_CONSISTENCY_PASS_PUBLISHED_INTERNAL_ALPHA`, `ARENA_CONSISTENCY_PASS_IMPLEMENTED_LOCAL`, `PVE_ARENA_INITIAL_PUBLISHED_INTERNAL_ALPHA`, `PVE_ARENA_INITIAL_DIRECTION_APPROVED`, `PVP assincrono`, `Supabase`, `Foundation Final Polish`, `Foundation Closeout`, `FOUNDATION_FINAL_POLISH_DELIVERED`, `Foundation Audit`, `FOUNDATION_AUDIT_ACTIVE`, `Foundation Loop UX Pass`, `loop pos-login`, `Track 00`, `Track 04`, `Track 11`, `Track 13`, `Track 14`, `Track 15`, `Track 16`, `Track 17`, `Track 18`, `Track 19`, `Track 21`, `Agent Operating Manual`, `documentation-index`, `primeiro slice mobile`, `guilda`, `conta guest`, `matchmaking por poder`, `Progression Lab humano`, `Battle Lab`, `account_profiles`, `game_saves`, `Hub modularization`, `release artifacts`, `release safety`, `Cloudflare Access` ou `simulacao no servidor`, use `Projetos/draxos-mobile/`.
- Se o usuario citar `mobile-universe` ou `_conceitos/mobile-universe`, use `Projetos/_conceitos/mobile-universe/` apenas para leitura e referencia de design â€” nao criar codigo, cenas ou assets a partir dali.
- Se o usuario citar `rpg-turnos`, `RPG Turnos`, exploracao 2D, NPC, mundo, `class_select`, `Track 02 - Draxos Lore And Progression Alignment` ou `P10 - Necromante`, use `Projetos/rpg-turnos/` apenas para consulta historica, salvo pedido explicito de retomar trabalho.
- Se o usuario citar `rpg-isometrico`, campanha isometrica, Arena, Survival, Boss, loadout de acao ou gates Fxx, use `Projetos/rpg-isometrico/` apenas para consulta historica, salvo pedido explicito de retomar trabalho.
- `Draxos` sozinho e contexto de lore compartilhada nao bastam para escolher `rpg-turnos` ou `draxos-mobile`; confirme pelo projeto citado, pela prioridade atual ou pelos termos operacionais acima.
- Depois de escolher o projeto alvo, leia apenas o `AGENTS.md`, `implementation/current-status.md` e etapa local desse projeto, salvo tarefa transversal. Para DraxosMobile, comece pelo `AGENTS.md` local e siga `docs/agent-operating-manual.md`, `docs/documentation-index.md`, `docs/pve-arena-initial-direction.md`, `docs/foundation-app-v0-audit.md` e `implementation/current-status.md`.

## Read Order - Fast Lane

Para tarefas localizadas num unico projeto ou area, comece com:

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `canon/canon-brief.md`
3. `Projetos/README.md`
4. `08_Coordenacao_Agentes/Estado_Atual.md`
5. A tarefa ativa em `08_Coordenacao_Agentes/Kanban/Doing/`, se existir
6. O `AGENTS.md` local do projeto Godot, se entrar no codigo

Escale para a ordem completa imediatamente se:

- a tarefa afetar mais de um projeto ou a direcao do canon;
- houver decisao de produto, arquitetura ou plataforma;
- o escopo se expandir alem dos arquivos tocados inicialmente.

## Read Order - Full

Antes de trabalho substancial que afete multiplos projetos ou o canon:

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `canon/product/product-vision.md`
3. `canon/design/game-design-document.md`
4. `canon/design/progression-design.md`
5. `canon/architecture/shared-architecture.md`
6. `canon/architecture/game-mode-standard.md`
7. `canon/roadmap/evolution-roadmap.md`
8. `canon/roadmap/release-horizons.md`
9. `canon/platform/steam-platform.md`
10. O `AGENTS.md` local do projeto, quando houver
11. O `implementation/current-status.md` local do projeto, quando houver
12. Este arquivo

## Canon Rule

Se o canon compartilhado conflitar com qualquer nota historica de implementacao, o canon prevalece.

Nao aplique silenciosamente a mecanica de um projeto em outro. `rpg-turnos` pode compartilhar lore com `rpg-isometrico`, mas os contratos de modo e loadout do RPG Isometrico nao sao canon do RPG Turnos a menos que um documento local do RPG Turnos os adote explicitamente.

Nao trate `draxos-roguelike-cardgame` como variante de `rpg-turnos`. O projeto foi bootstrapped com reuso estreito, mas possui contratos locais proprios. Qualquer regra de combate, deck, mana, compra, recompensa, hub, mapa ou pacing de `rpg-turnos` so vale em Draxos se um documento local de `draxos-roguelike-cardgame` adotar explicitamente.

DraxosMobile tem visao longa local em `Projetos/draxos-mobile/docs/product-vision.md`. Ate promocao explicita ao canon compartilhado, use esse documento para pilares, anti-pilares, limites de plataforma, monetizacao, live ops e futuro nao prometido do mobile. A etapa atual vive em `Projetos/draxos-mobile/implementation/current-status.md`; a direcao viva do early game vive em `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`; a auditoria original vive em `Projetos/draxos-mobile/docs/foundation-app-v0-audit.md` como referencia fechada. A operacao de agentes vive em `Projetos/draxos-mobile/docs/agent-operating-manual.md`, e o mapa de autoridade documental vive em `Projetos/draxos-mobile/docs/documentation-index.md`.

Nao trate RPGMobile ou BattleMobile como projetos Godot oficiais ate que recebam `AGENTS.md`, `implementation/current-status.md`, entrada oficial em `Projetos/README.md` como projeto implementavel e entrada resumida em `Estado_Atual.md`.

## Godot Rule

Implementacoes Godot vivem sob `Projetos/`.

Projetos Godot ativos:

- `Projetos/draxos-roguelike-cardgame/` â€” P0, Steam, roguelike cardgame
- `Projetos/draxos-mobile/` - P2, mobile + PC + browser, Godot 4.6.2 + Supabase (`BOSQUE_FOGUEIRA_POTION_CRAFTING_V1_PUBLISHED_INTERNAL_ALPHA`; proximo passo e playtest humano do pacote Bosque Fogueira Potion Crafting v1 publicado, preservando regressao da Arena PVE Menu Flow Simplification v1, progresso duravel do Bosque Durable Bau Mochila v1 e politica runtime Openworld do Bosque Offline-First Checkpoint v1)

Projetos Godot pausados:

- `Projetos/rpg-isometrico/`
- `Projetos/rpg-turnos/`

Ao entrar num projeto Godot ativo:

1. Consulte `Prioridades_Estudio.md` primeiro
2. Consulte o canon compartilhado
3. Consulte `Projetos/README.md` para confirmar o registro do projeto
4. Consulte `implementation/current-status.md` do projeto
5. Consulte o `AGENTS.md` local do projeto Godot e a track ativa em `implementation/tracks/`
6. Consulte docs de validacao historica apenas quando responderem uma pergunta especifica

Um projeto futuro em `Projetos/` so deve ser tratado como oficial quando tiver `AGENTS.md`, `implementation/current-status.md`, entrada em `Projetos/README.md`, e entrada resumida em `08_Coordenacao_Agentes/Estado_Atual.md`.

Use caminhos relativos ao referenciar o canon compartilhado de dentro de um projeto Godot.
Versao esperada do Godot: ver `.godot-version` na raiz deste workspace.

## Historical Context Rule

Se contexto historico for necessario, consulte nesta ordem:

1. `migration/`
2. `Projetos/rpg-isometrico/implementation/phase-g1/` a `phase-g4/`
3. Apenas entao qualquer repositorio legado externo, se a tarefa for explicitamente historica

## Manutencao do Estado_Atual.md

`08_Coordenacao_Agentes/Estado_Atual.md` e o snapshot vivo dos projetos. Mantenha-o atual:

- **Quando atualizar**: ao concluir qualquer tarefa que mude o status observavel de um projeto, prioridade de portfolio, track ativa, baseline ou proximo passo.
- **O que atualizar**: somente as linhas que mudaram - status, fase, prioridade, baseline curta, proximo passo e restricao operacional.
- **O que nao colocar**: historico de gates, detalhes tecnicos de implementacao, listas longas de arquivos. Isso vai para Done do Kanban ou para `implementation/current-status.md` do projeto.
- **Regra do tamanho**: mantenha o arquivo compacto e orientado a decisao.

## Coordination Structure

- Prioridades e foco do estudio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- Estado atual dos projetos: `08_Coordenacao_Agentes/Estado_Atual.md`
- Tarefas ativas: `08_Coordenacao_Agentes/Kanban/Doing/`
- Backlog: `08_Coordenacao_Agentes/Kanban/Backlog/`
- Handoffs entre agentes: `08_Coordenacao_Agentes/Handoffs/`
- Decisoes de produto e arquitetura: `08_Coordenacao_Agentes/Decisoes/`
- Templates oficiais: `08_Coordenacao_Agentes/Templates/`

**Nomenclatura de arquivos Kanban**: `YYYY-MM-DD_agente_slug.md`
Exemplos: `2026-05-04_codex_rpg-turnos_duelo-mode.md`, `2026-05-14_codex_estudio_portfolio.md`
