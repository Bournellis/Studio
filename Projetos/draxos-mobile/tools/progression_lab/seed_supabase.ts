type ResourceKey =
  | "almas"
  | "energia"
  | "sangue"
  | "cristais"
  | "ossos"
  | "diamante";

interface HealthySavesDocument {
  schema_version: number;
  model_id: string;
  saves: HealthySave[];
}

interface HealthySave {
  id: string;
  profile_id: string;
  milestone_id: string;
  hours: number;
  player: {
    username: string;
    level: number;
    xp: number;
    power: number;
  };
  resources: Record<ResourceKey, number>;
  build: {
    weapon_type: string;
    weapon_quality: string;
    weapon_level: number;
    spell_slots: string[];
    spells_unlocked: string[];
    passive_id: string;
    passive_level: number;
    pet_id: string;
    pet_level: number;
  };
  base: {
    construction_slots: number;
    structures: Array<{
      structure_id: string;
      level: number;
      produces: string;
    }>;
    active_job: {
      structure_id: string;
      target_level: number;
      remaining_minutes: number;
    } | null;
  };
  monetization: {
    premium_pass: boolean;
    battle_pass_xp: number;
    premium_unlocked: boolean;
    simulated_store_spend: number;
  };
  manual_checklist: string[];
}

interface SeedOptions {
  all: boolean;
  dryRun: boolean;
  verifyState: boolean;
  profileId: string;
  milestoneId: string;
  supabaseUrl: string;
  publishableKey: string;
  serviceRoleKey: string;
}

interface AuthSession {
  access_token: string;
  refresh_token: string;
  expires_at: number;
  user: {
    id: string;
    is_anonymous?: boolean;
  };
}

interface RestConfig {
  supabaseUrl: string;
  publishableKey: string;
  serviceRoleKey: string;
}

interface SeededSave {
  save_id: string;
  profile_id: string;
  milestone_id: string;
  player_id: string;
  auth_user_id: string;
  username: string;
  session_cache_path: string;
  account_state_ok?: boolean;
}

const DEFAULT_SUPABASE_URL = "http://127.0.0.1:54321";
const DEFAULT_PUBLISHABLE_KEY =
  "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH";
const HEALTHY_SAVES_PATH = "docs/progression-lab/generated/healthy_saves.json";
const SCRATCH_DIR = ".progression_lab_scratch";
const BATTLE_PASS_ID = "bp_s1_01";
const SEASON_ID = "season_001";

async function main(): Promise<void> {
  const options = parseOptions(Deno.args);
  if (Deno.args.includes("--help") || Deno.args.includes("-h")) {
    console.log(helpText());
    return;
  }

  const projectRoot = new URL("../../", import.meta.url);
  const document = await loadHealthySaves(projectRoot);
  const saves = selectSaves(document, options);
  if (saves.length === 0) {
    throw new Error(
      "No healthy saves matched the requested profile/milestone.",
    );
  }

  if (options.dryRun) {
    console.log(JSON.stringify(
      {
        ok: true,
        dry_run: true,
        selected: saves.map((save) => save.id),
        total: saves.length,
      },
      null,
      2,
    ));
    return;
  }

  const config = resolveConfig(options);
  assertLocalSupabase(config.supabaseUrl);
  await Deno.mkdir(new URL(`${SCRATCH_DIR}/`, projectRoot), {
    recursive: true,
  });

  const seeded: SeededSave[] = [];
  for (const save of saves) {
    seeded.push(await seedSave(projectRoot, config, save, options));
  }

  console.log(JSON.stringify(
    {
      ok: true,
      seeded: seeded.length,
      saves: seeded,
    },
    null,
    2,
  ));
}

async function loadHealthySaves(
  projectRoot: URL,
): Promise<HealthySavesDocument> {
  const raw = await Deno.readTextFile(new URL(HEALTHY_SAVES_PATH, projectRoot));
  return JSON.parse(raw) as HealthySavesDocument;
}

function selectSaves(
  document: HealthySavesDocument,
  options: SeedOptions,
): HealthySave[] {
  if (options.all) return document.saves;
  return document.saves.filter((save) =>
    save.profile_id === options.profileId &&
    save.milestone_id === options.milestoneId
  );
}

