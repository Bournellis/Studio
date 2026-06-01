# Track 19 - Arena Consistency Pass

- Data: `2026-05-31`
- Agente coordenador: Codex
- Branch de integracao: `codex/draxos-mobile/arena-consistency-pass`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-consistency-pass`
- Base: `codex/draxos-mobile/pve-arena-integration`
- Status: `ENTREGUE_LOCAL`

## Objetivo

Alinhar a entrega Track 18 PVE Arena Initial antes do tuning fino: consumo de
pocao na Arena, semantica de claim, endpoint publico de buff, selecao de arenas
data-driven, docs vivos, ruleset, labs e sanity targets.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/server/functions/arena/index.ts`
- `Projetos/draxos-mobile/supabase/functions/arena/index.ts`
- `Projetos/draxos-mobile/server/schema/migrations/*.sql`
- `Projetos/draxos-mobile/modes/boot/**`
- `Projetos/draxos-mobile/online/**`
- `Projetos/draxos-mobile/tools/battle_lab/**`
- `Projetos/draxos-mobile/tools/progression_lab/**`
- `Projetos/draxos-mobile/data/definitions/pve_*.json`
- `Projetos/draxos-mobile/data/definitions/arena_*.json`
- `Projetos/draxos-mobile/docs/**`
- `Projetos/draxos-mobile/implementation/current-status.md`
- portfolio snapshots se o status observavel mudar.

## Docs Lidos

- `AGENTS.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/pve-arena-v1.md`
- `Projetos/draxos-mobile/docs/behavior-potion-crafting-v1.md`

## Plano De Validacao

- `git diff --check`
- Deno check em `server/functions` e `supabase/functions`
- testes Deno de labs e backend afetado
- Godot `validate.gd`
- GUT client
- `smoke_responsive_layout.gd`
- `validate_foundation.ps1 -Profile Full -RequireClean`
- `publish_internal_alpha.ps1 -Mode Plan`
- `publish_internal_alpha.ps1 -Mode Package`

## Handoff

Integrar subpacotes pequenos por dominio, manter espelhos `server/` e
`supabase/` sincronizados e publicar Internal Alpha apos gate completo.

## Resultado Local

- Backend, client, docs/contracts, ruleset, labs e smoke visual integrados na
  branch `codex/draxos-mobile/arena-consistency-pass`.
- Track 19 preserva Track 18 como ultima publicacao remota e entrega uma
  camada local de consistencia para playtest/package.
- Validacoes executadas antes do gate limpo: Deno check/test, Godot
  `validate.gd`, GUT client e `smoke_responsive_layout.gd`. O gate limpo deve
  ser rodado no commit final da branch antes de publicacao remota.
