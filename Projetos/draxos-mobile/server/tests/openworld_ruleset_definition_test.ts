const PROJECT_PREFIX = "Projetos/draxos-mobile";
const RULESET_PATH = "data/definitions/openworld/forest_ruleset_v1.json";
const BASE_MIGRATION_PATH = "server/schema/migrations/202606020001_openworld_bosque_hardening_v1.sql";
const GUIDANCE_MIGRATION_PATH =
  "server/schema/migrations/202606040001_openworld_guidance_persistence_v1.sql";
const COLLECTION_SYNC_MIGRATION_PATH =
  "server/schema/migrations/202606040002_openworld_bosque_collection_sync_v1.sql";
const SUPABASE_COLLECTION_SYNC_MIGRATION_PATH =
  "supabase/migrations/202606040002_openworld_bosque_collection_sync_v1.sql";
const COLLECT_BATCH_MIGRATION_PATH =
  "server/schema/migrations/202606050003_openworld_bosque_collect_batch_v1.sql";
const SUPABASE_COLLECT_BATCH_MIGRATION_PATH =
  "supabase/migrations/202606050003_openworld_bosque_collect_batch_v1.sql";
const CHECKPOINT_MIGRATION_PATH =
  "server/schema/migrations/202606060001_openworld_bosque_checkpoint_v1.sql";
const SUPABASE_CHECKPOINT_MIGRATION_PATH =
  "supabase/migrations/202606060001_openworld_bosque_checkpoint_v1.sql";
const DURABLE_PROGRESS_MIGRATION_PATH =
  "server/schema/migrations/202606060002_openworld_bosque_durable_progress_v1.sql";
const SUPABASE_DURABLE_PROGRESS_MIGRATION_PATH =
  "supabase/migrations/202606060002_openworld_bosque_durable_progress_v1.sql";
const SESSION_LIFECYCLE_STRUCTURES_MIGRATION_PATH =
  "server/schema/migrations/202606070001_openworld_bosque_session_lifecycle_structures_v1.sql";
const SUPABASE_SESSION_LIFECYCLE_STRUCTURES_MIGRATION_PATH =
  "supabase/migrations/202606070001_openworld_bosque_session_lifecycle_structures_v1.sql";
const MODE_DOMAIN_PATH = "server/functions/_shared/mode_domain.ts";
const SUPABASE_MODE_DOMAIN_PATH = "supabase/functions/_shared/mode_domain.ts";

Deno.test("openworld forest ruleset v1 is active internal alpha and keeps v0 historical", async () => {
  const ruleset = await rulesetDefinition();
  assertEq(
    stringField(ruleset, "schema_version"),
    "openworld_forest_ruleset_v1",
    "schema should be v1",
  );
  assertEq(
    stringField(ruleset, "ruleset_id"),
    "openworld_forest_ruleset_v1",
    "ruleset id should be v1",
  );
  assertEq(numberField(ruleset, "ruleset_version"), 1, "ruleset version should be 1");
  assertEq(stringField(ruleset, "status"), "active", "bosque should be active");
  assertEq(
    stringField(ruleset, "release_channel"),
    "internal_alpha",
    "release channel remains internal alpha",
  );
  const historicalRulesets = arrayField(ruleset, "historical_rulesets");
  assert(
    historicalRulesets.some((entry) => {
      const historical = objectField(entry);
      return stringField(historical, "ruleset_id") === "openworld_forest_ruleset_v0" &&
        stringField(historical, "status") === "historical";
    }),
    "v0 should remain documented as historical",
  );
});

Deno.test("openworld forest ruleset cross-links resource nodes and recipe items", async () => {
  const ruleset = await rulesetDefinition();
  const itemIds = new Set(
    arrayField(ruleset, "items").map((item) => stringField(objectField(item), "item_id")),
  );

  for (const node of arrayField(ruleset, "resource_nodes").map(objectField)) {
    assert(
      itemIds.has(stringField(node, "item_id")),
      `node ${stringField(node, "node_id")} should reference a known item`,
    );
  }

  for (const recipe of arrayField(ruleset, "recipes").map(objectField)) {
    for (const itemId of Object.keys(objectField(recipe["cost"]))) {
      assert(
        itemIds.has(itemId),
        `recipe ${stringField(recipe, "recipe_id")} cost should reference ${itemId}`,
      );
    }
    for (const itemId of Object.keys(objectField(recipe["output"]))) {
      assert(
        itemIds.has(itemId),
        `recipe ${stringField(recipe, "recipe_id")} output should reference ${itemId}`,
      );
    }
  }
});

