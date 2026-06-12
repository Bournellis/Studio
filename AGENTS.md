# AGENTS.md

This file governs agent behavior for the `D:\Estudio` workspace.

## Single Source Of State

Operational state lives in exactly two files:

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md` - portfolio source of truth: focus, priority, status and allowed work per project.
2. `08_Coordenacao_Agentes/Estado_Atual.md` - live snapshot: marker, short baseline and next step per project.

No other workspace-level document may carry project status, active tracks, published package names, release URLs, version codes or next steps. `README.md`, `CLAUDE.md`, `canon/canon-brief.md`, `Projetos/README.md` and this file are pointer documents. Run `tools/check_doc_drift.ps1` to verify; it is part of the docs-only validation habit.

When a task changes observable status, update `Estado_Atual.md` (and the `Prioridades_Estudio.md` table if focus/priority changed). Do not replicate the change anywhere else; history goes to the project's history files (`implementation/tracks/`, `docs/release-history.md`, Kanban Done, Handoffs).

## Workspace Roles

- `08_Coordenacao_Agentes/` is the coordination hub: Prioridades, Estado_Atual, Kanban, Handoffs, Decisoes, Templates and Painel Visual (`Painel_Visual_Estudio.html`).
- `canon/` is the shared source of truth for established lore, product identity, gameplay contracts, progression, shared architecture, mode standard and platform strategy. It carries no operational state.
- `Projetos/` holds all Godot projects; `Projetos/README.md` is the stable registry (identity and entry points only).
- `07_Aprendizados/` preserves operational lessons for agents.
- `materiais/` holds supporting guides (`materiais/guides/*-current.md` are the live ones) and non-canonical material.
- `migration/` is a historical archive for cutover, relocation and legacy comparison context.
- `tools/` holds studio-level scripts (doc drift check).

## Multi-Agent Worktree And Git Rule

`D:\Estudio` is the main coordination/read workspace. By default, agents must not use it as an implementation worktree. Each agent working on implementation, documentation, contracts, backend, client, validation, release or portfolio changes must create or use a dedicated Git worktree outside the main root, unless the user explicitly asks for direct work in `D:\Estudio`.

Default worktree path and branch names:

```text
D:\Estudio-worktrees\<projeto>--<agente>--<slug>
codex/<projeto>/<slug>        (Codex)
<agente>/<projeto>/<slug>     (other agents)
```

Rules:

- Never edit another agent's worktree unless the user explicitly asks for intervention there.
- Before touching shared files (`AGENTS.md`, `canon/`, `08_Coordenacao_Agentes/`, `Projetos/README.md`) run `git status --short`, `git worktree list`, and read the current coordination docs.
- At the start of work, register branch, worktree, objective, intended files, base docs read, validation plan and next handoff point in `08_Coordenacao_Agentes/Kanban/Doing/` or `08_Coordenacao_Agentes/Handoffs/`.
- Commit by logical stage: documentation, contract, backend, client, validation, publication and coordination updates should not be mixed into one mega commit.
- Remote backup: `origin` = `https://github.com/Bournellis/Studio.git` (private GitHub repository). After merging to main, run `git push origin main` so the backup stays current; Fabio may also push via GitHub Desktop.
- Single writer rule: while an agent task is committing in the main tree, do not commit/stage/discard from GitHub Desktop or an IDE in that tree. See `07_Aprendizados/2026-06-11_git-escritor-unico.md`.
- Keep the worktree clean at handoff whenever possible. If not clean, list every remaining changed file and why it remains changed.

## Portfolio Gate

Before opening deep documentation of any project, read:

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `Projetos/README.md`
3. `08_Coordenacao_Agentes/Estado_Atual.md`

The status taxonomy (`P0_IMPLEMENTACAO`, `P1_CONCEITO`, `P2_IMPLEMENTACAO`, `PAUSADO_TEMPORARIO`, `PAUSADO_INDEFINIDO`, `AGUARDANDO_DECISAO`, `ARQUIVO_DESIGN`, `ARQUIVO_HISTORICO`) and what each status allows are defined in `Prioridades_Estudio.md`. Follow them; do not infer permissions from history.

## Project Selection Gate

Choose the target project using the user's request and the portfolio table. Route by request domain:

- football/Copa/ball/goals/shirts -> `Projetos/JogoDaCopa/`
- FPS/arena 1x1/hitscan/jump pads (legacy name `FpsShooter`) -> `Projetos/FpsPlayground/`
- roguelike/ship hub/run map/Souls/relics/lane battles -> `Projetos/draxos-roguelike-cardgame/`
- mobile/PC browser client/Supabase/async autobattler/Base/Internal Alpha/release ops -> `Projetos/draxos-mobile/`
- isometric action campaign -> `Projetos/rpg-isometrico/` (historical consultation by default)
- turn-based board/cards exploration RPG -> `Projetos/rpg-turnos/` (historical consultation by default)
- `_conceitos/mobile-universe/` -> read-only design reference for DraxosMobile

`Draxos` alone is shared vocabulary and does not select a project. If the request names no project, use the current focus in `Prioridades_Estudio.md`. If the domain is ambiguous, confirm against the portfolio table before reading deep docs.

After choosing the target project, read only that project's `AGENTS.md`, `implementation/current-status.md` and active stage docs, unless the task is cross-cutting.

## Read Order - Fast Lane

For tasks localized in a single project or area:

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `08_Coordenacao_Agentes/Estado_Atual.md` (relevant section)
3. The active task in `08_Coordenacao_Agentes/Kanban/Doing/`, if any
4. The target project's `AGENTS.md` and `implementation/current-status.md`
5. `canon/canon-brief.md` when the task touches shared identity, lore or architecture

Escalate to the full order immediately if the task affects more than one project or canon direction, involves a product/architecture/platform decision, or the scope grows beyond the initially touched files.

## Read Order - Full

Before substantial work affecting multiple projects or the canon:

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `canon/product/product-vision.md`
3. `canon/design/game-design-document.md`
4. `canon/design/progression-design.md`
5. `canon/architecture/shared-architecture.md`
6. `canon/architecture/game-mode-standard.md`
7. `canon/roadmap/evolution-roadmap.md` and `canon/roadmap/release-horizons.md`
8. `canon/platform/steam-platform.md`
9. The target project's `AGENTS.md` and `implementation/current-status.md`
10. This file

## Canon Rule

If shared canon conflicts with any historical implementation note, the canon prevails.

Do not silently apply one project's mechanics in another. Projects share lore and studio conventions only; a mechanic crosses projects only when a local document of the receiving project explicitly adopts it. This applies in every direction: RPG Isometrico contracts are not RPG Turnos canon; `draxos-roguelike-cardgame` is not a variant of `rpg-turnos`; DraxosMobile inherits no gameplay from any of them; `JogoDaCopa` and `FpsPlayground` are independent tech probes that inherit no Draxos gameplay/economy/progression/backend systems.

DraxosMobile keeps local long-term product canon in `Projetos/draxos-mobile/docs/product-vision.md` until parts are promoted into shared canon.

## Godot Rule

Implementations live under `Projetos/`. Expected Godot version: see `.godot-version` at the workspace root. Which projects are active, paused or archived is defined only in `Prioridades_Estudio.md`.

When entering a Godot project:

1. Confirm allowed work in `Prioridades_Estudio.md`
2. Read the project's `AGENTS.md` and `implementation/current-status.md`
3. Read the active track in `implementation/tracks/` when one exists
4. Use historical validation docs only to answer specific questions

A future project under `Projetos/` only becomes official when it has a local `AGENTS.md`, a local `implementation/current-status.md`, an entry in `Projetos/README.md` and a summary entry in `Estado_Atual.md`.

## Historical Context Rule

If historical context is needed, consult in order: `migration/`, then `Projetos/rpg-isometrico/implementation/phase-g1/` through `phase-g4/`, and only then any external legacy repository if the task is explicitly historical.

## Manutencao Do Estado_Atual.md

- **Quando atualizar**: ao concluir qualquer tarefa que mude status observavel, prioridade, track ativa, baseline ou proximo passo.
- **O que atualizar**: somente as linhas que mudaram.
- **O que nao colocar**: historico de gates/pacotes, detalhes tecnicos, listas longas de arquivos - isso vai para Kanban Done, Handoffs, `implementation/tracks/` ou `docs/release-history.md` do projeto.
- **Regra do tamanho**: maximo ~12 linhas por projeto.

## Coordination Structure

- Prioridades e foco: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Estado atual: `08_Coordenacao_Agentes/Estado_Atual.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- Tarefas: `08_Coordenacao_Agentes/Kanban/` (Backlog, Doing, Review, Done)
- Handoffs: `08_Coordenacao_Agentes/Handoffs/`
- Decisoes de produto e arquitetura: `08_Coordenacao_Agentes/Decisoes/` (registre toda decisao de produto/arquitetura/processo em 5-15 linhas usando o template)
- Templates oficiais: `08_Coordenacao_Agentes/Templates/`

**Nomenclatura de arquivos Kanban**: `YYYY-MM-DD_agente_slug.md` (ex.: `2026-06-10_codex_jogodacopa_track02-quality-upgrade-series-v1.md`)
