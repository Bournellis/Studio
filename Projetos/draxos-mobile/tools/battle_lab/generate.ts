import {
  type BattleEvent,
  type BattleSimulationResult,
  type CombatantBuild,
  simulateFirstSliceBattle,
} from "../../server/functions/_shared/battle_simulator.ts";

type Status = "PASS" | "REVIEW" | "CRITICAL";
type BuildKind = "fixed" | "random";
type BattleSide = "player" | "opponent";

interface BattleLabModel {
  schema_version: number;
  model_id: string;
  status: string;
  notes: string[];
  output_dir: string;
  seed: string;
  levels: number[];
  random_builds_per_archetype_per_level: number;
  thresholds: Thresholds;
  power_bands: PowerBand[];
  archetypes: ArchetypeModel[];
}

interface Thresholds {
  target_duration_min: number;
  target_duration_max: number;
  short_duration: number;
  long_duration: number;
  short_battle_rate_review_percent: number;
  long_battle_rate_review_percent: number;
  anti_stall_review_percent: number;
  healthy_win_rate_min_percent: number;
  healthy_win_rate_max_percent: number;
  dominance_review_percent: number;
  dominance_critical_percent: number;
  stomp_winner_hp_percent: number;
}

interface BattleLabOptions {
  archiveRunId?: string;
  compareWithRunId?: string;
  scratchRunId?: string;
  requestPath?: string;
  responsePath?: string;
}

interface PowerBand {
  id: string;
  display_name: string;
  min_power: number;
  max_power: number;
}

interface ArchetypeModel {
  id: string;
  display_name: string;
  role: string;
  spell_preferences: string[];
  passive_preferences: string[];
  pet_preferences: string[];
  weapon_level_ratio: number;
  spell_level_ratio: number;
  passive_level_ratio: number;
  pet_level_ratio: number;
  quality_bias: number;
}

interface LabBuild {
  id: string;
  kind: BuildKind;
  archetype_id: string;
  archetype_name: string;
  level: number;
  power: number;
  power_band: string;
  seed: string;
  build: CombatantBuild;
}

interface LabMatchup {
  id: string;
  seed: string;
  level: number;
  player_build_id: string;
  opponent_build_id: string;
  player_archetype_id: string;
  opponent_archetype_id: string;
  player_power: number;
  opponent_power: number;
  player_power_band: string;
  opponent_power_band: string;
  duration: number;
  winner: BattleSide;
  winner_archetype_id: string;
  reason: string;
  event_count: number;
  anti_stall: boolean;
  damage_by_source: NumericMap;
  damage_by_type: NumericMap;
  player_damage_by_source: NumericMap;
  opponent_damage_by_source: NumericMap;
  player_damage_by_type: NumericMap;
  opponent_damage_by_type: NumericMap;
  barrier_absorbed: number;
  healing: number;
  summons_created: number;
  spell_casts: NumericMap;
  player_final_hp_percent: number;
  opponent_final_hp_percent: number;
  alerts: string[];
  severity: Status;
}

interface AggregateRow {
  id: string;
  display_name: string;
  total: number;
  wins: number;
  losses: number;
  win_rate_percent: number;
  avg_duration: number;
  median_duration: number;
  short_rate_percent: number;
  long_rate_percent: number;
  anti_stall_rate_percent: number;
  status: Status;
}

interface SourceByArchetypeRow {
  archetype_id: string;
  display_name: string;
  total: number;
  wins: number;
  avg_duration: number;
  weapon_damage: number;
  spell_damage: number;
  dot_damage: number;
  pet_damage: number;
  summon_damage: number;
  system_damage: number;
  total_damage: number;
  dominant_source: string;
}

type SourceDamageColumn =
  | "weapon_damage"
  | "spell_damage"
  | "dot_damage"
  | "pet_damage"
  | "summon_damage"
  | "system_damage";

interface MatrixRow {
  player_archetype_id: string;
  opponent_archetype_id: string;
  total: number;
  wins: number;
  win_rate_percent: number;
  avg_duration: number;
  status: Status;
}

interface PowerBandRow {
  id: string;
  level: number;
  power_band: string;
  total: number;
  wins: number;
  win_rate_percent: number;
  avg_duration: number;
  median_duration: number;
  short_rate_percent: number;
  long_rate_percent: number;
  anti_stall_rate_percent: number;
  status: Status;
}

interface OutlierRow {
  type: string;
  severity: Status;
  matchup_id: string;
  seed: string;
  player_build_id: string;
  opponent_build_id: string;
  level: string;
  power: string;
  duration: string;
  winner: string;
  reason: string;
}

interface CheckRow {
  id: string;
  status: Status;
  observed: string;
  target: string;
  note: string;
}

interface CompareRow {
  metric: string;
  baseline: string;
  current: string;
  delta: string;
}

interface RunManifest {
  run_id: string;
  archived_at: string;
  base_sha: string;
  model_id: string;
  seed: string;
  hypothesis: string;
  overall_status: Status;
  avg_duration: number;
  median_duration: number;
  short_rate_percent: number;
  long_rate_percent: number;
  anti_stall_rate_percent: number;
  raw_stress_dominance_max_percent: number;
  near_power_dominance_max_percent: number;
  critical_archetypes: string[];
  compatibility?: CompatibilitySnapshot;
  files: string[];
}

interface CompatibilitySnapshot {
  simulator_hash: string;
  content_hash: string;
  model_hash: string;
  battle_log_schema: "battle_log_v1";
  compatibility_status: "current" | "stale";
}

interface BattleReplaySample {
  tag: string;
  matchup_id: string;
  seed: string;
  level: number;
  player_build_id: string;
  opponent_build_id: string;
  player_archetype_id: string;
  opponent_archetype_id: string;
  player_power: number;
  opponent_power: number;
  duration: number;
  winner: BattleSide;
  reason: string;
  battle_log: BattleSimulationResult["battleLog"];
  rewards: BattleSimulationResult["reward"];
}

interface BattleLabBridgeRequest {
  schema_version?: "battle_lab_request_v1";
  mode?: "run" | "replay";
  run_id?: string;
  archive_run_id?: string;
  compare_with_run_id?: string;
  scratch_run_id?: string;
  seed?: string;
  battle_id?: string;
  player_build?: CombatantBuild;
  opponent_build?: CombatantBuild;
}

interface BattleLabBridgeResponse {
  schema_version: "battle_lab_response_v1";
  ok: boolean;
  mode: "run" | "replay";
  status?: Status;
  run_id?: string;
  output_dir?: string;
  report_path?: string;
  summary?: BattleLabResult["summary"];
  checks?: CheckRow[];
  outliers?: OutlierRow[];
  compare?: CompareRow[];
  replay?: BattleReplaySample;
  error?: { code: string; message: string };
}

interface ProgressionLabDocument {
  saves?: ProgressionLabSave[];
  bot_pool?: ProgressionLabBot[];
}

interface ProgressionLabSave {
  id: string;
  profile_id: string;
  milestone_id: string;
  player: {
    level: number;
    power: number;
  };
  build: {
    archetype_id?: string;
  };
  combat_build: CombatantBuild;
}

interface ProgressionLabBot {
  id: string;
  milestone_id: string;
  profile_id: string;
  archetype_id: string;
  target_power: number;
  level: number;
  build: CombatantBuild;
}

interface BattleLabResult {
  model_id: string;
  generated_at: string;
  overall_status: Status;
  builds: LabBuild[];
  matchups: LabMatchup[];
  archetypes: AggregateRow[];
  near_power_archetypes: AggregateRow[];
  matrix: MatrixRow[];
  near_power_matrix: MatrixRow[];
  power_bands: PowerBandRow[];
  source_by_archetype: SourceByArchetypeRow[];
  outliers: OutlierRow[];
  checks: CheckRow[];
  summary: {
    total_battles: number;
    total_builds: number;
    avg_duration: number;
    median_duration: number;
    short_rate_percent: number;
    long_rate_percent: number;
    anti_stall_rate_percent: number;
    raw_stress_dominance_max_percent: number;
    near_power_dominance_max_percent: number;
    damage_by_source: NumericMap;
    damage_by_type: NumericMap;
    top_notes: string[];
  };
}

type NumericMap = Record<string, number>;

const SPELL_UNLOCKS: Record<string, number> = {
  sussurro_medo: 3,
  terror_primordial: 7,
  labirinto_razao: 7,
  incisao_ritual: 7,
  toxina_palida: 7,
  marca_brasa: 7,
  mare_escura: 7,
  geada_ossos: 7,
  lamina_vento: 7,
  descarga_nervosa: 7,
  mandato_oculto: 15,
  hemorragia_induzida: 15,
  coagulo_negro: 15,
  raizes_pedra: 15,
  coroa_cinzas: 25,
  prisao_gelo: 25,
  putrefacao: 25,
  marca_sepulcral: 25,
  erguer_ossos: 25,
  invocar_brasa_faminta: 25,
};

const PASSIVE_IDS = [
  "doutrina_pavor",
  "mente_fria",
  "anatomista_profano",
  "sangue_obediente",
  "alquimia_toxica",
  "cinza_viva",
  "mare_silenciosa",
  "pedra_interna",
  "pulso_tempestade",
  "ossuario_interior",
  "pacto_familiar",
];
const PET_IDS = [
  "corvo_pressagio",
  "sanguessuga_sacramental",
  "serpente_toxina",
  "cao_cinzas",
  "medusa_mare_fria",
  "escaravelho_pedra",
  "serpe_tempestade",
  "cranio_errante",
  "olho_veu",
];
const WEAPON_IDS = [
  "varinha_cinzas",
  "grimorio_veu",
  "athame_hematico",
  "cajado_ossario",
  "orbe_tempestade",
  "selo_mare_fria",
  "idolo_pedra_viva",
  "cetro_braseiro_negro",
];
const ARCHETYPE_WEAPONS: Record<string, string[]> = {
  starter_instrument: ["varinha_cinzas"],
  mental_controller: ["grimorio_veu", "varinha_cinzas"],
  elemental_mixer: [
    "orbe_tempestade",
    "selo_mare_fria",
    "cetro_braseiro_negro",
  ],
  familiar_handler: ["varinha_cinzas", "grimorio_veu"],
  summoner: ["cajado_ossario", "cetro_braseiro_negro"],
  defensive_occultist: ["idolo_pedra_viva", "selo_mare_fria"],
  dot_pressure: ["athame_hematico", "cetro_braseiro_negro"],
  funeral_burst: ["cajado_ossario", "cetro_braseiro_negro"],
};
const DAMAGE_SOURCE_KEYS = [
  "weapon",
  "spell",
  "dot",
  "pet",
  "summon",
  "system",
];
const DAMAGE_TYPE_KEYS = [
  "arcano",
  "fisico",
  "fogo",
  "agua",
  "gelo",
  "terra",
  "vento",
  "raio",
  "veneno",
  "morte",
  "sangue",
  "none",
];
const COMBAT_PACE_HP_MULTIPLIER_BASE = 3.85;
const COMBAT_PACE_HP_MULTIPLIER_PER_LEVEL = 0.095;
const NEAR_POWER_MAX_DELTA_PERCENT = 20;
const RUN_OUTPUT_FILES = [
  "battle_lab_report.html",
  "battle_lab_summary.json",
  "battle_lab_ui.json",
  "battle_lab_replays.json",
  "battle_lab_matchups.csv",
  "battle_lab_progression_matrix.csv",
  "battle_lab_builds.csv",
  "battle_lab_checks.csv",
  "battle_lab_archetypes.csv",
  "battle_lab_power_bands.csv",
  "battle_lab_outliers.csv",
  "battle_lab_source_by_archetype.csv",
  "battle_lab_near_power_matrix.csv",
  "battle_lab_history_index.csv",
  "battle_lab_compare.csv",
];
const PROGRESSION_MILESTONE_IDS = ["2h", "5h", "10h", "15h", "20h"];

export async function loadModel(
  modelUrl = new URL("model.v1.json", import.meta.url),
): Promise<BattleLabModel> {
  const raw = await Deno.readTextFile(modelUrl);
  return JSON.parse(raw) as BattleLabModel;
}

export function runBattleLab(model: BattleLabModel): BattleLabResult {
  const builds = createBuilds(model);
  const matchups = runMatchups(model, builds);
  return summarize(model, builds, matchups);
}

export function createBuilds(model: BattleLabModel): LabBuild[] {
  const builds: LabBuild[] = [];
  for (const level of model.levels) {
    for (const archetype of model.archetypes) {
      builds.push(createBuild(model, archetype, level, "fixed", 0));
      for (
        let index = 1;
        index <= model.random_builds_per_archetype_per_level;
        index += 1
      ) {
        builds.push(createBuild(model, archetype, level, "random", index));
      }
    }
  }
  builds.push(...createProgressionLabBuilds(model));
  return builds;
}

function createProgressionLabBuilds(model: BattleLabModel): LabBuild[] {
  const document = loadProgressionLabDocument();
  if (document === null) return [];

  const builds: LabBuild[] = [];
  for (const save of document.saves ?? []) {
    const archetypeId = save.build.archetype_id ??
      archetypeIdForBuild(model, save.combat_build);
    builds.push(progressionLabBuild(
      model,
      `PL_${save.id}`,
      `PL ${save.profile_id} ${save.milestone_id}`,
      archetypeId,
      save.player.level,
      save.player.power,
      save.combat_build,
      `${model.seed}:progression_save:${save.id}`,
    ));
  }

  for (const bot of document.bot_pool ?? []) {
    builds.push(progressionLabBuild(
      model,
      `PLBOT_${bot.id}`,
      `PL Bot ${bot.milestone_id} ${bot.archetype_id}`,
      bot.archetype_id,
      bot.level,
      bot.target_power,
      bot.build,
      `${model.seed}:progression_bot:${bot.id}`,
    ));
  }

  return uniqueBuilds(builds);
}

