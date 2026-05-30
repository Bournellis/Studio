# DraxosMobile - Foundation Expansion Readiness

- Status: `RUNBOOK`
- Lane: `QA/OPS CONTRACTS`
- Ultima atualizacao: `2026-05-30`
- Aplica-se a: pacotes futuros que expandam minigames, social, admin, backend, schema, rulesets, telemetria, migracoes ou operacao live.

## Proposito

Este documento transforma a Foundation Audit em um gate de expansao. Ele nao autoriza feature nova; ele define como uma feature futura deve provar que nao quebra a fundacao antes de entrar em codigo.

O baseline atual continua sendo `First Session Clarity v1` aprovado manualmente. A ordem operacional permanece: contrato primeiro, implementacao depois. Se uma proposta precisa de endpoint, migration, ruleset, teste, admin ou operacao remota, ela deve preencher este runbook antes de abrir PR de feature.

Comando de verificacao estrutural desta lane:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .
```

O script e read-only. Ele verifica presenca de contratos, migrations espelhadas, rulesets/conteudo autorado e testes de contrato/fundacao.

## Matriz De Lanes

| Lane | Owner primario | Arquivos/artefatos esperados | Gate minimo antes de codigo | Validacao minima |
|---|---|---|---|---|
| Product/Design | founder + product agent | `docs/product-vision.md`, `docs/game-design-document.md`, `docs/design-pending.md`, package note vivo | decidir se e fundacao real, mock atual ou conteudo candidato | decisao registrada no doc vivo do pacote |
| Client Shell | client agent | `modes/boot/`, presenters, surfaces, `tests/client/` | manter Entry/Refugio/Battle dentro do contrato responsivo quando tocar layout | GUT client ou smoke de layout relevante |
| Backend/API | backend agent | `docs/contracts/api-endpoints.md`, `server/functions/`, `supabase/functions/` | endpoint declarado com scope, auth, idempotencia, erro e fallback | Deno check/test ou smoke local/remoto |
| Schema/Migration | backend/data agent | `docs/contracts/database-schema.md`, `server/schema/migrations/`, `supabase/migrations/` | migration espelhada nos dois diretories e contrato atualizado antes da funcao | mirror check + teste de migration/smoke |
| Ruleset/Content | gameplay/data agent | `data/definitions/`, `data/generated/`, `tools/content_generator.gd`, simulador/ruleset versionado | IDs estaveis, schema version, regra de troca sem editar save manualmente | `tools/validate.gd` ou teste de contrato de catalogo |
| Minigame Integration | feature owner + backend/client | `docs/contracts/minigame-integration.md`, feature card, endpoints, ruleset, tests | contrato de entrada/custo/recompensa/progresso antes de qualquer minigame jogavel | checker desta lane + testes de endpoint/ruleset |
| Admin/Ops | ops owner + backend | `docs/contracts/admin-ops.md`, release runbooks, audit log future migration | operacao humana sempre auditavel; sem service role no cliente | release safety + admin audit tests quando houver endpoint |
| QA | QA owner | `server/tests/`, `tests/client/`, `tools/smoke_*.gd`, `tools/check_*.ps1` | cada pacote declara smoke/GUT/Deno minimo e bloqueios conhecidos | comando executado e resultado reportado |
| Release | release owner | `tools/publish_internal_alpha.ps1`, `docs/release-ops-checklist.md`, manifests | remote mutation so com aprovacao explicita e `-ConfirmRemoteMutation` | Plan/Package/Upload conforme pacote aprovado |
| Security/Abuse | backend/ops | RLS, auth rules, moderation/admin contracts, secrets policy | nenhum secret em cliente, docs publicas, portal, export ou manifest | release safety + revisao de segredo se tocar auth/ops |

## Gate Contract-First

Um pacote de expansao so pode comecar implementacao quando responder, por escrito:

1. Qual lane e owner responsavel pelo pacote?
2. Quais contratos vivos mudam?
3. Ha endpoint novo, scope novo, migration nova ou ruleset novo?
4. Qual dado pertence ao save, a conta, ao minigame, ao admin ou ao release?
5. Qual ledger/auditoria prova que recurso, recompensa, moderacao ou suporte nao duplicou?
6. Qual teste falha se o contrato for removido ou quebrado?
7. Qual fallback/rollback evita prender o usuario em estado ruim?

Se uma resposta for "a definir", o pacote ainda e planejamento. Planejamento pode editar docs; nao deve criar feature jogavel ou endpoint mutante.

## Minigame Antes De Feature

Todo minigame futuro deve passar pelo contrato `docs/contracts/minigame-integration.md` antes de:

- criar tela jogavel;
- criar endpoint;
- criar tabela ou migration;
- consumir ou conceder recurso;
- afetar nivel, poder, ranking, guilda, season ou inventario;
- aparecer em release manifest, portal, CTA principal ou telemetry funnel como promessa do produto.

Minigame pode ter progresso proprio, progresso compartilhado ou ambos, mas isso deve ser declarado antes de codigo. Recompensas devem usar fonte de ledger propria e idempotencia por request/minigame/save ou conta, conforme escopo.

## Admin Minimo Auditavel

Admin nao significa painel sofisticado nesta fase. Admin minimo significa que qualquer operacao humana futura pode ser explicada depois:

- quem executou;
- em qual ambiente;
- qual conta/save/social/batalha foi afetado;
- qual motivo operacional;
- qual estado antes/depois foi observado ou mutado;
- qual `request_id` ou correlation id liga a operacao ao log;
- qual rollback existe.

O contrato vivo e `docs/contracts/admin-ops.md`. Enquanto nao houver migration e endpoint dedicados, `admin-future` permanece reservado e nao deve ser simulado por endpoint `save-scoped`.

## Migration / Ruleset / Tests

Checklist obrigatorio quando o pacote tocar backend, dados ou regras:

| Area | Obrigatorio |
|---|---|
| Migration | arquivo SQL em `server/schema/migrations/` e espelho identico em `supabase/migrations/`; contrato de schema atualizado antes de deploy |
| API | endpoint no contrato com scope, auth, save header, idempotencia, erros e teste |
| Ruleset | versionar regra/conteudo em `data/definitions/`, simulador ou arquivo de modelo; nao codificar tuning invisivel no cliente |
| Tests | pelo menos um teste/ smoke que le o contrato ou exercita o endpoint/ruleset |
| Rollback | declarar como desligar, ignorar ou reverter sem reset manual de toda a conta |
| Ops | se houver operacao humana, declarar auditabilidade no contrato admin |

Para a fundacao atual, o ruleset esperado e `foundation_ruleset_v0`: `data/rulesets/foundation_ruleset_v0.json`, gerador `tools/generate_foundation_ruleset.ts`, mirrors `server/functions/_shared/foundation_ruleset.ts` e `supabase/functions/_shared/foundation_ruleset.ts`, teste `server/tests/foundation_ruleset_test.ts` e teste client de contratos do shell.

## Sinais De Bloqueio

Pare e peca decisao explicita quando:

- uma feature tentar ignorar `account_profiles` + `game_saves` e escrever nova fonte primaria em `players.save_type`;
- a proposta quiser criar minigame sem contrato de custo/recompensa/progresso;
- admin exigir service role em cliente, export, portal ou manifest;
- uma operacao remota nao tiver aprovacao e `-ConfirmRemoteMutation`;
- o pacote misturar tuning numerico, conteudo final, schema, social e release em uma unica entrega;
- o teste minimo depender de estado remoto nao reproduzivel e nao houver smoke read-only ou fixture local.

## Estado Implementado Neste Pacote

Esta primeira entrega da readiness cria a base tecnica e documental, mas nao abre novas features de gameplay:

- migrations espelhadas `202605300001_foundation_expansion_readiness.sql`, `202605300002_transactional_domain_enforcement.sql` e `202605300003_remaining_transactional_domain_enforcement.sql`;
- `account_profiles`, `game_saves`, `ruleset_registry` e `admin_audit_log`;
- idempotencia com `request_hash`, `scope_id`, `pending/completed/failed` e timestamps;
- RPCs base de profile/save, idempotencia, reconciliacao auditavel e dominios transacionais v1;
- `foundation_ruleset_v0` gerado a partir de definitions/modelos/simulador;
- battle request/history/replay com metadata de ruleset e `FIRST_SLICE_SIM` aplicado via RPC transacional para battle row, rewards, consumiveis e ranking;
- Base collect/upgrade, build equip, crafting craft/crush-bones, monetization rewards/alpha purchase e guild create/join migrados para o padrao `game_saves` + `request_hash` + idempotencia pending/completed;
- `server/tests/transactional_rpc_live_test.ts` prova em Supabase local resetado que as RPCs v1 fazem rollback de falha parcial, permitem retry apos precondicao corrigida, retornam resposta idempotente por `request_id` e rejeitam `request_hash` divergente em battle rewards, build equip, crafting, reward claim, alpha purchase e guild create/join;
- `server/tests/transactional_edge_rpc_smoke.ts` prova o caminho HTTP local das Edge Functions sobre os adapters RPC v1 e confirmou/corrigiu hash estavel em `battle/request` `FIRST_SLICE_SIM` e retry de `crafting/craft` sem prechecagem bloqueando a RPC;
- `DraxosOperationState` e `DraxosAppShellActionRouter` sem tocar `boot.gd`;
- contratos de account/save, ruleset registry, admin ops e minigame integration;
- checker read-only integrado ao gate de fundacao.

## Handoff Esperado

Ao concluir uma lane de readiness, reporte:

- arquivos alterados;
- contratos criados ou atualizados;
- migrations/rulesets/tests verificados;
- comandos executados e resultado;
- bloqueios ainda existentes;
- proximo owner seguro para continuar.

Este documento nao substitui `docs/documentation-index.md`; ele e a referencia operacional desta lane enquanto o indice nao for atualizado por um pacote proprio.
