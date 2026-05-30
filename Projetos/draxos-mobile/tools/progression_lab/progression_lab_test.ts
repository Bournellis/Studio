import {
  buildProgressionData,
  calculatePower,
  levelFromXp,
  xpForLevel,
} from "./generate.ts";
import modelJson from "./model.v1.json" with { type: "json" };

const model = modelJson as any;

Deno.test("progression lab generates every profile and milestone save", () => {
  const data = buildProgressionData(model);
  if (data.saves.length !== model.profiles.length * model.milestones.length) {
    throw new Error(`expected 25 saves, got ${data.saves.length}`);
  }
  const ids = new Set(data.saves.map((save) => save.id));
  if (!ids.has("free_100_rewards_10h")) {
    throw new Error("missing free_100_rewards_10h healthy save");
  }
});

Deno.test("xp curve round-trips level boundaries", () => {
  if (xpForLevel(1) !== 0) throw new Error("level 1 should start at 0 XP");
  if (levelFromXp(xpForLevel(10), 40) !== 10) {
    throw new Error("levelFromXp should resolve exact level boundary");
  }
});

Deno.test("premium profiles keep explicit premium flags and bot pool", () => {
  const data = buildProgressionData(model);
  const freemium = data.saves.find((save) => save.id === "freemium_basic_5h");
  if (freemium?.monetization.premium_unlocked !== true) {
    throw new Error("freemium save should unlock premium");
  }
  if (data.bot_pool.length < data.saves.length * 3) {
    throw new Error("bot pool should include offsets for every save");
  }
});

Deno.test("calculated power is deterministic for generated saves", () => {
  const data = buildProgressionData(model);
  const save = data.saves.find((item) => item.id === "free_100_rewards_20h");
  if (save === undefined) throw new Error("missing test save");
  const recalculated = calculatePower(
    model.power_weights,
    save.build,
    save.base.structures,
    save.player.level,
  );
  if (recalculated !== save.player.power) {
    throw new Error(`power mismatch: ${recalculated} != ${save.player.power}`);
  }
});

Deno.test("progression lab generated saves include Track 16 consumables and behavior", () => {
  const data = buildProgressionData(model);
  const save = data.saves.find((item) => item.id === "free_100_rewards_10h");
  if (save === undefined) throw new Error("missing test save");
  if (save.consumables.crafted_life_potions <= 0) {
    throw new Error("expected crafted life potions in 10h healthy save");
  }
  if (save.combat_build.potionSlot?.itemId !== "pocao_vida") {
    throw new Error("expected combat build potion slot");
  }
  if (Object.keys(save.combat_build.spellBehaviors ?? {}).length === 0) {
    throw new Error("expected spell behavior defaults in combat build");
  }
  if (
    !data.consumable_checks.some((check) =>
      check.id === "life_potion_stock" && check.profile_id === save.profile_id
    )
  ) {
    throw new Error("expected consumable checks");
  }
});
