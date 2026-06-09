# Bosque Overlay Interaction Authority v1

- Data: 2026-06-09
- Agente: Codex
- Branch: `codex/draxos-mobile/bosque-overlay-interaction-authority-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-overlay-interaction-authority-v1`
- Base: `main` em `bfbcb62`
- Status final: `BOSQUE_OVERLAY_INTERACTION_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`

## Objetivo

Corrigir a falha estrutural do overlay persistente do Bosque em Web: menus simples abriam sobre o Bosque, mas `Fechar`, `Voltar` e Esc podiam parecer inertes para o usuario. A etapa separou navegacao de overlay de acoes mutantes/busy, provou interacao real Web/canvas e publicou novo Internal Alpha.

## Publicacao

- Pacote: `Bosque Overlay Interaction Authority v1`
- Version: `0.0.19-alpha.0`
- Version code: `19`
- Minimum supported version code: `13`
- Release root: `internal-alpha/v0-bosque-overlay-interaction-authority-v1-20260609-a8aa9a0`
- Preview evidence: `https://1ee9e2a0.draxos-mobile-internal-alpha.pages.dev`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK SHA256: `acffb52c8ff149b215e86de0e713603018b97ec6b9cd06cea530caa58b1e1f7c`
- PC Windows ZIP SHA256: `72110533a1096a39b53efe55129f066032dc43ad58e5b6e5cbca27556756a34b`
- Web Index SHA256: `3f4ef706182d8e4bfd2905e0a3a41a175e4cb429ccb3d59fe5663f094b970b55`

## Problemas Resolvidos

- Acoes de landmark do Bosque para Account/Base/Shop/Social/Arena abrem rota de overlay sem cair no dispatcher generico como acao mutante.
- `Fechar`, `Voltar` e Esc passam por uma unica autoridade de fechamento/back.
- Refresh read-only de menus nao bloqueia fechamento.
- Respostas tardias depois de fechar/mudar rota sao ignoradas por epoch/rota.
- Overlay recebe foco, z-order e mouse handling adequados para Web/canvas.
- Smoke local e remoto clicou/pressionou controles reais no canvas; nao depende apenas de `pressed.emit()` ou chamada direta de `_input()`.
- `window.DRAXOS_WEB_RELEASE` e o pacote Web publicado expõem release root/version/code para diagnostico.

## Arquivos Alterados

- Runtime: `boot_runtime_action_dispatcher.gd`, `boot_runtime_navigation_controller.gd`, `boot_runtime_status_controller.gd`, `mode_shell_overlay_controller.gd`
- Testes/smokes: `test_boot_mobile_ui.gd`, `tools/smoke_web_overlay_controls.ps1`
- Release/versionamento: `project.godot`, `export_presets.cfg`, `ProjectInfo.gd`, `export_internal_alpha.ps1`, `publish_internal_alpha.ps1`, `build_cloudflare_pages_package.ps1`, release function mirrors, remote smoke tests
- Docs/status: `implementation/current-status.md`, `AGENTS.md`, `README.md`, `docs/agent-operating-manual.md`, `docs/documentation-index.md`, `docs/hardening-program.md`, `docs/minigames/openworld.md`, `docs/contracts/*`, `docs/product-*`, `docs/design-pending.md`, portfolio root docs

## Validacoes Executadas

- `git diff --check`: OK
- `validate_foundation.ps1 -Profile DocsOnly -NoProjectWrites`: OK antes da publicacao; rerodado apos docs finais no fechamento
- `validate_foundation.ps1 -Profile ClientQuick`: OK, 271 testes / 4012 asserts, smokes client incluidos
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: OK
- `check_release_safety.ps1`: OK
- `check_android_release_keystore.ps1 -Mode InternalAlpha`: OK com `debug_fallback`
- Export/package local Internal Alpha: OK
- Smoke Web overlay local por coordenadas reais: OK (`overlay_controls_passed`)
- Cloudflare Pages deploy: OK, preview `https://1ee9e2a0.draxos-mobile-internal-alpha.pages.dev`
- Remote Web launch smoke no preview: OK, release root casou
- Remote overlay controls smoke no preview: OK, `Fechar`, `Voltar` e Esc fecharam overlay por input real Web/canvas
- `RemoteReadOnly` com preview e `-AllowCloudflareAccess`: OK
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`: OK, `publication-report.json` gerado

## Riscos Residuais

- Stable Portal/Web continuam protegidos por Cloudflare Access para validacao anonima; a evidencia tecnica primaria e o preview hash publico e a validacao oficial deve usar sessao autenticada/cache disabled.
- APK usa `debug_fallback` enquanto a keystore release dedicada nao estiver configurada; aceito para esta Internal Alpha fechada.
- `FullPublish` executou upload/deploy de storage e funcao, mas a checagem estatica do dominio estavel nao passa anonimamente sob Cloudflare Access; o fechamento usou deploy de Cloudflare Pages + smokes no preview + DeployManifest report.
- O proximo passo continua sendo playtest humano focado do pacote publicado; bugs futuros voltam ao fluxo normal.
