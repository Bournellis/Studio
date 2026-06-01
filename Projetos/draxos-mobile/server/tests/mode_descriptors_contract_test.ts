interface ModeExpectation {
  modeId: string;
  displayName: string;
  sliceId: string;
  status: string;
  releaseChannel: string;
  publicCta: boolean;
  fullscreen: boolean;
  routeId: string;
  actionId: string;
  screenPath: string;
  enabledSetting: string;
  rulesetId: string;
  rulesetStatus: string;
  sessionModel: string;
  docPath: string;
}

interface JsonObject {
  [key: string]: unknown;
}

const PROJECT_PREFIX = "Projetos/draxos-mobile";
const EXPECTED_MODES: ModeExpectation[] = [
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
    screenPath: "",
    enabledSetting: "",
    rulesetId: "basebuilder_refugio_ruleset_v1",
    rulesetStatus: "active",
    sessionModel: "core_base_endpoints",
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
    screenPath: "",
    enabledSetting: "",
    rulesetId: "autobattler_pve_arena_ruleset_v1",
    rulesetStatus: "active",
    sessionModel: "arena_pve_endpoints",
    docPath: "docs/minigames/autobattler.md",
  },
  {
    modeId: "openworld",
    displayName: "Openworld",
    sliceId: "forest",
    status: "internal_alpha",
    releaseChannel: "internal_alpha",
    publicCta: true,
    fullscreen: true,
    routeId: "mode_shell",
    actionId: "open_mode_shell:openworld",
    screenPath: "res://modes/openworld/openworld_forest_screen.gd",
    enabledSetting: "draxos_mobile/modes/openworld/enabled",
    rulesetId: "openworld_forest_ruleset_v0",
    rulesetStatus: "active",
    sessionModel: "mode_session_bridge",
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
    screenPath: "",
    enabledSetting: "",
    rulesetId: "towerdefense_tbd_ruleset_v1",
    rulesetStatus: "draft",
    sessionModel: "none",
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
    screenPath: "",
    enabledSetting: "",
    rulesetId: "cardgame_tbd_ruleset_v1",
    rulesetStatus: "draft",
    sessionModel: "none",
    docPath: "docs/minigames/cardgame.md",
  },
];

Deno.test("mode descriptors declare official modes without playable placeholders", async () => {
  const registry = await readProjectText(
    "modes/boot/ui/mode_shell_registry.gd",
  );

  for (const expected of EXPECTED_MODES) {
    const descriptorPath =
      `data/definitions/modes/${expected.modeId}/metadata.json`;
    const placeholderPath =
      `data/definitions/modes/${expected.modeId}/placeholder.json`;
    const descriptor = await readProjectJson(descriptorPath);
    const placeholder = await readProjectJson(placeholderPath);

    assertEq(stringField(descriptor, "schema_version"), "mode_descriptor_v1");
    assertEq(stringField(descriptor, "mode_id"), expected.modeId);
    assertEq(stringField(descriptor, "display_name"), expected.displayName);
    assertEq(stringField(descriptor, "default_slice_id"), expected.sliceId);
    assertEq(stringField(descriptor, "status"), expected.status);
    assertEq(
      stringField(descriptor, "release_channel"),
      expected.releaseChannel,
    );
    assertEq(booleanField(descriptor, "public_cta"), expected.publicCta);
    assertEq(booleanField(descriptor, "fullscreen"), expected.fullscreen);

    const entry = objectField(descriptor, "entry");
    assertEq(stringField(entry, "route_id"), expected.routeId);
    assertEq(stringField(entry, "action_id"), expected.actionId);
    assertEq(stringField(entry, "client_screen_path"), expected.screenPath);
    assertEq(stringField(entry, "enabled_setting"), expected.enabledSetting);

    const ruleset = objectField(descriptor, "ruleset");
    assertEq(stringField(ruleset, "ruleset_id"), expected.rulesetId);
    assertEq(numberField(ruleset, "ruleset_version"), 1);
    assertEq(stringField(ruleset, "status"), expected.rulesetStatus);
    assertEq(stringField(ruleset, "session_model"), expected.sessionModel);

    const docs = objectField(descriptor, "docs");
    assertEq(stringField(docs, "mode_doc"), expected.docPath);
    await assertProjectFileExists(expected.docPath);

    assertEq(stringField(placeholder, "schema_version"), "mode_placeholder_v1");
    assertEq(stringField(placeholder, "mode_id"), expected.modeId);
    assertEq(booleanField(placeholder, "playable"), false);
    assertEq(booleanField(placeholder, "launchable"), false);
    assertEq(booleanField(placeholder, "reward_enabled"), false);
    assertEq(stringField(placeholder, "runtime"), "none");
    assertEq(stringField(placeholder, "entry_action"), "");

    assertIncludes(
      registry,
      `"descriptor_path": "res://data/definitions/modes/${expected.modeId}/metadata.json"`,
      `client registry should expose descriptor for ${expected.modeId}`,
    );
    assertIncludes(
      registry,
      `"placeholder_path": "res://data/definitions/modes/${expected.modeId}/placeholder.json"`,
      `client registry should expose placeholder for ${expected.modeId}`,
    );
  }
});

