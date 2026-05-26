import { emptyResponse, jsonResponse } from "../_shared/http.ts";
import { type SaveType, saveTypeFromRequest, saveTypeQuery } from "../_shared/save_context.ts";

type Route = "state" | "collect" | "upgrade";

interface EdgeConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

interface AuthContext {
  userId: string;
  saveType: SaveType;
}

interface RestError {
  code: string;
  message: string;
  status: number;
}

interface JwtPayload {
  sub?: unknown;
  is_anonymous?: unknown;
}

interface PlayerRow {
  id: string;
  save_type: SaveType;
  level: number;
}

interface ResourceRow {
  player_id: string;
  almas: string | number;
  energia: string | number;
  sangue: string | number;
  cristais: string | number;
  ossos: string | number;
  diamante: string | number;
  updated_at: string;
}

interface BaseStructureRow {
  player_id: string;
  structure_id: string;
  level: number;
  last_collected_at: string;
  updated_at: string;
}

interface ConstructionJobRow {
  id: string;
  player_id: string;
  structure_id: string;
  target_level: number;
  status: "active" | "completed";
  cost_payload: unknown;
  started_at: string;
  completes_at: string;
  completed_at: string | null;
  request_id: string;
  created_at: string;
  updated_at: string;
}

interface IdempotencyRow {
  response_payload: unknown;
}

interface StructureDefinition {
  id: string;
  displayName: string;
  description: string;
  benefitLabel: string;
  resource: ResourceKey | null;
  dailyAtLevel40: number;
}

type ResourceKey = "almas" | "energia" | "sangue" | "cristais" | "ossos";

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const SECONDS_PER_DAY = 86_400;
const MAX_STRUCTURE_LEVEL = 40;
const DEFAULT_CONSTRUCTION_SLOTS = 1;
const DOUBLE_CONSTRUCTION_QUEUE_PRODUCT_ID = "alpha_double_construction_queue";
const STRUCTURES: StructureDefinition[] = [
  {
    id: "altar_das_almas",
    displayName: "Altar das Almas",
    description: "Produz Almas e sustenta upgrades de instrumento, slots de spell e spells.",
    benefitLabel: "Almas para progressao arcana",
    resource: "almas",
    dailyAtLevel40: 10,
  },
  {
    id: "nucleo_energia",
    displayName: "Nucleo de Energia",
    description: "Produz Energia, o gargalo principal das construcoes da base.",
    benefitLabel: "Energia para evoluir predios",
    resource: "energia",
    dailyAtLevel40: 80,
  },
  {
    id: "pocos_sangue",
    displayName: "Pocos de Sangue",
    description: "Produz Sangue para crescimento de Familiares e sistemas biologicos.",
    benefitLabel: "Sangue para Familiares",
    resource: "sangue",
    dailyAtLevel40: 8,
  },
  {
    id: "minas_cristal",
    displayName: "Minas de Cristal",
    description: "Produz Cristais usados em Doutrinas e refinamentos arcanos.",
    benefitLabel: "Cristais para Doutrinas",
    resource: "cristais",
    dailyAtLevel40: 5,
  },
  {
    id: "estrutura_stats",
    displayName: "Estrutura de Stats",
    description: "Abriga melhorias permanentes de Vida, dano base, Defesa, Mana e regen.",
    benefitLabel: "Bonus permanentes de personagem",
    resource: null,
    dailyAtLevel40: 0,
  },
  {
    id: "ossario",
    displayName: "Ossario",
    description: "Produz Ossos e sustenta crafting de qualidade do instrumento ritual.",
    benefitLabel: "Ossos para crafting",
    resource: "ossos",
    dailyAtLevel40: 2,
  },
];

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  try {
    const route = resolveRoute(new URL(request.url).pathname);
    if (route === null) {
      return errorResponse("NOT_FOUND", "Unknown base endpoint.", 404);
    }

    if (route === "state" && request.method !== "GET") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use GET /base/state.", 405);
    }
    if (route === "collect" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /base/collect.", 405);
    }
    if (route === "upgrade" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /base/upgrade.", 405);
    }

    const auth = decodeAuthContext(request);
    if (auth.error !== null) {
      return errorResponse(auth.error.code, auth.error.message, auth.error.status);
    }

    const config = loadConfig();
    if (config.error !== null) {
      return errorResponse(config.error.code, config.error.message, config.error.status);
    }

    if (route === "state") {
      return await handleState(auth.value, config.value);
    }
    if (route === "collect") {
      return await handleCollect(request, auth.value, config.value);
    }
    return await handleUpgrade(request, auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse("INTERNAL_ERROR", "Unexpected base service error.", 500);
  }
});

