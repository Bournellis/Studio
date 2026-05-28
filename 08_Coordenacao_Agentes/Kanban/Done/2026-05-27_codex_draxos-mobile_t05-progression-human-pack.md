# T05-F Progression Human Pack

- Data: 2026-05-27
- Agente: Codex
- Projeto: `Projetos/draxos-mobile`
- Branch: `codex/draxos-mobile/t05-progression-human-pack`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t05-progression-human-pack`
- Status: `READY_FOR_INTEGRATION`

## Objetivo

Preparar a rodada humana do Progression Lab antes de qualquer tuning numerico, com runbook/checklist para perfis e milestones de `2h`, `5h`, `10h`, `15h` e `20h`.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/docs/progression-lab/`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/progression-human-pack.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/current-status.md`
- Esta nota Doing

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/implementation-plan.md`
- `Projetos/draxos-mobile/docs/progression-lab/README.md`
- `Projetos/draxos-mobile/docs/progression-lab/2026-05-27-t04-progression-economia.md`

## Validacao Planejada

- `npx -y deno test tools/progression_lab`
- `npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts`
- `npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t05-progression-human-pack\Projetos\draxos-mobile -s res://tools/smoke_dev_labs.gd`
- `git diff --check`

## Validacao Executada

- `npx -y deno test tools/progression_lab`: passou, `4/4`.
- `npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts`: passou, `25` saves, `75` bots, status `REVIEW`, `11` itens de review.
- `npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all`: passou, `25/25` saves selecionados.
- `smoke_dev_labs.gd`: passou com `[smoke-dev-labs] OK Battle Lab bridge + Progression Lab generate`; avisos pre-existentes de parse/autoload apareceram antes do OK, sem falha de exit code.
- `git diff --check`: passou.

## Guardrails

- Nao alterar numeros de economia, poder, bots, loja, recompensas ou combate.
- Nao publicar remoto, nao migrar schema e nao alterar save model.
- Tuning numerico fica para tarefa separada apos rodada humana.

## Proximo Handoff

Entregar runbook/checklist T05-F, criterios de decisao e validacoes para integracao posterior em T05-H.

## Resultado

- Runbook humano criado para os perfis e milestones obrigatorios.
- Casos foco, criterios de decisao e ficha de registro definidos.
- Nenhum numero de economia, poder, bot, loja, recompensa, recurso ou combate foi alterado.
- Validacao confirmada para `deno test tools/progression_lab`, `seed_supabase.ts --dry-run --all`, `smoke_dev_labs.gd` e `git diff --check`.
