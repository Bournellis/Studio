# Battle Visual Mockup

- Ultima atualizacao: `2026-05-26`
- Escopo: apresentacao visual de `battle_log_v1` no cliente Godot e no Battle Lab.

## Objetivo

Criar uma representacao completa e substituivel da batalha enquanto o projeto ainda nao tem arte final. O mockup usa controles nativos do Godot para mostrar personagens, ataques basicos, spells, buffs, dano, efeitos, icones de placeholder, summons, Familiar, status, cooldowns, HP, Mana, Barreira, resultado e timeline.

O controle vivo e `res://ui/battle_visual_mockup.gd`.

## Regra De Autoridade

O mockup nao calcula combate.

Entrada permitida:

- envelope `battle_log_v1`;
- `rewards` recebidos junto do log;
- campos extras opcionais ja presentes no log.

Saida permitida:

- estado visual local;
- timeline formatada;
- marcadores de placeholder para arte futura.

Nao pode alterar:

- HP real;
- vencedor;
- recompensa;
- recursos;
- ranking;
- matchmaking;
- build autoritativa.

## Onde E Usado

| Superficie | Arquivo | Uso |
|---|---|---|
| Tela Batalha do alpha | `modes/boot/boot.gd` | Replay do log recebido de `battle/request` ou `battle/latest`. |
| Battle Lab Dev | `dev/battle_lab/battle_lab_screen.gd` | Replay offline/custom retornado pelo runner Deno. |
| Testes client | `tests/client/test_battle_visual_mockup.gd` | Garante que eventos ricos renderizam sem simular. |

## Camadas Visuais

| Camada | Representa hoje | Substituicao futura |
|---|---|---|
| Combatant HUD | Nome, HP, Mana, Barreira, status, cooldowns | HUD final com retrato, frame, animacao de barra e tooltips. |
| Avatar placeholder | Letra/slot visual do Draxos e do oponente | Personagem, rig, sprite, animacao ou retrato. |
| Event icon | `ATK`, `SP`, `DOT`, `BUF`, `SUM`, `PET`, `HEAL`, `ANTI`, `END` | Icones finais por evento, spell, fonte ou efeito. |
| Arena markers | Status/Buffs, Spells/Cooldowns, Familiares/Summons | Marcadores com icones, stacks, duracao, VFX e animacoes. |
| Timeline | Texto formatado por `BattleLogPresenter` | Feed compacto, log expandivel ou overlay de debug. |

## Asset Hooks

`core/asset_ids.gd` ja reserva ids para assets futuros:

- `battle_character_player`
- `battle_character_opponent`
- `battle_icon_event`
- `battle_icon_weapon`
- `battle_icon_spell`
- `battle_icon_status`
- `battle_icon_buff`
- `battle_icon_damage`
- `battle_icon_summon`
- `battle_icon_pet`
- `battle_icon_heal`
- `battle_icon_reward`
- `battle_icon_result`
- `battle_fx_hit`
- `battle_fx_spell`
- `battle_fx_buff`

Enquanto esses arquivos nao existem, `AssetIds.has_art(id)` deve continuar retornando `false` e a UI usa placeholders nativos.

## Mapeamento De Eventos

| Evento | Feedback visual atual |
|---|---|
| `battle_start` | Timeline inicia. |
| `weapon_attack` | Icone `ATK`, dano, fonte e HP do alvo. |
| `spell_cast` | Icone `SP`, spell, fonte, dano e HP do alvo. |
| `mana_change` | Mana atualizada no HUD do lado afetado. |
| `cooldown_start` / `cooldown_ready` | Badge de cooldown entra/sai da faixa de spells. |
| `passive_apply` | Doutrina entra como buff/status. |
| `dot_apply` / `dot_tick` | Status/DoT entra no alvo e ticks atualizam HP. |
| `status_apply` / `status_expire` | Badge de status entra/sai do alvo. |
| `barrier_gain` / `barrier_absorb` | Barreira entra no HUD e badge de buff. |
| `resistance_apply` | Resistencia entra como buff/status. |
| `summon_spawn` / `summon_attack` / `summon_expire` | Summon aparece, ataca e pode sumir. |
| `pet_attack` | Familiar aparece no lado de origem e registra ataque. |
| `heal` | HP do alvo sobe e evento usa cor de sucesso. |
| `anti_stall` | HP dos dois lados atualiza e ambos recebem badge `anti_stall`. |
| `reward_preview` | Resultado central mostra recompensa. |
| `battle_result` | Resultado central mostra vencedor/motivo. |

## Como Evoluir

Quando um novo evento visual entrar:

1. Documentar o payload em `docs/contracts/battle-event-log.md`.
2. Garantir que `ui/battle_log_presenter.gd` formata o evento.
3. Adicionar mapeamento em `ui/battle_visual_mockup.gd`.
4. Adicionar ou reservar asset id em `core/asset_ids.gd`.
5. Cobrir com teste em `tests/client/`.
6. Rodar `tools/validate.gd` e, se mexer no Battle Lab, `tools/smoke_dev_lab_ui.gd`.

Quando arte real chegar:

1. Colocar arquivos sob `assets/battle/...`.
2. Manter os ids de `AssetIds` estaveis.
3. Trocar os placeholders de `BattleVisualMockup` por `TextureRect`, animacoes ou cenas instanciadas sem mudar o contrato do log.
4. Preservar fallback sem arte para smoke headless e builds de debug.
