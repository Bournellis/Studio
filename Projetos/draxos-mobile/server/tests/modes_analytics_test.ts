const PROJECT_PREFIX = "Projetos/draxos-mobile";

Deno.test("mode analytics contract exposes summary and telemetry dimensions", async () => {
  const edge = await projectText("server/functions/modes/index.ts");
  const contract = await projectText("docs/contracts/minigame-platform-v1.md");
  assertIncludes(edge, "/analytics/summary", "edge should expose analytics summary");
  assertIncludes(edge, "mode_analytics_v1", "edge should return analytics schema");
  for (const event of ["mode_hub_shown", "mode_card_selected", "mode_session_completed", "mode_reward_applied"]) {
    assertIncludes(contract, event, `contract should declare ${event}`);
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
