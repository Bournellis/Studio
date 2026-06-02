export type ModeStatus = "active" | "internal_alpha" | "planned_disabled";
export type ReleaseChannel = "internal_alpha" | "staged";
export type RulesetStatus = "active" | "draft";
export type SessionModel =
  | "core_base_endpoints"
  | "arena_pve_endpoints"
  | "mode_session_bridge"
  | "mode_session_snapshot_event_bridge"
  | "none";
export type DataStrategy =
  | "core-mode-progress"
  | "mode-local-progress"
  | "shared-save-progress";

export interface JsonObject {
  [key: string]: unknown;
}

export interface ModeExpectation {
  modeId: string;
  displayName: string;
  sliceId: string;
  status: ModeStatus;
  releaseChannel: ReleaseChannel;
  publicCta: boolean;
  fullscreen: boolean;
  routeId: string;
  actionId: string;
  surface: string;
  screenPath: string;
  enabledSetting: string;
  rulesetId: string;
  rulesetStatus: RulesetStatus;
  sessionModel: SessionModel;
  buildOwner: string;
  dataStrategy: DataStrategy;
  economyAuthority: string;
  rewardBridge: string;
  docPath: string;
}

export interface ModeDefinitionIssue {
  path: string;
  message: string;
}

export interface ModeDefinitionBundle {
  modeId: string;
  descriptor: JsonObject;
  placeholder: JsonObject;
  registryText?: string;
}

const DESCRIPTOR_KEYS = [
  "schema_version",
  "mode_id",
  "display_name",
  "summary",
  "default_slice_id",
  "status",
  "release_channel",
  "public_cta",
  "fullscreen",
  "entry",
  "ruleset",
  "ownership",
  "docs",
  "scaffold",
];

const ENTRY_KEYS = [
  "route_id",
  "action_id",
  "surface",
  "client_screen_path",
  "enabled_setting",
];

const RULESET_KEYS = [
  "ruleset_id",
  "ruleset_version",
  "status",
  "session_model",
];

const OWNERSHIP_KEYS = [
  "build_owner",
  "data_strategy",
  "economy_authority",
  "reward_bridge",
];

const DOCS_KEYS = ["mode_doc", "catalog", "contract"];
const SCAFFOLD_KEYS = [
  "placeholder_path",
  "playable_from_placeholder",
  "freeze",
];

const PLACEHOLDER_KEYS = [
  "schema_version",
  "mode_id",
  "placeholder_id",
  "playable",
  "launchable",
  "reward_enabled",
  "runtime",
  "entry_action",
  "purpose",
  "blocked_until",
  "non_goals",
];

