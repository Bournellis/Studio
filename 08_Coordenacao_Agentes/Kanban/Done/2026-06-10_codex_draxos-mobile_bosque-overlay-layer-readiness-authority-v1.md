# Bosque Overlay Layer And Readiness Authority v1

- Data: 2026-06-10
- Agente: Codex
- Branch: `codex/draxos-mobile/bosque-overlay-layer-readiness-authority-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-overlay-layer-readiness-authority-v1`
- Projeto: `Projetos/draxos-mobile`

## Objetivo

Corrigir a falha estrutural do overlay do Bosque onde Arena/duelo e confirmacoes podiam competir com o painel do menu, alem de tornar explicita a prontidao de menus que dependem de refresh do servidor.

Etapa alvo:

- Nome: `Bosque Overlay Layer And Readiness Authority v1`
- Status local: `BOSQUE_OVERLAY_LAYER_READINESS_AUTHORITY_V1_IMPLEMENTED_LOCAL`
- Status publicado: `BOSQUE_OVERLAY_LAYER_READINESS_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`
- Versao publicada: `0.0.23-alpha.0`
- Version code publicado: `23`
- Minimum supported version code: `13`

## Mudancas Entregues

- Overlay do Bosque passou a ter camadas explicitas para menu, Arena fullscreen, modal global e diagnosticos.
- Arena active/replay aberta pelo Bosque passa para camada fullscreen acima do painel de menu, evitando corte lateral do duelo.
- Confirmacoes de abandono da Arena e confirmacoes de loja usam autoridade modal global acima de menu e Arena.
- Rotas do overlay agora publicam fase `opening`, `refreshing`, `ready`, `mutating` ou `critical` e bloqueiam cliques cedo demais com feedback visivel.
- Diagnostico Web foi expandido com camada superior, retangulos, prontidao, modal, Arena fullscreen e motivo de input ignorado.
- Smokes Web foram reforcados para provar controle topmost por coordenada real, e nao apenas existencia de botao.

## Arquivos Alterados

- `Projetos/draxos-mobile/modes/boot/ui/mode_shell_overlay_controller.gd`
- `Projetos/draxos-mobile/modes/boot/boot_runtime_navigation_controller.gd`
- `Projetos/draxos-mobile/modes/boot/boot_runtime_surface_api.gd`
- `Projetos/draxos-mobile/modes/boot/boot_runtime_status_controller.gd`
- `Projetos/draxos-mobile/modes/boot/boot_runtime_action_dispatcher.gd`
- `Projetos/draxos-mobile/tools/smoke_web_overlay_menu_actions.ps1`
- `Projetos/draxos-mobile/tools/smoke_web_overlay_controls.ps1`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- Versionamento, manifesto, release function, docs/status vivos e guards de live-doc foram atualizados para o pacote publicado.

## Validacoes Locais

- `git diff --check`: passou antes dos commits de runtime.
- `validate_foundation.ps1 -Profile ClientQuick`: passou com 279 testes GUT e 4143 asserts.
- `smoke_web_overlay_menu_actions.ps1` local em Web export: passou para Account, Base, Shop, Social, Arena fullscreen e abandono topmost.
- `validate_foundation.ps1 -Profile DocsOnly -NoProjectWrites`: passou apos fechamento documental.
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: passou apos fechamento documental.
- `deno test --allow-read server/tests/release_auth_contract_test.ts`: passou, incluindo fallback da release root atual.
- `check_release_safety.ps1`: passou.
- `check_android_release_keystore.ps1 -Mode InternalAlpha`: passou com aviso esperado de release keystore ausente e fallback debug permitido para Internal Alpha.

## Publicacao

- Release root publicado: `internal-alpha/v0-bosque-overlay-layer-readiness-authority-v1-20260610-181861c`
- URL preview: `https://a9e3b2f9.draxos-mobile-internal-alpha.pages.dev`
- URL oficial: `https://draxos-mobile-internal-alpha.pages.dev/`
- Web direto oficial: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- APK SHA256: `986bff2ac180de883f5dfa97078e0a3ff31e2c0d4de139b8863c18e1d37507ab`
- PC ZIP SHA256: `4659da781b027dcb1c9f1b5d6ec32e56630eac14160413a35cb75a90c2e8c0dc`
- Web Index SHA256: `0f6e3e655367df73f9a6d3ba2ee5a4e205b487bbda03a108ec9fc6db3a7bd73b`

## Validacoes Remotas

- Preview hash carregou `window.DRAXOS_WEB_RELEASE` com `0.0.23-alpha.0` e release root publicado.
- Smoke remoto de launch passou na preview com cache disabled.
- Smoke remoto de overlay/menu action passou na preview, incluindo Social typing, Shop confirm/cancel/confirm, Arena retomar/abandonar, Arena fullscreen topmost, modal topmost, voltar e fechar.
- URL oficial/estavel retornou Cloudflare Access em automacao anonima; validacao oficial exige sessao autenticada/manual.

## Riscos Residuais

- URL oficial pode exigir sessao Cloudflare Access para smoke automatizado autenticado.
- Keystore de release Android continua nao configurado; Internal Alpha segue permitido com fallback debug quando explicitamente autorizado.
- Playtest humano ainda deve validar a sensacao real de Arena fullscreen sem corte lateral, modal global/topmost e prontidao de menus em ambiente autenticado.
