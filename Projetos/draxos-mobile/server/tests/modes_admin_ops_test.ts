const PROJECT_PREFIX = "Projetos/draxos-mobile";

Deno.test("mode admin ops are gated by admin_roles and audited compensation", async () => {
  const migration = await projectText("supabase/migrations/202606010001_modes_platform_v1.sql");
  const edge = await projectText("server/functions/modes/index.ts");
  assertIncludes(migration, "create table if not exists public.admin_roles", "admin_roles should exist");
  assertIncludes(migration, "alter table public.admin_roles enable row level security", "admin_roles should use RLS");
  assertIncludes(edge, "loadAdminRole", "edge should check admin role");
  assertIncludes(edge, "ADMIN_FORBIDDEN", "edge should block non-admin users");
  assertIncludes(edge, "admin_adjust_resource_balance_v1", "compensation should use audited admin RPC");
});

async function projectText(relativePath: string): Promise<string> {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  const path = cwd.endsWith("/draxos-mobile") ? relativePath : `${PROJECT_PREFIX}/${relativePath}`;
  return await Deno.readTextFile(path);
}

function assertIncludes(haystack: string, needle: string, message: string): void {
  if (!haystack.includes(needle)) throw new Error(message);
}
