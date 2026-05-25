type Status = "PASS" | "REVIEW" | "CRITICAL";
type ResourceKey =
  | "xp"
  | "almas"
  | "energia"
  | "sangue"
  | "cristais"
  | "ossos"
  | "diamante";

type ResourceVector = Record<ResourceKey, number>;

interface ProgressionModel {
  schema_version: number;
  model_id: string;
  status: string;
  output_dir: string;
  scratch_dir: string;
  seed: string;
  cap: number;
  milestones: Milestone[];
  profiles: Profile[];
  source_values: Record<string, Partial<ResourceVector>>;
  costs: CostModel;
  power_weights: PowerWeights;
  thresholds: Thresholds;
  bot_archetypes: string[];
}

interface Milestone {
  id: string;
  hours: number;
  target_level_min: number;
  target_level_max: number;
}

interface Profile {
  id: string;
  display_name: string;
  description: string;
  reward_completion: number;
  battle_pass_completion: number;
  battles_per_hour: number;
  checkins_per_hour: number;
  premium_pass: boolean;
  second_construction_queue: boolean;
  store_pack_intensity: number;
  speedup_multiplier: number;
  build_ratio: number;
  base_ratio: number;
}

interface CostCurve {
  min: number;
  coefficient: number;
}

interface CostModel {
  weapon_almas: CostCurve;
  spell_almas: CostCurve;
  pet_sangue: CostCurve;
  passive_cristais: CostCurve;
  base_structure_energia: CostCurve;
  weapon_quality_thresholds: number[];
}

interface PowerWeights {
  level: number;
  weapon_level: number;
  spell_level: number;
  pet_level: number;
  passive_level: number;
  weapon_quality_tier: number;
  base_stats_level: number;
  base_average_level: number;
}

interface Thresholds {
  premium_power_gap_review_percent: number;
  premium_power_gap_critical_percent: number;
  negative_resource_review: number;
  negative_resource_critical: number;
  bot_power_offsets_percent: number[];
}

interface HealthySave {
  id: string;
  profile_id: string;
  profile_name: string;
  milestone_id: string;
  hours: number;
  status: Status;
  notes: string[];
  player: {
    username: string;
    account_type: "progression_lab";
    level: number;
    xp: number;
    power: number;
  };
  resources: ResourceVector;
  resource_debt: ResourceVector;
  build: BuildState;
  base: {
    construction_slots: number;
    structures: BaseStructureState[];
    active_job: ConstructionJobState | null;
  };
  monetization: {
    premium_pass: boolean;
    battle_pass_xp: number;
    premium_unlocked: boolean;
    simulated_store_spend: number;
  };
  combat_build: CombatBuild;
  manual_checklist: string[];
}

interface BuildState {
  archetype_id: string;
  weapon_type: string;
  weapon_quality: string;
  weapon_quality_tier: number;
  weapon_level: number;
  spell_slots: string[];
  spells_unlocked: string[];
  spell_levels: Record<string, number>;
  passive_id: string;
  passive_level: number;
  pet_id: string;
  pet_level: number;
}

interface CombatBuild {
  id: string;
  displayName: string;
  level: number;
  weaponId?: string;
  weaponLevel: number;
  weaponQualityTier: number;
  spellIds: string[];
  spellLevels: Record<string, number>;
  passiveId?: string;
  passiveLevel?: number;
  petId?: string;
  petLevel?: number;
}

interface BaseStructureState {
  structure_id: string;
  level: number;
  produces: ResourceKey | "";
}

interface ConstructionJobState {
  structure_id: string;
  target_level: number;
  remaining_minutes: number;
}

interface ProgressionData {
  schema_version: number;
  model_id: string;
  status: Status;
  saves: HealthySave[];
  reward_checks: CheckRow[];
  premium_gap: PremiumGapRow[];
  power_recommendations: PowerRecommendationRow[];
  bot_pool: BotRow[];
}

interface CheckRow {
  id: string;
  profile_id: string;
  milestone_id: string;
  status: Status;
  observed: string;
  target: string;
  note: string;
}

interface PremiumGapRow {
  milestone_id: string;
  profile_id: string;
  compared_to: string;
  power_gap_percent: number;
  level_gap: number;
  premium_spend: number;
  status: Status;
}

interface PowerRecommendationRow {
  component: string;
  current_weight: number;
  observed_share_percent: number;
  recommendation: string;
  status: Status;
}

interface BotRow {
  id: string;
  milestone_id: string;
  profile_id: string;
  archetype_id: string;
  target_power: number;
  power_band: string;
  level: number;
  build: CombatBuild;
}

const RESOURCE_KEYS: ResourceKey[] = [
  "xp",
  "almas",
  "energia",
  "sangue",
  "cristais",
  "ossos",
  "diamante",
];

const BASE_STRUCTURES: Array<
  { id: string; produces: ResourceKey | ""; bias: number }
> = [
  { id: "nucleo_energia", produces: "energia", bias: 1.1 },
  { id: "altar_das_almas", produces: "almas", bias: 1.0 },
  { id: "pocos_sangue", produces: "sangue", bias: 0.82 },
  { id: "minas_cristal", produces: "cristais", bias: 0.74 },
  { id: "ossario", produces: "ossos", bias: 0.68 },
  { id: "estrutura_stats", produces: "", bias: 0.58 },
];

