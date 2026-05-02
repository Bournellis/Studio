# Unity To Godot System Map

Historical note: this file records the original cutover mapping from the legacy Unity surface to the Godot validation surface. It is not part of the active daily read order.

## Shared Boundary Mapping

| Shared Boundary | Unity Surface | Godot Surface |
| --- | --- | --- |
| `Foundation` | `Assets/Game/Code/Foundation` | `autoloads/` + reusable `Resource` and contract scripts |
| `Gameplay` | `Assets/Game/Code/Gameplay` | `gameplay/` |
| `Presentation` | `Assets/Game/Code/Presentation` | `presentation/` |
| `Composition` | `Assets/Game/Code/Composition` | `modes/` scene roots + launch/bootstrap seams |
| `Online` | `Assets/Game/Code/Online` | `online/` |

## First Godot Slice Mapping

| Capability | Unity Reference | Godot Target |
| --- | --- | --- |
| Frontend mission/loadout entry | `FrontEndSceneEntry`, `FrontEndShellPresenter` | `modes/frontend/` minimal real shell |
| Loadout validation | `MissionLoadoutValidator` | `gameplay/loadouts/` validation around generated resources |
| Combat runtime | `PlayerCombatController` | `gameplay/player/` combat controller in GDScript |
| Arena loop | `ArenaMatchController` | `modes/arena/` loop owner |
| Shared HUD shell idea | `Phase3CombatHudPresenter` | `presentation/hud/` PT-BR combat shell for first slice |
| Bot baseline | Arena Bot behavior and session flow | simple `gameplay/bot/` chase-and-attack opponent |
| Result/return flow | Unity results presenters and frontend return | minimal results overlay and return-to-frontend path |

## Transition Rule

The Godot implementation should inherit contracts and intent, not literal engine-specific structure.

Prefer:

- contract-level equivalence
- reusable generated data
- PT-BR player-facing labels
- PC-first playable loop

Avoid:

- copying Unity scene serialization assumptions
- porting Unity editor-specific workflows directly
- reopening Unity-only legacy concepts such as passives or weapon swap
