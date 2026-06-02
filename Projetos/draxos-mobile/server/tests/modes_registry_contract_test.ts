const PROJECT_PREFIX = "Projetos/draxos-mobile";
const EXPECTED_MODES = [
  {
    modeId: "basebuilder",
    displayName: "Basebuilder",
    sliceId: "refugio",
    status: "active",
  },
  {
    modeId: "autobattler",
    displayName: "Autobattler",
    sliceId: "pve_arena",
    status: "active",
  },
  {
    modeId: "towerdefense",
    displayName: "Towerdefense",
    sliceId: "tbd",
    status: "planned_disabled",
  },
  {
    modeId: "cardgame",
    displayName: "Cardgame",
    sliceId: "tbd",
    status: "planned_disabled",
  },
  {
    modeId: "openworld",
    displayName: "Openworld",
    sliceId: "forest",
    status: "active",
  },
] as const;

Deno.test("mode registry contract declares the five official modes", async () => {
  const migration = await projectText(
    "supabase/migrations/202606010001_modes_platform_v1.sql",
  );
  const clientRegistry = await projectText(
    "modes/boot/ui/mode_shell_registry.gd",
  );
  for (const { modeId } of EXPECTED_MODES) {
    assertIncludes(migration, `'${modeId}'`, `migration should seed ${modeId}`);
    assertIncludes(
      clientRegistry,
      `"${modeId}"`,
      `client registry should declare ${modeId}`,
    );
  }
  assertIncludes(
    clientRegistry,
    "display_name",
    "client registry should expose display names",
  );
  assertIncludes(
    clientRegistry,
    "hub_entries",
    "client registry should expose hub ordering",
  );
});

Deno.test("mode registry has matching nonplayable descriptor scaffolds", async () => {
  const clientRegistry = await projectText(
    "modes/boot/ui/mode_shell_registry.gd",
  );
  for (const expected of EXPECTED_MODES) {
    const descriptor = await projectJson(
      `data/definitions/modes/${expected.modeId}/metadata.json`,
    );
    const placeholder = await projectJson(
      `data/definitions/modes/${expected.modeId}/placeholder.json`,
    );

    assertEq(stringField(descriptor, "schema_version"), "mode_descriptor_v1");
    assertEq(stringField(descriptor, "mode_id"), expected.modeId);
    assertEq(stringField(descriptor, "display_name"), expected.displayName);
    assertEq(stringField(descriptor, "default_slice_id"), expected.sliceId);
    assertEq(stringField(descriptor, "status"), expected.status);

    assertEq(stringField(placeholder, "schema_version"), "mode_placeholder_v1");
    assertEq(stringField(placeholder, "mode_id"), expected.modeId);
    assertEq(booleanField(placeholder, "playable"), false);
    assertEq(booleanField(placeholder, "launchable"), false);
    assertEq(booleanField(placeholder, "reward_enabled"), false);

    assertIncludes(
      clientRegistry,
      `"descriptor_path": "res://data/definitions/modes/${expected.modeId}/metadata.json"`,
      `client registry should expose descriptor path for ${expected.modeId}`,
    );
    assertIncludes(
      clientRegistry,
      `"placeholder_path": "res://data/definitions/modes/${expected.modeId}/placeholder.json"`,
      `client registry should expose placeholder path for ${expected.modeId}`,
    );
  }
});

async function projectText(relativePath: string): Promise<string> {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  const path = cwd.endsWith("/draxos-mobile")
    ? relativePath
    : `${PROJECT_PREFIX}/${relativePath}`;
  return await Deno.readTextFile(path);
}

async function projectJson(
  relativePath: string,
): Promise<Record<string, unknown>> {
  const payload = JSON.parse(await projectText(relativePath)) as unknown;
  if (!isObject(payload)) {
    throw new Error(`${relativePath} should be a JSON object`);
  }
  return payload;
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

function stringField(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  if (typeof value !== "string") {
    throw new Error(`field ${key} should be a string`);
  }
  return value;
}

function booleanField(payload: Record<string, unknown>, key: string): boolean {
  const value = payload[key];
  if (typeof value !== "boolean") {
    throw new Error(`field ${key} should be a boolean`);
  }
  return value;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function assertEq(actual: unknown, expected: unknown): void {
  if (actual !== expected) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