export function calculatePower(build: CombatantBuild): number {
  const spellLevelsTotal = Object.values(build.spellLevels).reduce(
    (sum, level) => sum + level,
    0,
  );
  const petLevel = (build.petId ?? "") === "" ? 0 : build.petLevel ?? 0;
  const passiveLevel = (build.passiveId ?? "") === ""
    ? 0
    : build.passiveLevel ?? 0;
  return (build.level * 42) +
    (build.weaponLevel * 28) +
    (spellLevelsTotal * 40) +
    (petLevel * 34) +
    (passiveLevel * 22) +
    (build.weaponQualityTier * 30);
}

export function classifyPowerBand(power: number, bands: PowerBand[]): string {
  const band = bands.find((candidate) =>
    power >= candidate.min_power && power <= candidate.max_power
  );
  return band?.id ?? "unbanded";
}

export function allowedSpellIds(level: number): string[] {
  return Object.entries(SPELL_UNLOCKS)
    .filter(([, unlockLevel]) => level >= unlockLevel)
    .map(([spellId]) => spellId);
}

export function analyzeBattleLog(
  model: BattleLabModel,
  player: LabBuild,
  opponent: LabBuild,
  battleId: string,
  seed: string,
  simulation: BattleSimulationResult,
): LabMatchup {
  const damageBySource = emptyDamageSourceMap();
  const damageByType = emptyDamageTypeMap();
  const playerDamageBySource = emptyDamageSourceMap();
  const opponentDamageBySource = emptyDamageSourceMap();
  const playerDamageByType = emptyDamageTypeMap();
  const opponentDamageByType = emptyDamageTypeMap();
  const spellCasts: NumericMap = {};
  const maxHp = {
    player: maxHpForLevel(player.build.level),
    opponent: maxHpForLevel(opponent.build.level),
  };
  const lastHp: Record<BattleSide, number> = {
    player: maxHp.player,
    opponent: maxHp.opponent,
  };
  let barrierAbsorbed = 0;
  let healing = 0;
  let summonsCreated = 0;
  let antiStall = false;

  for (const event of simulation.battleLog.events) {
    const eventType = stringValue(event.type);
    if (eventType === "anti_stall") {
      antiStall = true;
      if (typeof event.player_hp_after === "number") {
        lastHp.player = event.player_hp_after;
      }
      if (typeof event.opponent_hp_after === "number") {
        lastHp.opponent = event.opponent_hp_after;
      }
    }

    const damageSource = damageSourceForEvent(eventType);
    if (damageSource !== "") {
      const damage = numberValue(event.damage, 0);
      damageBySource[damageSource] += damage;
      const damageType = stringValue(event.damage_type, "none");
      damageByType[damageType in damageByType ? damageType : "none"] += damage;
      const side = damageSideForEvent(event);
      if (side === "player") {
        playerDamageBySource[damageSource] += damage;
        playerDamageByType[
          damageType in playerDamageByType ? damageType : "none"
        ] += damage;
      } else if (side === "opponent") {
        opponentDamageBySource[damageSource] += damage;
        opponentDamageByType[
          damageType in opponentDamageByType ? damageType : "none"
        ] += damage;
      }
    }

    if (eventType === "barrier_absorb") {
      barrierAbsorbed += numberValue(event.amount, 0);
    } else if (eventType === "heal") {
      healing += numberValue(event.amount, 0);
    } else if (eventType === "summon_spawn") {
      summonsCreated += 1;
    } else if (eventType === "cooldown_start") {
      const spellId = stringValue(event.spell_id, "unknown");
      spellCasts[spellId] = (spellCasts[spellId] ?? 0) + 1;
    }

    const target = stringValue(event.target);
    if (
      (target === "player" || target === "opponent") &&
      typeof event.hp_after === "number"
    ) {
      lastHp[target] = event.hp_after;
    }
  }

  const winner = simulation.battleLog.result.winner;
  const winnerArchetypeId = winner === "player"
    ? player.archetype_id
    : opponent.archetype_id;
  const playerFinalHpPercent = percent(lastHp.player, maxHp.player);
  const opponentFinalHpPercent = percent(lastHp.opponent, maxHp.opponent);
  const winnerHpPercent = winner === "player"
    ? playerFinalHpPercent
    : opponentFinalHpPercent;
  const alerts: string[] = [];

  if (simulation.battleLog.duration < model.thresholds.short_duration) {
    alerts.push("SHORT");
  }
  if (simulation.battleLog.duration > model.thresholds.long_duration) {
    alerts.push("LONG");
  }
  if (antiStall) alerts.push("ANTI_STALL");
  if (
    simulation.battleLog.duration < model.thresholds.target_duration_min &&
    winnerHpPercent >= model.thresholds.stomp_winner_hp_percent
  ) {
    alerts.push("STOMP");
  }

  return {
    id: battleId,
    seed,
    level: player.level,
    player_build_id: player.id,
    opponent_build_id: opponent.id,
    player_archetype_id: player.archetype_id,
    opponent_archetype_id: opponent.archetype_id,
    player_power: player.power,
    opponent_power: opponent.power,
    player_power_band: player.power_band,
    opponent_power_band: opponent.power_band,
    duration: round(simulation.battleLog.duration, 2),
    winner,
    winner_archetype_id: winnerArchetypeId,
    reason: simulation.battleLog.result.reason,
    event_count: simulation.battleLog.events.length,
    anti_stall: antiStall,
    damage_by_source: roundMap(damageBySource),
    damage_by_type: roundMap(damageByType),
    player_damage_by_source: roundMap(playerDamageBySource),
    opponent_damage_by_source: roundMap(opponentDamageBySource),
    player_damage_by_type: roundMap(playerDamageByType),
    opponent_damage_by_type: roundMap(opponentDamageByType),
    barrier_absorbed: round(barrierAbsorbed, 2),
    healing: round(healing, 2),
    summons_created: summonsCreated,
    spell_casts: spellCasts,
    player_final_hp_percent: round(playerFinalHpPercent, 2),
    opponent_final_hp_percent: round(opponentFinalHpPercent, 2),
    alerts,
    severity: alerts.length > 0 ? "REVIEW" : "PASS",
  };
}

export function buildSummaryForTest(model: BattleLabModel): BattleLabResult {
  return summarize(
    model,
    createBuilds(model),
    runMatchups(model, createBuilds(model)),
  );
}

async function main(): Promise<void> {
  const options = parseOptions(Deno.args);
  const projectRoot = new URL("../../", import.meta.url);
  if (options.requestPath !== undefined) {
    await runBridgeRequest(projectRoot, options);
    return;
  }
  const model = await loadModel();
  await runStandardGeneration(projectRoot, model, options);
}

async function runStandardGeneration(
  projectRoot: URL,
  model: BattleLabModel,
  options: BattleLabOptions,
): Promise<BattleLabBridgeResponse> {
  const result = runBattleLab(model);
  const outputUrl = outputUrlForOptions(projectRoot, model, options);
  const runsUrl = new URL("docs/battle-lab/runs/", projectRoot);
  const compatibility = await buildCompatibilitySnapshot(projectRoot, model);
  const history = markHistoryCompatibility(
    await loadHistoryIndex(runsUrl),
    compatibility,
  );
  const compareRows = options.compareWithRunId === undefined
    ? []
    : await loadComparisonRows(runsUrl, options.compareWithRunId, result);
  const manifest = options.archiveRunId === undefined
    ? undefined
    : await buildRunManifest(
      projectRoot,
      result,
      options.archiveRunId,
      compatibility,
    );
  const historyWithPending = manifest === undefined
    ? history
    : upsertHistory(history, manifest);

  await writeOutputs(model, result, outputUrl, historyWithPending, compareRows);
  if (manifest !== undefined) {
    await archiveRun(outputUrl, runsUrl, manifest, historyWithPending);
  }

  const reviewCount =
    result.checks.filter((check) => check.status !== "PASS").length;
  console.log("[battle-lab] generated", {
    status: result.overall_status,
    battles: result.summary.total_battles,
    builds: result.summary.total_builds,
    review_checks: reviewCount,
    report: localPathFromUrl(new URL("battle_lab_report.html", outputUrl)),
    archived_run: options.archiveRunId ?? "",
    compared_with: options.compareWithRunId ?? "",
  });
  return {
    schema_version: "battle_lab_response_v1",
    ok: true,
    mode: "run",
    status: result.overall_status,
    run_id: options.archiveRunId ?? options.scratchRunId ?? "generated",
    output_dir: localPathFromUrl(outputUrl),
    report_path: localPathFromUrl(new URL("battle_lab_report.html", outputUrl)),
    summary: result.summary,
    checks: result.checks,
    outliers: result.outliers.slice(0, 20),
    compare: compareRows,
  };
}

export function parseOptions(args: string[]): BattleLabOptions {
  const options: BattleLabOptions = {};
  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];
    if (arg === "--archive-run") {
      const value = args[index + 1];
      if (value === undefined || value.startsWith("--")) {
        throw new Error("--archive-run requires a run id");
      }
      options.archiveRunId = value;
      index += 1;
    } else if (arg === "--compare-with") {
      const value = args[index + 1];
      if (value === undefined || value.startsWith("--")) {
        throw new Error("--compare-with requires a run id");
      }
      options.compareWithRunId = value;
      index += 1;
    } else if (arg === "--scratch-run") {
      const value = args[index + 1];
      if (value === undefined || value.startsWith("--")) {
        throw new Error("--scratch-run requires a run id");
      }
      options.scratchRunId = value;
      index += 1;
    } else if (arg === "--request") {
      const value = args[index + 1];
      if (value === undefined || value.startsWith("--")) {
        throw new Error("--request requires a JSON path");
      }
      options.requestPath = value;
      index += 1;
    } else if (arg === "--response") {
      const value = args[index + 1];
      if (value === undefined || value.startsWith("--")) {
        throw new Error("--response requires a JSON path");
      }
      options.responsePath = value;
      index += 1;
    } else {
      throw new Error(`Unknown Battle Lab argument: ${arg}`);
    }
  }
  if (options.requestPath === undefined && options.responsePath !== undefined) {
    throw new Error("--response requires --request");
  }
  if (
    options.archiveRunId !== undefined && options.scratchRunId !== undefined
  ) {
    throw new Error("--archive-run and --scratch-run are mutually exclusive");
  }
  return options;
}

async function runBridgeRequest(
  projectRoot: URL,
  options: BattleLabOptions,
): Promise<void> {
  const requestUrl = fileUrlFromPath(options.requestPath!);
  const request = JSON.parse(
    await Deno.readTextFile(requestUrl),
  ) as BattleLabBridgeRequest;
  const response = await handleBridgeRequest(projectRoot, request);
  const serialized = JSON.stringify(response, null, 2) + "\n";
  if (options.responsePath !== undefined) {
    await Deno.writeTextFile(fileUrlFromPath(options.responsePath), serialized);
  }
  console.log(serialized.trim());
}

export async function handleBridgeRequest(
  projectRoot: URL,
  request: BattleLabBridgeRequest,
): Promise<BattleLabBridgeResponse> {
  try {
    if (
      request.schema_version !== undefined &&
      request.schema_version !== "battle_lab_request_v1"
    ) {
      throw new Error(`Unsupported request schema: ${request.schema_version}`);
    }
    const model = await loadModel();
    if (request.seed !== undefined && request.seed.trim() !== "") {
      model.seed = request.seed.trim();
    }
    const mode = request.mode ?? "run";
    if (mode === "replay") {
      return buildBridgeReplayResponse(model, request);
    }
    return await runStandardGeneration(projectRoot, model, {
      archiveRunId: request.archive_run_id,
      compareWithRunId: request.compare_with_run_id,
      scratchRunId: request.archive_run_id === undefined
        ? request.scratch_run_id ?? request.run_id
        : undefined,
    });
  } catch (error) {
    return {
      schema_version: "battle_lab_response_v1",
      ok: false,
      mode: request.mode ?? "run",
      error: {
        code: "BATTLE_LAB_BRIDGE_FAILED",
        message: error instanceof Error ? error.message : String(error),
      },
    };
  }
}

export function buildBridgeReplayResponse(
  model: BattleLabModel,
  request: BattleLabBridgeRequest,
): BattleLabBridgeResponse {
  const player = validateBridgeBuild(request.player_build, "player_build");
  const opponent = validateBridgeBuild(
    request.opponent_build,
    "opponent_build",
  );
  const battleId = sanitizeRunId(request.battle_id ?? "godot_custom_replay");
  const seed = request.seed?.trim() || `battle_lab_bridge:${battleId}`;
  const playerLab = customLabBuild(model, player, "custom_player");
  const opponentLab = customLabBuild(model, opponent, "custom_opponent");
  const simulation = simulateFirstSliceBattle({
    battleId,
    seed,
    player,
    opponent,
  });
  const metrics = analyzeBattleLog(
    model,
    playerLab,
    opponentLab,
    battleId,
    seed,
    simulation,
  );
  return {
    schema_version: "battle_lab_response_v1",
    ok: true,
    mode: "replay",
    status: metrics.severity,
    replay: {
      tag: "custom",
      matchup_id: battleId,
      seed,
      level: Math.max(player.level, opponent.level),
      player_build_id: playerLab.id,
      opponent_build_id: opponentLab.id,
      player_archetype_id: playerLab.archetype_id,
      opponent_archetype_id: opponentLab.archetype_id,
      player_power: playerLab.power,
      opponent_power: opponentLab.power,
      duration: metrics.duration,
      winner: metrics.winner,
      reason: metrics.reason,
      battle_log: simulation.battleLog,
      rewards: simulation.reward,
    },
  };
}