Deno.test("openworld forest resource nodes stay clear of blockers and borders", async () => {
  const ruleset = await rulesetDefinition();
  const world = objectField(ruleset["world"]);
  const worldSize = vectorField(world, "size");
  const collectionRadius = numberField(world, "collection_radius");
  const playerCollisionRadius = 20;
  const minimumCollectionMargin = 8;
  const minimumStandableClearance = playerCollisionRadius + minimumCollectionMargin;
  const blockers = blockingCollisionFixtures(ruleset);

  assert(
    collectionRadius >= playerCollisionRadius + minimumCollectionMargin,
    "collection radius should cover the player body plus the minimum collection margin",
  );

  for (const node of arrayField(ruleset, "resource_nodes").map(objectField)) {
    const nodeId = stringField(node, "node_id");
    const position = vectorField(node, "position");
    const borderClearance = Math.min(
      position.x,
      position.y,
      worldSize.x - position.x,
      worldSize.y - position.y,
    );
    assert(
      borderClearance >= minimumStandableClearance,
      `${nodeId} should stay collectable away from map borders. ` +
        `Clearance=${roundForMessage(borderClearance)}`,
    );

    for (const blocker of blockers) {
      const blockerClearance = signedDistanceToBlocker(position, blocker);
      assert(
        blockerClearance >= minimumStandableClearance,
        `${nodeId} should not spawn inside or too close to blocker ${blocker.id}. ` +
          `Clearance=${roundForMessage(blockerClearance)}`,
      );
    }
  }
});

