# DraxosMobile Asset Pipeline

Track 05 prepares the project to receive real art later. This folder currently
contains no final art. Runtime must keep working with procedural visuals and
native Godot placeholders while files under `assets/` are missing.

## Folder Contract

Use these folders for the current `AssetIds` manifest:

| Folder | Current ids | Purpose |
|---|---|---|
| `assets/ui/` | `ui_*`, `icon_*`, `placeholder_card` | Hub, shell, cards and generic UI imagery. |
| `assets/portraits/` | `portrait_*` | Character and bot portraits. |
| `assets/battle/characters/` | `battle_character_*` | Main battle actor sprites, portraits or atlases. |
| `assets/battle/icons/` | `battle_icon_*` | Event, spell, status, reward and result icons. |
| `assets/battle/fx/` | `battle_fx_*` | Small effect sprites or sprite sheets for battle feedback. |

Do not place production files in the root `assets/` folder. Add a subfolder and
an `AssetIds` category before introducing a new asset family.

## Naming

- File names use lowercase `snake_case`.
- Runtime ids stay stable and semantic: `battle_icon_spell`, not
  `blue_fire_icon_v3`.
- One runtime id maps to one canonical path in `core/asset_ids.gd`.
- Variants go in the file name only when the runtime contract needs them, for
  example `battle_fx_hit_small.png`; otherwise replace the file at the stable
  path through a normal art update.
- Avoid spaces, accents, uppercase letters and version suffixes in runtime
  filenames. Versioning belongs in source art tooling or Git history.

## Formats

- Use `.png` for UI, portraits, icons, character sprites and transparent battle
  effects unless a later asset decision explicitly changes the registered path.
- Use `.webp` only for future large opaque backgrounds after the id is added with
  that extension from the start.
- Do not commit layered source formats such as `.psd`, `.kra`, `.clip`, `.ai` or
  `.blend` into the Godot runtime asset tree.
- Do not add final audio, video or 3D assets through this Track 05 package.

## Target Sizes

Targets are upper bounds for first real-art imports, not requirements for this
track:

| Asset family | Target size | Notes |
|---|---:|---|
| UI icon | `128x128` | Readable at small Android touch targets. |
| Small UI marker | `64x64` | Only for simple symbols with no text baked in. |
| Logo | Up to `1024x512` | Transparent PNG; preserve safe padding. |
| Boot/background image | `1920x1080` | Keep current `boot_background.png` path stable if used. |
| Portrait | `512x512` | Square crop, transparent or clean background. |
| Battle character | Up to `768x768` | Prefer transparent PNG; keep pivot requirements documented near the importer. |
| Battle icon | `128x128` | No text baked into the art. |
| Battle FX frame/sheet | Frame `256x256`, sheet up to `2048x2048` | Use only when procedural FX is being intentionally replaced. |

## Godot Import Policy

- Import real files through the Godot editor once art work starts, and commit the
  source runtime file plus its generated `.import` metadata together.
- Do not hand-edit `.import` files. If import settings must change, update them
  through the editor and review the generated diff.
- Keep 2D textures as 2D assets; do not enable 3D import assumptions for UI or
  battle sprites.
- Disable repeat for UI, portrait, icon and battle sprite textures.
- Do not create custom import plugins or generated resources in this track.
- Run `tools/smoke_exports.gd` after import-policy changes so Android, PC and
  Web presets still accept the project.

## Fallback Policy

- Missing art is allowed. `AssetIds.has_art(id)` may return `false` for any
  registered id.
- `AssetIds.texture(id)` must return `null` when art is absent; callers must keep
  procedural visuals or native Godot controls available.
- Tests and smokes must not require a real file under `assets/` unless the test is
  explicitly for an imported asset package after Track 05.
- Battle replay remains server-authoritative and procedural when art is missing.
  Art must never change event ordering, damage, rewards, economy or ranking.

## Id Stability

- Do not rename an existing id or change an existing path casually. These strings
  are part of the client-side visual contract and may appear in docs, tests and
  future content.
- If an id must be retired, keep a compatibility alias until all references and
  saved visual metadata are migrated.
- New ids must be added to `AssetIds.CATEGORY_IDS`, `AssetIds.PATHS`, this README
  when a new folder/family is involved, and GUT coverage in `tests/client/`.
- A path migration requires a small dedicated commit with test updates and an
  explicit note in Track 05 or the active track that owns the change.
