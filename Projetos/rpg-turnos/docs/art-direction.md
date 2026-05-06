# Art Direction

- Last Updated: `2026-05-04`
- Status: `active — design phase, no final assets yet`

This document is the single source of truth for all visual production on rpg-turnos. It maps the current state of every screen, defines the visual direction, specifies the card anatomy, and tracks every asset that needs to be produced.

---

## 1. Visual Identity

### Tone

Dark astral tactical science-fantasy. The game should feel like an ether-plasm command surface for a Draxos invasion of an elemental planet: readable, deliberate, alien, and charged with astral energy. Avoid the old generic-fantasy placeholder language as active visual direction.

### Reference keywords

Intimate, readable, deliberate. Every element on screen should look like it belongs on the same table.

### Color palette

All current screens already share a coherent dark base. This should be formalized as a design system.

| Token | Hex | Current usage |
|---|---|---|
| `bg_deep` | `#0B0D0F` | Screen backgrounds |
| `bg_panel` | `#181C1F` | Panel backgrounds |
| `bg_panel_alt` | `#141618` | Secondary panels |
| `border_default` | `#3D484F` | All panel borders |
| `border_active` | `#5A7080` | Highlighted / focused elements |
| `text_primary` | `#E0E0D8` | Main labels |
| `text_secondary` | `#8A9298` | Subtitles, secondary info |
| `text_phase` | `#B0C0C8` | Phase/mode indicators |

These should eventually live in a Godot `Theme` resource so no file hardcodes raw Color values.

### Card type color identity

Each card type gets a distinct accent used for the card frame border, type badge background, and slot tint.

| Type | Accent | Feel |
|---|---|---|
| `criatura` | `#4A7A5A` (forest green) | Living, organic |
| `estrutura` | `#5A6A7A` (slate blue) | Solid, immovable |
| `permanente` | `#7A6A3A` (amber) | Persistent, old magic |
| `magia` | `#6A4A7A` (deep violet) | Volatile, bright |
| `comando` | `#7A4A4A` (blood red) | Tactical, urgent |

### Typography

Currently: `ThemeDB.fallback_font` everywhere (system font, uncontrolled).

Target:
- **Title / header**: a serif or slab font — weight, authority
- **Card name**: medium weight sans, 14–16px, all caps or title case
- **Card body text**: small serif or mono, 10–11px, must be legible on dark background
- **HUD labels**: tabular figures, clean sans

Font decisions can be deferred until final art pass. For now, identify and import a single font family that covers all weights, and replace all fallback_font calls.

---

## 2. Card Design

### Current state

`BattleCardToken` (156×82px) and `CardToken` (148×118px normal / 132×70px compact) are plain `PanelContainer` nodes with text labels. No art frame, no type color, no illustration area. All card types look identical.

### Target anatomy (full card — deck setup view)

```
┌──────────────────────────────┐  ← type-color frame border (3px)
│  [TYPE BADGE]    [COST ●●○]  │  ← top bar: type label + energy pips
├──────────────────────────────┤
│                              │
│      [ILLUSTRATION AREA]     │  ← 60% of card height
│                              │
├──────────────────────────────┤
│  Card Name              ATK  │  ← name left, stat right
│  ──────────────────────────  │
│  Card text / ability line    │  ← 2 lines, small font
│  [rapido] [voadora]          │  ← keyword chips if present
└──────────────────────────────┘
```

Full card size: 148×180px (increase height from 118 to accommodate illustration)

### Target anatomy (battle token — hand view)

```
┌──────────────────────┐  ← type-color left stripe (4px)
│ Name        ATK / HP │
│ Cost: X              │
│ [keyword chip]       │
└──────────────────────┘
```

Battle token: 160×82px (current) — keep width, add left-stripe color.

### Energy cost pip display

Replace "Custo X" text with energy pips (filled circles). Max visible pips: 5. If cost > 5, show "X●".

### Keyword chips

Small rounded label, background from accent palette, white text, 10px. Examples: `[Rápido]` `[Voadora]` `[Defensor]`. Should appear in both deck setup card and battle token.

### Card back

For deck counter display and shuffle animation: plain `bg_panel` background with a centered emblem (TBD — could be a simple sigil or pattern). Must be distinct from card fronts.

---

