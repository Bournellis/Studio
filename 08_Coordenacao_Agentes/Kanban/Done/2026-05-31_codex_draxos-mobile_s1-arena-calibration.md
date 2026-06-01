# Codex - DraxosMobile S1 Arena Calibration

- Data: `2026-05-31`
- Projeto: `Projetos/draxos-mobile`
- Track: `Track 20 - Season 1 Arena Calibration`
- Status: `DONE_PUBLISHED_INTERNAL_ALPHA`
- Branch: `codex/draxos-mobile/s1-arena-calibration-integration`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--s1-arena-calibration-integration`
- Base: `codex/draxos-mobile/season1-arena-tuning-definitions` (`912776a`)

## Objetivo

Promover a matriz de arenas da Season 1 para fonte real de labs e runtime, calibrar a primeira temporada sem alterar formulas globais de combate/XP/power e preparar um pacote jogavel de Arena PVE data-driven.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/data/definitions/*arena*`
- `Projetos/draxos-mobile/data/generated/foundation_ruleset_v0.json`
- `Projetos/draxos-mobile/tools/generate_pve_arena_catalog.ts`
- `Projetos/draxos-mobile/tools/generate_foundation_ruleset.ts`
- `Projetos/draxos-mobile/tools/battle_lab/*`
- `Projetos/draxos-mobile/tools/progression_lab/*`
- `Projetos/draxos-mobile/server/functions/_shared/pve_arena_catalog.ts`
- `Projetos/draxos-mobile/supabase/functions/_shared/pve_arena_catalog.ts`
- `Projetos/draxos-mobile/server/functions/arena/index.ts`
- `Projetos/draxos-mobile/supabase/functions/arena/index.ts`
- Client Godot Arena flow and tests touched by `difficulty_id`.
- Track/status/docs touched only as needed for handoff.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`

## Validacao Planejada

- `git diff --check`
- `npx -y deno test --allow-read server/tests/pve_arena_difficulties_test.ts`
- `npx -y deno test --allow-read --allow-write tools/battle_lab tools/progression_lab`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- Godot `tools/validate.gd`
- GUT client
- `tools/smoke_responsive_layout.gd`
- `tools/validate_foundation.ps1 -Profile Quick`
- Antes de publicar: `tools/validate_foundation.ps1 -Profile Full -RequireClean`
- `tools/publish_internal_alpha.ps1 -Mode Plan`
- `tools/publish_internal_alpha.ps1 -Mode Package`

## Handoff

Entregar branch limpa com relatorio de calibragem, tiers em `REVIEW` documentados, pacote Internal Alpha local e proximos testes humanos recomendados.

## Progresso

- Dados/contratos: S1 progression targets, rewards por tier e ruleset gerado.
- Catalogo: gerador PVE criado e mirrors server/supabase gerados.
- Labs: Battle Lab e Progression Lab consomem `pve_arena_difficulties.json` e
  arquivam baseline `2026-05-31_s1_arena_baseline_v01`.
- Calibragem: 27/27 tiers Arena S1 em `PASS`; sem `CRITICAL`.
- Backend: runtime Arena usa `arena_id + difficulty_id`; repeat/first-clear usa
  `arena_id:difficulty_id`; claim continua read-only.
- Cliente: selecao de Arena lista dificuldades server-driven e envia
  `difficulty_id`.

## Validacao Executada

- `npx -y deno task check` em `server/functions`: PASS.
- `npx -y deno task check` em `supabase/functions`: PASS.
- Deno tests de dados/catalogo/ruleset/arena consistency: PASS (`10/10`).
- Deno tests Battle Lab + Progression Lab: PASS (`21/21`).
- Godot `tools/validate.gd`: PASS (`138/138`, `2368` asserts).
- GUT client: PASS (`138/138`, `2368` asserts).
- `tools/smoke_responsive_layout.gd`: PASS.
- `git diff --check`: PASS.
- `tools/validate_foundation.ps1 -Profile Quick`: PASS.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS, Android
  export mode `debug_fallback`.
- `tools/publish_internal_alpha.ps1 -Mode Plan`: PASS.
- `tools/publish_internal_alpha.ps1 -Mode Package`: PASS, local package at
  `Projetos/draxos-mobile/build/internal-alpha/publish`.
- `tools/validate_foundation.ps1 -Profile Full -RequireClean`: PASS before
  publication.
- Remote deploy fix: `202605310001_arena_pve_initial.sql` repaired to keep
  `ruleset_id` as text and use `ruleset_publication_id` as FK.
- Remote database: Arena initial tables repaired; migrations `202605310002` and
  `202605310003` pushed.
- Edge Functions: `arena`, `lab-runner` and `release` deployed.
- `tools/publish_internal_alpha.ps1 -Mode Upload -PublicDownloads
  -ConfirmRemoteMutation`: PASS.
- `tools/build_cloudflare_pages_package.ps1`: PASS.
- `npx -y wrangler pages deploy`: PASS, preview
  `https://c20c0ff3.draxos-mobile-internal-alpha.pages.dev`.
- `tools/publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads
  -ConfirmRemoteMutation`: PASS.
- Remote smokes: release manifest, artifacts and Internal Alpha PASS.

## Publicacao

- Release root:
  `internal-alpha/v0-s1-arena-calibration-20260531-c40c2a6`.
- Portal:
  `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`.
- Web:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`.
- Preview:
  `https://c20c0ff3.draxos-mobile-internal-alpha.pages.dev`.
- Android APK: `31762404` bytes,
  SHA256 `6c84aea08f9731d6449c9aca8186695020161a4fd688f0f0a59c24a952b1286d`.
- PC Windows ZIP: `40221978` bytes,
  SHA256 `aab5adad9064f869b01ffe92c8d7244a0ec36be7253839d09ef1765364050992`.
- Web Index: `5442` bytes,
  SHA256 `63bfb9aa4f79882413ff0b462f6420630cfedcdca825ba41b44ff51d65f6caff`.
- Manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`.

## Fechamento

- Card movido para `Done` apos commit local `ce16029`.
- Gate Full inicial falhou apenas por cards obsoletos em `Doing`; ambos foram
  arquivados em `Done` para repetir o gate com worktree limpa.
- Publicacao remota executada apos aprovacao explicita do usuario.