async function handleState(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const state = await loadBaseState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  await completeDueJobs(config, state.value.player.id, state.value.jobs, new Date());
  const refreshed = await loadBaseState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }
  return jsonResponse(baseStatePayload(refreshed.value));
}

async function handleCollect(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }

  const state = await loadBaseState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const existing = await loadIdempotency(config, state.value.player.id, "base/collect", requestId);
  if (existing.error !== null) {
    return errorResponse(existing.error.code, existing.error.message, existing.error.status);
  }
  if (existing.value !== null) {
    return jsonResponse(existing.value);
  }

  const now = new Date();
  await completeDueJobs(config, state.value.player.id, state.value.jobs, now);
  const refreshed = await loadBaseState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }

  const collected = calculateCollectable(refreshed.value.structures, now);
  const hasDelta = Object.values(collected).some((value) => value > 0);
  if (hasDelta) {
    const resources = refreshed.value.resources;
    const patch = {
      almas: numberValue(resources.almas, 0) + (collected.almas ?? 0),
      energia: numberValue(resources.energia, 0) + (collected.energia ?? 0),
      sangue: numberValue(resources.sangue, 0) + (collected.sangue ?? 0),
      cristais: numberValue(resources.cristais, 0) + (collected.cristais ?? 0),
      ossos: numberValue(resources.ossos, 0) + (collected.ossos ?? 0),
      updated_at: now.toISOString(),
    };
    const resourcePatch = await restRequest<unknown>(
      config,
      `resources?player_id=eq.${encodeURIComponent(refreshed.value.player.id)}`,
      { method: "PATCH", headers: { prefer: "return=minimal" }, body: JSON.stringify(patch) },
    );
    if (resourcePatch.error !== null) {
      return errorResponse("BASE_COLLECT_FAILED", "Unable to apply collected resources.", 500);
    }
    const transaction = await insertLedger(
      config,
      refreshed.value.player.id,
      "base/collect",
      requestId,
      collected,
    );
    if (transaction !== null) {
      return errorResponse(transaction.code, transaction.message, transaction.status);
    }
  }

  for (const structure of refreshed.value.structures) {
    if (definitionFor(structure.structure_id)?.resource === null) {
      continue;
    }
    await restRequest<unknown>(
      config,
      `base_structures?player_id=eq.${
        encodeURIComponent(refreshed.value.player.id)
      }&structure_id=eq.${encodeURIComponent(structure.structure_id)}`,
      {
        method: "PATCH",
        headers: { prefer: "return=minimal" },
        body: JSON.stringify({
          last_collected_at: now.toISOString(),
          updated_at: now.toISOString(),
        }),
      },
    );
  }

  const finalState = await loadBaseState(auth, config);
  if (finalState.error !== null) {
    return errorResponse(finalState.error.code, finalState.error.message, finalState.error.status);
  }
  const responsePayload = {
    ...baseStatePayload(finalState.value),
    collected,
  };
  const idem = await insertIdempotency(
    config,
    finalState.value.player.id,
    "base/collect",
    requestId,
    responsePayload,
  );
  if (idem !== null) {
    return errorResponse(idem.code, idem.message, idem.status);
  }
  return jsonResponse(responsePayload);
}