const QUALITY_NAMES = ["starter", "reforcada", "ritual", "abissal", "cosmica"];

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

const ARCHETYPE_SPELLS: Record<string, string[]> = {
  starter_instrument: [],
  mental_controller: ["sussurro_medo", "terror_primordial"],
  elemental_mixer: ["descarga_nervosa", "marca_brasa", "geada_ossos"],
  familiar_handler: ["sussurro_medo", "marca_brasa", "descarga_nervosa"],
  summoner: ["sussurro_medo", "erguer_ossos", "invocar_brasa_faminta"],
  defensive_occultist: ["coagulo_negro", "raizes_pedra", "geada_ossos"],
  dot_pressure: ["toxina_palida", "marca_brasa", "hemorragia_induzida"],
  funeral_burst: ["marca_sepulcral", "coroa_cinzas", "descarga_nervosa"],
};

const ARCHETYPE_PASSIVE: Record<string, string> = {
  starter_instrument: "",
  mental_controller: "doutrina_pavor",
  elemental_mixer: "pulso_tempestade",
  familiar_handler: "pacto_familiar",
  summoner: "ossuario_interior",
  defensive_occultist: "pedra_interna",
  dot_pressure: "alquimia_toxica",
  funeral_burst: "ossuario_interior",
};

const ARCHETYPE_PET: Record<string, string> = {
  starter_instrument: "",
  mental_controller: "corvo_pressagio",
  elemental_mixer: "serpe_tempestade",
  familiar_handler: "corvo_pressagio",
  summoner: "cranio_errante",
  defensive_occultist: "escaravelho_pedra",
  dot_pressure: "serpente_toxina",
  funeral_burst: "cranio_errante",
};

const ARCHETYPE_WEAPON: Record<string, string> = {
  starter_instrument: "varinha_cinzas",
  mental_controller: "grimorio_veu",
  elemental_mixer: "orbe_tempestade",
  familiar_handler: "varinha_cinzas",
  summoner: "cajado_ossario",
  defensive_occultist: "idolo_pedra_viva",
  dot_pressure: "athame_hematico",
  funeral_burst: "cajado_ossario",
};

export async function loadModel(
  modelUrl = new URL("model.v1.json", import.meta.url),
): Promise<ProgressionModel> {
  return JSON.parse(await Deno.readTextFile(modelUrl)) as ProgressionModel;
}

export function buildProgressionData(model: ProgressionModel): ProgressionData {
  const saves = buildHealthySaves(model);
  const rewardChecks = buildRewardChecks(model, saves);
  const premiumGap = buildPremiumGap(model, saves);
  const powerRecommendations = buildPowerRecommendations(model, saves);
  const botPool = buildBotPool(model, saves);
  const statuses = [
    ...saves.map((save) => save.status),
    ...rewardChecks.map((check) => check.status),
    ...premiumGap.map((gap) => gap.status),
    ...powerRecommendations.map((row) => row.status),
  ];
  return {
    schema_version: 1,
    model_id: model.model_id,
    status: worstStatus(statuses),
    saves,
    reward_checks: rewardChecks,
    premium_gap: premiumGap,
    power_recommendations: powerRecommendations,
    bot_pool: botPool,
  };
}

export async function writeProgressionOutputs(
  model: ProgressionModel,
  data: ProgressionData,
  projectRoot = new URL("../../", import.meta.url),
): Promise<void> {
  const outputUrl = new URL(
    `${model.output_dir.replace(/\/$/, "")}/`,
    projectRoot,
  );
  await Deno.mkdir(outputUrl, { recursive: true });
  await Deno.writeTextFile(
    new URL("progression_summary.json", outputUrl),
    JSON.stringify(data, null, 2) + "\n",
  );
  await Deno.writeTextFile(
    new URL("healthy_saves.json", outputUrl),
    JSON.stringify(
      {
        schema_version: 1,
        model_id: model.model_id,
        saves: data.saves,
      },
      null,
      2,
    ) + "\n",
  );
  await Deno.writeTextFile(
    new URL("milestone_profiles.csv", outputUrl),
    toCsv(data.saves.map(saveRow), [
      "id",
      "profile_id",
      "milestone_id",
      "hours",
      "status",
      "level",
      "xp",
      "power",
      "almas",
      "energia",
      "sangue",
      "cristais",
      "ossos",
      "diamante",
      "weapon_level",
      "weapon_quality_tier",
      "spells",
      "base_average_level",
    ]),
  );
  await Deno.writeTextFile(
    new URL("reward_scaling_checks.csv", outputUrl),
    toCsv(data.reward_checks, [
      "id",
      "profile_id",
      "milestone_id",
      "status",
      "observed",
      "target",
      "note",
    ]),
  );
  await Deno.writeTextFile(
    new URL("premium_gap.csv", outputUrl),
    toCsv(data.premium_gap, [
      "milestone_id",
      "profile_id",
      "compared_to",
      "power_gap_percent",
      "level_gap",
      "premium_spend",
      "status",
    ]),
  );
  await Deno.writeTextFile(
    new URL("power_recommendations.csv", outputUrl),
    toCsv(data.power_recommendations, [
      "component",
      "current_weight",
      "observed_share_percent",
      "recommendation",
      "status",
    ]),
  );
  await Deno.writeTextFile(
    new URL("bot_pool.csv", outputUrl),
    toCsv(data.bot_pool.map(botRow), [
      "id",
      "milestone_id",
      "profile_id",
      "archetype_id",
      "target_power",
      "power_band",
      "level",
      "spell_ids",
      "passive_id",
      "pet_id",
    ]),
  );
  await Deno.writeTextFile(
    new URL("progression_report.html", outputUrl),
    reportHtml(model, data),
  );
}

