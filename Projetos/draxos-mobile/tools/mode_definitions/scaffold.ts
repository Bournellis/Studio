import type { JsonObject } from "./schema.ts";

export interface ModeScaffoldInput {
  modeId: string;
  displayName: string;
  summary: string;
  fullscreen?: boolean;
}

export interface ModeScaffoldOutput {
  modeId: string;
  descriptorPath: string;
  placeholderPath: string;
  docPath: string;
  descriptor: JsonObject;
  placeholder: JsonObject;
  docBody: string;
}

export function renderModeScaffold(
  input: ModeScaffoldInput,
): ModeScaffoldOutput {
  const modeId = normalizeModeId(input.modeId);
  const displayName = input.displayName.trim();
  const summary = input.summary.trim();
  if (displayName.length === 0) {
    throw new Error("displayName is required.");
  }
  if (summary.length === 0) {
    throw new Error("summary is required.");
  }

  const descriptorPath = `data/definitions/modes/${modeId}/metadata.json`;
  const placeholderPath = `data/definitions/modes/${modeId}/placeholder.json`;
  const docPath = `docs/minigames/${modeId}.md`;
  const fullscreen = input.fullscreen ?? false;

  const descriptor: JsonObject = {
    schema_version: "mode_descriptor_v1",
    mode_id: modeId,
    display_name: displayName,
    summary,
    default_slice_id: "tbd",
    status: "planned_disabled",
    release_channel: "staged",
    public_cta: false,
    fullscreen,
    entry: {
      route_id: "",
      action_id: `mode_disabled:${modeId}`,
      surface: "mode_hub_disabled",
      client_screen_path: "",
      enabled_setting: "",
    },
    ruleset: {
      ruleset_id: `${modeId}_tbd_ruleset_v1`,
      ruleset_version: 1,
      status: "draft",
      session_model: "none",
    },
    ownership: {
      build_owner: modeId,
      data_strategy: "mode-local-progress",
      economy_authority: "none",
      reward_bridge: "none",
    },
    docs: {
      mode_doc: docPath,
      catalog: "docs/minigames/mode-catalog.md",
      contract: "docs/contracts/minigame-integration.md",
    },
    scaffold: {
      placeholder_path: placeholderPath,
      playable_from_placeholder: false,
      freeze: "no_new_gameplay_tuning_or_rewards",
    },
  };

  const placeholder: JsonObject = {
    schema_version: "mode_placeholder_v1",
    mode_id: modeId,
    placeholder_id: `${modeId}_tbd_placeholder_v1`,
    playable: false,
    launchable: false,
    reward_enabled: false,
    runtime: "none",
    entry_action: "",
    purpose:
      `Reserve the future ${displayName} mode identity without adding gameplay, tuning, rewards or backend mutations.`,
    blocked_until: [
      `explicit ${modeId} package decision`,
      "live design contract",
      "ruleset and registry update",
      "validation plan",
    ],
    non_goals: [
      "new gameplay",
      "new tuning",
      "new rewards",
      "new backend mutations",
    ],
  };

  const docBody = `# ${displayName}

- Status: \`PLANNED_DISABLED\`
- Mode id: \`${modeId}\`
- Slice id: \`tbd\`
- Descriptor: \`${descriptorPath}\`
- Placeholder: \`${placeholderPath}\`
- Entry action: \`mode_disabled:${modeId}\`
- Route: none

${displayName} is a future staged DraxosMobile mode identity. This scaffold does
not approve playable implementation.

## Current Scope

- Visible only as staged/disabled in the Mode Hub after registry approval.
- No playable scene.
- No session start.
- No reward bridge.
- No local progress format beyond the placeholder scaffold.

## Freeze For This Scaffold

- No gameplay.
- No tuning.
- No rewards.
- No backend or schema mutation.
- No public CTA change.

## Future Gate

${displayName} needs a live design contract, registry/ruleset update, telemetry
plan, disable/rollback plan and validation package before becoming launchable.
`;

  return {
    modeId,
    descriptorPath,
    placeholderPath,
    docPath,
    descriptor,
    placeholder,
    docBody,
  };
}

export function normalizeModeId(modeId: string): string {
  const normalized = modeId.trim().toLowerCase();
  if (!/^[a-z][a-z0-9_]*$/.test(normalized)) {
    throw new Error(
      `Invalid mode id '${modeId}'. Use lowercase letters, numbers or underscores, starting with a letter.`,
    );
  }
  return normalized;
}
