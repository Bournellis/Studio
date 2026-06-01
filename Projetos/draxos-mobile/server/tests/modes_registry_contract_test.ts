const PROJECT_PREFIX = "Projetos/draxos-mobile";

Deno.test("mode registry contract declares the five official modes", async () => {
  const migration = await projectText("supabase/migrations/202606010001_modes_platform_v1.sql");
  const clientRegistry = await projectText("modes/boot/ui/mode_shell_registry.gd");
  for (const modeId of ["basebuilder", "autobattler", "towerdefense", "cardgame", "openworld"]) {
    assertIncludes(migration, `'${modeId}'`, `migration should seed ${modeId}`);
    assertIncludes(clientRegistry, `"${modeId}"`, `client registry should declare ${modeId}`);
  }
  assertIncludes(clientRegistry, "display_name", "client registry should expose display names");
  assertIncludes(clientRegistry, "hub_entries", "client registry should expose hub ordering");
});

async function projectText(relativePath: string): Promise<string> {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  const path = cwd.endsWith("/draxos-mobile") ? relativePath : `${PROJECT_PREFIX}/${relativePath}`;
  return await Deno.readTextFile(path);
}

function assertIncludes(haystack: string, needle: string, message: string): void {
  if (!haystack.includes(needle)) {
    throw new Error(`${message}. Missing: ${needle}`);
  }
}