async function seedSave(
  projectRoot: URL,
  config: RestConfig,
  save: HealthySave,
  options: SeedOptions,
): Promise<SeededSave> {
  const auth = await createAnonymousSession(config, save);
  const suffix = auth.user.id.replaceAll("-", "").slice(0, 8);
  const username = `${save.player.username}_${suffix}`;
  const player = await upsertPlayer(config, save, auth.user.id, username);
  await upsertResources(config, player.id, save);
  await upsertBuild(config, player.id, save);
  await upsertBase(config, player.id, save);
  await upsertBattlePass(config, player.id, save);
  await insertRewardClaim(config, player.id, save);
  await upsertRanking(config, player.id, save);

  const sessionCache = buildSessionCache(save, auth, player.id, username);
  const sessionCacheUrl = new URL(
    `${SCRATCH_DIR}/session_${save.id}.json`,
    projectRoot,
  );
  await Deno.writeTextFile(
    sessionCacheUrl,
    JSON.stringify(sessionCache, null, 2) + "\n",
  );
  await Deno.writeTextFile(
    new URL(`${SCRATCH_DIR}/session_latest.json`, projectRoot),
    JSON.stringify(sessionCache, null, 2) + "\n",
  );

  const result: SeededSave = {
    save_id: save.id,
    profile_id: save.profile_id,
    milestone_id: save.milestone_id,
    player_id: player.id,
    auth_user_id: auth.user.id,
    username,
    session_cache_path: pathFromUrl(sessionCacheUrl),
  };

  if (options.verifyState) {
    result.account_state_ok = await verifyAccountState(
      config,
      auth.access_token,
    );
  }

  return result;
}

async function createAnonymousSession(
  config: RestConfig,
  save: HealthySave,
): Promise<AuthSession> {
  const response = await fetch(`${config.supabaseUrl}/auth/v1/signup`, {
    method: "POST",
    headers: {
      "accept": "application/json",
      "apikey": config.publishableKey,
      "content-type": "application/json",
    },
    body: JSON.stringify({
      data: {
        provider: "progression_lab",
        save_id: save.id,
      },
    }),
  });
  const body = await readJson(response);
  if (!response.ok) {
    throw new Error(
      `Auth signup failed (${response.status}): ${JSON.stringify(body)}`,
    );
  }
  const session = body as Partial<AuthSession>;
  if (
    typeof session.access_token !== "string" ||
    typeof session.refresh_token !== "string" ||
    typeof session.expires_at !== "number" ||
    session.user === undefined ||
    typeof session.user.id !== "string"
  ) {
    throw new Error("Auth signup did not return a usable anonymous session.");
  }
  return session as AuthSession;
}

async function upsertPlayer(
  config: RestConfig,
  save: HealthySave,
  authUserId: string,
  username: string,
): Promise<{ id: string }> {
  const rows = await restRequest<Array<{ id: string }>>(
    config,
    "players?on_conflict=auth_user_id",
    {
      method: "POST",
      body: [{
        auth_user_id: authUserId,
        username,
        account_type: "guest",
        level: save.player.level,
        xp: save.player.xp,
        power: save.player.power,
        updated_at: nowIso(),
      }],
    },
    "resolution=merge-duplicates,return=representation",
  );
  const row = rows[0];
  if (row === undefined || typeof row.id !== "string") {
    throw new Error("Player upsert did not return an id.");
  }
  return row;
}

async function upsertResources(
  config: RestConfig,
  playerId: string,
  save: HealthySave,
): Promise<void> {
  await restRequest(config, "resources?on_conflict=player_id", {
    method: "POST",
    body: [{
      player_id: playerId,
      ...save.resources,
      diamante: Math.round(save.resources.diamante),
      updated_at: nowIso(),
    }],
  });
}