## 3. HUD — Battle Screen

### Current state

One `status_label` that prints everything as a single string:
`"Turno 2 | Energia: 3/5 | Armadura: 1 | HP: 20 | Deck: 14"`

This is functional but not animatable, not scannable, and not expandable.

### Target HUD layout

Based on Phase H wireframe from `implementation/current-status.md`:

```
┌─────────────────────────────────────────────────────────────────────┐
│ [Turno 2]  [MODO: LIMPAR MESA]  [Fase: Principal]  [Prioridade: ●] │
├──────────────────────────────────────────────────────────────────────┤
│  INIMIGO: —  nenhum herói inimigo                    [HP] ░░░░░ 20  │
│  Rota A  [slot inimigo]  [slot inimigo]                              │
│  Rota B  [slot inimigo]  [slot inimigo]                              │
├──────────────────────────────────────────────────────────────────────┤
│  Rota A  [slot jogador]  [slot jogador]                              │
│  Rota B  [slot jogador]  [slot jogador]                              │
│  JOGADOR: HP [████░] 20  ENERGIA [███░░] 3/5  ARM [1]  DECK [14]   │
├──────────────────────────────────────────────────────────────────────┤
│  [mão de cartas]                                                     │
│  [Preparar Defesa]  [Passar Prioridade]  [Descarte: 0]              │
└─────────────────────────────────────────────────────────────────────┘
```

### Individual HUD nodes (Phase H requirement)

These must become discrete Label nodes (named, not in a composite string):

| Node name | Content |
|---|---|
| `turno_label` | "Turno X" |
| `modo_label` | "Limpar Mesa" (display name, not ID) |
| `phase_label` | "Principal" (display name) |
| `priority_label` | colored dot — player vs enemy |
| `player_hp_label` | numeric HP |
| `player_hp_bar` | ProgressBar or custom draw |
| `energy_label` | "X/Y" |
| `energy_bar` | pip row or ProgressBar |
| `armor_label` | armor value |
| `deck_label` | deck count |
| `hand_count_label` | cards in hand |
| `discard_counter_label` | how many to discard (Phase H7) |

### Phase display names

The phase IDs are internal. HUD must map them to Portuguese display names:

| ID | Display |
|---|---|
| `manutencao` | Manutenção |
| `compra` | Compra |
| `fase_principal` | Principal |
| `descarte` | Descarte |
| `encerrada` | — |

### Mode display names

| ID | Display |
|---|---|
| `limpar_mesa` | Limpar Mesa |
| `duelo` | Duelo |
| `ondas` | Ondas |

---

## 4. World Map

### Current state

Entirely `_draw()` calls: a flat green rectangle for the map area, a blue circle for NPC, an orange square for the encounter marker, a cream circle for the player. Labels drawn as strings above shapes.

This is a functional placeholder. No paths, no environment art, no character representation.

### Short-term improvement (no art assets needed)

- Replace plain shapes with `ColorRect` panels using styled borders
- Add simple path line between NPC and encounter marker
- NPC marker: distinct icon shape (pentagon or diamond) with name tag
- Encounter marker: warning-triangle or sword icon (drawn, not imported)
- Player: arrow or cursor shape indicating direction
- Add a background texture overlay (generated gradient or tiled `_draw` hatching)

### Medium-term (requires art assets)

- Background: painted or illustrated map environment (ether landing zone, ash field, crystal vents, elemental terrain)
- NPC sprite or portrait icon
- Encounter markers styled per encounter type (landing zone, conduto, bastiao, nucleo, selos)
- Player token with facing direction

### Long-term

- Animated player movement on map
- Encounter markers with animated "active" state
- Multiple map zones unlocking

---

## 5. Menus

### Main Menu (boot screen)

**Current**: "RPG Turnos" in 38px default font, "Slice jogavel inicial" subtitle, two buttons on a plain dark panel.

**Needs:**
- Game logo / title treatment (typography or illustrated)
- Background environment art or animated particle background
- Replace subtitle "Slice jogavel inicial" with actual tagline or leave blank
- Menu button styling beyond default Godot theme

### Deck Setup Screen

**Current**: functional two-column drag-and-drop. Layout is solid.