Deno.test("openworld forest ruleset is referenced by TS domain and effective SQL logic", async () => {
  const ruleset = await rulesetDefinition();
  const baseMigration = await projectText(BASE_MIGRATION_PATH);
  const guidanceMigration = await projectText(GUIDANCE_MIGRATION_PATH);
  const collectionSyncMigration = await projectText(COLLECTION_SYNC_MIGRATION_PATH);
  const supabaseCollectionSyncMigration = await projectText(
    SUPABASE_COLLECTION_SYNC_MIGRATION_PATH,
  );
  const collectBatchMigration = await projectText(COLLECT_BATCH_MIGRATION_PATH);
  const supabaseCollectBatchMigration = await projectText(SUPABASE_COLLECT_BATCH_MIGRATION_PATH);
  const checkpointMigration = await projectText(CHECKPOINT_MIGRATION_PATH);
  const supabaseCheckpointMigration = await projectText(SUPABASE_CHECKPOINT_MIGRATION_PATH);
  const durableProgressMigration = await projectText(DURABLE_PROGRESS_MIGRATION_PATH);
  const supabaseDurableProgressMigration = await projectText(SUPABASE_DURABLE_PROGRESS_MIGRATION_PATH);
  const sessionLifecycleStructuresMigration = await projectText(SESSION_LIFECYCLE_STRUCTURES_MIGRATION_PATH);
  const supabaseSessionLifecycleStructuresMigration = await projectText(
    SUPABASE_SESSION_LIFECYCLE_STRUCTURES_MIGRATION_PATH,
  );
  const effectiveMigration =
    `${baseMigration}\n${guidanceMigration}\n${collectionSyncMigration}\n${collectBatchMigration}\n${checkpointMigration}\n${durableProgressMigration}\n${sessionLifecycleStructuresMigration}`;
  const modeDomain = await projectText(MODE_DOMAIN_PATH);
  const supabaseModeDomain = await projectText(SUPABASE_MODE_DOMAIN_PATH);

  assertEq(
    normalizeNewlines(modeDomain),
    normalizeNewlines(supabaseModeDomain),
    "mode domain should be mirrored between server and supabase",
  );
  assertIncludes(
    modeDomain,
    RULESET_PATH,
    "mode domain should import the shared ruleset definition",
  );
  assertIncludes(
    modeDomain,
    "guidance_update",
    "mode domain should accept Bosque guidance updates",
  );
  assertIncludes(
    modeDomain,
    "collect_batch",
    "mode domain should accept batched Bosque collection events",
  );
  assertIncludes(
    modeDomain,
    "sessionCheckpointFromBody",
    "mode domain should parse offline-first checkpoint payloads",
  );
  assertEq(
    normalizeNewlines(collectionSyncMigration),
    normalizeNewlines(supabaseCollectionSyncMigration),
    "collection sync migration should be mirrored between server and supabase",
  );
  assertEq(
    normalizeNewlines(collectBatchMigration),
    normalizeNewlines(supabaseCollectBatchMigration),
    "collect batch migration should be mirrored between server and supabase",
  );
  assertEq(
    normalizeNewlines(checkpointMigration),
    normalizeNewlines(supabaseCheckpointMigration),
    "checkpoint migration should be mirrored between server and supabase",
  );
  assertEq(
    normalizeNewlines(durableProgressMigration),
    normalizeNewlines(supabaseDurableProgressMigration),
    "durable progress migration should be mirrored between server and supabase",
  );
  assertEq(
    normalizeNewlines(sessionLifecycleStructuresMigration),
    normalizeNewlines(supabaseSessionLifecycleStructuresMigration),
    "session lifecycle structures migration should be mirrored between server and supabase",
  );
  assertIncludes(
    collectBatchMigration,
    "'collect_batch'",
    "collect batch migration should allow collect_batch in event audit",
  );
  assertIncludes(
    checkpointMigration,
    "mode_session_checkpoint_v1",
    "checkpoint migration should add a dedicated checkpoint RPC",
  );
  assertIncludes(
    checkpointMigration,
    "'checkpoint'",
    "checkpoint migration should audit accepted checkpoints",
  );
  assertIncludes(
    durableProgressMigration,
    "openworld_forest_progress_v1",
    "durable progress migration should define Bosque save progress",
  );
  assertIncludes(
    sessionLifecycleStructuresMigration,
    "openworld_forest_progress_from_snapshot_v1",
    "session lifecycle hotfix should override durable progress extraction",
  );
  assertIncludes(
    sessionLifecycleStructuresMigration,
    "result := jsonb_set(result, '{structures}'",
    "session lifecycle hotfix should persist durable structures",
  );
  assertIncludes(
    sessionLifecycleStructuresMigration,
    "result := jsonb_set(result, '{collected_nodes}', '{}'::jsonb",
    "new sessions should reset visit collected nodes",
  );
  assertIncludes(
    sessionLifecycleStructuresMigration,
    "fogueira_estavel_1",
    "session lifecycle hotfix should canonicalize Fogueira between upgrades and structures",
  );
  assertIncludes(
    effectiveMigration,
    stringField(ruleset, "ruleset_id"),
    "effective migration chain should seed ruleset v1",
  );
  for (const node of arrayField(ruleset, "resource_nodes").map(objectField)) {
    const nodeId = stringField(node, "node_id");
    const itemId = stringField(node, "item_id");
    assertIncludes(
      collectionSyncMigration,
      `when '${nodeId}' then '${itemId}'`,
      `collection sync migration should map node ${nodeId}`,
    );
  }
});

Deno.test("openworld forest event migration preserves position except move heartbeat", async () => {
  const migration = await projectText(COLLECT_BATCH_MIGRATION_PATH);
  const applyEventFunction = sqlFunctionBody(migration, "openworld_forest_apply_event_v1");
  const moveBranchStart = applyEventFunction.indexOf("if p_event_type = 'move_heartbeat'");
  const collectBranchStart = applyEventFunction.indexOf("elsif p_event_type = 'collect_start'");

  assert(moveBranchStart >= 0, "apply event function should branch on move heartbeat");
  assert(collectBranchStart > moveBranchStart, "collect branch should follow move heartbeat branch");
  assertEq(
    applyEventFunction.slice(0, moveBranchStart).includes("'{player_position}'"),
    false,
    "apply event should not write player_position before event type dispatch",
  );
  assertIncludes(
    applyEventFunction.slice(moveBranchStart, collectBranchStart),
    "'{player_position}'",
    "move heartbeat branch should write player_position",
  );
  assertEq(
    applyEventFunction.slice(collectBranchStart).includes("'{player_position}'"),
    false,
    "collection/deposit/craft/guidance branches should preserve persisted player_position",
  );
});

