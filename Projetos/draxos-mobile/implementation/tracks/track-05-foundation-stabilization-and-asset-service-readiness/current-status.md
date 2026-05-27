# Track 05 - Current Status

- Last Updated: `2026-05-27`
- Status: `ACTIVE_FOUNDATION_STABILIZATION`
- Depends On: `T04_A_TO_H_INTEGRATED`
- Next Action: run T05-B to T05-G in parallel worktrees, then integrate through T05-H.

## Estado

Track 05 is active as a foundation stabilization track. Internal Alpha v0 passed, Track 04 integrated Hub render-only presenters, and the next step is to make the project easier to validate, extend with assets and prepare for future service work without changing gameplay behavior.

No final art, new service, economy tuning, schema migration or gameplay expansion is approved in this track.

## Ordem Atual

1. `T05-A` Coordenacao: create Track 05 docs, update portfolio/status and register prompts.
2. `T05-B` Validation Matrix: quick/full/release/remote validation and focused smokes.
3. `T05-C` Hub Foundation: harden Hub/presenter ownership without behavior changes.
4. `T05-D` Service Contracts: classify endpoint/service scope without schema changes.
5. `T05-E` Asset Pipeline: prepare asset conventions, ids and fallback tests.
6. `T05-F` Progression Human Pack: prepare human review before tuning.
7. `T05-G` Release Ops: checklist for manifest/export/publication readiness without publishing.
8. `T05-H` Integracao: merge, validate and update final status.

## Guardrails

- Do not edit directly in `D:\Estudio` for implementation.
- Do not create `account_profiles` + `game_saves`.
- Do not change economy, combat, reward, bot, shop or power numbers.
- Do not import final assets.
- Do not publish builds or mutate remote release state from Track 05 worktrees.

## Validation Baseline

Documentation-only packages:

```powershell
git diff --check
```

Client packages:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
git diff --check
```

Backend/test packages:

```powershell
cd <WORKTREE>\Projetos\draxos-mobile
npx -y deno task check --cwd supabase/functions
npx -y deno task check --cwd server/functions
git diff --check
```

## Fontes

- Escopo: `scope.md`
- Plano: `implementation-plan.md`
- Prompts: `agent-prompts.md`
- Track 04 status: `../track-04-post-handoff-hardening-and-hub-modularization/current-status.md`
- Product vision: `../../../docs/product-vision.md`
- Design pending: `../../../docs/design-pending.md`
