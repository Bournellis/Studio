# Content Definitions Contract

- Ultima atualizacao: `2026-05-31`
- Status: contrato inicial implementado com rework de personagem; Track 16 adicionou pocoes e receitas de crafting; Foundation Expansion Readiness adicionou `foundation_ruleset_v0` como manifest gerado de autoria/publicacao; Arena PVE v1 adiciona definitions ruleset-only para arenas, inimigos, buffs e rewards.

Conteudo autorado vive em `../../data/definitions/`. Resources Godot gerados vivem em `../../data/generated/` e nao devem ser editados manualmente.

Geradores vivos:

- `../../tools/content_generator.gd` para catalogo Godot.
- `../../tools/generate_foundation_ruleset.ts` para manifest de ruleset e mirrors server/supabase.

Catalogo gerado: `../../data/generated/draxos_mobile_catalog.tres`.

Ruleset gerado: `../../data/rulesets/foundation_ruleset_v0.json`.

## Formato Dos JSONs

Cada arquivo usa este envelope:

```json
{
  "schema_version": 1,
  "collection": "spells",
  "items": []
}
```

Todo item deve ter:

- `id`
- `display_name`
- `description`
- `version`
- `enabled`
- `tags`

IDs sao estaveis. Nao renomear ID para mudar texto player-facing.

## Arquivos Esperados

| Arquivo | Collection | Conteudo |
|---|---|---|
| `spells.json` | `spells` | Spells, custos, alvo, fonte de dano, familia de status, cooldown e efeitos |
| `pets.json` | `pets` | Familiares, fonte, cadencia e efeito |
| `passives.json` | `passives` | Doutrinas, bonus, escala e custo |
| `weapons.json` | `weapons` | Instrumentos rituais, qualidades e custos de Ossos |
| `base_structures.json` | `base_structures` | Estruturas, producao, armazenamento, custos e duracoes |
| `bot_builds.json` | `bot_builds` | Bots simulados por faixa de poder |
| `power_bands.json` | `power_bands` | Faixas de matchmaking |
| `battle_fixtures.json` | `battle_fixtures` | Fixtures `MVP_ONLY` e testes deterministas |
| `rewards.json` | `rewards` | Recompensas diarias, semanais, quests e battle pass |
| `potions.json` | `potions` | Consumiveis de batalha, efeito e comportamento default |
| `crafting_recipes.json` | `crafting_recipes` | Receitas server-authoritative de crafting |

## Arquivos Ruleset-Only Da Arena PVE v1

Os arquivos abaixo entram no `foundation_ruleset_v0` e nos contratos de backend/labs, mas ainda nao entram no catalogo Godot gerado por `tools/content_generator.gd`.

| Arquivo | Collection | Conteudo |
|---|---|---|
| `pve_arenas.json` | `pve_arenas` | Arenas, tamanho da lista, unlocks, sequencia de inimigos, reward profile e regras de tentativa |
| `pve_enemies.json` | `pve_enemies` | Inimigos PVE por arquetipo, papel didatico, poder alvo e build base |
| `arena_buffs.json` | `arena_buffs` | Buffs temporarios de stat oferecidos entre duelos |
| `arena_rewards.json` | `arena_rewards` | Perfis de recompensa da Arena PVE, repeticao reduzida e limites |

Campos minimos alem dos comuns:

- `mode = "PVE_ARENA_V1"`;
- `version`;
- tags com `PVE_ARENA_V1`;
- referencias estaveis para arena, inimigo, buff ou reward profile;
- valores numericos marcados como `CALIBRAVEL_ALPHA` quando ainda dependem de Lab/rodada humana.

## Foundation Ruleset v0

`foundation_ruleset_v0` e o primeiro pacote explicito de regras/conteudo. Ele nao substitui os JSONs autorados; ele registra quais fontes e hashes compoem a publicacao atual.

Inclui:

- `content_hash`;
- `simulator_hash`;
- references para definitions, Battle Lab, Progression Lab, economy simulator e battle simulator mirrors;
- references para definitions Arena PVE v1;
- `schema_version = foundation_ruleset_manifest_v1`;
- `ruleset_version = 1`.

