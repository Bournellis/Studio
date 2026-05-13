# RPG Turnos Lore Campaign

- Last Updated: `2026-05-13`
- Status: `pointer — lore authority delegated`
- Shared Canon: `../../canon/lore/shared-lore.md`, `../../canon/lore/draxos-invasion.md`

## Lore Authority

RPG Turnos shares all Draxos lore with `Projetos/draxos-roguelike-cardgame`.

The authoritative lore document is:

`Projetos/draxos-roguelike-cardgame/docs/lore-campaign.md`

Do not maintain a parallel Draxos narrative here. Any story direction for RPG Turnos must be consistent with that document and with `canon/lore/draxos-invasion.md`.

## What RPG Turnos Owns

RPG Turnos owns its mechanics, classes, encounter rules, and progression systems.

It does not own a separate Draxos story. Setting, characters, world, and narrative framing come from the shared lore.

## Class Lore

The three active classes are Invocador, Arcano, and Necromante. Each represents a Draxos mage specialty with its own combat doctrine, starter deck, passive ability, and hero power.

Their in-universe roles within the Draxos expedition hierarchy are still being defined. Narrative anchoring for each class — how they fit within Draxos society, what their training path looks like, and how NPCs refer to them — should be developed in coordination with the shared lore and the roguelike's character and NPC work.

## Encounter Arc

The current world map runs eight encounters as a linear Draxos operation:

1. **Operacao de Pouso** — secure the landing zone (limpar_mesa)
2. **Confronto com Guardiao** — duel the sector guardian (duelo)
3. **Tomada do Conduto** — capture the astral conduit at the crossroads (limpar_mesa)
4. **Avanco ao Bastiao** — break through the gorge stronghold (limpar_mesa)
5. **Ondas de Resistencia** — repel coordinated elemental counter-attack (ondas)
6. **Defesa da Base de Ether** — hold the ether base perimeter (defesa)
7. **Nucleo Fragmentado** — destroy the multi-part elemental construct (chefe_multiparte)
8. **Ruptura de Selos** — break the astral seals blocking the volcano path (quebra_cabeca)

Each encounter has a `mission` field in the catalog that states its operational purpose. Technical IDs (`emboscada_na_ponte`, `duelista_bandido`, etc.) are legacy placeholders and should not be renamed until a dedicated compatibility pass.