export const MODE_EXPECTATIONS: ModeExpectation[] = [
  {
    modeId: "basebuilder",
    displayName: "Basebuilder",
    sliceId: "refugio",
    status: "active",
    releaseChannel: "internal_alpha",
    publicCta: true,
    fullscreen: false,
    routeId: "refuge",
    actionId: "show_base",
    surface: "refuge",
    screenPath: "",
    enabledSetting: "",
    rulesetId: "basebuilder_refugio_ruleset_v1",
    rulesetStatus: "active",
    sessionModel: "core_base_endpoints",
    buildOwner: "basebuilder",
    dataStrategy: "core-mode-progress",
    economyAuthority: "base_endpoints_existing",
    rewardBridge: "none",
    docPath: "docs/minigames/basebuilder.md",
  },
  {
    modeId: "autobattler",
    displayName: "Autobattler",
    sliceId: "pve_arena",
    status: "active",
    releaseChannel: "internal_alpha",
    publicCta: true,
    fullscreen: false,
    routeId: "arena_selection",
    actionId: "open_arena",
    surface: "arena_pve",
    screenPath: "",
    enabledSetting: "",
    rulesetId: "autobattler_pve_arena_ruleset_v1",
    rulesetStatus: "active",
    sessionModel: "arena_pve_endpoints",
    buildOwner: "autobattler",
    dataStrategy: "core-mode-progress",
    economyAuthority: "arena_pve_endpoints_existing",
    rewardBridge: "arena_pve_reward_existing",
    docPath: "docs/minigames/autobattler.md",
  },
  {
    modeId: "openworld",
    displayName: "Openworld",
    sliceId: "forest",
    status: "active",
    releaseChannel: "internal_alpha",
    publicCta: true,
    fullscreen: true,
    routeId: "mode_shell",
    actionId: "open_mode_shell:openworld",
    surface: "fullscreen",
    screenPath: "res://modes/openworld/openworld_forest_screen.gd",
    enabledSetting: "draxos_mobile/modes/openworld/enabled",
    rulesetId: "openworld_forest_ruleset_v1",
    rulesetStatus: "active",
    sessionModel: "mode_session_snapshot_event_bridge",
    buildOwner: "openworld",
    dataStrategy: "shared-save-progress",
    economyAuthority: "mode_session_complete_v1_server_snapshot",
    rewardBridge: "openworld_forest_limited_snapshot_authoritative",
    docPath: "docs/minigames/openworld.md",
  },
  {
    modeId: "towerdefense",
    displayName: "Towerdefense",
    sliceId: "tbd",
    status: "planned_disabled",
    releaseChannel: "staged",
    publicCta: false,
    fullscreen: true,
    routeId: "",
    actionId: "mode_disabled:towerdefense",
    surface: "mode_hub_disabled",
    screenPath: "",
    enabledSetting: "",
    rulesetId: "towerdefense_tbd_ruleset_v1",
    rulesetStatus: "draft",
    sessionModel: "none",
    buildOwner: "towerdefense",
    dataStrategy: "mode-local-progress",
    economyAuthority: "none",
    rewardBridge: "none",
    docPath: "docs/minigames/towerdefense.md",
  },
  {
    modeId: "cardgame",
    displayName: "Cardgame",
    sliceId: "tbd",
    status: "planned_disabled",
    releaseChannel: "staged",
    publicCta: false,
    fullscreen: false,
    routeId: "",
    actionId: "mode_disabled:cardgame",
    surface: "mode_hub_disabled",
    screenPath: "",
    enabledSetting: "",
    rulesetId: "cardgame_tbd_ruleset_v1",
    rulesetStatus: "draft",
    sessionModel: "none",
    buildOwner: "cardgame",
    dataStrategy: "mode-local-progress",
    economyAuthority: "none",
    rewardBridge: "none",
    docPath: "docs/minigames/cardgame.md",
  },
];

export const OFFICIAL_MODE_IDS = MODE_EXPECTATIONS.map((item) => item.modeId);

export function modeExpectationFor(
  modeId: string,
): ModeExpectation | undefined {
  return MODE_EXPECTATIONS.find((item) => item.modeId === modeId);
}

export function validateOfficialModeDirectoryNames(
  modeIds: string[],
): ModeDefinitionIssue[] {
  const issues: ModeDefinitionIssue[] = [];
  const actual = [...modeIds].sort((left, right) =>
    left.localeCompare(right, "en")
  );
  const expected = [...OFFICIAL_MODE_IDS].sort((left, right) =>
    left.localeCompare(right, "en")
  );
  for (const modeId of expected) {
    if (!actual.includes(modeId)) {
      pushIssue(
        issues,
        "data/definitions/modes",
        `missing official mode ${modeId}`,
      );
    }
  }
  for (const modeId of actual) {
    if (!expected.includes(modeId)) {
      pushIssue(
        issues,
        "data/definitions/modes",
        `unexpected mode directory ${modeId}; add a package decision before registry expansion`,
      );
    }
  }
  return issues;
}

export function validateModeDefinitionBundle(
  bundle: ModeDefinitionBundle,
): ModeDefinitionIssue[] {
  const issues: ModeDefinitionIssue[] = [];
  const expectation = modeExpectationFor(bundle.modeId);
  if (expectation === undefined) {
    pushIssue(
      issues,
      bundle.modeId,
      `mode ${bundle.modeId} is not an official V1 mode`,
    );
    return issues;
  }

  validateDescriptor(bundle.descriptor, expectation, issues);
  validatePlaceholder(bundle.placeholder, expectation, issues);
  if (bundle.registryText !== undefined) {
    assertRegistryContains(bundle.registryText, expectation.modeId, issues);
  }
  return issues;
}