function outputUrlForOptions(
  projectRoot: URL,
  model: BattleLabModel,
  options: BattleLabOptions,
): URL {
  if (options.scratchRunId !== undefined) {
    return new URL(
      `.battle_lab_scratch/${sanitizeRunId(options.scratchRunId)}/`,
      projectRoot,
    );
  }
  return new URL(`${model.output_dir.replace(/\/$/, "")}/`, projectRoot);
}

export async function loadHistoryIndex(runsUrl: URL): Promise<RunManifest[]> {
  try {
    const raw = await Deno.readTextFile(new URL("index.json", runsUrl));
    const parsed = JSON.parse(raw) as { runs?: RunManifest[] };
    return Array.isArray(parsed.runs) ? parsed.runs : [];
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      return [];
    }
    throw error;
  }
}

export async function loadComparisonRows(
  runsUrl: URL,
  baselineRunId: string,
  current: BattleLabResult,
): Promise<CompareRow[]> {
  const baselineUrl = new URL(
    `${baselineRunId}/battle_lab_summary.json`,
    runsUrl,
  );
  const baseline = JSON.parse(
    await Deno.readTextFile(baselineUrl),
  ) as BattleLabResult;
  return compareBattleLabResults(baselineRunId, baseline, current);
}

export function compareBattleLabResults(
  baselineRunId: string,
  baseline: BattleLabResult,
  current: BattleLabResult,
): CompareRow[] {
  const rows: CompareRow[] = [
    compareText("baseline_run", baselineRunId, current.model_id),
    compareText(
      "overall_status",
      baseline.overall_status,
      current.overall_status,
    ),
    compareNumber(
      "avg_duration",
      baseline.summary.avg_duration,
      current.summary.avg_duration,
      "s",
    ),
    compareNumber(
      "median_duration",
      baseline.summary.median_duration,
      current.summary.median_duration,
      "s",
    ),
    compareNumber(
      "short_rate_percent",
      baseline.summary.short_rate_percent,
      current.summary.short_rate_percent,
      "%",
    ),
    compareNumber(
      "long_rate_percent",
      baseline.summary.long_rate_percent,
      current.summary.long_rate_percent,
      "%",
    ),
    compareNumber(
      "anti_stall_rate_percent",
      baseline.summary.anti_stall_rate_percent,
      current.summary.anti_stall_rate_percent,
      "%",
    ),
    compareNumber(
      "raw_stress_dominance_max_percent",
      baseline.summary.raw_stress_dominance_max_percent ??
        maxAggregateWinRate(baseline.archetypes),
      current.summary.raw_stress_dominance_max_percent,
      "%",
    ),
    compareNumber(
      "near_power_dominance_max_percent",
      baseline.summary.near_power_dominance_max_percent ??
        maxAggregateWinRate(baseline.near_power_archetypes ?? []),
      current.summary.near_power_dominance_max_percent,
      "%",
    ),
  ];

  for (const currentRow of current.near_power_archetypes) {
    const baselineRow = (baseline.near_power_archetypes ?? []).find((row) =>
      row.id === currentRow.id
    );
    if (baselineRow === undefined) continue;
    rows.push(
      compareNumber(
        `near_power_win_rate:${currentRow.id}`,
        baselineRow.win_rate_percent,
        currentRow.win_rate_percent,
        "%",
      ),
    );
  }

  return rows;
}

export async function buildRunManifest(
  projectRoot: URL,
  result: BattleLabResult,
  runId: string,
  compatibility?: CompatibilitySnapshot,
): Promise<RunManifest> {
  return {
    run_id: runId,
    archived_at: new Date().toISOString(),
    base_sha: await readGitHead(projectRoot),
    model_id: result.model_id,
    seed: result.builds[0]?.seed.split(":")[0] ?? "",
    hypothesis: hypothesisForRunId(runId),
    overall_status: result.overall_status,
    avg_duration: result.summary.avg_duration,
    median_duration: result.summary.median_duration,
    short_rate_percent: result.summary.short_rate_percent,
    long_rate_percent: result.summary.long_rate_percent,
    anti_stall_rate_percent: result.summary.anti_stall_rate_percent,
    raw_stress_dominance_max_percent:
      result.summary.raw_stress_dominance_max_percent,
    near_power_dominance_max_percent:
      result.summary.near_power_dominance_max_percent,
    critical_archetypes: result.near_power_archetypes
      .filter((row) => row.status === "CRITICAL")
      .map((row) => row.id),
    compatibility,
    files: RUN_OUTPUT_FILES,
  };
}

export function upsertHistory(
  history: RunManifest[],
  manifest: RunManifest,
): RunManifest[] {
  return [
    ...history.filter((entry) => entry.run_id !== manifest.run_id),
    manifest,
  ].sort((left, right) => left.run_id.localeCompare(right.run_id));
}

export function markHistoryCompatibility(
  history: RunManifest[],
  current: CompatibilitySnapshot,
): RunManifest[] {
  return history.map((entry) => {
    const compatibility = entry.compatibility;
    const isCurrent = compatibility !== undefined &&
      compatibility.simulator_hash === current.simulator_hash &&
      compatibility.content_hash === current.content_hash &&
      compatibility.model_hash === current.model_hash &&
      compatibility.battle_log_schema === current.battle_log_schema;
    return {
      ...entry,
      compatibility: {
        simulator_hash: compatibility?.simulator_hash ?? "unknown",
        content_hash: compatibility?.content_hash ?? "unknown",
        model_hash: compatibility?.model_hash ?? "unknown",
        battle_log_schema: "battle_log_v1",
        compatibility_status: isCurrent ? "current" : "stale",
      },
    };
  });
}

export async function archiveRun(
  outputUrl: URL,
  runsUrl: URL,
  manifest: RunManifest,
  historyRows: RunManifest[],
): Promise<void> {
  const runUrl = new URL(`${manifest.run_id}/`, runsUrl);
  await Deno.mkdir(runUrl, { recursive: true });
  for (const fileName of RUN_OUTPUT_FILES) {
    try {
      const content = await Deno.readTextFile(new URL(fileName, outputUrl));
      await Deno.writeTextFile(new URL(fileName, runUrl), content);
    } catch (error) {
      if (!(error instanceof Deno.errors.NotFound)) {
        throw error;
      }
    }
  }
  await Deno.writeTextFile(
    new URL("run_manifest.json", runUrl),
    JSON.stringify(manifest, null, 2) + "\n",
  );
  await Deno.mkdir(runsUrl, { recursive: true });
  await Deno.writeTextFile(
    new URL("index.json", runsUrl),
    historyIndexDocument(historyRows),
  );
}

export function historyIndexDocument(historyRows: RunManifest[]): string {
  return JSON.stringify(
    {
      schema_version: 1,
      updated_at: new Date().toISOString(),
      runs: historyRows,
    },
    null,
    2,
  ) + "\n";
}

function createBuild(
  model: BattleLabModel,
  archetype: ArchetypeModel,
  level: number,
  kind: BuildKind,
  variant: number,
): LabBuild {
  const seed = `${model.seed}:${archetype.id}:L${level}:${kind}:${variant}`;
  const rng = new SeededRandom(seed);
  const maxSlots = maxSpellSlots(level);
  const spells = selectSpells(archetype, level, maxSlots, kind, rng);
  const passiveId = selectOptional(
    archetype.passive_preferences,
    PASSIVE_IDS,
    level >= 10,
    kind,
    rng,
  );
  const petId = selectOptional(
    archetype.pet_preferences,
    PET_IDS,
    level >= 15,
    kind,
    rng,
  );
  const weaponId = selectOptional(
    ARCHETYPE_WEAPONS[archetype.id] ?? [],
    WEAPON_IDS,
    true,
    kind,
    rng,
  ) ?? "varinha_cinzas";
  const weaponLevel = scaledLevel(
    level,
    archetype.weapon_level_ratio,
    kind,
    rng,
  );
  const spellLevel = scaledLevel(level, archetype.spell_level_ratio, kind, rng);
  const passiveLevel = passiveId === undefined
    ? undefined
    : scaledLevel(level, archetype.passive_level_ratio, kind, rng);
  const petLevel = petId === undefined
    ? undefined
    : scaledLevel(level, archetype.pet_level_ratio, kind, rng);
  const qualityTier = qualityTierForLevel(
    level,
    archetype.quality_bias,
    kind,
    rng,
  );
  const spellLevels: Record<string, number> = {};
  for (const spellId of spells) {
    spellLevels[spellId] = Math.min(level, spellLevel);
  }

  const suffix = kind === "fixed" ? "fixed" : `r${variant}`;
  const id = `L${level}_${archetype.id}_${suffix}`;
  const build: CombatantBuild = {
    id,
    displayName: `${archetype.display_name} L${level}`,
    level,
    weaponId,
    weaponLevel,
    weaponQualityTier: qualityTier,
    spellIds: spells,
    spellLevels,
    passiveId,
    passiveLevel,
    petId,
    petLevel,
  };
  const power = calculatePower(build);
  return {
    id,
    kind,
    archetype_id: archetype.id,
    archetype_name: archetype.display_name,
    level,
    power,
    power_band: classifyPowerBand(power, model.power_bands),
    seed,
    build,
  };
}

function loadProgressionLabDocument(): ProgressionLabDocument | null {
  const candidates = [
    new URL(
      "../../docs/progression-lab/generated/progression_summary.json",
      import.meta.url,
    ),
    new URL(
      "../../docs/progression-lab/generated/healthy_saves.json",
      import.meta.url,
    ),
  ];
  for (const url of candidates) {
    try {
      return JSON.parse(Deno.readTextFileSync(url)) as ProgressionLabDocument;
    } catch {
      continue;
    }
  }
  return null;
}

function progressionLabBuild(
  model: BattleLabModel,
  id: string,
  displayName: string,
  archetypeId: string,
  level: number,
  _power: number,
  build: CombatantBuild,
  seed: string,
): LabBuild {
  const normalizedArchetypeId = archetypeIdForModel(model, archetypeId);
  const combatBuild: CombatantBuild = {
    ...build,
    id,
    displayName,
    level,
  };
  const resolvedPower = calculatePower(combatBuild);
  return {
    id,
    kind: "fixed",
    archetype_id: normalizedArchetypeId,
    archetype_name: archetypeNameFor(model, normalizedArchetypeId),
    level,
    power: resolvedPower,
    power_band: classifyPowerBand(resolvedPower, model.power_bands),
    seed,
    build: combatBuild,
  };
}

function archetypeIdForBuild(
  model: BattleLabModel,
  build: CombatantBuild,
): string {
  const spellIds = new Set(build.spellIds);
  if (spellIds.has("erguer_ossos") || spellIds.has("invocar_brasa_faminta")) {
    return archetypeIdForModel(model, "summoner");
  }
  if (
    spellIds.has("hemorragia_induzida") || spellIds.has("toxina_palida") ||
    spellIds.has("putrefacao")
  ) {
    return archetypeIdForModel(model, "dot_pressure");
  }
  if (
    spellIds.has("marca_sepulcral") || spellIds.has("coroa_cinzas") ||
    spellIds.has("descarga_nervosa")
  ) {
    return archetypeIdForModel(model, "funeral_burst");
  }
  if (build.petId !== undefined && build.petId !== "") {
    return archetypeIdForModel(model, "familiar_handler");
  }
  if (
    spellIds.has("coagulo_negro") || spellIds.has("geada_ossos") ||
    spellIds.has("raizes_pedra")
  ) {
    return archetypeIdForModel(model, "defensive_occultist");
  }
  if (spellIds.has("sussurro_medo") || spellIds.has("terror_primordial")) {
    return archetypeIdForModel(model, "mental_controller");
  }
  if (spellIds.size > 0) return archetypeIdForModel(model, "elemental_mixer");
  return archetypeIdForModel(model, "starter_instrument");
}

function archetypeIdForModel(
  model: BattleLabModel,
  archetypeId: string,
): string {
  if (model.archetypes.some((candidate) => candidate.id === archetypeId)) {
    return archetypeId;
  }
  return model.archetypes[0]?.id ?? archetypeId;
}

function archetypeNameFor(model: BattleLabModel, archetypeId: string): string {
  return model.archetypes.find((candidate) => candidate.id === archetypeId)
    ?.display_name ?? archetypeId;
}

function uniqueBuilds(builds: LabBuild[]): LabBuild[] {
  const seen = new Set<string>();
  const unique: LabBuild[] = [];
  for (const build of builds) {
    if (seen.has(build.id)) continue;
    seen.add(build.id);
    unique.push(build);
  }
  return unique;
}

function runMatchups(model: BattleLabModel, builds: LabBuild[]): LabMatchup[] {
  const matchups: LabMatchup[] = [];
  const byLevel = groupBy(builds, (build) => String(build.level));
  for (const [levelKey, levelBuilds] of Object.entries(byLevel)) {
    let index = 1;
    for (let left = 0; left < levelBuilds.length; left += 1) {
      for (let right = left + 1; right < levelBuilds.length; right += 1) {
        const first = levelBuilds[left];
        const second = levelBuilds[right];
        matchups.push(
          runSingleMatchup(model, Number(levelKey), index, first, second),
        );
        index += 1;
        matchups.push(
          runSingleMatchup(model, Number(levelKey), index, second, first),
        );
        index += 1;
      }
    }
  }
  return matchups;
}

function runSingleMatchup(
  model: BattleLabModel,
  level: number,
  index: number,
  player: LabBuild,
  opponent: LabBuild,
): LabMatchup {
  const battleId = `L${level}_M${String(index).padStart(4, "0")}`;
  const seed =
    `battle_lab:${model.model_id}:${battleId}:${player.seed}:${opponent.seed}`;
  const simulation = simulateFirstSliceBattle({
    battleId,
    seed,
    player: player.build,
    opponent: opponent.build,
  });
  return analyzeBattleLog(model, player, opponent, battleId, seed, simulation);
}

