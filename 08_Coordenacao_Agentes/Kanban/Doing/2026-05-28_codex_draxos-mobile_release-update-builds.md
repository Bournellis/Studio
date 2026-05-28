# DraxosMobile - Release update builds

- Agente: Codex
- Branch: `codex/draxos-mobile/release-update-builds`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--release-update-builds`
- Objetivo: gerar e publicar builds atualizadas do Internal Alpha para site, Web, Android APK e Windows ZIP.
- Base lida: `AGENTS.md`, `Projetos/draxos-mobile/AGENTS.md`, `docs/internal-alpha-v0-handoff.md`, `docs/internal-alpha-release-plan.md`, scripts `export_internal_alpha.ps1`, `publish_internal_alpha.ps1` e `build_cloudflare_pages_package.ps1`.
- Arquivos pretendidos: correção pontual de warnings no presenter do Refúgio, relatório/status de publicação se necessário e artefatos gerados em `build/` não versionados.
- Validação planejada: `validate.gd`, `smoke_mobile_presentation.gd`, `smoke_battle_replay.gd`, `smoke_exports.gd`, export internal alpha, publish Supabase, pacote/deploy Cloudflare Pages, smoke remoto/manifest e `git diff --check`.
- Observação: a publicação deve ser feita a partir desta worktree limpa para não empacotar `assets/referenciaimagens/`, que é moodboard local e não asset runtime.
