# Track 02 - Implementation Plan

## Ordem De Execucao

1. Estabelecer documentacao da track e fazer commit proprio.
2. Criar `tools/progression_lab/model.v1.json`.
3. Criar gerador offline `tools/progression_lab/generate.ts`.
4. Criar testes Deno para modelo, milestones, perfis, saves saudaveis, bot pool e checks.
5. Criar seeder Supabase local `tools/progression_lab/seed_supabase.ts`.
6. Criar UI dev-only no Godot para preparar/carregar saves e abrir checklist.
7. Integrar Battle Lab com `healthy_saves.json`.
8. Atualizar status local e validacoes.

## Outputs Do Gerador

- `progression_summary.json`
- `healthy_saves.json`
- `milestone_profiles.csv`
- `reward_scaling_checks.csv`
- `premium_gap.csv`
- `power_recommendations.csv`
- `bot_pool.csv`
- `progression_report.html`

## Validacao

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno test tools/progression_lab
npx -y deno test tools/battle_lab
npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_exports.gd
```

Supabase local:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y supabase db reset
npx -y deno run --allow-net --allow-env --allow-read --allow-write tools/progression_lab/seed_supabase.ts --all
```

## Regra De Tuning

O Progression Lab mede e recomenda. Ajustes de combate, economia, bots ou poder devem ser feitos em tarefas separadas, sempre com relatorio before/after.
