# DraxosMobile - Ossos Inteiros v1

## Status

- Estado: `DONE`
- Branch: `codex/draxos-mobile/integer-bones`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--integer-bones`
- Resultado: pacote implementado, validado, publicado e preparado para merge em `master`.

## Entrega

- Corrigida a coleta de Ossos no runtime de Base para preservar accrual sub-unitario e so atualizar `last_collected_at` quando houver pelo menos `1` Osso inteiro coletavel.
- `collectableFor()` agora arredonda Ossos para baixo com `Math.floor`, mantendo outros recursos no arredondamento existente.
- Catalogos Grimoire regenerados com Ossos inteiros: Ossario `200/dia`, derrota `4`, vitoria `20`, primeira vitoria `100`, treino MVP `100`, battle pass free `6000` e premium `12000`.
- Smoke remoto de Grimoire passou a validar valores inteiros no catalogo publicado.
- Downloads Internal Alpha voltaram a URLs publicas unlisted no Storage para evitar erro direto de Bearer token no APK.
- Web publicado com root versionado `internal-alpha/v0-integer-bones-20260529` para evitar cache antigo de `index.js`, `index.pck` e `index.wasm`.

## Publicacao

- Supabase migration remota `202605280001_behavior_crafting.sql`: aplicada.
- Edge Functions: redeploy de `healthcheck account battle base social competition build crafting content monetization telemetry progression-lab release`.
- Storage roots publicados:
  - `internal-alpha/v0`
  - `internal-alpha/v0-integer-bones-20260529`
- Cloudflare Pages preview: `https://d7a31bf6.draxos-mobile-internal-alpha.pages.dev`.
- Manifest remoto: atualizado com hashes novos e downloads publicos.

## Validacao

- `integer_bones_contract_test.ts`: PASS.
- Deno check de `base/content` mirrors e teste novo: PASS.
- `foundation_contracts_test.ts` + `integer_bones_contract_test.ts`: PASS.
- `validate_foundation.ps1 -Profile Client`: PASS.
- `validate_foundation.ps1 -Profile Quick`: PASS.
- Remote smokes: `base_manager_smoke.ts`, `monetization_rewards_smoke.ts`, `grimoire_catalog_smoke.ts`, `first_slice_battle_smoke.ts`: PASS.
- Export Internal Alpha: PASS, Android mode `debug_fallback`.
- Cloudflare Pages deploy: PASS.
- Remote release smokes: `release_manifest_smoke.ts`, `release_artifacts_remote_smoke.ts`, `internal_alpha_remote_smoke.ts`, `grimoire_catalog_smoke.ts`: PASS.
- Direct APK HEAD sem Bearer token: PASS (`200`, `31629333`, `application/vnd.android.package-archive`).
- Preview Web cache-bust checks: PASS para `GODOT_CONFIG`, root versionado, `index.js`, `index.pck` e `index.wasm`.

## Proximo passo

Revisar manualmente Android/Windows/Web confirmando que Base, recompensas e Grimoire nao exibem `0.1 osso`, depois escolher Battle Presentation v1 ou outro pacote explicito.
