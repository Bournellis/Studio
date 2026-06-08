# DraxosMobile Hardening Doing: platform-v1 - Bosque Resume Exit Lifecycle v1

## Metadata

- data: `2026-06-08`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `platform-v1`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/bosque-resume-exit-lifecycle-v1`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-resume-exit-lifecycle-v1`

## Objetivo

Corrigir a retomada do Bosque apos `Voltar`, impedindo que uma sessao preservada vire um Bosque novo fora do save e garantindo que falhas de checkpoint nao prendam o jogador dentro do modo.

## Latest Context

- latest package: `Bosque Feel & Spawn Authority v1`
- release root atual: `internal-alpha/v0-bosque-feel-spawn-authority-v1-20260608-70b79c3`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`
- openworld source: `docs/minigames/openworld.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`

## Escopo

- Incluir:
  - retomada robusta de sessao Openworld/Bosque por `session_id` preservado;
  - fallback server-side para retornar sessao ativa quando `start_session` encontra visita viva;
  - saida do Bosque com pendencias sem aprisionar o jogador;
  - testes client/server focados no fluxo `Voltar -> reabrir -> sair`;
  - bump de release, docs/status e publicacao Web/APK.
- Fora do escopo:
  - tuning de spawn, economia, conteudo, PVP, visual final ou novas features;
  - worktrees de outros agentes;
  - secrets ou service role em cliente/docs.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/openworld/openworld_integrated_session_bridge.gd`
- `Projetos/draxos-mobile/modes/openworld/openworld_forest_screen.gd`
- `Projetos/draxos-mobile/server/functions/modes/*`
- `Projetos/draxos-mobile/supabase/functions/modes/*`
- `Projetos/draxos-mobile/server/schema/migrations/*`
- `Projetos/draxos-mobile/supabase/migrations/*`
- `Projetos/draxos-mobile/tests/client/*openworld*`
- `Projetos/draxos-mobile/server/tests/*openworld*`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- release/version files and studio status docs after publication.

## Validation Plan

- targeted GUT Openworld tests
- Deno mode/openworld tests and function checks
- `validate_foundation.ps1 -Profile ClientQuick`
- `validate_foundation.ps1 -Profile ServerQuick`
- `validate_foundation.ps1 -Profile ReleaseDryRun`
- release safety checks
- `git diff --check`
- package/upload/deploy/smoke for Internal Alpha after local validation

## Handoff Point

Handoff only after the hotfix is validated, merged to `main`, published to the canonical Internal Alpha URL, and status docs list the new release root, APK, preview evidence and any residual risk.