export function validateTemplateScaffold(
  descriptor: JsonObject,
  placeholder: JsonObject,
): ModeDefinitionIssue[] {
  const issues: ModeDefinitionIssue[] = [];
  assertExactKeys(
    descriptor,
    DESCRIPTOR_KEYS,
    "metadata.template.json",
    issues,
  );
  assertEq(
    descriptor,
    "schema_version",
    "mode_descriptor_v1",
    "metadata.template.json",
    issues,
  );
  assertEq(
    descriptor,
    "mode_id",
    "<mode_id>",
    "metadata.template.json",
    issues,
  );
  assertEq(
    descriptor,
    "default_slice_id",
    "tbd",
    "metadata.template.json",
    issues,
  );
  assertEq(
    descriptor,
    "status",
    "planned_disabled",
    "metadata.template.json",
    issues,
  );
  assertEq(
    descriptor,
    "release_channel",
    "staged",
    "metadata.template.json",
    issues,
  );
  assertEq(descriptor, "public_cta", false, "metadata.template.json", issues);
  const entry = objectField(
    descriptor,
    "entry",
    "metadata.template.json",
    issues,
  );
  if (entry !== undefined) {
    assertExactKeys(entry, ENTRY_KEYS, "metadata.template.json.entry", issues);
    assertEq(entry, "route_id", "", "metadata.template.json.entry", issues);
    assertEq(
      entry,
      "action_id",
      "mode_disabled:<mode_id>",
      "metadata.template.json.entry",
      issues,
    );
    assertEq(
      entry,
      "client_screen_path",
      "",
      "metadata.template.json.entry",
      issues,
    );
    assertEq(
      entry,
      "enabled_setting",
      "",
      "metadata.template.json.entry",
      issues,
    );
  }
  const ownership = objectField(
    descriptor,
    "ownership",
    "metadata.template.json",
    issues,
  );
  if (ownership !== undefined) {
    assertExactKeys(
      ownership,
      OWNERSHIP_KEYS,
      "metadata.template.json.ownership",
      issues,
    );
    assertEq(
      ownership,
      "economy_authority",
      "none",
      "metadata.template.json.ownership",
      issues,
    );
    assertEq(
      ownership,
      "reward_bridge",
      "none",
      "metadata.template.json.ownership",
      issues,
    );
  }

  assertExactKeys(
    placeholder,
    PLACEHOLDER_KEYS,
    "placeholder.template.json",
    issues,
  );
  assertEq(
    placeholder,
    "schema_version",
    "mode_placeholder_v1",
    "placeholder.template.json",
    issues,
  );
  assertEq(
    placeholder,
    "mode_id",
    "<mode_id>",
    "placeholder.template.json",
    issues,
  );
  assertEq(placeholder, "playable", false, "placeholder.template.json", issues);
  assertEq(
    placeholder,
    "launchable",
    false,
    "placeholder.template.json",
    issues,
  );
  assertEq(
    placeholder,
    "reward_enabled",
    false,
    "placeholder.template.json",
    issues,
  );
  assertEq(placeholder, "runtime", "none", "placeholder.template.json", issues);
  assertEq(
    placeholder,
    "entry_action",
    "",
    "placeholder.template.json",
    issues,
  );
  validateStringArray(
    placeholder,
    "blocked_until",
    "placeholder.template.json",
    issues,
  );
  validateStringArray(
    placeholder,
    "non_goals",
    "placeholder.template.json",
    issues,
  );
  return issues;
}