async function handleUpgrade(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const structureId = stringField(body, "structure_id");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  const definition = definitionFor(structureId);
  if (definition === undefined) {
    return errorResponse("INVALID_STRUCTURE", "structure_id is not part of Base v0.", 400);
  }

  const state = await loadBaseState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const existing = await loadIdempotency(config, state.value.player.id, "base/upgrade", requestId);
  if (existing.error !== null) {
    return errorResponse(existing.error.code, existing.error.message, existing.error.status);
  }
  if (existing.value !== null) {
    return jsonResponse(existing.value);
  }

  const now = new Date();
  await completeDueJobs(config, state.value.player.id, state.value.jobs, now);
  const refreshed = await loadBaseState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }

  const structure = refreshed.value.structures.find((item) => item.structure_id === structureId);
  if (structure === undefined) {
    return errorResponse("BASE_STATE_INCOMPLETE", "Base structure state is missing.", 409);
  }
  if (
    refreshed.value.jobs.some((job) => job.status === "active" && job.structure_id === structureId)
  ) {
    return errorResponse(
      "STRUCTURE_ALREADY_UPGRADING",
      "This structure already has an active upgrade.",
      409,
    );
  }
  if (
    refreshed.value.jobs.filter((job) => job.status === "active").length >=
      refreshed.value.constructionSlots
  ) {
    return errorResponse("CONSTRUCTION_QUEUE_FULL", "No construction slot is available.", 409);
  }

  const targetLevel = structure.level + 1;
  const cap = Math.min(MAX_STRUCTURE_LEVEL, Math.max(1, refreshed.value.player.level));
  if (targetLevel > cap) {
    return errorResponse("LEVEL_CAP_REACHED", "Structure upgrade is limited by player level.", 409);
  }
  const cost = upgradeCost(targetLevel);
  if (numberValue(refreshed.value.resources.energia, 0) < cost) {
    return errorResponse("INSUFFICIENT_RESOURCES", "Not enough Energia for this upgrade.", 409);
  }

  const resourcePatch = await restRequest<unknown>(
    config,
    `resources?player_id=eq.${encodeURIComponent(refreshed.value.player.id)}`,
    {
      method: "PATCH",
      headers: { prefer: "return=minimal" },
      body: JSON.stringify({
        energia: numberValue(refreshed.value.resources.energia, 0) - cost,
        updated_at: now.toISOString(),
      }),
    },
  );
  if (resourcePatch.error !== null) {
    return errorResponse("BASE_UPGRADE_FAILED", "Unable to spend Energia.", 500);
  }

  const completesAt = new Date(now.getTime() + upgradeDurationSeconds(targetLevel) * 1000);
  const jobInsert = await restRequest<ConstructionJobRow[]>(
    config,
    "construction_jobs?select=*",
    {
      method: "POST",
      headers: { prefer: "return=representation" },
      body: JSON.stringify({
        player_id: refreshed.value.player.id,
        structure_id: structureId,
        target_level: targetLevel,
        cost_payload: { energia: -cost },
        started_at: now.toISOString(),
        completes_at: completesAt.toISOString(),
        request_id: requestId,
      }),
    },
  );
  if (jobInsert.error !== null) {
    return errorResponse("BASE_UPGRADE_FAILED", "Unable to create construction job.", 500);
  }
  const ledger = await insertLedger(config, refreshed.value.player.id, "base/upgrade", requestId, {
    energia: -cost,
  });
  if (ledger !== null) {
    return errorResponse(ledger.code, ledger.message, ledger.status);
  }

  const finalState = await loadBaseState(auth, config);
  if (finalState.error !== null) {
    return errorResponse(finalState.error.code, finalState.error.message, finalState.error.status);
  }
  const responsePayload = {
    ...baseStatePayload(finalState.value),
    job: jobInsert.value[0] ?? null,
  };
  const idem = await insertIdempotency(
    config,
    finalState.value.player.id,
    "base/upgrade",
    requestId,
    responsePayload,
  );
  if (idem !== null) {
    return errorResponse(idem.code, idem.message, idem.status);
  }
  return jsonResponse(responsePayload);
}