export function buildHealthySaves(model: ProgressionModel): HealthySave[] {
  const saves: HealthySave[] = [];
  for (const profile of model.profiles) {
    for (const milestone of model.milestones) {
      saves.push(buildHealthySave(model, profile, milestone));
    }
  }
  return saves;
}

export function buildHealthySave(
  model: ProgressionModel,
  profile: Profile,
  milestone: Milestone,
): HealthySave {
  const gains = estimateGains(model, profile, milestone);
  const level = levelFromXp(gains.xp, model.cap);
  const archetypeId = archetypeForLevel(level, profile);
  const build = buildStateFor(model, profile, archetypeId, level, gains);
  const base = baseStateFor(model, profile, level, milestone, gains.energia);
  const spend = estimateSpend(model, build, base.structures);
  const resources = subtractResources(gains, spend);
  const simulatedStoreSpend = Math.max(
    0,
    -(model.source_values.store_pack_hour?.diamante ?? 0) * milestone.hours *
      profile.store_pack_intensity,
  );
  resources.diamante = Math.max(0, resources.diamante);
  const debt = resourceDebt(resources);
  const normalizedResources = clampResources(resources);
  const combatBuild = combatBuildFor(
    `${profile.id}_${milestone.id}`,
    build,
    level,
  );
  const power = calculatePower(
    model.power_weights,
    build,
    base.structures,
    level,
  );
  const notes = saveNotes(model, milestone, level, debt, power, profile);
  const status = statusForSave(model, milestone, level, debt);
  return {
    id: `${profile.id}_${milestone.id}`,
    profile_id: profile.id,
    profile_name: profile.display_name,
    milestone_id: milestone.id,
    hours: milestone.hours,
    status,
    notes,
    player: {
      username: `plab_${profile.id}_${milestone.id}`,
      account_type: "progression_lab",
      level,
      xp: Math.round(gains.xp),
      power,
    },
    resources: normalizedResources,
    resource_debt: debt,
    build,
    base,
    monetization: {
      premium_pass: profile.premium_pass,
      battle_pass_xp: Math.round(
        milestone.hours * 65 * profile.battle_pass_completion *
          (profile.premium_pass ? 1.35 : 1),
      ),
      premium_unlocked: profile.premium_pass,
      simulated_store_spend: Math.round(simulatedStoreSpend),
    },
    combat_build: combatBuild,
    manual_checklist: checklistFor(profile, milestone, build),
  };
}

export function calculatePower(
  weights: PowerWeights,
  build: BuildState,
  structures: BaseStructureState[],
  level: number,
): number {
  const spellTotal = Object.values(build.spell_levels).reduce(
    (sum, value) => sum + value,
    0,
  );
  const petLevel = build.pet_id === "" ? 0 : build.pet_level;
  const passiveLevel = build.passive_id === "" ? 0 : build.passive_level;
  const baseStats = structures.find((item) => item.structure_id === "estrutura_stats")?.level ??
    0;
  const baseAverage = avg(structures.map((item) => item.level));
  return Math.round(
    level * weights.level +
      build.weapon_level * weights.weapon_level +
      spellTotal * weights.spell_level +
      petLevel * weights.pet_level +
      passiveLevel * weights.passive_level +
      build.weapon_quality_tier * weights.weapon_quality_tier +
      baseStats * weights.base_stats_level +
      baseAverage * weights.base_average_level,
  );
}

function estimateGains(
  model: ProgressionModel,
  profile: Profile,
  milestone: Milestone,
): ResourceVector {
  const gains = emptyResources();
  addScaled(
    gains,
    model.source_values.battle,
    milestone.hours * profile.battles_per_hour,
  );
  addScaled(
    gains,
    model.source_values.routine_reward_hour_full,
    milestone.hours * profile.reward_completion,
  );
  addScaled(
    gains,
    model.source_values.free_pass_hour_full,
    milestone.hours * profile.battle_pass_completion,
  );
  addScaled(
    gains,
    model.source_values.base_checkin_hour,
    milestone.hours * profile.checkins_per_hour,
  );
  if (profile.premium_pass) {
    addScaled(
      gains,
      model.source_values.premium_pass_hour_full,
      milestone.hours * profile.battle_pass_completion,
    );
  }
  if (profile.store_pack_intensity > 0) {
    addScaled(
      gains,
      model.source_values.store_pack_hour,
      milestone.hours * profile.store_pack_intensity,
    );
  }
  if (profile.premium_pass) {
    gains.diamante += 500;
  }
  return roundResources(gains);
}

function estimateSpend(
  model: ProgressionModel,
  build: BuildState,
  structures: BaseStructureState[],
): ResourceVector {
  const spend = addResources(
    estimateBuildSpend(model, build),
    estimateBaseSpend(model, structures),
  );
  return roundResources(spend);
}