Deno.test("openworld forest collect batch migration validates nodes atomically", async () => {
  const migration = await projectText(COLLECT_BATCH_MIGRATION_PATH);
  const applyEventFunction = sqlFunctionBody(migration, "openworld_forest_apply_event_v1");
  const batchBranchStart = applyEventFunction.indexOf("elsif p_event_type = 'collect_batch'");
  const depositBranchStart = applyEventFunction.indexOf("elsif p_event_type = 'deposit_all'");
  assert(batchBranchStart >= 0, "apply event function should support collect_batch");
  assert(depositBranchStart > batchBranchStart, "deposit should apply after collect_batch");
  const batchBranch = applyEventFunction.slice(batchBranchStart, depositBranchStart);

  assertIncludes(
    batchBranch,
    "jsonb_array_elements(nodes_payload)",
    "collect_batch should iterate payload nodes inside one event",
  );
  assertIncludes(
    batchBranch,
    "batch_seen_nodes ? batch_node_id",
    "collect_batch should reject duplicate nodes in the same batch",
  );
  assertIncludes(
    batchBranch,
    "OPENWORLD_NODE_ALREADY_COLLECTED",
    "collect_batch should reject already collected nodes",
  );
  assertIncludes(
    batchBranch,
    "MODE_RESULT_REJECTED",
    "collect_batch should reject capacity overflow",
  );
  assertIncludes(
    batchBranch,
    "batch_count < 1",
    "collect_batch should reject empty batches",
  );
});

Deno.test("openworld forest checkpoint migration validates snapshots and gates rewards", async () => {
  const migration = await projectText(CHECKPOINT_MIGRATION_PATH);
  const durableMigration = await projectText(DURABLE_PROGRESS_MIGRATION_PATH);
  const validateFunction = sqlFunctionBody(migration, "openworld_forest_validate_checkpoint_v1");
  const validateV2Function = sqlFunctionBody(
    durableMigration,
    "openworld_forest_validate_checkpoint_v2",
  );
  const checkpointFunction = sqlFunctionBody(migration, "mode_session_checkpoint_v1");
  const durableCheckpointFunction = sqlFunctionBody(durableMigration, "mode_session_checkpoint_v1");
  const completeWrapper = sqlFunctionBody(migration, "mode_session_complete_v1");
  const durableCompleteWrapper = sqlFunctionBody(durableMigration, "mode_session_complete_v1");

  assertIncludes(
    validateFunction,
    "public.openworld_forest_node_item_v1",
    "checkpoint validation should derive collected nodes from the ruleset",
  );
  assertIncludes(
    validateFunction,
    "public.openworld_forest_clean_inventory_v1",
    "checkpoint validation should sanitize local pocket and chest",
  );
  assertIncludes(
    validateFunction,
    "MODE_CHECKPOINT_REJECTED",
    "invalid checkpoint snapshots should fail atomically",
  );
  assertIncludes(
    checkpointFunction,
    "'modes/session/checkpoint'",
    "checkpoint RPC should reserve a dedicated idempotency endpoint",
  );
  assertIncludes(
    checkpointFunction,
    "'mode_checkpoint_ack'",
    "checkpoint RPC should return explicit checkpoint ACK semantics",
  );
  assertIncludes(
    checkpointFunction,
    "snapshot_revision = revision_after",
    "accepted checkpoint should advance one snapshot revision",
  );
  assertIncludes(
    completeWrapper,
    "MODE_CHECKPOINT_REQUIRED",
    "completion should require an accepted checkpoint before reward",
  );
  assertIncludes(
    validateV2Function,
    "base_progress",
    "durable checkpoint validation should use the session-start progress base",
  );
  assertIncludes(
    validateV2Function,
    "recipe_costs",
    "durable checkpoint validation should still prove new crafts are derivable",
  );
  assertIncludes(
    durableCheckpointFunction,
    "openworld_forest_mark_checkpoint_progress_v1",
    "checkpoint should save durable pocket, chest and upgrades",
  );
  assertIncludes(
    durableCheckpointFunction,
    "openworld_forest_inventory_delta_above_v1",
    "checkpoint should expose only unrewarded chest deltas to reward completion",
  );
  assertIncludes(
    durableCompleteWrapper,
    "openworld_forest_mark_completed_progress_v1",
    "completion should preserve durable Bosque progress and update reward ledger",
  );
});