function summarize(
  model: BattleLabModel,
  builds: LabBuild[],
  matchups: LabMatchup[],
): BattleLabResult {
  const durations = matchups.map((matchup) => matchup.duration);
  const totalBattles = matchups.length;
  const shortCount =
    matchups.filter((matchup) =>
      matchup.duration < model.thresholds.short_duration
    ).length;
  const longCount =
    matchups.filter((matchup) =>
      matchup.duration > model.thresholds.long_duration
    ).length;
  const antiStallCount =
    matchups.filter((matchup) => matchup.anti_stall).length;
  const damageBySource = sumMaps(
    matchups.map((matchup) => matchup.damage_by_source),
    DAMAGE_SOURCE_KEYS,
  );
  const damageByType = sumMaps(
    matchups.map((matchup) => matchup.damage_by_type),
    DAMAGE_TYPE_KEYS,
  );
  const nearPowerMatchups = matchups.filter((matchup) =>
    nearPowerMatchup(matchup, NEAR_POWER_MAX_DELTA_PERCENT) &&
    !sameArchetypeMatchup(matchup)
  );
  const archetypes = aggregateArchetypes(model, matchups);
  const nearPowerArchetypes = aggregateArchetypesAcrossSides(
    model,
    nearPowerMatchups,
  );
  const matrix = aggregateMatrix(model, matchups);
  const nearPowerMatrix = aggregateMatrix(model, nearPowerMatchups, {
    excludeSelf: true,
  });
  const powerBands = aggregatePowerBands(model, matchups);
  const sourceByArchetype = aggregateSourceByArchetype(model, matchups);
  const outliers = buildOutliers(
    model,
    matchups,
    archetypes,
    nearPowerArchetypes,
  );
  const checks = buildChecks(
    model,
    matchups,
    nearPowerArchetypes,
    totalBattles,
    shortCount,
    longCount,
    antiStallCount,
    durations,
  );
  const overallStatus = maxStatus(checks.map((check) => check.status));
  const topNotes = buildTopNotes(checks, outliers);

  return {
    model_id: model.model_id,
    generated_at: "deterministic-local",
    overall_status: overallStatus,
    builds,
    matchups,
    archetypes,
    near_power_archetypes: nearPowerArchetypes,
    matrix,
    near_power_matrix: nearPowerMatrix,
    power_bands: powerBands,
    source_by_archetype: sourceByArchetype,
    outliers,
    checks,
    summary: {
      total_battles: totalBattles,
      total_builds: builds.length,
      avg_duration: round(avg(durations), 2),
      median_duration: round(median(durations), 2),
      short_rate_percent: rate(shortCount, totalBattles),
      long_rate_percent: rate(longCount, totalBattles),
      anti_stall_rate_percent: rate(antiStallCount, totalBattles),
      raw_stress_dominance_max_percent: maxAggregateWinRate(archetypes),
      near_power_dominance_max_percent: maxAggregateWinRate(
        nearPowerArchetypes,
      ),
      damage_by_source: roundMap(damageBySource),
      damage_by_type: roundMap(damageByType),
      top_notes: topNotes,
    },
  };
}

function aggregateArchetypes(
  model: BattleLabModel,
  matchups: LabMatchup[],
): AggregateRow[] {
  return model.archetypes.map((archetype) => {
    const rows = matchups.filter((matchup) =>
      matchup.player_archetype_id === archetype.id
    );
    return aggregateRows(archetype.id, archetype.display_name, rows, model);
  });
}

function aggregateArchetypesAcrossSides(
  model: BattleLabModel,
  matchups: LabMatchup[],
): AggregateRow[] {
  return model.archetypes.map((archetype) => {
    const rows = matchups.filter((matchup) =>
      matchup.player_archetype_id === archetype.id ||
      matchup.opponent_archetype_id === archetype.id
    );
    const wins = rows.filter((matchup) =>
      matchup.winner_archetype_id === archetype.id
    ).length;
    return aggregateRowsWithWins(
      archetype.id,
      archetype.display_name,
      rows,
      wins,
      model,
    );
  });
}

function aggregateMatrix(
  model: BattleLabModel,
  matchups: LabMatchup[],
  options: { excludeSelf?: boolean } = {},
): MatrixRow[] {
  const rows: MatrixRow[] = [];
  for (const player of model.archetypes) {
    for (const opponent of model.archetypes) {
      if (options.excludeSelf === true && player.id === opponent.id) {
        continue;
      }
      const filtered = matchups.filter((matchup) =>
        matchup.player_archetype_id === player.id &&
        matchup.opponent_archetype_id === opponent.id
      );
      if (filtered.length === 0) continue;
      const wins = filtered.filter((matchup) =>
        matchup.winner === "player"
      ).length;
      const winRate = rate(wins, filtered.length);
      rows.push({
        player_archetype_id: player.id,
        opponent_archetype_id: opponent.id,
        total: filtered.length,
        wins,
        win_rate_percent: winRate,
        avg_duration: round(
          avg(filtered.map((matchup) => matchup.duration)),
          2,
        ),
        status: statusForWinRate(model, winRate),
      });
    }
  }
  return rows;
}

function aggregatePowerBands(
  model: BattleLabModel,
  matchups: LabMatchup[],
): PowerBandRow[] {
  const grouped = groupBy(
    matchups,
    (matchup) => `${matchup.level}:${matchup.player_power_band}`,
  );
  return Object.entries(grouped).map(([key, rows]) => {
    const [levelText, band] = key.split(":");
    const aggregate = aggregateRows(`${levelText}_${band}`, band, rows, model);
    return {
      id: aggregate.id,
      level: Number(levelText),
      power_band: band,
      total: aggregate.total,
      wins: aggregate.wins,
      win_rate_percent: aggregate.win_rate_percent,
      avg_duration: aggregate.avg_duration,
      median_duration: aggregate.median_duration,
      short_rate_percent: aggregate.short_rate_percent,
      long_rate_percent: aggregate.long_rate_percent,
      anti_stall_rate_percent: aggregate.anti_stall_rate_percent,
      status: aggregate.status,
    };
  }).sort((left, right) =>
    left.level - right.level || left.power_band.localeCompare(right.power_band)
  );
}

function aggregateRows(
  id: string,
  displayName: string,
  rows: LabMatchup[],
  model: BattleLabModel,
): AggregateRow {
  const wins = rows.filter((matchup) => matchup.winner === "player").length;
  return aggregateRowsWithWins(id, displayName, rows, wins, model);
}

function aggregateRowsWithWins(
  id: string,
  displayName: string,
  rows: LabMatchup[],
  wins: number,
  model: BattleLabModel,
): AggregateRow {
  const durations = rows.map((matchup) => matchup.duration);
  const shortCount =
    rows.filter((matchup) => matchup.duration < model.thresholds.short_duration)
      .length;
  const longCount =
    rows.filter((matchup) => matchup.duration > model.thresholds.long_duration)
      .length;
  const antiStallCount = rows.filter((matchup) => matchup.anti_stall).length;
  const winRate = rate(wins, rows.length);
  return {
    id,
    display_name: displayName,
    total: rows.length,
    wins,
    losses: rows.length - wins,
    win_rate_percent: winRate,
    avg_duration: round(avg(durations), 2),
    median_duration: round(median(durations), 2),
    short_rate_percent: rate(shortCount, rows.length),
    long_rate_percent: rate(longCount, rows.length),
    anti_stall_rate_percent: rate(antiStallCount, rows.length),
    status: maxStatus([
      statusForWinRate(model, winRate),
      rate(antiStallCount, rows.length) >
          model.thresholds.anti_stall_review_percent
        ? "REVIEW"
        : "PASS",
    ]),
  };
}

function aggregateSourceByArchetype(
  model: BattleLabModel,
  matchups: LabMatchup[],
): SourceByArchetypeRow[] {
  return model.archetypes.map((archetype) => {
    const damage = emptyDamageSourceMap();
    const rows = matchups.filter((matchup) =>
      matchup.player_archetype_id === archetype.id ||
      matchup.opponent_archetype_id === archetype.id
    );
    let wins = 0;
    for (const matchup of rows) {
      if (matchup.winner_archetype_id === archetype.id) {
        wins += 1;
      }
      if (matchup.player_archetype_id === archetype.id) {
        addMap(damage, matchup.player_damage_by_source);
      }
      if (matchup.opponent_archetype_id === archetype.id) {
        addMap(damage, matchup.opponent_damage_by_source);
      }
    }
    const totalDamage = DAMAGE_SOURCE_KEYS.reduce(
      (total, key) => total + (damage[key] ?? 0),
      0,
    );
    const dominantSource = [...DAMAGE_SOURCE_KEYS].sort((left, right) =>
      (damage[right] ?? 0) - (damage[left] ?? 0)
    )[0] ?? "";
    return {
      archetype_id: archetype.id,
      display_name: archetype.display_name,
      total: rows.length,
      wins,
      avg_duration: round(
        avg(rows.map((matchup) =>
          matchup.duration
        )),
        2,
      ),
      weapon_damage: round(damage.weapon ?? 0, 2),
      spell_damage: round(damage.spell ?? 0, 2),
      dot_damage: round(damage.dot ?? 0, 2),
      pet_damage: round(damage.pet ?? 0, 2),
      summon_damage: round(damage.summon ?? 0, 2),
      system_damage: round(damage.system ?? 0, 2),
      total_damage: round(totalDamage, 2),
      dominant_source: dominantSource,
    };
  });
}

function buildOutliers(
  model: BattleLabModel,
  matchups: LabMatchup[],
  archetypes: AggregateRow[],
  nearPowerArchetypes: AggregateRow[],
): OutlierRow[] {
  const rows: OutlierRow[] = [];
  for (const matchup of matchups) {
    for (const alert of matchup.alerts) {
      rows.push({
        type: alert,
        severity: matchup.severity,
        matchup_id: matchup.id,
        seed: matchup.seed,
        player_build_id: matchup.player_build_id,
        opponent_build_id: matchup.opponent_build_id,
        level: String(matchup.level),
        power: `${matchup.player_power} vs ${matchup.opponent_power}`,
        duration: String(matchup.duration),
        winner: matchup.winner_archetype_id,
        reason: matchup.reason,
      });
    }
  }

  for (const archetype of archetypes) {
    if (
      archetype.win_rate_percent > model.thresholds.dominance_review_percent
    ) {
      rows.push({
        type: "RAW_STRESS_DOMINANCE",
        severity: archetype.win_rate_percent >
            model.thresholds.dominance_critical_percent
          ? "CRITICAL"
          : "REVIEW",
        matchup_id: "",
        seed: "",
        player_build_id: archetype.id,
        opponent_build_id: "all",
        level: "all",
        power: "",
        duration: String(archetype.avg_duration),
        winner: archetype.id,
        reason: `win_rate=${archetype.win_rate_percent}%`,
      });
    }
  }

  for (const archetype of nearPowerArchetypes) {
    if (
      archetype.win_rate_percent > model.thresholds.dominance_review_percent
    ) {
      rows.push({
        type: "NEAR_POWER_DOMINANCE",
        severity: archetype.win_rate_percent >
            model.thresholds.dominance_critical_percent
          ? "CRITICAL"
          : "REVIEW",
        matchup_id: "",
        seed: "",
        player_build_id: archetype.id,
        opponent_build_id: `near_power_delta_${NEAR_POWER_MAX_DELTA_PERCENT}%`,
        level: "all",
        power: "near_power",
        duration: String(archetype.avg_duration),
        winner: archetype.id,
        reason: `win_rate=${archetype.win_rate_percent}%`,
      });
    }
  }

  return rows.sort((left, right) =>
    statusRank(right.severity) - statusRank(left.severity)
  );
}

function buildChecks(
  model: BattleLabModel,
  matchups: LabMatchup[],
  nearPowerArchetypes: AggregateRow[],
  totalBattles: number,
  shortCount: number,
  longCount: number,
  antiStallCount: number,
  durations: number[],
): CheckRow[] {
  const avgDuration = round(avg(durations), 2);
  const shortRate = rate(shortCount, totalBattles);
  const longRate = rate(longCount, totalBattles);
  const antiStallRate = rate(antiStallCount, totalBattles);
  const maxWinRate = maxAggregateWinRate(nearPowerArchetypes);
  const minWinRate = minAggregateWinRate(nearPowerArchetypes);
  const coveredLevels = new Set(matchups.map((matchup) => matchup.level));
  const configuredLevelsCovered =
    model.levels.filter((level) => coveredLevels.has(level)).length;
  const expectedLevels = model.levels.length;

  return [
    {
      id: "average_duration_target",
      status: avgDuration >= model.thresholds.target_duration_min &&
          avgDuration <= model.thresholds.target_duration_max
        ? "PASS"
        : "REVIEW",
      observed: `${avgDuration}s`,
      target:
        `${model.thresholds.target_duration_min}-${model.thresholds.target_duration_max}s`,
      note:
        "Average battle duration should sit near the target playtest window.",
    },
    {
      id: "short_battle_rate",
      status: shortRate <= model.thresholds.short_battle_rate_review_percent
        ? "PASS"
        : "REVIEW",
      observed: `${shortRate}%`,
      target: `<= ${model.thresholds.short_battle_rate_review_percent}%`,
      note: "Too many short battles suggest burst or low HP scaling issues.",
    },
    {
      id: "long_battle_rate",
      status: longRate <= model.thresholds.long_battle_rate_review_percent
        ? "PASS"
        : "REVIEW",
      observed: `${longRate}%`,
      target: `<= ${model.thresholds.long_battle_rate_review_percent}%`,
      note:
        "Too many long battles suggest defensive scaling or low damage pressure.",
    },
    {
      id: "anti_stall_rate",
      status: antiStallRate <= model.thresholds.anti_stall_review_percent
        ? "PASS"
        : "REVIEW",
      observed: `${antiStallRate}%`,
      target: `<= ${model.thresholds.anti_stall_review_percent}%`,
      note: "Anti-stall should be rare in normal same-level matchups.",
    },
    {
      id: "near_power_dominance",
      status: maxWinRate > model.thresholds.dominance_critical_percent
        ? "CRITICAL"
        : maxWinRate > model.thresholds.dominance_review_percent
        ? "REVIEW"
        : "PASS",
      observed: `${maxWinRate}% max / ${minWinRate}% min`,
      target: `max <= ${model.thresholds.dominance_review_percent}%`,
      note:
        `Dominance uses <= ${NEAR_POWER_MAX_DELTA_PERCENT}% power delta and excludes same-archetype mirrors.`,
    },
    {
      id: "level_coverage",
      status: configuredLevelsCovered === expectedLevels ? "PASS" : "CRITICAL",
      observed:
        `${configuredLevelsCovered}/${expectedLevels} configured, ${coveredLevels.size} total`,
      target: `${expectedLevels}/${expectedLevels}`,
      note: "Every configured level checkpoint should produce matchups.",
    },
    ...buildSourceIdentityChecks(model, matchups),
  ];
}

