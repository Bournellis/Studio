# Lab Heuristics Contract

- Status: `CONTRATO`
- Contract id: `LAB_HEURISTICS_CONTRACT_V1`
- Ultima atualizacao: `2026-05-31`
- Escopo: Progression Lab, Battle Lab, modelos offline, healthy saves, custom
  replays, relatorios gerados e runner remoto interno do Web export.

## Decisao

Progression Lab e Battle Lab sao ferramentas de diagnostico e autoria assistida.
Eles nao sao fonte autoritativa de tuning em runtime.

O runtime autoritativo continua sendo:

- `foundation_ruleset_v0` para pacote de regras/conteudo publicado;
- `_shared/battle_simulator.ts` para simulacao de batalha server-side;
- `_shared/battle_combatants.ts` para mapping player/build/bot/potion/behavior;
- `_shared/progression_domain.ts` para payload de build, unlocks e power runtime;
- `_shared/base_domain.ts` e `_shared/economy_domain.ts` para Base/Economia.

Qualquer alteracao em numeros de combate, economia, power, bots, recompensas,
thresholds, pacing ou progressao so vira regra depois de pacote explicito,
ruleset regenerado e validacao cruzada.

## Autoridade Por Artefato

| Artefato | Authority | Pode Mudar Runtime? | Observacao |
|---|---|---:|---|
| `tools/battle_lab/model.v1.json` | `lab-only` | Nao | Define matriz offline de build, archetypes, thresholds de relatorio, bands e checks. |
| `tools/battle_lab/generate.ts` | `lab-only + simulator consumer` | Nao | Chama o simulador atual para relatorios, cobre Track 16 potion/behavior e continua sendo a fonte local/editor. Pode ser reutilizado pelo `lab-runner` apenas como adaptador remoto in-memory, sem publicar tuning sozinho. |
| `dev/battle_lab/battle_lab_screen.gd` | `client dev shell` | Nao | UI de custom replay/scratch; deve espelhar pesos exibidos pelo Battle Lab, nao inventar formula nova. Pode montar Pocao de Vida e desativacao simples de spell para replay custom lab-only. |
| `docs/battle-lab/generated/` | `generated evidence` | Nao | Evidencia historica/diagnostica; nao substitui ruleset. |
| `docs/battle-lab/runs/` | `archived evidence` | Nao | Runs oficiais sao snapshots; hashes podem ficar stale. |
| `tools/progression_lab/model.v1.json` | `lab-only` | Nao | Define perfis, milestones, source values, custos, pesos macro, bot offsets e cobertura Track 16 de consumables/crafting para leitura offline. |
| `tools/progression_lab/generate.ts` | `lab-only + generated save producer` | Nao | Gera healthy saves, consumable readiness e bot pool para teste manual. Pode ser reutilizado pelo `lab-runner` apenas como adaptador remoto in-memory; nao altera save normal. |
| `dev/progression_lab/progression_lab_screen.gd` | `client dev shell` | Nao | Aplica ou carrega somente `progression_lab`; cache local-only nao tem token valido. |
| `docs/progression-lab/generated/` | `generated evidence` | Nao | Healthy saves e relatorios para review manual. |
| `POST /progression-lab/apply` | `server-authoritative lab adapter` | Sim, apenas save Lab | Escreve somente no save `progression_lab` e valida profile/milestone/save gerado. |
| `POST /lab-runner/battle` | `internal-alpha remote lab adapter` | Nao | Runner remoto para Web export quando processo local nao existe; exige JWT de conta alpha Supabase por email/senha com save `normal` registrado, retorna run/replay in-memory, nao escreve run oficial e nao muta economia/ranking. |
| `POST /lab-runner/progression` | `internal-alpha remote lab adapter` | Nao | Runner remoto para Web export quando processo local nao existe; exige o mesmo acesso alpha por email/senha do Supabase, retorna dados in-memory e nao aplica healthy save. |

## Runner Remoto Web

O Web export nao pode executar `npx/deno` no navegador. Para manter os Labs
testaveis no link publicado, `lab-runner` expõe dois endpoints internos:

- `POST /lab-runner/battle`;
- `POST /lab-runner/progression`.

Esse runner usa a mesma entrada alpha do Supabase usada pelo jogo: JWT de conta
email/senha, nao anonima, com save `normal` registrado na Internal Alpha. Nao
existe allowlist paralela para Labs; quem nao passou pelo mesmo gate de email e
conta alpha do Supabase recebe erro antes de qualquer geracao.

Regras do runner remoto:

- usa `SUPABASE_SERVICE_ROLE_KEY` somente dentro da Edge Function para verificar
  acesso alpha;
- nunca envia service role, secrets ou dados de outro jogador ao cliente;
- nao grava arquivos em `docs/**`, `.battle_lab_scratch/**` ou
  `.progression_lab_scratch/**`;
- nao aplica reward, XP, ranking, recursos, progresso, potion stock, save ou
  ledger;
- run oficial/archive continua sendo fluxo local/editor;
- replay custom e scratch remoto sao resultados de sessao, nao evidencia
  arquivada.

## Battle Lab Heuristics

