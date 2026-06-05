# Admin Ops Contract

- Status: `CONTRATO`
- Contract id: `ADMIN_OPS_CONTRACT_V1`
- Ultima atualizacao: `2026-05-30`
- Escopo: administracao minima auditavel para suporte, migracao, moderacao, diagnostico e operacao live futura.

## Principio

Admin minimo nao e painel completo. Admin minimo e a capacidade de explicar e auditar qualquer intervencao humana futura sem depender de memoria, chat solto ou acesso manual invisivel ao banco.

Foundation Closeout implementa o minimo interno auditavel como RPCs de banco
`service_role`-only. Nao ha painel publico, rota de cliente ou segredo no
export. Operacoes administrativas novas fora desse minimo ainda exigem contrato
proprio.

## O Que Deve Ser Auditavel

Toda operacao administrativa futura que leia dado sensivel, mute estado, modere social, aplique compensacao, invalide save, altere release, rode migration remota ou diagnostique batalha deve registrar:

| Campo | Regra |
|---|---|
| `audit_id` | id unico da operacao |
| `actor_id` | identidade do operador ou automation |
| `actor_role` | papel autorizado |
| `environment` | local, staging, internal_alpha, production futura |
| `action` | verbo canonico da operacao |
| `target_type` | account, save, player, guild, chat_message, battle, release, migration |
| `target_id` | id tecnico afetado |
| `reason` | motivo humano obrigatorio |
| `request_id` | idempotencia/correlation quando houver mutacao |
| `before_ref` | referencia ao estado antes ou resumo seguro |
| `after_ref` | referencia ao estado depois ou resumo seguro |
| `result` | success, blocked, failed, rolled_back |
| `created_at` | timestamp server-side |

Dados sensiveis nao devem ser despejados em texto livre. Use referencias, hashes ou resumos seguros quando o dado puder incluir email, token, chat privado ou detalhe de pagamento futuro.

## Roles Minimas Futuras

| Role | Pode | Nao pode |
|---|---|---|
| `support_viewer` | localizar conta/save, ver resumo, copiar correlation ids | mutar recursos, moderar, publicar release |
| `support_operator` | aplicar compensacao limitada, invalidar retry, marcar caso resolvido | alterar schema, usar service role fora do backend |
| `moderator` | revisar social/chat/guilda, ocultar ou bloquear conteudo conforme contrato | conceder economia ou editar batalha |
| `release_operator` | rodar Plan/Package e preparar manifest | Upload/Deploy sem aprovacao e `-ConfirmRemoteMutation` |
| `admin_engineer` | executar migration/admin endpoint aprovado | colocar secret no cliente/export/portal/docs publicas |

Roles reais podem mudar, mas o contrato deve manter separacao entre leitura, suporte, moderacao, release e engenharia.

## Capacidades Minimas

Antes de Alpha mais ampla, as capacidades abaixo devem manter contrato, audit
log e teste/smoke quando forem expandidas:

| Capacidade | Status atual | Requisito antes de codigo |
|---|---|---|
| localizar conta/save | implementado minimo | RPC `admin_lookup_account_v1`, service-role-only, sem painel publico |
| diagnosticar batalha | implementado minimo | RPC `admin_battle_diagnostics_v1`, leitura por `battle_id`, sem rerodar simulador nem reaplicar recompensa |
| reconciliar recurso | implementado minimo | RPC `resource_reconciliation_report_v1`, read-only |
| compensar recurso/item | implementado recurso | RPC `admin_adjust_resource_balance_v1`, ledger dedicado, `request_id`, `request_hash`, before/after |
| invalidar ou reconstruir save | futuro | decisao explicita; nao usar reset geral sem registro |
| flaggar/suspender conta | implementado minimo | RPC `admin_flag_account_v1`, reason obrigatorio e audit log |
| moderar chat/guilda | futuro | action canonica, reason, alvo, appeal/rollback basico |
| ajustar release manifest | parcialmente coberto por release ops | manter `ConfirmRemoteMutation` e auditabilidade externa/local |
| rodar migration remota | futuro | aprovacao explicita, backup/rollback, log de ambiente |

## Estado Implementado Na Fundacao

`202605300001_foundation_expansion_readiness.sql` cria `admin_audit_log` como tabela minima de auditoria interna para operacoes de suporte/reconciliacao. `202605300004_foundation_closeout.sql` adiciona RPCs minimas internas:

- `admin_lookup_account_v1`;
- `admin_battle_diagnostics_v1`;
- `resource_reconciliation_report_v1`;
- `admin_adjust_resource_balance_v1`;
- `admin_flag_account_v1`.

Todas sao `service_role`-only, sem grant para `anon` ou `authenticated`.

Campos implementados:

- `id`
- `actor_auth_user_id`
- `account_profile_id`
- `game_save_id`
- `player_id`
- `action`
- `reason`
- `request_id`
- `before_state`
- `after_state`
- `metadata`
- `created_at`

`admin_adjust_resource_balance_v1` usa essa tabela junto com
`resource_transactions`, garantindo ledger, `request_hash` e auditoria na mesma
operacao.

Mode Platform V1 hardening adiciona RPCs internas auditadas para que
`/modes/admin/*` nao faca `PATCH` direto em tabelas operacionais:

- `admin_set_mode_status_v1`;
- `admin_expire_mode_session_v1`;
- `admin_invalidate_mode_session_v1`.

Todas exigem `request_id`, `request_hash`, `reason`, usam `admin_audit_log` com
before/after e sao `service_role`-only.

## Guardrails De Segredo

Proibido colocar em cliente, export, portal, manifest ou docs operacionais publicas:

