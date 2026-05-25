# DraxosMobile - Character Systems Rework

- Last Updated: `2026-05-25`
- Status: `AUTHORITATIVE_BASELINE`
- Scope: instruments, spells, doutrines/passives, familiars/pets, stats, damage sources and status families.

This document supersedes the early placeholder character content from Track 00. The slot model is preserved, but names, sources, status taxonomy and build fantasy are now aligned with the occultist Draxos direction.

## Slot Model

The player remains one Draxos mage with:

- 1 Ritual Instrument
- 3 Spell slots
- 1 Doutrine slot, implemented as the existing passive slot
- 1 Familiar slot, implemented as the existing pet slot

Every ritual instrument, spell, doutrine and familiar has its own permanent level. Each item level remains capped by the character level.

## Magic Degrees

| Degree | Scope | Gameplay Role |
|---|---|---|
| Mental Acts | Fear, panic, terror, confusion, compulsion and will-breaking | Control, vulnerability, tempo disruption and setup. Mental is a status family, not a damage type. |
| Corporeal Acts | Physical force, blood, venom, fire, water, ice, earth, wind and lightning | Direct damage, DoTs, barriers, slows, wounds and material interactions. |
| Funeral Acts | Death, decay, anti-regeneration, sepulchral marks and necromancy | Superior to ordinary corporeal magic, but still before future energetic magic. |
| Energetic Acts | Future energy-body systems | Reserved. Do not add chakra-facing content yet. |

## Stats

Primary stats:

| Stat | Meaning |
|---|---|
| Vida | Body integrity. |
| Mana | Spell resource and combat pacing resource. |
| Potencia Ritual | Strength of damage, healing, barriers and spell payloads. |
| Controle Ritual | Application, duration and stability of status effects. |
| Guarda | Mitigation against direct physical pressure and impact. |
| Vontade | Resistance against mental status families. |
| Vitalidade | Resistance against blood, venom, death and body deterioration. |
| Celeridade Ritual | Attack rhythm, cast cadence and cooldown pressure. |

Derived stats:

- Regen Vida
- Regen Mana
- Tenacidade
- Damage-source resistances
- Status duration modifiers
- Status intensity modifiers
- Ritual Instrument power

Regen is not removed. Regen Vida and Regen Mana stay in simulation and tools, but they are derived/secondary readouts rather than identity-defining primary stats.

## Damage Sources

The final source vocabulary is:

- Arcano
- Fisico
- Fogo
- Agua
- Gelo
- Terra
- Vento
- Raio
- Veneno
- Sangue
- Morte

`Magico`, `Choque` and `Sangramento` were placeholder source names. Use `Arcano`, `Raio` and `Sangue` instead. Sangramento remains a status/condition inside the Blood family.

## Status Families

| Family | Statuses |
|---|---|
| Mental | Inquietacao, Medo, Panico, Terror, Confusao, Compulsao, Quebra de Vontade |
| Blood | Ferida, Sangramento, Hemorragia, Sangue Exposto, Coagulacao Profana |
| Venom | Toxina, Envenenado, Necrose Quimica, Fraqueza |
| Fire | Brasa, Queimando, Incinerado, Cinzas Marcadas |
| Water/Ice | Molhado, Resfriado, Lento, Congelado, Estilhacavel |
| Earth/Physical | Enraizado, Fraturado, Vulneravel, Couraca |
| Wind/Lightning | Desequilibrado, Condutor, Eletrificado, Atordoado |
| Death | Pressagio, Decaimento, Marca Sepulcral, Carne Morta, Anti-Regeneracao |

Status design rule: a status must have a clear family, counter-stat and role. Similar DoTs should not differ only by name.

## Initial Balance V1 - 2026-05-25

The first numeric pass after the rework is now the live alpha baseline:

- Battle Lab official run: `2026-05-25_initial_balance_v01`.
- Overall Battle Lab status: `PASS`.
- Average duration: `21.13s`.
- Anti-stall: `0.96%`.
- Near-power dominance: `64.46% max`, inside the `<= 65%` review gate.

Applied tuning direction:

- Reduced global HP pacing from the post-rework placeholder so anti-stall is rare again.
- Repriced power around equipped systems: level `42`, weapon level `30`, spell level total `35`, pet level `30`, passive level `22`, quality tier `30`.
- Recalculated Battle Lab imported Progression Lab builds from their real combat loadout instead of trusting target power.
- Split `corvo_pressagio` from `inquietacao`; Corvo now applies `pressagio` so it no longer stacks the same mental slow as `sussurro_medo`.
- Softened Familiar, DoT and fire/blood pressure while strengthening `cajado_ossario` enough for Funeral/Summoner identities to function before late Death unlocks.

Progression Lab remains `REVIEW`, not final balance, because premium gap and some 15h/20h level windows still need manual playtest.

## Ritual Instruments