function buildSourceIdentityChecks(
  model: BattleLabModel,
  matchups: LabMatchup[],
): CheckRow[] {
  const postStarterRows = sourceRowsFromLevel(model, matchups, 7);
  const nonStarterRows = postStarterRows.filter((row) =>
    row.archetype_id !== "starter_instrument" && row.total_damage > 0
  );
  const maxWeaponRow =
    nonStarterRows.sort((left, right) =>
      sourceSharePercent(right, ["weapon_damage"]) -
      sourceSharePercent(left, ["weapon_damage"])
    )[0];
  const maxWeaponShare = maxWeaponRow === undefined
    ? 0
    : sourceSharePercent(maxWeaponRow, ["weapon_damage"]);
  const checks: CheckRow[] = [
    {
      id: "source_identity_weapon_cap",
      status: maxWeaponShare > 85
        ? "CRITICAL"
        : maxWeaponShare > 75
        ? "REVIEW"
        : "PASS",
      observed: maxWeaponRow === undefined
        ? "0%"
        : `${maxWeaponShare}% max (${maxWeaponRow.archetype_id})`,
      target: "<= 75% from level 7+ outside starter",
      note:
        "Non-starter archetypes should not read as ritual-instrument-only combat once spells enter the kit.",
    },
  ];

  checks.push(
    sourceIdentityCheck(
      "source_identity_mental",
      sourceRowsFromLevel(model, matchups, 7),
      "mental_controller",
      ["spell_damage", "pet_damage"],
      22,
      "Mental Controller should visibly pressure through spells and occult familiars, not only weapon cadence.",
    ),
    sourceIdentityCheck(
      "source_identity_elemental",
      sourceRowsFromLevel(model, matchups, 7),
      "elemental_mixer",
      ["spell_damage", "dot_damage", "pet_damage"],
      28,
      "Elemental Mixer should show elemental spell, dot or familiar pressure in the damage mix.",
    ),
    sourceIdentityCheck(
      "source_identity_familiar",
      sourceRowsFromLevel(model, matchups, 15),
      "familiar_handler",
      ["pet_damage"],
      10,
      "Familiar Handler should have a measurable familiar contribution after pets unlock.",
    ),
    sourceIdentityCheck(
      "source_identity_summoner",
      sourceRowsFromLevel(model, matchups, 25),
      "summoner",
      ["summon_damage"],
      10,
      "Summoner should produce real summon damage after superior physical rites unlock.",
    ),
    sourceIdentityCheck(
      "source_identity_dot",
      sourceRowsFromLevel(model, matchups, 15),
      "dot_pressure",
      ["dot_damage"],
      12,
      "Dot Pressure should be readable through bleed, poison, burn or death ticks.",
    ),
    sourceIdentityCheck(
      "source_identity_funeral",
      sourceRowsFromLevel(model, matchups, 25),
      "funeral_burst",
      ["spell_damage", "dot_damage", "summon_damage"],
      30,
      "Funeral Burst should lean on death/fire rites once advanced physical magic unlocks.",
    ),
  );

  return checks;
}

function sourceRowsFromLevel(
  model: BattleLabModel,
  matchups: LabMatchup[],
  minimumLevel: number,
): SourceByArchetypeRow[] {
  return aggregateSourceByArchetype(
    model,
    matchups.filter((matchup) => matchup.level >= minimumLevel),
  );
}

function sourceIdentityCheck(
  id: string,
  rows: SourceByArchetypeRow[],
  archetypeId: string,
  columns: SourceDamageColumn[],
  targetPercent: number,
  note: string,
): CheckRow {
  const row = rows.find((item) => item.archetype_id === archetypeId);
  if (row === undefined || row.total_damage <= 0) {
    return {
      id,
      status: "CRITICAL",
      observed: "missing",
      target: `>= ${targetPercent}%`,
      note,
    };
  }
  const observed = sourceSharePercent(row, columns);
  return {
    id,
    status: observed >= targetPercent ? "PASS" : "REVIEW",
    observed: `${observed}% (${columns.map(sourceColumnLabel).join("+")})`,
    target: `>= ${targetPercent}%`,
    note,
  };
}

function sourceSharePercent(
  row: SourceByArchetypeRow,
  columns: SourceDamageColumn[],
): number {
  if (row.total_damage <= 0) return 0;
  const amount = columns.reduce((total, column) => total + row[column], 0);
  return round((amount / row.total_damage) * 100, 2);
}

function sourceColumnLabel(column: SourceDamageColumn): string {
  return column.replace("_damage", "");
}

export async function writeOutputs(
  model: BattleLabModel,
  result: BattleLabResult,
  outputUrl: URL,
  historyRows: RunManifest[] = [],
  compareRows: CompareRow[] = [],
): Promise<void> {
  await Deno.mkdir(outputUrl, { recursive: true });
  const replaySamples = buildReplaySamples(model, result);
  await Deno.writeTextFile(
    new URL("battle_lab_summary.json", outputUrl),
    JSON.stringify(result, null, 2) + "\n",
  );
  await Deno.writeTextFile(
    new URL("battle_lab_ui.json", outputUrl),
    JSON.stringify(
      buildUiDocument(result, historyRows, compareRows, replaySamples),
      null,
      2,
    ) + "\n",
  );
  await Deno.writeTextFile(
    new URL("battle_lab_replays.json", outputUrl),
    JSON.stringify(
      {
        schema_version: "battle_lab_replays_v1",
        generated_at: result.generated_at,
        model_id: result.model_id,
        replays: replaySamples,
      },
      null,
      2,
    ) + "\n",
  );
  await Deno.writeTextFile(
    new URL("battle_lab_builds.csv", outputUrl),
    toCsv(buildRows(result.builds), [
      "id",
      "kind",
      "archetype_id",
      "archetype_name",
      "level",
      "power",
      "power_band",
      "seed",
      "weapon_id",
      "spell_ids",
      "passive_id",
      "pet_id",
      "weapon_level",
      "weapon_quality_tier",
    ]),
  );
  await Deno.writeTextFile(
    new URL("battle_lab_matchups.csv", outputUrl),
    toCsv(matchupRows(result.matchups), [
      "id",
      "seed",
      "level",
      "player_build_id",
      "opponent_build_id",
      "player_archetype_id",
      "opponent_archetype_id",
      "player_power",
      "opponent_power",
      "duration",
      "winner",
      "reason",
      "event_count",
      "anti_stall",
      "barrier_absorbed",
      "healing",
      "summons_created",
      "player_final_hp_percent",
      "opponent_final_hp_percent",
      "alerts",
      "damage_by_source",
      "damage_by_type",
      "player_damage_by_source",
      "opponent_damage_by_source",
      "player_damage_by_type",
      "opponent_damage_by_type",
      "spell_casts",
    ]),
  );
  await Deno.writeTextFile(
    new URL("battle_lab_progression_matrix.csv", outputUrl),
    toCsv(progressionMatrixRows(result.matchups), [
      "category",
      "milestone_id",
      "player",
      "opponent",
      "total",
      "wins",
      "win_rate_percent",
      "avg_duration",
      "status",
    ]),
  );
  await Deno.writeTextFile(
    new URL("battle_lab_archetypes.csv", outputUrl),
    toCsv(result.archetypes, [
      "id",
      "display_name",
      "total",
      "wins",
      "losses",
      "win_rate_percent",
      "avg_duration",
      "median_duration",
      "short_rate_percent",
      "long_rate_percent",
      "anti_stall_rate_percent",
      "status",
    ]),
  );
  await Deno.writeTextFile(
    new URL("battle_lab_power_bands.csv", outputUrl),
    toCsv(result.power_bands, [
      "id",
      "level",
      "power_band",
      "total",
      "wins",
      "win_rate_percent",
      "avg_duration",
      "median_duration",
      "short_rate_percent",
      "long_rate_percent",
      "anti_stall_rate_percent",
      "status",
    ]),
  );
  await Deno.writeTextFile(
    new URL("battle_lab_outliers.csv", outputUrl),
    toCsv(result.outliers, [
      "type",
      "severity",
      "matchup_id",
      "seed",
      "player_build_id",
      "opponent_build_id",
      "level",
      "power",
      "duration",
      "winner",
      "reason",
    ]),
  );
  await Deno.writeTextFile(
    new URL("battle_lab_checks.csv", outputUrl),
    toCsv(result.checks, [
      "id",
      "status",
      "observed",
      "target",
      "note",
    ]),
  );
  await Deno.writeTextFile(
    new URL("battle_lab_source_by_archetype.csv", outputUrl),
    toCsv(result.source_by_archetype, [
      "archetype_id",
      "display_name",
      "total",
      "wins",
      "avg_duration",
      "weapon_damage",
      "spell_damage",
      "dot_damage",
      "pet_damage",
      "summon_damage",
      "system_damage",
      "total_damage",
      "dominant_source",
    ]),
  );
  await Deno.writeTextFile(
    new URL("battle_lab_near_power_matrix.csv", outputUrl),
    toCsv(result.near_power_matrix, [
      "player_archetype_id",
      "opponent_archetype_id",
      "total",
      "wins",
      "win_rate_percent",
      "avg_duration",
      "status",
    ]),
  );
  await Deno.writeTextFile(
    new URL("battle_lab_history_index.csv", outputUrl),
    toCsv(historyRowsForCsv(historyRows), [
      "run_id",
      "archived_at",
      "base_sha",
      "model_id",
      "seed",
      "hypothesis",
      "overall_status",
      "avg_duration",
      "median_duration",
      "short_rate_percent",
      "long_rate_percent",
      "anti_stall_rate_percent",
      "raw_stress_dominance_max_percent",
      "near_power_dominance_max_percent",
      "critical_archetypes",
      "compatibility_status",
      "simulator_hash",
      "content_hash",
      "model_hash",
      "files",
    ]),
  );
  await Deno.writeTextFile(
    new URL("battle_lab_compare.csv", outputUrl),
    toCsv(compareRows, [
      "metric",
      "baseline",
      "current",
      "delta",
    ]),
  );
  await Deno.writeTextFile(
    new URL("battle_lab_report.html", outputUrl),
    renderHtml(model, result, historyRows, compareRows),
  );
}

function buildRows(builds: LabBuild[]): Array<Record<string, unknown>> {
  return builds.map((build) => ({
    id: build.id,
    kind: build.kind,
    archetype_id: build.archetype_id,
    archetype_name: build.archetype_name,
    level: build.level,
    power: build.power,
    power_band: build.power_band,
    seed: build.seed,
    weapon_id: build.build.weaponId ?? "varinha_cinzas",
    spell_ids: build.build.spellIds.join("|"),
    passive_id: build.build.passiveId ?? "",
    pet_id: build.build.petId ?? "",
    weapon_level: build.build.weaponLevel,
    weapon_quality_tier: build.build.weaponQualityTier,
  }));
}

function matchupRows(matchups: LabMatchup[]): Array<Record<string, unknown>> {
  return matchups.map((matchup) => ({
    id: matchup.id,
    seed: matchup.seed,
    level: matchup.level,
    player_build_id: matchup.player_build_id,
    opponent_build_id: matchup.opponent_build_id,
    player_archetype_id: matchup.player_archetype_id,
    opponent_archetype_id: matchup.opponent_archetype_id,
    player_power: matchup.player_power,
    opponent_power: matchup.opponent_power,
    duration: matchup.duration,
    winner: matchup.winner_archetype_id,
    reason: matchup.reason,
    event_count: matchup.event_count,
    anti_stall: matchup.anti_stall,
    barrier_absorbed: matchup.barrier_absorbed,
    healing: matchup.healing,
    summons_created: matchup.summons_created,
    player_final_hp_percent: matchup.player_final_hp_percent,
    opponent_final_hp_percent: matchup.opponent_final_hp_percent,
    alerts: matchup.alerts.join("|"),
    damage_by_source: compactMap(matchup.damage_by_source),
    damage_by_type: compactMap(matchup.damage_by_type),
    player_damage_by_source: compactMap(matchup.player_damage_by_source),
    opponent_damage_by_source: compactMap(matchup.opponent_damage_by_source),
    player_damage_by_type: compactMap(matchup.player_damage_by_type),
    opponent_damage_by_type: compactMap(matchup.opponent_damage_by_type),
    spell_casts: compactMap(matchup.spell_casts),
  }));
}

