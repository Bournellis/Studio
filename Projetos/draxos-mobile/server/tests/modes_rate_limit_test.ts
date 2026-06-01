const PROJECT_PREFIX = "Projetos/draxos-mobile";

Deno.test("mode platform V1 declares default session limits", async () => {
  const migration = await projectText("supabase/migrations/202606010001_modes_platform_v1.sql");
  for (
    const fragment of [
      "create table if not exists public.mode_limit_policies",
      "max_active_sessions integer not null default 1",
      "start_cooldown_seconds integer not null default 10",
      "session_expiry_seconds integer not null default 7200",
      "daily_start_limit integer not null default 100",
      "('openworld', 'forest', 'openworld_forest_ruleset_v0', 1, 10, 7200, 100",
    ]
  ) {
    assertIncludes(migration, fragment, `rate-limit contract should include ${fragment}`);
  }
});

async function projectText(relativePath: string): Promise<string> {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  const path = cwd.endsWith("/draxos-mobile") ? relativePath : `${PROJECT_PREFIX}/${relativePath}`;
  return await Deno.readTextFile(path);
}

function assertIncludes(haystack: string, needle: string, message: string): void {
  if (!haystack.includes(needle)) throw new Error(message);
}
