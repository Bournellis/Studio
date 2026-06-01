import {
  type JsonObject,
  type ModeDefinitionIssue,
  OFFICIAL_MODE_IDS,
  validateModeDefinitionBundle,
  validateOfficialModeDirectoryNames,
  validateTemplateScaffold,
} from "./schema.ts";

const PROJECT_ROOT = new URL("../../", import.meta.url);

if (import.meta.main) {
  const issues = await validateModeDefinitions(PROJECT_ROOT);
  if (issues.length > 0) {
    for (const issue of issues) {
      console.error(`[mode-definitions][FAIL] ${issue.path}: ${issue.message}`);
    }
    Deno.exit(1);
  }
  console.log("[mode-definitions] OK", {
    official_modes: OFFICIAL_MODE_IDS.length,
  });
}

export async function validateModeDefinitions(
  projectRoot: URL,
): Promise<ModeDefinitionIssue[]> {
  const issues: ModeDefinitionIssue[] = [];
  const modesRoot = new URL("data/definitions/modes/", projectRoot);
  const discoveredModeIds: string[] = [];

  for await (const entry of Deno.readDir(modesRoot)) {
    if (!entry.isDirectory || entry.name === "_template") {
      continue;
    }
    discoveredModeIds.push(entry.name);
  }

  issues.push(...validateOfficialModeDirectoryNames(discoveredModeIds));
  const registryText = await Deno.readTextFile(
    new URL("modes/boot/ui/mode_shell_registry.gd", projectRoot),
  );

  for (const modeId of OFFICIAL_MODE_IDS) {
    const descriptor = await readJsonObject(
      new URL(`data/definitions/modes/${modeId}/metadata.json`, projectRoot),
      issues,
    );
    const placeholder = await readJsonObject(
      new URL(`data/definitions/modes/${modeId}/placeholder.json`, projectRoot),
      issues,
    );
    if (descriptor !== undefined && placeholder !== undefined) {
      issues.push(
        ...validateModeDefinitionBundle({
          modeId,
          descriptor,
          placeholder,
          registryText,
        }),
      );
    }
    await assertFileExists(
      new URL(`docs/minigames/${modeId}.md`, projectRoot),
      `docs/minigames/${modeId}.md`,
      issues,
    );
  }

  const templateDescriptor = await readJsonObject(
    new URL(
      "data/definitions/modes/_template/metadata.template.json",
      projectRoot,
    ),
    issues,
  );
  const templatePlaceholder = await readJsonObject(
    new URL(
      "data/definitions/modes/_template/placeholder.template.json",
      projectRoot,
    ),
    issues,
  );
  if (templateDescriptor !== undefined && templatePlaceholder !== undefined) {
    issues.push(
      ...validateTemplateScaffold(templateDescriptor, templatePlaceholder),
    );
  }

  return issues;
}

async function readJsonObject(
  path: URL,
  issues: ModeDefinitionIssue[],
): Promise<JsonObject | undefined> {
  try {
    const payload = JSON.parse(await Deno.readTextFile(path)) as unknown;
    if (!isObject(payload)) {
      issues.push({
        path: toProjectPath(path),
        message: "JSON root must be an object",
      });
      return undefined;
    }
    return payload;
  } catch (error) {
    issues.push({
      path: toProjectPath(path),
      message: error instanceof Error ? error.message : String(error),
    });
    return undefined;
  }
}

async function assertFileExists(
  path: URL,
  label: string,
  issues: ModeDefinitionIssue[],
): Promise<void> {
  try {
    const stat = await Deno.stat(path);
    if (!stat.isFile) {
      issues.push({ path: label, message: "expected a file" });
    }
  } catch (error) {
    issues.push({
      path: label,
      message: error instanceof Error ? error.message : String(error),
    });
  }
}

function toProjectPath(path: URL): string {
  return decodeURIComponent(path.pathname)
    .replace(PROJECT_ROOT.pathname, "")
    .replace(/^\//, "");
}

function isObject(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
