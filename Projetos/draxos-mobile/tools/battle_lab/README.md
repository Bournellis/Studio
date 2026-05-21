# Battle Lab

Ferramenta offline para gerar baseline de balanceamento do combate
`FIRST_SLICE_SIM`.

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
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --archive-run 2026-05-21_archetype_source_tuning_v02 --compare-with 2026-05-21_pacing_alpha_v01
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
- gera replay custom sob demanda;
- reproduz `battle_log_v1` em uma arena debug 2D.

O cliente Godot nao calcula resultado, dano ou recompensa. Ele apenas monta o
pedido, chama Deno local e apresenta o log retornado.

Os exports excluem `dev/**`, `tools/battle_lab/**`, `docs/battle-lab/**` e
`.battle_lab_scratch/**`.

## Configurar

Edite `model.v1.json`.

Campos principais:

- `levels`: checkpoints de progressao testados.
- `random_builds_per_archetype_per_level`: volume de variantes deterministicas
  por arquetipo.
- `thresholds`: janelas de duracao, anti-stall e dominancia.
- `archetypes`: preferencias de spells, passivas, pets e ratios de level por
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

O baseline gerado em `docs/battle-lab/generated/` ja inclui a rodada
`2026-05-21_archetype_source_tuning_v02`.

Resumo:

- duracao media: `18.91s`;
- batalhas curtas: `0%`;
- batalhas longas: `0%`;
- anti-stall: `0.12%`;
- status geral: `REVIEW` por `pet_handler` ainda acima de 65% em poder
  proximo;
- `burst_caster`: `60%` em poder proximo, fora de critical;
- `pet_handler`: `70.45%` em poder proximo, ainda em review.

Proximo foco recomendado: investigar `pet_handler`, lacuna de `dot_pressure` e
formula/pesos de poder usando `battle_lab_source_by_archetype.csv`,
`battle_lab_near_power_matrix.csv` e `battle_lab_compare.csv`.
