# DraxosMobile - Battle Lab

Battle Lab e o workflow local para calibrar o combate do DraxosMobile sem mexer
nos numeros no escuro.

## Objetivo

- Rodar batalhas offline em massa com o mesmo simulador `FIRST_SLICE_SIM` usado
  pelo servidor.
- Testar builds fixas e randomicas deterministicas em diferentes checkpoints de
  level e poder.
- Encontrar batalhas curtas demais, longas demais, anti-stall frequente, stomps
  e arquetipos dominantes.
- Apresentar os dados em HTML, CSV e JSON para orientar tuning posterior.

## Workflow

1. Rodar o gerador:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts
```

Para arquivar uma run oficial e comparar com uma anterior:

```powershell
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --archive-run 2026-05-21_archetype_source_tuning_v02 --compare-with 2026-05-21_pacing_alpha_v01
```

2. Abrir `generated/battle_lab_report.html`.
3. Ler primeiro os checks e outliers.
4. Escolher uma hipotese pequena de tuning.
5. Alterar numeros de combate em uma tarefa separada.
6. Rodar o Battle Lab de novo e comparar relatorios.

## Artefatos

- `generated/battle_lab_report.html`: painel principal para leitura humana.
- `generated/battle_lab_summary.json`: dados completos do baseline.
- `generated/battle_lab_matchups.csv`: uma linha por batalha.
- `generated/battle_lab_builds.csv`: builds e seeds reproduziveis.
- `generated/battle_lab_archetypes.csv`: agregados por arquetipo.
- `generated/battle_lab_source_by_archetype.csv`: dano causado por fonte e
  arquetipo.
- `generated/battle_lab_near_power_matrix.csv`: matriz somente com matchups de
  ate 20% de diferenca de poder, sem espelhos do mesmo arquetipo.
- `generated/battle_lab_history_index.csv`: indice das runs oficiais
  arquivadas.
- `generated/battle_lab_compare.csv`: deltas entre a run atual e a run passada
  via `--compare-with`.
- `generated/battle_lab_power_bands.csv`: agregados por level e power band.
- `generated/battle_lab_outliers.csv`: problemas priorizados.
- `generated/battle_lab_checks.csv`: criterios PASS/REVIEW/CRITICAL.
- `runs/`: historico versionado de runs oficiais de balanceamento. `generated/`
  e sempre a visao atual sobrescrita.

## Contrato

- A ferramenta e offline.
- A ferramenta nao chama Supabase.
- A ferramenta nao cria jogador.
- A ferramenta nao aplica recompensa.
- A ferramenta nao altera ranking, recursos ou progresso.
- A ferramenta nao muda numeros de combate; isso pertence a uma etapa posterior
  de tuning.

## Como Usar Os Dados

- Se muitas lutas caem abaixo de 12s, revisar burst, dano de varinha/spells ou
  HP por level.
- Se muitas lutas passam de 32s ou acionam anti-stall, revisar defesa, barreira,
  sustain, DoTs fracos ou dano global.
- Se um arquetipo passa de 65% de win rate em `near_power_dominance`, revisar
  primeiro matchups e fonte de dano antes de nerfar globalmente.
- Se o problema aparece apenas em `raw_stress_dominance`, tratar como estresse
  de builds/power, nao como prova isolada de nerf.
- Se o problema aparece so em um level/power band, preferir ajuste de scaling em
  vez de alterar valor base.
- Use `runs/index.json` para decidir proximos testes: compare deltas de duracao,
  dominancia por poder proximo e fonte dominante antes de abrir nova hipotese.

## Tuning Atual

Ultima rodada: `2026-05-21_archetype_source_tuning_v02`.

Mudanca aplicada:

- Battle Lab passou a arquivar runs oficiais em `docs/battle-lab/runs/` e gerar
  comparacao contra baseline anterior.
- Dominancia principal agora usa matchups de poder proximo (`<= 20%`) e exclui
  espelhos do mesmo arquetipo.
- `raio` e `odio` tiveram dano direto reduzido.
- DoTs de Fogo, Veneno e Sangramento receberam aumento leve de tick.
- Pets tiveram dano base/escala reduzidos.

Resultado Battle Lab:

| Metrica | Pacing v01 | Tuning v02 |
|---|---:|---:|
| Duracao media | 18.19s | 18.91s |
| Batalhas curtas | 2.38% | 0% |
| Batalhas longas | 0% | 0% |
| Anti-stall | 0.12% | 0.12% |
| Dominancia bruta maxima | 88.1% | 77.62% |
| Dominancia poder proximo maxima | 79.37% | 70.45% |
| Status geral | CRITICAL | REVIEW |

Leitura:

- O pacing global segue dentro da janela operacional `18s-28s`.
- `burst_caster` saiu de dominancia critica em poder proximo (`76.13%` para
  `60%`).
- `pet_handler` caiu de `79.37%` para `70.45%` em poder proximo, ainda em
  REVIEW e candidato a proxima rodada fina.
- `dot_pressure` melhorou de `26.87%` para `33.45%`, mas ainda pede observacao.
- A proxima rodada deve focar ajuste fino de pet/poder/DoT, nao HP global.

Validacoes rodadas:

```powershell
npx -y deno test server/tests/first_slice_simulator_test.ts
npx -y deno test tools/battle_lab
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --archive-run 2026-05-21_archetype_source_tuning_v02 --compare-with 2026-05-21_pacing_alpha_v01
cd server/functions
npx -y deno task check
npx -y deno task lint
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
```
