# DraxosMobile Hardening Done: technical-hardening

## Metadata

- data: `2026-06-05`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `coord-docs + validation-release + client-shell + backend-schema + session-data`
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/technical-hardening`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--technical-hardening`
- status: `TRACK_22_TECHNICAL_HARDENING_DELIVERED_LOCAL`

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

## Delivery State

Track 22 Technical Hardening is delivered locally on branch `codex/draxos-mobile/technical-hardening`.

No remote publication, Supabase remote mutation, Cloudflare deploy or Android keystore work was performed.

Delivered scope:

- live DraxosMobile docs compacted;
- validation runner made non-publishing;
- `Modes Ops` isolated out of the Godot client;
- account reset idempotency hardened with `request_hash`;
- Arena rewards moved to explicit DB-side reward profiles;
- shared `verifiedAuthContext` applied broadly across mutable/lab/release endpoints;
- Base and Arena client surface presenters split into smaller pure helper modules.

## Handoff Point

Handoff quando cada pacote logico estiver validado e, se possivel, commitado separadamente. Se a execucao completa ficar grande demais para uma unica sessao, o proximo agente deve continuar a partir deste Doing, preservando worktree/branch e validando o ultimo pacote antes de abrir o seguinte.

Final handoff: review/merge branch `codex/draxos-mobile/technical-hardening`; `DatabaseLocal` was rerun successfully with local Supabase/Edge stack active.

## Execution Snapshot - 2026-06-05

- Phase 1 delivered locally on branch `codex/draxos-mobile/technical-hardening`.
- Handoff file: `08_Coordenacao_Agentes/Handoffs/2026-06-05_codex_draxos-mobile_technical-hardening.md`.
- Latest commit: `676265d Verify progression lab auth context`.
- No remote mutation/publication.
- Validated latest backend package with `ServerQuick`; latest client refactors with `ClientQuick`.
- Remaining recommended phase 2: migrate remaining mutable endpoints to `verifiedAuthContext` and continue optional extraction-only refactors in smaller packages.

## Final Execution Snapshot - 2026-06-05

- Phase 2 delivered locally.
- Latest commit at handoff: `17f699a Extract arena surface text helpers`.
- `ServerQuick`: PASS (`112` foundation tests + `19` PVE Arena tests).
- `ClientQuick`: PASS (`223/223`, `3608` asserts, responsive/export smokes included).
- `ModePlatform`: PASS (`38/38`, Bosque/Openworld/Modes Ops smokes included).
- `ReleaseDryRun`: PASS after this card moved from Doing to Done.
- `DatabaseLocal`: PASS after starting Docker Desktop, local Supabase and local Edge Functions.

## Phase 2 Execution Plan - 2026-06-05

- Branch/worktree: continue on `codex/draxos-mobile/technical-hardening` at `D:\Estudio-worktrees\draxos-mobile--codex--technical-hardening`.
- Approved scope:
  - migrate remaining user-bearer Edge endpoints to shared `verifiedAuthContext`;
  - include `content`, `lab-runner` and, last, `release`;
  - preserve Battle Lab and Progression Lab;
  - continue extraction-only client refactors in small packages, including Base render helpers with responsive smoke validation;
  - attempt `DatabaseLocal` only if the local Supabase/Edge stack is ready.
- Out of scope:
  - remote mutation/publication/deploy/upload;
  - Android keystore/release signing;
  - tuning, PVP, new content, new weapons, new spells, new potions or broad economy changes.
- Planned package order:
  1. shared auth helper foundation;
  2. `content` + `lab-runner`;
  3. `base` + `competition`;
  4. `build` + `crafting` + `monetization` + `social`;
  5. `battle` + `arena`;
  6. `modes`;
  7. `release`;
  8. client Base pure text helpers;
  9. client Base visual helpers;
  10. client Base/Crafting flow;
  11. client Arena pure text helpers;
  12. wrapper cleanup and final validation/handoff.
- Validation strategy:
  - targeted `deno check`/tests per backend package;
  - `ServerQuick` after backend groups;
  - GUT/client targeted validation and `ClientQuick` after client packages;
  - `smoke_responsive_layout.gd` for Base/Arena render changes;
  - `ModePlatform` after modes/lab-sensitive work;
  - `ReleaseDryRun` and `check_release_safety.ps1` after the release endpoint package;
  - final `git diff --check` and `git status --short`.
