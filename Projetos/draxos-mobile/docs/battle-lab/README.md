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
- Cobrir Track 16 como evidencia lab-only: `pocao_vida`, slot de pocao,
  comportamento default de pocao e comportamento simples de spell.

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

Run oficial atual:

```powershell
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --archive-run 2026-05-25_source_identity_balance_v02 --compare-with 2026-05-25_initial_balance_v01
```

Scratch Track 16 recomendado antes de tuning:

```powershell
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --scratch-run 2026-05-30_track16_lab_alignment_v01 --compare-with 2026-05-25_source_identity_balance_v02
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
  Inclui `potion_uses`, `potion_enabled_sides`, `spell_behavior_rules` e
  `disabled_spell_behavior_rules`.
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
- Cenarios Track 16 sao cobertura de laboratorio. Eles nao liberam novos
  thresholds, novas pocoes, prioridades de spell ou comportamento por inimigo.
- A tela Godot e dev/internal-alpha gated: pode existir em builds de revisao quando
  `dev_tools_enabled` estiver ativo, mas nao e produto, nao aplica tuning
  autoritativo e nao deve aparecer em release publico.
- Runs antigas recebem metadados de compatibilidade. Quando simulador, conteudo
  ou modelo mudam, elas aparecem como `stale` em vez de desaparecer.

## Battle Lab Dev No Godot

Use para ver o combate enquanto ajusta numeros e arte:

- `Run`: gera `generated/`, scratch ou run oficial.
- `Builds`: editor visual completo de level, arma, qualidade, spells, passiva,
  pet, Pocao de Vida e desativacao simples da primeira spell para replay custom.
- `Analytics`: checks e outliers da ultima run.
- `Replay`: aba rolavel com palco procedural 2D, HP, marcadores de
  pet/summon/status, slots front/middle/back, numeros flutuantes, step,
  play/pause e velocidade. Esta aba usa o mesmo `BattleVisualMockup` da tela
  Batalha para evitar divergencia entre replay real e replay de laboratorio.
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

## Baseline Atual

Ultima rodada viva versionada: `2026-05-25_source_identity_balance_v02`.
Generated atual: Track 16 Lab Alignment, regenerado em `2026-05-30` sem tuning
numerico.

Resultado:

- Status geral: `REVIEW`.
- Batalhas/builds: `4644` / `244`.
- Duracao media: `24.03s`.
- Anti-stall: `6.4%`, acima da meta lab `<= 5%`.
- Dominancia em poder proximo: `63.34% max`, dentro da meta `<= 65%`.
- Cenarios com pocao: `1492` matchups; `76.61%` dos matchups com pocao
  equipada tiveram uso de consumivel.
- Healing medio em matchup com uso de pocao: `225.14`.
- Cenarios com comportamento de spell: `1238`; com comportamento desativado:
  `644`.
- Checks de identidade de fonte continuam cobertos; o unico check em `REVIEW`
  no generated atual e `anti_stall_rate`.

Mudanca aplicada:

- Battle Lab v4 adiciona checks de identidade por fonte: arma nao pode dominar
  arquetipos nao-starter e Mental/Elemental/Familiar/Summoner/DoT/Funeral precisam
  aparecer no mix de dano.
- Poder inicial foi realinhado: arma pesa menos, spells e Familiar pesam mais
  para o matchmaking nao tratar sistemas equipados como poder barato.
- Bots do Progression Lab preservam arquetipo e spells no offset negativo; os
  oponentes fracos deixam de parecer personagens sem kit.
- O replay dev carrega uma amostra representativa nao-starter primeiro, deixando
  spells, Familiar e summons visiveis no diagnostico.
- Ritmo, DoTs, efeitos mentais, Familiar e anti-stall foram ajustados para o
  combate deixar de parecer ataque basico sem voltar a dominancia por DoT.
- Track 16 Lab Alignment adicionou cenarios de Pocao de Vida e comportamento
  simples sem alterar simulador, recompensas ou tuning.

Leitura:

- O `REVIEW` atual nao deve virar nerf automatico. Ele prova que a pocao mudou a
  leitura de sustain/anti-stall e que o tuning do autobattler deve partir deste
  generated, nao da run pre-pocao.
- `2026-05-25_initial_balance_v01` permanece arquivada como primeira passada
  numerica pos-rework.
- Deltas numericos contra runs anteriores devem ser lidos como alerta de
  compatibilidade, nao como prova direta de balanceamento final.
- Proxima rodada deve focar playtest manual: impacto da Pocao de Vida em
  anti-stall, premium gap, janelas 15h/20h, Defesa/Mental com win rate baixo em
  near-power e sensacao de Familiar/Funeral em replay visual.

Validacoes rodadas:

```powershell
npx -y deno test server/tests/first_slice_simulator_test.ts
npx -y deno test tools/battle_lab
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --archive-run 2026-05-25_source_identity_balance_v02 --compare-with 2026-05-25_initial_balance_v01
cd server/functions
npx -y deno task check
npx -y deno task lint
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_exports.gd
```
