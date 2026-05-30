# DraxosMobile - Lab Track 16 Alignment

- Data: 2026-05-30
- Agente: Codex
- Branch/worktree: `codex/draxos-mobile/foundation-expansion-readiness` em `D:\Estudio-worktrees\draxos-mobile--codex--foundation-expansion-readiness`
- Objetivo: atualizar Battle Lab e Progression Lab para cobrir pocoes, comportamento, crafting e contexto de ruleset antes de qualquer tuning.
- Status: entregue.

## Entrega

- Battle Lab cobre cenarios Track 16 com potion behavior default, potion disabled e spell behavior disabled.
- Battle Lab gerado ficou em `REVIEW` por anti-stall `6.4%` contra threshold `<=5%`; isso e evidencia de tuning, nao mudanca automatica.
- Progression Lab gera saves com `po_osso`, `craft_pocao_vida`, `pocao_vida`, potion slot, inventory e spell behaviors.
- Progression Lab apply/seeder preservam consumables, slots e behaviors gerados nos snapshots lab.
- Telas dev dos labs aceitam e validam potion slot e behavior.
- Docs/runbooks/contrato de labs foram atualizados para marcar essa cobertura como lab-only.

## Validacao

- `npx -y deno test tools/battle_lab tools/progression_lab`: PASS.
- `npx -y deno test --allow-read server/tests/lab_heuristics_contract_test.ts`: PASS.
- `npx -y deno check server/functions/progression-lab/index.ts supabase/functions/progression-lab/index.ts tools/progression_lab/seed_supabase.ts`: PASS.
- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- GUT client focado nos labs: PASS (`132/132`, `2057` asserts; com noise conhecido de ObjectDB/orphans no exit).
- `tools/smoke_dev_labs.gd`: PASS.
- `validate_foundation.ps1 -Profile Quick`: PASS; o gate primeiro capturou drift de `content_hash` do ruleset na migration closeout, que foi corrigido e revalidado.

## Handoff

- Proximo pacote deve escolher explicitamente base builder tuning, autobattler tuning, social expansion ou minigame shell/contract.
- Labs alinhados podem orientar tuning, mas nao promovem valores sozinhos.
