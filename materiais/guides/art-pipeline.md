# Art Pipeline

## Purpose of This Document

This document is the visual production reference for the game. It defines the art direction already decided, the production philosophy, the tool chain, and the pipeline for every visual category the game requires.

This document does **not** define production order for specific tracks or gates. That is handled by the active operational docs under `Projetos/rpg-isometrico/implementation/`. Its purpose is to be the permanent guide that answers "how do we produce this type of asset?" for any content produced at any point in the project.

Read this document before producing or commissioning any visual asset.

---

## 1. Visual Identity — Decided

The visual direction of the game is fixed and does not need to be rediscovered per asset or per phase.

**Style:** Low-poly 3D stylized
**Atmosphere:** Dark and intense
**Shader:** Toon shader with rim light
**Lighting:** Punctual accent lighting; dark base with bright highlight points
**Combat feedback:** Bright, high-contrast particle effects against dark environments
**Reference:** Hades, Returnal (impact intensity and color contrast — not art style)

Every asset produced must be evaluated against these criteria:
- Does it read clearly in a dark environment?
- Does it have enough contrast to be legible at isometric distance?
- Does it look like it belongs to the same dark-stylized world as the other assets?

---

## 2. Structural Constraint: The Isometric Camera

The game camera is always isometric, always fixed, and always non-rotating. This is not a preference — it is a design pillar.

This has direct consequences for every art decision:

**Silhouette must be designed for the isometric angle.** A character that looks great in a viewport front view may be unreadable in the actual game camera. Every asset — character, enemy, weapon, VFX, UI — must be validated in the real game camera before being considered complete, even at placeholder quality.

**Top-surface clarity matters.** In isometric view, the top of a character's torso, head, and weapon are highly visible. Asset details should be concentrated where the camera actually reveals them.

**VFX must spread laterally and vertically.** A particle effect that only expands forward (toward the camera) will be nearly invisible. All combat VFX must be authored with the isometric angle as the primary view.

**Arena readability comes before environment beauty.** The environment exists to support combat clarity, not to be its own visual star. The character, enemy, and VFX must always dominate the frame.

Exact camera values live in the active Godot implementation and must be validated in the current playable camera before an asset is considered ready.

---

## 3. The Race System as the Visual Architecture

The most important thing this pipeline must account for is the **race system**. This game is not built around a single protagonist — it is built around four distinct races, each with its own visual world, technology philosophy, and weapon identity.

Each race is a visual package:

| Race | Visual World | Technology / Aesthetic |
| --- | --- | --- |
| Humans | Military, tactical, contemporary | Firearms, explosives, tactical gear, no magic |
| Heroic | Ancient, mythological, dark fantasy | Magical ancient weapons — hammer, bow, sword, spear |
| Intelligent Aliens | Futuristic, technological, alien | Lasers, magnetic devices, drone summons |
| Magic Beings | Arcane, ethereal, powerful | Teleportation, mental manipulation, pure arcane |

These are not skins of the same base character. They are fundamentally different visual worlds. A Human soldier and a Heroic warrior share a humanoid rig structure but nothing else.

This means the pipeline must be designed to accommodate **visual identity per race**, not just per character. When producing a new weapon, skill, or VFX, the asset must look like it belongs to its race's world — not just like it belongs to the game in general.

---

## 4. The Weapon as the Center of the Animation Library

In this game, **the weapon drives the animation library, not the character**. Each weapon has:

- Its own Basic Attack pattern (combo structure and cadence unique to that weapon)
- Its own Movement Skill / Dash (inherent to the weapon)
- Its own pool of skills that can support the canonical 4 selected skill slots, with base, upgrade, and ultimate tiers where applicable

This means the animation set is organized per weapon, not per character. The same humanoid body can carry multiple weapons, but each weapon requires its own combat animation set.

### Minimum Animation Set per Weapon

| Animation | Notes |
| --- | --- |
| Idle | Weapon-appropriate resting pose |
| Walk | Standard locomotion |
| Run | Standard run cycle |
| Basic Attack — Hit 1 | Weapon-specific attack 1 |
| Basic Attack — Hit 2 | Weapon-specific attack 2 |
| Basic Attack — Hit 3 | Weapon-specific attack 3 (if combo) |
| Movement Skill / Dash | Weapon-specific dash animation |
| Skill 1 — Cast | Base cast animation |
| Skill 2 — Cast | Base cast animation |
| Skill 3 — Cast | Base cast animation |
| Skill 4 — Cast | Base cast animation |
| Hit React | Weapon-held impact reaction |
| Death | |
| Reload / Resource Action | Only for weapons with reload (e.g., Assault Rifle) |

