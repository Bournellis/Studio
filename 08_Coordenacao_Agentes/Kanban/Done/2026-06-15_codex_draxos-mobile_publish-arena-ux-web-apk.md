# DraxosMobile Done: publish Arena UX Web+APK

## Metadata

- data: `2026-06-15`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `release`
- mode_scope: `autobattler`
- branch: `codex/draxos-mobile/publish-arena-ux-web-apk`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--publish-arena-ux-web-apk`
- status: publicado e validado remotamente; merge local pendente no fechamento da rodada.

## Resultado

- Pacote publicado: `Arena UX Readability Recovery v1`
- Versao: `0.0.24-alpha.0` / version code `24`
- Release root: `internal-alpha/v0-arena-ux-readability-recovery-v1-20260615-52c870c7`
- Preview evidence: `https://101e1ff7.draxos-mobile-internal-alpha.pages.dev`
- Portal estavel: `https://draxos-mobile-internal-alpha.pages.dev/`
- Web estavel: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- APK: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/download?artifact=android`
- PC ZIP companion: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/download?artifact=pc_windows`

## Evidencias

- APK SHA256: `664dd0d93891220fb1f03e77fb43c2f11fa41fa94c26590182c19d9f4d14b97a`
- PC ZIP SHA256: `9b0fc25e2ac9f770c74a033a7ad9e133ac76ea46f4e03d32763b37b0e57f69e6`
- Web index SHA256: `cca1cba35ec2b5c67de9497af40014d77e2d868a43b978acc301b3031ef9d985`
- Cloudflare Pages deploy: `https://101e1ff7.draxos-mobile-internal-alpha.pages.dev`
- Remote Web launch smoke: `game_loaded`, release root correto, `index.pck` e `index.wasm` 200, sem runtime errors.
- Stable Portal/Web podem retornar Cloudflare Access; a prova automatizada publica usa o preview hash.

## Validacao

- `validate_foundation.ps1 -Profile ClientQuick`: PASS
- `validate_foundation.ps1 -Profile ServerQuick`: PASS
- `validate_foundation.ps1 -Profile ReleaseDryRun`: PASS
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`: PASS
- `wrangler pages deploy`: PASS
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`: PASS
- `validate_foundation.ps1 -Profile RemoteReadOnly -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS

## Guardrails

- Publicacao feita por aprovacao explicita do usuario para viabilizar prova humana.
- Arena core continua `ARENA_CORE_NEEDS_UX_FIX` + `ARENA_CORE_NOT_PROVEN` ate Fabio registrar veredito.
- Nao abrir tuning, economia, PVP, conteudo novo, visual final ou expansao Openworld antes da prova humana.
- APK usa `debug_fallback` enquanto a keystore release dedicada nao estiver configurada.
- PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
