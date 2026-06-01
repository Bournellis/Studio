# Mode Descriptors

- Status: `CONTRATO_DADOS`
- Schema: `mode_descriptor_v1` + `mode_placeholder_v1`
- Scope: declarative scaffolds only.

This folder declares the five official DraxosMobile modes without adding new
gameplay, tuning, rewards, schema or backend behavior.

Each official mode folder must contain:

- `metadata.json`: stable mode identity, current status, entry route/action,
  ruleset pointer, ownership and docs.
- `placeholder.json`: non-playable reservation for future slices or future
  playable work. It must keep `playable`, `launchable` and `reward_enabled`
  set to `false`.

The current client registry exposes these paths through
`modes/boot/ui/mode_shell_registry.gd`. Runtime gameplay remains owned by the
existing surfaces:

- Basebuilder: current Refugio/Base shell.
- Autobattler: current Arena PVE shell.
- Openworld: current Openworld Bosque Internal Alpha shell.
- Towerdefense/Cardgame: staged and disabled.

Future modes or slices should start from `_template/`, then receive an explicit
package decision before any playable code, reward bridge, tuning or backend
mutation is added.
