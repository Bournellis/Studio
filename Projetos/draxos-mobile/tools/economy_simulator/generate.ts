type ResourceId = "xp" | "almas" | "energia" | "sangue" | "cristais" | "ossos" | "diamante";
type ResourceVector = Record<ResourceId, number>;

type Profile = {
  id: string;
  display_name: string;
  description: string;
  battles_per_day: number;
  checkins_per_day: number;
  daily_mission_completion: number;
  weekly_mission_completion: number;
  free_pass_completion: number;
  premium_pass: boolean;
  second_construction_queue: boolean;
  limited_packs: boolean;
  speedup_multiplier: number;
  catchup_multiplier: number;
  start_day: number;
};

type Model = {
  schema_version: number;
  model_id: string;
  status: string;
  notes: string[];
  season_defaults: {
    selected_season_id: string;
    duration_days: number;
    battle_pass_duration_days: number;
    selected_cap: number;
    initial_cap_options: number[];
    future_caps: Array<{ season_id: string; cap: number }>;
    free_active_target_cap_day: number;
  };
  activity_minutes: Record<string, number>;
  resources: Array<{
    id: string;
    display_name: string;
    role: string;
    primary_sources: string[];
    primary_sinks: string[];
    persistence: string;
  }>;
  source_values: Record<string, Partial<ResourceVector>>;
  upgrade_costs: Record<string, any>;
  profile_defaults: Profile[];
  checks: Record<string, any>;
};

type ProfileSummary = {
  id: string;
  name: string;
  end_level: number;
  cap_day: number | null;
  estimated_minutes_per_day: number;
  queue_count: number;
  total_xp: number;
  total_almas: number;
  total_energia: number;
  total_sangue: number;
  total_cristais: number;
  total_ossos: number;
  total_diamante: number;
  main_build_coverage: number;
  full_account_coverage: number;
  construction_time_coverage: number;
};

type DailyRow = {
  day: number;
  profile_id: string;
  profile_name: string;
  level: number;
  xp_total: number;
  almas: number;
  energia: number;
  sangue: number;
  cristais: number;
  ossos: number;
  diamante: number;
};

const projectRoot = new URL("../../", import.meta.url);
const modelUrl = new URL("economy_model.v1.json", import.meta.url);
const outputUrl = new URL("docs/economy/generated/", projectRoot);

const resourceIds: ResourceId[] = ["xp", "almas", "energia", "sangue", "cristais", "ossos", "diamante"];

function emptyVector(): ResourceVector {
  return { xp: 0, almas: 0, energia: 0, sangue: 0, cristais: 0, ossos: 0, diamante: 0 };
}

function addVector(target: ResourceVector, source: Partial<ResourceVector>, multiplier = 1): void {
  for (const key of resourceIds) {
    target[key] += (source[key] ?? 0) * multiplier;
  }
}

function round(value: number, digits = 2): number {
  const scale = 10 ** digits;
  return Math.round(value * scale) / scale;
}

function xpTotalForLevel(level: number): number {
  if (level <= 1) return 0;
  return 3 * (level ** 3 - 6 * level ** 2 + 17 * level - 12);
}

function levelForXp(xp: number, cap: number): number {
  let level = 1;
  for (let candidate = 2; candidate <= cap; candidate += 1) {
    if (xp >= xpTotalForLevel(candidate)) {
      level = candidate;
    } else {
      break;
    }
  }
  return level;
}

function upgradeCost(min: number, coefficient: number, cap: number): number {
  let total = 0;
  for (let level = 2; level <= cap; level += 1) {
    total += Math.max(min, Math.round(coefficient * level ** 2));
  }
  return total;
}

function durationHours(min: number, coefficient: number, cap: number): number {
  let total = 0;
  for (let level = 2; level <= cap; level += 1) {
    total += Math.max(min, coefficient * level ** 2);
  }
  return total;
}

