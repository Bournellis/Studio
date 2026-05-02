# Godot Patterns

This file captures validated Godot-specific patterns and recurring pitfalls.

## Pattern: Scene Authoring Via Tools When Editor Access Is Not Practical
**Discovered:** Transition foundation
**Type:** Validated pattern

**What happened:** The project needed initial scenes and generated resources before a stable editor-authored library existed.
**Root cause:** The workspace was bootstrapped from a near-empty Godot project.
**Systems affected beyond the plan:** scene creation, resource generation, validation tooling.

**Rule for Planning Agent:** Prefer editor-owned scenes by default, but when initial bootstrap or automation requires it, generate scenes through Godot scripts instead of hand-editing `.tscn`.
