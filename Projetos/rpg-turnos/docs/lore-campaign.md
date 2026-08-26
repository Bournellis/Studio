# RPG Turnos Lore Campaign

## Metadata

- status: `frozen`
- authority: `product_contract`
- last_verified: `2026-08-26`
- review_when: `shared lore changes or RPG Turnos explicitly adopts new local narrative`
- supersedes: `lore pointer delegated to the Roguelike project`
- superseded_by: `none`

Shared-universe binding: `../STUDIO_CORE.md`. Shared facts come only from the
adopted `shared_foundation`, `draxos` and `draxos_elemental_expedition` domains
in Studio Core revision `lore.v2`. The exact cross-project authority is
`D:\Studio Core\universe\windows\DRAXOS_ELEMENTAL_EXPEDITION.md`.

## Lore Authority

Studio Core is the sole authority for reusable Draxos facts and for the lore,
characters, classes, narrative and general expedition objective shared with
Draxos Roguelike. This file owns only the RPG Turnos manifestation and local
narrative delivery.

The Roguelike remains a separate product and is not a mechanics or
implementation authority for this project. Neither game's local documents are
a second shared authority; any change to the shared axis must first be authored
in Core and then adopted by both bindings.

## What RPG Turnos Owns

RPG Turnos owns its class mechanics, encounter rules, progression systems, runtime and implementation.

Its encounter arc and concrete delivery remain local. Only the lore, characters, classes, narrative and general objective enumerated by the adopted Core window are shared; new local details do not rise to that window automatically.

## Class Lore

The three active classes are Invocador, Arcano, and Necromante. Their names, fiction and roleplay identity are shared with Draxos Roguelike through the adopted Core window.

Their combat doctrines, starter decks, passive abilities, hero powers and board behavior are local RPG Turnos mechanics. The class documents must point to Core for shared identity and to themselves for mechanics.

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

Each encounter has a `mission` field in the catalog that states its operational purpose. The eight chain IDs were migrated in P20 to `operacao_pouso`, `confronto_guardiao`, `tomada_conduto`, `avanco_bastiao`, `ondas_resistencia`, `defesa_base_ether`, `nucleo_fragmentado` and `ruptura_selos` with save v1→v2 compatibility.

Five side encounter IDs remain unchanged and require a future local lore decision before any rename: `patrulha_avancada`, `duelista_sombrio`, `emboscada_reforcos`, `escolta_vulcanica` and `reduto_eter`.
