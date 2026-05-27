# Progression Lab - T04 Progression Economia

- Data: 2026-05-27
- Tipo: rodada tecnica
- Projeto: DraxosMobile
- Escopo: milestones `2h`, `5h`, `10h`, `15h`, `20h`
- Perfis pedidos: free, freemium, light e max
- Status da rodada: `REVIEW`

Esta rodada registra leitura tecnica dos artefatos do Progression Lab. Ela nao muda numeros de economia, recompensa, poder, bots, loja, combate ou recursos.

## Mapeamento De Perfis

| Pedido | Perfil do lab | Uso nesta rodada |
|---|---|---|
| free | `free_100_rewards` | Referencia principal free ativo. |
| free casual | `free_50_rewards` | Guardrail adicional porque o lab ja gera este perfil. |
| freemium | `freemium_basic` | Battle Pass + segunda fila, sem gasto leve extra. |
| light | `spender_light` | Battle Pass + segunda fila + gasto leve. |
| max | `max_spender` | Teto de aceleracao para stress test. |

## Comandos Executados

```powershell
npx -y deno test tools/progression_lab
npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts
npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all
npx -y deno test tools/battle_lab
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t04-progression-economia\Projetos\draxos-mobile -s res://tools/smoke_dev_labs.gd
```

Resultado:

- Progression Lab tests: `4/4` passaram.
- Geracao: `25` saves, `75` bots, status `REVIEW`, `11` itens de review.
- Seeder dry-run: selecionou `25/25` saves, sem tocar Supabase.
- Battle Lab tests: `14/14` passaram.
- Godot `smoke_dev_labs.gd`: passou com `[smoke-dev-labs] OK Battle Lab bridge + Progression Lab generate`; o console emitiu avisos pre-existentes de parse/autoload (`BattleSymbolIcon`, `ProjectInfo`) antes do smoke, sem exit code de falha.

Artefatos lidos:

- `docs/progression-lab/generated/progression_report.html`
- `docs/progression-lab/generated/milestone_profiles.csv`
- `docs/progression-lab/generated/reward_scaling_checks.csv`
- `docs/progression-lab/generated/premium_gap.csv`
- `docs/progression-lab/generated/power_recommendations.csv`
- `docs/progression-lab/generated/bot_pool.csv`

## Resultado Primario

| Milestone | free ativo | freemium | light | max |
|---|---|---|---|---|
| `2h` | L8 / P738 / `PASS` | L9 / P809 / `PASS` | L9 / P877 / `PASS` | L9 / P995 / `PASS` |
| `5h` | L11 / P1459 / `PASS` | L11 / P1483 / `PASS` | L12 / P1715 / `PASS` | L12 / P1857 / `PASS` |
| `10h` | L14 / P1943 / `PASS` | L14 / P2083 / `PASS` | L15 / P2711 / `PASS` | L15 / P2956 / `PASS` |
| `15h` | L16 / P2609 / `PASS` | L16 / P2751 / `PASS` | L16 / P2928 / `PASS` | L17 / P3453 / `PASS` |
| `20h` | L17 / P2786 / `REVIEW` | L17 / P2969 / `REVIEW` | L18 / P3325 / `PASS` | L19 / P3867 / `PASS` |

Observacao: o `REVIEW` de free/freemium em `20h` vem de level `17` contra janela alvo `18-36`, nao de divida de recurso.

## Itens De Review