function estimateBuildSpend(
  model: ProgressionModel,
  build: BuildState,
): ResourceVector {
  const spend = emptyResources();
  spend.almas += cumulativeCost(model.costs.weapon_almas, build.weapon_level);
  for (const level of Object.values(build.spell_levels)) {
    spend.almas += cumulativeCost(model.costs.spell_almas, level);
  }
  if (build.pet_level > 0) {
    spend.sangue += cumulativeCost(model.costs.pet_sangue, build.pet_level);
  }
  if (build.passive_level > 0) {
    spend.cristais += cumulativeCost(
      model.costs.passive_cristais,
      build.passive_level,
    );
  }
  spend.ossos += model.costs.weapon_quality_thresholds[build.weapon_quality_tier] ?? 0;
  return roundResources(spend);
}

function estimateBaseSpend(
  model: ProgressionModel,
  structures: BaseStructureState[],
): ResourceVector {
  const spend = emptyResources();
  for (const structure of structures) {
    spend.energia += cumulativeCost(
      model.costs.base_structure_energia,
      structure.level,
    );
  }
  return roundResources(spend);
}

function buildStateFor(
  model: ProgressionModel,
  profile: Profile,
  archetypeId: string,
  level: number,
  gains: ResourceVector,
): BuildState {
  const ratio = profile.build_ratio;
  const weaponLevel = clampedScaledLevel(level, ratio + 0.05);
  const unlocked = unlockedSpells(level);
  const preferred = (ARCHETYPE_SPELLS[archetypeId] ?? ["sussurro_medo"]).filter((
    spell,
  ) => unlocked.includes(spell));
  const slots = maxSpellSlots(level);
  const spellSlots = preferred.slice(0, slots);
  const spellLevel = clampedScaledLevel(level, Math.max(0.1, ratio - 0.05));
  const spellLevels: Record<string, number> = {};
  for (const spell of spellSlots) {
    spellLevels[spell] = spellLevel;
  }
  const passiveId = level >= 10 ? ARCHETYPE_PASSIVE[archetypeId] ?? "doutrina_pavor" : "";
  const petId = level >= 15 ? ARCHETYPE_PET[archetypeId] ?? "corvo_pressagio" : "";
  const passiveLevel = passiveId === "" ? 0 : clampedScaledLevel(level, ratio - 0.12);
  const petLevel = petId === "" ? 0 : clampedScaledLevel(level, ratio - 0.1);
  const qualityTier = qualityTierFor(model, gains.ossos);
  const desired: BuildState = {
    archetype_id: archetypeId,
    weapon_type: ARCHETYPE_WEAPON[archetypeId] ?? "varinha_cinzas",
    weapon_quality: QUALITY_NAMES[qualityTier] ?? "starter",
    weapon_quality_tier: qualityTier,
    weapon_level: weaponLevel,
    spell_slots: spellSlots,
    spells_unlocked: unlocked,
    spell_levels: spellLevels,
    passive_id: passiveId,
    passive_level: passiveLevel,
    pet_id: petId,
    pet_level: petLevel,
  };
  return fitBuildToResources(model, desired, gains);
}

function baseStateFor(
  model: ProgressionModel,
  profile: Profile,
  level: number,
  milestone: Milestone,
  availableEnergia: number,
): HealthySave["base"] {
  const desiredStructures = BASE_STRUCTURES.map((definition) => ({
    structure_id: definition.id,
    produces: definition.produces,
    level: clamp(
      Math.floor(
        level * profile.base_ratio * definition.bias *
          profile.speedup_multiplier,
      ),
      0,
      level,
    ),
  }));
  const structures = fitBaseToEnergy(
    model,
    desiredStructures,
    availableEnergia,
    profile,
  );
  const primary = structures.find((item) => item.structure_id === "nucleo_energia") ??
    structures[0];
  const activeJob = primary.level < level
    ? {
      structure_id: primary.structure_id,
      target_level: primary.level + 1,
      remaining_minutes: Math.max(10, Math.round(90 - milestone.hours * 2)),
    }
    : null;
  return {
    construction_slots: profile.second_construction_queue ? 2 : 1,
    structures,
    active_job: activeJob,
  };
}

function fitBuildToResources(
  model: ProgressionModel,
  desired: BuildState,
  gains: ResourceVector,
): BuildState {
  const fitted = cloneBuild(desired);
  const budget = {
    almas: Math.max(0, gains.almas * 0.88),
    sangue: Math.max(0, gains.sangue * 0.82),
    cristais: Math.max(0, gains.cristais * 0.82),
  };

  for (let guard = 0; guard < 200; guard += 1) {
    const spend = estimateBuildSpend(model, fitted);
    var changed = false;
    if (spend.almas > budget.almas) {
      changed = reduceAlmasSpend(fitted) || changed;
    }
    if (spend.sangue > budget.sangue && fitted.pet_level > 0) {
      fitted.pet_level -= 1;
      if (fitted.pet_level === 0) fitted.pet_id = "";
      changed = true;
    }
    if (spend.cristais > budget.cristais && fitted.passive_level > 0) {
      fitted.passive_level -= 1;
      if (fitted.passive_level === 0) fitted.passive_id = "";
      changed = true;
    }
    if (!changed) break;
  }

  return fitted;
}