async function rulesetDefinition(): Promise<Record<string, unknown>> {
  return objectField(JSON.parse(await projectText(RULESET_PATH)));
}

async function projectText(relativePath: string): Promise<string> {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  const path = cwd.endsWith("/draxos-mobile") ? relativePath : `${PROJECT_PREFIX}/${relativePath}`;
  return await Deno.readTextFile(path);
}

function objectField(value: unknown): Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown>
    : {};
}

function arrayField(record: Record<string, unknown>, key: string): unknown[] {
  return Array.isArray(record[key]) ? record[key] as unknown[] : [];
}

function stringField(record: Record<string, unknown>, key: string): string {
  return typeof record[key] === "string" ? record[key] as string : "";
}

function numberField(record: Record<string, unknown>, key: string): number {
  return typeof record[key] === "number" ? record[key] as number : Number.NaN;
}

type Vector2 = {
  x: number;
  y: number;
};

type BlockingCollisionFixture = {
  id: string;
  collisionShape: string;
  position: Vector2;
  collisionSize: Vector2;
  collisionRadius: number;
  collisionOffset: Vector2;
};

function blockingCollisionFixtures(ruleset: Record<string, unknown>): BlockingCollisionFixture[] {
  const world = objectField(ruleset["world"]);
  const result: BlockingCollisionFixture[] = [
    {
      id: "chest_home",
      collisionShape: "rectangle",
      position: vectorField(world, "chest_position"),
      collisionSize: { x: 82, y: 54 },
      collisionRadius: 43,
      collisionOffset: { x: 0, y: 4 },
    },
  ];

  for (const section of ["structures", "obstacles"]) {
    for (const entry of arrayField(ruleset, section).map(objectField)) {
      if (entry["blocks_player"] === false) continue;
      result.push({
        id: stringField(entry, "id"),
        collisionShape: stringField(entry, "collision_shape") || "circle",
        position: vectorField(entry, "position"),
        collisionSize: vectorField(entry, "collision_size"),
        collisionRadius: numberField(entry, "collision_radius"),
        collisionOffset: vectorField(entry, "collision_offset"),
      });
    }
  }

  return result;
}

function vectorField(
  record: Record<string, unknown>,
  key: string,
  fallback: Vector2 = { x: 0, y: 0 },
): Vector2 {
  const value = objectField(record[key]);
  const x = numberField(value, "x");
  const y = numberField(value, "y");
  return Number.isFinite(x) && Number.isFinite(y) ? { x, y } : fallback;
}

function signedDistanceToBlocker(point: Vector2, blocker: BlockingCollisionFixture): number {
  const center = addVectors(blocker.position, blocker.collisionOffset);
  if (blocker.collisionShape === "rectangle") {
    return signedDistanceToRectangle(point, center, blocker.collisionSize);
  }
  return distanceBetween(point, center) - blocker.collisionRadius;
}

function signedDistanceToRectangle(point: Vector2, center: Vector2, size: Vector2): number {
  const dx = Math.abs(point.x - center.x) - size.x * 0.5;
  const dy = Math.abs(point.y - center.y) - size.y * 0.5;
  const outsideDistance = Math.hypot(Math.max(dx, 0), Math.max(dy, 0));
  const insideDistance = Math.min(Math.max(dx, dy), 0);
  return outsideDistance + insideDistance;
}

function addVectors(left: Vector2, right: Vector2): Vector2 {
  return { x: left.x + right.x, y: left.y + right.y };
}

function distanceBetween(left: Vector2, right: Vector2): number {
  return Math.hypot(left.x - right.x, left.y - right.y);
}

function roundForMessage(value: number): string {
  return value.toFixed(2);
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(`${message}. Actual=${String(actual)} Expected=${String(expected)}`);
  }
}

function assertIncludes(haystack: string, needle: string, message: string): void {
  if (!haystack.includes(needle)) throw new Error(`${message}. Missing=${needle}`);
}

function normalizeNewlines(value: string): string {
  return value.replaceAll("\r\n", "\n");
}

function sqlFunctionBody(sql: string, functionName: string): string {
  const marker = `create or replace function public.${functionName}`;
  const start = sql.indexOf(marker);
  assert(start >= 0, `migration should define ${functionName}`);
  const end = sql.indexOf("\n$$;", start);
  assert(end > start, `migration should close ${functionName}`);
  return sql.slice(start, end);
}
