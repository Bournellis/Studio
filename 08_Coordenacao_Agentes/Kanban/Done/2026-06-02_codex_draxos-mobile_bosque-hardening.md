# DraxosMobile - Bosque Hardening

- Data: 2026-06-02
- Agente: Codex
- Lane: mode-scaffolds / backend-schema / client-shell / validation-release
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/bosque-hardening`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-hardening`
- Base: `master` @ `1e79f97`
- Objetivo: implementar o hardening tecnico do Openworld Bosque como modo oficial `active` em `internal_alpha`, com ruleset v1, snapshot remoto retomavel, eventos server-authoritative, Reward Bridge preservada e release preparado sem publicacao.

## Dependencias E Guardrails

- `codex/draxos-mobile/app-responsiveness` ainda nao esta mergeada em `master`; a implementacao do Bosque fica isolada e a publicacao/merge final deve esperar essa baseline ou rebasear apos ela.
- `codex/draxos-mobile/arena-backend` informa padroes de definitions/mirror/testes, mas nao bloqueia este trabalho enquanto estiver sujo e em commit antigo.
- Remote mutation nao autorizada nesta tarefa: nao aplicar migrations remotas, nao fazer upload, nao rodar `DeployManifest`, nao trocar manifest e nao publicar.

## Escopo

- Definitions versionadas para `openworld/forest` ruleset v1.
- Backend `modes` com start/event/complete/abandon/state para snapshot remoto, revision e event log.
- Client Openworld com retomada remota, envio de eventos, heartbeat 15s, preview offline sem recompensa e UI limpa.
- Docs/status atualizados e release plan local sem publicacao.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/data/definitions/openworld/`
- `Projetos/draxos-mobile/data/definitions/modes/openworld/metadata.json`
- `Projetos/draxos-mobile/modes/openworld/`
- `Projetos/draxos-mobile/online/supabase_client.gd`
- `Projetos/draxos-mobile/server/functions/modes/`
- `Projetos/draxos-mobile/supabase/functions/modes/`
- `Projetos/draxos-mobile/server/schema/migrations/`
- `Projetos/draxos-mobile/supabase/migrations/`
- `Projetos/draxos-mobile/server/tests/`
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/docs/minigames/`
- `Projetos/draxos-mobile/docs/contracts/`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Validacao Planejada

- `git diff --check`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- Deno tests de modes/openworld, mirrors e definitions.
- `tools/smoke_openworld_forest.gd`
- `tools/smoke_modes_visual_layout.gd`
- GUT client relevante.
- `tools/validate_foundation.ps1 -Profile ServerQuick`
- `tools/validate_foundation.ps1 -Profile ModePlatform`
- `tools/validate_foundation.ps1 -Profile ReleaseDryRun`

## Handoff

- Proximo ponto de handoff: apos backend/client/docs locais green, com publicacao explicitamente nao executada.
- 2026-06-02: implementacao local concluida no worktree, `ServerQuick`, `ModePlatform`, `ClientQuick` e `ReleaseDryRun` passaram. Handoff final registrado em `08_Coordenacao_Agentes/Handoffs/2026-06-02_codex_draxos-mobile_bosque-hardening.md`.
