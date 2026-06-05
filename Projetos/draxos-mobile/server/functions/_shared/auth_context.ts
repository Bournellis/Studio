import {
  SAVE_TYPE_HEADER,
  saveTypeFromRequest,
  type SaveType,
} from "./save_context.ts";

export interface AuthContext {
  userId: string;
  isAnonymous: boolean;
  saveType: SaveType;
}

export interface AuthUser {
  id?: unknown;
  email?: unknown;
  is_anonymous?: unknown;
}

export interface RestError {
  code: string;
  message: string;
  status: number;
}

export interface SupabaseAuthConfig {
  supabaseUrl: string;
  authApiKey?: string;
  publishableKey?: string;
  serviceRoleKey?: string;
}

export interface AuthContextOptions {
  requireExplicitSaveType?: boolean;
  missingSaveTypeMessage?: string;
}

interface JwtPayload {
  sub?: unknown;
  is_anonymous?: unknown;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{12}$/i;

export function decodeAuthContext(
  request: Request,
  options: AuthContextOptions = {},
): { value: AuthContext; error: null } | { value: null; error: RestError } {
  const tokenResult = bearerTokenFromRequest(request);
  if (tokenResult.error !== null) {
    return { value: null, error: tokenResult.error };
  }
  const subject = decodeBearerSubject(tokenResult.value);
  if (subject.error !== null) {
    return { value: null, error: subject.error };
  }
  const saveType = resolveSaveType(request, options);
  if (saveType.error !== null) {
    return { value: null, error: saveType.error };
  }
  return {
    value: {
      userId: subject.value.sub,
      isAnonymous: subject.value.isAnonymous,
      saveType: saveType.value,
    },
    error: null,
  };
}

export async function verifiedAuthContext(
  request: Request,
  config: SupabaseAuthConfig,
  options: AuthContextOptions = {},
): Promise<{ value: AuthContext; error: null } | { value: null; error: RestError }> {
  const tokenResult = bearerTokenFromRequest(request);
  if (tokenResult.error !== null) {
    return { value: null, error: tokenResult.error };
  }
  const token = tokenResult.value;
  const subject = decodeBearerSubject(token);
  if (subject.error !== null) {
    return { value: null, error: subject.error };
  }
  const authUser = await fetchAuthUser(config, token);
  if (authUser.error !== null) {
    return { value: null, error: authUser.error };
  }
  const userId = typeof authUser.value.id === "string" ? authUser.value.id : "";
  if (!UUID_PATTERN.test(userId)) {
    return {
      value: null,
      error: {
        code: "UNAUTHENTICATED",
        message: "Authenticated user id is invalid.",
        status: 401,
      },
    };
  }
  if (userId !== subject.value.sub) {
    return {
      value: null,
      error: {
        code: "UNAUTHENTICATED",
        message: "Bearer token subject mismatch.",
        status: 401,
      },
    };
  }
  const saveType = resolveSaveType(request, options);
  if (saveType.error !== null) {
    return { value: null, error: saveType.error };
  }
  return {
    value: {
      userId,
      isAnonymous: authUser.value.is_anonymous === true || subject.value.isAnonymous,
      saveType: saveType.value,
    },
    error: null,
  };
}

export function bearerTokenFromRequest(
  request: Request,
): { value: string; error: null } | { value: null; error: RestError } {
  const header = request.headers.get("authorization") ?? "";
  const prefix = "Bearer ";
  if (!header.startsWith(prefix)) {
    return {
      value: null,
      error: {
        code: "UNAUTHENTICATED",
        message: "Bearer token is required.",
        status: 401,
      },
    };
  }
  const token = header.slice(prefix.length).trim();
  if (token === "") {
    return {
      value: null,
      error: {
        code: "UNAUTHENTICATED",
        message: "Bearer token is required.",
        status: 401,
      },
    };
  }
  return { value: token, error: null };
}

export function decodeBearerSubject(
  token: string,
): { value: { sub: string; isAnonymous: boolean }; error: null } | {
  value: null;
  error: RestError;
} {
  const parts = token.split(".");
  if (parts.length < 2) {
    return {
      value: null,
      error: {
        code: "UNAUTHENTICATED",
        message: "Invalid bearer token.",
        status: 401,
      },
    };
  }
  const payload = decodeJwtPayload(parts[1]);
  if (payload === null || typeof payload.sub !== "string" || !UUID_PATTERN.test(payload.sub)) {
    return {
      value: null,
      error: {
        code: "UNAUTHENTICATED",
        message: "Token subject is invalid.",
        status: 401,
      },
    };
  }
  return {
    value: { sub: payload.sub, isAnonymous: payload.is_anonymous === true },
    error: null,
  };
}

async function fetchAuthUser(
  config: SupabaseAuthConfig,
  token: string,
): Promise<{ value: AuthUser; error: null } | { value: null; error: RestError }> {
  const apiKey = authApiKey(config);
  if (config.supabaseUrl.trim() === "" || apiKey === "") {
    return {
      value: null,
      error: {
        code: "SERVER_MISCONFIGURED",
        message: "Auth verification is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }
  const response = await fetch(`${config.supabaseUrl.replace(/\/$/, "")}/auth/v1/user`, {
    method: "GET",
    headers: authUserHeaders(apiKey, token),
  });
  const text = await response.text();
  const payload = text === "" ? null : parseJson(text);
  if (!response.ok || !isObject(payload)) {
    return {
      value: null,
      error: {
        code: "UNAUTHENTICATED",
        message: "Bearer token could not be verified by Supabase Auth.",
        status: 401,
      },
    };
  }
  return { value: payload as AuthUser, error: null };
}

function resolveSaveType(
  request: Request,
  options: AuthContextOptions,
): { value: SaveType; error: null } | { value: null; error: RestError } {
  const saveTypeHeader = request.headers.get(SAVE_TYPE_HEADER);
  if (options.requireExplicitSaveType === true && (saveTypeHeader === null || saveTypeHeader.trim() === "")) {
    return {
      value: null,
      error: {
        code: "INVALID_SAVE_TYPE",
        message: options.missingSaveTypeMessage ?? "x-draxos-save-type is required.",
        status: 400,
      },
    };
  }
  const saveType = saveTypeFromRequest(request);
  if (saveType === null) {
    return {
      value: null,
      error: {
        code: "INVALID_SAVE_TYPE",
        message: "Save type must be normal or progression_lab.",
        status: 400,
      },
    };
  }
  return { value: saveType, error: null };
}

function authApiKey(config: SupabaseAuthConfig): string {
  return (config.authApiKey ?? config.publishableKey ?? config.serviceRoleKey ?? "").trim();
}

function authUserHeaders(apiKey: string, token: string): Headers {
  const headers = new Headers();
  headers.set("accept", "application/json");
  headers.set("apikey", apiKey);
  headers.set("authorization", `Bearer ${token}`);
  return headers;
}

function decodeJwtPayload(encodedPayload: string): JwtPayload | null {
  try {
    const normalized = encodedPayload.replaceAll("-", "+").replaceAll("_", "/");
    const padded = normalized + "=".repeat((4 - normalized.length % 4) % 4);
    const bytes = Uint8Array.from(atob(padded), (character) => character.charCodeAt(0));
    const decoded = new TextDecoder().decode(bytes);
    const payload: unknown = JSON.parse(decoded);
    return isObject(payload) ? payload as JwtPayload : null;
  } catch {
    return null;
  }
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