Modelo atual: `draxos_mobile_battle_lab_v4_source_identity`.
Status atual: `SOURCE_IDENTITY_ALPHA`.

Heuristicas locais conhecidas:

- duracao alvo: `18s` a `28s`;
- batalha curta: `< 12s`;
- batalha longa: `> 32s`;
- review se batalhas curtas ou longas passam de `20%`;
- review se anti-stall passa de `5%`;
- win rate saudavel: `45%` a `55%`;
- dominance review: `65%`;
- dominance critical: `75%`;
- stomp check: vencedor com `65%` HP;
- near-power dominance usa delta maximo de `20%` e ignora mirrors de mesmo archetype;
- archetypes, ratios de level e `quality_bias` existem para gerar stress cases,
  nao para publicar builds finais.
- `track16_scenarios` cobre `pocao_vida`, comportamento default de pocao e
  desativacao simples da primeira spell apenas como evidencia de laboratorio.
- Generated atual de Track 16 Lab Alignment: `4644` batalhas, `244` builds,
  status `REVIEW` por `anti_stall_rate = 6.4%`, dominancia near-power
  `63.34%`, `1492` matchups com pocao e `1238` com comportamento de spell.

Pesos de poder exibidos pelo Battle Lab:

| Componente | Peso |
|---|---:|
| `level` | 42 |
| `weaponLevel` | 28 |
| `spellLevelsTotal` | 40 |
| `petLevel` | 34 |
| `passiveLevel` | 22 |
| `weaponQualityTier` | 30 |

O Battle Lab usa `spellLevelsTotal` porque mede fantasia/source identity de
spells em relatorio offline. O runtime de build atual em
`_shared/progression_domain.ts` ainda usa uma leitura mais conservadora para
power runtime. Essa diferenca e permitida somente enquanto estiver documentada
como Lab heuristic; promover a formula do Lab para runtime exige pacote de
tuning proprio.

## Progression Lab Heuristics

Modelo atual: `draxos_mobile_progression_lab_v1`.
Status atual: `INITIAL_BALANCE_ALPHA`.

Heuristicas locais conhecidas:

- milestones: `2h`, `5h`, `10h`, `15h`, `20h`;
- perfis: `free_50_rewards`, `free_100_rewards`, `freemium_basic`,
  `spender_light`, `max_spender`;
- cap de level do Lab: `40`;
- targets de level por milestone sao faixas de review, nao promessa de produto;
- perfis premium simulam conforto/tempo e devem ser revisados contra pay-to-win;
- `source_values`, custos e `weapon_quality_thresholds` sao estimativas alpha;
- pesos macro incluem base stats e base average para leitura economica;
- `bot_power_offsets_percent`: `-12`, `0`, `12`;
- bot pool gerado fica fora de leaderboard e fora do save normal.
- `track16_consumables` modela `po_osso`, `craft_pocao_vida`, `pocao_vida`,
  estoque alvo por milestone, slot de pocao e comportamentos default.
- `healthy_saves.json` deve carregar `consumables`, `combat_build.potionSlot`
  quando aplicavel e `combat_build.spellBehaviors`; `potion_affordability.csv`,
  `crafting_pressure.csv` e `preparation_readiness.csv` sao artefatos vivos do
  runbook.

O Progression Lab pode gerar `healthy_saves.json`, `bot_pool.csv` e cache
local-only. Esses artefatos devem continuar isolados do save `normal`.

## Bloqueios

Ficam blocked until explicit package decision:

- trocar pesos de power runtime pelo modelo do Lab;
- mudar `target_duration`, dominance, anti-stall ou win-rate gates;
- adicionar bots ponte;
- mudar source values, custos, recompensas, XP, Battle Pass ou store packs;
- mudar custo/estoque/threshold/heal de pocao ou conversao de `ossos/po_osso`;
- promover thresholds customizados, spell priorities, enemy-specific behavior
  ou previsao de vitoria para UI de jogador;
- usar generated healthy saves como conteudo publicado sem ruleset/registry.

## Guardrails

Mudancas em Labs devem provar:

1. o modelo ainda esta hasheado por `foundation_ruleset_v0`;
2. a documentacao lista o `model_id` atual;
3. a tela Godot do Battle Lab exibe a mesma formula de poder do runner TS;
4. Progression Lab screen e model mantem os mesmos profile/milestone ids;
5. healthy saves do Progression Lab incluem Track 16 consumables/behavior sem
   tocar save `normal`;
6. `progression_lab` continua isolado do save `normal`;
7. geradores dev continuam locais/editor; no Web export, somente o
   `lab-runner` pode reutiliza-los como adaptador remoto in-memory;
8. runtime de gameplay nao importa geradores nem telas dev dos Labs;
9. `validate_foundation.ps1 -Profile Quick` continua verde.

Comandos minimos quando este contrato mudar:

```powershell
npx -y deno test --allow-read server/tests/lab_heuristics_contract_test.ts
npx -y deno test tools/battle_lab tools/progression_lab
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/client/test_battle_lab_dev.gd -gtest=res://tests/client/test_progression_lab_dev.gd -gexit
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick
```
