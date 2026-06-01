# Track 20 - Season 1 Arena Calibration

- Status: `PUBLISHED_INTERNAL_ALPHA`
- Data: `2026-05-31`
- Branch de integracao: `codex/draxos-mobile/s1-arena-calibration-integration`
- Base: `codex/draxos-mobile/season1-arena-tuning-definitions`

## Objetivo

Transformar a matriz de arenas da Season 1 em fonte operacional para labs, backend e cliente. Esta track calibra as primeiras batalhas e o scaling PVE da primeira temporada sem alterar formulas globais de combate, XP, `players.power`, armas, spells, Doutrinas, Familiares, pocoes novas ou assets.

## Escopo

- Corrigir contratos/dados para que todos os tiers apontem para inimigos, arenas e recompensas existentes.
- Gerar catalogo PVE compartilhado para `server/functions` e `supabase/functions`.
- Fazer Battle Lab e Progression Lab consumirem `pve_arena_difficulties.json`.
- Rodar baseline e calibragem offline da Season 1.
- Promover backend e cliente para `arena_id + difficulty_id` data-driven.
- Validar, publicar e empacotar uma Internal Alpha remota para playtest humano.

## Nao Objetivos

- Tuning fino final da Season 1.
- Alterar formulas globais de combate, XP ou power.
- Criar armas, spells, passivas, familiares, pocoes ou assets.
- Reintroduzir PVP como core inicial.
- Publicacao remota sem aprovacao explicita e `-ConfirmRemoteMutation`.

## Gate De Saida

- Dados e catalogo gerado consistentes.
- Labs geram linhas para todos os tiers S1.
- Nenhum tier fica `CRITICAL`; `REVIEW` aspiracional deve estar documentado.
- Runtime inicia arena por `arena_id:difficulty_id`.
- Rewards first-clear/repeat usam chave por tier.
- Cliente lista dificuldades vindas do servidor.
- Gates locais, migrations/functions remotas, pacote Internal Alpha e manifest
  publicados.

## Entrega Atual

- Dados: 27 tiers S1, recompensas explicitamente referenciadas e progression
  targets de 40 leveis.
- Catalogo: `tools/generate_pve_arena_catalog.ts` gera os mirrors de
  `server/functions/_shared/pve_arena_catalog.ts` e
  `supabase/functions/_shared/pve_arena_catalog.ts`.
- Labs: Battle Lab e Progression Lab leem a matriz S1 e arquivaram baseline em
  `docs/battle-lab/runs/2026-05-31_s1_arena_baseline_v01` e
  `docs/progression-lab/runs/2026-05-31_s1_arena_baseline_v01`.
- Runtime: `arena/pve/state` e `arena/pve/start` usam `arena_id + difficulty_id`;
  first clear/repeat usa metadata `completed_tiers`.
- Cliente: Arena renderiza dificuldades vindas do servidor e emite
  `arena_start:<arena_id>:<difficulty_id>`.

## Validacao Local

- Deno `server/functions` check: PASS.
- Deno `supabase/functions` check: PASS.
- Deno dados/schema Arena + ruleset: PASS.
- Deno Battle Lab + Progression Lab: PASS.
- Godot `tools/validate.gd`: PASS (`138/138`, `2368` asserts).
- GUT client: PASS (`138/138`, `2368` asserts).
- `tools/smoke_responsive_layout.gd`: PASS.
- `git diff --check`: PASS.
- `tools/validate_foundation.ps1 -Profile Quick`: PASS.
- `tools/export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `tools/publish_internal_alpha.ps1 -Mode Plan`: PASS.
- `tools/publish_internal_alpha.ps1 -Mode Package`: PASS.

## Publicacao Remota

- Publish dir: `build/internal-alpha/publish`.
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
- Android export mode: `debug_fallback`; keystore release ainda nao configurada.
- Remote migrations: PASS after repairing the initial Arena table drift; pending
  migrations `202605310002` and `202605310003` applied.
- Edge Functions: `arena`, `lab-runner` and `release` deployed.
- Remote smokes: `release_manifest_smoke`, `release_artifacts_remote_smoke` and
  `internal_alpha_remote_smoke` PASS.
