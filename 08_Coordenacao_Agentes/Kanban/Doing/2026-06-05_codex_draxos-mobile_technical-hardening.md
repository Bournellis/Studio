# DraxosMobile Hardening Doing: technical-hardening

## Metadata

- data: `2026-06-05`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `coord-docs + validation-release + client-shell + backend-schema + session-data`
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/technical-hardening`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--technical-hardening`

## Objetivo

Executar o plano aprovado de hardening tecnico antes de novas expansoes: compactar docs vivos, remover mutacao de publicacao do runner de validacao, tirar Modes Ops do cliente, refatorar hotspots para facilitar proximas implementacoes e endurecer auth/idempotencia/recompensas legacy.

## Latest Context

- latest published package: `Openworld Main Menu Sync`
- latest release root: `internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`
- latest Arena loop package: `Track 21 - Arena Loop Unlock And Friction Pass`
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`
- previous hardening/live-doc baseline: `Foundation Hardening V2`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `canon/canon-brief.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Escopo

- Incluir:
  - reconciliacao e compactacao de docs vivos de DraxosMobile;
  - release tooling para impedir publicacao mutante via `validate_foundation.ps1`;
  - remocao/bloqueio forte de `Modes Ops` no cliente, preservando Battle Lab e Progression Lab;
  - refatoracao extract-only de hotspots e budgets estruturais;
  - hardening amplo em duas fases de auth para handlers mutaveis;
  - reset transacional v1 com `request_hash`;
  - Arena rewards DB-side com `arena_reward_profiles`.
- Fora do escopo:
  - remote mutation/publicacao;
  - keystore/release signing Android;
  - desativar Labs;
  - tuning numerico amplo, PVP, conteudo novo, novas armas/spells/pocoes ou economia ampla;
  - worktrees de outros agentes.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/product-vision.md`
- `Projetos/draxos-mobile/docs/product-brief.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/design-pending.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/implementation/tracks/track-13-validation-release-safety/*`
- `Projetos/draxos-mobile/tools/validate_foundation.ps1`
- `Projetos/draxos-mobile/tools/check_release_safety.ps1`
- `Projetos/draxos-mobile/project.godot`
- `Projetos/draxos-mobile/modes/boot/**`
- `Projetos/draxos-mobile/online/**`
- `Projetos/draxos-mobile/server/**`
- `Projetos/draxos-mobile/supabase/**`
- `Projetos/draxos-mobile/tests/**`
- `Projetos/draxos-mobile/tools/smoke_*.gd`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-05_codex_draxos-mobile_technical-hardening.md`

## Validation Plan

- `git diff --check`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile DocsOnly -NoProjectWrites`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun -NoProjectWrites`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick -NoProjectWrites`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ModePlatform -NoProjectWrites`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ServerQuick -NoProjectWrites`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- targeted Deno/GUT/smoke tests per package.

## Handoff Point

Handoff quando cada pacote logico estiver validado e, se possivel, commitado separadamente. Se a execucao completa ficar grande demais para uma unica sessao, o proximo agente deve continuar a partir deste Doing, preservando worktree/branch e validando o ultimo pacote antes de abrir o seguinte.
