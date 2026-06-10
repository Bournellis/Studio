# Bosque Arena Abandon Recovery Authority v1

- Status: `DONE`
- Agente: Codex
- Data: `2026-06-10`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/bosque-arena-abandon-recovery-authority-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-arena-abandon-recovery-authority-v1`
- Resultado: `BOSQUE_ARENA_ABANDON_RECOVERY_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`

## Objetivo

Corrigir estruturalmente o cancelamento/abandono de tentativa ativa da Arena dentro do overlay do Bosque, tratando a falha como problema de contrato de estado, verificacao pos-mutacao e recuperacao de tentativa local antiga, nao como clique pontual.

## Entrega

- Publicado `Bosque Arena Abandon Recovery Authority v1`.
- Version: `0.0.22-alpha.0`
- Version code: `22`
- Minimum supported version code: `13`
- Release root: `internal-alpha/v0-bosque-arena-abandon-recovery-authority-v1-20260610-a252241`
- Preview validado: `https://b149da8f.draxos-mobile-internal-alpha.pages.dev`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`

## Artefatos

- APK SHA256: `10cdc2bc4f7ea25db7c05be917efe0a0d73baa1047b01311748857e6637dfc99`
- PC ZIP SHA256: `ff63afa6b605d699d101a4a9eb5177f98cd994e155445d0ba2ccbdbbac49fb13`
- Web Index SHA256: `5f5faac20e9798cc84fd47cee9a6c2f36ab6407a1d1ff9d8ae4ee735f023bce9`

## Arquivos Alterados

- Runtime Arena/client shell: `arena_surface_presenter.gd`, `arena_lifecycle_flow.gd`, `boot_runtime_action_dispatcher.gd`, `boot_runtime_status_controller.gd`, `boot_runtime_state.gd`, `boot_runtime_navigation_controller.gd`, `arena_dev_fixture_provider.gd`, `session_store.gd`.
- Backend mirror: `server/functions/arena/index.ts`, `supabase/functions/arena/index.ts`.
- Release/version: `core/project_info.gd`, export/publish/smoke scripts, release Edge Function mirrors, manifest fallback and release tests.
- Tests/smokes: `test_boot_mobile_ui.gd`, `test_project_info.gd`, `smoke_responsive_layout.gd`, release manifest/auth tests.
- Docs/status/coordenacao: project/root AGENTS, README/status docs, contracts, hardening program, portfolio snapshots and this Done card.

## Validacoes Executadas

- `git diff --check`
- `deno check` para release functions/tests
- `validate_foundation.ps1 -Profile DocsOnly -NoProjectWrites`
- `validate_foundation.ps1 -Profile ClientQuick`
- `validate_foundation.ps1 -Profile ServerQuick`
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites` depois de mover o card para Done
- `check_release_safety.ps1`
- `check_android_release_keystore.ps1 -Mode InternalAlpha`
- Package/export local e `publish_internal_alpha.ps1` com `-ConfirmRemoteMutation`
- Cloudflare Pages deploy para preview hash
- `smoke_web_launch_remote.ps1` contra o preview com release root esperado
- `smoke_web_overlay_controls.ps1` contra o preview
- `smoke_web_overlay_menu_actions.ps1` contra o preview, cobrindo Arena active -> confirmar abandono -> selection liberada

## Publicacao

- `release` foi redeployada e o manifest remoto passou a recomendar `0.0.22-alpha.0`.
- O preview hash publico carregou o jogo, bateu release root e passou os smokes remotos.
- A URL oficial continua sendo o contrato player-facing, mas validacao anonima automatizada cai em Cloudflare Access; validar a URL oficial com sessao autenticada/cache disabled.

## Riscos Residuais

- APK usa `debug_fallback` enquanto a keystore release dedicada nao estiver configurada.
- Official Portal/Web pode exigir Cloudflare Access; preview hash segue como evidencia tecnica publica.
- Playtest humano ainda precisa confirmar a conta real e cenarios de tentativa remota longa, apesar do smoke remoto cobrir abandono liberando selection.

## Commits

- `a252241 Fix Bosque Arena abandon recovery authority`
- `fc5a603 Prepare Bosque Arena abandon recovery release root`
- `6dd0571 Fix responsive Arena active smoke fixture`
- commit final de publicacao/documentacao nesta branch antes do merge seguro em `main`