function fitBaseToEnergy(
  model: ProgressionModel,
  desired: BaseStructureState[],
  availableEnergia: number,
  profile: Profile,
): BaseStructureState[] {
  const structures = desired.map((item) => ({ ...item }));
  const budgetRatio = profile.second_construction_queue ? 0.9 : 0.78;
  const budget = Math.max(0, availableEnergia * budgetRatio);

  for (let guard = 0; guard < 400; guard += 1) {
    const spend = estimateBaseSpend(model, structures);
    if (spend.energia <= budget) break;
    const index = highestReducibleStructureIndex(structures);
    if (index < 0) break;
    structures[index].level -= 1;
  }

  return structures;
}

function reduceAlmasSpend(build: BuildState): boolean {
  let spellToReduce = "";
  let highestSpellLevel = 1;
  for (const [spellId, level] of Object.entries(build.spell_levels)) {
    if (level > highestSpellLevel) {
      spellToReduce = spellId;
      highestSpellLevel = level;
    }
  }
  if (spellToReduce !== "") {
    build.spell_levels[spellToReduce] -= 1;
    return true;
  }
  if (build.weapon_level > 1) {
    build.weapon_level -= 1;
    return true;
  }
  return false;
}

function highestReducibleStructureIndex(
  structures: BaseStructureState[],
): number {
  var selected = -1;
  var selectedLevel = 0;
  for (let index = 0; index < structures.length; index += 1) {
    const level = structures[index].level;
    if (level > selectedLevel) {
      selected = index;
      selectedLevel = level;
    }
  }
  return selectedLevel > 0 ? selected : -1;
}

function cloneBuild(build: BuildState): BuildState {
  return {
    ...build,
    spell_slots: [...build.spell_slots],
    spells_unlocked: [...build.spells_unlocked],
    spell_levels: { ...build.spell_levels },
  };
}

function combatBuildFor(
  id: string,
  build: BuildState,
  level: number,
): CombatBuild {
  return {
    id,
    displayName: id,
    level,
    weaponId: build.weapon_type,
    weaponLevel: build.weapon_level,
    weaponQualityTier: build.weapon_quality_tier,
    spellIds: build.spell_slots,
    spellLevels: build.spell_levels,
    passiveId: build.passive_id || undefined,
    passiveLevel: build.passive_level || undefined,
    petId: build.pet_id || undefined,
    petLevel: build.pet_level || undefined,
  };
}

function buildRewardChecks(
  model: ProgressionModel,
  saves: HealthySave[],
): CheckRow[] {
  const rows: CheckRow[] = [];
  for (const save of saves) {
    const milestone = model.milestones.find((item) => item.id === save.milestone_id)!;
    rows.push({
      id: "level_window",
      profile_id: save.profile_id,
      milestone_id: save.milestone_id,
      status: save.player.level < milestone.target_level_min ||
          save.player.level > milestone.target_level_max
        ? "REVIEW"
        : "PASS",
      observed: String(save.player.level),
      target: `${milestone.target_level_min}-${milestone.target_level_max}`,
      note: "Level should stay inside the intended first-hours window.",
    });
    const worstDebt = Math.min(
      ...RESOURCE_KEYS.map((key) => save.resource_debt[key]),
    );
    rows.push({
      id: "resource_debt",
      profile_id: save.profile_id,
      milestone_id: save.milestone_id,
      status: worstDebt <= model.thresholds.negative_resource_critical
        ? "CRITICAL"
        : worstDebt <= model.thresholds.negative_resource_review
        ? "REVIEW"
        : "PASS",
      observed: String(round(worstDebt, 2)),
      target: `>= ${model.thresholds.negative_resource_review}`,
      note: "Healthy save should not require large hidden resource debt.",
    });
  }
  return rows;
}

function buildPremiumGap(
  model: ProgressionModel,
  saves: HealthySave[],
): PremiumGapRow[] {
  const rows: PremiumGapRow[] = [];
  for (const milestone of model.milestones) {
    const free = saves.find((save) =>
      save.profile_id === "free_100_rewards" &&
      save.milestone_id === milestone.id
    );
    if (free === undefined) continue;
    for (
      const save of saves.filter((candidate) =>
        candidate.milestone_id === milestone.id &&
        candidate.profile_id !== free.profile_id
      )
    ) {
      const gap = percentGap(save.player.power, free.player.power);
      rows.push({
        milestone_id: milestone.id,
        profile_id: save.profile_id,
        compared_to: free.profile_id,
        power_gap_percent: round(gap, 2),
        level_gap: save.player.level - free.player.level,
        premium_spend: save.monetization.simulated_store_spend,
        status: gap >= model.thresholds.premium_power_gap_critical_percent
          ? "CRITICAL"
          : gap >= model.thresholds.premium_power_gap_review_percent
          ? "REVIEW"
          : "PASS",
      });
    }
  }
  return rows;
}

