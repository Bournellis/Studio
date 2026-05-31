# Battle Lab

Arena PVE sequence analysis powered by battle simulator.

Ela reutiliza `server/functions/_shared/battle_simulator.ts`, entao mede o mesmo
simulador usado pelo backend local. A ferramenta nao chama Supabase, nao cria
conta, nao aplica recompensa e nao altera estado autoritativo.

## Rodar

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts
```

Run oficial arquivada:

```powershell
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --archive-run 2026-05-25_initial_balance_v01 --compare-with 2026-05-21_archetype_source_tuning_v02
```

Run oficial atual:

```powershell
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --archive-run 2026-05-25_source_identity_balance_v02 --compare-with 2026-05-25_initial_balance_v01
```

Scratch de alinhamento Track 16 antes de tuning:

```powershell
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --scratch-run 2026-05-30_track16_lab_alignment_v01 --compare-with 2026-05-25_source_identity_balance_v02
```

Bridge usado pelo Godot dev-only:

```powershell
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --request user_request.json --response user_response.json
```

Scratch local fora do Git:

```powershell
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --scratch-run scratch_pet_review
```

Saidas:

- `docs/battle-lab/generated/battle_lab_report.html`
- `docs/battle-lab/generated/battle_lab_summary.json`
- `docs/battle-lab/generated/battle_lab_ui.json`
- `docs/battle-lab/generated/battle_lab_replays.json`
- `docs/battle-lab/generated/battle_lab_matchups.csv`
- `docs/battle-lab/generated/battle_lab_progression_matrix.csv`
- `docs/battle-lab/generated/battle_lab_builds.csv`
- `docs/battle-lab/generated/battle_lab_archetypes.csv`
- `docs/battle-lab/generated/battle_lab_power_bands.csv`
- `docs/battle-lab/generated/battle_lab_outliers.csv`
- `docs/battle-lab/generated/battle_lab_checks.csv`
- `docs/battle-lab/generated/battle_lab_source_by_archetype.csv`
- `docs/battle-lab/generated/battle_lab_near_power_matrix.csv`
- `docs/battle-lab/generated/battle_lab_history_index.csv`
- `docs/battle-lab/generated/battle_lab_compare.csv`
- `docs/battle-lab/runs/<run_id>/` para runs oficiais versionadas.
- `.battle_lab_scratch/<run_id>/` para ensaios locais ignorados pelo Git.

## Dentro Do Godot

No editor, com `draxos_mobile/battle_lab/enabled=true`, o Refugio mostra
`Battle Lab Dev`.

Essa tela:

- chama o runner Deno configurado em `project.godot`;
- gera scratch runs e runs oficiais;
- mostra resumo/checks/outliers;
- permite montar builds manualmente com validacao de unlock;
- permite ensaiar Pocao de Vida e desativacao simples da primeira spell em
  replay custom;
- gera replay custom sob demanda e registra esse resultado de sessao em Replay/History;
- reproduz `battle_log_v1` no `BattleVisualMockup`, o mesmo mockup usado pela
  tela Batalha do alpha, com palco 2D procedural, slots front/middle/back,
  efeitos temporarios e tooltips.

O cliente Godot nao calcula resultado, dano ou recompensa. Ele apenas monta o
pedido, chama Deno local e apresenta o log retornado.

Os exports excluem `dev/**`, `tools/battle_lab/**`, `docs/battle-lab/**` e
`.battle_lab_scratch/**`.

Quando `docs/progression-lab/generated/progression_summary.json` existe, o
runner tambem importa os healthy saves e bots do Progression Lab para gerar a
matriz `battle_lab_progression_matrix.csv`. Isso continua offline e nao chama
Supabase.

## Configurar

Edite `model.v1.json`.

Campos principais:

- `levels`: checkpoints de progressao testados.
- `random_builds_per_archetype_per_level`: volume de variantes deterministicas
  por arquetipo.
- `thresholds`: janelas de duracao, anti-stall e dominancia.
- `track16_scenarios`: cobertura lab-only de Pocao de Vida e comportamento
  simples. Nao muda tuning por si so.
- `arena_sequences`: saida projetada para tentativa de Arena PVE, com tutorial,
  arenas de 3/4/5/6 duelos, HP resetado por duelo e alvos de sanidade por
  comprimento.
- `archetypes`: preferencias de spells, Doutrinas, Familiares e ratios de level por
  build.

## Ler O Relatorio

Abra `docs/battle-lab/generated/battle_lab_report.html`.

Use nesta ordem:

1. `O Que Olhar Primeiro`: lista automatica dos checks e outliers mais
   importantes.
2. `Checks`: status geral do baseline.
3. `Near Power Archetypes`: identifica dominancia em poder proximo.
4. `Source By Archetype`: mostra quais fontes realmente sustentam cada build.
5. `Level And Power Bands`: mostra onde a escala quebra por level/faixa.
6. `Compare` e `Run History`: mostram deltas e historico oficial.
7. `Replay Samples`: use `battle_lab_replays.json` para ver logs completos de
   outliers e representantes no Godot.
8. `Outliers`: lista matchups reproduziveis por `matchup_id`, `seed` e build
   IDs.

## Regra De Tuning

Nao ajuste numeros direto depois de uma unica luta manual. Primeiro gere
baseline, revise outliers, escolha uma hipotese pequena, ajuste poucos
parametros em outra tarefa, regenere o relatorio e compare antes/depois.

## Baseline Atual

O baseline gerado em `docs/battle-lab/generated/` esta em Track 16 Lab
Alignment. Ele inclui a run oficial `2026-05-25_source_identity_balance_v02`, os
healthy saves do Progression Lab e cenarios lab-only de Pocao de Vida e
comportamento simples.

Resumo:

- batalhas/builds: `4644` / `244`;
- duracao media: `24.03s`;
- batalhas curtas: `0%`;
- batalhas longas: `16.86%`;
- anti-stall: `6.4%` (`REVIEW`, acima da meta lab `<= 5%`);
- dominancia em poder proximo: `63.34% max`;
- cenarios com pocao: `1492`; uso de pocao em `76.61%` dos matchups com slot
  equipado;
- cenarios com comportamento: `1238`;
- identidade de fonte: todos os checks em `PASS`;
- status geral: `REVIEW`;
- `funeral_burst`: sucessor do antigo burst caster apos o rework de Morte/Fogo;
- `familiar_handler`: sucessor do antigo pet handler com familiares por papel.

Proximo foco recomendado: validar manualmente impacto da Pocao de Vida em
anti-stall/sustain, `familiar_handler`, `funeral_burst`, `mental_controller`,
`defensive_occultist`, gap premium 10h e janelas 15h/20h usando
`battle_lab_source_by_archetype.csv`, `battle_lab_near_power_matrix.csv`,
`battle_lab_progression_matrix.csv`, `battle_lab_matchups.csv` e
`battle_lab_compare.csv`.
