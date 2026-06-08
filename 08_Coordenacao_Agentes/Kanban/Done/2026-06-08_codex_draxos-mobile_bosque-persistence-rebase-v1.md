# DraxosMobile Hardening Done: Bosque Persistence Rebase v1

## Metadata

- data: `2026-06-08`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `backend-schema + session-data + mode-scaffolds + validation-release`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/bosque-persistence-rebase-v1`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-persistence-rebase-v1`

## Objetivo

Rebasear a persistencia do Bosque para ACK + retry server-authoritative, com nodes persistentes por cooldown de item, versao `0.0.10-alpha.0` e publicacao Web/APK no canal Internal Alpha.

## Latest Context

- latest remote package: `Bosque Session Lifecycle & Durable Structures Hotfix v1`
- latest release root: `internal-alpha/v0-bosque-session-lifecycle-structures-hotfix-v1-20260607-c953b51`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`
- Openworld source: `docs/minigames/openworld.md`
- Openworld decision source: `docs/minigames/openworld-decision-pack.md`
- release source: `docs/release-ops-checklist.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-decision-pack.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`

## Escopo

- Incluir:
  - progresso duravel `openworld_forest_progress_v2` com `node_state` e `applied_ops`;
  - checkpoint operations v2 para coleta, deposito, craft, guidance e posicao;
  - fila local `openworld_pending_ops_cache` e feedback honesto de ACK;
  - cooldown por item para nodes do Bosque;
  - testes client/server e docs vivas;
  - versionamento, commit, merge e publicacao Web/APK.
- Fora do escopo:
  - PVP, social, economia ampla, tuning amplo, novos mapas, NPCs, combate, quests ou novos assets finais;
  - trabalho em worktrees de outros agentes;
  - secrets em Git/docs/export.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/data/definitions/openworld/forest_ruleset_v1.json`
- `Projetos/draxos-mobile/modes/openworld/`
- `Projetos/draxos-mobile/online/session_store.gd`
- `Projetos/draxos-mobile/server/schema/migrations/`
- `Projetos/draxos-mobile/supabase/migrations/`
- `Projetos/draxos-mobile/server/functions/`
- `Projetos/draxos-mobile/supabase/functions/`
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/server/tests/`
- `Projetos/draxos-mobile/docs/minigames/`
- release/version/status docs.

## Validation Plan

- `git diff --check`
- Openworld GUT targeted
- full GUT client
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- Openworld/modes Deno tests
- `validate_foundation.ps1 -Profile ClientQuick`
- `validate_foundation.ps1 -Profile ServerQuick`
- `validate_foundation.ps1 -Profile ReleaseDryRun`
- `check_release_safety.ps1`
- `check_android_release_keystore.ps1 -Mode InternalAlpha`
- `check_foundation_expansion_readiness.ps1`
- release package/upload/deploy/manifest and remote smokes after local gates.

## Handoff Point

Implementacao e validacao local principais concluidas; release/publish segue no mesmo branch/worktree. Registrar commits, arquivos alterados, comandos, resultados, release root, preview Web, APK, estado do worktree e qualquer pendencia de playtest humano no handoff/final.

## Resultados Locais

- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- Deno modos/ruleset/ops targeted: PASS, 43 tests.
- GUT client completo: PASS, 242 tests / 3794 asserts.
- `validate_foundation.ps1 -Profile ClientQuick`: PASS.
- `validate_foundation.ps1 -Profile ServerQuick`: PASS apos atualizar o release fallback contract para o pacote novo.
- Migracao `202606080001_openworld_bosque_persistence_rebase_v1.sql`: server/supabase byte-equivalente por SHA-256.

## Pendencias De Release

- `validate_foundation.ps1 -Profile ReleaseDryRun` deve ser repetido apos a remocao desta Doing card.
- Commitar etapas logicas.
- Rebase/merge em `main`.
- Aplicar migracao Supabase remota, deploy functions, package/upload/deploy Web/APK, smokes remotos e registro final de evidencias.