Skills with Ultimate upgrades may require additional or modified animations, but the base cast animation is the minimum.

### Shared vs. Weapon-Specific Animations

Some animations can be shared across weapons using humanoid rig retargeting and the Godot import/animation pipeline where feasible:

- **Shared across all humanoids:** Idle base, Walk, Run, Hit React (universal impact), Death (universal)
- **Weapon-specific (cannot be shared):** All attack animations, the weapon's dash, skill casts that involve weapon motion, reload/resource actions

This distinction is critical for planning animation production cost per weapon.

---

## 5. Tools — Confirmed Pipeline

The production pipeline for this project is:

**3D Characters and Weapons:**
Meshy / Tripo3D (AI 3D generation) → Blender (cleanup, scale, pivot, rig prep, export) → Mixamo or authored rigs/animations where useful → Godot (AnimationPlayer/AnimationTree, final integration)

**Godot handoff format:**
Prefer `glTF 2.0` as `.glb` for current Godot asset handoff. Use `FBX` only when a specific upstream asset or animation workflow behaves better there and `glTF` is not viable.

**2D Assets (UI, Icons, Concepts):**
AI image generation (concepts, bases, ornaments) → Photoshop / Krita (cleanup, standardization, export) → Figma (UI layout, component organization) → Godot UI integration

**VFX:**
Godot particle, shader, and material tools — AI used for visual reference only, not as production output

**Environment / Arena:**
Modular kit packs, authored meshes, or generated proxy assets + manual composition in Godot

---

## 6. Tool Roles in Detail

### Meshy / Tripo3D
- Generate base 3D models for characters, enemies, weapons, and props
- Output: rough 3D mesh for cleanup
- Does not replace: rigging, animation, integration — only generates base geometry

### Blender
- Adjust scale, rotation, and pivot
- Correct mesh topology issues from AI generation
- Attach weapon sockets / bone markers
- Light mesh editing (remove clipping, adjust proportions)
- Prepare mesh for Mixamo (clean A-pose or T-pose)
- Export a Godot-facing `glTF 2.0` `.glb` by default; use `FBX` only as an exception when needed
- Does **not** require artistic modeling mastery — technical cleanup only

### Mixamo
- Auto-rig humanoid characters
- Source for shared animations (walk, run, death, hit react)
- Source for base combat animations to adapt per weapon
- Limitation: Mixamo animations are generic starting points. Weapon-specific timing must be adjusted in the Godot animation setup.

### Godot (Central Integration)
- AnimationPlayer / AnimationTree setup per weapon, race, or shared character rig where appropriate
- Blend spaces or state-machine equivalents for locomotion
- Animation events, call tracks, or data hooks synchronized with gameplay code (hit frames, cast frames, recovery frames)
- VFX authored with Godot particle, material, shader, and scene tools
- UI assembled from exported assets
- Material standardization (toon shader applied consistently)
- Final validation of all assets in the actual game camera

### Figma
- Organize UI components into a consistent design system
- Layout HUD, skill buttons, resource bars, loadout screens
- Does not replace Godot integration — exports specs and assets for implementation

### AI Image Generation
- Concept art for races, weapons, enemies, arenas, and spells
- UI ornaments and decorative elements
- Icon bases (always require cleanup)
- Texture references for stylized materials
- Does **not** replace: rig, animation, integration, or VFX authoring

---

## 7. What AI Does vs. What Must Be Manual

This distinction determines whether a production decision costs hours or days.

### AI Accelerates:

| Category | What AI Produces |
| --- | --- |
| 3D base geometry | Characters, enemies, weapons, props — rough mesh only |
| Concept art | All four races, all weapons, all skills, all environments |
| UI bases | Frames, panels, backgrounds, ornaments, splash screens |
| Icons | Skills, items, buffs, potions, races, loadout categories |
| Portraits and profile art | Per character, per race |
| Texture references | Fabric, metal, stone, arcane glows, alien surfaces |
| Skin concept variations | Cosmetic variations for the same character or weapon |

### Manual Is Always Required For:

