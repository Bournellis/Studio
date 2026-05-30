import {
  botCombatantFromRow,
  DEFAULT_POTION_BEHAVIOR,
  DEFAULT_SPELL_BEHAVIOR,
  normalizeBehavior,
  playerCombatantFromState,
  potionSlotForBattle,
  spellBehaviorMap,
} from "../functions/_shared/battle_combatants.ts";
import {
  botCombatantFromRow as supabaseBotCombatantFromRow,
  playerCombatantFromState as supabasePlayerCombatantFromState,
} from "../../supabase/functions/_shared/battle_combatants.ts";
import { simulateFirstSliceBattle } from "../functions/_shared/battle_simulator.ts";

const SERVER_MODULE_PATH = "server/functions/_shared/battle_combatants.ts";
const SUPABASE_MODULE_PATH = "supabase/functions/_shared/battle_combatants.ts";

Deno.test("battle combatants module is mirrored and adapter-free", async () => {
  const serverModule = await Deno.readTextFile(SERVER_MODULE_PATH);
  const supabaseModule = await Deno.readTextFile(SUPABASE_MODULE_PATH);

  assertEq(
    normalizeNewlines(serverModule),
    normalizeNewlines(supabaseModule),
    "server and supabase battle combatants modules should mirror exactly",
  );
  assertNotIncludes(
    serverModule,
    "Deno.serve",
    "battle combatants domain must not serve HTTP",
  );
  assertNotIncludes(
    serverModule,
    "fetch(",
    "battle combatants domain must not call Supabase REST",
  );
  assertNotIncludes(
    serverModule,
    "rpc/",
    "battle combatants domain must not call transactional RPCs",
  );
});

Deno.test("battle combatants project player build with potion and behaviors", () => {
  const state = samplePlayerState();
  const combatant = playerCombatantFromState(state);
  const supabaseCombatant = supabasePlayerCombatantFromState(state);

  assertEq(stableStringify(combatant), stableStringify(supabaseCombatant));
  assertEq(combatant.id, "player-1");
  assertEq(combatant.displayName, "Draxos");
  assertEq(combatant.level, 12);
  assertEq(combatant.weaponId, "varinha_cinzas");
  assertEq(combatant.weaponLevel, 3);
  assertEq(combatant.weaponQualityTier, 1);
  assertEq(
    stableStringify(combatant.spellIds),
    stableStringify(["sussurro_medo"]),
  );
  assertEq(combatant.spellLevels.sussurro_medo, 12);
  assertEq(combatant.passiveId, "doutrina_pavor");
  assertEq(combatant.passiveLevel, 2);
  assertEq(combatant.petId, "corvo_pressagio");
  assertEq(combatant.petLevel, 3);
  assert(combatant.potionSlot !== undefined, "player should carry potion slot");
  assertEq(combatant.potionSlot.quantity, 2);
  assertEq(combatant.potionSlot.behavior.hp.mode, "below");
  assertEq(combatant.potionSlot.behavior.hp.percent, 35);
  assertEq(combatant.spellBehaviors?.sussurro_medo.enabled, false);
});

Deno.test("battle combatants project bot build with stable defaults", () => {
  const bot = {
    id: "bot-effect-trainer",
    build_data: {
      display_name: "",
      level: "8",
      weapon_id: "",
      weapon_level: "6",
      weapon_quality: "ritual",
      spell_ids: [],
      spell_levels: { sussurro_medo: "7" },
      passive_id: "",
      pet_id: "corvo_pressagio",
      pet_level: "4",
    },
  };

  const combatant = botCombatantFromRow(bot);
  const supabaseCombatant = supabaseBotCombatantFromRow(bot);

  assertEq(stableStringify(combatant), stableStringify(supabaseCombatant));
  assertEq(combatant.id, "bot-effect-trainer");
  assertEq(combatant.displayName, "Treinador da Primeira Ruina");
  assertEq(combatant.level, 8);
  assertEq(combatant.weaponId, "varinha_cinzas");
  assertEq(combatant.weaponLevel, 6);
  assertEq(combatant.weaponQualityTier, 2);
  assertEq(
    stableStringify(combatant.spellIds),
    stableStringify(["sussurro_medo"]),
  );
  assertEq(combatant.spellLevels.sussurro_medo, 7);
  assertEq(combatant.passiveId, undefined);
  assertEq(combatant.petId, "corvo_pressagio");
  assertEq(combatant.petLevel, 4);
});

Deno.test("battle combatants normalize behavior and potion eligibility", () => {
  const disabledPotion = potionSlotForBattle({
    inventory: [{ item_id: "pocao_vida", quantity: 0 }],
    potionSlots: [{
      slot_index: 1,
      potion_id: "pocao_vida",
      behavior: DEFAULT_POTION_BEHAVIOR,
    }],
  });
  assertEq(disabledPotion, undefined);

  const behavior = normalizeBehavior({
    enabled: false,
    hp: { mode: "above", percent: "88.9" },
    mana: { mode: "invalid", percent: 999 },
  }, DEFAULT_SPELL_BEHAVIOR);
  assertEq(behavior.enabled, false);
  assertEq(behavior.hp.mode, "above");
  assertEq(behavior.hp.percent, 88);
  assertEq(behavior.mana.mode, "ignore");
  assertEq(behavior.mana.percent, 0);

  const mapped = spellBehaviorMap([{
    spell_id: "sussurro_medo",
    behavior: { enabled: true, hp: { mode: "below", percent: -10 } },
  }]);
  assertEq(mapped.sussurro_medo.hp.percent, 0);
});

Deno.test("battle combatants output remains accepted by simulator", () => {
  const simulation = simulateFirstSliceBattle({
    battleId: "battle-combatants-test",
    seed: "battle-combatants-seed",
    player: playerCombatantFromState(samplePlayerState()),
    opponent: botCombatantFromRow({
      id: "bot-effect-trainer",
      build_data: {
        level: 8,
        weapon_id: "varinha_cinzas",
        weapon_level: 3,
        weapon_quality: "reforcada",
        spell_ids: ["sussurro_medo"],
        spell_levels: { sussurro_medo: 8 },
      },
    }),
  });

  assertEq(simulation.battleLog.schema_version, "battle_log_v1");
  assertEq(simulation.battleLog.participants.player.id, "player-1");
  assertEq(simulation.battleLog.participants.opponent.id, "bot-effect-trainer");
  assert(
    simulation.battleLog.events.length > 0,
    "simulation should produce events",
  );
});

function samplePlayerState(): Parameters<typeof playerCombatantFromState>[0] {
  return {
    player: { id: "player-1", username: "", level: 12 },
    build: {
      weapon_type: "",
      weapon_quality: "reforcada",
      weapon_level: 3,
      spell_slots: [],
      spells_unlocked: ["sussurro_medo"],
      pet_id: "corvo_pressagio",
      pet_level: 3,
      passive_id: "doutrina_pavor",
      passive_level: 2,
    },
    inventory: [{ item_id: "pocao_vida", quantity: 2 }],
    potionSlots: [{
      slot_index: 1,
      potion_id: "pocao_vida",
      behavior: {
        enabled: true,
        hp: { mode: "below", percent: 35 },
        mana: { mode: "ignore", percent: 0 },
      },
    }],
    spellBehaviors: [{
      spell_id: "sussurro_medo",
      behavior: { enabled: false },
    }],
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
    throw new Error(message);
  }
}
