const PROJECT_PREFIX = "Projetos/draxos-mobile";

Deno.test("mode platform V1 supports disable and session rollback states", async () => {
  const migration = await projectText("supabase/migrations/202606010001_modes_platform_v1.sql");
  const edge = await projectText("server/functions/modes/index.ts");
  for (const fragment of ["planned_disabled", "paused", "expired", "invalidated", "invalidated_reason"]) {
    assertIncludes(migration, fragment, `migration should include ${fragment}`);
  }
  for (const route of ["/admin/disable", "/admin/enable", "/admin/session/expire", "/admin/session/invalidate"]) {
    assertIncludes(edge, route, `edge should expose ${route}`);
  }
  assertIncludes(edge, "MODE_DISABLED", "disabled modes should reject session starts");
});

async function projectText(relativePath: string): Promise<string> {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  const path = cwd.endsWith("/draxos-mobile") ? relativePath : `${PROJECT_PREFIX}/${relativePath}`;
  return await Deno.readTextFile(path);
}

function assertIncludes(haystack: string, needle: string, message: string): void {
  if (!haystack.includes(needle)) throw new Error(message);
}
