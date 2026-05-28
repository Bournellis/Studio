# DraxosMobile - Release update builds

- Agente: Codex
- Branch: `codex/draxos-mobile/release-update-builds`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--release-update-builds`
- Objetivo: gerar e publicar builds atualizadas do Internal Alpha para site, Web, Android APK e Windows ZIP.
- Base lida: `AGENTS.md`, `Projetos/draxos-mobile/AGENTS.md`, `docs/internal-alpha-v0-handoff.md`, `docs/internal-alpha-release-plan.md`, scripts `export_internal_alpha.ps1`, `publish_internal_alpha.ps1` e `build_cloudflare_pages_package.ps1`.
- Arquivos pretendidos: correção pontual de warnings no presenter do Refúgio, relatório/status de publicação se necessário e artefatos gerados em `build/` não versionados.
- Validação planejada: `validate.gd`, `smoke_mobile_presentation.gd`, `smoke_battle_replay.gd`, `smoke_exports.gd`, export internal alpha, publish Supabase, pacote/deploy Cloudflare Pages, smoke remoto/manifest e `git diff --check`.
- Observação: a publicação deve ser feita a partir desta worktree limpa para não empacotar `assets/referenciaimagens/`, que é moodboard local e não asset runtime.

## Resultado

- `tools/validate.gd`: passou com GUT `98/98` e `1208` asserts.
- `smoke_mobile_presentation.gd`, `smoke_foundation_hardening.gd`, `smoke_exports.gd`: passaram.
- Checks Deno de `supabase/functions` e `server/functions`: passaram.
- Edge Function `battle` redeployada para atualizar `/battle/history` e `/battle/replay` no remoto.
- `smoke_battle_replay.gd`: passou contra o Supabase remoto Internal Alpha.
- Export Internal Alpha: gerou Android APK, PC Windows ZIP e Web export; APK em modo `debug_fallback`.
- Publish Supabase: Storage/manifest atualizados e `release` redeployada.
- Cloudflare Pages: deploy concluido em `https://36b1d46c.draxos-mobile-internal-alpha.pages.dev`.
- Smokes remotos `release_manifest_smoke.ts` e `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`: passaram.
- Observacao operacional: `https://draxos-mobile-internal-alpha.pages.dev` esta protegido por Cloudflare Access e retorna tela de login para checagem anonima publica.
