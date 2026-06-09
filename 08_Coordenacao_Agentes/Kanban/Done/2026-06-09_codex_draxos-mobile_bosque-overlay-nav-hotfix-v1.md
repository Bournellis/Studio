# Bosque Overlay Navigation Hotfix v1

- Data: `2026-06-09`
- Agente: Codex
- Branch: `codex/draxos-mobile/bosque-overlay-nav-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-overlay-nav-hotfix-v1`
- Projeto: `Projetos/draxos-mobile`
- Base: `main` em `6da9ab7`
- Estado: implementado localmente; publicacao e handoff final em andamento nesta branch.

## Objetivo

Corrigir a regressao reportada no teste Web do pacote `Bosque Persistent Overlay Shell v1`: menu/overlay abria, mas o usuario nao conseguia fechar, voltar nem usar Esc. A correcao foi tratada como revisao estrutural da implementacao de overlay/back/close/input, nao como ajuste pontual.

## Arquivos Alterados

- `Projetos/draxos-mobile/modes/boot/boot_runtime.gd`
- `Projetos/draxos-mobile/modes/boot/boot_runtime_action_dispatcher.gd`
- `Projetos/draxos-mobile/modes/boot/ui/mode_shell_overlay_controller.gd`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/tests/client/test_project_info.gd`
- `Projetos/draxos-mobile/core/project_info.gd`
- `Projetos/draxos-mobile/export_presets.cfg`
- `Projetos/draxos-mobile/server/functions/release/index.ts`
- `Projetos/draxos-mobile/supabase/functions/release/index.ts`
- `Projetos/draxos-mobile/server/tests/*release*.ts`
- `Projetos/draxos-mobile/data/rulesets/foundation_ruleset_v0.json`
- `Projetos/draxos-mobile/server/functions/_shared/foundation_ruleset.ts`
- `Projetos/draxos-mobile/supabase/functions/_shared/foundation_ruleset.ts`
- `Projetos/draxos-mobile/server/schema/migrations/202605300004_foundation_closeout.sql`
- `Projetos/draxos-mobile/supabase/migrations/202605300004_foundation_closeout.sql`

## Problemas Resolvidos

- Header do overlay agora preserva clique nos botoes `Voltar` e `Fechar`.
- Esc/Web passa pelo `_input` alem de `_unhandled_input`, com fallback explicito para `KEY_ESCAPE`.
- Fechamento do overlay nao fica bloqueado por busy global ou action id obsoleto; bloqueia apenas replay critico ou mutacao critica realmente ocupada.
- Acoes internas que fecham o overlay limpam `_active_action_id` e `_active_action_scope`, evitando bloqueio fantasma.
- Hash do ruleset foundation foi regenerado e o seed/mirror do closeout foi alinhado para manter `ServerQuick` verde.

## Validacoes Executadas

- `git diff --check`: OK.
- Godot GUT client completo: 270/270 OK.
- `validate_foundation.ps1 -Profile ClientQuick`: OK.
- `npx -y deno test --allow-read --allow-env server/tests/foundation_closeout_schema_test.ts`: OK.
- `validate_foundation.ps1 -Profile ServerQuick`: OK.
- `check_release_safety.ps1`: OK.
- `check_android_release_keystore.ps1 -Mode InternalAlpha`: OK, com aviso esperado de `debug_fallback` por keystore release nao configurado.

## Publicacao

- Pacote: `Bosque Overlay Navigation Hotfix v1`
- Versao: `0.0.18-alpha.0`
- Version code: `18`
- Minimum supported version code: `13`
- Release root: pendente de publicacao final.
- Preview: pendente de publicacao final.
- Hashes: pendentes de publicacao final.

## Riscos Residuais

- Keystore Android release nao configurado; Internal Alpha segue permitindo `debug_fallback`, ja coberto pelo gate atual.
- Validacao manual Web/APK ainda deve confirmar sensacao de fechamento/retorno no pacote publicado.
