import {
  FOUNDATION_RULESET as SERVER_FOUNDATION_RULESET,
  foundationRuleset,
} from "../functions/_shared/foundation_ruleset.ts";
import { FOUNDATION_RULESET as SUPABASE_FOUNDATION_RULESET } from "../../supabase/functions/_shared/foundation_ruleset.ts";

type SourceKind = "definition_json" | "tool_model" | "battle_simulator";
type CanonicalizationMode = "json" | "text";

interface SourceSpec {
  path: string;
  kind: SourceKind;
  canonicalization: CanonicalizationMode;
}

interface SourceDigest {
  path: string;
  kind: SourceKind;
  sha256: string;
  canonical_bytes: number;
}

interface JsonObject {
  [key: string]: unknown;
}

const PROJECT_PREFIX = "Projetos/draxos-mobile";
const RULESET_ID = "foundation_ruleset_v0";
const CONTENT_SOURCES: SourceSpec[] = [
  "arena_buffs.json",
  "arena_rewards.json",
  "base_structures.json",
  "battle_fixtures.json",
  "bot_builds.json",
  "crafting_recipes.json",
  "passives.json",
  "pets.json",
  "potions.json",
  "power_bands.json",
  "pve_arenas.json",
  "pve_enemies.json",
  "rewards.json",
  "spells.json",
  "weapons.json",
].map((fileName) => ({
  path: `data/definitions/${fileName}`,
  kind: "definition_json",
  canonicalization: "json",
}));
const TOOL_MODEL_SOURCES: SourceSpec[] = [
  "tools/battle_lab/model.v1.json",
  "tools/economy_simulator/economy_model.v1.json",
  "tools/progression_lab/model.v1.json",
].map((path) => ({
  path,
  kind: "tool_model",
  canonicalization: "json",
}));
const SIMULATOR_SOURCES: SourceSpec[] = [
  "server/functions/_shared/battle_combatants.ts",
  "server/functions/_shared/battle_simulator.ts",
  "supabase/functions/_shared/battle_combatants.ts",
  "supabase/functions/_shared/battle_simulator.ts",
].map((path) => ({
  path,
  kind: "battle_simulator",
  canonicalization: "text",
}));

Deno.test("foundation ruleset publishes deterministic metadata and hashes", async () => {
  const jsonRuleset = JSON.parse(
    await readProjectText("data/rulesets/foundation_ruleset_v0.json"),
  ) as JsonObject;
  const serverRuleset = SERVER_FOUNDATION_RULESET as JsonObject;
  const supabaseRuleset = SUPABASE_FOUNDATION_RULESET as JsonObject;

  assertDeepEq(
    jsonRuleset,
    serverRuleset,
    "server shared ruleset should mirror JSON",
  );
  assertDeepEq(
    serverRuleset,
    supabaseRuleset,
    "supabase shared ruleset should mirror server",
  );
  assertDeepEq(
    foundationRuleset() as JsonObject,
    serverRuleset,
    "ruleset helper should clone data",
  );

  assertEq(
    stringField(serverRuleset, "schema_version"),
    "foundation_ruleset_manifest_v1",
  );
  assertEq(stringField(serverRuleset, "ruleset_id"), RULESET_ID);
  assertEq(numberField(serverRuleset, "ruleset_version"), 1);
  assertEq(stringField(serverRuleset, "lifecycle"), "FOUNDATION_AUDIT_ACTIVE");
  assertHash(stringField(serverRuleset, "content_hash"), "content_hash");
  assertHash(stringField(serverRuleset, "simulator_hash"), "simulator_hash");

  const runtime = objectField(serverRuleset, "runtime");
  assertEq(stringField(runtime, "mode"), "FIRST_SLICE_SIM");
  assertEq(stringField(runtime, "battle_log_schema"), "battle_log_v1");
  assertEq(stringField(runtime, "catalog_schema"), "grimoire_catalog_v1");
  assertEq(booleanField(runtime, "server_authoritative"), true);

  const contentSources = await digestSources([
    ...CONTENT_SOURCES,
    ...TOOL_MODEL_SOURCES,
  ]);
  const simulatorSources = await digestSources(SIMULATOR_SOURCES);
  const expectedSources = [...contentSources, ...simulatorSources];
  const actualSources = arrayField(serverRuleset, "sources");

  assertEq(actualSources.length, expectedSources.length);
  assertSourcePaths(
    actualSources,
    expectedSources.map((source) => source.path),
  );
  assertDeepEq(
    actualSources,
    expectedSources,
    "ruleset sources should match canonical inputs",
  );
  assertEq(
    stringField(serverRuleset, "content_hash"),
    await sha256Hex(`${stableStringify(contentSources)}\n`),
  );

  assertMirroredSimulatorSources(simulatorSources);
  assertEq(
    stringField(serverRuleset, "simulator_hash"),
    await sha256Hex(`${stableStringify(simulatorSources)}\n`),
  );

  const counts = objectField(serverRuleset, "counts");
  assertEq(numberField(counts, "definitions"), CONTENT_SOURCES.length);
  assertEq(numberField(counts, "tool_models"), TOOL_MODEL_SOURCES.length);
  assertEq(numberField(counts, "battle_simulators"), SIMULATOR_SOURCES.length);
  assertEq(numberField(counts, "total_sources"), expectedSources.length);
});