function progressionMatrixRows(
  matchups: LabMatchup[],
): Array<Record<string, unknown>> {
  const buckets = new Map<
    string,
    { total: number; wins: number; durations: number[] }
  >();
  for (const matchup of matchups) {
    const player = progressionBuildInfo(
      matchup.player_build_id,
      matchup.player_archetype_id,
    );
    const opponent = progressionBuildInfo(
      matchup.opponent_build_id,
      matchup.opponent_archetype_id,
    );
    const category = progressionCategory(player.kind, opponent.kind);
    if (category === "") continue;

    const milestoneId = player.milestone_id !== ""
      ? player.milestone_id
      : opponent.milestone_id;
    const key = [
      category,
      milestoneId,
      player.label,
      opponent.label,
    ].join("::");
    const bucket = buckets.get(key) ?? { total: 0, wins: 0, durations: [] };
    bucket.total += 1;
    if (matchup.winner === "player") bucket.wins += 1;
    bucket.durations.push(matchup.duration);
    buckets.set(key, bucket);
  }

  return [...buckets.entries()].map(([key, bucket]) => {
    const [category, milestoneId, player, opponent] = key.split("::");
    const winRate = rate(bucket.wins, bucket.total);
    return {
      category,
      milestone_id: milestoneId,
      player,
      opponent,
      total: bucket.total,
      wins: bucket.wins,
      win_rate_percent: winRate,
      avg_duration: round(avg(bucket.durations), 2),
      status: winRate >= 35 && winRate <= 65 ? "PASS" : "REVIEW",
    };
  });
}

function progressionBuildInfo(buildId: string, archetypeId: string): {
  kind: "profile" | "bot" | "archetype";
  milestone_id: string;
  label: string;
} {
  if (buildId.startsWith("PLBOT_bot_")) {
    const parsed = parseProgressionId(buildId.slice("PLBOT_bot_".length));
    return {
      kind: "bot",
      milestone_id: parsed.milestone_id,
      label: `bot:${parsed.profile_id}:${parsed.milestone_id}`,
    };
  }
  if (buildId.startsWith("PL_")) {
    const parsed = parseProgressionId(buildId.slice("PL_".length));
    return {
      kind: "profile",
      milestone_id: parsed.milestone_id,
      label: `profile:${parsed.profile_id}:${parsed.milestone_id}`,
    };
  }
  return {
    kind: "archetype",
    milestone_id: "",
    label: `archetype:${archetypeId}`,
  };
}

function parseProgressionId(
  id: string,
): { profile_id: string; milestone_id: string } {
  for (const milestoneId of PROGRESSION_MILESTONE_IDS) {
    const middleToken = `_${milestoneId}_`;
    const middleIndex = id.indexOf(middleToken);
    if (middleIndex >= 0) {
      return {
        profile_id: id.slice(0, middleIndex),
        milestone_id: milestoneId,
      };
    }
    const endToken = `_${milestoneId}`;
    if (id.endsWith(endToken)) {
      return {
        profile_id: id.slice(0, -endToken.length),
        milestone_id: milestoneId,
      };
    }
  }
  return { profile_id: id, milestone_id: "" };
}

function progressionCategory(left: string, right: string): string {
  if (
    (left === "profile" && right === "bot") ||
    (left === "bot" && right === "profile")
  ) return "profile_vs_bot";
  if (left === "profile" && right === "profile") return "profile_vs_profile";
  if (
    (left === "profile" && right === "archetype") ||
    (left === "archetype" && right === "profile")
  ) return "profile_vs_archetype";
  return "";
}

function historyRowsForCsv(
  rows: RunManifest[],
): Array<Record<string, unknown>> {
  return rows.map((row) => ({
    ...row,
    compatibility_status: row.compatibility?.compatibility_status ?? "stale",
    simulator_hash: row.compatibility?.simulator_hash ?? "unknown",
    content_hash: row.compatibility?.content_hash ?? "unknown",
    model_hash: row.compatibility?.model_hash ?? "unknown",
  }));
}

function buildUiDocument(
  result: BattleLabResult,
  historyRows: RunManifest[],
  compareRows: CompareRow[],
  replaySamples: BattleReplaySample[],
): Record<string, unknown> {
  return {
    schema_version: "battle_lab_ui_v1",
    generated_at: result.generated_at,
    model_id: result.model_id,
    overall_status: result.overall_status,
    summary: result.summary,
    checks: result.checks,
    outliers: result.outliers.slice(0, 40),
    builds: result.builds.map((build) => ({
      id: build.id,
      kind: build.kind,
      archetype_id: build.archetype_id,
      archetype_name: build.archetype_name,
      level: build.level,
      power: build.power,
      power_band: build.power_band,
      build: build.build,
    })),
    near_power_archetypes: result.near_power_archetypes,
    near_power_matrix: result.near_power_matrix,
    source_by_archetype: result.source_by_archetype,
    history: historyRows.map((row) => ({
      run_id: row.run_id,
      archived_at: row.archived_at,
      overall_status: row.overall_status,
      avg_duration: row.avg_duration,
      short_rate_percent: row.short_rate_percent,
      long_rate_percent: row.long_rate_percent,
      anti_stall_rate_percent: row.anti_stall_rate_percent,
      near_power_dominance_max_percent: row.near_power_dominance_max_percent,
      compatibility_status: row.compatibility?.compatibility_status ?? "stale",
    })),
    compare: compareRows,
    replay_index: replaySamples.map((sample) => ({
      tag: sample.tag,
      matchup_id: sample.matchup_id,
      level: sample.level,
      player_build_id: sample.player_build_id,
      opponent_build_id: sample.opponent_build_id,
      player_archetype_id: sample.player_archetype_id,
      opponent_archetype_id: sample.opponent_archetype_id,
      duration: sample.duration,
      winner: sample.winner,
      reason: sample.reason,
    })),
  };
}

export function buildReplaySamples(
  model: BattleLabModel,
  result: BattleLabResult,
  maxSamples = 24,
): BattleReplaySample[] {
  const selected = new Map<string, string>();
  const representativeLevels = [...model.levels].sort((left, right) => {
    const leftSpellSlots = maxSpellSlots(left) > 0 ? 0 : 1;
    const rightSpellSlots = maxSpellSlots(right) > 0 ? 0 : 1;
    return leftSpellSlots - rightSpellSlots || left - right;
  });
  for (const level of representativeLevels) {
    if (selected.size >= maxSamples) break;
    const representative = representativeReplayForLevel(result.matchups, level);
    if (representative !== undefined) {
      selected.set(representative.id, `level_${level}_representative`);
    }
  }
  for (const outlier of result.outliers) {
    if (selected.size >= maxSamples) break;
    if (!selected.has(outlier.matchup_id)) {
      selected.set(outlier.matchup_id, outlier.type);
    }
  }

  const buildsById = new Map(result.builds.map((build) => [build.id, build]));
  const samples: BattleReplaySample[] = [];
  for (const [matchupId, tag] of selected.entries()) {
    const matchup = result.matchups.find((row) => row.id === matchupId);
    if (matchup === undefined) continue;
    const player = buildsById.get(matchup.player_build_id);
    const opponent = buildsById.get(matchup.opponent_build_id);
    if (player === undefined || opponent === undefined) continue;
    const simulation = simulateFirstSliceBattle({
      battleId: matchup.id,
      seed: matchup.seed,
      player: player.build,
      opponent: opponent.build,
    });
    samples.push({
      tag,
      matchup_id: matchup.id,
      seed: matchup.seed,
      level: matchup.level,
      player_build_id: matchup.player_build_id,
      opponent_build_id: matchup.opponent_build_id,
      player_archetype_id: matchup.player_archetype_id,
      opponent_archetype_id: matchup.opponent_archetype_id,
      player_power: matchup.player_power,
      opponent_power: matchup.opponent_power,
      duration: matchup.duration,
      winner: matchup.winner,
      reason: matchup.reason,
      battle_log: simulation.battleLog,
      rewards: simulation.reward,
    });
  }
  return samples;
}

function representativeReplayForLevel(
  matchups: LabMatchup[],
  level: number,
): LabMatchup | undefined {
  const candidates = matchups.filter((matchup) => matchup.level === level);
  return candidates.find((matchup) =>
    matchup.alerts.length === 0 && matchupHasSpellActivity(matchup) &&
    nonStarterMatchup(matchup)
  ) ??
    candidates.find((matchup) =>
      matchupHasSpellActivity(matchup) && nonStarterMatchup(matchup)
    ) ??
    candidates.find((matchup) =>
      matchup.alerts.length === 0 && matchupHasSpellActivity(matchup)
    ) ??
    candidates.find(matchupHasSpellActivity) ??
    candidates.find((matchup) => matchup.alerts.length === 0) ??
    candidates[0];
}

function matchupHasSpellActivity(matchup: LabMatchup): boolean {
  return Object.values(matchup.spell_casts).some((count) => count > 0);
}

function nonStarterMatchup(matchup: LabMatchup): boolean {
  return matchup.player_archetype_id !== "starter_instrument" &&
    matchup.opponent_archetype_id !== "starter_instrument";
}

