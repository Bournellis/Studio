interface JsonObject {
  [key: string]: unknown;
}

Deno.test("pve arena difficulties are internally consistent", async () => {
  const arenasPayload = await readJson("data/definitions/pve_arenas.json");
  const enemiesPayload = await readJson("data/definitions/pve_enemies.json");
  const difficultiesPayload = await readJson(
    "data/definitions/pve_arena_difficulties.json",
  );

  assertEq(stringField(arenasPayload, "collection"), "pve_arenas");
  assertEq(stringField(enemiesPayload, "collection"), "pve_enemies");
  assertEq(
    stringField(difficultiesPayload, "collection"),
    "pve_arena_difficulties",
  );
  assertEq(stringField(difficultiesPayload, "season_id"), "season_001");
  assertEq(stringField(difficultiesPayload, "status"), "CALIBRAVEL_ALPHA");

  const arenas = objectItems(arenasPayload);
  const enemies = objectItems(enemiesPayload);
  const ladder = arrayField(difficultiesPayload, "difficulty_ladder")
    .map((item) => assertObject(item));
  const sequences = arrayField(difficultiesPayload, "enemy_sequences")
    .map((item) => assertObject(item));
  const difficultyItems = objectItems(difficultiesPayload);

  assertEq(difficultyItems.length, 27, "Season 1 should define 27 arena tiers");

  const arenaById = new Map(
    arenas.map((arena) => [stringField(arena, "id"), arena]),
  );
  const enemyIds = new Set(enemies.map((enemy) => stringField(enemy, "id")));
  const ladderIds = new Set(ladder.map((item) => stringField(item, "id")));
  const sequenceById = new Map(
    sequences.map((sequence) => [
      stringField(sequence, "id"),
      stringArray(sequence, "enemy_ids"),
    ]),
  );

  assertEq(
    ladderIds.size,
    ladder.length,
    "difficulty ladder IDs should be unique",
  );

  const tierKeySet = new Set<string>();
  for (const item of difficultyItems) {
    assertEq(stringField(item, "mode"), "PVE_ARENA_V1");
    assertEq(stringField(item, "season_id"), "season_001");
    assertIncludes(stringArray(item, "tags"), "CALIBRAVEL_ALPHA");

    const arenaId = stringField(item, "arena_id");
    const arena = arenaById.get(arenaId);
    assert(arena !== undefined, `unknown arena_id ${arenaId}`);

    const difficultyId = stringField(item, "difficulty_id");
    assert(
      ladderIds.has(difficultyId),
      `unknown difficulty_id ${difficultyId}`,
    );

    const tierKey = `${arenaId}:${difficultyId}`;
    assert(!tierKeySet.has(tierKey), `duplicate arena difficulty ${tierKey}`);
    tierKeySet.add(tierKey);

    const sequenceId = stringField(item, "enemy_sequence_id");
    const expectedSequence = sequenceById.get(sequenceId);
    assert(
      expectedSequence !== undefined,
      `unknown enemy_sequence_id ${sequenceId}`,
    );

    const enemySequence = stringArray(item, "enemy_sequence");
    assertDeepEq(
      enemySequence,
      expectedSequence,
      `enemy sequence should match ${sequenceId}`,
    );
    for (const enemyId of enemySequence) {
      assert(enemyIds.has(enemyId), `unknown PVE enemy ${enemyId}`);
    }

    const duelCount = numberField(arena, "duel_count");
    assertEq(
      enemySequence.length,
      duelCount,
      `${tierKey} should have one enemy per arena duel`,
    );

    const targets = numberArray(item, "duel_power_targets");
    assertEq(
      targets.length,
      duelCount,
      `${tierKey} should have one target power per duel`,
    );
    assertEq(
      targets[targets.length - 1],
      numberField(item, "final_enemy_power"),
      `${tierKey} final target should match final_enemy_power`,
    );
    for (let index = 1; index < targets.length; index += 1) {
      assert(
        targets[index] >= targets[index - 1],
        `${tierKey} target powers should be non-decreasing`,
      );
    }

    const minClear = numberField(item, "clear_rate_target_min_percent");
    const maxClear = numberField(item, "clear_rate_target_max_percent");
    assert(
      minClear > 0 && minClear <= maxClear,
      `${tierKey} clear target range`,
    );
    assert(maxClear <= 100, `${tierKey} clear target should be a percentage`);

    const catalog = objectField(arena, "difficulty_catalog");
    assertEq(
      stringField(catalog, "source_collection"),
      "pve_arena_difficulties",
    );
    assertIncludes(
      stringArray(catalog, "season_1_difficulty_ids"),
      difficultyId,
      `${tierKey} should be listed by its arena`,
    );
  }

  for (const arena of arenas) {
    const arenaId = stringField(arena, "id");
    const catalog = objectField(arena, "difficulty_catalog");
    for (
      const difficultyId of stringArray(catalog, "season_1_difficulty_ids")
    ) {
      assert(
        tierKeySet.has(`${arenaId}:${difficultyId}`),
        `${arenaId} declares missing tier ${difficultyId}`,
      );
    }
  }
});

async function readJson(relativePath: string): Promise<JsonObject> {
  const payload = JSON.parse(
    await Deno.readTextFile(projectFile(relativePath)),
  );
  return assertObject(payload);
}

function projectFile(relativePath: string): string {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  if (cwd.endsWith("/draxos-mobile")) {
    return relativePath;
  }
  return `Projetos/draxos-mobile/${relativePath}`;
}

function objectItems(payload: JsonObject): JsonObject[] {
  return arrayField(payload, "items").map((item) => assertObject(item));
}

function objectField(payload: JsonObject, key: string): JsonObject {
  return assertObject(payload[key], `field ${key} should be an object`);
}

function arrayField(payload: JsonObject, key: string): unknown[] {
  const value = payload[key];
  assert(Array.isArray(value), `field ${key} should be an array`);
  return value;
}

function stringArray(payload: JsonObject, key: string): string[] {
  const value = arrayField(payload, key);
  for (const item of value) {
    assert(typeof item === "string", `field ${key} should contain strings`);
  }
  return value as string[];
}

function numberArray(payload: JsonObject, key: string): number[] {
  const value = arrayField(payload, key);
  for (const item of value) {
    assert(typeof item === "number", `field ${key} should contain numbers`);
  }
  return value as number[];
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

function assertObject(
  value: unknown,
  message = "value should be an object",
): JsonObject {
  assert(
    value !== null && typeof value === "object" && !Array.isArray(value),
    message,
  );
  return value as JsonObject;
}

function assertIncludes<T>(
  items: T[],
  item: T,
  message = "array should include item",
): void {
  assert(items.includes(item), message);
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

function assertDeepEq(
  actual: unknown,
  expected: unknown,
  message: string,
): void {
  const actualJson = JSON.stringify(actual);
  const expectedJson = JSON.stringify(expected);
  if (actualJson !== expectedJson) {
    throw new Error(`${message}. Expected ${expectedJson}, got ${actualJson}`);
  }
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}
