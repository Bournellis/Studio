# Bosque Overlay Navigation Hotfix v1

- Data: `2026-06-09`
- Agente: Codex
- Branch: `codex/draxos-mobile/bosque-overlay-nav-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-overlay-nav-hotfix-v1`
- Projeto: `Projetos/draxos-mobile`
- Base: `main` em `6da9ab7`
- Estado: publicado como novo Internal Alpha Web/APK; handoff final registrado nesta branch.

## Objetivo

Corrigir a regressao reportada no teste Web do pacote `Bosque Overlay Navigation Hotfix v1`: menu/overlay abria, mas o usuario nao conseguia fechar, voltar nem usar Esc. A correcao foi tratada como revisao estrutural da implementacao de overlay/back/close/input, nao como ajuste pontual.

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
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/design-pending.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/contracts/update-manifest.md`
- `Projetos/draxos-mobile/portal/internal-alpha/manifest.example.json`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- `Projetos/README.md`
- `AGENTS.md`

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
- `validate_foundation.ps1 -Profile ReleaseDryRun`: OK.
- `publish_internal_alpha.ps1 -Mode FullPublish -ConfirmRemoteMutation`: artefatos exportados, enviados ao Supabase Storage, secrets de release aplicados e funcao `release` redeployada. O smoke de Portal no dominio estavel encontrou Cloudflare Access, esperado para este ambiente.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: OK, preview `https://92cc0579.draxos-mobile-internal-alpha.pages.dev`.
- Preview Portal `https://92cc0579.draxos-mobile-internal-alpha.pages.dev/`: HTTP 200 e contem `DraxosMobile`.
- Preview Web `https://92cc0579.draxos-mobile-internal-alpha.pages.dev/web/index.html`: HTTP 200, contem `GODOT_CONFIG` e release root publicado.
- `smoke_web_launch_remote.ps1` no preview com timeout 180s: OK.
- `validate_foundation.ps1 -Profile RemoteReadOnly -IncludeRemoteReadOnly -RemoteWebUrl "https://92cc0579.draxos-mobile-internal-alpha.pages.dev/web/index.html" -ExpectedReleaseRoot "internal-alpha/v0-bosque-overlay-navigation-hotfix-v1-20260609-9b93e5d" -NoProjectWrites`: OK; Web launch remoto carregou em 3711 ms durante validacao consolidada.
- Deno release smoke direto com `DRAXOS_EXPECTED_RELEASE_ROOT` e `DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS=1`: OK, 4 passed / 0 failed.

## Publicacao

- Pacote: `Bosque Overlay Navigation Hotfix v1`
- Versao: `0.0.18-alpha.0`
- Version code: `18`
- Minimum supported version code: `13`
- Release root: `internal-alpha/v0-bosque-overlay-navigation-hotfix-v1-20260609-9b93e5d`.
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`.
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`.
- Preview evidence: `https://92cc0579.draxos-mobile-internal-alpha.pages.dev`.
- Android APK SHA256: `80d30c54f315d2a0681374ae603a33d8c4cb19759b3bb3262752ccc7f06624d8`.
- PC Windows ZIP SHA256: `4fa2fba1505d4dfe97e365923209b3ea76c7601a8e9f03da6bf2da8828357de0`.
- Web Index SHA256: `33244df3094513af49d57b3b6f9bc32e755b66671926c92db9baaffc3905db55`.

## Riscos Residuais

- Keystore Android release nao configurado; Internal Alpha segue permitindo `debug_fallback`, ja coberto pelo gate atual.
- Validacao manual Web/APK ainda deve confirmar sensacao de fechamento/retorno no pacote publicado em aparelho/browser humano.
- Stable Portal/Web ficam atras de Cloudflare Access neste ambiente; preview Pages foi usado como evidencia publica de conteudo e Web launch.