| Area | Why It Cannot Be Automated |
| --- | --- |
| Rig validation and Avatar setup | Humanoid retargeting requires correct bone mapping — errors here break all animations |
| Animation timing per weapon | Attack frame timing directly defines gameplay feel and hitbox sync |
| Animation Events (hit, cast, recovery frames) | These connect animations to game code — must be authored by a human who understands the weapon's design |
| VFX timing and positioning | Particle effects must read in the actual isometric camera, not in preview |
| Weapon attachment to bone socket | Scale, rotation, and clipping must be checked in motion with real animations |
| UI layout and contrast for future mobile downscaling | AI-generated bases require standardization for small screen legibility |
| Visual standardization across packs | Multiple packs from different sources must look like one game |
| Camera validation | Every asset must be tested in the actual game camera before being finalized |

The principle: **AI accelerates the creation of visual material. Human work ensures that material functions as a game.**

---

## 8. VFX — Core Visual Identity

VFX in this game is not a cosmetic layer added on top of working systems. It is a core component of the combat philosophy.

The design principle is explicit: **High and exuberant. Bright impact effects against dark environments. Heavy particle effects, color contrast, screen shake for major impacts.** (Reference: Hades, Returnal)

This means VFX must be designed and integrated at the same priority level as animation, not after.

### VFX Categories

**Category 1 — Combat Feedback (Highest Priority)**

These VFX are part of the gameplay loop. They communicate information to the player and must be designed for clarity, not just aesthetics.

| Effect | Purpose |
| --- | --- |
| Hit sparks / impact burst | Confirms attack landing. Color-coded per hit weight (light / medium / heavy) |
| Hit stop (0–6 frame pause) | Communicates hit weight. Value to be determined through playtesting |
| Projectile trail | Communicates projectile speed, direction, and danger level |
| AoE marker | Communicates area of effect before impact (telegraphing) |
| Skill startup indicator | Communicates cast initiation to the opponent (gives read opportunity) |
| Death effect | Confirms kill and matches match-end state |

**Category 2 — Skill VFX (Per Weapon, High Priority)**

Each skill has visual effects tied to its weapon's race identity. These are not generic — they must look like they belong to the race that uses them.

*Heroic / Martelo example:*
- Ground Slam: rock/earth particles, shockwave ring, dust cloud in cone
- Hammer Throw: spinning projectile trail, magnetic return arc
- Leap Strike: landing shockwave, lingering energy field (ultimate tier)
- Speed Burst: trailing energy/wind effect, impact ring on enemy collision

*Human / Assault Rifle example:*
- Burst Fire: muzzle flash, bullet tracers, ejected casings
- Impact Grenade: explosion ring, debris scatter, AoE shockwave
- Barricade: construction effect, HP indicator, machine gun barrel (ultimate)
- Land Mine: placement marker (invisible to enemy — display only on HUD), trigger burst

Skill VFX must reflect the tier of the skill. Base, Level 2, and Ultimate versions should have visually distinct intensities.

**Category 3 — Crystal and Arena VFX (Medium Priority)**

| Effect | Purpose |
| --- | --- |
| Crystal idle glow | Signals crystal presence on the map |
| Crystal under attack | Visual feedback as crystal takes damage |
| Crystal destruction | Kill confirmation + buff activation signal |
| Crystal buff activation | Clear visual that the player received a buff |
| Destructible object damage / destruction | Communicates changing map state |
| Reflect damage indicator | Communicates that attacking the crystal costs HP |

**Category 4 — Ambient and Polish (Low Priority)**

Environmental ambience, level-of-detail particles, and cosmetic skin effects. These are deferred until Category 1–3 VFX are complete and validated in gameplay.

### VFX Production Rules

1. All VFX must be authored and validated in the real isometric game camera before being considered complete
2. Impact VFX must not obscure the player's positional read during combat (high contrast, short duration)
3. VFX must use the game's color vocabulary: bright, high-saturation effects against a dark environment
4. Screen shake must preserve the active desktop baseline and remain viable for future mobile screen sizes
5. Performance: particle systems must stay within the active platform budgets and remain scalable for future mobile targets

---

## 9. Visual Guidelines per Race

Each race has a distinct visual vocabulary. All assets — characters, weapons, VFX, UI skins — must respect the vocabulary of their race.

### Humans — Military / Tactical

**Visual references:** Contemporary military, tactical gear, realistic proportions stylized
**Color vocabulary:** Grays, dark greens, blacks, tactical orange / red accents
**Weapons:** Mechanical, functional, no magical glow — firearms feel grounded
**Skill VFX:** Explosions, smoke, debris, muzzle flash, shrapnel — physical, not magical
**Character silhouette:** Body armor, tactical vest, helmet visible in isometric view

### Heroic — Ancient / Dark Fantasy

