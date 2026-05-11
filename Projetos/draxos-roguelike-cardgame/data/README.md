# Data

Authoritative authored definitions and generated resources live here.

The active cardgame catalog keeps heroes, cards, boards, encounters, and starter decks in JSON, then generates Godot resources for runtime use.

Visual support uses `definitions/visual_assets.json` directly at runtime through `VisualAssets`. Missing PNGs are reported but do not fail validation in V1.
