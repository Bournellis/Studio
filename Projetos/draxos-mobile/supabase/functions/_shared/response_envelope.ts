export const APP_RESPONSIVENESS_API_VERSION = "app_responsiveness_v1";

interface StateEnvelopeOptions {
  surface: string;
  saveType?: string;
  schemaVersion?: string;
  startedAtMs?: number;
  account?: unknown;
  save?: unknown;
  generatedAt?: Date;
}

export function stateEnvelope<T extends Record<string, unknown>>(
  payload: T,
  options: StateEnvelopeOptions,
): T & {
  ok: true;
  schema_version: string;
  api_version: string;
  account: unknown;
  save: unknown;
  cache: { surface: string; generated_at: string };
  server_timing: { duration_ms: number };
} {
  const generatedAt = options.generatedAt ?? new Date();
  const save = options.save ?? { save_type: options.saveType ?? String(payload.save_type ?? "") };
  return {
    ...payload,
    ok: true,
    schema_version: options.schemaVersion ?? String(payload.schema_version ?? `${options.surface}_state_v1`),
    api_version: APP_RESPONSIVENESS_API_VERSION,
    account: options.account ?? payload.account ?? null,
    save,
    cache: {
      surface: options.surface,
      generated_at: generatedAt.toISOString(),
    },
    server_timing: {
      duration_ms: elapsedMs(options.startedAtMs),
    },
  };
}

export function elapsedMs(startedAtMs?: number): number {
  if (startedAtMs === undefined) return 0;
  return Math.max(0, Math.round(performance.now() - startedAtMs));
}
