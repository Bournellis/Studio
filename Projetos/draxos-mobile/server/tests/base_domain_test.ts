import {
  BASE_STRUCTURES,
  type BaseConstructionJobRow,
  type BaseResourceRow,
  baseStatePayload,
  type BaseStructureRow,
  calculateCollectable,
  collectableFor,
  DEFAULT_CONSTRUCTION_SLOTS,
  definitionFor,
  DOUBLE_CONSTRUCTION_QUEUE_PRODUCT_ID,
  upgradeBlockMessage,
  upgradeBlockReason,
  upgradeCost,
  upgradeDurationSeconds,
} from "../functions/_shared/base_domain.ts";
import {
  baseStatePayload as supabaseBaseStatePayload,
  calculateCollectable as supabaseCalculateCollectable,
} from "../../supabase/functions/_shared/base_domain.ts";

const SERVER_MODULE_PATH = "server/functions/_shared/base_domain.ts";
const SUPABASE_MODULE_PATH = "supabase/functions/_shared/base_domain.ts";

Deno.test("base domain module is mirrored and adapter-free", async () => {
  const serverModule = await Deno.readTextFile(SERVER_MODULE_PATH);
  const supabaseModule = await Deno.readTextFile(SUPABASE_MODULE_PATH);

  assertEq(
    normalizeNewlines(serverModule),
    normalizeNewlines(supabaseModule),
    "server and supabase base domain modules should mirror exactly",
  );
  assertNotIncludes(
    serverModule,
    "Deno.serve",
    "base domain must not serve HTTP",
  );
  assertNotIncludes(
    serverModule,
    "fetch(",
    "base domain must not call Supabase REST",
  );
  assertNotIncludes(
    serverModule,
    "rpc/",
    "base domain must not call transactional RPCs",
  );
});

Deno.test("base domain projects deterministic collectable resources", () => {
  const now = new Date("2026-05-30T12:00:00.000Z");
  const structures = [
    structure("altar_das_almas", 40, "2026-05-30T00:00:00.000Z"),
    structure("ossario", 40, "2026-05-30T00:00:00.000Z"),
    structure("estrutura_stats", 40, "2026-05-30T00:00:00.000Z"),
  ];

  assertEq(collectableFor(structures[0], now), 5);
  assertEq(collectableFor(structures[1], now), 100);
  assertEq(collectableFor(structures[2], now), 0);

  const collected = calculateCollectable(structures, now);
  const supabaseCollected = supabaseCalculateCollectable(structures, now);
  assertEq(stableStringify(collected), stableStringify(supabaseCollected));
  assertEq(collected.almas, 5);
  assertEq(collected.ossos, 100);
});

Deno.test("base domain preserves upgrade blocks and state payload contract", () => {
  const now = new Date("2026-05-30T12:00:00.000Z");
  const resources = resourceRow({ energia: 200 });
  const structures = [
    structure("nucleo_energia", 5, "2026-05-30T00:00:00.000Z"),
    structure("altar_das_almas", 40, "2026-05-30T00:00:00.000Z"),
  ];
  const jobs: BaseConstructionJobRow[] = [job("nucleo_energia", now)];

  assertEq(
    upgradeBlockReason(
      structures[0],
      { id: "player-1", level: 10 },
      resources,
      jobs[0],
      1,
      1,
    ),
    "STRUCTURE_ALREADY_UPGRADING",
  );
  assertEq(
    upgradeBlockMessage("CONSTRUCTION_QUEUE_FULL"),
    "Fila de construcao cheia.",
  );
  assertEq(upgradeCost(8), 32);
  assertEq(upgradeDurationSeconds(8), 23040);
  assert(
    definitionFor("ossario") !== undefined,
    "ossario definition should exist",
  );

  const payload = baseStatePayload({
    player: { id: "player-1", level: 10 },
    resources,
    structures,
    jobs,
    constructionSlots: 2,
  }, now);
  const supabasePayload = supabaseBaseStatePayload({
    player: { id: "player-1", level: 10 },
    resources,
    structures,
    jobs,
    constructionSlots: 2,
  }, now);

  assertEq(stableStringify(payload), stableStringify(supabasePayload));
  assertEq(payload.ok, true);
  const base = objectField(payload, "base");
  assertEq(
    stringField(base, "construction_slots_source"),
    DOUBLE_CONSTRUCTION_QUEUE_PRODUCT_ID,
  );
  assertEq(numberField(base, "construction_slots"), 2);

  const projectedStructures = arrayField(base, "structures");
  assertEq(projectedStructures.length, 2);
  const energyStructure = objectValue(projectedStructures[0]);
  assertEq(stringField(energyStructure, "display_name"), "Nucleo de Energia");
  assertEq(
    stringField(energyStructure, "blocked_reason"),
    "STRUCTURE_ALREADY_UPGRADING",
  );
  assertEq(objectField(energyStructure, "active_job").remaining_seconds, 3600);

  assertEq(BASE_STRUCTURES.length, 6);
  assertEq(DEFAULT_CONSTRUCTION_SLOTS, 1);
});