| ID | Name | Role |
|---|---|---|
| `varinha_cinzas` | Varinha de Cinzas | Initial balanced Arcano instrument. |
| `grimorio_veu` | Grimorio do Veu | Mental control, fear and compulsion. |
| `athame_hematico` | Athame Hematico | Fisico/Sangue wounds, bleeding and execution. |
| `cajado_ossario` | Cajado Ossario | Morte/Terra, summons, protection and decay. |
| `orbe_tempestade` | Orbe da Tempestade | Vento/Raio, interruption, speed and conductor setups. |
| `selo_mare_fria` | Selo da Mare Fria | Agua/Gelo, control, wet, freeze and defense. |
| `idolo_pedra_viva` | Idolo de Pedra Viva | Terra/Fisico, guard, rooting and fracture. |
| `cetro_braseiro_negro` | Cetro do Braseiro Negro | Fogo/Morte, burning, ashes and sustained pressure. |

## Spells

Mental:

- `sussurro_medo` - applies Inquietacao/Medo setup.
- `terror_primordial` - turns fear pressure into Terror.
- `labirinto_razao` - applies Confusao and cadence disruption.
- `mandato_oculto` - applies Compulsao and tempo loss.

Corporeal:

- `incisao_ritual` - Fisico/Sangue wound opener.
- `hemorragia_induzida` - Blood DoT pressure.
- `coagulo_negro` - defensive blood barrier.
- `toxina_palida` - Veneno and Vitalidade pressure.
- `marca_brasa` - Fogo setup and burn.
- `coroa_cinzas` - Fogo/Morte payoff against marked targets.
- `mare_escura` - Agua and Molhado setup.
- `geada_ossos` - Gelo slow and body stiffening.
- `prisao_gelo` - stronger Gelo control.
- `raizes_pedra` - Terra root and guard.
- `lamina_vento` - Vento/Fisico fast damage.
- `descarga_nervosa` - Raio and conductor pressure.

Funeral:

- `putrefacao` - Morte DoT and anti-regeneration pressure.
- `marca_sepulcral` - Morte vulnerability setup.
- `erguer_ossos` - defensive death summon.
- `invocar_brasa_faminta` - offensive fire/death summon.

## Doutrines

Doutrines replace the player-facing "generic passive" fantasy, while the technical passive slot remains.

| ID | Name | Role |
|---|---|---|
| `doutrina_pavor` | Doutrina do Pavor | Mental control and fear pressure. |
| `mente_fria` | Mente Fria | Vontade and received-control resistance. |
| `anatomista_profano` | Anatomista Profano | Fisico, wounds and blood pressure. |
| `sangue_obediente` | Sangue Obediente | Blood sustain, coagulation and lifesteal. |
| `alquimia_toxica` | Alquimia Toxica | Venom, weakness and body corrosion. |
| `cinza_viva` | Cinza Viva | Fire, burn and ash marks. |
| `mare_silenciosa` | Mare Silenciosa | Water/ice, slow and freeze control. |
| `pedra_interna` | Pedra Interna | Guarda, Tenacidade and earth defense. |
| `pulso_tempestade` | Pulso de Tempestade | Wind/lightning rhythm and interruptions. |
| `ossuario_interior` | Ossuario Interior | Death, summons and anti-regeneration. |
| `pacto_familiar` | Pacto Familiar | Familiar cadence, pressure and status support. |

## Familiars

Familiars may be visible creatures or abstract entities. Both forms are valid.

| ID | Name | Form | Role |
|---|---|---|---|
| `corvo_pressagio` | Corvo do Pressagio | Creature | Mental/Morte mark support. |
| `sanguessuga_sacramental` | Sanguessuga Sacramental | Creature | Blood drain and bleeding. |
| `serpente_toxina` | Serpente de Toxina | Creature | Venom and Vitalidade pressure. |
| `cao_cinzas` | Cao de Cinzas | Creature | Fire sustained pressure. |
| `medusa_mare_fria` | Medusa de Mare Fria | Creature/entity | Water/ice slow support. |
| `escaravelho_pedra` | Escaravelho de Pedra | Creature | Guard, earth and root support. |
| `serpe_tempestade` | Serpe de Tempestade | Creature | Wind/lightning conductor support. |
| `cranio_errante` | Cranio Errante | Entity | Death and decay support. |
| `olho_veu` | Olho do Veu | Abstract entity | Mental control and weakness reveal. |

## Removed Or Reworked Placeholder Concepts

- `Magico` source is reworked to `Arcano`.
- `Choque` source is reworked to `Raio`.
- `Sangramento` source is reworked to `Sangue`; Sangramento remains a status.
- `Varinha Magica` is reworked to the initial Ritual Instrument `Varinha de Cinzas`.
- Generic passives `Forca`, `Resistencia`, `Escudo`, `Vampirismo` and `Velocidade` are reworked into named Doutrines.
- The rule "one pet per damage type" is removed. Familiars are role-first.
- Early status names can inspire behavior, but they are no longer literal final taxonomy.
