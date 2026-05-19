# Content Definitions Contract

- Ultima atualizacao: `2026-05-19`
- Status: contrato antes dos JSONs reais

Conteudo autorado vive em `../../data/definitions/`. Resources Godot gerados vivem em `../../data/generated/` e nao devem ser editados manualmente.

## Arquivos Esperados

| Arquivo | Conteudo |
|---|---|
| `spells.json` | Spells, custos, alvo, tipo de dano, cooldown e efeitos |
| `pets.json` | Pets, tipo de dano, cadencia e efeito |
| `passives.json` | Passivas, bonus, escala e custo |
| `weapons.json` | Tipos/qualidades de arma e custos de Ossos |
| `base_structures.json` | Estruturas, producao, armazenamento, custos e duracoes |
| `bot_builds.json` | Bots simulados por faixa de poder |
| `power_bands.json` | Faixas de matchmaking |
| `battle_fixtures.json` | Fixtures `MVP_ONLY` e testes deterministas |
| `rewards.json` | Recompensas diarias, semanais, quests e battle pass |

## Campos Comuns

Todo item de conteudo deve ter:

- `id`
- `display_name`
- `description`
- `version`
- `enabled`
- `tags`

IDs sao estaveis. Nao renomear ID para mudar texto player-facing.

## Fixture MVP

`battle_fixtures.json` deve conter:

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

## Validacao

- IDs unicos por arquivo.
- Referencias cruzadas precisam existir.
- Conteudo desativado (`enabled: false`) nao entra em matchmaking/recompensas.
- Fixtures `MVP_ONLY` nao podem aparecer em economia final sem migracao explicita.

## Pendencias De Design

Quando um campo depender de decisao em aberto, o JSON real deve aguardar a pendencia correspondente em `../design-pending.md`.

Exemplos:

- Custos de Ossos dependem de `DMOB-D021`.
- Bot generation depende de `DMOB-D017`.
- Recompensas dependem de `DMOB-D008`, `DMOB-D011`, `DMOB-D027` e `DMOB-D028`.
