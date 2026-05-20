# Battle Event Log Contract

- Ultima atualizacao: `2026-05-20`
- Versao atual: `battle_log_v1`

O log de batalha e a unica fonte que o cliente usa para animar uma batalha. O cliente nao recalcula dano, vida, vitoria, recompensa ou ranking.

Status MVP: `battle/request` server-authoritative implementado em T00-P07 com bot `mvp_training_bot`, seed deterministica e eventos `battle_log_v1`.

Status primeiro slice v0: `FIRST_SLICE_SIM` implementado em T00-P10 com simulador TypeScript deterministico, bot `bot_summoner_01`, varinha, mana, spells diretas, barreiras, pets, summons, anti-stall e recompensas `FIRST_SLICE_SIM`.

## Envelope

```json
{
  "schema_version": "battle_log_v1",
  "battle_id": "uuid",
  "seed": "string",
  "mode": "MVP_ONLY",
  "duration": 4.2,
  "participants": {
    "player": { "id": "uuid", "display_name": "Draxos" },
    "opponent": { "id": "mvp_training_bot", "display_name": "Bot de Treino", "is_bot": true }
  },
  "result": {
    "winner": "player",
    "reason": "opponent_defeated"
  },
  "events": []
}
```

## Evento Base

Todo evento possui:

| Campo | Tipo | Uso |
|---|---|---|
| `t` | number | Tempo em segundos desde inicio visual |
| `type` | string | Tipo do evento |
| `source` | string | `player`, `opponent`, summon/pet/id de origem ou `system` |
| `target` | string | alvo logico ou `none` |
| `seq` | integer | Ordem absoluta para desempate quando `t` empatar |

## Eventos MVP

### `battle_start`

```json
{ "t": 0.0, "seq": 1, "type": "battle_start", "source": "system", "target": "none" }
```

### `weapon_attack`

```json
{
  "t": 0.5,
  "seq": 2,
  "type": "weapon_attack",
  "source": "player",
  "target": "opponent",
  "damage": 15,
  "damage_type": "magico",
  "hp_after": 85
}
```

### `spell_cast`

```json
{
  "t": 1.2,
  "seq": 3,
  "type": "spell_cast",
  "source": "player",
  "target": "opponent",
  "spell_id": "raio_cosmico",
  "damage": 25,
  "damage_type": "magico",
  "hp_after": 60
}
```

### `reward_preview`

```json
{
  "t": 3.9,
  "seq": 10,
  "type": "reward_preview",
  "source": "system",
  "target": "player",
  "reward_type": "MVP_ONLY"
}
```

### `battle_result`

```json
{
  "t": 4.0,
  "seq": 11,
  "type": "battle_result",
  "source": "system",
  "target": "none",
  "winner": "player",
  "reason": "opponent_defeated"
}
```

## Eventos Do Primeiro Slice V0

### `mana_change`

```json
{
  "t": 0.5,
  "seq": 4,
  "type": "mana_change",
  "source": "player",
  "target": "player",
  "mana_after": 14
}
```

### `summon_spawn`

```json
{
  "t": 0.5,
  "seq": 5,
  "type": "summon_spawn",
  "source": "player",
  "target": "player_demonio",
  "spell_id": "invocar_demonio",
  "hp": 50,
  "damage_type": "fogo"
}
```

### `summon_attack`

```json
{
  "t": 1.0,
  "seq": 8,
  "type": "summon_attack",
  "source": "player_demonio",
  "target": "opponent",
  "damage": 7,
  "damage_type": "fogo",
  "hp_after": 150
}
```

### `pet_attack`

```json
{
  "t": 3.0,
  "seq": 16,
  "type": "pet_attack",
  "source": "player",
  "target": "opponent",
  "pet_id": "familiar_cinzento",
  "damage": 20,
  "damage_type": "magico",
  "hp_after": 93
}
```

### `barrier_gain`

```json
{
  "t": 2.0,
  "seq": 12,
  "type": "barrier_gain",
  "source": "player",
  "target": "player",
  "spell_id": "fortificar",
  "amount": 48,
  "hp_after": 120
}
```

### `anti_stall`

```json
{
  "t": 30.0,
  "seq": 44,
  "type": "anti_stall",
  "source": "system",
  "target": "none",
  "player_hp_after": 40,
  "opponent_hp_after": 35
}
```

## Eventos Do Primeiro Slice Futuro

O contrato deve aceitar estes tipos quando o simulador completo expandir alem do v0:

- `dot_apply`
- `dot_tick`
- `status_apply`
- `status_expire`
- `barrier_absorb`
- `resistance_apply`
- `summon_spawn`
- `summon_attack`
- `summon_expire`
- `summon_death`
- `pet_attack`
- `mana_change`
- `heal`
- `anti_stall`
- `cooldown_start`
- `cooldown_ready`

Cada novo tipo deve documentar payload antes de ser usado pelo cliente.

## Tolerancia Do Cliente

- Eventos desconhecidos nao quebram replay; cliente registra aviso e segue.
- Campos extras devem ser ignorados.
- `seq` sempre define ordem final.
- `duration` e informativo; a timeline deve terminar no ultimo evento se houver divergencia.
