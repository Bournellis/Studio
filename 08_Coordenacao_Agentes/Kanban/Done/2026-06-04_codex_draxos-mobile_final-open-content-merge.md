# DraxosMobile Done: final open content merge

## Metadata

- data: `2026-06-04`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `coord-docs`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/final-open-content-merge`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--final-open-content-merge`

## Objetivo

Integrar seletivamente no `master` o conteudo util que restou em aberto apos o merge de DraxosMobile, sem aplicar merges literais de branches antigas que rebaixam snapshots ou criam conflitos documentais.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Kanban/Review/2026-06-04_codex_draxos-mobile_open-content-review.md`
- `Projetos/draxos-mobile/docs/design-pending.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-objectives.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-decision-pack.md`

## Escopo

- Preservar como historico os registros uteis de `codex/draxos-mobile/publish-latest-main-url`.
- Extrair de `codex/draxos-mobile/openworld-objectives-docs` apenas a direcao de produto ainda valida: Openworld como experimento interno, expansao menu-no-mundo como candidata e conflito minimo como candidata futura.
- Fechar o cartao de Review quando o conteudo util estiver incorporado.

## Fora Do Escopo

- Merge literal de branches antigas.
- Mudanca runtime Godot, backend, schema, Supabase, Cloudflare ou publicacao remota.
- Promover Openworld completo, cidade, inimigos, NPCs, quests ou combate para implementacao.

## Validation Plan

- `git diff --check`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile DocsOnly`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`

## Handoff Point

Handoff quando o conteudo util estiver em docs vivos, os registros historicos preservados, o Review fechado e a branch pronta para fast-forward/merge no `master`.

## Resultado - 2026-06-04

- Registros historicos de `publish-latest-main-url` preservados em `Handoffs/`
  e `Kanban/Done/`, marcados como superseded por Bosque Mecanico Basico v2.
- Handoff de `openworld-objectives-docs` preservado como historico e marcado
  contra merge literal.
- Conteudo util de produto integrado seletivamente em:
  - `Projetos/draxos-mobile/docs/minigames/openworld-objectives.md`;
  - `Projetos/draxos-mobile/docs/minigames/openworld-decision-pack.md`;
  - `Projetos/draxos-mobile/docs/design-pending.md`.
- `DMOB-D072` e `DMOB-D073` registrados como decisoes futuras abertas.
- Review `2026-06-04_codex_draxos-mobile_open-content-review.md` movido para
  `Kanban/Done`.

## Validacao Executada

- `git diff --check`: PASS.
- `validate_foundation.ps1 -Profile DocsOnly`: PASS.
- `check_foundation_expansion_readiness.ps1`: PASS.