Deno.test("foundation ruleset generated artifacts do not contain secret material", async () => {
  for (
    const relativePath of [
      "data/rulesets/foundation_ruleset_v0.json",
      "server/functions/_shared/foundation_ruleset.ts",
      "supabase/functions/_shared/foundation_ruleset.ts",
    ]
  ) {
    const source = await readProjectText(relativePath);
    assertNoSecretLikeText(source, relativePath);
  }
});

async function digestSources(specs: SourceSpec[]): Promise<SourceDigest[]> {
  const digests: SourceDigest[] = [];
  for (const spec of specs) {
    const canonicalBody = await canonicalSourceBody(spec);
    digests.push({
      path: spec.path,
      kind: spec.kind,
      sha256: await sha256Hex(canonicalBody),
      canonical_bytes: new TextEncoder().encode(canonicalBody).byteLength,
    });
  }
  return digests.sort((left, right) =>
    left.path.localeCompare(right.path, "en")
  );
}

async function canonicalSourceBody(spec: SourceSpec): Promise<string> {
  const text = await readProjectText(spec.path);
  if (spec.canonicalization === "json") {
    return `${stableStringify(JSON.parse(text))}\n`;
  }
  return `${text.replaceAll("\r\n", "\n").trimEnd()}\n`;
}

async function sha256Hex(text: string): Promise<string> {
  const bytes = new TextEncoder().encode(text);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

function stableStringify(value: unknown): string {
  if (value === null || typeof value !== "object") {
    return JSON.stringify(value);
  }
  if (Array.isArray(value)) {
    return `[${value.map((item) => stableStringify(item)).join(",")}]`;
  }
  return `{${
    Object.entries(value as Record<string, unknown>)
      .sort(([left], [right]) => left.localeCompare(right, "en"))
      .map(([key, item]) => `${JSON.stringify(key)}:${stableStringify(item)}`)
      .join(",")
  }}`;
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

function assertSourcePaths(
  actualSources: unknown[],
  expectedPaths: string[],
): void {
  const actualPaths = actualSources.map((source) => {
    assert(isObject(source), "ruleset source should be an object");
    return stringField(source, "path");
  });
  assertDeepEq(
    actualPaths.sort(),
    [...expectedPaths].sort(),
    "ruleset source paths",
  );
}

function assertMirroredSimulatorSources(sources: SourceDigest[]): void {
  const byPath = new Map(sources.map((source) => [source.path, source]));
  for (const source of sources) {
    if (!source.path.startsWith("server/functions/")) {
      continue;
    }
    const mirrorPath = source.path.replace(
      "server/functions/",
      "supabase/functions/",
    );
    const mirror = byPath.get(mirrorPath);
    assert(
      mirror !== undefined,
      `missing simulator mirror for ${source.path}`,
    );
    assertEq(
      mirror.sha256,
      source.sha256,
      `simulator mirror hash for ${source.path}`,
    );
  }
}

function assertNoSecretLikeText(source: string, label: string): void {
  const forbiddenPatterns = [
    /service_role/i,
    /supabase_access_token/i,
    /supabase_service_role/i,
    /\bsk-(?:proj|live|test)-/i,
    /\beyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\b/,
  ];
  for (const pattern of forbiddenPatterns) {
    assert(!pattern.test(source), `${label} should not contain ${pattern}`);
  }
}

function assertHash(value: string, label: string): void {
  assert(
    /^[a-f0-9]{64}$/.test(value),
    `${label} should be a sha256 hex digest`,
  );
}

function objectField(payload: JsonObject, key: string): JsonObject {
  const value = payload[key];
  assert(isObject(value), `field ${key} should be an object`);
  return value;
}

function arrayField(payload: JsonObject, key: string): unknown[] {
  const value = payload[key];
  assert(Array.isArray(value), `field ${key} should be an array`);
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

function assertDeepEq(
  actual: unknown,
  expected: unknown,
  message: string,
): void {
  const actualJson = stableStringify(actual);
  const expectedJson = stableStringify(expected);
  if (actualJson !== expectedJson) {
    throw new Error(`${message}. Expected ${expectedJson}, got ${actualJson}`);
  }
}
