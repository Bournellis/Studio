# Decisao: Account Save Gate

## Metadata

- data: `2026-05-27`
- decisor: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/t04-account-save-gate`

## Contexto

Depois da aprovacao do alpha/handoff `T03-P18`, o projeto precisava decidir se o modelo atual `players.save_type` continua para a Track 04 ou se a proxima etapa deve planejar a separacao explicita `account_profiles` + `game_saves`.

Foram revisados:

- `docs/contracts/database-schema.md`
- `docs/architecture.md`
- `implementation/current-status.md`
- `supabase/functions/_shared/save_context.ts`
- `supabase/functions/account/index.ts`
- `supabase/functions/social/index.ts`
- `supabase/functions/competition/index.ts`
- `supabase/functions/monetization/index.ts`
- migrations `202605260001`, `202605260002`, `202605260003` e `202605270001`

## Decision

Manter `players.save_type` para a Internal Alpha v0 e para os primeiros pacotes da Track 04. Nao planejar nem executar migration `account_profiles` + `game_saves` agora.

A separacao explicita continua sendo a direcao estrutural correta antes de escalar social/conta/save, mas ela nao e necessaria para o alpha aprovado porque:

- `save_type` esta centralizado no header `x-draxos-save-type` e no helper `_shared/save_context.ts`;
- `account` cria, carrega e reseta saves por `auth_user_id + save_type`;
- `reset_player_save` e `apply_progression_lab_save` limpam apenas o `player_id` do save alvo;
- `social` ja resolve o save `normal` como identidade social canonica e marca o viewer do Lab como `lab`;
- `competition/ranking/current` exclui explicitamente `progression_lab`;
- `monetization` opera por `player_id`, mantendo claims, redeems, premium alpha e fila dupla separados por save;
- smokes documentados cobriram dois saves, reset isolado, Progression Lab apply, Social/Competicao e Monetizacao.

## Riscos Aceitos

- `players` continua representando tanto identidade de conta quanto save, entao `player_id` fica semanticamente ambivalente.
- Social depende de convencao em Edge Function para usar o save `normal` como identidade canonica.
- Entitlements de loja sao por save; pagamento real ou compra account-wide exigiriam novo contrato antes de entrar em producao.
- Todo endpoint novo precisa declarar se e save-scoped ou account-scoped e aplicar a regra do Lab explicitamente.
- O custo da migration cresce se novas tabelas sociais/account-wide forem adicionadas antes da separacao.

## Alternatives Considered

- Planejar migration agora para `account_profiles` + `game_saves`: rejeitado porque nao ha bug real de isolamento/corrupcao, o alpha esta validado e a Track 04 ainda prioriza playtest, bugs, UX e modularizacao do Hub.
- Manter `players.save_type` indefinidamente: rejeitado como estrategia longa; o modelo e aceitavel para alpha, mas nao deve virar base de escala social/conta/save.

## Impact

- Nenhuma migration sera criada neste pacote.
- Nenhuma Edge Function ou schema runtime sera alterado neste pacote.
- Track 04 continua com playtest fechado, bugfixes, UX/onboarding e modularizacao incremental do Hub antes de qualquer schema work.
- Novos endpoints devem registrar escopo `save-scoped` ou `account-scoped` durante review.

## Review When

Reabrir este gate se qualquer um destes sinais aparecer:

- bug real de isolamento, seguranca, corrupcao ou reset cruzado entre `normal` e `progression_lab`;
- necessidade de compra real, entitlement account-wide, painel administrativo de conta ou migracao de guest para conta registrada com preservacao complexa;
- mais de dois saves/modos por conta;
- social remoto com guilda/chat/amigos precisando sobreviver independente de saves;
- snapshot historico de ranking/season exigir identidade de conta separada do save;
- inicio do plano de saida Supabase para Backend Proprio + Postgres.

## Sem Migration

Nao criado. Pela decisao acima, migration nao e necessaria agora. Quando um gatilho de revisao ocorrer, abrir track/commit proprio para desenhar o plano antes de qualquer SQL.