async function loadBaseState(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<
  {
    value: {
      player: PlayerRow;
      resources: ResourceRow;
      structures: BaseStructureRow[];
      jobs: ConstructionJobRow[];
      constructionSlots: number;
    };
    error: null;
  } | { value: null; error: RestError }
> {
  const playerResult = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${encodeURIComponent(auth.userId)}&${
      saveTypeQuery(auth.saveType)
    }&select=id,save_type,level&limit=1`,
    { method: "GET" },
  );
  if (playerResult.error !== null) {
    return { value: null, error: stateReadError() };
  }
  const player = playerResult.value[0] ?? null;
  if (player === null) {
    return {
      value: null,
      error: {
        code: "PLAYER_NOT_FOUND",
        message: "Guest account was not created yet.",
        status: 404,
      },
    };
  }

  await ensureBaseRows(config, player.id);
  const constructionSlots = await loadConstructionSlots(config, player.id);
  if (constructionSlots.error !== null) {
    return { value: null, error: constructionSlots.error };
  }
  const playerId = encodeURIComponent(player.id);
  const resourcesResult = await restRequest<ResourceRow[]>(
    config,
    `resources?player_id=eq.${playerId}&select=player_id,almas,energia,sangue,cristais,ossos,diamante,updated_at&limit=1`,
    { method: "GET" },
  );
  const structuresResult = await restRequest<BaseStructureRow[]>(
    config,
    `base_structures?player_id=eq.${playerId}&select=player_id,structure_id,level,last_collected_at,updated_at&order=structure_id.asc`,
    { method: "GET" },
  );
  const jobsResult = await restRequest<ConstructionJobRow[]>(
    config,
    `construction_jobs?player_id=eq.${playerId}&select=*&order=created_at.desc`,
    { method: "GET" },
  );
  if (
    resourcesResult.error !== null || structuresResult.error !== null || jobsResult.error !== null
  ) {
    return { value: null, error: stateReadError() };
  }
  const resources = resourcesResult.value[0] ?? null;
  if (resources === null || structuresResult.value.length < STRUCTURES.length) {
    return {
      value: null,
      error: { code: "BASE_STATE_INCOMPLETE", message: "Base state is incomplete.", status: 409 },
    };
  }
  return {
    value: {
      player,
      resources,
      structures: structuresResult.value,
      jobs: jobsResult.value,
      constructionSlots: constructionSlots.value,
    },
    error: null,
  };
}

async function loadConstructionSlots(
  config: EdgeConfig,
  playerId: string,
): Promise<{ value: number; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<{ id: string }[]>(
    config,
    `alpha_purchases?player_id=eq.${encodeURIComponent(playerId)}&product_id=eq.${
      encodeURIComponent(DOUBLE_CONSTRUCTION_QUEUE_PRODUCT_ID)
    }&select=id&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) {
    return { value: null, error: stateReadError() };
  }
  return { value: result.value.length > 0 ? 2 : DEFAULT_CONSTRUCTION_SLOTS, error: null };
}

async function ensureBaseRows(config: EdgeConfig, playerId: string): Promise<void> {
  for (const definition of STRUCTURES) {
    await restRequest<unknown>(config, "base_structures", {
      method: "POST",
      headers: { prefer: "resolution=ignore-duplicates,return=minimal" },
      body: JSON.stringify({ player_id: playerId, structure_id: definition.id }),
    });
  }
}

async function completeDueJobs(
  config: EdgeConfig,
  playerId: string,
  jobs: ConstructionJobRow[],
  now: Date,
): Promise<void> {
  for (const job of jobs) {
    if (job.status !== "active" || new Date(job.completes_at).getTime() > now.getTime()) {
      continue;
    }
    await restRequest<unknown>(
      config,
      `construction_jobs?id=eq.${encodeURIComponent(job.id)}`,
      {
        method: "PATCH",
        headers: { prefer: "return=minimal" },
        body: JSON.stringify({
          status: "completed",
          completed_at: now.toISOString(),
          updated_at: now.toISOString(),
        }),
      },
    );
    await restRequest<unknown>(
      config,
      `base_structures?player_id=eq.${encodeURIComponent(playerId)}&structure_id=eq.${
        encodeURIComponent(job.structure_id)
      }`,
      {
        method: "PATCH",
        headers: { prefer: "return=minimal" },
        body: JSON.stringify({ level: job.target_level, updated_at: now.toISOString() }),
      },
    );
  }
}

