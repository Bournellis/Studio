# Bosque Overlay Interactive Controls Authority v1

- Agente: Codex
- Branch: `codex/draxos-mobile/bosque-overlay-interactive-controls-authority-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-overlay-interactive-controls-authority-v1`
- Projeto: `Projetos/draxos-mobile`
- Status: `BOSQUE_OVERLAY_INTERACTIVE_CONTROLS_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`

## Resultado

Publicado o pacote Internal Alpha `Bosque Overlay Interactive Controls Authority v1` para corrigir a interacao real dos controles internos do overlay do Bosque no Web/APK, sem alterar backend, schema, economia, tuning, recompensas, conteudo ou contratos HTTP.

O pacote preserva o Bosque vivo e visivel atras de Account/Base/Shop/Social/Arena, pausa o input do mundo durante o overlay, e corrige:

- Social: foco/texto em `LineEdit` dentro do overlay e clique em acoes sociais.
- Shop: confirmacao propria do overlay, com cancelar/confirmar e retorno no mesmo painel.
- Arena: `Retomar tentativa` e `Abandonar tentativa` dentro do stack do overlay.
- Regressao: `Fechar`, `Voltar`, Esc, Account check update, Base sync, Shop refresh, Social refresh e retorno ao Bosque.

## Publicacao

- Version: `0.0.21-alpha.0`
- Version code: `21`
- Minimum supported version code: `13`
- Release root: `internal-alpha/v0-bosque-overlay-interactive-controls-authority-v1-20260609-d3be1fb`
- Preview: `https://9461e4be.draxos-mobile-internal-alpha.pages.dev`
- Official URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- APK SHA256: `fc4f414d7c1f769a0505c2ff9cef01ad919a149f28279c4ffc13cf56ce2aa06c`
- PC ZIP SHA256: `a0621dcd27c1fa6d78f0e4c4a393b1f5ee21a2138901eba170f7558aeea94c9f`
- Web Index SHA256: `c954e026276d0d0d03dc38e382689daf5ef3e5e9ea7b15caac08057bdb6ddff9`

`release` foi redeployada no Supabase e os artefatos foram enviados ao Storage. A URL oficial anonima continua protegida por Cloudflare Access; a evidencia tecnica automatizada primaria e o preview hash acima.

## Validacoes Executadas

- `git diff --check`
- GUT client alvo: `test_boot_mobile_ui.gd` + `test_project_info.gd` passou com `278` testes e `4098` asserts.
- `deno test --allow-read server/tests/release_auth_contract_test.ts` passou.
- `tools/check_release_safety.ps1` passou.
- `tools/check_android_release_keystore.ps1 -Mode InternalAlpha` passou com aviso conhecido de `debug_fallback`.
- `validate_foundation.ps1 -Profile ClientQuick` passou.
- Web local interactive smoke passou para Account/Base/Shop/Social/Arena, Social typing, Shop cancel/confirm e Arena resume/abandon.
- Cloudflare Pages deploy passou para `https://9461e4be.draxos-mobile-internal-alpha.pages.dev`.
- Remote Web launch smoke passou no preview com release root esperado.
- Remote overlay menu-actions smoke passou no preview, incluindo Social typing/click, Shop confirmavel e Arena retomar/abandonar.
- Official URL smoke anonimo retornou `cloudflare_access_expected`, confirmando bloqueio por Cloudflare Access sem sessao autenticada.

## Arquivos Alterados

- Runtime/shell: `modes/boot/ui/mode_shell_overlay_controller.gd`, `modes/boot/boot_runtime_navigation_controller.gd`, `modes/boot/boot_runtime_action_dispatcher.gd`, `modes/boot/boot_runtime_surface_api.gd`, `modes/boot/surfaces/arena_surface_presenter.gd`.
- Testes/smoke/release: `tools/smoke_web_overlay_menu_actions.ps1`, `tools/export_internal_alpha.ps1`, `tools/publish_internal_alpha.ps1`, `tools/validate_foundation.ps1`, release function mirrors and release contract tests.
- Status/docs: `implementation/current-status.md`, `README.md`, `AGENTS.md`, `docs/agent-operating-manual.md`, `docs/documentation-index.md`, `docs/hardening-program.md`, `docs/product-vision.md`, `docs/product-brief.md`, `docs/minigames/openworld.md`, `docs/contracts/update-manifest.md`, portfolio/status root docs.

## Riscos Residuais

- Official stable URL exige sessao Cloudflare Access para validacao humana/autenticada; smoke anonimo so valida o bloqueio esperado.
- Android usa `debug_fallback`, aceito para Internal Alpha funcional; assinatura release dedicada segue adiada.
- Smokes remotos exercitam conta/save de Internal Alpha e rotas controladas; playtest humano ainda deve validar sensacao, texto real de feedback e estados remotos variaveis.
- Nenhuma expansao de Social, Shop, Arena ruleset, economia, PVP, conteudo, tuning ou Openworld amplo foi aprovada por este pacote.

## Proximo Passo

Playtest humano focado do pacote publicado, validando Social typing/actions, Shop cancel/confirm, Arena retomar/abandonar, `Fechar`, `Voltar`, Esc e regressao de craft/check update/sync. Bugs futuros voltam ao fluxo normal de bugfix.
