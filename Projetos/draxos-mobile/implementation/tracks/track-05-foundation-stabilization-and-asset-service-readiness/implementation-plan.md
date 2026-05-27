# Track 05 - Implementation Plan

## Regra Da Track

Track 05 estabiliza a fundacao antes de assets reais e novos servicos.

Ela nao expande produto, nao altera economia, nao cria schema novo e nao publica build. O foco e tornar o projeto previsivel para paralelizacao, validacao e evolucao posterior.

Commits esperados:

- `docs:` track, matriz, runbooks, contratos e status.
- `test:` smokes/cobertura de fundacao.
- `client:` apenas hardening render-only ou asset pipeline sem arte final.
- `contracts:` classificacao de escopo de endpoints, sem payload novo.
- `tools:` validacao, smokes e checklists seguros.

## Trilhas Paralelas Oficiais

| Trilha | Prioridade | Trabalho | Dependencia |
|---|---:|---|---|
| T05-A Coordenacao | 0 | Criar Track 05, status, plano e Kanban | Nenhuma |
| T05-B Validation Matrix | 1 | Formalizar matriz quick/full/release e smokes faltantes | T05-A |
| T05-C Hub Foundation | 1 | Reduzir risco do Hub/presenters sem mudar comportamento | T05-A |
| T05-D Service Contracts | 1 | Classificar escopo dos endpoints e endurecer testes sem schema novo | T05-A |
| T05-E Asset Pipeline | 2 | Preparar convencoes, ids, fallback e testes para assets reais | T05-A |
| T05-F Progression Human Pack | 2 | Preparar rodada humana do Progression Lab e criterios de tuning | T05-A |
| T05-G Release Ops | 2 | Revisar manifest/build/publicacao/remote smoke como fundacao operacional | T05-A |
| T05-H Integracao | 0 final | Integrar, validar tudo e atualizar status | T05-B a T05-G |

## T05-A - Coordenacao

Status: `IN_PROGRESS`.

- Criar pasta da Track 05 com `scope.md`, `current-status.md`, `implementation-plan.md` e `agent-prompts.md`.
- Atualizar snapshots de portfolio e status local.
- Registrar Doing.
- Nao alterar Godot runtime, Supabase, schema, economia ou assets.

Validacao: `git diff --check`.

## T05-B - Validation Matrix

Status: `PENDING_AFTER_T05_A`.

- Formalizar matriz `quick`, `full`, `release` e `remote`.
- Adicionar smokes focados para Base, Shop, Social e Competition somente se faltarem.
- Smokes novos devem chamar fluxos existentes e nao criar regras novas.

Validacao: `validate.gd`, GUT, smokes novos, session shell, battle replay e `git diff --check`.

## T05-C - Hub Foundation

Status: `PENDING_AFTER_T05_A`.

- Auditar `boot.gd` e `modes/boot/surfaces/`.
- Garantir presenters render-only.
- Remover apenas wrapper/codigo morto claramente redundante.
- Aposentar `battle_surface_presenter.gd` somente se estiver obsoleto e coberto.

Validacao: `validate.gd`, GUT, session shell, battle replay e `git diff --check`.

## T05-D - Service Contracts

Status: `PENDING_AFTER_T05_A`.

- Classificar endpoints e funcoes como `save-scoped`, `account-scoped`, `release`, `telemetry` ou `admin-future`.
- Documentar que novos endpoints devem declarar escopo.
- Adicionar testes Deno apenas para comportamento existente, se util.

Validacao: Deno checks de `supabase/functions` e `server/functions`, testes adicionados e `git diff --check`.

## T05-E - Asset Pipeline

Status: `PENDING_AFTER_T05_A`.

- Documentar convencoes para assets reais.
- Manter ids e paths atuais estaveis.
- Testar que missing art continua permitido e fallback nao quebra.
- Nao importar arte final.

Validacao: `validate.gd`, GUT, `smoke_exports.gd` e `git diff --check`.

## T05-F - Progression Human Pack

Status: `PENDING_AFTER_T05_A`.

- Criar runbook/checklist de rodada humana para 2h, 5h, 10h, 15h e 20h.
- Cobrir `free_100_rewards`, `freemium_basic`, `spender_light` e `max_spender`.
- Focar `spender_light_10h`, `max_spender_10h`, `max_spender_20h`, `free_100_rewards_20h` e `freemium_basic_20h`.
- Definir criterios de decisao antes de tuning.

Validacao: `smoke_dev_labs.gd`, checks do Progression Lab quando aplicavel e `git diff --check`.

## T05-G - Release Ops

Status: `PENDING_AFTER_T05_A`.

- Revisar manifest/version gate, scripts de export/publicacao e docs Cloudflare + Supabase Storage.
- Formalizar checklist release-ready.
- Nao publicar, nao redeployar, nao alterar manifest remoto real.

Validacao: `smoke_exports.gd`, checks seguros de scripts quando houver e `git diff --check`.

## T05-H - Integracao

Status: `BLOCKED_UNTIL_T05_B_TO_G`.

- Integrar T05-B a T05-G em ordem segura.
- Resolver conflitos sem esconder falhas.
- Rodar validacao completa.
- Atualizar current-status, Track 05 current-status e snapshots de portfolio.

Validacao final:

- `tools/validate.gd`
- GUT client completo
- `tools/smoke_session_shell.gd`
- `tools/smoke_battle_replay.gd`
- `tools/smoke_dev_labs.gd`
- `tools/smoke_dev_lab_ui.gd`
- `tools/smoke_exports.gd`
- smokes novos da Track 05
- Deno checks quando aplicavel
- `git diff --check`

## Assumptions

- Assets reais comecam depois da Track 05.
- Servicos novos comecam depois da Track 05.
- Supabase continua como backend do alpha.
- Backend Proprio + Postgres segue apenas como plano de saida.
- `players.save_type` permanece para esta track.
- Nenhum tuning numerico acontece antes da rodada humana do Progression Lab.
