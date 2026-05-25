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

2. No Godot editor, abrir `Refugio -> Battle Lab Dev` quando quiser testar
   builds visualmente.
3. Gerar scratch runs para ensaios locais ou runs oficiais para tuning
   versionado.
4. Ler primeiro os checks, outliers e matriz de poder proximo.
5. Assistir amostras de replay ou gerar replay custom por build.
6. Escolher uma hipotese pequena de tuning.
7. Alterar numeros de combate em uma tarefa separada.
8. Rodar o Battle Lab de novo e comparar relatorios.

## Artefatos

- `generated/battle_lab_report.html`: painel principal para leitura humana.
- `generated/battle_lab_summary.json`: dados completos do baseline.
- `generated/battle_lab_ui.json`: resumo compacto para a UI Godot.
- `generated/battle_lab_replays.json`: amostras com `battle_log_v1` completo
  para replay visual.
- `generated/battle_lab_matchups.csv`: uma linha por batalha.
- `generated/battle_lab_progression_matrix.csv`: matriz dos healthy saves do
  Progression Lab contra bots, perfis e arquetipos quando
  `docs/progression-lab/generated/progression_summary.json` existe.
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
- `.battle_lab_scratch/`: runs locais ignoradas pelo Git.

## Contrato

- A ferramenta e offline.
- A ferramenta nao chama Supabase.
- A ferramenta nao cria jogador.
- A ferramenta nao aplica recompensa.
- A ferramenta nao altera ranking, recursos ou progresso.
- Quando o Progression Lab ja foi gerado, a ferramenta importa apenas os JSONs
  locais de saves/bots saudaveis para simular combate; continua offline.
- A ferramenta nao muda numeros de combate; isso pertence a uma etapa posterior
  de tuning.
- A tela Godot e dev-only: aparece apenas no editor e os exports excluem
  `dev/**`, `tools/battle_lab/**`, `docs/battle-lab/**` e scratch outputs.
- Runs antigas recebem metadados de compatibilidade. Quando simulador, conteudo
  ou modelo mudam, elas aparecem como `stale` em vez de desaparecer.

## Battle Lab Dev No Godot

Use para ver o combate enquanto ajusta numeros e arte:

- `Run`: gera `generated/`, scratch ou run oficial.
- `Builds`: editor visual completo de level, arma, qualidade, spells, passiva e
  pet.
- `Analytics`: checks e outliers da ultima run.
- `Replay`: arena debug 2D com HP, marcadores de pet/summon/status, step,
  play/pause e velocidade.
- `History`: resumo da run e comparacao carregada.

O Godot chama Deno por `draxos_mobile/battle_lab/deno_command` e
`draxos_mobile/battle_lab/deno_prefix_args`. O padrao local e `npx -y deno run
--allow-read --allow-write`.

## Como Usar Os Dados

- Se muitas lutas caem abaixo de 12s, revisar burst, dano de Instrumento/spells ou
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

Ultima rodada viva: rework de personagem `2026-05-25`.

Mudanca aplicada:

- Battle Lab passou a usar Instrumentos Rituais, Doutrinas e Familiares.
- A taxonomia de dano foi migrada para
  Arcano/Fisico/Fogo/Agua/Gelo/Terra/Vento/Raio/Veneno/Sangue/Morte.
- Mental deixou de ser dano e virou familia de status para medo, terror,
  confusao e compulsao.
- O gerador agora valida `weapon_id`/`weaponId` nos builds, CSVs e bridge Godot.
- Archetypes antigos foram substituidos por `starter_instrument`,
  `mental_controller`, `elemental_mixer`, `familiar_handler`, `summoner`,
  `defensive_occultist`, `dot_pressure` e `funeral_burst`.

Leitura:

- O baseline 2026-05-21 permanece arquivado como historico pre-rework.
- Deltas numericos contra runs antigas devem ser lidos como alerta de
  compatibilidade, nao como prova direta de balanceamento.
- A proxima rodada de tuning deve medir dominancia por Instrumento/Familiar,
  intensidade de status mental e pressao de Sangue/Veneno/Morte.

Validacoes rodadas:

```powershell
npx -y deno test server/tests/first_slice_simulator_test.ts
npx -y deno test tools/battle_lab
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --compare-with 2026-05-21_archetype_source_tuning_v02
cd server/functions
npx -y deno task check
npx -y deno task lint
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_exports.gd
```