**Visual references:** Mythological warriors, dark fantasy, enchanted ancient weapons
**Color vocabulary:** Deep golds, dark purples, cold blues, stone grays with magical highlights
**Weapons:** Ancient materials (stone, enchanted metal) with magical aura or runes
**Skill VFX:** Earth, stone, shockwaves, magical energy emanating from weapon impacts
**Character silhouette:** Heavy armor, large weapon visible at isometric angle

### Intelligent Aliens — Advanced Technology

**Visual references:** Hard sci-fi, alien technology, non-human proportions acceptable
**Color vocabulary:** Electric blues, cyans, whites, dark metallics
**Weapons:** Energy-based — lasers, magnetic fields, drone devices
**Skill VFX:** Energy beams, magnetic arcs, holographic markers, drone movement
**Character silhouette:** Alien anatomy or advanced armor — must still read clearly at isometric distance

### Magic Beings — Pure Arcane

**Visual references:** Ethereal, powerful, barely physical — more force than matter
**Color vocabulary:** Deep purples, arcane pinks, gold runes, black and white contrast
**Weapons:** Arcane constructs — spells, summoned energy forms, telekinetic forces
**Skill VFX:** Arcane circles, runes, teleportation flashes, mental distortion effects
**Character silhouette:** Robes, magical constructs, levitation possible — must still read positionally in combat

---

## 10. Asset Categories and Production Notes

### Characters (Playable)

Each playable character is built on a humanoid rig and requires:
- Base mesh validated for isometric silhouette
- Toon shader material applied and calibrated
- Rim light visible and appropriate to the race's color vocabulary
- Race-appropriate proportions (Human proportions differ from Alien or Heroic)
- Weapon socket bone correctly positioned and tested with all weapons in the weapon pool
- Full animation set for each weapon in the character's pool (see Section 4)

### Enemies

Enemies follow the same race system. An enemy from the Heroic race shares the same visual vocabulary as a Heroic playable character. This ensures visual coherence between factions in PvE modes.

Enemy-specific requirements:
- Clear visual distinction from the player character (size, color accent, or silhouette difference)
- Attack telegraphs must be readable at isometric distance
- Death effect must clearly confirm elimination

### Weapons (3D Objects)

