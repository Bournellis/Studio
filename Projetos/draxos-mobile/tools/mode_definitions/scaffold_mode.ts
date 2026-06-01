import { renderModeScaffold } from "./scaffold.ts";

const PROJECT_ROOT = new URL("../../", import.meta.url);

interface CliOptions {
  modeId: string;
  displayName: string;
  summary: string;
  fullscreen: boolean;
  write: boolean;
  force: boolean;
}

if (import.meta.main) {
  const options = parseArgs(Deno.args);
  const scaffold = renderModeScaffold(options);
  if (!options.write) {
    console.log(JSON.stringify(
      {
        mode_id: scaffold.modeId,
        descriptor_path: scaffold.descriptorPath,
        placeholder_path: scaffold.placeholderPath,
        doc_path: scaffold.docPath,
        descriptor: scaffold.descriptor,
        placeholder: scaffold.placeholder,
        doc_body: scaffold.docBody,
      },
      null,
      2,
    ));
  } else {
    await writeScaffold(scaffold, options.force);
    console.log("[scaffold-mode] OK", {
      mode_id: scaffold.modeId,
      descriptor_path: scaffold.descriptorPath,
      placeholder_path: scaffold.placeholderPath,
      doc_path: scaffold.docPath,
    });
  }
}

async function writeScaffold(
  scaffold: ReturnType<typeof renderModeScaffold>,
  force: boolean,
): Promise<void> {
  const writes = [
    {
      path: scaffold.descriptorPath,
      body: `${JSON.stringify(scaffold.descriptor, null, 2)}\n`,
    },
    {
      path: scaffold.placeholderPath,
      body: `${JSON.stringify(scaffold.placeholder, null, 2)}\n`,
    },
    { path: scaffold.docPath, body: scaffold.docBody },
  ];

  for (const write of writes) {
    const target = new URL(write.path, PROJECT_ROOT);
    if (!force && await exists(target)) {
      throw new Error(
        `${write.path} already exists. Use --force to overwrite.`,
      );
    }
  }

  for (const write of writes) {
    const target = new URL(write.path, PROJECT_ROOT);
    await Deno.mkdir(new URL(".", target), { recursive: true });
    await Deno.writeTextFile(target, write.body);
  }
}

async function exists(path: URL): Promise<boolean> {
  try {
    await Deno.stat(path);
    return true;
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      return false;
    }
    throw error;
  }
}

function parseArgs(args: string[]): CliOptions {
  if (args.includes("--help") || args.includes("-h")) {
    printHelp();
    Deno.exit(0);
  }

  const modeId = stringFlag(args, "--mode-id");
  const displayName = stringFlag(args, "--display-name");
  const summary = stringFlag(args, "--summary");
  if (
    modeId === undefined || displayName === undefined || summary === undefined
  ) {
    printHelp();
    throw new Error("--mode-id, --display-name and --summary are required.");
  }

  return {
    modeId,
    displayName,
    summary,
    fullscreen: args.includes("--fullscreen"),
    write: args.includes("--write"),
    force: args.includes("--force"),
  };
}

function stringFlag(args: string[], name: string): string | undefined {
  const index = args.indexOf(name);
  if (index < 0) {
    return undefined;
  }
  const value = args[index + 1];
  if (value === undefined || value.startsWith("--")) {
    throw new Error(`${name} requires a value.`);
  }
  return value;
}

function printHelp(): void {
  console.log(`Usage:
  npx -y deno run --allow-read --allow-write tools/mode_definitions/scaffold_mode.ts --mode-id <id> --display-name <name> --summary <summary> [--fullscreen] [--write] [--force]

Default mode is dry-run JSON output. --write creates:
  data/definitions/modes/<id>/metadata.json
  data/definitions/modes/<id>/placeholder.json
  docs/minigames/<id>.md

The generated scaffold is planned_disabled, rewardless and non-launchable.`);
}
