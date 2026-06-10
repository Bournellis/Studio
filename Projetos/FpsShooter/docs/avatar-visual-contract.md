# Avatar Visual Contract

- Last updated: `2026-06-10`
- Status: `TRACK_06A_ACTIVE`

## Purpose

Track 06A creates the first runtime avatar foundation for `FPS Playground`. The goal is to make the player and bot read as football characters in first person without importing final art, committing to a production rig, or adding a save/customization backend.

This contract covers procedural humanoid visuals, appearance selection and basic animation states for the `Futebol` mode. It is intentionally lightweight so the studio can later replace the primitive body with authored models or AI-assisted assets without rewriting gameplay.

## Scope

- Use runtime primitive meshes only.
- Represent a simple humanoid with head, torso, arms, legs, hands and feet.
- Support selectable skin tones.
- Support country-inspired football kits for World Cup-style celebration.
- Avoid official federation logos, FIFA branding, real protected crests, sponsors or trademarked patterns.
- Animate by procedural transforms, not imported animation clips.
- Integrate first in `Futebol`; Arena Shooter can adopt avatars later.
- Keep selection in memory only.

## Out Of Scope

- Imported Blender/Mixamo/FBX/GLTF pipeline.
- Final character art.
- Official World Cup licenses, crest copies or national team replica shirts.
- Character creator persistence.
- Networked cosmetic sync.
- Facial animation, inverse kinematics or complex skeletal animation.
- Third-person camera conversion.

## Appearance Contract

The runtime appearance model must expose:

- skin tone id;
- country kit id;
- human-readable skin label;
- human-readable kit label;
- primary shirt color;
- secondary/accent kit color;
- shorts color;
- socks or shoe accent color.

The first catalog should be small, stable and easy to extend. Country kits are inspired by broad color identities, not exact national-team shirts.

Initial kit set:

- Brazil inspired: yellow, green and blue;
- Argentina inspired: sky blue and white;
- France inspired: blue, white and red;
- Japan inspired: white, blue and red;
- Portugal inspired: red and green;
- Germany inspired: white, black and red-gold accents.

Initial skin tone set:

- light;
- tan;
- brown;
- dark.

## Animation Contract

The avatar system must expose readable procedural states:

- `idle`;
- `move`;
- `jump`;
- `fall`;
- `kick`;
- `strong_kick`;
- `celebrate`;
- `hit`.

The animation is presentation only. It must not drive movement, kick physics, goal detection, player collision, bot logic or ball authority.

The local first-person player avatar must not block the camera or make aiming unreadable. Hiding or lowering head geometry for the local avatar is allowed.

## Mode Integration Contract

`FootballRoot` remains authority for:

- player and bot spawning;
- ball contact/kick resolution;
- goals and match end;
- HUD snapshots;
- appearance selection updates.

`FootballHud` may show simple selection controls in the intro panel:

- previous/next skin tone;
- previous/next shirt/country kit;
- current skin and kit labels.

The intro menu stays paused until `Comecar`. Selection changes before start must update player and bot avatar visuals immediately enough for tests and editor playtest.

## Test Contract

Automated coverage should verify:

- avatar catalog has stable defaults and multiple choices;
- procedural avatar instantiates expected body parts;
- applying an appearance changes skin and shirt materials;
- animation requests update debug state without requiring imported assets;
- Futebol scene spawns player and bot avatars;
- intro panel exposes selection controls;
- cycling skin/kit updates selected appearance and player avatar debug data;
- kick and goal events trigger avatar animation states.

## Future Replacement Path

When authored assets arrive, keep the existing public appearance and animation methods as the adapter surface. The new implementation can swap primitive parts for rigged meshes while preserving mode-level calls such as:

- `apply_appearance`;
- `set_move_state`;
- `play_kick`;
- `play_celebrate`;
- `play_hit`.