function baseStatePayload(state: {
  player: PlayerRow;
  resources: ResourceRow;
  structures: BaseStructureRow[];
  jobs: ConstructionJobRow[];
  constructionSlots: number;
}) {
  const now = new Date();
  const activeJobs = state.jobs.filter((job) => job.status === "active");
  return {
    ok: true,
    resources: state.resources,
    base: {
      server_time: now.toISOString(),
      construction_slots: state.constructionSlots,
      construction_slots_source: state.constructionSlots > DEFAULT_CONSTRUCTION_SLOTS
        ? DOUBLE_CONSTRUCTION_QUEUE_PRODUCT_ID
        : "default",
      structures: state.structures.map((structure) => {
        const definition = definitionFor(structure.structure_id);
        const pending = collectableFor(structure, now);
        const activeJob = activeJobs.find((job) => job.structure_id === structure.structure_id);
        const nextLevel = structure.level >= MAX_STRUCTURE_LEVEL ? null : structure.level + 1;
        const upgradeCostValue = nextLevel === null ? null : upgradeCost(nextLevel);
        const upgradeDurationValue = nextLevel === null ? null : upgradeDurationSeconds(nextLevel);
        const blockedReason = upgradeBlockReason(
          structure,
          state.player,
          state.resources,
          activeJob,
          activeJobs.length,
          state.constructionSlots,
        );
        return {
          ...structure,
          display_name: definition?.displayName ?? structure.structure_id,
          description: definition?.description ?? "",
          benefit_label: definition?.benefitLabel ?? "",
          max_level: MAX_STRUCTURE_LEVEL,
          produces: definition?.resource,
          daily_production: dailyProduction(structure),
          storage_cap: storageCap(structure),
          pending_collectable: pending,
          next_level: nextLevel,
          upgrade_cost: upgradeCostValue === null ? null : { energia: upgradeCostValue },
          upgrade_duration_seconds: upgradeDurationValue,
          can_upgrade: blockedReason === "",
          blocked_reason: blockedReason,
          blocked_message: upgradeBlockMessage(blockedReason),
          active_job: activeJob === undefined ? null : jobPayload(activeJob, now),
        };
      }),
      jobs: state.jobs.map((job) => jobPayload(job, now)),
    },
  };
}

function jobPayload(job: ConstructionJobRow, now: Date) {
  return {
    ...job,
    display_name: definitionFor(job.structure_id)?.displayName ?? job.structure_id,
    remaining_seconds: Math.max(
      0,
      Math.ceil((new Date(job.completes_at).getTime() - now.getTime()) / 1000),
    ),
  };
}

function upgradeBlockReason(
  structure: BaseStructureRow,
  player: PlayerRow,
  resources: ResourceRow,
  activeJob: ConstructionJobRow | undefined,
  activeJobCount: number,
  constructionSlots: number,
): string {
  if (structure.level >= MAX_STRUCTURE_LEVEL) {
    return "MAX_LEVEL_REACHED";
  }
  if (activeJob !== undefined) {
    return "STRUCTURE_ALREADY_UPGRADING";
  }
  if (activeJobCount >= constructionSlots) {
    return "CONSTRUCTION_QUEUE_FULL";
  }
  const targetLevel = structure.level + 1;
  const cap = Math.min(MAX_STRUCTURE_LEVEL, Math.max(1, player.level));
  if (targetLevel > cap) {
    return "LEVEL_CAP_REACHED";
  }
  if (numberValue(resources.energia, 0) < upgradeCost(targetLevel)) {
    return "INSUFFICIENT_RESOURCES";
  }
  return "";
}

function upgradeBlockMessage(reason: string): string {
  switch (reason) {
    case "":
      return "Upgrade disponivel.";
    case "MAX_LEVEL_REACHED":
      return "Predio ja esta no nivel maximo.";
    case "STRUCTURE_ALREADY_UPGRADING":
      return "Este predio ja esta em upgrade.";
    case "CONSTRUCTION_QUEUE_FULL":
      return "Fila de construcao cheia.";
    case "LEVEL_CAP_REACHED":
      return "Nivel do predio limitado pelo level do jogador.";
    case "INSUFFICIENT_RESOURCES":
      return "Energia insuficiente para iniciar este upgrade.";
    default:
      return "Upgrade bloqueado.";
  }
}