async function upsertBuild(
  config: RestConfig,
  playerId: string,
  save: HealthySave,
): Promise<void> {
  await restRequest(config, "builds?on_conflict=player_id", {
    method: "POST",
    body: [{
      player_id: playerId,
      weapon_type: save.build.weapon_type,
      weapon_quality: save.build.weapon_quality,
      weapon_level: save.build.weapon_level,
      spell_slots: save.build.spell_slots,
      spells_unlocked: save.build.spells_unlocked,
      pet_id: nullableText(save.build.pet_id),
      pet_level: save.build.pet_level,
      passive_id: nullableText(save.build.passive_id),
      passive_level: save.build.passive_level,
      updated_at: nowIso(),
    }],
  });
}

async function upsertBase(
  config: RestConfig,
  playerId: string,
  save: HealthySave,
): Promise<void> {
  const rows = save.base.structures.map((structure) => ({
    player_id: playerId,
    structure_id: structure.structure_id,
    level: structure.level,
    last_collected_at: nowIso(),
    updated_at: nowIso(),
  }));
  await restRequest(
    config,
    "base_structures?on_conflict=player_id,structure_id",
    {
      method: "POST",
      body: rows,
    },
  );

  if (save.base.active_job === null) return;
  const job = save.base.active_job;
  await restRequest(config, "construction_jobs", {
    method: "POST",
    body: [{
      id: crypto.randomUUID(),
      player_id: playerId,
      structure_id: job.structure_id,
      target_level: job.target_level,
      status: "active",
      cost_payload: {
        progression_lab: true,
        source_save_id: save.id,
        target_level: job.target_level,
      },
      started_at: nowIso(),
      completes_at: minutesFromNow(job.remaining_minutes),
      request_id: crypto.randomUUID(),
      updated_at: nowIso(),
    }],
  });
}

async function upsertBattlePass(
  config: RestConfig,
  playerId: string,
  save: HealthySave,
): Promise<void> {
  await restRequest(
    config,
    "battle_pass_progress?on_conflict=player_id,pass_id",
    {
      method: "POST",
      body: [{
        player_id: playerId,
        pass_id: BATTLE_PASS_ID,
        pass_xp: save.monetization.battle_pass_xp,
        premium_unlocked: save.monetization.premium_unlocked,
        updated_at: nowIso(),
      }],
    },
  );
}

async function insertRewardClaim(
  config: RestConfig,
  playerId: string,
  save: HealthySave,
): Promise<void> {
  await restRequest(config, "reward_claims", {
    method: "POST",
    body: [{
      id: crypto.randomUUID(),
      player_id: playerId,
      source: "daily",
      reward_id: "progression_lab_checkpoint",
      period_key: save.id,
      request_id: crypto.randomUUID(),
      reward_payload: {
        progression_lab: true,
        profile_id: save.profile_id,
        milestone_id: save.milestone_id,
        resources: save.resources,
      },
    }],
  });
}

async function upsertRanking(
  config: RestConfig,
  playerId: string,
  save: HealthySave,
): Promise<void> {
  await restRequest(config, "ranking?on_conflict=season_id,player_id", {
    method: "POST",
    body: [{
      season_id: SEASON_ID,
      player_id: playerId,
      arena_points: Math.max(0, Math.round(save.player.power / 20)),
      wins: 0,
      losses: 0,
      updated_at: nowIso(),
    }],
  });
}

async function verifyAccountState(
  config: RestConfig,
  accessToken: string,
): Promise<boolean> {
  const response = await fetch(
    `${config.supabaseUrl}/functions/v1/account/state`,
    {
      method: "GET",
      headers: {
        "accept": "application/json",
        "apikey": config.publishableKey,
        "authorization": `Bearer ${accessToken}`,
      },
    },
  );
  const body = await readJson(response);
  if (!response.ok || !(body as { ok?: boolean }).ok) {
    throw new Error(
      `account/state verification failed (${response.status}): ${
        JSON.stringify(body)
      }`,
    );
  }
  return true;
}