Deno.test("future mode templates stay disabled and rewardless", async () => {
  const metadata = await readProjectJson(
    "data/definitions/modes/_template/metadata.template.json",
  );
  const placeholder = await readProjectJson(
    "data/definitions/modes/_template/placeholder.template.json",
  );

  assertEq(stringField(metadata, "schema_version"), "mode_descriptor_v1");
  assertEq(stringField(metadata, "status"), "planned_disabled");
  assertEq(stringField(metadata, "release_channel"), "staged");
  assertEq(booleanField(metadata, "public_cta"), false);

  const entry = objectField(metadata, "entry");
  assertEq(stringField(entry, "route_id"), "");
  assertEq(stringField(entry, "client_screen_path"), "");

  const ownership = objectField(metadata, "ownership");
  assertEq(stringField(ownership, "reward_bridge"), "none");

  assertEq(stringField(placeholder, "schema_version"), "mode_placeholder_v1");
  assertEq(booleanField(placeholder, "playable"), false);
  assertEq(booleanField(placeholder, "launchable"), false);
  assertEq(booleanField(placeholder, "reward_enabled"), false);
});

async function readProjectJson(relativePath: string): Promise<JsonObject> {
  const payload = JSON.parse(await readProjectText(relativePath)) as unknown;
  assert(isObject(payload), `${relativePath} should be a JSON object`);
  return payload;
}

async function readProjectText(relativePath: string): Promise<string> {
  return await Deno.readTextFile(projectFile(relativePath));
}

async function assertProjectFileExists(relativePath: string): Promise<void> {
  const stat = await Deno.stat(projectFile(relativePath));
  assert(stat.isFile, `${relativePath} should be a file`);
}

function projectFile(relativePath: string): string {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  if (cwd.endsWith("/draxos-mobile")) {
    return relativePath;
  }
  return `${PROJECT_PREFIX}/${relativePath}`;
}

function objectField(payload: JsonObject, key: string): JsonObject {
  const value = payload[key];
  assert(isObject(value), `field ${key} should be an object`);
  return value;
}

function stringField(payload: JsonObject, key: string): string {
  const value = payload[key];
  assert(typeof value === "string", `field ${key} should be a string`);
  return value;
}

function numberField(payload: JsonObject, key: string): number {
  const value = payload[key];
  assert(typeof value === "number", `field ${key} should be a number`);
  return value;
}

function booleanField(payload: JsonObject, key: string): boolean {
  const value = payload[key];
  assert(typeof value === "boolean", `field ${key} should be a boolean`);
  return value;
}

function isObject(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function assertIncludes(
  haystack: string,
  needle: string,
  message: string,
): void {
  if (!haystack.includes(needle)) {
    throw new Error(`${message}. Missing: ${needle}`);
  }
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(
  actual: unknown,
  expected: unknown,
  message = "values should match",
): void {
  if (actual !== expected) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}
