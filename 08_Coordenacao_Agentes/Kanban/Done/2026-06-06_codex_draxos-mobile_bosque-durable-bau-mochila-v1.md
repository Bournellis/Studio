# DraxosMobile - Bosque Durable Bau Mochila v1

- Data: `2026-06-06`
- Agente: `codex`
- Branch: `codex/draxos-mobile/bosque-durable-bau-mochila-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-durable-bau-mochila-v1`
- Status: `DONE_PUBLISHED_INTERNAL_ALPHA`

## Objetivo

Implementar persistencia duravel de Bau, Mochila/Bolso, upgrades e estruturas do Bosque por save, preservando runtime offline-first e reward server-authoritative.

## Resultado

- Backend adicionou `openworld_forest_progress_v1` em `mode_progress.progress_payload`.
- `mode_session_start_v1` injeta progresso duravel em nova visita e mantem nodes coletados como estado da visita.
- `mode_session_checkpoint_v1` grava progresso duravel aceito junto do snapshot da sessao.
- `mode_session_complete_v1` faz merge duravel e nao apaga Bau, Mochila/Bolso, upgrades ou estruturas.
- Cliente separou `openworld_active_session_cache` e `openworld_durable_progress_cache`.
- `complete_session` limpa somente cache de visita ativa.
- Bosque mantem `Bau`, `Mochila/Bolso`, capacidade e estruturas apos sair/reabrir, completar e iniciar nova visita.
- Documentacao de Openworld, contratos, status e coordenacao foi atualizada.

## Publicacao

- Release root: `internal-alpha/v0-bosque-durable-bau-mochila-v1-20260606-6e7ca6b`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Preview evidence: `https://39198a35.draxos-mobile-internal-alpha.pages.dev`
- APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-durable-bau-mochila-v1-20260606-6e7ca6b/downloads/draxos-mobile-alpha.apk`
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-durable-bau-mochila-v1-20260606-6e7ca6b/downloads/draxos-mobile-alpha.zip`
- Version: `0.0.6-alpha.0`
- Version code: `6`
- Android export mode: `debug_fallback`

## Validacao

- Deno mode/domain/ruleset tests: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- Godot `tools/validate.gd`: PASS, 237 tests.
- Supabase dry-run and remote migration apply: PASS.
- Edge Functions `modes` and `release` deploy: PASS.
- Export/package/upload/deploy manifest: PASS.
- Cloudflare Pages deploy branch `main`: PASS.
- Remote Web launch smoke: PASS.
- RemoteReadOnly final: PASS after final docs guard update.

## Proximo Passo

Playtest humano focado em Bau, Mochila/Bolso, upgrades e estruturas apos sair/reabrir, completar visita, atualizar APK/Web e reentrar. Manter regressao da Arena PVE Menu Flow Simplification v1.