function dailyGain(model: Model, profile: Profile): ResourceVector {
  const gain = emptyVector();
  addVector(gain, model.source_values.battle, profile.battles_per_day);
  addVector(gain, model.source_values.daily_missions_full, profile.daily_mission_completion);
  addVector(gain, model.source_values.weekly_missions_daily_average, profile.weekly_mission_completion);
  addVector(gain, model.source_values.free_battle_pass_daily_average, profile.free_pass_completion);
  addVector(gain, model.source_values.base_checkin_daily_value, profile.checkins_per_day);
  if (profile.premium_pass) {
    addVector(gain, model.source_values.premium_battle_pass_daily_average, 1);
  }
  if (profile.limited_packs) {
    addVector(gain, model.source_values.limited_premium_pack_daily_equivalent, 1);
  }
  if (profile.catchup_multiplier !== 1) {
    for (const key of resourceIds) {
      if (key !== "diamante") gain[key] *= profile.catchup_multiplier;
    }
  }
  return gain;
}

function estimateMinutes(model: Model, profile: Profile): number {
  const minutes = model.activity_minutes;
  return round(
    profile.battles_per_day * minutes.battle +
      profile.checkins_per_day * minutes.checkin +
      profile.daily_mission_completion * minutes.daily_mission_admin +
      profile.weekly_mission_completion * minutes.weekly_mission_admin +
      Math.max(profile.free_pass_completion, profile.premium_pass ? 1 : 0) * minutes.battle_pass_claim +
      (profile.limited_packs ? minutes.shop_admin : 0),
    1,
  );
}

function calculateCosts(model: Model, cap: number) {
  const costs = model.upgrade_costs;
  const weaponCost = upgradeCost(costs.weapon_almas.min, costs.weapon_almas.coefficient, cap);
  const spellCost = upgradeCost(costs.spell_almas.min, costs.spell_almas.coefficient, cap);
  const petCost = upgradeCost(costs.pet_sangue.min, costs.pet_sangue.coefficient, cap);
  const passiveCost = upgradeCost(costs.passive_cristais.min, costs.passive_cristais.coefficient, cap);
  const structureEnergyCost = upgradeCost(
    costs.base_structure_energia.min,
    costs.base_structure_energia.coefficient,
    cap,
  );
  const structureHours = durationHours(
    costs.base_structure_duration_hours.min,
    costs.base_structure_duration_hours.coefficient,
    cap,
  );
  const weaponQualityOssos = costs.weapon_quality_ossos_total.coefficient * cap;
  return {
    xpToCap: xpTotalForLevel(cap),
    weaponCost,
    spellCost,
    petCost,
    passiveCost,
    structureEnergyCost,
    structureHours,
    weaponQualityOssos,
    mainBuild: {
      almas: weaponCost + 2 * spellCost,
      sangue: petCost,
      energia: structureEnergyCost,
      ossos: weaponQualityOssos,
    },
    fullAccount: {
      almas: weaponCost + 3 * spellCost,
      sangue: petCost,
      cristais: passiveCost,
      energia: 6 * structureEnergyCost,
      ossos: weaponQualityOssos,
      hours: 6 * structureHours,
    },
  };
}

function coverage(actual: number, needed: number): number {
  if (needed <= 0) return 1;
  return round(actual / needed, 4);
}

function minCoverage(values: number[]): number {
  return round(Math.min(...values), 4);
}