function buildSessionCache(
  save: HealthySave,
  auth: AuthSession,
  playerId: string,
  username: string,
): Record<string, unknown> {
  return {
    cache_version: 1,
    auth: {
      access_token: auth.access_token,
      refresh_token: auth.refresh_token,
      expires_at: auth.expires_at,
      user_id: auth.user.id,
    },
    session_id: crypto.randomUUID(),
    guest_request_id: crypto.randomUUID(),
    player: {
      id: playerId,
      username,
      account_type: "guest",
      level: save.player.level,
      xp: save.player.xp,
      power: save.player.power,
      created_at: nowIso(),
      updated_at: nowIso(),
    },
    resources: {
      player_id: playerId,
      ...save.resources,
      diamante: Math.round(save.resources.diamante),
      updated_at: nowIso(),
    },
    build: {
      player_id: playerId,
      weapon_type: save.build.weapon_type,
      weapon_quality: save.build.weapon_quality,
      weapon_level: save.build.weapon_level,
      spell_slots: save.build.spell_slots,
      spells_unlocked: save.build.spells_unlocked,
      pet_id: nullableText(save.build.pet_id),
      pet_level: save.build.pet_level,
      passive_id: nullableText(save.build.passive_id),
      passive_level: save.build.passive_level,
      updated_at: nowIso(),
    },
    base_state: {
      construction_slots: save.base.construction_slots,
      structures: save.base.structures.map((structure) => ({
        structure_id: structure.structure_id,
        display_name: structureLabel(structure.structure_id),
        level: structure.level,
        pending_collectable: 0,
        storage_cap: Math.max(100, structure.level * 100),
        last_collected_at: nowIso(),
      })),
      jobs: save.base.active_job === null ? [] : [{
        structure_id: save.base.active_job.structure_id,
        target_level: save.base.active_job.target_level,
        status: "active",
        completes_at: minutesFromNow(save.base.active_job.remaining_minutes),
      }],
    },
    social_state: {},
    competition_state: {
      ranking: {
        season: {
          id: SEASON_ID,
          display_name: "Season 1 Alpha",
        },
        self: {
          arena_points: Math.max(0, Math.round(save.player.power / 20)),
          wins: 0,
          losses: 0,
        },
        bots_included: false,
      },
    },
    monetization_state: {
      battle_pass: {
        pass: {
          id: BATTLE_PASS_ID,
          display_name: "Battle Pass Alpha 01",
        },
        progress: {
          player_id: playerId,
          pass_id: BATTLE_PASS_ID,
          pass_xp: save.monetization.battle_pass_xp,
          premium_unlocked: save.monetization.premium_unlocked,
        },
      },
      daily_rewards: [],
      alpha_products: [],
    },
    last_battle_id: null,
    last_battle_log: {},
    last_battle_rewards: {},
    offline: false,
    last_error: {},
    progression_lab: {
      save_id: save.id,
      profile_id: save.profile_id,
      milestone_id: save.milestone_id,
      manual_checklist: save.manual_checklist,
    },
  };
}

async function restRequest<T = unknown>(
  config: RestConfig,
  path: string,
  init: { method: string; body?: unknown },
  prefer = "resolution=merge-duplicates",
): Promise<T> {
  const headers: Record<string, string> = {
    "accept": "application/json",
    "apikey": config.serviceRoleKey,
    "authorization": `Bearer ${config.serviceRoleKey}`,
    "prefer": prefer,
  };
  let body: string | undefined;
  if (init.body !== undefined) {
    headers["content-type"] = "application/json";
    body = JSON.stringify(init.body);
  }

  const response = await fetch(`${config.supabaseUrl}/rest/v1/${path}`, {
    method: init.method,
    headers,
    body,
  });
  const responseBody = await readJson(response);
  if (!response.ok) {
    throw new Error(
      `REST ${path} failed (${response.status}): ${
        JSON.stringify(responseBody)
      }`,
    );
  }
  return responseBody as T;
}

async function readJson(response: Response): Promise<unknown> {
  const text = await response.text();
  if (text.trim() === "") return {};
  try {
    return JSON.parse(text);
  } catch {
    return { raw: text };
  }
}

