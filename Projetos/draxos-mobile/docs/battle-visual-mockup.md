# Battle Visual Mockup

- Ultima atualizacao: `2026-05-26`
- Escopo: apresentacao visual de `battle_log_v1` no cliente Godot e no Battle Lab.

## Objetivo

Criar uma representacao completa e substituivel da batalha enquanto o projeto ainda nao tem arte final. O mockup usa controles nativos do Godot para mostrar um palco 2D lateral, personagens parados frente a frente, ataques basicos, spells, buffs, dano, efeitos, icones de placeholder, summons, Familiar, status, cooldowns, HP, Mana, Barreira, resultado e timeline.

O controle orquestrador vivo e `res://ui/battle_visual_mockup.gd`.

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
| Testes client | `tests/client/test_battle_visual_mockup.gd`, `tests/client/test_battle_stage_2d.gd` | Garante que eventos ricos e palco procedural renderizam sem simular. |

## Camadas Visuais

| Camada | Representa hoje | Substituicao futura |
|---|---|---|
| Palco 2D procedural | Visao lateral tipo luta classica: Draxos na esquerda, oponente na direita, solo e guia de centro | Cena final de batalha, camera, paralaxe, animacoes e VFX. |
| Combatant HUD | Nome, HP, Mana, Barreira, status, cooldowns | HUD final com retrato, frame, animacao de barra e tooltips. |
| Actor procedural | Silhueta desenhada por `_draw()`, barras e pulse de impacto | Personagem, rig, sprite, animacao ou retrato. |
| Event icon | `ATK`, `SP`, `DOT`, `BUF`, `SUM`, `PET`, `HEAL`, `ANTI`, `END` | Icones finais por evento, spell, fonte ou efeito. |
| Slots front/middle/back | Familiar e summons posicionados em frente, meio e tras de cada personagem | Marcadores com sprites, ancoras de VFX e animacoes. |
| Efeitos temporarios | Projeteis simples, flashes, numeros flutuantes e labels que somem por tween | VFX reais, hit stop, camera shake, sprite trails e animacoes. |
| Tooltips | Explicam placeholders, asset futuro, status, cooldown e slot | Tooltips finais com nomes localizados, regras e icones. |
| Timeline | Texto formatado por `BattleLogPresenter` | Feed compacto, log expandivel ou overlay de debug. |

## Formato 2D Atual

- Apresentacao inspirada em uma luta 2D lateral classica.
- Personagens ficam parados, voltados um para o outro.
- `player` sempre ocupa a esquerda; `opponent` sempre ocupa a direita.
- Familiar e summons usam tres slots relativos ao proprio personagem:
  `front`, `middle` e `back`.
- Quando o log ainda nao informa `slot`, o cliente usa fallback visual:
  Familiar em `back`; primeiro summon em `front`; segundo em `middle`; terceiro
  em `back`.
- `slot` pode ser adicionado futuramente em `summon_spawn` sem quebrar logs
  antigos.
- Essa escolha e somente apresentacao; nao altera alvo, dano, HP, resultado ou
  qualquer regra autoritativa.

## Scripts Procedurais

| Script | Papel |
|---|---|
| `ui/battle_stage_2d.gd` | Palco lateral, layout dos atores, slots, cooldown/status rows e efeitos temporarios. |
| `ui/battle_actor_marker.gd` | Silhueta procedural de cada combatente, barras e pulse de feedback. |
| `ui/battle_symbol_icon.gd` | Icone circular procedural com simbolo, stack/timer e tooltip. |
| `ui/battle_visual_mockup.gd` | Interpreta `battle_log_v1`, mantem estado visual derivado e alimenta palco, HUD tecnico e timeline. |

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
| `battle_start` | Timeline inicia e palco fica pronto. |
| `weapon_attack` | Icone `ATK`, projetil procedural, dano flutuante, pulse no alvo, fonte e HP do alvo. |
| `spell_cast` | Icone `SP`, projetil/flash procedural, spell, fonte, dano e HP do alvo. |
| `mana_change` | Mana atualizada no HUD do lado afetado. |
| `cooldown_start` / `cooldown_ready` | Icone de cooldown entra/sai da faixa de spells com timer placeholder. |
| `passive_apply` | Doutrina entra como buff/status. |
| `dot_apply` / `dot_tick` | Status/DoT entra no alvo, tick mostra numero flutuante e HP atualiza. |
| `status_apply` / `status_expire` | Badge de status entra/sai do alvo. |
| `barrier_gain` / `barrier_absorb` | Barreira entra no HUD e badge de buff. |
| `resistance_apply` | Resistencia entra como buff/status. |
| `summon_spawn` / `summon_attack` / `summon_expire` | Summon aparece em slot front/middle/back, ataca e pode sumir. |
| `pet_attack` | Familiar aparece no slot back do lado de origem e registra ataque. |
| `heal` | HP do alvo sobe e numero verde flutua no palco. |
| `anti_stall` | HP dos dois lados atualiza e ambos recebem badge `anti_stall`. |
| `reward_preview` | Resultado central mostra recompensa. |
| `battle_result` | Resultado central mostra vencedor/motivo e feedback grande no palco. |

## Como Evoluir

Quando um novo evento visual entrar:

1. Documentar o payload em `docs/contracts/battle-event-log.md`.
2. Garantir que `ui/battle_log_presenter.gd` formata o evento.
3. Adicionar mapeamento em `ui/battle_visual_mockup.gd`.
4. Adicionar feedback procedural em `ui/battle_stage_2d.gd`, se o evento tiver leitura espacial.
5. Adicionar ou reservar asset id em `core/asset_ids.gd`.
6. Cobrir com teste em `tests/client/`.
7. Rodar `tools/validate.gd` e, se mexer no Battle Lab, `tools/smoke_dev_lab_ui.gd`.

Quando arte real chegar:

1. Colocar arquivos sob `assets/battle/...`.
2. Manter os ids de `AssetIds` estaveis.
3. Trocar placeholders de `BattleActorMarker`, `BattleSymbolIcon` ou `BattleStage2D` por `TextureRect`, animacoes ou cenas instanciadas sem mudar o contrato do log.
4. Preservar fallback sem arte para smoke headless e builds de debug.