function renderHtml(
  model: BattleLabModel,
  result: BattleLabResult,
  historyRows: RunManifest[] = [],
  compareRows: CompareRow[] = [],
): string {
  const statusClass = result.overall_status.toLowerCase();
  const outliers = result.outliers.slice(0, 80);
  const matrixRows = result.matrix
    .map((row) =>
      `<tr><td>${escapeHtml(row.player_archetype_id)}</td><td>${
        escapeHtml(row.opponent_archetype_id)
      }</td><td>${row.total}</td><td>${row.win_rate_percent}%</td><td>${row.avg_duration}s</td><td><span class="badge ${row.status.toLowerCase()}">${row.status}</span></td></tr>`
    )
    .join("\n");
  const nearPowerRows = result.near_power_archetypes
    .map((row) =>
      `<tr><td>${
        escapeHtml(row.display_name)
      }</td><td>${row.total}</td><td>${row.win_rate_percent}%</td><td>${row.avg_duration}s</td><td>${row.short_rate_percent}%</td><td>${row.long_rate_percent}%</td><td>${row.anti_stall_rate_percent}%</td><td><span class="badge ${row.status.toLowerCase()}">${row.status}</span></td></tr>`
    )
    .join("\n");
  const nearMatrixRows = result.near_power_matrix
    .map((row) =>
      `<tr><td>${escapeHtml(row.player_archetype_id)}</td><td>${
        escapeHtml(row.opponent_archetype_id)
      }</td><td>${row.total}</td><td>${row.win_rate_percent}%</td><td>${row.avg_duration}s</td><td><span class="badge ${row.status.toLowerCase()}">${row.status}</span></td></tr>`
    )
    .join("\n");
  const archetypeRows = result.archetypes
    .map((row) =>
      `<tr><td>${
        escapeHtml(row.display_name)
      }</td><td>${row.total}</td><td>${row.win_rate_percent}%</td><td>${row.avg_duration}s</td><td>${row.short_rate_percent}%</td><td>${row.long_rate_percent}%</td><td>${row.anti_stall_rate_percent}%</td><td><span class="badge ${row.status.toLowerCase()}">${row.status}</span></td></tr>`
    )
    .join("\n");
  const powerRows = result.power_bands
    .map((row) =>
      `<tr><td>${row.level}</td><td>${
        escapeHtml(row.power_band)
      }</td><td>${row.total}</td><td>${row.win_rate_percent}%</td><td>${row.avg_duration}s</td><td>${row.median_duration}s</td><td>${row.short_rate_percent}%</td><td>${row.long_rate_percent}%</td><td>${row.anti_stall_rate_percent}%</td><td><span class="badge ${row.status.toLowerCase()}">${row.status}</span></td></tr>`
    )
    .join("\n");
  const outlierRows = outliers
    .map((row) =>
      `<tr><td><span class="badge ${row.severity.toLowerCase()}">${row.severity}</span></td><td>${
        escapeHtml(row.type)
      }</td><td>${escapeHtml(row.matchup_id)}</td><td>${
        escapeHtml(row.level)
      }</td><td>${escapeHtml(row.power)}</td><td>${
        escapeHtml(row.duration)
      }</td><td>${escapeHtml(row.winner)}</td><td>${
        escapeHtml(row.player_build_id)
      }</td><td>${escapeHtml(row.opponent_build_id)}</td><td>${
        escapeHtml(row.reason)
      }</td></tr>`
    )
    .join("\n");
  const sourceRows = result.source_by_archetype
    .map((row) =>
      `<tr><td>${
        escapeHtml(row.display_name)
      }</td><td>${row.total}</td><td>${row.wins}</td><td>${row.avg_duration}s</td><td>${row.weapon_damage}</td><td>${row.spell_damage}</td><td>${row.dot_damage}</td><td>${row.pet_damage}</td><td>${row.summon_damage}</td><td>${row.system_damage}</td><td>${row.total_damage}</td><td>${
        escapeHtml(row.dominant_source)
      }</td></tr>`
    )
    .join("\n");
  const compareTableRows = compareRows
    .map((row) =>
      `<tr><td>${escapeHtml(row.metric)}</td><td>${
        escapeHtml(row.baseline)
      }</td><td>${escapeHtml(row.current)}</td><td>${
        escapeHtml(row.delta)
      }</td></tr>`
    )
    .join("\n");
  const historyTableRows = historyRows
    .map((row) =>
      `<tr><td>${escapeHtml(row.run_id)}</td><td>${
        escapeHtml(row.archived_at)
      }</td><td><span class="badge ${row.overall_status.toLowerCase()}">${row.overall_status}</span></td><td>${row.avg_duration}s</td><td>${row.short_rate_percent}%</td><td>${row.anti_stall_rate_percent}%</td><td>${row.raw_stress_dominance_max_percent}%</td><td>${row.near_power_dominance_max_percent}%</td><td>${
        escapeHtml(row.critical_archetypes.join("|"))
      }</td><td>${escapeHtml(row.hypothesis)}</td></tr>`
    )
    .join("\n");
  const checkRows = result.checks
    .map((row) =>
      `<tr><td><span class="badge ${row.status.toLowerCase()}">${row.status}</span></td><td>${
        escapeHtml(row.id)
      }</td><td>${escapeHtml(row.observed)}</td><td>${
        escapeHtml(row.target)
      }</td><td>${escapeHtml(row.note)}</td></tr>`
    )
    .join("\n");
  const notes = result.summary.top_notes.map((note) =>
    `<li>${escapeHtml(note)}</li>`
  ).join("\n");

  return `<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>DraxosMobile Battle Lab</title>
  <style>
    :root {
      color-scheme: light;
      --bg: #f6f7f9;
      --panel: #ffffff;
      --text: #181b20;
      --muted: #5b6472;
      --line: #d9dee7;
      --pass: #147a3f;
      --review: #9a6700;
      --critical: #b42318;
      --pass-bg: #dff7e9;
      --review-bg: #fff1c7;
      --critical-bg: #ffe1dd;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: "Segoe UI", Arial, sans-serif;
      background: var(--bg);
      color: var(--text);
      line-height: 1.35;
    }
    header {
      padding: 24px 28px 16px;
      border-bottom: 1px solid var(--line);
      background: var(--panel);
    }
    main { padding: 20px 28px 32px; }
    h1 { margin: 0 0 8px; font-size: 28px; letter-spacing: 0; }
    h2 { margin: 26px 0 10px; font-size: 18px; letter-spacing: 0; }
    p { margin: 0 0 8px; color: var(--muted); }
    .status-line { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; }
    .badge {
      display: inline-block;
      min-width: 64px;
      padding: 3px 8px;
      border-radius: 6px;
      text-align: center;
      font-weight: 700;
      font-size: 12px;
      border: 1px solid transparent;
    }
    .pass { color: var(--pass); background: var(--pass-bg); border-color: #a7dfbb; }
    .review { color: var(--review); background: var(--review-bg); border-color: #e5c96f; }
    .critical { color: var(--critical); background: var(--critical-bg); border-color: #f4aaa3; }
    .cards {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
      gap: 10px;
      margin: 16px 0 8px;
    }
    .card {
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: 8px;
      padding: 12px;
    }
    .card .label { color: var(--muted); font-size: 12px; }
    .card .value { font-size: 24px; font-weight: 700; margin-top: 2px; }
    .grid {
      display: grid;
      grid-template-columns: minmax(280px, 0.9fr) minmax(360px, 1.1fr);
      gap: 14px;
    }
    section {
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: 8px;
      padding: 14px;
      overflow: auto;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 13px;
    }
    th, td {
      padding: 7px 8px;
      border-bottom: 1px solid var(--line);
      text-align: left;
      white-space: nowrap;
    }
    th {
      color: var(--muted);
      font-weight: 700;
      background: #f1f3f6;
      position: sticky;
      top: 0;
    }
    ul { margin: 8px 0 0 18px; padding: 0; }
    li { margin: 4px 0; }
    .wide { margin-top: 14px; }
    @media (max-width: 920px) {
      main, header { padding-left: 16px; padding-right: 16px; }
      .grid { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
  <header>
    <div class="status-line">
      <h1>DraxosMobile Battle Lab</h1>
      <span class="badge ${statusClass}">${result.overall_status}</span>
    </div>
    <p>Model: ${escapeHtml(model.model_id)} | Status: ${
    escapeHtml(model.status)
  } | Generated: ${escapeHtml(result.generated_at)}</p>
    <p>Offline FIRST_SLICE_SIM analysis. This report does not mutate Supabase, rewards, ranking or client state.</p>
  </header>
  <main>
    <div class="cards">
      ${metricCard("Battles", result.summary.total_battles)}
      ${metricCard("Builds", result.summary.total_builds)}
      ${metricCard("Avg duration", `${result.summary.avg_duration}s`)}
      ${metricCard("Median", `${result.summary.median_duration}s`)}
      ${metricCard("Short", `${result.summary.short_rate_percent}%`)}
      ${metricCard("Long", `${result.summary.long_rate_percent}%`)}
      ${metricCard("Anti-stall", `${result.summary.anti_stall_rate_percent}%`)}
      ${
    metricCard(
      "Raw dominance",
      `${result.summary.raw_stress_dominance_max_percent}%`,
    )
  }
      ${
    metricCard(
      "Near power",
      `${result.summary.near_power_dominance_max_percent}%`,
    )
  }
    </div>

    <div class="grid">
      <section>
        <h2>O Que Olhar Primeiro</h2>
        <ul>${notes}</ul>
      </section>
      <section>
        <h2>Checks</h2>
        <table>
          <thead><tr><th>Status</th><th>Check</th><th>Observed</th><th>Target</th><th>Note</th></tr></thead>
          <tbody>${checkRows}</tbody>
        </table>
      </section>
    </div>

    <section class="wide">
      <h2>Near Power Archetypes</h2>
      <table>
        <thead><tr><th>Archetype</th><th>Total</th><th>Win rate</th><th>Avg duration</th><th>Short</th><th>Long</th><th>Anti-stall</th><th>Status</th></tr></thead>
        <tbody>${nearPowerRows}</tbody>
      </table>
    </section>

    <section class="wide">
      <h2>Raw Stress Archetypes</h2>
      <table>
        <thead><tr><th>Archetype</th><th>Total</th><th>Win rate</th><th>Avg duration</th><th>Short</th><th>Long</th><th>Anti-stall</th><th>Status</th></tr></thead>
        <tbody>${archetypeRows}</tbody>
      </table>
    </section>

    <section class="wide">
      <h2>Level And Power Bands</h2>
      <table>
        <thead><tr><th>Level</th><th>Power band</th><th>Total</th><th>Win rate</th><th>Avg</th><th>Median</th><th>Short</th><th>Long</th><th>Anti-stall</th><th>Status</th></tr></thead>
        <tbody>${powerRows}</tbody>
      </table>
    </section>

    <section class="wide">
      <h2>Near Power Matrix</h2>
      <table>
        <thead><tr><th>Player archetype</th><th>Opponent archetype</th><th>Total</th><th>Player win rate</th><th>Avg duration</th><th>Status</th></tr></thead>
        <tbody>${nearMatrixRows}</tbody>
      </table>
    </section>

    <section class="wide">
      <h2>Raw Stress Matrix</h2>
      <table>
        <thead><tr><th>Player archetype</th><th>Opponent archetype</th><th>Total</th><th>Player win rate</th><th>Avg duration</th><th>Status</th></tr></thead>
        <tbody>${matrixRows}</tbody>
      </table>
    </section>

    <section class="wide">
      <h2>Outliers</h2>
      <table>
        <thead><tr><th>Severity</th><th>Type</th><th>Matchup</th><th>Level</th><th>Power</th><th>Duration</th><th>Winner</th><th>Player build</th><th>Opponent build</th><th>Reason</th></tr></thead>
        <tbody>${outlierRows}</tbody>
      </table>
    </section>

    <section class="wide">
      <h2>Source By Archetype</h2>
      <table>
        <thead><tr><th>Archetype</th><th>Total</th><th>Wins</th><th>Avg</th><th>Weapon</th><th>Spell</th><th>DoT</th><th>Pet</th><th>Summon</th><th>System</th><th>Total damage</th><th>Dominant</th></tr></thead>
        <tbody>${sourceRows}</tbody>
      </table>
    </section>

    <section class="wide">
      <h2>Compare</h2>
      <table>
        <thead><tr><th>Metric</th><th>Baseline</th><th>Current</th><th>Delta</th></tr></thead>
        <tbody>${compareTableRows}</tbody>
      </table>
    </section>

    <section class="wide">
      <h2>Run History</h2>
      <table>
        <thead><tr><th>Run</th><th>Archived</th><th>Status</th><th>Avg</th><th>Short</th><th>Anti-stall</th><th>Raw dominance</th><th>Near dominance</th><th>Critical archetypes</th><th>Hypothesis</th></tr></thead>
        <tbody>${historyTableRows}</tbody>
      </table>
    </section>

    <section class="wide">
      <h2>Damage Breakdown</h2>
      <table>
        <thead><tr><th>Source</th><th>Damage</th></tr></thead>
        <tbody>${mapRows(result.summary.damage_by_source)}</tbody>
      </table>
      <h2>Damage Types</h2>
      <table>
        <thead><tr><th>Type</th><th>Damage</th></tr></thead>
        <tbody>${mapRows(result.summary.damage_by_type)}</tbody>
      </table>
    </section>
  </main>
</body>
</html>`;
}

function metricCard(label: string, value: string | number): string {
  return `<div class="card"><div class="label">${
    escapeHtml(label)
  }</div><div class="value">${escapeHtml(String(value))}</div></div>`;
}

function mapRows(map: NumericMap): string {
  return Object.entries(map)
    .map(([key, value]) =>
      `<tr><td>${escapeHtml(key)}</td><td>${round(value, 2)}</td></tr>`
    )
    .join("\n");
}

function buildTopNotes(checks: CheckRow[], outliers: OutlierRow[]): string[] {
  const notes: string[] = [];
  const failing = checks.filter((check) => check.status !== "PASS");
  for (const check of failing.slice(0, 4)) {
    notes.push(
      `${check.status}: ${check.id} observed ${check.observed}, target ${check.target}.`,
    );
  }
  const criticalOutlier = outliers.find((outlier) =>
    outlier.severity === "CRITICAL"
  );
  if (criticalOutlier !== undefined) {
    notes.push(
      `Critical outlier: ${criticalOutlier.type} on ${
        criticalOutlier.matchup_id || criticalOutlier.player_build_id
      }.`,
    );
  }
  const reviewOutlier = outliers.find((outlier) =>
    outlier.severity === "REVIEW"
  );
  if (reviewOutlier !== undefined) {
    notes.push(
      `Review first matchup: ${reviewOutlier.type} ${reviewOutlier.matchup_id} (${reviewOutlier.player_build_id} vs ${reviewOutlier.opponent_build_id}).`,
    );
  }
  if (notes.length === 0) {
    notes.push(
      "No review checks. Preserve this report as the current combat baseline before tuning.",
    );
  }
  return notes;
}

function selectSpells(
  archetype: ArchetypeModel,
  level: number,
  maxSlots: number,
  kind: BuildKind,
  rng: SeededRandom,
): string[] {
  if (maxSlots <= 0 || archetype.spell_preferences.length === 0) {
    return [];
  }
  const legal = allowedSpellIds(level);
  const preferred = archetype.spell_preferences.filter((spellId) =>
    legal.includes(spellId)
  );
  const candidates = kind === "fixed"
    ? preferred
    : shuffle(unique([...preferred, ...legal]), rng);
  const desiredCount = kind === "fixed" ? maxSlots : 1 + rng.nextInt(maxSlots);
  return candidates.slice(0, Math.min(maxSlots, desiredCount));
}

function selectOptional(
  preferred: string[],
  fallback: string[],
  unlocked: boolean,
  kind: BuildKind,
  rng: SeededRandom,
): string | undefined {
  if (!unlocked || preferred.length === 0) {
    return undefined;
  }
  if (kind === "fixed") {
    return preferred[0];
  }
  const candidates = shuffle(unique([...preferred, ...fallback]), rng);
  return candidates[0];
}

function scaledLevel(
  level: number,
  ratio: number,
  kind: BuildKind,
  rng: SeededRandom,
): number {
  if (ratio <= 0) {
    return 1;
  }
  const jitter = kind === "fixed" ? 0 : (rng.nextFloat() - 0.5) * 0.35;
  const finalRatio = clampNumber(ratio + jitter, 0.35, 1);
  return clamp(Math.round(level * finalRatio), 1, level);
}

function qualityTierForLevel(
  level: number,
  bias: number,
  kind: BuildKind,
  rng: SeededRandom,
): number {
  const base = level >= 35
    ? 4
    : level >= 25
    ? 3
    : level >= 14
    ? 2
    : level >= 5
    ? 1
    : 0;
  const jitter = kind === "fixed" ? 0 : rng.nextInt(3) - 1;
  return clamp(base + bias + jitter, 0, 4);
}

function maxSpellSlots(level: number): number {
  if (level >= 25) return 3;
  if (level >= 7) return 2;
  if (level >= 3) return 1;
  return 0;
}

function maxHpForLevel(level: number): number {
  const normalizedLevel = clamp(level, 1, 40);
  const baseHp = 100 + 8 * (normalizedLevel - 1);
  const paceMultiplier = COMBAT_PACE_HP_MULTIPLIER_BASE +
    COMBAT_PACE_HP_MULTIPLIER_PER_LEVEL * (normalizedLevel - 1);
  return Math.round(baseHp * paceMultiplier);
}

export function nearPowerMatchup(
  matchup: Pick<LabMatchup, "player_power" | "opponent_power">,
  maxDeltaPercent = NEAR_POWER_MAX_DELTA_PERCENT,
): boolean {
  const maxPower = Math.max(matchup.player_power, matchup.opponent_power);
  if (maxPower <= 0) {
    return true;
  }
  const delta = Math.abs(matchup.player_power - matchup.opponent_power);
  return delta <= maxPower * (maxDeltaPercent / 100);
}

