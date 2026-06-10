# Bosque Overlay Menu Action Authority v1 - Handoff

- Data: 2026-06-09
- Agente: Codex
- Branch: `codex/draxos-mobile/bosque-overlay-menu-action-authority-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-overlay-menu-action-authority-v1`
- Status: `BOSQUE_OVERLAY_MENU_ACTION_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`

## Resultado

Publicado novo Internal Alpha `Bosque Overlay Menu Action Authority v1` para transformar o overlay do Bosque em superficie interativa completa. O Bosque permanece vivo e visivel atras de Account/Base/Shop/Social/Arena, input do mundo continua pausado durante overlay, e os controles internos agora executam no contexto do overlay sem recriar o `mode_shell`.

## Publicacao

- Version: `0.0.20-alpha.0`
- Version code: `20`
- Minimum supported version code: `13`
- Release root: `internal-alpha/v0-bosque-overlay-menu-action-authority-v1-20260609-aa9402d`
- Preview evidence: `https://5f04e6ae.draxos-mobile-internal-alpha.pages.dev`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK SHA256: `1f3aa89eebdf6296dca222f3d0f128feb532dd26a315245d5cbc4dc9c39f0da2`
- PC ZIP SHA256: `024d402d8355bea0d92b7b8b77de7c7a30cdda16724064fe92872cc35c2a9920`
- Web Index SHA256: `6f668a968a7f18d5a2b55ed753a7f61b767875f25c64a8b0d10a62cd5beb9596`

## Bug Reproduzido

- O pacote `0.0.19-alpha.0` conseguia fechar o overlay, mas botoes internos dos menus nao executavam no teste Web.
- O primeiro preview `0.0.20` tambem revelou uma falha real de escala/dispatch no Pages: o canvas CSS podia estar em dimensoes diferentes do viewport Godot, e o smoke remoto provou que o clique interno nao chegava ao action dispatcher.

## Correcoes

- Botoes internos do overlay passam a ter autoridade por contexto do overlay em `boot_runtime_action_dispatcher.gd`.
- `mode_shell_overlay_controller.gd` aceita comando Web por caminho de botao real visivel/habilitado, sem depender do rect visual dentro de `ScrollContainer`.
- `boot_runtime_navigation_controller.gd` publica diagnosticos `window.DRAXOS_GODOT_STATE`, faz ponte Web para `pointerdown` e `mousedown`, normaliza coordenadas do canvas para viewport Godot e registra a ultima acao real.
- Smokes remotos cobrem CTAs internos: Account `Checar update`, Base `Sincronizar Refugio`, Shop `Atualizar loja`, Social `Atualizar social`, Arena `Voltar ao Refugio`.
- Smokes remotos tambem cobrem `Fechar`, `Voltar` e Esc.

## Validacoes Executadas

- GUT client: `274/274`, `4029` asserts.
- `validate_foundation.ps1 -Profile ServerQuick`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick`: PASS antes da republicacao final; GUT foi reexecutado apos o ajuste Web.
- `tools/smoke_web_overlay_menu_actions.ps1` local: PASS para `aa9402d`.
- `tools/smoke_web_overlay_menu_actions.ps1` remoto preview `https://5f04e6ae...`: PASS.
- `tools/smoke_web_overlay_controls.ps1` remoto preview `https://5f04e6ae...`: PASS.
- `tools/build_cloudflare_pages_package.ps1`: PASS.
- `npx -y wrangler@latest pages deploy ... --branch main`: PASS, preview `https://5f04e6ae.draxos-mobile-internal-alpha.pages.dev`.
- `tools/publish_internal_alpha.ps1 -Mode FullPublish ... -ConfirmRemoteMutation`: executou upload, manifest secret e deploy da funcao `release`; o assert textual final do Portal falhou em request anonimo porque a URL oficial redireciona para Cloudflare Access.

## Riscos Residuais

- URL oficial anonima esta protegida por Cloudflare Access; automacao sem sessao nao valida o dominio estavel. Preview hash publico e release root injetado sao a evidencia automatizada.
- APK Android segue em `debug_fallback` ate a keystore release dedicada ser configurada.
- Playtest humano ainda precisa confirmar o fluxo autenticado na URL oficial e no APK.