function buildPowerRecommendations(
  model: ProgressionModel,
  saves: HealthySave[],
): PowerRecommendationRow[] {
  const totals = {
    level: 0,
    weapon_level: 0,
    spell_level: 0,
    pet_level: 0,
    passive_level: 0,
    weapon_quality_tier: 0,
    base_stats_level: 0,
    base_average_level: 0,
  };
  let grandTotal = 0;
  for (const save of saves) {
    const spellTotal = Object.values(save.build.spell_levels).reduce(
      (sum, value) => sum + value,
      0,
    );
    const baseStats = save.base.structures.find((item) =>
      item.structure_id === "estrutura_stats"
    )?.level ?? 0;
    const baseAverage = avg(save.base.structures.map((item) => item.level));
    const petLevel = save.build.pet_id === "" ? 0 : save.build.pet_level;
    const passiveLevel = save.build.passive_id === "" ? 0 : save.build.passive_level;
    const components = {
      level: save.player.level * model.power_weights.level,
      weapon_level: save.build.weapon_level * model.power_weights.weapon_level,
      spell_level: spellTotal * model.power_weights.spell_level,
      pet_level: petLevel * model.power_weights.pet_level,
      passive_level: passiveLevel * model.power_weights.passive_level,
      weapon_quality_tier: save.build.weapon_quality_tier *
        model.power_weights.weapon_quality_tier,
      base_stats_level: baseStats * model.power_weights.base_stats_level,
      base_average_level: baseAverage * model.power_weights.base_average_level,
    };
    for (
      const key of Object.keys(components) as Array<keyof typeof components>
    ) {
      totals[key] += components[key];
      grandTotal += components[key];
    }
  }
  return (Object.keys(totals) as Array<keyof typeof totals>).map(
    (component) => {
      const share = grandTotal <= 0 ? 0 : totals[component] / grandTotal * 100;
      const status: Status = share > 45 ? "REVIEW" : "PASS";
      return {
        component,
        current_weight: model.power_weights[component],
        observed_share_percent: round(share, 2),
        recommendation: status === "REVIEW"
          ? "Review weight; this component dominates early matchmaking power."
          : "Keep as baseline until Battle Lab matchup data disagrees.",
        status,
      };
    },
  );
}

function buildBotPool(model: ProgressionModel, saves: HealthySave[]): BotRow[] {
  const rows: BotRow[] = [];
  for (const save of saves) {
    for (const offset of model.thresholds.bot_power_offsets_percent) {
      const archetype = botArchetypeFor(save, offset, model.bot_archetypes);
      const targetPower = Math.max(
        50,
        Math.round(save.player.power * (1 + offset / 100)),
      );
      const botBuild = combatBuildFor(
        `bot_${save.id}_${offset}`,
        buildStateForBot(save, archetype, offset),
        save.player.level,
      );
      rows.push({
        id: `bot_${save.id}_${offset >= 0 ? "p" : "m"}${Math.abs(offset)}`,
        milestone_id: save.milestone_id,
        profile_id: save.profile_id,
        archetype_id: archetype,
        target_power: targetPower,
        power_band: classifyPowerBand(targetPower),
        level: save.player.level,
        build: botBuild,
      });
    }
  }
  return rows;
}

function buildStateForBot(
  save: HealthySave,
  archetypeId: string,
  offset: number,
): BuildState {
  const clone = structuredClone(save.build) as BuildState;
  clone.archetype_id = archetypeId;
  const preferred = (ARCHETYPE_SPELLS[archetypeId] ?? clone.spell_slots).filter(
    (spell) => clone.spells_unlocked.includes(spell),
  );
  clone.spell_slots = preferred.slice(0, maxSpellSlots(save.player.level));
  clone.spell_levels = {};
  for (const spell of clone.spell_slots) {
    clone.spell_levels[spell] = clamp(
      Math.round(
        (save.build.spell_levels[Object.keys(save.build.spell_levels)[0]] ??
          save.player.level) *
          (1 + offset / 100),
      ),
      1,
      save.player.level,
    );
  }
  clone.passive_id = save.player.level >= 10
    ? ARCHETYPE_PASSIVE[archetypeId] ?? clone.passive_id
    : "";
  clone.pet_id = save.player.level >= 15 ? ARCHETYPE_PET[archetypeId] ?? clone.pet_id : "";
  return clone;
}

function saveNotes(
  model: ProgressionModel,
  milestone: Milestone,
  level: number,
  debt: ResourceVector,
  power: number,
  profile: Profile,
): string[] {
  const notes: string[] = [];
  if (
    level < milestone.target_level_min || level > milestone.target_level_max
  ) {
    notes.push(
      `Level ${level} outside target ${milestone.target_level_min}-${milestone.target_level_max}.`,
    );
  }
  for (const key of RESOURCE_KEYS) {
    if (debt[key] < model.thresholds.negative_resource_review) {
      notes.push(`${key} debt ${round(debt[key], 2)} should be reviewed.`);
    }
  }
  if (profile.premium_pass) {
    notes.push(
      "Premium profile: validate that advantage feels like time/conforto, not exclusive power.",
    );
  }
  notes.push(
    `Use power ${power} as initial matchmaking observation, not final truth.`,
  );
  return notes;
}

function statusForSave(
  model: ProgressionModel,
  milestone: Milestone,
  level: number,
  debt: ResourceVector,
): Status {
  if (
    Math.min(...RESOURCE_KEYS.map((key) => debt[key])) <=
      model.thresholds.negative_resource_critical
  ) {
    return "CRITICAL";
  }
  if (
    level < milestone.target_level_min ||
    level > milestone.target_level_max ||
    Math.min(...RESOURCE_KEYS.map((key) => debt[key])) <=
      model.thresholds.negative_resource_review
  ) {
    return "REVIEW";
  }
  return "PASS";
}

