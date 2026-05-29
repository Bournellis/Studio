import { GRIMOIRE_CATALOG } from "../functions/_shared/grimoire_catalog.ts";

const PROJECT_PREFIX = "Projetos/draxos-mobile";

Deno.test("grimoire catalog publishes whole-number bone economy", async () => {
  const catalog = GRIMOIRE_CATALOG as JsonObject;
  assertIntegerBonesCatalog(catalog, "server grimoire catalog");

  const portalCatalog = JSON.parse(
    await readProjectText("portal/internal-alpha/assets/grimoire-catalog.json"),
  ) as JsonObject;
  assertIntegerBonesCatalog(portalCatalog, "portal grimoire catalog");
});

Deno.test("base collect keeps bone production whole and preserves sub-one accrual", async () => {
  for (
    const relativePath of [
      "server/functions/base/index.ts",
      "supabase/functions/base/index.ts",
    ]
  ) {
    const source = await readProjectText(relativePath);
    assert(
      source.includes('if (definition.resource === "ossos")'),
      `${relativePath} should special-case Ossos as an integer resource`,
    );
    assert(
      source.includes("return Math.floor(collectable);"),
      `${relativePath} should floor Ossos collection to whole units`,
    );
    assert(
      source.includes("if (collectableFor(structure, now) <= 0)"),
      `${relativePath} should avoid resetting collection timers with no visible gain`,
    );
  }
});

function assertIntegerBonesCatalog(catalog: JsonObject, label: string): void {
  const collections = objectField(catalog, "collections", label);
  const structures = arrayField(collections, "base_structures", label);
  const rewards = arrayField(collections, "rewards", label);

  const ossario = objectById(structures, "ossario", label);
  const produces = arrayField(ossario, "produces", `${label} ossario`);
  const bonesProduction = produces.find((item) =>
    isObject(item) && item.resource === "ossos"
  );
  assert(
    isObject(bonesProduction),
    `${label} should expose Ossario bones production`,
  );
  assertEq(
    numberField(bonesProduction, "daily_at_level_40", label),
    200,
    `${label} should publish Ossario as 200 Ossos/day at level 40`,
  );

  assertResource(
    objectById(rewards, "first_slice_battle_loss", label),
    "ossos",
    4,
    label,
  );
  assertResource(
    objectById(rewards, "first_slice_battle_win", label),
    "ossos",
    20,
    label,
  );
  assertResource(
    objectById(rewards, "mvp_training_reward", label),
    "ossos",
    100,
    label,
  );
  assertResource(
    objectById(rewards, "daily_first_win", label),
    "ossos",
    100,
    label,
  );
  assertAllBonesAreWhole(catalog, label);
}

function assertResource(
  payload: JsonObject,
  resourceId: string,
  expected: number,
  label: string,
): void {
  const resources = objectField(payload, "resources", label);
  assertEq(
    numberField(resources, resourceId, label),
    expected,
    `${label} ${
      stringField(payload, "id")
    } should expose ${expected} ${resourceId}`,
  );
}

function assertAllBonesAreWhole(value: unknown, label: string): void {
  walk(value, [], (path, current) => {
    if (path[path.length - 1] !== "ossos") return;
    if (typeof current !== "number") return;
    assert(
      Number.isInteger(current),
      `${label} should not expose fractional ossos at ${
        path.join(".")
      }: ${current}`,
    );
  });
}

function walk(
  value: unknown,
  path: string[],
  visit: (path: string[], value: unknown) => void,
): void {
  visit(path, value);
  if (Array.isArray(value)) {
    value.forEach((item, index) => walk(item, [...path, String(index)], visit));
    return;
  }
  if (!isObject(value)) return;
  for (const [key, child] of Object.entries(value)) {
    walk(child, [...path, key], visit);
  }
}

async function readProjectText(relativePath: string): Promise<string> {
  return await Deno.readTextFile(projectFile(relativePath));
}

function projectFile(relativePath: string): string {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  if (cwd.endsWith("/draxos-mobile")) {
    return relativePath;
  }
  return `${PROJECT_PREFIX}/${relativePath}`;
}

interface JsonObject {
  [key: string]: unknown;
}

function objectById(items: unknown[], id: string, label: string): JsonObject {
  const found = items.find((item) => isObject(item) && item.id === id);
  assert(isObject(found), `${label} should include item ${id}`);
  return found;
}

function objectField(
  payload: JsonObject,
  key: string,
  label: string,
): JsonObject {
  const value = payload[key];
  assert(isObject(value), `${label} field ${key} should be an object`);
  return value;
}

function arrayField(
  payload: JsonObject,
  key: string,
  label: string,
): unknown[] {
  const value = payload[key];
  assert(Array.isArray(value), `${label} field ${key} should be an array`);
  return value;
}

function numberField(payload: JsonObject, key: string, label: string): number {
  const value = payload[key];
  assert(typeof value === "number", `${label} field ${key} should be a number`);
  return value;
}

function stringField(payload: JsonObject, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value : "";
}

function isObject(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}
