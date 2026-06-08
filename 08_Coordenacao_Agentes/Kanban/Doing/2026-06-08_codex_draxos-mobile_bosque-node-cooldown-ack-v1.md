# DraxosMobile Doing: Bosque Node Cooldown ACK v1

## Metadata

- data: `2026-06-08`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `mode-scaffolds` + `backend-schema` + `validation-release`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/bosque-node-cooldown-ack-v1`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-node-cooldown-ack-v1`

## Objetivo

Corrigir o bug em que nodes do Bosque parecem respawnar instantaneamente ao sair/voltar e a segunda coleta fica presa em "aguardando o servidor". O contrato do pacote e: node coletado so pode reaparecer por `node_state.next_spawn_at` calculado a partir da coleta confirmada pelo servidor, e rejeicoes de cooldown devem ser terminais para a operacao local, nunca retry infinito.

## Intended Files

- `Projetos/draxos-mobile/modes/openworld/openworld_integrated_session_bridge.gd`
- `Projetos/draxos-mobile/modes/openworld/openworld_forest_screen.gd`
- `Projetos/draxos-mobile/server/functions/modes/*`
- `Projetos/draxos-mobile/supabase/functions/modes/*`
- `Projetos/draxos-mobile/tests/client/*openworld*`
- `Projetos/draxos-mobile/server/tests/*openworld*`
- version/release files, release smoke tests and live docs after implementation.

## Docs Read

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`

## Validation Plan

- Targeted GUT Openworld bridge/screen tests.
- Targeted Deno Openworld/modes tests.
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `validate_foundation.ps1 -Profile ClientQuick`
- `validate_foundation.ps1 -Profile ServerQuick`
- `validate_foundation.ps1 -Profile ReleaseDryRun`
- Release smokes after publication.
- `git diff --check`

## Handoff Point

After implementation and validation, move this card to Done with release root, preview evidence, artifact hashes and remote smoke status.
