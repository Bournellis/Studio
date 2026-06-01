# Track 21 - Arena Loop Unlock And Friction Pass

- Agente: Codex
- Branch: `codex/draxos-mobile/track21-arena-loop-unlock-friction`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--track21-arena-loop-unlock-friction`
- Base: `codex/draxos-mobile/s1-arena-calibration-integration` (`4a7c649`)
- Objetivo: corrigir unlock da primeira arena real apos tutorial e reduzir cliques obrigatorios do loop Arena PVE.
- Arquivos pretendidos: migrations espelhadas `server/schema` e `supabase/migrations`, `server/functions/arena`, `supabase/functions/arena`, `modes/boot/flows/arena_lifecycle_flow.gd`, `modes/boot/surfaces/arena_surface_presenter.gd`, testes Deno/GUT e status da Track 21.
- Docs lidos: workspace `AGENTS.md`, `Prioridades_Estudio.md`, `Projetos/README.md`, `Estado_Atual.md`, `Projetos/draxos-mobile/AGENTS.md`, `implementation/current-status.md`, `docs/agent-operating-manual.md`, `docs/documentation-index.md`, `docs/pve-arena-initial-direction.md`, `docs/foundation-responsive-layout-contract.md`.
- Validacao concluida: `git diff --check`, testes Deno de arena/schema/catalog, checks Deno server/supabase, Godot `validate.gd` (140 tests / 2376 asserts), `smoke_responsive_layout.gd`, `smoke_exports.gd`, `validate_foundation.ps1 -Profile Quick`, `export_internal_alpha.ps1`, `publish_internal_alpha.ps1 -Mode Plan` e `publish_internal_alpha.ps1 -Mode Package`.
- Publicacao remota: `internal-alpha/v0-track21-arena-loop-20260531-df9f12d`; preview `https://2adcfa6b.draxos-mobile-internal-alpha.pages.dev`; manifest e smokes remotos passaram.
- Handoff: testar novo save em remoto: tutorial -> continuar na Arena -> primeira arena 3 duelos desbloqueada -> start direto sem confirmacao redundante.
