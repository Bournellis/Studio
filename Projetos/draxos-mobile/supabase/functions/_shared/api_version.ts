import { jsonResponse } from "./http.ts";

export const DRAXOS_API_VERSION = "1";
export const DRAXOS_API_VERSION_HEADER = "x-draxos-api-version";

export function validateApiVersion(request: Request): Response | null {
  const rawVersion = request.headers.get(DRAXOS_API_VERSION_HEADER);
  if (rawVersion === null || rawVersion.trim() === "") {
    return null;
  }
  if (rawVersion.trim() === DRAXOS_API_VERSION) {
    return null;
  }
  return jsonResponse(
    {
      ok: false,
      error: {
        code: "UNSUPPORTED_API_VERSION",
        message:
          `Unsupported Draxos API version. Use ${DRAXOS_API_VERSION_HEADER}: ${DRAXOS_API_VERSION}.`,
      },
    },
    400,
  );
}
