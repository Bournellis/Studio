# DraxosMobile Doing - docs-stabilization

## Metadata

- data: `2026-06-15`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `coord-docs`
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/docs-stabilization`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--docs-stabilization`

## Objetivo

Executar uma rodada documental completa para alinhar indice, runbooks,
historico, docs de modos e labs ao gate atual de prova humana da Arena PVE,
sem alterar runtime, publicacao ou estado remoto.

## Latest Context

- Current operational state: ver `Projetos/draxos-mobile/implementation/current-status.md`.
- Portfolio state: ver `08_Coordenacao_Agentes/Prioridades_Estudio.md` e `08_Coordenacao_Agentes/Estado_Atual.md`.
- Arena proof source: `Projetos/draxos-mobile/docs/arena-pve-product-proof.md`.
- Arena UX proof plan: `Projetos/draxos-mobile/docs/arena-ux-proof-release-discipline-plan.md`.
- Mode boundaries: `Projetos/draxos-mobile/docs/minigames/mode-catalog.md`.
- Platform contracts: `Projetos/draxos-mobile/docs/contracts/minigame-platform-v1.md`.

## Base Lida

- `C:\Users\Fabio\.codex\skills\estudio-workspace\SKILL.md`
- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`

## Escopo

- Incluir:
  - corrigir referencias desatualizadas em docs de modo;
  - ampliar cobertura do indice documental;
  - separar runbook atual de historico de Internal Alpha;
  - reforcar limites de produto enquanto Arena PVE segue nao provada;
  - preparar labs para uma rodada pos-veredito humano.
- Fora do escopo:
  - runtime ou Godot code;
  - backend, Supabase ou Cloudflare mutation;
  - export, package, upload ou deploy;
  - tuning numerico, economia, PVP, conteudo novo, visual final ou expansao Openworld;
  - worktrees de outros agentes.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/minigames/autobattler.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-decision-pack.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-objectives.md`
- `Projetos/draxos-mobile/docs/minigames/mode-catalog.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/docs/internal-alpha-release-plan.md`
- `Projetos/draxos-mobile/docs/internal-alpha-*.md`
- `Projetos/draxos-mobile/docs/arena-pve-product-proof.md`
- `Projetos/draxos-mobile/docs/arena-ux-proof-release-discipline-plan.md`
- `Projetos/draxos-mobile/docs/product-vision.md`
- `Projetos/draxos-mobile/docs/product-brief.md`
- `Projetos/draxos-mobile/docs/game-design-document.md`
- `Projetos/draxos-mobile/docs/design-pending.md`
- `Projetos/draxos-mobile/docs/battle-lab/README.md`
- `Projetos/draxos-mobile/docs/progression-lab/README.md`
- `Projetos/draxos-mobile/docs/contracts/lab-heuristics.md`

## Validation Plan

- `git diff --check`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_doc_drift.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -Profile DocsOnly -NoProjectWrites`
- targeted `rg` drift checks for stale package/current-stage wording.

## Remote Mutation / Publication

- remote mutation/publication run: `no`
- preserved boundary: `no deploy, no Supabase/Cloudflare mutation, no export/publication`

## Handoff Point

Fechar com commits locais separados por bloco documental, mover este card para
Done com validacoes e declarar `PUSH PENDENTE: Fabio - GitHub Desktop - Push
origin`.
