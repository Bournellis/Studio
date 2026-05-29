# DraxosMobile - Visual Direction v1

- Status: `VIVO`
- Last updated: `2026-05-29`
- Stage: `VISUAL_DIRECTION_V1_IMPLEMENTED`
- Scope: client visual direction for the current Foundation Loop and Social Basico build.

## Purpose

Visual Direction v1 gives the current prototype one coherent, testable visual language without promising final art, final combat presentation, final economy, final naming or final monetization.

This pass is intentionally small: it consolidates color/accent decisions in `core/ui_tokens.gd`, applies surface accents through existing shell/presenter helpers, preserves current responsive constraints and keeps the implemented user flows unchanged.

## Product Tone

DraxosMobile should read as dark occult fantasy with arcane machinery and mobile clarity:

- `Refugio`: ritual home base, dark, energetic, readable as the player's operational center.
- `Batalha`: blood/impact, immediate danger, reward clarity after the result.
- `Social`: living conclave, safer green accent, identity and guild communication.
- `Competicao`: ranked tension, amber warning/season accent.
- `Loja`: bone/gold value accent, still restrained and not casino-like.
- `Conta`: cool account/system accent, clear and lower drama than battle or refuge.

## Palette Contract

The token source of truth is `core/ui_tokens.gd`.

Core surfaces:

- Entry: `accent_blood`
- Refugio/Base: `accent_refuge`
- Battle: `accent_battle`
- Social: `accent_social`
- Competition: `accent_competition`
- Shop: `accent_shop`
- Account: `accent_account`
- Progression Lab: `accent_ritual`

Backgrounds stay near-black and blue-black. Accent colors are used for borders, action focus and section emphasis. They should not become full-screen color themes.

## Component Rules

- Keep panels small-radius, touch-safe and inside existing responsive frames.
- Keep text readable before mood: no decorative typography, no tiny controls, no hidden action labels.
- Use accent borders and light background tint instead of large colored cards.
- Use CTA styling for the next meaningful action only: battle request/result, return to Refugio, collect, send guild chat and upgrade/purchase/reward actions.
- Preserve visible text on Refugio icons and action buttons even when icons are present.
- Do not add new assets, shaders, animations or generated art in this v1 pass.

## Implementation Contract

Implemented central helpers:

- `UiTokens.surface_accent_token(surface_id)`
- `UiTokens.surface_accent_color(surface_id)`
- `UiTokens.action_accent_token(action_id, surface_id)`
- `UiTokens.action_button_style_id(action_id)`
- `UiTokens.panel_style_from_tokens(...)`
- `UiTokens.surface_panel_style(...)`
- `UiTokens.button_style(style_id, state, accent_token)`

Current application points:

- App shell section labels, output panels and generic action buttons use the active surface accent.
- Entry and Refugio drawer actions use the same action style helper.
- Base/Social/Competition/Shop panels inherit the active surface accent when they use the default border.
- Embedded Base action buttons use the same action style helper.

## Non-Goals

This pass does not implement:

- final visual identity;
- final battle presentation;
- new assets or asset pipeline changes;
- backend, schema, migration or API changes;
- social expansion beyond the current Guilda v1 scope;
- economy, weapons, spells, Battle Pass or numeric tuning;
- realtime, direct chat, moderation, guild contributions or help systems;
- remote publication.

## Acceptance

Visual Direction v1 is acceptable when:

- existing Foundation Loop screens still render and fit inside the responsive layout contract;
- Social, Shop, Base/Refugio, Competition, Battle and Account have distinct but restrained accents;
- touch target sizes are preserved;
- no normal product-facing UI introduces internal terms such as `polling`, `server-authoritative`, `snapshot`, `redeem` or `alpha`;
- validation includes `git diff --check`, client/GUT tests and `tools/smoke_responsive_layout.gd`.

Manual publication remains a separate opt-in step.
