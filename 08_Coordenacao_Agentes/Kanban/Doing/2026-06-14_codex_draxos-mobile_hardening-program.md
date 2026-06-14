# DraxosMobile Hardening Doing: multi-lane - estabilizacao completa

## Metadata

- data: `2026-06-14`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `coord-docs | backend-schema | client-shell | platform-v1`
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/hardening-*`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--hardening-*`

## Objetivo

Executar o programa completo de estabilizacao do DraxosMobile antes de novas
expansoes de produto.

## Latest Context

- Current published package: `Bosque Overlay Layer And Readiness Authority v1`
  (`BOSQUE_OVERLAY_LAYER_READINESS_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`).
- Current local implemented stage: pacote publicado preservado como baseline.
- Preserved Arena context: `Arena PVE remains the first approved core; see docs below`.
- Open decision: `none for expansion; hardening only`.
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/hardening-program.md`
- `Projetos/draxos-mobile/docs/pve-arena-v1.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`

## Escopo

- Incluir:
  - `coord-docs`: corrigir drift de estado operacional e `DocsOnly`.
  - `backend-schema`: reduzir risco do mirror `server/` <-> `supabase/`.
  - `client-shell`: decompor/harden overlay shell e testes de interacao.
  - `openworld`: decompor bridge e consolidar persistencia sem expandir modo.
  - `architecture-contract-refresh`: atualizar arquitetura viva e contratos.
  - `arena-pve-proof`: preparar roteiro/evidencia para playtest humano.
- Fora do escopo:
  - worktrees de outros agentes;
  - remote mutation/publicacao;
  - push/fetch/pull;
  - tuning numerico, economia, PVP, conteudo novo ou visual final sem decisao
    explicita.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/tools/validate_foundation.ps1`
- `Projetos/draxos-mobile/tools/sync_backend_mirror.ps1`
- `Projetos/draxos-mobile/docs/*`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/modes/boot/ui/*`
- `Projetos/draxos-mobile/modes/openworld/*`
- `Projetos/draxos-mobile/tests/client/*`

## Validation Plan

- `git diff --check`
- `tools/check_doc_drift.ps1`
- `validate_foundation.ps1 -Profile DocsOnly -NoProjectWrites`
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`
- `validate_foundation.ps1 -Profile ModePlatform -NoProjectWrites`

## Remote Mutation / Publication

- remote mutation/publication run: `no`
- if yes, evidence: `n/a`
- if no, preserved boundary: `no deploy, no Supabase/Cloudflare mutation, no export/publication`

## Handoff Point

Handoff seguro quando as lanes estiverem integradas localmente, os gates
disponiveis passarem e Fabio tiver um roteiro claro para playtest humano da Arena
PVE. Fechamento deve declarar `PUSH PENDENTE: Fabio - GitHub Desktop - Push
origin`.