function calculateCollectable(
  structures: BaseStructureRow[],
  now: Date,
): Record<ResourceKey, number> {
  const collected: Record<ResourceKey, number> = {
    almas: 0,
    energia: 0,
    sangue: 0,
    cristais: 0,
    ossos: 0,
  };
  for (const structure of structures) {
    const definition = definitionFor(structure.structure_id);
    if (definition === undefined || definition.resource === null) {
      continue;
    }
    collected[definition.resource] += collectableFor(structure, now);
  }
  return Object.fromEntries(
    Object.entries(collected).map(([key, value]) => [key, round2(value)]),
  ) as Record<ResourceKey, number>;
}

function collectableFor(structure: BaseStructureRow, now: Date): number {
  const definition = definitionFor(structure.structure_id);
  if (definition === undefined || definition.resource === null || structure.level <= 0) {
    return 0;
  }
  const elapsedSeconds = Math.max(
    0,
    (now.getTime() - new Date(structure.last_collected_at).getTime()) / 1000,
  );
  const produced = dailyProduction(structure) * (elapsedSeconds / SECONDS_PER_DAY);
  return round2(Math.min(storageCap(structure), produced));
}

function dailyProduction(structure: BaseStructureRow): number {
  const definition = definitionFor(structure.structure_id);
  if (definition === undefined || definition.resource === null || structure.level <= 0) {
    return 0;
  }
  return Math.max(1, Math.round(definition.dailyAtLevel40 * structure.level / 40));
}

function storageCap(structure: BaseStructureRow): number {
  const daily = dailyProduction(structure);
  return daily <= 0 ? 0 : Math.max(8, Math.ceil(daily * 2));
}

function upgradeCost(targetLevel: number): number {
  return Math.max(20, Math.round(0.5 * targetLevel * targetLevel));
}

function upgradeDurationSeconds(targetLevel: number): number {
  return Math.max(120, Math.round(0.1 * targetLevel * targetLevel * 3600));
}

function definitionFor(structureId: string): StructureDefinition | undefined {
  return STRUCTURES.find((definition) => definition.id === structureId);
}

