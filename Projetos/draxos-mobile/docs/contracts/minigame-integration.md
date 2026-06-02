# Minigame Integration Contract

- Contract id: `MINIGAME_INTEGRATION_CONTRACT_V2`
- Platform contract: `MINIGAME_PLATFORM_V1`
- API surface: `/modes`
- Client route/action: `mode_shell`, `open_mode_shell:<mode_id>`

Este contrato governa como qualquer modo jogavel entra no DraxosMobile sem quebrar Conta, Save, Base, economia, telemetria, admin ou release. O nome historico da camada continua sendo Minigame Platform, mas o produto V1 fala em **modos oficiais**.

## Principios

1. Todo modo tem identidade tecnica estavel em `mode_registry`.
2. Todo modo declara owner de build, surface, status e release channel.
3. Nenhum modo escreve direto em recursos compartilhados pelo cliente.
4. Recompensa real exige RPC/service role, ledger, idempotencia e ruleset.
5. `progression_lab` nunca recebe reward real.
6. Disable/rollback nao apaga saves alpha.
7. Card disabled/staged pode aparecer no Hub, mas nao promete data nem simula recompensa.

## Modos Oficiais V1

| mode_id | Nome | Slice inicial | Status | Entrada |
| --- | --- | --- | --- | --- |
| `basebuilder` | `Basebuilder` | `refugio` | active | Refugio/Base |
| `autobattler` | `Autobattler` | `pve_arena` | active | Arena PVE |
| `openworld` | `Openworld` | `forest` | active (`internal_alpha`) | `open_mode_shell:openworld` |
| `towerdefense` | `Towerdefense` | `tbd` | planned_disabled | Hub disabled |
| `cardgame` | `Cardgame` | `tbd` | planned_disabled | Hub disabled |

## Descriptor Scaffold

Cada modo oficial deve ter:

- `data/definitions/modes/<mode_id>/metadata.json`;
- `data/definitions/modes/<mode_id>/placeholder.json`;
- doc viva em `docs/minigames/<mode_id>.md`.

O descriptor registra identidade, status, entrada, ruleset pointer e ownership.
O placeholder reserva futuro trabalho e deve permanecer nao jogavel
(`playable=false`, `launchable=false`, `reward_enabled=false`) ate uma decisao
de pacote propria. Descriptors nao substituem `mode_registry` remoto nem abrem
reward bridge por si so.

Enforcement:

- `tools/mode_definitions/schema.ts` e
  `server/tests/mode_definitions_schema_test.ts` definem o schema estrito.
- `tools/validate_mode_definitions.ps1` roda o pacote local de validacao.
- `tools/mode_definitions/scaffold_mode.ts` gera scaffolds futuros
  `planned_disabled` em dry-run por padrao.
- Pastas novas em `data/definitions/modes/` sao bloqueadas ate decision pack,
  contrato vivo e aprovacao humana.

## Client Shell

Contrato ativo:

- route id: `mode_shell`;
- action id: `open_mode_shell:<mode_id>`;
- action category: `mode`;
- scope: `mode:<id>:<save_type>`;
- default shell surface: fullscreen gameplay quando o modo declarar `fullscreen=true`.

Contrato inativo em V1:

- `minigame_shell`;
- `open_minigame_shell:<id>`;
- `/minigames`.

## Data Strategy

| Strategy | Uso | Requisito |
| --- | --- | --- |
| `core-mode-progress` | Basebuilder/Autobattler usam endpoints core ja existentes | Contrato do dominio owner |
| `mode-local-progress` | Progresso proprio sem Conta/Base | Estado isolado e plano de reset/disable |
| `shared-save-progress` | Reward real para Conta/Base | RPC, ledger, idempotencia e cap diario |

## Refugio Mode Hub Gate

Um modo so pode ter `public_cta=true` quando cumprir:

- design contract vivo;
- registry row completo;
- ruleset ativo versionado;
- rate/cooldown policy em `mode_limit_policies`;
- disable/rollback testado;
- admin/ops funcional;
- telemetria `mode_analytics_v1`;
- Reward Bridge com ledger, se emitir recurso;
- bloqueio de reward real no `progression_lab`;
- UX clara no Hub;
- smoke mobile portrait;
- GUT client;
- backend tests;
- Full validation;
- aprovacao humana registrada.

V1 Internal Alpha:

- Basebuilder, Autobattler e Openworld aparecem clicaveis.
- Towerdefense e Cardgame aparecem staged/disabled.

## Analytics

Eventos oficiais:

- `mode_hub_shown`
- `mode_card_shown`
- `mode_card_selected`
- `mode_start_requested`
- `mode_start_failed`
- `mode_session_started`
- `mode_session_abandoned`
- `mode_session_completed`
- `mode_reward_applied`
- `mode_exit`
- `mode_disabled_seen`
- `mode_ops_action`

Dimensoes obrigatorias:

- `mode_id`
- `slice_id`
- `ruleset_id`
- `ruleset_version`
- `release_channel`
- `entry_surface`
- `save_type`
- `app_platform`
- `client_version`
- `session_id` quando houver
- `request_id` quando houver
- `error_code` quando houver

## Openworld Registro Atual

`openworld/forest` e o primeiro modo que usa generic Mode sessions com
snapshot remoto retomavel e eventos revisionados. "Oficial" neste contexto
significa modo `active` no canal `internal_alpha`; nao significa release
publica, upload, manifest novo ou mutacao remota aplicada.

- ruleset: `openworld_forest_ruleset_v1`
- snapshot schema: `openworld_forest_snapshot_v1`
- definition: `data/definitions/openworld/forest_ruleset_v1.json`
- screen: `modes/openworld/openworld_forest_screen.gd`
- docs: `docs/minigames/openworld.md`
- state/resume: `GET /modes/state?mode_id=openworld`
- event bridge: `POST /modes/session/event`
- reward bridge: `mode_session_complete_v1`
- authority: rewards derive only from `mode_sessions.snapshot_payload`, with
  `expected_revision` required on complete.
- offline/no auth: preview only, no reward ledger mutation.

`openworld_forest_ruleset_v0` permanece historico do prototipo local e nao deve
ser usado como ruleset ativo.

## Pendencias Conceituais

- Towerdefense precisa de design contract proprio para torre, hordas, pets, spells e upgrades.
- Cardgame precisa de design contract proprio sem herdar mecanicas do projeto Steam.
- Openworld continuo precisa definir mapa, progressao, risco, interacao, combate e fronteira com Basebuilder.