Valide com:

```powershell
npx -y deno run --allow-read --allow-write tools/generate_foundation_ruleset.ts
npx -y deno test --allow-read server/tests/foundation_ruleset_test.ts
```

## Fixture MVP Atual

`battle_fixtures.json` contem `mvp_training_battle`:

```json
{
  "id": "mvp_training_battle",
  "mode": "MVP_ONLY",
  "player_fixture": {
    "level": 1,
    "weapon_type": "varinha_cinzas",
    "spell_ids": ["sussurro_medo"]
  },
  "opponent_fixture": {
    "id": "mvp_training_bot",
    "level": 1
  }
}
```

Itens relacionados:

- spell: `sussurro_medo`
- weapon: `varinha_cinzas`
- passive/doutrine: `doutrina_pavor`
- pet/familiar: `corvo_pressagio`
- bot: `mvp_training_bot`
- power band: `mvp_training_band`
- reward: `mvp_training_reward`

## Validacao

`tools/validate.gd` executa:

- geracao do catalogo a partir dos JSONs esperados;
- validacao de campos comuns;
- validacao de IDs unicos por collection;
- validacao de referencias entre fixture, bot, weapon, spells, passive e pet;
- carga do resource gerado;
- GUT client.

## Pendencias De Design

Fixtures `MVP_ONLY` nao resolvem design final. Quando um campo depender de decisao em aberto, o JSON real deve aguardar a pendencia correspondente em `../design-pending.md`.

Exemplos:

- Custos de Ossos dependem de `DMOB-D021`.
- Recompensas v0 vivem em `../game-design-document.md` e `../economy/README.md`; valores numericos continuam calibraveis no alpha.

## Consumiveis E Crafting Track 16

Conteudo inicial:

- `pocao_vida`: consumivel de batalha, `heal_over_time`, cura `20%` da vida maxima em `5s` (`4%/s`) sem ultrapassar a vida maxima.
- `craft_pocao_vida`: custa `50 po_osso` e gera `1 pocao_vida`.

`po_osso` nao e item de inventario; e recurso tecnico inteiro em `resources`. A conversao `1 Osso -> 1 Po de Osso` vive no endpoint `crafting/crush-bones` para manter autoridade no servidor.

## Bots E Faixas De Poder Do Primeiro Slice

`bot_builds.json` deve popular testes iniciais com bots legais por level e poder. Bots nao entram em ranking e nao recebem recompensas.

Campos recomendados por bot:

- `id`
- `display_name`
- `archetype`
- `level`
- `power`
- `power_band`
- `weapon`
- `equipped_spells`
- `passive_id`
- `pet_id`
- `variation_seed`
- `enabled`
- `is_ranked`

Archetypes iniciais:

| Archetype | Level | Uso |
|---|---|---|
| `starter_instrument` | 1-2 | Instrumento ritual puro, sem spell |
| `mental_controller` | 3-6 | Primeiro ato mental, baseline inicial |
| `elemental_mixer` | 7-14 | Duas spells elementais |
| `familiar_handler` | 15-24 | Duas spells + familiar |
| `summoner` | 25-40 | Tres spells com summon |
| `defensive_occultist` | 25-40 | Barreira/terra/gelo + dano sustentado |
| `dot_pressure` | 15-40 | Sangue, Veneno, Fogo e Morte por tempo |
| `funeral_burst` | 25-40 | Payoff de Morte/Fogo e dano alto |

`power_bands.json` deve definir bandas por poder calculado, nao por level cru. A sugestao inicial e gerar bandas estreitas no comeco e mais largas no fim:

| Banda | Power alvo | Diferenca inicial |
|---|---|---|
| `band_001` | 0-250 | 10% |
| `band_002` | 251-600 | 10% |
| `band_003` | 601-1200 | 15% |
| `band_004` | 1201-2200 | 20% |
| `band_005` | 2201+ | 25% |

O matchmaking pode expandir tolerancia por tempo de busca ate 35% antes de cair em bot.