**Needs:**
- Card type color applied to pool and deck cards (left border stripe per type)
- Pool section header shows card count clearly
- Deck slots: empty slot indicator (dashed border with slot number)
- Valid deck state: visual confirmation beyond button enable/disable (e.g., border color change on deck panel)

### Result Screen

**Current**: "Vitoria" or "Derrota" in plain text. Both look identical.

**Needs:**
- Victory: warm accent color, celebratory layout, summary of what was achieved
- Defeat: cooler/darker palette, summary of what happened
- Reward display for victory: show card earned (if applicable)
- Retry prompt styled differently from the victory return prompt

---

## 6. Dialogue System

### Current state

Plain `dialogue_panel` at screen bottom with text and "Fechar" button. No speaker name, no portrait.

### Needs

- Speaker name label above dialogue text
- Portrait panel (64×64 or 80×80) to the left of text
- Placeholder portrait per NPC type (silhouette with type color until art exists)
- Dialogue text animation (typewriter, optional)

---

## 7. Asset Production Checklist

Priority levels: 🔴 blocking gameplay feel · 🟡 important for first impression · 🟢 polish

### Design system

| Asset | Priority | Status |
|---|---|---|
| Godot Theme resource with color tokens | 🔴 | missing |
| Font family selected and imported | 🔴 | missing |
| Phase display name map (GDScript dict) | 🔴 | missing |
| Mode display name map | 🔴 | missing |

### Card visuals

| Asset | Priority | Status |
|---|---|---|
| Card frame per type (criatura) | 🔴 | missing |
| Card frame per type (magia) | 🔴 | missing |
| Card frame per type (estrutura) | 🟡 | missing |
| Card frame per type (permanente) | 🟡 | missing |
| Card frame per type (comando) | 🟡 | missing |
| Energy cost pip component | 🔴 | missing |
| Keyword chip component | 🔴 | missing |
| Card illustration placeholder (gray box) | 🟡 | missing |
| Card back design | 🟡 | missing |

### HUD components

| Asset | Priority | Status |
|---|---|---|
| HUD refactor: discrete label nodes | 🔴 | missing (Phase H) |
| HP bar visual | 🔴 | missing |
| Energy pip row | 🔴 | missing |
| Route/lane visual markers | 🟡 | missing |
| Slot occupied / empty visual state | 🟡 | missing |
| Damage number styled labels | 🟡 | missing |
| Descarte counter + UI panel | 🔴 | missing (Phase H7) |
| Priority indicator (animated dot) | 🟡 | missing |

### World map

| Asset | Priority | Status |
|---|---|---|
| Improved shape markers (no art needed) | 🟡 | missing |
| NPC portrait silhouette for dialogue | 🟡 | missing |
| Path line between markers | 🟢 | missing |
| Background environment (requires art) | 🟢 | missing |

### Menus

| Asset | Priority | Status |
|---|---|---|
| Game title typography / logo | 🟡 | missing |
| Main menu background | 🟢 | missing |
| Button style override | 🟡 | missing |
| Result screen victory/defeat styling | 🟡 | missing |

### Audio (entire category deferred)

| Asset | Priority | Status |
|---|---|---|
| Card play sound | 🟡 | missing |
| Attack / damage sound | 🟡 | missing |
| Victory / defeat jingle | 🟡 | missing |
| Ambient battle loop | 🟢 | missing |
| UI navigation sounds | 🟢 | missing |

---

## 8. Implementation Order

The visual work maps to Phase H in `implementation/current-status.md`. The recommended sequence before touching art assets:

1. **Design system first** — create a Theme resource and a `UiTokens` autoload dict with color tokens and display name maps. Remove all hardcoded `Color(...)` from screen files.
2. **HUD refactor** — break `status_label` into discrete named nodes. This unblocks animation and makes Phase H testable.
3. **Card left-stripe color** — minimal visual type differentiation with zero art assets. Add a 4px `ColorRect` on the left edge of each token using the type accent.
4. **Keyword chips** — pure code, no art. Small rounded label per keyword in card data.
5. **Energy pips** — replace "Custo X" text with pip row component.
6. **Result screen** — victory vs defeat visual differentiation.
7. **Font import** — select and import one font family.
8. **Card illustration placeholder** — gray region in card to reserve space before art arrives.
9. **Full card art frames** — first art assets to produce once visual direction is locked.
