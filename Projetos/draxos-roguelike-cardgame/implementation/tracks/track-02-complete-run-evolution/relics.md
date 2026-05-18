# Track 02 Relics

- Last Updated: `2026-05-18`
- Status: `APPROVED_FOR_IMPLEMENTATION_PLANNING`

## Rules

Relics are universal run passives.

- Relics are not class-specific.
- Relics are separate from class passive and class active.
- Relics do not persist between runs.
- Relics can appear as map rewards and shop items.
- A successful run should usually collect 5-6 relics, with more possible through shop.
- Relics use the same rarity labels as rewards: common, rare, ultra rare.
- Relics must expose full tooltip text wherever shown.
- Relic effects must be visible in battle/reward/shop previews when they change a number or rule.

## Initial Common Relics

| Relic | Effect | Design role |
|---|---|---|
| Bolsa de Cinzas | Gain +3 Souls after each combat. | Economy floor. |
| Lamina de Reserva | The first duplicate-card shop purchase costs 50% less. | Encourages deck shaping. |
| Mao Preparada | On the first turn of each combat, draw +1 card, then discard 1. | Improves opening quality without raising hand cap. |
| Couro Astral | Gain +3 max HP when picked. | Simple survival relic. |
| Marca de Guerra | The first allied creature summoned in each combat gains +1 HP. | Board stability. |
| Eco Menor | The first spell that deals damage in each combat deals +1 damage. | Small spell payoff. |

## Initial Rare Relics

| Relic | Effect | Design role |
|---|---|---|
| Catalisador Arcano | The first spell played each turn costs 1 less, minimum 0. | Mana smoothing and spell build support. |
| Contrato de Sangue | After each victory, choose +5 Souls or heal 3 HP. | Flexible recovery/economy. |
| Ferramentas de Cirurgia | The first card removal in each shop costs 0. | Strong deck thinning. |
| Estandarte Vivo | The first allied creature summoned each turn gains +1 ATK until end of turn. | Creature tempo. |
| Nucleo Instavel | When a new-card reward rolls ultra rare, gain +1 extra copy. | High-roll reward amplifier. |
| Escudo de Marcha | At combat start, the leftmost allied creature in hand gains Escudo when summoned this combat. | Defensive planning. |

## Initial Ultra Rare Relics

| Relic | Effect | Design role |
|---|---|---|
| Coracao de Eter | Gain +1 temporary mana on the first turn of each combat. | Explosive openers. |
| Biblioteca Proibida | New-card rewards show +1 additional option when possible. | Choice expansion. |
| Forja Negra | Card-upgrade rewards also heal 4 HP. | Upgrade/recovery bridge. |
| Olho do Grande Mestre | Enemy intent reveals boss special actions 1 turn earlier. | Planning and boss clarity. |
| Selo de Dominacao | When a lane is cleared, deal 1 damage to the enemy hero if the encounter has one. | Duel/boss pressure. |
| Pacto das Ruinas | Gain +10 max HP; healing rewards and shop healing restore 50% less. | Risk/reward durability. |

## Implementation Notes

- Relics should be data-driven.
- Relic ids should be stable and ASCII.
- Relics should be stored in run state as ids.
- Relic effects should be resolved through explicit hooks, not hardcoded UI text.
- A relic can be disabled in data without breaking saves if its id remains known.

Suggested ids:

- `bolsa_de_cinzas`
- `lamina_de_reserva`
- `mao_preparada`
- `couro_astral`
- `marca_de_guerra`
- `eco_menor`
- `catalisador_arcano`
- `contrato_de_sangue`
- `ferramentas_de_cirurgia`
- `estandarte_vivo`
- `nucleo_instavel`
- `escudo_de_marcha`
- `coracao_de_eter`
- `biblioteca_proibida`
- `forja_negra`
- `olho_do_grande_mestre`
- `selo_de_dominacao`
- `pacto_das_ruinas`