function simulate(model: Model) {
  const cap = model.season_defaults.selected_cap;
  const days = model.season_defaults.duration_days;
  const costs = calculateCosts(model, cap);
  const dailyRows: DailyRow[] = [];
  const summaries: ProfileSummary[] = [];

  for (const profile of model.profile_defaults) {
    const totals = emptyVector();
    let capDay: number | null = null;
    let endLevel = 1;
    const gain = dailyGain(model, profile);

    for (let day = 1; day <= days; day += 1) {
      if (day >= profile.start_day) {
        addVector(totals, gain, 1);
      }
      endLevel = levelForXp(totals.xp, cap);
      if (endLevel >= cap && capDay === null) capDay = day;
      dailyRows.push({
        day,
        profile_id: profile.id,
        profile_name: profile.display_name,
        level: endLevel,
        xp_total: round(totals.xp, 2),
        almas: round(totals.almas, 2),
        energia: round(totals.energia, 2),
        sangue: round(totals.sangue, 2),
        cristais: round(totals.cristais, 2),
        ossos: round(totals.ossos, 2),
        diamante: round(totals.diamante, 2),
      });
    }

    const queueCount = profile.second_construction_queue ? 2 : 1;
    const constructionHoursAvailable = days * 24 * queueCount * profile.speedup_multiplier;
    const mainCoverage = minCoverage([
      coverage(totals.almas, costs.mainBuild.almas),
      coverage(totals.sangue, costs.mainBuild.sangue),
      coverage(totals.energia, costs.mainBuild.energia),
      coverage(totals.ossos, costs.mainBuild.ossos),
    ]);
    const fullCoverage = minCoverage([
      coverage(totals.almas, costs.fullAccount.almas),
      coverage(totals.sangue, costs.fullAccount.sangue),
      coverage(totals.cristais, costs.fullAccount.cristais),
      coverage(totals.energia, costs.fullAccount.energia),
      coverage(totals.ossos, costs.fullAccount.ossos),
      coverage(constructionHoursAvailable, costs.fullAccount.hours),
    ]);
    summaries.push({
      id: profile.id,
      name: profile.display_name,
      end_level: endLevel,
      cap_day: capDay,
      estimated_minutes_per_day: estimateMinutes(model, profile),
      queue_count: queueCount,
      total_xp: round(totals.xp, 2),
      total_almas: round(totals.almas, 2),
      total_energia: round(totals.energia, 2),
      total_sangue: round(totals.sangue, 2),
      total_cristais: round(totals.cristais, 2),
      total_ossos: round(totals.ossos, 2),
      total_diamante: round(totals.diamante, 2),
      main_build_coverage: mainCoverage,
      full_account_coverage: fullCoverage,
      construction_time_coverage: coverage(constructionHoursAvailable, costs.fullAccount.hours),
    });
  }

  return { cap, days, costs, dailyRows, summaries };
}

function buildChecks(model: Model, sim: ReturnType<typeof simulate>) {
  const byId = new Map(sim.summaries.map((profile) => [profile.id, profile]));
  const freeActive = byId.get("free_active")!;
  const freeCasual = byId.get("free_casual")!;
  const efficient = byId.get("efficient_buyer")!;
  const whale = byId.get("whale_accelerator")!;
  const catchup = byId.get("catchup_newcomer")!;

  const checks = [
    {
      id: "free_active_cap_day",
      status:
        freeActive.cap_day !== null &&
          freeActive.cap_day >= model.checks.free_active_cap_day_min &&
          freeActive.cap_day <= model.checks.free_active_cap_day_max
          ? "PASS"
          : "REVIEW",
      observed: freeActive.cap_day ?? "not reached",
      target: `${model.checks.free_active_cap_day_min}-${model.checks.free_active_cap_day_max}`,
      note: "Free ativo deve chegar ao cap perto do dia 105.",
    },
    {
      id: "free_active_checkins",
      status:
        model.profile_defaults.find((profile) => profile.id === "free_active")!.checkins_per_day <=
            model.checks.free_active_max_required_checkins
          ? "PASS"
          : "REVIEW",
      observed: model.profile_defaults.find((profile) => profile.id === "free_active")!.checkins_per_day,
      target: `<= ${model.checks.free_active_max_required_checkins}`,
      note: "Free ativo nao deve exigir mais que 1 check-in obrigatorio por dia.",
    },
    {
      id: "free_active_main_build",
      status: freeActive.main_build_coverage >= model.checks.free_active_main_build_coverage_min ? "PASS" : "REVIEW",
      observed: freeActive.main_build_coverage,
      target: `>= ${model.checks.free_active_main_build_coverage_min}`,
      note: "Free ativo deve fechar uma build principal, nao a conta inteira.",
    },
    {
      id: "free_casual_below_cap",
      status: model.checks.free_casual_should_reach_cap ? "REVIEW" : freeCasual.end_level < sim.cap ? "PASS" : "REVIEW",
      observed: freeCasual.end_level,
      target: `< ${sim.cap}`,
      note: "Free casual nao e obrigado a chegar ao cap.",
    },
    {
      id: "efficient_buyer_faster_than_free",
      status:
        efficient.cap_day !== null && freeActive.cap_day !== null && efficient.cap_day < freeActive.cap_day
          ? "PASS"
          : "REVIEW",
      observed: efficient.cap_day ?? "not reached",
      target: `< ${freeActive.cap_day}`,
      note: "Compra eficiente deve comprar conforto/velocidade.",
    },
    {
      id: "whale_respects_cap",
      status: whale.end_level <= sim.cap ? "PASS" : "REVIEW",
      observed: whale.end_level,
      target: `<= ${sim.cap}`,
      note: "Aceleracao extrema nao pode ultrapassar o cap.",
    },
    {
      id: "catchup_newcomer_approaches_cap",
      status: catchup.end_level >= model.checks.catchup_newcomer_min_end_level && catchup.end_level < sim.cap
        ? "PASS"
        : "REVIEW",
      observed: catchup.end_level,
      target: `>= ${model.checks.catchup_newcomer_min_end_level} and < ${sim.cap}`,
      note: "Catch-up aproxima sem pular toda a jornada.",
    },
    {
      id: "premium_no_exclusive_power",
      status: !model.checks.premium_power_exclusive_allowed ? "PASS" : "REVIEW",
      observed: "no exclusive power modeled",
      target: "premium sells time/conforto only",
      note: "Premium nao deve vender poder exclusivo.",
    },
  ];
  return checks;
}