function structure(
  structureId: string,
  level: number,
  lastCollectedAt: string,
): BaseStructureRow {
  return {
    player_id: "player-1",
    structure_id: structureId,
    level,
    last_collected_at: lastCollectedAt,
    updated_at: lastCollectedAt,
  };
}

function resourceRow(
  overrides: Partial<BaseResourceRow> = {},
): BaseResourceRow {
  return {
    player_id: "player-1",
    almas: 0,
    energia: 0,
    sangue: 0,
    cristais: 0,
    ossos: 0,
    po_osso: 0,
    diamante: 0,
    updated_at: "2026-05-30T00:00:00.000Z",
    ...overrides,
  };
}

function job(structureId: string, now: Date): BaseConstructionJobRow {
  return {
    id: "job-1",
    player_id: "player-1",
    structure_id: structureId,
    target_level: 6,
    status: "active",
    cost_payload: { energia: 20 },
    started_at: now.toISOString(),
    completes_at: new Date(now.getTime() + 3600 * 1000).toISOString(),
    completed_at: null,
    request_id: "00000000-0000-4000-8000-000000000001",
    created_at: now.toISOString(),
    updated_at: now.toISOString(),
  };
}

function normalizeNewlines(value: string): string {
  return value.replace(/\r\n/g, "\n");
}

function stableStringify(value: unknown): string {
  if (Array.isArray(value)) {
    return `[${value.map(stableStringify).join(",")}]`;
  }
  if (isObject(value)) {
    return `{${
      Object.keys(value).sort().map((key) =>
        `${JSON.stringify(key)}:${stableStringify(value[key])}`
      ).join(",")
    }}`;
  }
  return JSON.stringify(value);
}

function objectValue(value: unknown): Record<string, unknown> {
  assert(isObject(value), `value should be object: ${JSON.stringify(value)}`);
  return value;
}

function objectField(
  payload: Record<string, unknown>,
  key: string,
): Record<string, unknown> {
  return objectValue(payload[key]);
}

function arrayField(payload: Record<string, unknown>, key: string): unknown[] {
  const value = payload[key];
  assert(Array.isArray(value), `${key} should be an array`);
  return value;
}

function stringField(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value : "";
}

function numberField(payload: Record<string, unknown>, key: string): number {
  const value = payload[key];
  if (typeof value === "number") return value;
  if (typeof value === "string") return Number(value);
  throw new Error(`${key} should be numeric, got ${JSON.stringify(value)}`);
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(actual: unknown, expected: unknown, message?: string): void {
  if (actual !== expected) {
    throw new Error(
      `${message ?? "values should match"}. Expected ${
        JSON.stringify(expected)
      }, got ${JSON.stringify(actual)}`,
    );
  }
}

function assertNotIncludes(
  actual: string,
  search: string,
  message: string,
): void {
  if (actual.includes(search)) {
    throw new Error(`${message}. Unexpected ${search}.`);
  }
}
