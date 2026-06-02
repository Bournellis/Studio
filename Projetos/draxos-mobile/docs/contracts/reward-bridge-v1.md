# Reward Bridge V1 Contract

- Status: `CONTRATO`
- Contract id: `REWARD_BRIDGE_V1`
- Applies to: `/modes/session/complete`, future mode completion RPCs, and audited admin compensation boundaries.
- Current runtime: `mode_session_complete_v1` for `openworld/forest`.

## Principle

Mode rewards are server-authoritative. A client can submit completion evidence, but it never sends final economy deltas as truth.

The bridge must validate the mode, ruleset, session, save, result plausibility, reward caps and idempotency before any resource, XP, progress or claim row changes.

## Required Inputs

Every reward-applying mode completion must carry:

| Field | Rule |
|---|---|
| `request_id` | UUID, unique per logical mutation. |
| `request_hash` | Explicit client hash or server-derived canonical hash. |
| `game_save_id` | Resolved by the Edge adapter from authenticated account/save context. |
| `mode_id` | Stable mode id from `mode_registry`. |
| `slice_id` | Stable slice id for the mode. |
| `ruleset_id` | Active ruleset expected by the server. |
| `ruleset_version` | Active ruleset version expected by the server. |
| `session_id` | Existing server-created session. |
| `expected_revision` | Snapshot/revision gate when the mode is event-sourced or resumable. |
| `result` | Mode-specific completion evidence, never final deltas. Historical only for modes not yet using snapshot authority. |

## Current Openworld Payload

`openworld/forest` completion accepts:

- `session_id`
- `expected_revision`
- `ruleset_id = openworld_forest_ruleset_v1`
- `ruleset_version = 1`

The Edge adapter canonicalizes this payload before hashing. The RPC loads
`mode_sessions.snapshot_payload`, rejects stale revisions and derives
`session_seconds`, `activity_score` and `deposited_items` from the server
snapshot. Client-submitted `deposited_items` is ignored for reward authority.

## Idempotency

Reward bridge mutations must use:

- endpoint identity: `modes/session/complete`;
- `request_id`;
- `request_hash`;
- `scope_id = mode:<mode_id>:<save_type>`;
- the foundation `reserve_idempotency` / `complete_idempotency` flow.

Repeating the same `request_id` with the same canonical request hash returns the same response. Reusing the same `request_id` with a different hash must fail with `IDEMPOTENCY_HASH_MISMATCH`.

## Mutation Boundary

A successful reward bridge may mutate only through transactional server code:

- `mode_sessions`
- `mode_progress`
- `mode_reward_claims`
- `players` XP/level where explicitly defined
- `resources`
- `resource_transactions`

It must not grant rewards by client-visible table writes or direct unaudited Edge `PATCH` flows.

## Reward Caps

Current mode rewards are capped by:

- mode ruleset `reward_limits`;
- period key for daily/session caps;
- existing `mode_reward_claims`;
- save type guard.

`progression_lab` saves are blocked from receiving account/base rewards through the Reward Bridge.

## Response Shape

Reward bridge responses must include:

- `ok`
- `schema_version`
- `request_id`
- `mode`
- `session`
- `reward`
- `resources`
- `limits`
- `server_time`

Current Openworld reward payload uses schema version `openworld_reward_bridge_v1` inside the outer `mode_platform_v1` response.

## Admin Boundary

Admin compensation is not a mode reward. It must use an audited admin RPC such as `admin_adjust_resource_balance_v1`, with `admin_audit_log`, reason, request id and before/after state.

Admin mode status/session operations must use the audited RPCs:

- `admin_set_mode_status_v1`
- `admin_expire_mode_session_v1`
- `admin_invalidate_mode_session_v1`

Those RPCs may change operational mode/session state, but they must not apply player rewards directly.

## Mirrors And Tests

Changes to Reward Bridge behavior must keep these mirrors aligned:

- `server/schema/migrations/`
- `supabase/migrations/`
- `server/functions/`
- `supabase/functions/`

Minimum test coverage:

- schema mirror equality;
- service-role-only grants for reward/admin RPCs;
- idempotency hash mismatch guard;
- no direct admin `PATCH` in `/modes/admin/*`;
- RLS smoke denying admin RPCs to player roles;
- mode completion duplicate request coverage.
- Openworld complete fraud coverage proving client `deposited_items` cannot
  change reward outcome.