function csvEscape(value: unknown): string {
  if (value === null || value === undefined) return "";
  const text = String(value);
  if (/[",\r\n]/.test(text)) return `"${text.replaceAll('"', '""')}"`;
  return text;
}

function toCsv(rows: Array<Record<string, unknown>>, headers: string[]): string {
  return [
    headers.join(","),
    ...rows.map((row) => headers.map((header) => csvEscape(row[header])).join(",")),
  ].join("\n") + "\n";
}

function xmlEscape(value: unknown): string {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function columnName(index: number): string {
  let name = "";
  let value = index + 1;
  while (value > 0) {
    const mod = (value - 1) % 26;
    name = String.fromCharCode(65 + mod) + name;
    value = Math.floor((value - mod) / 26);
  }
  return name;
}

type Cell = string | number | boolean | null;

function sheetXml(rows: Cell[][]): string {
  const colCount = Math.max(...rows.map((row) => row.length));
  const dimension = `A1:${columnName(Math.max(0, colCount - 1))}${Math.max(1, rows.length)}`;
  const cols = Array.from({ length: colCount }, (_, index) =>
    `<col min="${index + 1}" max="${index + 1}" width="${index === 0 ? 22 : 16}" customWidth="1"/>`
  ).join("");
  const rowXml = rows.map((row, rowIndex) => {
    const cells = row.map((value, colIndex) => {
      const ref = `${columnName(colIndex)}${rowIndex + 1}`;
      if (typeof value === "number") {
        return `<c r="${ref}"><v>${Number.isFinite(value) ? value : 0}</v></c>`;
      }
      if (typeof value === "boolean") {
        return `<c r="${ref}" t="b"><v>${value ? 1 : 0}</v></c>`;
      }
      const text = value === null || value === undefined ? "" : xmlEscape(value);
      return `<c r="${ref}" t="inlineStr"><is><t>${text}</t></is></c>`;
    }).join("");
    return `<row r="${rowIndex + 1}">${cells}</row>`;
  }).join("");
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <dimension ref="${dimension}"/>
  <sheetViews><sheetView workbookViewId="0"><pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/></sheetView></sheetViews>
  <cols>${cols}</cols>
  <sheetData>${rowXml}</sheetData>
</worksheet>`;
}

function crc32(bytes: Uint8Array): number {
  let crc = 0xffffffff;
  for (const byte of bytes) {
    crc ^= byte;
    for (let i = 0; i < 8; i += 1) {
      crc = (crc >>> 1) ^ (0xedb88320 & -(crc & 1));
    }
  }
  return (crc ^ 0xffffffff) >>> 0;
}

function u16(value: number): Uint8Array {
  const bytes = new Uint8Array(2);
  new DataView(bytes.buffer).setUint16(0, value, true);
  return bytes;
}

function u32(value: number): Uint8Array {
  const bytes = new Uint8Array(4);
  new DataView(bytes.buffer).setUint32(0, value, true);
  return bytes;
}

function concat(parts: Uint8Array[]): Uint8Array {
  const size = parts.reduce((sum, part) => sum + part.length, 0);
  const output = new Uint8Array(size);
  let offset = 0;
  for (const part of parts) {
    output.set(part, offset);
    offset += part.length;
  }
  return output;
}

function zipStore(files: Array<{ path: string; content: string }>): Uint8Array {
  const encoder = new TextEncoder();
  const localParts: Uint8Array[] = [];
  const centralParts: Uint8Array[] = [];
  let offset = 0;
  const modTime = 0;
  const modDate = 33;

  for (const file of files) {
    const name = encoder.encode(file.path);
    const data = encoder.encode(file.content);
    const crc = crc32(data);
    const localHeader = concat([
      u32(0x04034b50),
      u16(20),
      u16(0),
      u16(0),
      u16(modTime),
      u16(modDate),
      u32(crc),
      u32(data.length),
      u32(data.length),
      u16(name.length),
      u16(0),
      name,
    ]);
    localParts.push(localHeader, data);
    centralParts.push(concat([
      u32(0x02014b50),
      u16(20),
      u16(20),
      u16(0),
      u16(0),
      u16(modTime),
      u16(modDate),
      u32(crc),
      u32(data.length),
      u32(data.length),
      u16(name.length),
      u16(0),
      u16(0),
      u16(0),
      u16(0),
      u32(0),
      u32(offset),
      name,
    ]));
    offset += localHeader.length + data.length;
  }

  const central = concat(centralParts);
  const end = concat([
    u32(0x06054b50),
    u16(0),
    u16(0),
    u16(files.length),
    u16(files.length),
    u32(central.length),
    u32(offset),
    u16(0),
  ]);
  return concat([...localParts, central, end]);
}

function workbookFiles(sheets: Array<{ name: string; rows: Cell[][] }>) {
  const sheetContentTypes = sheets.map((_, index) =>
    `<Override PartName="/xl/worksheets/sheet${index + 1}.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>`
  ).join("");
  const workbookSheets = sheets.map((sheet, index) =>
    `<sheet name="${xmlEscape(sheet.name)}" sheetId="${index + 1}" r:id="rId${index + 1}"/>`
  ).join("");
  const workbookRels = sheets.map((_, index) =>
    `<Relationship Id="rId${index + 1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet${index + 1}.xml"/>`
  ).join("") +
    `<Relationship Id="rId${sheets.length + 1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>`;

  const files = [
    {
      path: "[Content_Types].xml",
      content: `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
  ${sheetContentTypes}
</Types>`,
    },
    {
      path: "_rels/.rels",
      content: `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>`,
    },
    {
      path: "xl/workbook.xml",
      content: `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>${workbookSheets}</sheets>
</workbook>`,
    },
    {
      path: "xl/_rels/workbook.xml.rels",
      content: `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">${workbookRels}</Relationships>`,
    },
    {
      path: "xl/styles.xml",
      content: `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <fonts count="1"><font><sz val="11"/><name val="Calibri"/></font></fonts>
  <fills count="1"><fill><patternFill patternType="none"/></fill></fills>
  <borders count="1"><border/></borders>
  <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
  <cellXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/></cellXfs>
  <cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>
  <dxfs count="0"/>
  <tableStyles count="0" defaultTableStyle="TableStyleMedium2" defaultPivotStyle="PivotStyleLight16"/>
</styleSheet>`,
    },
  ];

  for (let i = 0; i < sheets.length; i += 1) {
    files.push({ path: `xl/worksheets/sheet${i + 1}.xml`, content: sheetXml(sheets[i].rows) });
  }
  return files;
}

function rowsFromObjects(rows: Array<Record<string, unknown>>, headers: string[]): Cell[][] {
  return [
    headers,
    ...rows.map((row) => headers.map((header) => {
      const value = row[header];
      if (typeof value === "number" || typeof value === "boolean" || value === null || value === undefined) return value as Cell;
      return String(value);
    })),
  ];
}

async function main() {
  const model = JSON.parse(await Deno.readTextFile(modelUrl)) as Model;
  const sim = simulate(model);
  const checks = buildChecks(model, sim);
  await Deno.mkdir(outputUrl, { recursive: true });

  const summary = {
    model_id: model.model_id,
    status: model.status,
    generated_at: "deterministic-local",
    selected_cap: sim.cap,
    duration_days: sim.days,
    costs: sim.costs,
    profiles: sim.summaries,
    checks,
  };

  const profileHeaders = [
    "id",
    "name",
    "end_level",
    "cap_day",
    "estimated_minutes_per_day",
    "queue_count",
    "total_xp",
    "total_almas",
    "total_energia",
    "total_sangue",
    "total_cristais",
    "total_ossos",
    "total_diamante",
    "main_build_coverage",
    "full_account_coverage",
    "construction_time_coverage",
  ];
  const dailyHeaders = [
    "day",
    "profile_id",
    "profile_name",
    "level",
    "xp_total",
    "almas",
    "energia",
    "sangue",
    "cristais",
    "ossos",
    "diamante",
  ];
  const checkHeaders = ["id", "status", "observed", "target", "note"];

  await Deno.writeTextFile(new URL("season_economy_summary.json", outputUrl), JSON.stringify(summary, null, 2) + "\n");
  await Deno.writeTextFile(new URL("season_economy_profiles.csv", outputUrl), toCsv(sim.summaries as any[], profileHeaders));
  await Deno.writeTextFile(new URL("season_economy_daily.csv", outputUrl), toCsv(sim.dailyRows as any[], dailyHeaders));
  await Deno.writeTextFile(new URL("season_economy_checks.csv", outputUrl), toCsv(checks as any[], checkHeaders));

  const dashboardRows: Cell[][] = [
    ["DraxosMobile Economy Simulator", model.status],
    ["Selected cap", sim.cap],
    ["Season days", sim.days],
    ["Free active target cap day", model.season_defaults.free_active_target_cap_day],
    [],
    ["Profile", "End level", "Cap day", "Minutes/day", "Main build coverage", "Full account coverage"],
    ...sim.summaries.map((profile) => [
      profile.name,
      profile.end_level,
      profile.cap_day ?? "not reached",
      profile.estimated_minutes_per_day,
      profile.main_build_coverage,
      profile.full_account_coverage,
    ]),
    [],
    ["Check", "Status", "Observed", "Target"],
    ...checks.map((check) => [check.id, check.status, check.observed as Cell, check.target]),
  ];

  const seasonRows: Cell[][] = [
    ["Field", "Value"],
    ["selected_season_id", model.season_defaults.selected_season_id],
    ["duration_days", model.season_defaults.duration_days],
    ["battle_pass_duration_days", model.season_defaults.battle_pass_duration_days],
    ["selected_cap", model.season_defaults.selected_cap],
    ["initial_cap_options", model.season_defaults.initial_cap_options.join("/")],
    [],
    ["Season", "Cap"],
    ...model.season_defaults.future_caps.map((row) => [row.season_id, row.cap]),
  ];

  const resourceRows = rowsFromObjects(model.resources as any[], [
    "id",
    "display_name",
    "role",
    "primary_sources",
    "primary_sinks",
    "persistence",
  ]).map((row, rowIndex) =>
    rowIndex === 0 ? row : row.map((value) => Array.isArray(value) ? value.join(", ") : value) as Cell[]
  );

  const sourceRows: Cell[][] = [
    ["Source", ...resourceIds],
    ...Object.entries(model.source_values).map(([source, values]) => [
      source,
      ...resourceIds.map((resource) => values[resource] ?? 0),
    ]),
  ];

  const sinkRows: Cell[][] = [
    ["Sink", "Resource", "Formula", "Season 1 cap cost"],
    ["xp_to_cap", "xp", model.upgrade_costs.xp_total_formula, sim.costs.xpToCap],
    ["weapon_level", "almas", model.upgrade_costs.weapon_almas.formula, sim.costs.weaponCost],
    ["spell_level_each", "almas", model.upgrade_costs.spell_almas.formula, sim.costs.spellCost],
    ["pet_level", "sangue", model.upgrade_costs.pet_sangue.formula, sim.costs.petCost],
    ["passive_level", "cristais", model.upgrade_costs.passive_cristais.formula, sim.costs.passiveCost],
    ["base_structure_each", "energia", model.upgrade_costs.base_structure_energia.formula, sim.costs.structureEnergyCost],
    ["base_structure_hours_each", "hours", model.upgrade_costs.base_structure_duration_hours.formula, round(sim.costs.structureHours, 2)],
    ["weapon_quality", "ossos", model.upgrade_costs.weapon_quality_ossos_total.formula, sim.costs.weaponQualityOssos],
  ];

  const premiumRows: Cell[][] = [
    ["Profile", "Premium pass", "Second queue", "Limited packs", "Speedup", "End level", "Cap day", "Full coverage"],
    ...model.profile_defaults.map((profile) => {
      const summaryProfile = sim.summaries.find((item) => item.id === profile.id)!;
      return [
        profile.display_name,
        profile.premium_pass,
        profile.second_construction_queue,
        profile.limited_packs,
        profile.speedup_multiplier,
        summaryProfile.end_level,
        summaryProfile.cap_day ?? "not reached",
        summaryProfile.full_account_coverage,
      ];
    }),
  ];

  const catchupRows: Cell[][] = [
    ["Field", "Value"],
    ["catchup_profile", "catchup_newcomer"],
    ["start_day", model.profile_defaults.find((profile) => profile.id === "catchup_newcomer")!.start_day],
    ["catchup_multiplier", model.profile_defaults.find((profile) => profile.id === "catchup_newcomer")!.catchup_multiplier],
    ["end_level", sim.summaries.find((profile) => profile.id === "catchup_newcomer")!.end_level],
    ["target", `>= ${model.checks.catchup_newcomer_min_end_level} and < ${sim.cap}`],
  ];

  const workbook = zipStore(workbookFiles([
    { name: "Dashboard", rows: dashboardRows },
    { name: "Season Inputs", rows: seasonRows },
    { name: "Resource Matrix", rows: resourceRows },
    { name: "Profiles", rows: rowsFromObjects(sim.summaries as any[], profileHeaders) },
    { name: "Sources", rows: sourceRows },
    { name: "Sinks", rows: sinkRows },
    { name: "Daily Simulation", rows: rowsFromObjects(sim.dailyRows as any[], dailyHeaders) },
    { name: "Premium Stress", rows: premiumRows },
    { name: "Catch-up", rows: catchupRows },
    { name: "Checks", rows: rowsFromObjects(checks as any[], checkHeaders) },
  ]));
  await Deno.writeFile(new URL("draxos_mobile_economy_simulator.xlsx", outputUrl), workbook);

  const failing = checks.filter((check) => check.status !== "PASS");
  if (failing.length > 0) {
    console.warn(`Economy simulator generated with ${failing.length} checks marked REVIEW.`);
    for (const check of failing) console.warn(`${check.id}: ${check.observed} target ${check.target}`);
  } else {
    console.log("Economy simulator generated with all checks PASS.");
  }
}

if (import.meta.main) {
  await main();
}
