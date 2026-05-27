const PROJECT_PREFIX = "Projetos/draxos-mobile";

const SERVICE_SCOPES = new Set([
  "save-scoped",
  "account-scoped",
  "release",
  "telemetry",
  "admin-future",
  "none",
]);

const FEATURE_STATUSES = new Set([
  "PLANNED",
  "IN_PROGRESS",
  "READY_FOR_INTEGRATION",
  "INTEGRATED",
  "BLOCKED",
  "DEFERRED",
]);

const REQUIRED_FEATURE_FIELDS = [
  "Owner",
  "Surface",
  "Status",
  "Endpoints affected",
  "Service scope",
  "Service contract notes",
  "Client files",
  "Backend files",
  "Smoke required",
  "GUT required",
  "Other validation",
  "Fallback",
  "Rollback",
  "Guardrail notes",
  "Handoff notes",
];

Deno.test("endpoint matrix declares service scope for every current endpoint", async () => {
  const apiContract = await readProjectText("docs/contracts/api-endpoints.md");
  const matrixSection = extractBetween(
    apiContract,
    "### Matriz Atual De Endpoints",
    "## Endpoints De Release",
  );
  const rows = parseMarkdownTable(matrixSection);
  assert(rows.length > 0, "endpoint matrix should contain endpoint rows");

  const endpoints = new Set<string>();
  for (const row of rows) {
    assert(
      row.length >= 6,
      `endpoint matrix row should have six cells: ${row.join(" | ")}`,
    );
    const [method, endpoint, scope, saveHeader, idempotency] = row;
    const cleanScope = cleanInlineCode(scope);
    assert(
      method !== "",
      `endpoint matrix row should declare method for ${endpoint}`,
    );
    assert(
      endpoint !== "",
      "endpoint matrix row should declare endpoint/function",
    );
    assert(
      SERVICE_SCOPES.has(cleanScope),
      `endpoint ${endpoint} should declare a valid scope, got '${scope}'`,
    );
    assert(
      saveHeader !== "",
      `endpoint ${endpoint} should declare save-header behavior`,
    );
    assert(
      idempotency !== "",
      `endpoint ${endpoint} should declare idempotency behavior`,
    );
    assert(
      !endpoints.has(endpoint),
      `endpoint matrix should not duplicate ${endpoint}`,
    );
    endpoints.add(endpoint);
  }
});

Deno.test("feature registry cards have complete contract fields", async () => {
  const registry = await readProjectText(
    "implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md",
  );
  const cardsSection = extractBetween(
    registry,
    "## Feature Cards",
    "## Template For New Feature Cards",
  );
  const cards = splitFeatureCards(cardsSection);
  assert(cards.length > 0, "feature registry should contain feature cards");

  for (const card of cards) {
    const fields = parseFeatureFields(card.body);
    for (const fieldName of REQUIRED_FEATURE_FIELDS) {
      assert(
        fields.has(fieldName),
        `${card.id} should include field '${fieldName}'`,
      );
      const value = fields.get(fieldName) ?? "";
      assertCompleteValue(value, `${card.id} field '${fieldName}'`);
    }

    const status = cleanInlineCode(fields.get("Status") ?? "");
    assert(
      FEATURE_STATUSES.has(status),
      `${card.id} should use an allowed status, got '${status}'`,
    );

    const serviceScope = serviceScopeToken(fields.get("Service scope") ?? "");
    assert(
      SERVICE_SCOPES.has(serviceScope),
      `${card.id} should declare an allowed service scope, got '${
        fields.get("Service scope")
      }'`,
    );
  }
});

async function readProjectText(relativePath: string): Promise<string> {
  return await Deno.readTextFile(projectFile(relativePath));
}

function projectFile(relativePath: string): string {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  if (cwd.endsWith("/draxos-mobile")) {
    return relativePath;
  }
  return `${PROJECT_PREFIX}/${relativePath}`;
}

function extractBetween(
  text: string,
  startMarker: string,
  endMarker: string,
): string {
  const start = text.indexOf(startMarker);
  assert(start >= 0, `missing section start '${startMarker}'`);
  const sectionStart = start + startMarker.length;
  const end = text.indexOf(endMarker, sectionStart);
  assert(end >= 0, `missing section end '${endMarker}'`);
  return text.slice(sectionStart, end);
}

function parseMarkdownTable(section: string): string[][] {
  const lines = section.split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.startsWith("|"));
  assert(
    lines.length >= 3,
    "markdown table should include header, separator and rows",
  );

  const header = parseTableLine(lines[0]);
  assert(
    header.includes("Escopo"),
    "endpoint matrix table should include Escopo column",
  );

  return lines.slice(2)
    .filter((line) => !/^\|\s*-/.test(line))
    .map(parseTableLine);
}

function parseTableLine(line: string): string[] {
  return line.replace(/^\|/, "").replace(/\|$/, "").split("|").map((cell) =>
    cell.trim()
  );
}

interface FeatureCard {
  id: string;
  body: string;
}

function splitFeatureCards(section: string): FeatureCard[] {
  const headingPattern = /^### `([^`]+)`\s*$/gm;
  const matches = [...section.matchAll(headingPattern)];
  return matches.map((match, index) => {
    const next = matches[index + 1];
    return {
      id: match[1],
      body: section.slice(
        match.index! + match[0].length,
        next?.index ?? section.length,
      ),
    };
  });
}

function parseFeatureFields(body: string): Map<string, string> {
  const fields = new Map<string, string>();
  for (const line of body.split(/\r?\n/)) {
    const match = line.match(/^- ([^:]+):\s*(.*)$/);
    if (match) {
      fields.set(match[1].trim(), match[2].trim());
    }
  }
  return fields;
}

function assertCompleteValue(value: string, label: string): void {
  const cleaned = cleanInlineCode(value).trim();
  assert(cleaned !== "", `${label} should not be empty`);
  assert(!/\bTBD\b/i.test(cleaned), `${label} should not contain TBD`);
  assert(!/\bunknown\b/i.test(cleaned), `${label} should not contain unknown`);
}

function serviceScopeToken(value: string): string {
  const cleaned = cleanInlineCode(value).replace(/[.,;:]+$/g, "").trim();
  return cleaned.split(/\s+/)[0] ?? "";
}

function cleanInlineCode(value: string): string {
  return value.replaceAll("`", "").trim();
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}
