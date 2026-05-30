export type BaseResourceKey = "almas" | "energia" | "sangue" | "cristais" | "ossos";

export interface BasePlayerRow {
  id: string;
  save_type?: string;
  level: number;
}

export interface BaseResourceRow {
  player_id: string;
  almas: string | number;
  energia: string | number;
  sangue: string | number;
  cristais: string | number;
  ossos: string | number;
  po_osso: string | number;
  diamante: string | number;
  updated_at: string;
}

export interface BaseStructureRow {
  player_id: string;
  structure_id: string;
  level: number;
  last_collected_at: string;
  updated_at: string;
}

export interface BaseConstructionJobRow {
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

export interface BaseStructureDefinition {
  id: string;
  displayName: string;
  description: string;
  benefitLabel: string;
  resource: BaseResourceKey | null;
  dailyAtLevel40: number;
}

export const MAX_STRUCTURE_LEVEL = 40;
export const DEFAULT_CONSTRUCTION_SLOTS = 1;
export const DOUBLE_CONSTRUCTION_QUEUE_PRODUCT_ID = "alpha_double_construction_queue";

const SECONDS_PER_DAY = 86_400;

export const BASE_STRUCTURES: BaseStructureDefinition[] = [
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
    dailyAtLevel40: 200,
  },
];

export function baseStatePayload(
  state: {
    player: BasePlayerRow;
    resources: BaseResourceRow;
    structures: BaseStructureRow[];
    jobs: BaseConstructionJobRow[];
    constructionSlots: number;
  },
  now = new Date(),
): Record<string, unknown> {
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

export function jobPayload(
  job: BaseConstructionJobRow,
  now: Date,
): Record<string, unknown> {
  return {
    ...job,
    display_name: definitionFor(job.structure_id)?.displayName ?? job.structure_id,
    remaining_seconds: Math.max(
      0,
      Math.ceil((new Date(job.completes_at).getTime() - now.getTime()) / 1000),
    ),
  };
}

export function upgradeBlockReason(
  structure: BaseStructureRow,
  player: BasePlayerRow,
  resources: BaseResourceRow,
  activeJob: BaseConstructionJobRow | undefined,
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

export function upgradeBlockMessage(reason: string): string {
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

export function calculateCollectable(
  structures: BaseStructureRow[],
  now: Date,
): Record<BaseResourceKey, number> {
  const collected: Record<BaseResourceKey, number> = {
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
  ) as Record<BaseResourceKey, number>;
}

export function collectableFor(
  structure: BaseStructureRow,
  now: Date,
): number {
  const definition = definitionFor(structure.structure_id);
  if (
    definition === undefined || definition.resource === null ||
    structure.level <= 0
  ) {
    return 0;
  }
  const elapsedSeconds = Math.max(
    0,
    (now.getTime() - new Date(structure.last_collected_at).getTime()) / 1000,
  );
  const produced = dailyProduction(structure) * (elapsedSeconds / SECONDS_PER_DAY);
  const collectable = Math.min(storageCap(structure), produced);
  if (definition.resource === "ossos") {
    return Math.floor(collectable);
  }
  return round2(collectable);
}

export function dailyProduction(structure: BaseStructureRow): number {
  const definition = definitionFor(structure.structure_id);
  if (
    definition === undefined || definition.resource === null ||
    structure.level <= 0
  ) {
    return 0;
  }
  return Math.max(
    1,
    Math.round(definition.dailyAtLevel40 * structure.level / MAX_STRUCTURE_LEVEL),
  );
}

export function storageCap(structure: BaseStructureRow): number {
  const daily = dailyProduction(structure);
  return daily <= 0 ? 0 : Math.max(8, Math.ceil(daily * 2));
}

export function upgradeCost(targetLevel: number): number {
  return Math.max(20, Math.round(0.5 * targetLevel * targetLevel));
}

export function upgradeDurationSeconds(targetLevel: number): number {
  return Math.max(120, Math.round(0.1 * targetLevel * targetLevel * 3600));
}

export function definitionFor(
  structureId: string,
): BaseStructureDefinition | undefined {
  return BASE_STRUCTURES.find((definition) => definition.id === structureId);
}

function round2(value: number): number {
  return Math.round(value * 100) / 100;
}

function numberValue(value: unknown, fallback: number): number {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string" && value.trim() !== "") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
  }
  return fallback;
}