- service role;
- database password;
- keystore password;
- token privado de Supabase, Cloudflare ou GitHub;
- segredo de painel admin;
- URL assinada longa ou reutilizavel;
- dump de usuario com email/token/chat sensivel.

Qualquer operacao que precise service role deve acontecer no servidor, em script local ignorado ou em pipeline configurado fora do cliente. O contrato do endpoint deve declarar exatamente que o cliente nunca recebe esse segredo.

## RPCs Admin-Internal

As RPCs existentes sao internas e nao devem ser chamadas pelo cliente:

| RPC | Tipo | Auditabilidade |
|---|---|---|
| `admin_lookup_account_v1` | read-only | sem mutacao; usado para localizar account/profile/save |
| `admin_battle_diagnostics_v1` | read-only | inclui battle, ruleset/hash, reward e ledger por `battle_id` |
| `resource_reconciliation_report_v1` | read-only | compara saldo atual e ledger por `game_save_id` |
| `admin_adjust_resource_balance_v1` | mutacao | exige `request_id`, `request_hash`, reason, before/after, ledger e `admin_audit_log` |
| `admin_flag_account_v1` | mutacao | exige `request_id`, status, reason e `admin_audit_log` |
| `admin_set_mode_status_v1` | mutacao | exige `request_id`, `request_hash`, reason, before/after e `admin_audit_log` |
| `admin_expire_mode_session_v1` | mutacao | exige `request_id`, `request_hash`, reason, before/after e `admin_audit_log` |
| `admin_invalidate_mode_session_v1` | mutacao | exige `request_id`, `request_hash`, reason, before/after e `admin_audit_log` |

## Endpoints Admin-Futuros

Todo endpoint admin futuro deve declarar:

| Campo | Obrigatorio |
|---|---|
| metodo e rota | endpoint logico separado de gameplay |
| auth | autenticacao forte e role esperada |
| scope | `admin-internal` ou contrato novo mais especifico |
| target | conta/save/social/battle/release/migration afetado |
| idempotencia | obrigatoria para mutacoes |
| audit log | campos gravados e onde consultar |
| redacao | quais campos sao omitidos/mascarados |
| rate/approval | limite, dupla aprovacao ou confirmacao manual |
| rollback | como desfazer ou neutralizar |
| teste | smoke local/remoto ou teste de contrato |

`/modes/admin/reconcile` e diagnostico read-only: exige `request_id` para
correlacao operacional, mas nao usa `request_hash` nem grava audit log porque
nao muta estado. Qualquer evolucao dele para reconciliacao corretiva deve virar
nova mutacao auditada.

Admin endpoints nao devem conceder recurso por chamada direta a tabela sem ledger. Mutacoes economicas administrativas devem usar fonte propria, por exemplo `admin_adjustment`, com reason, request id e request hash.

## Migration De Audit Log

Quando o primeiro endpoint admin mutante for aprovado, ele deve adotar `admin_audit_log` ou criar uma extensao equivalente. O formato minimo historico era:

```sql
admin_audit_log(
  id uuid primary key,
  actor_id text not null,
  actor_role text not null,
  environment text not null,
  action text not null,
  target_type text not null,
  target_id text not null,
  reason text not null,
  request_id text,
  before_ref jsonb,
  after_ref jsonb,
  result text not null,
  created_at timestamptz not null default now()
)
```

Regras:

- migration em `server/schema/migrations/` e `supabase/migrations/`;
- RLS ou service-only definido explicitamente;
- indices por `target_type + target_id`, `actor_id`, `created_at` e `request_id` quando houver mutacoes;
- teste de contrato verificando que operacoes mutantes nao existem sem audit log.

Esta fundacao cria a migration minima e as RPCs internas listadas acima. Endpoints
admin futuros ainda precisam contrato proprio, role/auth, teste e revisao antes
de existir.

## Operacao Manual De Emergencia

Se uma emergencia exigir acao manual antes de endpoint admin existir:

1. pausar e pedir aprovacao explicita do usuario/fundador;
2. registrar ambiente, motivo, alvo, comando planejado e rollback em handoff;
3. preferir script read-only para diagnostico;
4. executar mutacao minima;
5. registrar resultado, antes/depois disponivel e risco residual;
6. criar follow-up para transformar a acao em endpoint/script auditavel.

Sem emergencia real, nao use acesso manual ao banco como atalho de produto.

## Release E Remote Mutation

Operacoes de release continuam governadas por `docs/release-ops-checklist.md` e scripts seguros:

- `Mode Plan` nao muta local/remoto;
- `Mode Package` gera pacote local e exige `-ReleaseRoot` versionado;
- `Mode Upload`, `Mode DeployManifest` e `Mode FullPublish` exigem aprovacao explicita, `-ReleaseRoot` versionado e `-ConfirmRemoteMutation`;
- override de manifest exige ambiente preparado e nao deve vazar secrets.

O contrato admin nao relaxa esses gates. Ele adiciona rastreabilidade quando release operation virar fluxo de suporte/ops recorrente.

## Checklist Antes De Implementar Admin

- [ ] endpoint/RPC declarado como `admin-internal` ou contrato novo aprovado;
- [ ] role e auth definidos;
- [ ] audit log ou log operacional definido;
- [ ] migration espelhada quando houver tabela nova;
- [ ] redacao de dados sensiveis definida;
- [ ] idempotencia e rollback definidos;
- [ ] teste/smoke declarado;
- [ ] release/remote mutation respeita `ConfirmRemoteMutation`;
- [ ] nenhum segredo entra no cliente/export/portal/manifest/docs publicas.
