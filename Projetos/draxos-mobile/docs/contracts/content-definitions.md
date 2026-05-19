# Content Definitions Contract

- Ultima atualizacao: `2026-05-19`
- Status: contrato inicial implementado com fixtures `MVP_ONLY`

Conteudo autorado vive em `../../data/definitions/`. Resources Godot gerados vivem em `../../data/generated/` e nao devem ser editados manualmente.

Gerador vivo: `../../tools/content_generator.gd`.

Catalogo gerado: `../../data/generated/draxos_mobile_catalog.tres`.

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
| `spells.json` | `spells` | Spells, custos, alvo, tipo de dano, cooldown e efeitos |
| `pets.json` | `pets` | Pets, tipo de dano, cadencia e efeito |
| `passives.json` | `passives` | Passivas, bonus, escala e custo |
| `weapons.json` | `weapons` | Tipos/qualidades de arma e custos de Ossos |
| `base_structures.json` | `base_structures` | Estruturas, producao, armazenamento, custos e duracoes |
| `bot_builds.json` | `bot_builds` | Bots simulados por faixa de poder |
| `power_bands.json` | `power_bands` | Faixas de matchmaking |
| `battle_fixtures.json` | `battle_fixtures` | Fixtures `MVP_ONLY` e testes deterministas |
| `rewards.json` | `rewards` | Recompensas diarias, semanais, quests e battle pass |

## Fixture MVP Atual

`battle_fixtures.json` contem `mvp_training_battle`:

```json
{
  "id": "mvp_training_battle",
  "mode": "MVP_ONLY",
  "player_fixture": {
    "level": 1,
    "weapon_type": "varinha_magica",
    "spell_ids": ["raio_cosmico"]
  },
  "opponent_fixture": {
    "id": "mvp_training_bot",
    "level": 1
  }
}
```

Itens relacionados:

- spell: `raio_cosmico`
- weapon: `varinha_magica`
- passive: `foco_astral`
- pet: `familiar_cinzento`
- bot: `mvp_training_bot`
- power band: `mvp_training_band`
- reward: `mvp_training_reward`

## Validacao

`tools/validate.gd` executa:

- geracao do catalogo a partir dos 9 JSONs esperados;
- validacao de campos comuns;
- validacao de IDs unicos por collection;
- validacao de referencias entre fixture, bot, weapon, spells, passive e pet;
- carga do resource gerado;
- GUT client.

## Pendencias De Design

Fixtures `MVP_ONLY` nao resolvem design final. Quando um campo depender de decisao em aberto, o JSON real deve aguardar a pendencia correspondente em `../design-pending.md`.

Exemplos:

- Custos de Ossos dependem de `DMOB-D021`.
- Bot generation depende de `DMOB-D017`.
- Recompensas dependem de `DMOB-D008`, `DMOB-D011`, `DMOB-D027` e `DMOB-D028`.
