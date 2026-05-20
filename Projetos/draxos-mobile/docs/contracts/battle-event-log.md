# Battle Event Log Contract

- Ultima atualizacao: `2026-05-20`
- Versao atual: `battle_log_v1`

O log de batalha e a unica fonte que o cliente usa para animar uma batalha. O cliente nao recalcula dano, vida, vitoria, recompensa ou ranking.

Status MVP: `battle/request` server-authoritative implementado em T00-P07 com bot `mvp_training_bot`, seed deterministica e eventos `battle_log_v1`.

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

## Eventos Do Primeiro Slice

O contrato deve aceitar estes tipos quando o simulador completo entrar:

- `dot_apply`
- `dot_tick`
- `status_apply`
- `status_expire`
- `barrier_gain`
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
