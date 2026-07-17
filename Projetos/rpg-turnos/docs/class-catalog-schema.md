# RPG Turnos — class catalog schema

## Metadata

- status: `active`
- authority: `technical_contract`
- last_verified: `2026-07-17`
- review_when: `the authored class JSON, resource projection or ContentLibrary contract changes`
- supersedes: `five-class prospective schema from 2026-05-12`
- superseded_by: `none`

This contract describes the three classes already implemented in `../data/definitions/slice_catalog.json`. Exact content belongs to JSON; this document governs shape and ownership.

## Sources and projection

- Authoring source: `../data/definitions/slice_catalog.json`.
- Generator: `../tools/content_generator.gd`.
- Generated projection: `../data/generated/slice_catalog.tres`.
- Resource schema: `../data/resources/slice_catalog_resource.gd`.
- Runtime reader: `../data/content_library.gd`.
- Session identity: `GameSession.selected_class` in `../core/game_session.gd`.

The generated `.tres` is never the authoring source. Regeneration must be reviewed and repeated validation must leave no additional tracked diff.

## Class entry

```json
{
  "id": "invocador",
  "display_name": "Invocador",
  "tagline": "Buffs permanentes. Cada invocação fortalece o campo.",
  "passiva": {
    "id": "comandante_de_campo",
    "display_name": "Comandante de Campo",
    "text": "..."
  },
  "hero": {
    "id": "invocador_heroi",
    "display_name": "Comandante Draxos",
    "max_health": 25,
    "hero_power": {
      "id": "amplificar",
      "display_name": "Amplificar",
      "cost": 1,
      "speed": "normal",
      "once_per_own_turn": true,
      "text": "...",
      "effect": {"action": "gain_stats", "target": "any_own_creature"}
    }
  },
  "starter_deck": ["20 card ids"]
}
```

Required class fields are `id`, `display_name`, `tagline`, `passiva`, `hero` and `starter_deck`. IDs are stable persistence keys and must not be renamed without save compatibility.

## Nested contracts

`passiva` requires `id`, `display_name` and `text`. Runtime recognizes the implemented IDs:

- `comandante_de_campo` for Invocador;
- `fluxo_continuo` for Arcano;
- `colheita_sombria` for Necromante.

`hero` requires `id`, `display_name`, positive `max_health` and structured `hero_power`.

`hero_power` requires `id`, `display_name`, nonnegative `cost`, `speed`, `once_per_own_turn`, `text` and `effect`. Effect dispatch is data-driven, but an unknown `action` is invalid rather than an invitation to infer behavior.

`starter_deck` contains exactly 20 existing card IDs. Duplicate IDs represent copies. Every class deck must work without an enemy hero in all modes except rules explicitly restricted to `duelo`.

## Implemented hero-power effects

| Class | Power | Effect contract |
|---|---|---|
| Invocador | `amplificar` | `gain_stats`, +2/+0 permanent, `any_own_creature`. |
| Arcano | `pulso_astral_arcano` | `damage`, amount 1, `magico`, `any_permanent_or_hero`, `fluxo_bonus: true`. |
| Necromante | `ritual_das_sombras` | `ritual_das_sombras` with tiers at 2/4/6 Cinzas. |

Class-specific rules and player-facing text remain in `classes/`. Battle behavior remains in the engine and GDD; JSON cannot silently create a new mechanic.

## Compatibility

- Empty or absent `selected_class` uses the generic starter deck and `Preparar Defesa` only as legacy fallback.
- Invalid non-empty class IDs do not become a class.
- Save v1→v2 migrates encounter IDs, not class mechanics; the input dictionary must not be mutated.
- The discarded five-class design is historical and recoverable in Git. It is not canon, an implementation queue or a schema extension surface.

## Validation

The contract suite must prove:

- exactly Invocador, Arcano and Necromante exist;
- every required nested field has the expected type;
- every starter deck has 20 valid card IDs;
- `ContentLibrary` returns defensive copies of class, hero, power and deck data;
- selection and save/load preserve valid class IDs and safely handle missing/invalid values;
- generated resources match authored JSON and a second full validation leaves the tree unchanged.
