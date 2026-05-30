# Account And Save Contract

- Status: `CONTRATO`
- Contract id: `ACCOUNT_SAVE_CONTRACT_V1`
- Ultima atualizacao: `2026-05-30`
- Migration base: `202605300001_foundation_expansion_readiness.sql`
- Closeout migration: `202605300004_foundation_closeout.sql`

## Decisao

DraxosMobile nao deve escalar social, recompensas, minigames, seasons ou suporte usando `players.save_type` como fonte real de conta/save. A partir da Foundation Expansion Readiness:

- `account_profiles` e a entidade account-wide.
- `game_saves` e a entidade de progresso por save.
- `players` permanece como compat layer alpha e alias legado de save enquanto endpoints antigos ainda usam `player_id`.

## Entidades

### `account_profiles`

Identidade de conta, suporte, social identity futura e entitlement base.

Campos contratuais:

- `id`
- `auth_user_id`
- `canonical_player_id`
- `username`
- `account_type`
- `status`
- `metadata`
- `created_at`
- `updated_at`

Regras:

- Uma conta Supabase Auth possui no maximo um `account_profiles`.
- `canonical_player_id` aponta para o player/save legado preferencial enquanto existir compatibilidade com `players`.
- Social account-wide deve resolver por `account_profiles`, nao por save Lab.
- Admin/support deve localizar conta por `auth_user_id`, `username`, `canonical_player_id` ou `account_profile_id`.

### `game_saves`

Progresso por save, save type, contexto de ruleset e estado versionado.

Campos contratuais:

- `id`
- `account_profile_id`
- `legacy_player_id`
- `save_type`
- `slot_key`
- `display_name`
- `lifecycle_status`
- `ruleset_id`
- `ruleset_version`
- `ruleset_publication_id`
- `ruleset_content_hash`
- `ruleset_simulator_hash`
- `ruleset_schema_version`
- `state_version`
- `season_context`
- `snapshot`
- `created_at`
- `updated_at`

Regras:

- `save_type` inicial aceita `normal` e `progression_lab`.
- `legacy_player_id` e ponte temporaria para tabelas alpha que ainda usam `player_id`.
- Novos sistemas devem declarar se referenciam `game_save_id`, `account_profile_id` ou mantem `legacy_player_id` por compatibilidade.
- Save normal, Progression Lab e futuros saves devem ser modelados em `game_saves`.
- `state_version` comeca em `1` e permite migracoes futuras de snapshot/save.
- `season_context` comeca em `{"season_id":"alpha_0","channel":"internal_alpha"}`.
- Contexto de ruleset salvo no save deve apontar para a publicacao usada para
  explicar estado, reward, replay e diagnostico.
- `snapshot` e somente contexto compacto; o estado autoritativo continua nas tabelas de dominio ate migracao dedicada.

## Compatibilidade

`players.save_type` nao e removido nesta fundacao. Ele continua necessario porque Edge Functions existentes e tabelas alpha usam `player_id`. A regra de expansao e:

1. criar/garantir `account_profiles` e `game_saves`;
2. continuar aceitando endpoints antigos;
3. fazer contratos novos dependerem de account/save explicito;
4. migrar tabelas de dominio por lane quando houver pacote proprio.

## RPC De Bootstrap

`ensure_foundation_profile_and_saves(p_auth_user_id, p_ruleset_id)` cria ou sincroniza o perfil e saves a partir dos `players` existentes.

Resposta logica:

```json
{
  "ok": true,
  "account_profile_id": "uuid",
  "auth_user_id": "uuid",
  "canonical_player_id": "uuid",
  "save_count": 2
}
```

Uso:

- pos-migration;
- bootstrap de conta guest ou email/alpha;
- reparo de dados antes de expandir social/admin/minigame.

Nao usar este RPC para conceder recompensa ou resetar progresso.

## Retorno De Estado

Endpoints de estado devem evoluir para expor contexto explicito:

```json
{
  "account": {
    "account_profile_id": "uuid",
    "auth_user_id": "uuid",
    "status": "active"
  },
  "save": {
    "game_save_id": "uuid",
    "save_type": "normal",
    "legacy_player_id": "uuid",
    "ruleset_id": "foundation_ruleset_v0",
    "ruleset_version": 1,
    "ruleset_publication_id": "uuid",
    "state_version": 1,
    "season_context": {
      "season_id": "alpha_0",
      "channel": "internal_alpha"
    }
  },
  "ruleset": {
    "publication_id": "uuid",
    "ruleset_id": "foundation_ruleset_v0",
    "ruleset_version": 1,
    "content_hash": "sha256",
    "simulator_hash": "sha256",
    "schema_version": "foundation_ruleset_manifest_v1"
  }
}
```

Campos extras sao permitidos. Cliente deve tolerar ausencia temporaria enquanto endpoints legados ainda retornam apenas `player`.

## Expansao

Antes de qualquer novo minigame, social expandido ou season:

- declarar escopo: account, save, minigame ou release;
- decidir se a chave primaria nova e `account_profile_id`, `game_save_id` ou ambos;
- proibir `players.save_type` como fonte primaria nova;
- declarar rollback/disable para saves antigos;
- testar RLS/token forjado quando endpoint expor leitura client-side.
