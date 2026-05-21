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
- `generated/battle_lab_power_bands.csv`: agregados por level e power band.
- `generated/battle_lab_outliers.csv`: problemas priorizados.
- `generated/battle_lab_checks.csv`: criterios PASS/REVIEW/CRITICAL.

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
- Se um arquetipo passa de 65% de win rate, revisar primeiro matchups e fonte de
  dano antes de nerfar globalmente.
- Se o problema aparece so em um level/power band, preferir ajuste de scaling em
  vez de alterar valor base.
