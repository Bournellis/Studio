const PROJECT_PREFIX = "Projetos/draxos-mobile";

const MIRRORED_FUNCTIONS = [
  "arena",
  "base",
  "build",
  "competition",
  "crafting",
  "monetization",
  "social",
];

Deno.test("latency backend pass keeps touched edge function mirrors aligned", async () => {
  for (const functionName of MIRRORED_FUNCTIONS) {
    const serverSource = await readProjectText(`server/functions/${functionName}/index.ts`);
    const supabaseSource = await readProjectText(`supabase/functions/${functionName}/index.ts`);
    assertEq(
      normalizeNewlines(serverSource),
      normalizeNewlines(supabaseSource),
      `${functionName} server/supabase function mirrors should match`,
    );
  }

  const serverModeSupport = await readProjectText("server/functions/modes/mode_support.ts");
  const supabaseModeSupport = await readProjectText("supabase/functions/modes/mode_support.ts");
  assertEq(
    normalizeNewlines(serverModeSupport),
    normalizeNewlines(supabaseModeSupport),
    "modes support server/supabase mirrors should match",
  );
});

Deno.test("state loaders batch independent reads for backend responsiveness", async () => {
  const modeSupport = await readProjectText("server/functions/modes/mode_support.ts");
  assertIncludes(
    modeSupport,
    "const [registry, rulesets] = await Promise.all",
    "mode state should batch registry and ruleset reads",
  );
  assertIncludes(
    modeSupport,
    "const [progress, sessions, claims, resources] = await Promise.all",
    "mode state should batch save-scoped state reads",
  );

  const base = await readProjectText("server/functions/base/index.ts");
  assertIncludes(
    base,
    "const gameSavePromise = loadGameSave",
    "base state should start game save lookup before independent reads",
  );
  assertIncludes(
    base,
    "await Promise.all(BASE_STRUCTURES.map",
    "base row bootstrap should not insert structures sequentially",
  );

  const build = await readProjectText("server/functions/build/index.ts");
  assertIncludes(
    build,
    "const [gameSave, buildResult, inventoryResult, slotsResult, behaviorsResult] =",
    "build state should batch loadout, inventory, slot and behavior reads",
  );

  const crafting = await readProjectText("server/functions/crafting/index.ts");
  assertIncludes(
    crafting,
    "const [gameSave, resourcesResult, inventoryResult, slotsResult] = await Promise.all",
    "crafting state should batch resources, inventory and slot reads",
  );

  const monetization = await readProjectText("server/functions/monetization/index.ts");
  assertIncludes(
    monetization,
    "const [gameSave, resources, progress, claims, purchases] = await Promise.all",
    "monetization state should batch independent save and economy reads",
  );

  const competition = await readProjectText("server/functions/competition/index.ts");
  assertIncludes(
    competition,
    "const [player, botResult] = await Promise.all",
    "matchmaking preview should batch player and bot pool reads",
  );
  assertIncludes(
    competition,
    "const [player, season] = await Promise.all",
    "ranking state should batch player and active season reads",
  );

  const arena = await readProjectText("server/functions/arena/index.ts");
  const arenaStateSection = codeSection(
    arena,
    "async function handleList",
    "async function handleStart",
  );
  assertIncludes(
    arena,
    "const [bot, progress] = await Promise.all",
    "arena duel request should batch bot and progress reads after active attempt resolution",
  );
  assertIncludes(
    arenaStateSection,
    "select=id,game_save_id,player_id,arena_id,difficulty_id,difficulty_rank,max_steps,current_step_index,status,seed,enemy_sequence,active_buffs,reward_payload,started_at,completed_at,abandoned_at,updated_at",
    "arena pve state should keep using the lightweight attempt projection",
  );
  assertNotIncludes(
    arenaStateSection,
    "loadout_snapshot",
    "arena pve state projection should not include full loadout snapshots",
  );
});

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

function normalizeNewlines(value: string): string {
  return value.replaceAll("\r\n", "\n");
}

function assertIncludes(haystack: string, needle: string, message: string): void {
  if (!haystack.includes(needle)) {
    throw new Error(`${message}. Missing: ${needle}`);
  }
}

function assertNotIncludes(haystack: string, needle: string, message: string): void {
  if (haystack.includes(needle)) {
    throw new Error(`${message}. Unexpected: ${needle}`);
  }
}

function codeSection(haystack: string, start: string, end: string): string {
  const startIndex = haystack.indexOf(start);
  const endIndex = haystack.indexOf(end);
  if (startIndex < 0 || endIndex <= startIndex) {
    throw new Error(`missing code section ${start} -> ${end}`);
  }
  return haystack.slice(startIndex, endIndex);
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(message);
  }
}
