const PROJECT_PREFIX = "Projetos/draxos-mobile";

Deno.test("mode admin ops are gated by admin_roles and audited compensation", async () => {
  const migration = await projectText("supabase/migrations/202606010001_modes_platform_v1.sql");
  const hardening = await projectText(
    "supabase/migrations/202606010002_modes_admin_audit_hardening.sql",
  );
  const edge = await projectText("server/functions/modes/mode_handler.ts");
  assertIncludes(
    migration,
    "create table if not exists public.admin_roles",
    "admin_roles should exist",
  );
  assertIncludes(
    migration,
    "alter table public.admin_roles enable row level security",
    "admin_roles should use RLS",
  );
  assertIncludes(edge, "loadAdminRole", "edge should check admin role");
  assertIncludes(edge, "ADMIN_FORBIDDEN", "edge should block non-admin users");
  assertIncludes(
    edge,
    "admin_adjust_resource_balance_v1",
    "compensation should use audited admin RPC",
  );
  for (
    const rpc of [
      "admin_set_mode_status_v1",
      "admin_expire_mode_session_v1",
      "admin_invalidate_mode_session_v1",
    ]
  ) {
    assertIncludes(hardening, `create or replace function public.${rpc}`, `${rpc} should exist`);
    assertIncludes(edge, `rpc/${rpc}`, `edge should call ${rpc}`);
    assertIncludes(
      hardening,
      `where action = '${rpc}'`,
      `${rpc} should dedupe through admin audit`,
    );
  }
  assertNotIncludes(
    codeSection(
      edge,
      "async function handleAdminModeStatus",
      "async function handleAdminReconcile",
    ),
    'method: "PATCH"',
    "admin mode/session routes should not PATCH mode tables directly",
  );
});

async function projectText(relativePath: string): Promise<string> {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  const path = cwd.endsWith("/draxos-mobile") ? relativePath : `${PROJECT_PREFIX}/${relativePath}`;
  return await Deno.readTextFile(path);
}

function assertIncludes(haystack: string, needle: string, message: string): void {
  if (!haystack.includes(needle)) throw new Error(message);
}

function assertNotIncludes(haystack: string, needle: string, message: string): void {
  if (haystack.includes(needle)) throw new Error(message);
}

function codeSection(haystack: string, start: string, end: string): string {
  const startIndex = haystack.indexOf(start);
  const endIndex = haystack.indexOf(end);
  if (startIndex < 0 || endIndex <= startIndex) throw new Error(`missing section ${start}`);
  return haystack.slice(startIndex, endIndex);
}