function checklistFor(
  profile: Profile,
  milestone: Milestone,
  build: BuildState,
): string[] {
  return [
    `Carregar ${profile.id} em ${milestone.id}.`,
    "Conferir se Refugio mostra recursos, poder, fila e base coerentes.",
    "Fazer uma batalha FIRST_SLICE_SIM e observar duracao/recompensa.",
    "Abrir Base e avaliar se proximo upgrade parece desejavel.",
    "Abrir Loja/Passe e avaliar se premium parece conforto, nao obrigacao.",
    `Conferir build: arma L${build.weapon_level}, spells ${
      build.spell_slots.join(", ") || "nenhuma"
    }.`,
    "Registrar gargalo, momento confuso e vontade de continuar.",
  ];
}

function archetypeForLevel(level: number, profile: Profile): string {
  if (level < 3) return "starter_instrument";
  if (level < 7) return "mental_controller";
  if (level < 15) {
    return profile.id === "free_50_rewards" ? "elemental_mixer" : "funeral_burst";
  }
  if (level < 25) {
    return profile.premium_pass ? "familiar_handler" : "elemental_mixer";
  }
  if (profile.id === "max_spender") return "summoner";
  if (profile.id === "spender_light") return "funeral_burst";
  return profile.id === "free_50_rewards" ? "defensive_occultist" : "dot_pressure";
}

function botArchetypeFor(
  save: HealthySave,
  offset: number,
  archetypes: string[],
): string {
  if (offset < 0) {
    return archetypes.includes("starter_instrument")
      ? "starter_instrument"
      : save.build.archetype_id;
  }
  if (offset > 0) {
    return archetypes.includes("funeral_burst") ? "funeral_burst" : save.build.archetype_id;
  }
  return save.build.archetype_id;
}

function unlockedSpells(level: number): string[] {
  return Object.entries(SPELL_UNLOCKS)
    .filter(([, unlock]) => level >= unlock)
    .map(([spell]) => spell);
}

function maxSpellSlots(level: number): number {
  if (level >= 25) return 3;
  if (level >= 7) return 2;
  if (level >= 3) return 1;
  return 0;
}

function qualityTierFor(model: ProgressionModel, ossos: number): number {
  let tier = 0;
  for (
    let index = 0;
    index < model.costs.weapon_quality_thresholds.length;
    index += 1
  ) {
    if (ossos >= model.costs.weapon_quality_thresholds[index]) tier = index;
  }
  return clamp(tier, 0, 4);
}

function clampedScaledLevel(level: number, ratio: number): number {
  return clamp(Math.max(1, Math.round(level * ratio)), 1, level);
}

function cumulativeCost(curve: CostCurve, targetLevel: number): number {
  let total = 0;
  for (let level = 2; level <= targetLevel; level += 1) {
    total += Math.max(curve.min, Math.round(curve.coefficient * level * level));
  }
  return total;
}

export function xpForLevel(level: number): number {
  return Math.max(0, 3 * (level ** 3 - 6 * level ** 2 + 17 * level - 12));
}

export function levelFromXp(xp: number, cap: number): number {
  let level = 1;
  for (let candidate = 1; candidate <= cap; candidate += 1) {
    if (xpForLevel(candidate) <= xp) level = candidate;
  }
  return level;
}

function subtractResources(
  left: ResourceVector,
  right: ResourceVector,
): ResourceVector {
  const result = emptyResources();
  for (const key of RESOURCE_KEYS) result[key] = left[key] - right[key];
  return roundResources(result);
}

function addResources(
  left: ResourceVector,
  right: ResourceVector,
): ResourceVector {
  const result = emptyResources();
  for (const key of RESOURCE_KEYS) result[key] = left[key] + right[key];
  return roundResources(result);
}

function resourceDebt(resources: ResourceVector): ResourceVector {
  const debt = emptyResources();
  for (const key of RESOURCE_KEYS) debt[key] = Math.min(0, resources[key]);
  return roundResources(debt);
}

function clampResources(resources: ResourceVector): ResourceVector {
  const result = emptyResources();
  for (const key of RESOURCE_KEYS) result[key] = Math.max(0, resources[key]);
  return roundResources(result);
}

function emptyResources(): ResourceVector {
  return {
    xp: 0,
    almas: 0,
    energia: 0,
    sangue: 0,
    cristais: 0,
    ossos: 0,
    diamante: 0,
  };
}

function roundResources(resources: ResourceVector): ResourceVector {
  const rounded = emptyResources();
  for (const key of RESOURCE_KEYS) rounded[key] = round(resources[key], 2);
  return rounded;
}

function addScaled(
  target: ResourceVector,
  vector: Partial<ResourceVector> | undefined,
  scale: number,
): void {
  if (vector === undefined) return;
  for (const key of RESOURCE_KEYS) {
    target[key] += (vector[key] ?? 0) * scale;
  }
}

function classifyPowerBand(power: number): string {
  if (power <= 250) return "band_001";
  if (power <= 600) return "band_002";
  if (power <= 1200) return "band_003";
  if (power <= 2200) return "band_004";
  return "band_005";
}