function validateDescriptor(
  descriptor: JsonObject,
  expectation: ModeExpectation,
  issues: ModeDefinitionIssue[],
): void {
  const root = `${expectation.modeId}/metadata.json`;
  assertExactKeys(descriptor, DESCRIPTOR_KEYS, root, issues);
  assertEq(descriptor, "schema_version", "mode_descriptor_v1", root, issues);
  assertEq(descriptor, "mode_id", expectation.modeId, root, issues);
  assertEq(descriptor, "display_name", expectation.displayName, root, issues);
  assertNonEmptyString(descriptor, "summary", root, issues);
  assertEq(descriptor, "default_slice_id", expectation.sliceId, root, issues);
  assertEq(descriptor, "status", expectation.status, root, issues);
  assertEq(
    descriptor,
    "release_channel",
    expectation.releaseChannel,
    root,
    issues,
  );
  assertEq(descriptor, "public_cta", expectation.publicCta, root, issues);
  assertEq(descriptor, "fullscreen", expectation.fullscreen, root, issues);

  const entry = objectField(descriptor, "entry", root, issues);
  if (entry !== undefined) {
    assertExactKeys(entry, ENTRY_KEYS, `${root}.entry`, issues);
    assertEq(entry, "route_id", expectation.routeId, `${root}.entry`, issues);
    assertEq(entry, "action_id", expectation.actionId, `${root}.entry`, issues);
    assertEq(entry, "surface", expectation.surface, `${root}.entry`, issues);
    assertEq(
      entry,
      "client_screen_path",
      expectation.screenPath,
      `${root}.entry`,
      issues,
    );
    assertEq(
      entry,
      "enabled_setting",
      expectation.enabledSetting,
      `${root}.entry`,
      issues,
    );
  }

  const ruleset = objectField(descriptor, "ruleset", root, issues);
  if (ruleset !== undefined) {
    assertExactKeys(ruleset, RULESET_KEYS, `${root}.ruleset`, issues);
    assertEq(
      ruleset,
      "ruleset_id",
      expectation.rulesetId,
      `${root}.ruleset`,
      issues,
    );
    assertEq(ruleset, "ruleset_version", 1, `${root}.ruleset`, issues);
    assertEq(
      ruleset,
      "status",
      expectation.rulesetStatus,
      `${root}.ruleset`,
      issues,
    );
    assertEq(
      ruleset,
      "session_model",
      expectation.sessionModel,
      `${root}.ruleset`,
      issues,
    );
  }

  const ownership = objectField(descriptor, "ownership", root, issues);
  if (ownership !== undefined) {
    assertExactKeys(ownership, OWNERSHIP_KEYS, `${root}.ownership`, issues);
    assertEq(
      ownership,
      "build_owner",
      expectation.buildOwner,
      `${root}.ownership`,
      issues,
    );
    assertEq(
      ownership,
      "data_strategy",
      expectation.dataStrategy,
      `${root}.ownership`,
      issues,
    );
    assertEq(
      ownership,
      "economy_authority",
      expectation.economyAuthority,
      `${root}.ownership`,
      issues,
    );
    assertEq(
      ownership,
      "reward_bridge",
      expectation.rewardBridge,
      `${root}.ownership`,
      issues,
    );
  }

  const docs = objectField(descriptor, "docs", root, issues);
  if (docs !== undefined) {
    assertExactKeys(docs, DOCS_KEYS, `${root}.docs`, issues);
    assertEq(docs, "mode_doc", expectation.docPath, `${root}.docs`, issues);
    assertEq(
      docs,
      "catalog",
      "docs/minigames/mode-catalog.md",
      `${root}.docs`,
      issues,
    );
    assertEq(
      docs,
      "contract",
      "docs/contracts/minigame-integration.md",
      `${root}.docs`,
      issues,
    );
  }

  const scaffold = objectField(descriptor, "scaffold", root, issues);
  if (scaffold !== undefined) {
    assertExactKeys(scaffold, SCAFFOLD_KEYS, `${root}.scaffold`, issues);
    assertEq(
      scaffold,
      "placeholder_path",
      `data/definitions/modes/${expectation.modeId}/placeholder.json`,
      `${root}.scaffold`,
      issues,
    );
    assertEq(
      scaffold,
      "playable_from_placeholder",
      false,
      `${root}.scaffold`,
      issues,
    );
    assertEq(
      scaffold,
      "freeze",
      expectation.modeId === "openworld"
        ? "no_map_combat_risk_or_reward_expansion"
        : "no_new_gameplay_tuning_or_rewards",
      `${root}.scaffold`,
      issues,
    );
  }
}

function validatePlaceholder(
  placeholder: JsonObject,
  expectation: ModeExpectation,
  issues: ModeDefinitionIssue[],
): void {
  const root = `${expectation.modeId}/placeholder.json`;
  assertExactKeys(placeholder, PLACEHOLDER_KEYS, root, issues);
  assertEq(placeholder, "schema_version", "mode_placeholder_v1", root, issues);
  assertEq(placeholder, "mode_id", expectation.modeId, root, issues);
  assertNonEmptyString(placeholder, "placeholder_id", root, issues);
  const placeholderId = stringField(
    placeholder,
    "placeholder_id",
    root,
    issues,
  );
  if (
    placeholderId !== undefined &&
    !placeholderId.startsWith(`${expectation.modeId}_`)
  ) {
    pushIssue(issues, `${root}.placeholder_id`, "must start with the mode id");
  }
  assertEq(placeholder, "playable", false, root, issues);
  assertEq(placeholder, "launchable", false, root, issues);
  assertEq(placeholder, "reward_enabled", false, root, issues);
  assertEq(placeholder, "runtime", "none", root, issues);
  assertEq(placeholder, "entry_action", "", root, issues);
  assertNonEmptyString(placeholder, "purpose", root, issues);
  validateStringArray(placeholder, "blocked_until", root, issues);
  validateStringArray(placeholder, "non_goals", root, issues);

  if (expectation.status === "planned_disabled") {
    const blockedUntil = arrayField(placeholder, "blocked_until", root, issues);
    if (
      blockedUntil !== undefined &&
      !blockedUntil.some((item) =>
        typeof item === "string" &&
        item.includes(`explicit ${expectation.modeId} package decision`)
      )
    ) {
      pushIssue(
        issues,
        `${root}.blocked_until`,
        `must require explicit ${expectation.modeId} package decision`,
      );
    }
  }
}