| Area | Item | Leitura |
|---|---|---|
| Janela 15h | `free_50_rewards` L14 contra alvo `15-30` | Guardrail casual abaixo da janela; nao tratar como falha do free ativo. |
| Janela 20h | `free_50_rewards` L15 contra alvo `18-36` | Casual fica bem abaixo do alvo; decidir se a janela vale para casual. |
| Janela 20h | `free_100_rewards` L17 contra alvo `18-36` | Free ativo fica 1 level abaixo; precisa playtest manual antes de ajuste. |
| Janela 20h | `freemium_basic` L17 contra alvo `18-36` | Freemium fica 1 level abaixo; indica que o passe/segunda fila nao corrigem XP de level diretamente. |
| Premium gap 10h | `spender_light` +39.53% poder vs free ativo | Gap alto para 10h, mesmo com apenas +1 level. |
| Premium gap 10h | `max_spender` +52.14% poder vs free ativo | Principal alerta da rodada; validar sensacao e matchmaking. |
| Premium gap 20h | `max_spender` +38.8% poder e +2 levels vs free ativo | Aceleracao segue alta no teto, mas abaixo do pico de 10h. |

Nao apareceu `CRITICAL`. Todas as checagens de `resource_debt` passaram com `0`.

## Premium Gap

Leitura:

- `freemium_basic` esta estavel: gap entre `1.64%` e `9.62%` nas janelas medidas.
- `spender_light` so entra em `REVIEW` em `10h` com `39.53%`.
- `max_spender` entra em `REVIEW` em `10h` com `52.14%` e em `20h` com `38.8%`.
- O pico de `10h` parece mais ligado a upgrades de build/poder do que a simples level gap, pois o level gap e apenas `+1`.

Recomendacao:

- Nao aumentar recompensas premium antes da rodada humana.
- Jogar manualmente `spender_light_10h`, `max_spender_10h` e `max_spender_20h` como casos obrigatorios.
- Se o poder pago parecer opressivo, preferir deslocar valor premium para conforto, fila, previsibilidade, cosmetico ou reducao de atrito, nao para recursos que aumentem poder imediato.
- Se o gap parecer aceitavel porque o matchmaking separa bem os poderes, manter os numeros e registrar apenas criterio de pareamento.

Decisao pendente:

- Definir alvo de gap aceitavel por janela. A rodada sugere que `10h` deve ter limite mais conservador do que `20h`, porque o jogador ainda esta formando expectativa de justica.

## Janelas 15h E 20h

Leitura:

- `15h` passa para free ativo, freemium, light e max.
- O unico `15h REVIEW` e `free_50_rewards`, que representa free casual incompleto.
- `20h` fica no limite: free ativo e freemium chegam a L17, 1 level abaixo do alvo L18.
- Light e max passam em `20h`, chegando a L18 e L19.

Recomendacao:

- Separar explicitamente dois alvos: free casual como guardrail de retencao e free ativo como alvo de progressao.
- Antes de mexer em XP/recompensas, decidir se L18 em `20h` e requisito real ou apenas janela agressiva do lab.
- Se L18 for requisito real, ajustar depois em tarefa dedicada para levantar free ativo/freemium sem ampliar demais light/max.
- Se L17 for aceitavel aos `20h`, ajustar o target do lab em tarefa separada, mantendo o status `REVIEW` desta rodada como evidencia historica.

## Poder

Leitura de `power_recommendations.csv`:

| Componente | Peso atual | Share observado | Status |
|---|---:|---:|---|
| level | 42 | 27.22% | `PASS` |
| weapon_level | 28 | 12.55% | `PASS` |
| spell_level | 40 | 39.74% | `PASS` |
| pet_level | 34 | 9.7% | `PASS` |
| passive_level | 22 | 7.9% | `PASS` |
| weapon_quality_tier | 30 | 0.06% | `PASS` |
| base_stats_level | 8 | 1.94% | `PASS` |
| base_average_level | 4 | 0.9% | `PASS` |

Recomendacao:

- Manter pesos de poder por enquanto.
- Nao reduzir `spell_level` so pelo share alto; spells sao identidade de build e o Battle Lab ainda passa.
- Usar rodada humana para checar se builds de Familiar/Funeral aos `10h-20h` parecem equivalentes em leitura, nao so em poder.
- Qualquer mudanca de peso deve exigir nova rodada Battle Lab + Progression Lab, comparando near-power matchups.

## Bots

Leitura:

- O lab gerou `75` bots: 3 por save, com offsets aproximados `-12%`, `0%`, `+12%`.
- Distribuicao por power band:
  - `band_002`: 1 bot
  - `band_003`: 15 bots
  - `band_004`: 27 bots
  - `band_005`: 32 bots
- Por milestone:
  - `2h`: 1 em `band_002`, 14 em `band_003`
  - `5h`: 1 em `band_003`, 14 em `band_004`
  - `10h`: 8 em `band_004`, 7 em `band_005`
  - `15h`: 3 em `band_004`, 12 em `band_005`
  - `20h`: 2 em `band_004`, 13 em `band_005`

Recomendacao:

- Manter o pool atual como baseline tecnica.
- Na rodada humana, observar especialmente a transicao `10h` entre `band_004` e `band_005`.
- Se o pareamento parecer saltar demais, adicionar depois bots ponte nos limites de banda em vez de mudar a formula de poder primeiro.
- Preservar bots fora da leaderboard publica e fora do save `progression_lab`, como ja definido.

## Recursos

Leitura:

- Nao ha divida oculta de recurso em nenhum save.
- Free ativo em `20h` ainda tem reservas de `almas`, `energia`, `sangue`, `cristais` e `ossos`, mas fica 1 level abaixo da janela.
- Freemium em `20h` tem menos `energia` que free ativo, coerente com segunda fila consumindo mais ritmo de base.
- Max em `20h` chega a `weapon_quality_tier=1` e termina com `ossos=7.3`, um sinal bom para olhar se qualidade de arma cria gargalo perceptivel ou apenas sink saudavel.

Recomendacao:

- Nao mexer em recursos antes da rodada humana.
- Durante o playtest, anotar para cada perfil se o proximo upgrade esta claro e desejavel.
- Checar se freemium/light sentem a segunda fila como conforto ou como pressao extra de Energia.
- Checar se max em `20h` parece acelerado com objetivo futuro claro, nao apenas drenado por sink.

## Matriz Manual Recomendada

Rodada primaria:

| Perfil | Milestones obrigatorios |
|---|---|
| `free_100_rewards` | `2h`, `5h`, `10h`, `15h`, `20h` |
| `freemium_basic` | `2h`, `5h`, `10h`, `15h`, `20h` |
| `spender_light` | `2h`, `5h`, `10h`, `15h`, `20h` |
| `max_spender` | `2h`, `5h`, `10h`, `15h`, `20h` |

Casos obrigatorios de foco:

- `spender_light_10h`
- `max_spender_10h`
- `max_spender_20h`
- `free_100_rewards_20h`
- `freemium_basic_20h`

Guardrail opcional:

- `free_50_rewards_15h`
- `free_50_rewards_20h`

Checklist por caso:

1. Carregar save no Progression Lab.
2. Conferir se Refugio mostra recursos, poder, fila e base coerentes.
3. Rodar uma batalha `FIRST_SLICE_SIM`.
4. Abrir Base e avaliar se o proximo upgrade parece desejavel.
5. Abrir Loja/Passe e avaliar se premium parece conforto, nao obrigacao.
6. Registrar gargalo, momento confuso, objetivo claro e vontade de continuar.

## Decisoes Recomendadas Antes De Tuning

1. Premium gap: escolher alvo aceitavel para `10h` e `20h`.
2. Janela 20h: decidir se L18 minimo e requisito real para free ativo/freemium.
3. Bots: decidir se transicao `band_004` -> `band_005` precisa de bots ponte.
4. Recursos: decidir se segunda fila deve ser conforto liquido ou tradeoff com Energia mais apertada.
5. Poder: manter pesos ate nova evidencia conjunta Progression Lab + Battle Lab.

## Conclusao

A rodada tecnica deixa o Progression Lab em `REVIEW`, mas sem bloqueio critico. O sistema esta pronto para rodada humana focada nos casos de `10h` premium e `20h` free/freemium antes de qualquer mudanca numerica.