async function loadIdempotency(
  config: EdgeConfig,
  playerId: string,
  endpoint: string,
  requestId: string,
): Promise<{ value: unknown | null; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<IdempotencyRow[]>(
    config,
    `idempotency_keys?player_id=eq.${encodeURIComponent(playerId)}&endpoint=eq.${
      encodeURIComponent(endpoint)
    }&request_id=eq.${encodeURIComponent(requestId)}&select=response_payload&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) {
    return { value: null, error: stateReadError() };
  }
  return { value: result.value[0]?.response_payload ?? null, error: null };
}

async function insertLedger(
  config: EdgeConfig,
  playerId: string,
  source: string,
  requestId: string,
  delta: Record<string, number>,
): Promise<RestError | null> {
  const result = await restRequest<unknown>(config, "resource_transactions", {
    method: "POST",
    headers: { prefer: "return=minimal" },
    body: JSON.stringify({ player_id: playerId, source, request_id: requestId, delta }),
  });
  return result.error === null
    ? null
    : { code: "LEDGER_WRITE_FAILED", message: "Unable to record resource ledger.", status: 500 };
}

async function insertIdempotency(
  config: EdgeConfig,
  playerId: string,
  endpoint: string,
  requestId: string,
  responsePayload: unknown,
): Promise<RestError | null> {
  const result = await restRequest<unknown>(config, "idempotency_keys", {
    method: "POST",
    headers: { prefer: "return=minimal" },
    body: JSON.stringify({
      player_id: playerId,
      endpoint,
      request_id: requestId,
      response_payload: responsePayload,
    }),
  });
  return result.error === null ? null : {
    code: "IDEMPOTENCY_WRITE_FAILED",
    message: "Unable to persist base idempotency.",
    status: 500,
  };
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/state")) return "state";
  if (pathname.endsWith("/collect")) return "collect";
  if (pathname.endsWith("/upgrade")) return "upgrade";
  return null;
}

function decodeAuthContext(request: Request): { value: AuthContext; error: null } | {
  value: null;
  error: RestError;
} {
  const header = request.headers.get("authorization") ?? "";
  const prefix = "Bearer ";
  if (!header.startsWith(prefix)) {
    return {
      value: null,
      error: { code: "UNAUTHENTICATED", message: "Bearer token is required.", status: 401 },
    };
  }
  const token = header.slice(prefix.length);
  const parts = token.split(".");
  if (parts.length < 2) {
    return {
      value: null,
      error: { code: "UNAUTHENTICATED", message: "Invalid bearer token.", status: 401 },
    };
  }
  const payload = decodeJwtPayload(parts[1]);
  if (payload === null || typeof payload.sub !== "string" || !UUID_PATTERN.test(payload.sub)) {
    return {
      value: null,
      error: { code: "UNAUTHENTICATED", message: "Token subject is invalid.", status: 401 },
    };
  }
  if (payload.is_anonymous === false) {
    return {
      value: null,
      error: {
        code: "AUTH_NOT_ANONYMOUS",
        message: "Use an anonymous Supabase Auth session.",
        status: 403,
      },
    };
  }
  const saveType = saveTypeFromRequest(request);
  if (saveType === null) {
    return {
      value: null,
      error: {
        code: "INVALID_SAVE_TYPE",
        message: "Save type must be normal or progression_lab.",
        status: 400,
      },
    };
  }
  return { value: { userId: payload.sub, saveType }, error: null };
}

function decodeJwtPayload(encodedPayload: string): JwtPayload | null {
  try {
    const normalized = encodedPayload.replaceAll("-", "+").replaceAll("_", "/");
    const padded = normalized + "=".repeat((4 - normalized.length % 4) % 4);
    const bytes = Uint8Array.from(atob(padded), (character) => character.charCodeAt(0));
    const payload: unknown = JSON.parse(new TextDecoder().decode(bytes));
    return isObject(payload) ? payload as JwtPayload : null;
  } catch {
    return null;
  }
}

function loadConfig(): { value: EdgeConfig; error: null } | { value: null; error: RestError } {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (supabaseUrl === "" || serviceRoleKey === "") {
    return {
      value: null,
      error: {
        code: "SERVER_MISCONFIGURED",
        message: "Base function is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }
  return { value: { supabaseUrl: supabaseUrl.replace(/\/$/, ""), serviceRoleKey }, error: null };
}

async function readJsonObject(request: Request): Promise<Record<string, unknown> | null> {
  try {
    const payload: unknown = await request.json();
    return isObject(payload) ? payload : null;
  } catch {
    return null;
  }
}

async function restRequest<T>(
  config: EdgeConfig,
  path: string,
  init: RequestInit,
): Promise<{ value: T; error: null } | { value: null; error: RestError }> {
  const headers = new Headers(init.headers);
  headers.set("accept", "application/json");
  headers.set("apikey", config.serviceRoleKey);
  headers.set("authorization", `Bearer ${config.serviceRoleKey}`);
  if (init.body !== undefined) {
    headers.set("content-type", "application/json");
  }
  const response = await fetch(`${config.supabaseUrl}/rest/v1/${path}`, { ...init, headers });
  const text = await response.text();
  const data = text === "" ? null : parseJson(text);
  if (!response.ok) {
    const body = isObject(data) ? data : {};
    return {
      value: null,
      error: {
        code: stringValue(body.code, "REST_ERROR"),
        message: stringValue(body.message, response.statusText),
        status: response.status,
      },
    };
  }
  return { value: data as T, error: null };
}

function stateReadError(): RestError {
  return { code: "STATE_READ_FAILED", message: "Unable to load base state.", status: 500 };
}

function errorResponse(code: string, message: string, status: number): Response {
  return jsonResponse({ ok: false, error: { code, message } }, status);
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function stringField(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value.trim() : "";
}

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value !== "" ? value : fallback;
}

function numberValue(value: unknown, fallback: number): number {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string" && value.trim() !== "") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
  }
  return fallback;
}

function round2(value: number): number {
  return Math.round(value * 100) / 100;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
