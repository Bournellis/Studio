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

## Resultado

- Implementado backend/schema, client/cache/UX, testes, docs e release para corrigir sessao expirada do Bosque e persistencia duravel de `structures`.
- Publicado como Internal Alpha `0.0.9-alpha.0` / version code `9`.
- Release root: `internal-alpha/v0-bosque-session-lifecycle-structures-hotfix-v1-20260607-c953b51`.
- Preview: `https://8ecac093.draxos-mobile-internal-alpha.pages.dev`.
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`.
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`.
- APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-session-lifecycle-structures-hotfix-v1-20260607-c953b51/downloads/draxos-mobile-alpha.apk`.
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-session-lifecycle-structures-hotfix-v1-20260607-c953b51/downloads/draxos-mobile-alpha.zip`.

## Validacao Executada

- `git diff --check`: PASS.
- Deno focused tests for modes/Openworld/release: PASS.
- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- `validate_foundation.ps1 -Profile ServerQuick`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick`: PASS, GUT 241 tests / 3771 asserts; known teardown orphan warnings only.
- `validate_foundation.ps1 -Profile ReleaseDryRun -RequireClean`: PASS.
- Remote migration `202606070001_openworld_bosque_session_lifecycle_structures_v1.sql`: applied.
- Supabase functions `modes` and `release`: deployed.
- Export/package/upload/deploy manifest: PASS.
- Direct preview Web launch smoke: PASS, loaded in `7288 ms`.
- `validate_foundation.ps1 -Profile RemoteReadOnly`: PASS, remote Web launch loaded in `3265 ms`.

## Fechamento

Branch final pronta para merge em `main`. Depois do merge, remover a worktree `D:\Estudio-worktrees\draxos-mobile--hotfix--bosque-session-lifecycle-structures` e deletar a branch `codex/draxos-mobile/bosque-session-lifecycle-structures-hotfix-v1`.
