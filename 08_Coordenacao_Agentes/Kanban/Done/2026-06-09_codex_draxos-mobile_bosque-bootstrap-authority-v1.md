# DraxosMobile - Bosque Bootstrap Authority v1

- Data: `2026-06-09`
- Agente: `Codex`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/bosque-bootstrap-authority-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-bootstrap-authority-v1`
- Base: `main` em `16ae233`
- Status: `READY_FOR_PUBLISH`

## Objetivo

Corrigir o bootstrap visual do Openworld/Bosque para impedir que a tela exiba um frame de Bosque `full spawn` antes de aplicar o estado canônico remoto ou cache canônico válido.

## Escopo Pretendido

- Cliente Godot do Bosque:
  - `modes/openworld/openworld_forest_screen.gd`
  - `modes/openworld/openworld_forest_runtime_state.gd`
  - testes relacionados em `tests/client/`
- Versionamento e release:
  - `core/project_info.gd`
  - `export_presets.cfg`
  - `server/functions/release/`
  - `supabase/functions/release/`
  - docs/status vivos se a publicação for concluída
- Coordenação:
  - este cartão Doing e eventual registro final.

## Fora De Escopo

- Não alterar cooldowns, economia, conteúdo, recipes, Fogueira, Arena PVE ou backend `modes`.
- Não reabrir o contrato de persistência v2; apenas corrigir a primeira renderização visual antes da autoridade online.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/foundation-app-v0-audit.md`

## Plano De Validacao

- GUT targeted para Bosque/Openworld.
- GUT client completo ou `tools/validate.gd`, conforme custo/tempo.
- `validate_foundation.ps1 -Profile ClientQuick`.
- `validate_foundation.ps1 -Profile ReleaseDryRun`.
- `check_release_safety.ps1`.
- `check_android_release_keystore.ps1 -Mode InternalAlpha`.
- `git diff --check`.
- Release package/upload/deploy manifest/Web smoke após merge em `main`, com `-ConfirmRemoteMutation`.

## Handoff Planejado

Após implementação, validação, commit, merge e publicação Web+APK, registrar:

- release root;
- version/version code;
- preview hash;
- evidências de validação;
- links APK/PC/Web/manifest quando disponíveis.

## Progresso

- Código cliente implementado.
- Regressão de bootstrap visual adicionada.
- Versionamento local preparado para `0.0.15-alpha.0` / version code `15`.
- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- GUT client: PASS, 252 testes / 3849 asserts.
- `validate_foundation.ps1 -Profile ClientQuick`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun`: falhou enquanto este cartão ainda estava em `Doing`; repetir após este move.