function assertRegistryContains(
  registryText: string,
  modeId: string,
  issues: ModeDefinitionIssue[],
): void {
  const descriptorPath =
    `"descriptor_path": "res://data/definitions/modes/${modeId}/metadata.json"`;
  const placeholderPath =
    `"placeholder_path": "res://data/definitions/modes/${modeId}/placeholder.json"`;
  if (!registryText.includes(descriptorPath)) {
    pushIssue(
      issues,
      "modes/boot/ui/mode_shell_registry.gd",
      `missing ${descriptorPath}`,
    );
  }
  if (!registryText.includes(placeholderPath)) {
    pushIssue(
      issues,
      "modes/boot/ui/mode_shell_registry.gd",
      `missing ${placeholderPath}`,
    );
  }
}

function assertExactKeys(
  payload: JsonObject,
  expectedKeys: string[],
  path: string,
  issues: ModeDefinitionIssue[],
): void {
  const actualKeys = Object.keys(payload);
  for (const key of expectedKeys) {
    if (!actualKeys.includes(key)) {
      pushIssue(issues, path, `missing required field ${key}`);
    }
  }
  for (const key of actualKeys) {
    if (!expectedKeys.includes(key)) {
      pushIssue(issues, path, `unexpected field ${key}`);
    }
  }
}

function objectField(
  payload: JsonObject,
  key: string,
  path: string,
  issues: ModeDefinitionIssue[],
): JsonObject | undefined {
  const value = payload[key];
  if (!isObject(value)) {
    pushIssue(issues, `${path}.${key}`, "must be an object");
    return undefined;
  }
  return value;
}

function stringField(
  payload: JsonObject,
  key: string,
  path: string,
  issues: ModeDefinitionIssue[],
): string | undefined {
  const value = payload[key];
  if (typeof value !== "string") {
    pushIssue(issues, `${path}.${key}`, "must be a string");
    return undefined;
  }
  return value;
}

function arrayField(
  payload: JsonObject,
  key: string,
  path: string,
  issues: ModeDefinitionIssue[],
): unknown[] | undefined {
  const value = payload[key];
  if (!Array.isArray(value)) {
    pushIssue(issues, `${path}.${key}`, "must be an array");
    return undefined;
  }
  return value;
}

function assertNonEmptyString(
  payload: JsonObject,
  key: string,
  path: string,
  issues: ModeDefinitionIssue[],
): void {
  const value = stringField(payload, key, path, issues);
  if (value !== undefined && value.trim().length === 0) {
    pushIssue(issues, `${path}.${key}`, "must not be empty");
  }
}

function validateStringArray(
  payload: JsonObject,
  key: string,
  path: string,
  issues: ModeDefinitionIssue[],
): void {
  const values = arrayField(payload, key, path, issues);
  if (values === undefined) {
    return;
  }
  if (values.length === 0) {
    pushIssue(issues, `${path}.${key}`, "must not be empty");
  }
  values.forEach((item, index) => {
    if (typeof item !== "string" || item.trim().length === 0) {
      pushIssue(
        issues,
        `${path}.${key}[${index}]`,
        "must be a non-empty string",
      );
    }
  });
}

function assertEq(
  payload: JsonObject,
  key: string,
  expected: unknown,
  path: string,
  issues: ModeDefinitionIssue[],
): void {
  const actual = payload[key];
  if (actual !== expected) {
    pushIssue(
      issues,
      `${path}.${key}`,
      `expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}

function pushIssue(
  issues: ModeDefinitionIssue[],
  path: string,
  message: string,
): void {
  issues.push({ path, message });
}

function isObject(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
