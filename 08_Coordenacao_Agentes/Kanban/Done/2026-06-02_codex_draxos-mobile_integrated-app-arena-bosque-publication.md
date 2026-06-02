# DraxosMobile - Integrated App/Arena/Bosque Publication

- Data: `2026-06-02`
- Agente: `Codex`
- Status: `DONE`
- Projeto: `Projetos/draxos-mobile/`
- Branch base final: `master`
- Release root: `internal-alpha/v0-integrated-app-arena-bosque-20260602-99304ed`
- Production URL: `https://draxos-mobile-internal-alpha.pages.dev`
- Deployment evidence: `https://8f2829c0.draxos-mobile-internal-alpha.pages.dev`

## Escopo entregue

- Commitou e integrou os trabalhos recentes de App Responsiveness, Arena Loop
  Simplification/Feedback e Openworld Bosque Hardening V1.
- Corrigiu compatibilidade da migration Bosque para o schema remoto vivo de
  `mode_limit_policies`.
- Aplicou `supabase db push`, publicou Edge Functions, exportou Android/PC/Web,
  fez upload dos artefatos para Supabase Storage, publicou Cloudflare Pages e
  atualizou o manifest remoto.
- Atualizou os snapshots de portfolio e status observavel do Estudio.

## Evidencias

- `supabase db push`: passou.
- `supabase functions deploy --project-ref armxgipvnbbshzqawklw`: passou.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: passou,
  Android mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`: passou.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: passou.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`:
  passou.
- `smoke_web_launch_remote.ps1`: passou no preview, `outcome=game_loaded`,
  `loaded_after_ms=6737`.
- `release_artifacts_remote_smoke.ts`: passou; stable Portal/Web protegidos por
  Cloudflare Access como esperado.
- `internal_alpha_remote_smoke.ts` leve: passou healthcheck, CORS e manifest.
- `index.pck`: `4660188` bytes local/remoto.
- `index.wasm`: `37695054` bytes local/remoto.

## Proximo passo

Playtest humano do pacote integrado: login/cache refresh, primeira Arena real,
desbloqueio de proxima dificuldade e Bosque online start/event/deposit/complete.
