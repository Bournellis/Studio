# Bosque Session Lifecycle & Durable Structures Hotfix v1

- Projeto: `Projetos/draxos-mobile/`
- Agente: Codex
- Branch: `codex/draxos-mobile/bosque-session-lifecycle-structures-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--hotfix--bosque-session-lifecycle-structures`
- Base: `main` em `11c93e4`
- Lane: `backend-schema`, `client-shell`, `validation-release`
- Modo: `openworld`

## Objetivo

Corrigir a regressao em que o Bosque reabre sessao expirada com nodes ja coletados e a regressao em que construcoes duraveis, especialmente `fogueira_estavel_1`, somem apos sair/relogar.

## Escopo Pretendido

- Migrations espelhadas `server/schema` e `supabase/migrations`.
- Edge/shared mode state filtering quando necessario.
- Cliente Godot Openworld: cache de sessao ativa, boot, checkpoint critico da Fogueira e UX de salvamento.
- Testes Godot/servidor focados em sessao expirada, structures duraveis e Fogueira.
- Docs/status/coordenação e publicacao Web/APK aprovadas pelo pedido.

## Docs Lidos

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

## Validacao Planejada

- Deno checks/tests de Openworld/modes.
- GUT client tests focados em Openworld/Arena.
- `tools/validate.gd`.
- `validate_foundation.ps1` perfis `ServerQuick`, `ClientQuick` e `ReleaseDryRun`.
- `publish_internal_alpha.ps1` Plan/Package/Upload/DeployManifest e smokes remotos apos merge/publicacao.

## Handoff

Handoff quando o hotfix estiver validado, publicado, mergeado em `main` e a worktree limpa/removida.