- Scaled and positioned to read at isometric distance (weapon must be visible in the character's hand — not too small)
- Attached to the correct hand bone and tested in all attack animations
- Toon shader applied consistently with character
- No extreme clipping with the character's body in key animation frames
- Weapon-specific VFX attachment points defined (muzzle, blade edge, head, etc.)

### Arena Elements

**A Forja (canonical arena identity):**

| Element | Visual Requirements |
| --- | --- |
| Floor / tiles | Neutral — must not compete with characters or VFX |
| Indestructible obstacles (pillars, walls) | Dark, readable, distinct from character silhouette |
| Destructible obstacles (×2) | Visual state change on destruction — before/after clearly different |
| Crystal (neutral zone) | Glowing, prominent, readable from both spawn points; damage state visible |
| Spawn points | Subtle marker — must not distract during combat |
| Zone differentiation (Open / Closed) | Environmental texture or lighting difference to reinforce tactical identity of each half |

Future arenas follow the same structure. Each arena is a self-contained visual package.

### UI and HUD

The HUD must function in combat, not compete with it.

**Combat Shell priority:**
- HP bar: large, clear, and glanceable
- Skill buttons: readable icons, cooldown state clear, activation visual feedback
- Potion buttons: distinct from skills while preserving the shared 4 skills / 2 potions contract
- Resource indicator (bullets, charges, etc.): must be glanceable mid-combat
- Awareness indicators: minimal and non-intrusive

**UI Production Flow:**
AI generation (ornaments, frames, backgrounds) → Krita/Photoshop cleanup → Figma layout → Godot integration

**Contrast rules:** All text and icons must meet minimum contrast requirements for the active desktop baseline and remain viable for future mobile downscaling.

### Icons

All icons follow a consistent template:
- Fixed frame size and shape per category (skill icon, item icon, buff icon, currency icon)
- Race-colored background accent to reinforce faction identity
- Readable at the smallest size they will appear on screen, including future mobile HUD downscaling
- Distinct enough to be told apart at a glance during combat

### Skin System

Skins are **cosmetic only** and have zero mechanical impact.

A skin modifies:
- Character model (new mesh or retextured mesh for the race)
- Weapon appearance (new weapon model or retextured version)
- Skill and movement skill VFX (new particle systems replacing the base VFX)

A skin does **not** modify:
- Hitboxes or collision geometry
- Animation timings or attack frames
- Any stat or game mechanic

Production implication: The base character, weapon, and VFX assets should be structured from the start so that skin variants can replace visual components without touching the gameplay-side integration. This means keeping geometry, materials, and VFX in cleanly separable layers.

---

## 11. Quality Standards for Placeholder Assets

An asset is considered "placeholder-complete" when it satisfies all criteria in its category — regardless of whether it is final art.

### Characters

- Silhouette readable at game camera distance
- Race identity visible (color vocabulary, proportions)
- All minimum animations present and functional (see Section 4)
- Weapon attached correctly and tested in all combat animations
- No severe visual errors (extreme clipping, broken rig, missing textures)

### Weapons

- Readable in hand at isometric distance
- Race identity consistent
- VFX attachment points defined
- No clipping errors in key attack animation frames

### VFX

- Readable in the actual isometric game camera
- Duration appropriate (does not linger long enough to obscure the next action)
- Contrast sufficient against dark environment
- No performance issues against the active platform budget or future mobile downscaling target

### UI / HUD

- All states functional (idle, cooldown, active, disabled)
- Readable at active desktop size and future mobile scale
- Consistent style across all elements on the same screen

### Icons

- Distinguishable at minimum display size
- Consistent frame and background treatment
- Race accent present

### Arena Elements

- No visual competition with characters and VFX
- Navigation clearly readable (where can the player go vs. where is a wall)
- Destructible objects clearly communicate their state

---

## 12. Common Errors to Avoid

**Error 1 — Validating assets only in viewport or editor, never in game camera**
Everything must be checked in the actual isometric camera running in Godot. An asset that looks great in Blender may be unreadable in the game.

**Error 2 — Treating VFX as decoration**
In this game, VFX is combat communication. Impact sparks, skill telegraphs, and AoE markers are gameplay-critical. Anything that makes them unclear or illegible is a gameplay problem, not a cosmetic problem.

**Error 3 — Building animations for the character before building animations for the weapon**
The weapon defines the animation. A character can have great idle and walk animations and still be unusable if the weapon's attack timings are not correct.

**Error 4 — Ignoring race visual vocabulary when producing new assets**
An arcane spell that looks like an explosion, or a military weapon that glows with magical energy, breaks the visual language that makes race identity meaningful. Each asset must visually communicate which race it belongs to.

**Error 5 — Using AI-generated assets without cleanup or validation**
AI generates starting points. Every AI-generated mesh, image, or icon must be cleaned, standardized, and validated against the game camera and contrast rules before integration.

**Error 6 — Designing skins that affect gameplay readability**
A skin may be visually stunning but reduce the clarity of the character's silhouette, weapon reach indication, or skill telegraph. Skins are cosmetic, but they cannot degrade gameplay readability.

**Error 7 — Mixing asset packs without visual unification**
Different packs have different normal levels, material responses, and color palettes. All packs must have the same toon shader applied, the same material settings, and must be reviewed for visual consistency as a set — not just as individual assets.

---

## 13. Production Philosophy Summary

The production strategy for this game is:

**Base assets from reliable sources (packs, AI generation, Mixamo) → Technical cleanup in Blender → Humanoid rig standardization → Animation library per weapon → Integration and validation in Godot → VFX authored in Godot → UI assembled from AI-accelerated bases → Visual unification pass**

The philosophy behind this strategy:

- Solo dev with programming focus: automation and acceleration are mandatory, not optional
- Four visually distinct races: asset production must respect visual vocabulary even at placeholder quality
- Weapon-driven animation: every new weapon adds an animation production requirement, not just a new model
- Isometric camera as constraint: nothing ships without camera validation
- VFX as combat identity: visual feedback is gameplay, not garnish
- Skins as product: the skin system must be architecturally supported from the start

The placeholder stage exists to produce assets good enough to run real gameplay tests — not to produce final art. But placeholder does not mean arbitrary. Every placeholder must communicate the game's visual identity clearly enough that a tester understands what they are looking at and what they are feeling when they hit something.

---

## 14. Rule for Using This Document

This document is the production reference for any visual asset decision.

For detailed game mode rules, weapon designs, and skill definitions, read `canon/design/game-design-document.md`.

For the product vision, design pillars, and race system, read `canon/product/product-vision.md`.

If a visual decision conflicts with this document, the conflict must be explicitly resolved and this document updated. Silent drift from the art direction is not acceptable — it produces assets that do not look like the same game.
