# Minigame Platform V0 Contract

- Status: `CONTRATO`
- Contract id: `MINIGAME_PLATFORM_V0`
- Ultima atualizacao: `2026-05-31`
- Primeiro modo: `rpgsuave`

## Regras

Minigames com recompensa real usam estado save-scoped e nunca escrevem direto em
Base/Conta pelo cliente. O cliente pode produzir um resultado local, mas o
servidor decide se aceita, clampa, rejeita e aplica recompensa.

Toda mutacao exige:

- JWT Supabase;
- `x-draxos-api-version: 1`;
- `x-draxos-save-type`;
- `request_id`;
- `request_hash`;
- RPC `security definer` com grant apenas para `service_role`;
- ledger quando afetar recursos ou XP.

## Identidade

| Campo | Valor v0 |
|---|---|
| `mode_id` | `rpgsuave` |
| `slice_id` | `forest` |
| `ruleset_id` | `rpgsuave_forest_ruleset_v0` |
| `ruleset_version` | `1` |
| `release_channel` | `internal_alpha` |
| `entry_action` | `open_minigame_shell:rpgsuave` |

## Schema

Migration: `202606010000_minigame_platform_v0.sql`.

Tabelas:

- `mode_registry`: modos e canal permitido;
- `mode_ruleset_registry`: ruleset ativo por modo/slice;
- `mode_sessions`: start/complete de sessoes;
- `mode_progress`: progresso isolado por `game_save_id + mode_id`;
- `mode_reward_claims`: aplicacoes de recompensa e limites diarios.

Leitura usa RLS para o dono do save. Escrita acontece por RPC.

## Endpoints

| Metodo | Endpoint | Uso |
|---|---|---|
| GET | `/minigames/registry` | lista modos/rulesets disponiveis |
| GET | `/minigames/state?mode_id=rpgsuave` | estado do modo no save ativo |
| POST | `/minigames/session/start` | inicia sessao server-authoritative |
| POST | `/minigames/session/complete` | completa sessao e aplica reward bridge |

## Complete Result V0

Payload aceito:

```json
{
  "request_id": "uuid",
  "session_id": "uuid",
  "mode_id": "rpgsuave",
  "slice_id": "forest",
  "ruleset_id": "rpgsuave_forest_ruleset_v0",
  "ruleset_version": 1,
  "session_seconds": 120,
  "activity_score": 42,
  "deposited_items": {
    "galho": 2,
    "ossos_preview": 3
  },
  "request_hash": "sha256:..."
}
```

O servidor rejeita modo/ruleset incorreto, sessao inexistente, `progression_lab`
para recompensa real, duracao fora de `5..1800`, score acima de `500`, item
desconhecido ou quantidade acima de `999`.

## Response V0

Resposta de sucesso de complete:

```json
{
  "ok": true,
  "schema_version": "minigame_platform_v0",
  "request_id": "uuid",
  "request_hash": "sha256:...",
  "mode": {},
  "session": {},
  "reward": {},
  "resources": {},
  "limits": {},
  "server_time": "timestamp"
}
```

## Validacao

- `npx -y deno task check` em `server/functions` e `supabase/functions`;
- `npx -y deno test --allow-read server/tests/minigame_domain_test.ts server/tests/minigame_platform_schema_test.ts`;
- `tools/smoke_rpgsuave_forest.gd`;
- GUT client para SessionStore/SupabaseClient/minigame local.

## Publicacao 2026-05-31

O contrato v0 foi publicado no Internal Alpha a partir da branch
`codex/draxos-mobile/rpgsuave-integrated-alpha`.

- Migration remota aplicada: `202606010000_minigame_platform_v0.sql`.
- Edge Function remota publicada: `minigames`.
- Release root:
  `internal-alpha/v0-rpgsuave-integrated-alpha-20260531-0aa3969`.
- Full gate local: `tools/validate_foundation.ps1 -ProjectDir . -Profile Full
  -RequireClean` passou.
- Smoke remoto integrado: email auth, battle request, minigame
  start/complete idempotente, bloqueio de recompensa em `progression_lab` e
  release manifest passaram.
- Smoke de artefatos: manifest remoto, Portal/Web, APK/ZIP e hash remoto
  completo de APK/ZIP passaram.

Proximo gate: playtest humano do `Rpgsuave Bosque` publicado. Mudancas de
economia, tuning numerico, CTA publico ou fullscreen devem abrir pacote proprio.
