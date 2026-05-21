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

Saidas:

- `docs/battle-lab/generated/battle_lab_report.html`
- `docs/battle-lab/generated/battle_lab_summary.json`
- `docs/battle-lab/generated/battle_lab_matchups.csv`
- `docs/battle-lab/generated/battle_lab_builds.csv`
- `docs/battle-lab/generated/battle_lab_archetypes.csv`
- `docs/battle-lab/generated/battle_lab_power_bands.csv`
- `docs/battle-lab/generated/battle_lab_outliers.csv`
- `docs/battle-lab/generated/battle_lab_checks.csv`

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
3. `Archetypes`: identifica dominancia ou colapso por arquetipo.
4. `Level And Power Bands`: mostra onde a escala quebra por level/faixa.
5. `Outliers`: lista matchups reproduziveis por `matchup_id`, `seed` e build
   IDs.

## Regra De Tuning

Nao ajuste numeros direto depois de uma unica luta manual. Primeiro gere
baseline, revise outliers, escolha uma hipotese pequena, ajuste poucos
parametros em outra tarefa, regenere o relatorio e compare antes/depois.