function saveRow(save: HealthySave): Record<string, unknown> {
  return {
    id: save.id,
    profile_id: save.profile_id,
    milestone_id: save.milestone_id,
    hours: save.hours,
    status: save.status,
    level: save.player.level,
    xp: save.player.xp,
    power: save.player.power,
    almas: save.resources.almas,
    energia: save.resources.energia,
    sangue: save.resources.sangue,
    cristais: save.resources.cristais,
    ossos: save.resources.ossos,
    diamante: save.resources.diamante,
    weapon_level: save.build.weapon_level,
    weapon_quality_tier: save.build.weapon_quality_tier,
    spells: save.build.spell_slots.join("|"),
    base_average_level: round(
      avg(save.base.structures.map((item) => item.level)),
      2,
    ),
  };
}

function botRow(row: BotRow): Record<string, unknown> {
  return {
    id: row.id,
    milestone_id: row.milestone_id,
    profile_id: row.profile_id,
    archetype_id: row.archetype_id,
    target_power: row.target_power,
    power_band: row.power_band,
    level: row.level,
    spell_ids: row.build.spellIds.join("|"),
    passive_id: row.build.passiveId ?? "",
    pet_id: row.build.petId ?? "",
  };
}

function reportHtml(model: ProgressionModel, data: ProgressionData): string {
  const cards = [
    ["Status", data.status],
    ["Healthy saves", String(data.saves.length)],
    ["Bots", String(data.bot_pool.length)],
    ["Profiles", String(model.profiles.length)],
  ];
  const saveRows = data.saves.map((save) =>
    `<tr><td>${save.id}</td><td>${save.status}</td><td>${save.player.level}</td><td>${save.player.power}</td><td>${
      save.notes.join("<br>")
    }</td></tr>`
  ).join("\n");
  const checkRows = data.reward_checks.map((check) =>
    `<tr><td>${check.status}</td><td>${check.profile_id}</td><td>${check.milestone_id}</td><td>${check.id}</td><td>${check.observed}</td><td>${check.target}</td></tr>`
  ).join("\n");
  const gapRows = data.premium_gap.map((gap) =>
    `<tr><td>${gap.status}</td><td>${gap.profile_id}</td><td>${gap.milestone_id}</td><td>${gap.power_gap_percent}%</td><td>${gap.premium_spend}</td></tr>`
  ).join("\n");
  return `<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>DraxosMobile Progression Lab</title>
  <style>
    body { font-family: Arial, sans-serif; background: #111820; color: #e7edf3; margin: 24px; }
    h1, h2 { margin-bottom: 8px; }
    .cards { display: grid; grid-template-columns: repeat(4, minmax(120px, 1fr)); gap: 12px; margin: 16px 0; }
    .card { border: 1px solid #344554; padding: 12px; background: #18222c; border-radius: 6px; }
    table { width: 100%; border-collapse: collapse; margin: 12px 0 24px; }
    th, td { border: 1px solid #344554; padding: 8px; text-align: left; vertical-align: top; }
    th { background: #22303c; }
  </style>
</head>
<body>
  <h1>DraxosMobile Progression Lab</h1>
  <p>Model ${model.model_id}. Use this report to pick manual Godot saves and tuning hypotheses.</p>
  <div class="cards">${
    cards.map(([label, value]) => `<div class="card"><strong>${label}</strong><br>${value}</div>`)
      .join("")
  }</div>
  <h2>Healthy Saves</h2>
  <table><tr><th>Save</th><th>Status</th><th>Level</th><th>Power</th><th>Notes</th></tr>${saveRows}</table>
  <h2>Reward Checks</h2>
  <table><tr><th>Status</th><th>Profile</th><th>Milestone</th><th>Check</th><th>Observed</th><th>Target</th></tr>${checkRows}</table>
  <h2>Premium Gap</h2>
  <table><tr><th>Status</th><th>Profile</th><th>Milestone</th><th>Power Gap</th><th>Premium Spend</th></tr>${gapRows}</table>
</body>
</html>
`;
}

function toCsv(rows: any[], headers: string[]): string {
  const lines = [headers.join(",")];
  for (const row of rows) {
    lines.push(headers.map((header) => csvCell(row[header])).join(","));
  }
  return lines.join("\n") + "\n";
}

function csvCell(value: unknown): string {
  const text = value === undefined || value === null ? "" : String(value);
  if (/[",\n]/.test(text)) return `"${text.replaceAll('"', '""')}"`;
  return text;
}

function worstStatus(statuses: Status[]): Status {
  if (statuses.includes("CRITICAL")) return "CRITICAL";
  if (statuses.includes("REVIEW")) return "REVIEW";
  return "PASS";
}

function avg(values: number[]): number {
  if (values.length === 0) return 0;
  return values.reduce((sum, value) => sum + value, 0) / values.length;
}

function percentGap(value: number, baseline: number): number {
  if (baseline <= 0) return 0;
  return (value - baseline) / baseline * 100;
}

function round(value: number, places = 0): number {
  const factor = 10 ** places;
  return Math.round(value * factor) / factor;
}

function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

async function main(): Promise<void> {
  const model = await loadModel();
  const data = buildProgressionData(model);
  await writeProgressionOutputs(model, data);
  const reviewCount = [
    ...data.saves,
    ...data.reward_checks,
    ...data.premium_gap,
    ...data.power_recommendations,
  ].filter((item) => item.status !== "PASS").length;
  console.log(
    `Progression Lab generated ${data.saves.length} saves, ${data.bot_pool.length} bots, status ${data.status}, ${reviewCount} review items.`,
  );
}

if (import.meta.main) {
  await main();
}
