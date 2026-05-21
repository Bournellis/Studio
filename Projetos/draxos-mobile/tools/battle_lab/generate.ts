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

interface BattleLabResult {
  model_id: string;
  generated_at: string;
  overall_status: Status;
  builds: LabBuild[];
  matchups: LabMatchup[];
  archetypes: AggregateRow[];
  matrix: MatrixRow[];
  power_bands: PowerBandRow[];
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
    damage_by_source: NumericMap;
    damage_by_type: NumericMap;
    top_notes: string[];
  };
}

type NumericMap = Record<string, number>;

const SPELL_UNLOCKS: Record<string, number> = {
  raio_cosmico: 3,
  raio: 7,
  acender: 7,
  envenenar: 7,
  congelar: 7,
  odio: 25,
  dilacerar: 25,
  fortificar: 25,
  invocar_demonio: 25,
  animar_morto: 25,
};

const PASSIVE_IDS = [
  "foco_astral",
  "forca",
  "resistencia",
  "escudo",
  "vampirismo",
  "velocidade",
];
const PET_IDS = ["familiar_cinzento", "brasido", "gelum"];
const DAMAGE_SOURCE_KEYS = [
  "weapon",
  "spell",
  "dot",
  "pet",
  "summon",
  "system",
];
const DAMAGE_TYPE_KEYS = [
  "magico",
  "fogo",
  "gelo",
  "veneno",
  "choque",
  "morte",
  "sangramento",
  "none",
];

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
  return builds;
}

export function calculatePower(build: CombatantBuild): number {
  const spellLevelsTotal = Object.values(build.spellLevels).reduce(
    (sum, level) => sum + level,
    0,
  );
  return (build.level * 50) +
    (build.weaponLevel * 30) +
    (spellLevelsTotal * 20) +
    ((build.petLevel ?? 0) * 15) +
    ((build.passiveLevel ?? 0) * 10) +
    (build.weaponQualityTier * 25);
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
  const model = await loadModel();
  const result = runBattleLab(model);
  const projectRoot = new URL("../../", import.meta.url);
  const outputUrl = new URL(
    `${model.output_dir.replace(/\/$/, "")}/`,
    projectRoot,
  );
  await writeOutputs(model, result, outputUrl);

  const reviewCount =
    result.checks.filter((check) => check.status !== "PASS").length;
  console.log("[battle-lab] generated", {
    status: result.overall_status,
    battles: result.summary.total_battles,
    builds: result.summary.total_builds,
    review_checks: reviewCount,
    report: new URL("battle_lab_report.html", outputUrl).pathname,
  });
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
  const archetypes = aggregateArchetypes(model, matchups);
  const matrix = aggregateMatrix(model, matchups);
  const powerBands = aggregatePowerBands(model, matchups);
  const outliers = buildOutliers(model, matchups, archetypes);
  const checks = buildChecks(
    model,
    matchups,
    archetypes,
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
    matrix,
    power_bands: powerBands,
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

function aggregateMatrix(
  model: BattleLabModel,
  matchups: LabMatchup[],
): MatrixRow[] {
  const rows: MatrixRow[] = [];
  for (const player of model.archetypes) {
    for (const opponent of model.archetypes) {
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

function buildOutliers(
  model: BattleLabModel,
  matchups: LabMatchup[],
  archetypes: AggregateRow[],
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
        type: "DOMINANCE",
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

  return rows.sort((left, right) =>
    statusRank(right.severity) - statusRank(left.severity)
  );
}

function buildChecks(
  model: BattleLabModel,
  matchups: LabMatchup[],
  archetypes: AggregateRow[],
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
  const maxWinRate = Math.max(...archetypes.map((row) => row.win_rate_percent));
  const minWinRate = Math.min(...archetypes.map((row) => row.win_rate_percent));
  const levelsCovered = new Set(matchups.map((matchup) => matchup.level)).size;
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
      id: "archetype_dominance",
      status: maxWinRate > model.thresholds.dominance_critical_percent
        ? "CRITICAL"
        : maxWinRate > model.thresholds.dominance_review_percent
        ? "REVIEW"
        : "PASS",
      observed: `${maxWinRate}% max / ${minWinRate}% min`,
      target: `max <= ${model.thresholds.dominance_review_percent}%`,
      note:
        "A dominant archetype should be reviewed before changing global numbers.",
    },
    {
      id: "level_coverage",
      status: levelsCovered === expectedLevels ? "PASS" : "CRITICAL",
      observed: `${levelsCovered}/${expectedLevels}`,
      target: `${expectedLevels}/${expectedLevels}`,
      note: "Every configured level checkpoint should produce matchups.",
    },
  ];
}

async function writeOutputs(
  model: BattleLabModel,
  result: BattleLabResult,
  outputUrl: URL,
): Promise<void> {
  await Deno.mkdir(outputUrl, { recursive: true });
  await Deno.writeTextFile(
    new URL("battle_lab_summary.json", outputUrl),
    JSON.stringify(result, null, 2) + "\n",
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
      "spell_casts",
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
    new URL("battle_lab_report.html", outputUrl),
    renderHtml(model, result),
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
    spell_casts: compactMap(matchup.spell_casts),
  }));
}

function renderHtml(model: BattleLabModel, result: BattleLabResult): string {
  const statusClass = result.overall_status.toLowerCase();
  const outliers = result.outliers.slice(0, 80);
  const matrixRows = result.matrix
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
      <h2>Archetypes</h2>
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
      <h2>Archetype Matrix</h2>
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
  return Math.round(100 + 8 * (level - 1));
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
    for (const [key, value] of Object.entries(map)) {
      output[key] = (output[key] ?? 0) + value;
    }
  }
  return output;
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