function sameArchetypeMatchup(matchup: LabMatchup): boolean {
  return matchup.player_archetype_id === matchup.opponent_archetype_id;
}

function damageSourceForEvent(eventType: string): string {
  switch (eventType) {
    case "weapon_attack":
      return "weapon";
    case "spell_cast":
      return "spell";
    case "dot_tick":
      return "dot";
    case "pet_attack":
      return "pet";
    case "summon_attack":
      return "summon";
    case "anti_stall":
      return "system";
    default:
      return "";
  }
}

function damageSideForEvent(event: BattleEvent): BattleSide | "" {
  const source = stringValue(event.source);
  if (source === "player" || source === "opponent") {
    return source;
  }
  const target = stringValue(event.target);
  if (target === "player") {
    return "opponent";
  }
  if (target === "opponent") {
    return "player";
  }
  return "";
}

function statusForWinRate(model: BattleLabModel, winRate: number): Status {
  if (winRate > model.thresholds.dominance_critical_percent) {
    return "CRITICAL";
  }
  if (
    winRate > model.thresholds.dominance_review_percent ||
    winRate < 100 - model.thresholds.dominance_review_percent
  ) {
    return "REVIEW";
  }
  return "PASS";
}

function emptyDamageSourceMap(): NumericMap {
  return Object.fromEntries(DAMAGE_SOURCE_KEYS.map((key) => [key, 0]));
}

function emptyDamageTypeMap(): NumericMap {
  return Object.fromEntries(DAMAGE_TYPE_KEYS.map((key) => [key, 0]));
}

function sumMaps(maps: NumericMap[], keys: string[]): NumericMap {
  const output = Object.fromEntries(keys.map((key) => [key, 0])) as NumericMap;
  for (const map of maps) {
    addMap(output, map);
  }
  return output;
}

function addMap(target: NumericMap, source: NumericMap): void {
  for (const [key, value] of Object.entries(source)) {
    target[key] = (target[key] ?? 0) + value;
  }
}

function maxAggregateWinRate(rows: AggregateRow[]): number {
  return rows.length === 0
    ? 0
    : Math.max(...rows.map((row) => row.win_rate_percent));
}

function minAggregateWinRate(rows: AggregateRow[]): number {
  return rows.length === 0
    ? 0
    : Math.min(...rows.map((row) => row.win_rate_percent));
}

function compareText(
  metric: string,
  baseline: string,
  current: string,
): CompareRow {
  return {
    metric,
    baseline,
    current,
    delta: baseline === current ? "unchanged" : "changed",
  };
}

function compareNumber(
  metric: string,
  baseline: number,
  current: number,
  suffix = "",
): CompareRow {
  const delta = round(current - baseline, 2);
  const sign = delta > 0 ? "+" : "";
  return {
    metric,
    baseline: `${round(baseline, 2)}${suffix}`,
    current: `${round(current, 2)}${suffix}`,
    delta: `${sign}${delta}${suffix}`,
  };
}

function validateBridgeBuild(
  value: unknown,
  fieldName: string,
): CombatantBuild {
  if (value === null || typeof value !== "object" || Array.isArray(value)) {
    throw new Error(`${fieldName} must be an object`);
  }
  const build = value as CombatantBuild;
  const errors: string[] = [];
  const level = numberValue(build.level, 0);
  const weaponId = stringValue(build.weaponId, "varinha_cinzas");
  const weaponLevel = numberValue(build.weaponLevel, 0);
  const weaponQualityTier = numberValue(build.weaponQualityTier, -1);
  if (stringValue(build.id) === "") errors.push("id is required");
  if (stringValue(build.displayName) === "") {
    errors.push("displayName is required");
  }
  if (level < 1 || level > 40) errors.push("level must be 1-40");
  if (!WEAPON_IDS.includes(weaponId)) {
    errors.push(`unknown weapon ${weaponId}`);
  }
  if (weaponLevel < 1 || weaponLevel > level) {
    errors.push("weaponLevel must be 1..level");
  }
  if (weaponQualityTier < 0 || weaponQualityTier > 4) {
    errors.push("weaponQualityTier must be 0-4");
  }
  if (!Array.isArray(build.spellIds)) {
    errors.push("spellIds must be an array");
  } else {
    const allowed = allowedSpellIds(level);
    const uniqueSpells = unique(
      build.spellIds.map((spellId) => String(spellId)),
    );
    if (uniqueSpells.length !== build.spellIds.length) {
      errors.push("spellIds must not include duplicates");
    }
    if (build.spellIds.length > maxSpellSlots(level)) {
      errors.push("spellIds exceeds unlocked slots");
    }
    for (const spellId of build.spellIds) {
      if (!allowed.includes(String(spellId))) {
        errors.push(`spell ${spellId} is locked at level ${level}`);
      }
      const spellLevel = numberValue(build.spellLevels?.[spellId], 0);
      if (spellLevel < 1 || spellLevel > level) {
        errors.push(`spell ${spellId} level must be 1..level`);
      }
    }
  }
  if (build.passiveId !== undefined) {
    if (level < 10) errors.push("passive is locked before level 10");
    if (!PASSIVE_IDS.includes(String(build.passiveId))) {
      errors.push(`unknown passive ${build.passiveId}`);
    }
    const passiveLevel = numberValue(build.passiveLevel, 0);
    if (passiveLevel < 1 || passiveLevel > level) {
      errors.push("passiveLevel must be 1..level");
    }
  }
  if (build.petId !== undefined) {
    if (level < 15) errors.push("pet is locked before level 15");
    if (!PET_IDS.includes(String(build.petId))) {
      errors.push(`unknown pet ${build.petId}`);
    }
    const petLevel = numberValue(build.petLevel, 0);
    if (petLevel < 1 || petLevel > level) {
      errors.push("petLevel must be 1..level");
    }
  }
  if (errors.length > 0) {
    throw new Error(`${fieldName} invalid: ${errors.join("; ")}`);
  }
  return {
    id: String(build.id),
    displayName: String(build.displayName),
    level,
    weaponId,
    weaponLevel,
    weaponQualityTier,
    spellIds: build.spellIds.map((spellId) => String(spellId)),
    spellLevels: Object.fromEntries(
      build.spellIds.map((spellId) => [
        String(spellId),
        numberValue(build.spellLevels?.[spellId], level),
      ]),
    ),
    passiveId: build.passiveId === undefined
      ? undefined
      : String(build.passiveId),
    passiveLevel: build.passiveId === undefined
      ? undefined
      : numberValue(build.passiveLevel, level),
    petId: build.petId === undefined ? undefined : String(build.petId),
    petLevel: build.petId === undefined
      ? undefined
      : numberValue(build.petLevel, level),
  };
}

function customLabBuild(
  model: BattleLabModel,
  build: CombatantBuild,
  fallbackId: string,
): LabBuild {
  const power = calculatePower(build);
  return {
    id: build.id || fallbackId,
    kind: "fixed",
    archetype_id: "custom",
    archetype_name: "Custom",
    level: build.level,
    power,
    power_band: classifyPowerBand(power, model.power_bands),
    seed: `custom:${build.id || fallbackId}`,
    build,
  };
}

async function buildCompatibilitySnapshot(
  projectRoot: URL,
  model: BattleLabModel,
): Promise<CompatibilitySnapshot> {
  return {
    simulator_hash: shortHash(
      await readTextIfExists(
        new URL("server/functions/_shared/battle_simulator.ts", projectRoot),
      ),
    ),
    content_hash: shortHash(await readDefinitionsDigest(projectRoot)),
    model_hash: shortHash(JSON.stringify(model)),
    battle_log_schema: "battle_log_v1",
    compatibility_status: "current",
  };
}

async function readDefinitionsDigest(projectRoot: URL): Promise<string> {
  const definitionsUrl = new URL("data/definitions/", projectRoot);
  const chunks: string[] = [];
  for await (const entry of Deno.readDir(definitionsUrl)) {
    if (entry.isFile && entry.name.endsWith(".json")) {
      const fileUrl = new URL(entry.name, definitionsUrl);
      chunks.push(`${entry.name}:${await Deno.readTextFile(fileUrl)}`);
    }
  }
  return chunks.sort().join("\n");
}

async function readTextIfExists(url: URL): Promise<string> {
  try {
    return await Deno.readTextFile(url);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return "";
    throw error;
  }
}

function shortHash(value: string): string {
  return hashString(value).toString(16).padStart(8, "0");
}

function sanitizeRunId(value: string): string {
  return value.replace(/[^a-zA-Z0-9_.-]/g, "_").slice(0, 96) || "run";
}

function fileUrlFromPath(path: string): URL {
  if (path.startsWith("file:")) {
    return new URL(path);
  }
  const normalized = path.replaceAll("\\", "/");
  if (/^[a-zA-Z]:\//.test(normalized)) {
    return new URL(`file:///${normalized}`);
  }
  return new URL(
    normalized,
    new URL(`${Deno.cwd().replaceAll("\\", "/")}/`, "file:///"),
  );
}

function localPathFromUrl(url: URL): string {
  const path = decodeURIComponent(url.pathname);
  return /^\/[a-zA-Z]:\//.test(path) ? path.slice(1) : path;
}

async function readGitHead(projectRoot: URL): Promise<string> {
  let current = projectRoot;
  for (let depth = 0; depth < 8; depth += 1) {
    try {
      const head = (await Deno.readTextFile(new URL(".git/HEAD", current)))
        .trim();
      if (!head.startsWith("ref: ")) {
        return head.slice(0, 12);
      }
      const refPath = head.slice(5);
      const sha = (await Deno.readTextFile(new URL(`.git/${refPath}`, current)))
        .trim();
      return sha.slice(0, 12);
    } catch (error) {
      if (!(error instanceof Deno.errors.NotFound)) {
        return "unknown";
      }
      const parent = new URL("../", current);
      if (parent.href === current.href) {
        break;
      }
      current = parent;
    }
  }
  return "unknown";
}

function hypothesisForRunId(runId: string): string {
  if (runId.includes("pacing_alpha_v01")) {
    return "Baseline apos pacing alpha global de HP e antes do ajuste por fonte.";
  }
  if (runId.includes("archetype_source_tuning_v02")) {
    return "Ajuste por arquetipo/fonte: reduzir burst/pet e medir dominancia por poder proximo.";
  }
  return runId.replaceAll("_", " ");
}

function toCsv<T extends object>(rows: T[], headers: string[]): string {
  return [
    headers.join(","),
    ...rows.map((row) => {
      const record = row as Record<string, unknown>;
      return headers.map((header) => csvEscape(record[header])).join(",");
    }),
  ].join("\n") + "\n";
}

function csvEscape(value: unknown): string {
  if (value === null || value === undefined) return "";
  const text = typeof value === "string" ? value : JSON.stringify(value);
  if (/[",\r\n]/.test(text)) {
    return `"${text.replaceAll('"', '""')}"`;
  }
  return text;
}

function compactMap(map: NumericMap): string {
  return Object.entries(map)
    .filter(([, value]) => value !== 0)
    .map(([key, value]) => `${key}:${round(value, 2)}`)
    .join("|");
}

function groupBy<T>(
  items: T[],
  keyFn: (item: T) => string,
): Record<string, T[]> {
  const groups: Record<string, T[]> = {};
  for (const item of items) {
    const key = keyFn(item);
    groups[key] ??= [];
    groups[key].push(item);
  }
  return groups;
}

function unique(values: string[]): string[] {
  return [...new Set(values)];
}

function shuffle(values: string[], rng: SeededRandom): string[] {
  const copy = [...values];
  for (let index = copy.length - 1; index > 0; index -= 1) {
    const swapIndex = rng.nextInt(index + 1);
    [copy[index], copy[swapIndex]] = [copy[swapIndex], copy[index]];
  }
  return copy;
}

function avg(values: number[]): number {
  if (values.length === 0) return 0;
  return values.reduce((sum, value) => sum + value, 0) / values.length;
}

function median(values: number[]): number {
  if (values.length === 0) return 0;
  const sorted = [...values].sort((left, right) => left - right);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 0
    ? (sorted[middle - 1] + sorted[middle]) / 2
    : sorted[middle];
}

function rate(count: number, total: number): number {
  return total <= 0 ? 0 : round((count / total) * 100, 2);
}

function percent(value: number, total: number): number {
  return total <= 0 ? 0 : (value / total) * 100;
}

function round(value: number, digits = 2): number {
  const scale = 10 ** digits;
  return Math.round(value * scale) / scale;
}

function roundMap(map: NumericMap): NumericMap {
  return Object.fromEntries(
    Object.entries(map).map(([key, value]) => [key, round(value, 2)]),
  );
}

function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, Math.trunc(value)));
}

function clampNumber(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

function numberValue(value: unknown, fallback: number): number {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

function stringValue(value: unknown, fallback = ""): string {
  return typeof value === "string" ? value : fallback;
}

function maxStatus(statuses: Status[]): Status {
  return statuses.reduce(
    (current, next) => statusRank(next) > statusRank(current) ? next : current,
    "PASS" as Status,
  );
}

function statusRank(status: Status): number {
  if (status === "CRITICAL") return 2;
  if (status === "REVIEW") return 1;
  return 0;
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

class SeededRandom {
  private state: number;

  constructor(seed: string) {
    this.state = hashString(seed);
  }

  nextFloat(): number {
    this.state = (1664525 * this.state + 1013904223) >>> 0;
    return this.state / 0x100000000;
  }

  nextInt(maxExclusive: number): number {
    return Math.floor(this.nextFloat() * maxExclusive);
  }
}

function hashString(seed: string): number {
  let hash = 2166136261;
  for (let index = 0; index < seed.length; index += 1) {
    hash ^= seed.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }
  return hash >>> 0;
}

if (import.meta.main) {
  await main();
}
