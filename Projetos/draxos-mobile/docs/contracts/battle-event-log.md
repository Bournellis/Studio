# Battle Event Log Contract

- Ultima atualizacao: `2026-05-20`
- Versao atual: `battle_log_v1`

O log de batalha e a unica fonte que o cliente usa para animar uma batalha. O cliente nao recalcula dano, vida, vitoria, recompensa ou ranking.

Status MVP: `battle/request` server-authoritative implementado em T00-P07 com bot `mvp_training_bot`, seed deterministica e eventos `battle_log_v1`.

Status primeiro slice: `FIRST_SLICE_SIM` completo em T00-P10 com simulador TypeScript deterministico, bots de variacao, Instrumentos Rituais, mana, spells diretas, DoTs, status, resistencias, barreiras, Familiares, Doutrinas, summons, cooldowns, anti-stall e recompensas `FIRST_SLICE_SIM`.

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
  "damage_type": "arcano",
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
  "spell_id": "sussurro_medo",
  "damage": 25,
  "damage_type": "none",
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

## Eventos Do Primeiro Slice

### `passive_apply`

```json
{
  "t": 0.0,
  "seq": 2,
  "type": "passive_apply",
  "source": "player",
  "target": "player",
  "passive_id": "sangue_obediente",
  "passive_level": 20
}
```

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

### `cooldown_start` / `cooldown_ready`

```json
{
  "t": 0.5,
  "seq": 5,
  "type": "cooldown_start",
  "source": "player",
  "target": "player",
  "spell_id": "marca_brasa",
  "ready_at": 7.5
}
```

```json
{
  "t": 7.5,
  "seq": 30,
  "type": "cooldown_ready",
  "source": "player",
  "target": "player",
  "spell_id": "marca_brasa"
}
```

### `dot_apply` / `dot_tick`

```json
{
  "t": 0.5,
  "seq": 8,
  "type": "dot_apply",
  "source": "opponent",
  "target": "player",
  "spell_id": "marca_brasa",
  "status_id": "queimando",
  "stacks": 1,
  "tick_damage": 3,
  "duration": 5
}
```

```json
{
  "t": 1.5,
  "seq": 12,
  "type": "dot_tick",
  "source": "opponent",
  "target": "player",
  "status_id": "queimando",
  "damage": 3,
  "damage_type": "fogo",
  "hp_after": 82
}
```

### `status_apply` / `status_expire`

```json
{
  "t": 1.0,
  "seq": 10,
  "type": "status_apply",
  "source": "opponent",
  "target": "player",
  "spell_id": "geada_ossos",
  "status_id": "resfriado",
  "stacks": 1,
  "duration": 5
}
```

```json
{
  "t": 6.5,
  "seq": 28,
  "type": "status_expire",
  "source": "opponent",
  "target": "player",
  "status_id": "resfriado"
}
```

### `summon_spawn`

```json
{
  "t": 0.5,
  "seq": 5,
  "type": "summon_spawn",
  "source": "player",
  "target": "player_brasa_faminta",
  "spell_id": "invocar_brasa_faminta",
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
  "source": "player_brasa_faminta",
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
  "pet_id": "corvo_pressagio",
  "damage": 20,
  "damage_type": "morte",
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
  "spell_id": "coagulo_negro",
  "amount": 48,
  "hp_after": 120
}
```

### `barrier_absorb`

```json
{
  "t": 0.5,
  "seq": 4,
  "type": "barrier_absorb",
  "source": "player",
  "target": "opponent",
  "damage_type": "arcano",
  "amount": 12,
  "barrier_after": 0
}
```

### `resistance_apply`

```json
{
  "t": 2.0,
  "seq": 14,
  "type": "resistance_apply",
  "source": "player",
  "target": "player",
  "spell_id": "coagulo_negro",
  "status_id": "fortificado",
  "amount": 0.08,
  "duration": 8
}
```

### `heal`

```json
{
  "t": 3.5,
  "seq": 20,
  "type": "heal",
  "source": "player",
  "target": "player",
  "amount": 2,
  "hp_after": 84
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

## Eventos Futuros Possiveis

O contrato ainda pode aceitar estes tipos quando o simulador expandir alem do T00-P10:

- `summon_death`
- `barrier_break`
- `cleanse`
- `revive`

Cada novo tipo deve documentar payload antes de ser usado pelo cliente.

## Tolerancia Do Cliente

- Eventos desconhecidos nao quebram replay; cliente registra aviso e segue.
- Campos extras devem ser ignorados.
- `seq` sempre define ordem final.
- `duration` e informativo; a timeline deve terminar no ultimo evento se houver divergencia.
