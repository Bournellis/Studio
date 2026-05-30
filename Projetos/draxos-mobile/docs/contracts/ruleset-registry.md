# Ruleset Registry Contract

- Status: `CONTRATO`
- Contract id: `RULESET_REGISTRY_CONTRACT_V1`
- Ultima atualizacao: `2026-05-30`
- Migration base: `202605300001_foundation_expansion_readiness.sql`
- Closeout migration: `202605300004_foundation_closeout.sql`
- Current ruleset: `foundation_ruleset_v0`

## Decisao

O DraxosMobile usa uma terceira via:

- ruleset gerado no repo como fonte de autoria;
- banco como registry de publicacao;
- server, client, labs, portal e testes consomem artefatos compativeis do mesmo pacote.

O banco nao e ferramenta de autoria de balanceamento. Ele registra o que foi publicado, em qual canal/cohort, com hashes que permitem diagnostico e replay.

## Artefatos

| Artefato | Papel |
|---|---|
| `data/rulesets/foundation_ruleset_v0.json` | Manifest gerado e versionado do ruleset. |
| `tools/generate_foundation_ruleset.ts` | Gerador deterministico do manifest e mirrors TS. |
| `server/functions/_shared/foundation_ruleset.ts` | Artefato server para Edge Functions e testes. |
| `supabase/functions/_shared/foundation_ruleset.ts` | Mirror Supabase do artefato server. |
| `server/tests/foundation_ruleset_test.ts` | Prova hashes, mirrors e ausencia de secrets. |

## Registry

`ruleset_registry` registra publicacoes imutaveis. A identidade tecnica de uma
publicacao e `publication_id`; `ruleset_id` continua sendo o nome legivel do
pacote e nao deve ser usado sozinho como chave unica.

Campos contratuais:

- `publication_id`
- `ruleset_id`
- `ruleset_version`
- `content_hash`
- `simulator_hash`
- `schema_version`
- `active_from`
- `channel`
- `cohort`
- `status`
- `publication_payload`
- `created_at`
- `updated_at`

Invariantes:

- primary key em `publication_id`;
- unique em `ruleset_id + ruleset_version + channel + cohort`;
- apenas uma publicacao ativa por `ruleset_id + channel + cohort`;
- mudanca de hash/schema/status deve criar nova publicacao ou migration
  corretiva explicita, nao sobrescrever historico silenciosamente.

Registro inicial:

```json
{
  "publication_id": "uuid",
  "ruleset_id": "foundation_ruleset_v0",
  "ruleset_version": 1,
  "content_hash": "5b7121a37a78e966c06098cc70283dabc5dbbcc1d3f9a21d279b855d09aee1e7",
  "simulator_hash": "e835cadde3c937cba45c46785da3761139373ab23ac9dfaaed814d79f933bbe9",
  "schema_version": "foundation_ruleset_manifest_v1",
  "channel": "internal_alpha",
  "cohort": "all",
  "status": "active"
}
```

## O Que Entra No Ruleset

O pacote de fundacao inclui fontes para:

- combat;
- base structures;
- rewards;
- economy curves;
- leveling;
- build unlocks;
- weapons;
- spells;
- passives/doutrines;
- pets/familiars;
- potions;
- crafting recipes;
- bots;
- power bands;
- Battle Lab;
- Progression Lab;
- economy simulator.

Novas regras nao devem ficar invisiveis em UI, Edge Function ou tabela sem passar por um ruleset/contrato equivalente.

## Persistencia De Estado

Linhas e snapshots que dependem de regra devem salvar contexto de ruleset:

- `game_saves`;
- `battles`;
- `construction_jobs`;
- `reward_claims`;
- `alpha_purchases`;
- battle replay/history payloads.

`battle_log_v1` aceita campo extra `ruleset`. Replays novos devem usar os
hashes salvos na propria row (`ruleset_publication_id`, `content_hash`,
`simulator_hash`, `schema_version`). Replays antigos sem hashes persistidos
continuam validos e recebem fallback para `foundation_ruleset_v0` apenas para
leitura historica.

## Regra De Hash

- `content_hash` cobre definitions e modelos de ferramentas que participam da autoria.
- `simulator_hash` cobre o simulador de batalha espelhado server/supabase.
- Um deploy que muda simulador sem atualizar o ruleset deve falhar em teste.
- Um deploy que muda definitions/modelos sem regenerar o ruleset deve falhar em teste.

## Publicacao

Para publicar um ruleset:

1. editar fontes autoradas;
2. rodar `npx -y deno run --allow-read --allow-write tools/generate_foundation_ruleset.ts`;
3. rodar `npx -y deno test --allow-read server/tests/foundation_ruleset_test.ts`;
4. atualizar migration/registry ou release process se o ruleset for promovido;
5. registrar channel/cohort/status;
6. validar server/supabase mirrors.

Publicacao remota continua sujeita a aprovacao explicita e `-ConfirmRemoteMutation`.
