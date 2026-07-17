# RPG Turnos Lore Campaign

## Metadata

- status: `frozen`
- authority: `product_contract`
- last_verified: `2026-07-17`
- review_when: `shared lore changes or RPG Turnos explicitly adopts new local narrative`
- supersedes: `lore pointer delegated to the Roguelike project`
- superseded_by: `none`

Shared canon: `../../../canon/shared-lore/shared-lore.md` and `../../../canon/shared-lore/draxos-invasion.md`.

## Lore Authority

Shared lore is the studio authority for reusable Draxos facts. This file is the local authority for the campaign framing explicitly adopted by RPG Turnos.

The Roguelike is a separate product and is not a lore or mechanics authority for this project. Any cross-project idea must first be promoted to shared lore and then adopted here.

## What RPG Turnos Owns

RPG Turnos owns its mechanics, classes, encounter rules, and progression systems.

It does not own a separate Draxos story. Setting, characters, world, and narrative framing come from the shared lore.

## Class Lore

The three active classes are Invocador, Arcano, and Necromante. Each represents a Draxos mage specialty with its own combat doctrine, starter deck, passive ability, and hero power.

Their detailed in-universe roles remain deliberately undefined. Future anchoring must use shared lore plus an explicit local decision; another project's character work cannot define it implicitly.

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
