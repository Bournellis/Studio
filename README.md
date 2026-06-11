# Estudio Workspace

This workspace is the documentation and implementation home for the studio's Godot projects, coordination state and shared canon.

## Operational State - Single Source

Portfolio truth lives in exactly two files:

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md` - focus, priority and allowed work per project
2. `08_Coordenacao_Agentes/Estado_Atual.md` - per-project snapshot and next step

This README intentionally carries no project status, package names, version codes or next steps. If any other document conflicts with the two files above, those two files win. Run `tools/check_doc_drift.ps1` to detect violations.

## Structure

- `canon/`: shared lore, product identity, architecture and platform direction (stable truth only).
- `Projetos/`: all Godot projects and concept archives; `Projetos/README.md` is the registry.
- `08_Coordenacao_Agentes/`: coordination hub - Prioridades, Estado_Atual, Kanban, Handoffs, Decisoes, Templates, Painel Visual.
- `07_Aprendizados/`: operational lessons for agents.
- `materiais/`: supporting guides and non-canonical material. Prefer `materiais/guides/*-current.md`; older guides are historical.
- `migration/`: historical cutover archive, parity notes and relocation records.
- `builds/`: generated build outputs and other disposable packages.
- `tools/`: studio-level scripts (doc drift check).
- Remote backup: private GitHub repository `Bournellis/Studio` (`origin`); push routine in `AGENTS.md`.

## Standard Read Order

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `AGENTS.md`
3. `Projetos/README.md`
4. `08_Coordenacao_Agentes/Estado_Atual.md`
5. the target project's `AGENTS.md` and `implementation/current-status.md`

## Historical Context

- `Projetos/rpg-isometrico/implementation/phase-g1/` through `phase-g4/` preserve the closed Godot validation cycle.
- `migration/` preserves the workspace cutover context and legacy comparison notes.

No standard task in this workspace should require opening the external Unity repository.

## Project Boundary

Projects under `Projetos/` may share lore and studio conventions without sharing mechanics automatically. A mechanic only crosses projects when a local document of the receiving project explicitly adopts it.
