# Playtest Report - Track 04B1 Character Presentation

- Date: `2026-06-11`
- Agent: `Codex`
- Scope: Track 04B1 - Character Presentation & Animation V1.
- Scene surface: runtime avatar path through `PlayerAvatar3D`.
- Capture method: temporary runtime capture script, removed after generating screenshots.
- Constraint: no controller/root/HUD/menu files touched; 04B2 area left untouched.

## What Ran

- Imported the worktree once through headless editor mode.
- Instantiated the runtime avatar with the real Quaternius UBC body mesh and UAL skeleton.
- Applied Brazil kit with `simple_parted` hair and France kit with `long` hair.
- Captured front, side and back views of both looks.
- Played `JogoDaCopa_Kick` through the same `AnimationPlayer` path used by tests and captured four side frames.
- Enabled toon render and captured the running pose with material `next_pass` outline enabled.
- Ran full validation after the final code changes: `68/68` tests, `838` asserts.

## Captures

- `docs/screenshots/track-04b1-character-presentation-v1/brazil-simple-front.png`
- `docs/screenshots/track-04b1-character-presentation-v1/brazil-simple-side.png`
- `docs/screenshots/track-04b1-character-presentation-v1/brazil-simple-back.png`
- `docs/screenshots/track-04b1-character-presentation-v1/france-long-front.png`
- `docs/screenshots/track-04b1-character-presentation-v1/france-long-side.png`
- `docs/screenshots/track-04b1-character-presentation-v1/france-long-back.png`
- `docs/screenshots/track-04b1-character-presentation-v1/kick-frame-00.png`
- `docs/screenshots/track-04b1-character-presentation-v1/kick-frame-01.png`
- `docs/screenshots/track-04b1-character-presentation-v1/kick-frame-02.png`
- `docs/screenshots/track-04b1-character-presentation-v1/kick-frame-03.png`
- `docs/screenshots/track-04b1-character-presentation-v1/toon-on-next-pass-no-duplicate.png`

## Checklist

| Item | Result | Evidence |
|---|---|---|
| Camisa, shorts, pele, cabelo, chuteira e meia legiveis | PASS | Brazil/France front/side/back captures |
| Uniforme usa regioes procedurais por bone dominante | PASS | `test_avatar_uniform_regions_are_encoded_in_vertex_colors_and_shader_uniforms` |
| Skin tone nao muda kit e kit nao muda pele | PASS | `test_avatar_skin_and_kit_changes_do_not_cross_region_uniforms` |
| Cabelo real anexado ao Head e bot com cabelo proprio | PASS | `test_avatar_instantiates_expected_runtime_parts`, `test_bot_variant_can_use_female_model` |
| Toon ON sem corpo duplicado em T-pose | PASS | `test_avatar_toon_uses_material_next_pass_without_duplicate_t_pose_mesh` and toon screenshot |
| Chute novo fica abaixo do quadril | PASS | `test_authorial_kick_keeps_right_foot_below_pelvis` and kick screenshots |

## Observations

- O uniforme tem cortes duros de bone dominante, como esperado para camisa/shorts/meia/chuteira, sem textura de roupa pintada no corpo base.
- A pele preserva detalhe da textura original; roupa usa cor solida com shading leve.
- A sequencia de chute prioriza amplitude humana e limite de quadril sobre exagero arcade.
- O modo toon agora segue o skinning do personagem; a evidencia visual nao mostra corpo extra parado em T-pose.
- A integracao de UI da intro para cabelo ficou exposta via catalog/avatar API, sem tocar na area paralela de HUD/menu/controller.
