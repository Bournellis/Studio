import { renderModeScaffold } from "../../tools/mode_definitions/scaffold.ts";
import {
  type JsonObject,
  type ModeDefinitionIssue,
  OFFICIAL_MODE_IDS,
  validateModeDefinitionBundle,
  validateOfficialModeDirectoryNames,
  validateTemplateScaffold,
} from "../../tools/mode_definitions/schema.ts";
import { validateModeDefinitions } from "../../tools/mode_definitions/validate.ts";

const PROJECT_ROOT = new URL("../../", import.meta.url);

Deno.test("mode definition filesystem passes the strict schema", async () => {
  const issues = await validateModeDefinitions(PROJECT_ROOT);
  assertNoIssues(issues);
});

Deno.test("mode definition folders are exactly the five official modes", async () => {
  const discovered: string[] = [];
  for await (
    const entry of Deno.readDir(
      new URL("data/definitions/modes/", PROJECT_ROOT),
    )
  ) {
    if (entry.isDirectory && entry.name !== "_template") {
      discovered.push(entry.name);
    }
  }
  assertNoIssues(validateOfficialModeDirectoryNames(discovered));
  assertEquals(
    discovered.sort((left, right) => left.localeCompare(right, "en")),
    [...OFFICIAL_MODE_IDS].sort((left, right) =>
      left.localeCompare(right, "en")
    ),
    "official mode directory list",
  );
});

Deno.test("strict mode schema rejects extra descriptor fields", async () => {
  const descriptor = await readJsonObject(
    "data/definitions/modes/cardgame/metadata.json",
  );
  const placeholder = await readJsonObject(
    "data/definitions/modes/cardgame/placeholder.json",
  );
  const issues = validateModeDefinitionBundle({
    modeId: "cardgame",
    descriptor: { ...descriptor, playable: true },
    placeholder,
  });
  assert(
    issues.some((issue) =>
      issue.path === "cardgame/metadata.json" &&
      issue.message === "unexpected field playable"
    ),
    "strict schema should reject fields outside the descriptor contract",
  );
});

Deno.test("future mode scaffold renders disabled and rewardless output", () => {
  const scaffold = renderModeScaffold({
    modeId: "relicrace",
    displayName: "Relic Race",
    summary: "Future diagnostic scaffold for a staged mode.",
    fullscreen: true,
  });

  assertEquals(scaffold.modeId, "relicrace", "mode id");
  assertEquals(scaffold.descriptor.status, "planned_disabled", "status");
  assertEquals(
    scaffold.descriptor.release_channel,
    "staged",
    "release channel",
  );
  assertEquals(scaffold.descriptor.public_cta, false, "public CTA");
  assertEquals(scaffold.placeholder.playable, false, "playable");
  assertEquals(scaffold.placeholder.launchable, false, "launchable");
  assertEquals(scaffold.placeholder.reward_enabled, false, "reward enabled");
  assertEquals(scaffold.placeholder.runtime, "none", "runtime");
  assertStringIncludes(scaffold.docBody, "No gameplay.");
  assertStringIncludes(scaffold.docBody, "No backend or schema mutation.");
});

Deno.test("future mode templates remain strict planned-disabled scaffolds", async () => {
  const descriptor = await readJsonObject(
    "data/definitions/modes/_template/metadata.template.json",
  );
  const placeholder = await readJsonObject(
    "data/definitions/modes/_template/placeholder.template.json",
  );
  assertNoIssues(validateTemplateScaffold(descriptor, placeholder));
});

Deno.test("mode decision packs keep future modes behind package decisions", async () => {
  for (
    const [path, requiredText] of [
      [
        "docs/minigames/openworld-decision-pack.md",
        "No Openworld expansion is approved by this pack.",
      ],
      [
        "docs/minigames/towerdefense-decision-pack.md",
        "Towerdefense remains staged/disabled.",
      ],
      [
        "docs/minigames/cardgame-decision-pack.md",
        "Cardgame remains staged/disabled.",
      ],
    ] as const
  ) {
    const text = await Deno.readTextFile(new URL(path, PROJECT_ROOT));
    assertStringIncludes(text, "No runtime gameplay change");
    assertStringIncludes(text, "No backend mutation");
    assertStringIncludes(text, requiredText);
  }
});

async function readJsonObject(relativePath: string): Promise<JsonObject> {
  const payload = JSON.parse(
    await Deno.readTextFile(new URL(relativePath, PROJECT_ROOT)),
  ) as unknown;
  assert(isObject(payload), `${relativePath} should be a JSON object`);
  return payload;
}

function assertNoIssues(issues: ModeDefinitionIssue[]): void {
  if (issues.length > 0) {
    throw new Error(
      issues.map((issue) => `${issue.path}: ${issue.message}`).join("\n"),
    );
  }
}

function assertStringIncludes(haystack: string, needle: string): void {
  if (!haystack.includes(needle)) {
    throw new Error(`expected text to include ${needle}`);
  }
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEquals(
  actual: unknown,
  expected: unknown,
  message: string,
): void {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}

function isObject(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