function parseOptions(args: string[]): SeedOptions {
  const options: SeedOptions = {
    all: false,
    dryRun: false,
    verifyState: false,
    profileId: "",
    milestoneId: "",
    supabaseUrl: DEFAULT_SUPABASE_URL,
    publishableKey: DEFAULT_PUBLISHABLE_KEY,
    serviceRoleKey: "",
  };

  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];
    if (arg === "--all") options.all = true;
    else if (arg === "--dry-run") options.dryRun = true;
    else if (arg === "--verify-state") options.verifyState = true;
    else if (arg === "--profile") options.profileId = args[++index] ?? "";
    else if (arg === "--milestone") options.milestoneId = args[++index] ?? "";
    else if (arg === "--supabase-url") {
      options.supabaseUrl = args[++index] ?? "";
    } else if (arg === "--publishable-key") {
      options.publishableKey = args[++index] ?? "";
    } else if (arg === "--help" || arg === "-h") continue;
    else throw new Error(`Unknown option: ${arg}`);
  }

  if (
    !options.all && (options.profileId === "" || options.milestoneId === "")
  ) {
    throw new Error("Use --all or provide both --profile and --milestone.");
  }

  return options;
}

function resolveConfig(options: SeedOptions): RestConfig {
  const supabaseUrl = optionOrEnv(
    options.supabaseUrl,
    "SUPABASE_URL",
    DEFAULT_SUPABASE_URL,
  );
  const publishableKey = optionOrEnv(
    options.publishableKey,
    "SUPABASE_ANON_KEY",
    DEFAULT_PUBLISHABLE_KEY,
  );
  const serviceRoleKey = optionOrEnv(
    options.serviceRoleKey,
    "SUPABASE_SERVICE_ROLE_KEY",
    "",
  );
  if (serviceRoleKey === "") {
    throw new Error(
      "SUPABASE_SERVICE_ROLE_KEY is required to seed server-authoritative tables.",
    );
  }
  return {
    supabaseUrl: supabaseUrl.replace(/\/$/, ""),
    publishableKey,
    serviceRoleKey,
  };
}

function optionOrEnv(value: string, envName: string, fallback: string): string {
  if (value !== "") return value;
  return Deno.env.get(envName) ?? fallback;
}

function assertLocalSupabase(supabaseUrl: string): void {
  const url = new URL(supabaseUrl);
  if (!["127.0.0.1", "localhost", "::1"].includes(url.hostname)) {
    throw new Error(`Refusing to seed non-local Supabase URL: ${supabaseUrl}`);
  }
}

function nullableText(value: string): string | null {
  return value.trim() === "" ? null : value;
}

function structureLabel(structureId: string): string {
  const labels: Record<string, string> = {
    altar_das_almas: "Altar das Almas",
    nucleo_energia: "Nucleo de Energia",
    pocos_sangue: "Pocos de Sangue",
    minas_cristal: "Minas de Cristal",
    estrutura_stats: "Estrutura de Stats",
    ossario: "Ossario",
  };
  return labels[structureId] ?? structureId;
}

function nowIso(): string {
  return new Date().toISOString();
}

function minutesFromNow(minutes: number): string {
  return new Date(Date.now() + Math.max(0, minutes) * 60_000).toISOString();
}

function pathFromUrl(url: URL): string {
  return decodeURIComponent(url.pathname).replace(/^\//, "").replaceAll(
    "/",
    "\\",
  );
}

function helpText(): string {
  return [
    "Usage:",
    "  npx -y deno run --allow-net --allow-env --allow-read --allow-write tools/progression_lab/seed_supabase.ts --profile free_100_rewards --milestone 10h",
    "  npx -y deno run --allow-net --allow-env --allow-read --allow-write tools/progression_lab/seed_supabase.ts --all",
    "",
    "Options:",
    "  --profile <id>       Profile id from healthy_saves.json.",
    "  --milestone <id>     Milestone id: 2h, 5h, 10h, 15h or 20h.",
    "  --all                Seed every profile/milestone combination.",
    "  --dry-run            Print selected saves without network or writes.",
    "  --verify-state       Also call functions/v1/account/state after seeding.",
    "",
    "Safety:",
    "  The script refuses non-local Supabase URLs and requires SUPABASE_SERVICE_ROLE_KEY.",
  ].join("\n");
}

if (import.meta.main) {
  await main();
}
