# Minigame Integration Contract

- Status: `CONTRATO`
- Contract id: `MINIGAME_INTEGRATION_CONTRACT_V1`
- Ultima atualizacao: `2026-05-31`
- Escopo: integrar minigames futuros sem quebrar conta, save, economia, social, base, batalha, telemetry, release ou admin.

## Principio

DraxosMobile deve nascer com espaco para minigames, mas nenhum minigame novo deve entrar como feature jogavel antes do contrato. Este documento define o minimo para planejar, revisar, implementar e testar uma integracao.

Contract-first significa:

1. registrar identidade, owner e escopo do minigame;
2. declarar entrada, custo, recompensa, progresso e dados;
3. declarar endpoints, migration, ruleset e tests antes do codigo mutante;
4. manter rollback e fallback simples;
5. nao prometer o minigame em release/portal antes de ele passar pelo gate.

## Identidade Do Minigame

Todo minigame integrado deve ter um registro com:

| Campo | Regra |
|---|---|
| `minigame_id` | snake_case estavel, nunca usado como texto player-facing |
| `display_name` | texto localizavel e substituivel |
| `owner` | agente/time responsavel por design, cliente, backend e QA |
| `status` | `planned`, `prototype`, `ready_for_integration`, `integrated`, `disabled`, `deprecated` |
| `service_scope` | `save-scoped`, `account-scoped`, `release`, `telemetry` ou `admin-future` quando houver operacao |
| `ruleset_version` | versao do conjunto de regras usado para resolver resultado/recompensa |
| `contract_version` | versao deste contrato aplicada ao minigame |
| `feature_flag` | flag de habilitacao ou ausencia explicita de flag |
| `release_channel` | canal permitido, inicialmente `internal_alpha` |

## Fronteira De Dados

Declare uma destas estrategias antes de qualquer migration:

| Estrategia | Uso | Regra |
|---|---|---|
| `shared-save-progress` | minigame concede XP, recursos, itens ou base progress ao save atual | requer ledger, idempotencia e contrato de recompensa |
| `minigame-local-progress` | progresso proprio do minigame, sem afetar recursos principais | requer tabela/estado isolado e plano de reset/disable |
| `account-wide-progress` | progresso atravessa saves ou e social/account-wide | exige decisao explicita; nao reutilizar `players.save_type` como atalho silencioso |
| `read-only-demo` | prototipo sem mutacao economica/social | deve bloquear recompensas e ranking por contrato/teste |

Nenhum minigame deve escrever diretamente em `resources`, `ranking`, `guilds`, `battle_pass`, `builds` ou `base_structures` sem endpoint server-authoritative e ledger/auditoria.

## Entrada E UI Shell

Foundation Closeout reserva um shell client-side disabled/dev-only:

- route id: `minigame_shell`;
- action id: `open_minigame_shell:<minigame_id>`;
- action category: `minigame`;
- scope: `minigame:<id>:<save_type>`;
- reward handoff: bloqueado ate contrato e endpoint server-authoritative;
- sem ranking, economy, migration, promessa publica ou gameplay real.

O minigame deve declarar:

- onde aparece: Refugio, Base, Social, Competition, Labs Dev, portal ou menu separado;
- pre-condicoes: conta, save ativo, nivel, base, guilda, season, flag;
- estado offline permitido ou bloqueado;
- loading, erro e retry esperados;
- retorno ao loop principal;
- se usa app chrome normal ou tela fullscreen;
- como a UI se comporta em Android portrait, PC e Web.

Se tocar Entry, Refugio ou Battle, o pacote tambem deve respeitar `docs/foundation-responsive-layout-contract.md`.

## Registro Implementado - Rpgsuave Bosque

`rpgsuave` e o primeiro uso concreto deste contrato.

| Campo | Valor |
|---|---|
| `minigame_id`/`mode_id` | `rpgsuave` |
| `display_name` | `Rpgsuave Bosque` |
| `slice_id` | `forest` |
| `status` | `dev_only` no cliente; ponte `internal_alpha` pronta no backend |
| `surface` | Labs Dev |
| `action` | `open_minigame_shell:rpgsuave` |
| `service_scope` | `save-scoped` |
| `ruleset_id` | `rpgsuave_forest_ruleset_v0` |
| `ruleset_version` | `1` |
| `data_strategy` | `minigame-local-progress` ate complete; `shared-save-progress` somente pela RPC |
| `feature_flag` | `draxos_mobile/minigames/rpgsuave/enabled`; rede via `integrated_alpha=false` por default |

Contrato detalhado: `docs/minigames/rpgsuave.md` e
`docs/contracts/minigame-platform-v0.md`.

## Contrato De Servico

Antes de criar endpoint, adicionar no contrato de API:

| Campo | Obrigatorio |
|---|---|
| metodo e rota | metodo HTTP e endpoint logico |
| scope | `save-scoped`, `account-scoped`, `release`, `telemetry` ou `admin-future` |
| auth | JWT, release publico ou outro gate explicito |
| save header | usa, valida, ignora ou bloqueia `x-draxos-save-type` |
| idempotencia | dono do `request_id` e chave de dedupe |
| mutacao | quais tabelas/ledgers podem mudar |
| erros | codigos esperados e mensagens seguras |
| teste | smoke ou teste de contrato que prova o comportamento |

Endpoints de minigame nao devem chamar outros endpoints client-side para aplicar recompensa. O servidor resolve resultado e aplica efeitos em uma transacao ou em fluxo auditavel.

## Migration

Migration nova exige:

- SQL em `server/schema/migrations/`;
- espelho identico em `supabase/migrations/`;
- entrada em `docs/contracts/database-schema.md`;
- RLS/policies adequadas ou comentario explicando por que a tabela e service-only;
- plano de rollback/disable;
- teste local ou smoke que cubra aplicacao basica.

Como `account_profiles` + `game_saves` agora existe como fundacao, qualquer minigame account-wide deve usar esse contrato. `players.save_type` permanece apenas como compatibilidade alpha, nao como nova fonte primaria.

## Ruleset

Ruleset e qualquer dado que decide resultado, custo, recompensa, match, cooldown, dificuldade, multiplicador ou elegibilidade.

Rulesets aceitos:

- JSON autorado em `data/definitions/`;
- modelo versionado em `tools/*/model.v1.json`;
- modulo server-authoritative em `server/functions/_shared/`;
- contrato markdown que descreve regra ainda nao implementada.

Cada ruleset deve declarar:

| Campo | Regra |
|---|---|
| `schema_version` | versao do formato |
| `ruleset_id` | id estavel |
| `ruleset_version` | versao de balanceamento/regras |
| `enabled` | gate operacional |
| `migration_notes` | como saves antigos continuam legiveis |
| `test_reference` | teste/smoke que carrega ou exercita a regra |

O cliente pode apresentar regras, mas nao decide recompensa, ranking, inventario ou consumo.

## Recompensa E Economia

Toda recompensa deve declarar:

- recurso/item afetado;
- fonte de ledger (`source`);
- se e unica, repetivel, diaria, sazonal ou por partida;
- chave de idempotencia;
- limite/rate limit;
- se entra em ranking, Battle Pass, guilda ou season;
- fallback quando a aplicacao falha depois do resultado visual.

Recompensa visual sem ledger real deve ser chamada de preview e nao deve ser lida pelo cliente como saldo final.

## Telemetria

Eventos minimos:

| Evento | Quando |
|---|---|
| `minigame_entry_shown` | CTA ou entrada visivel |
| `minigame_start_requested` | usuario tenta iniciar |
| `minigame_start_failed` | pre-condicao, rede, auth ou server error |
| `minigame_completed` | resultado aceito pelo servidor |
| `minigame_reward_applied` | recompensa persistida |
| `minigame_exit` | retorno ao shell |

Telemetry nunca concede progresso, recurso, ranking ou recompensa.

## Admin/Ops

Qualquer minigame com recurso, ranking, social, season, cooldown ou reward precisa responder:

- como suporte localiza uma tentativa;
- como diagnostica resultado e reward;
- qual operacao humana e permitida;
- qual auditoria registra a operacao;
- como desabilitar o minigame sem quebrar saves existentes.

Use `docs/contracts/admin-ops.md` para a parte auditavel.

## Template De Registro

```markdown
### `minigame_id`

- Owner:
- Status:
- Surface:
- Service scope:
- Entry conditions:
- Endpoints affected:
- Migration:
- Ruleset:
- Reward/ledger:
- Telemetry:
- Client files:
- Backend files:
- Smoke required:
- GUT required:
- Other validation:
- Fallback:
- Rollback:
- Admin/Ops notes:
- Handoff notes:
```

## Checklist De Integracao

Antes de implementar:

- [ ] registro preenchido;
- [ ] API contract atualizado se houver endpoint;
- [ ] schema contract atualizado se houver migration;
- [ ] ruleset versionado se houver regra/conteudo;
- [ ] teste ou smoke declarado;
- [ ] admin/ops declarado se houver mutacao humana possivel;
- [ ] fallback/rollback declarado;
- [ ] release/feature flag definido.

Antes de publicar:

- [ ] migrations locais/remotas alinhadas quando aplicavel;
- [ ] server/supabase functions alinhadas quando aplicavel;
- [ ] teste de contrato verde;
- [ ] GUT/smoke client verde quando tocar UI;
- [ ] release safety verde quando tocar publicacao;
- [ ] handoff registra bloqueios restantes.
