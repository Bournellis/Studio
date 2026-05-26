export type SaveType = "normal" | "progression_lab";

export const SAVE_TYPE_NORMAL: SaveType = "normal";
export const SAVE_TYPE_PROGRESSION_LAB: SaveType = "progression_lab";
export const SAVE_TYPE_HEADER = "x-draxos-save-type";

export function saveTypeFromRequest(request: Request): SaveType | null {
  const value = request.headers.get(SAVE_TYPE_HEADER);
  if (value === null || value.trim() === "") {
    return SAVE_TYPE_NORMAL;
  }
  return normalizeSaveType(value);
}

export function normalizeSaveType(value: string): SaveType | null {
  const normalized = value.trim().toLowerCase();
  if (normalized === SAVE_TYPE_NORMAL) {
    return SAVE_TYPE_NORMAL;
  }
  if (normalized === SAVE_TYPE_PROGRESSION_LAB) {
    return SAVE_TYPE_PROGRESSION_LAB;
  }
  return null;
}

export function saveTypeQuery(saveType: SaveType): string {
  return `save_type=eq.${encodeURIComponent(saveType)}`;
}

export function isProgressionLabSave(saveType: SaveType): boolean {
  return saveType === SAVE_TYPE_PROGRESSION_LAB;
}
