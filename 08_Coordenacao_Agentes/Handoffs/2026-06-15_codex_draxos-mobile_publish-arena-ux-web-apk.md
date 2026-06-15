# Handoff - DraxosMobile Arena UX Web+APK

- Data: 2026-06-15
- Agente: Codex
- Branch: `codex/draxos-mobile/publish-arena-ux-web-apk`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--publish-arena-ux-web-apk`
- Pacote: `Arena UX Readability Recovery v1`
- Versao: `0.0.24-alpha.0` / vc `24`
- Release root: `internal-alpha/v0-arena-ux-readability-recovery-v1-20260615-52c870c7`

## Publicacao

- Portal estavel: `https://draxos-mobile-internal-alpha.pages.dev/`
- Web estavel: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Preview validado: `https://101e1ff7.draxos-mobile-internal-alpha.pages.dev`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- APK protegido: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/download?artifact=android`
- PC ZIP protegido: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/download?artifact=pc_windows`

## Evidencias

- APK SHA256: `664dd0d93891220fb1f03e77fb43c2f11fa41fa94c26590182c19d9f4d14b97a`
- PC ZIP SHA256: `9b0fc25e2ac9f770c74a033a7ad9e133ac76ea46f4e03d32763b37b0e57f69e6`
- Web index SHA256: `cca1cba35ec2b5c67de9497af40014d77e2d868a43b978acc301b3031ef9d985`
- Remote Web smoke: `game_loaded`, release root correto, assets chave 200, sem runtime errors.
- Diagnostico local do ultimo smoke: `C:\Users\Fabio\AppData\Local\Temp\draxos-mobile-web-launch-remote-20260615-064608`

## Validacoes Executadas

- `ClientQuick`: PASS
- `ServerQuick`: PASS
- `ReleaseDryRun`: PASS
- `RemoteReadOnly` com `-AllowCloudflareAccess`: PASS
- Upload Supabase Storage: PASS
- Deploy Cloudflare Pages: PASS
- Deploy manifest/function release: PASS

## Proximo Passo

Fabio/tester deve executar a prova humana em `Projetos/draxos-mobile/docs/arena-pve-product-proof.md` usando o pacote publicado. Registrar o veredito antes de tuning, economia, PVP, conteudo novo, visual final ou expansao Openworld.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
