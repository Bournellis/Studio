# Track 05 - Agent Prompts

## Agente 1 - T05-A Coordenacao

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Use a skill estudio-workspace se disponivel. Nao edite direto em D:\Estudio: crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t05-coordenacao e branch codex/draxos-mobile/t05-coordenacao.

Objetivo: abrir oficialmente a Track 05 - Foundation Stabilization And Asset/Service Readiness. Criar implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/ com scope.md, current-status.md, implementation-plan.md e agent-prompts.md. Registrar Kanban/Doing. Atualizar implementation/current-status.md, Prioridades_Estudio.md, Estado_Atual.md e Projetos/README.md para indicar que Track 05 esta ativa para estabilizacao de fundacao antes de assets/servicos.

Escopo: documentacao/coordenacao apenas. Nao alterar Godot, Supabase, schema, economia ou assets. Valide com git diff --check e entregue resumo dos arquivos alterados.
```

## Agente 2 - T05-B Validation Matrix

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Dependa de T05-A. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t05-validation-matrix e branch codex/draxos-mobile/t05-validation-matrix.

Objetivo: transformar a validacao atual em fundacao reproduzivel. Formalize matriz quick/full/release/remote na Track 05 e adicione smokes focados somente se faltarem para Base, Shop, Social e Competition. Nao mude comportamento do jogo. Nao mexa em economia, schema ou contratos HTTP.

Saida esperada: documentacao da matriz e, se necessario, ferramentas/smokes pequenos que chamem fluxos existentes sem criar novas regras. Valide validate.gd, GUT, smokes novos, smoke_session_shell.gd, smoke_battle_replay.gd e git diff --check.
```

## Agente 3 - T05-C Hub Foundation

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Dependa de T05-A. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t05-hub-foundation e branch codex/draxos-mobile/t05-hub-foundation.

Objetivo: reduzir risco estrutural do Hub pos-Track 04 sem mudanca funcional. Audite boot.gd e modes/boot/surfaces/. Garanta que presenters continuem render-only, actions/network/session/telemetria continuem no boot.gd, e remova apenas wrappers ou codigo morto claramente redundante. Se battle_surface_presenter.gd estiver obsoleto, aposente com cuidado e cobertura.

Nao alterar SupabaseClient, SessionStore, BackendConfig, contratos HTTP, economia, battle simulator ou schema. Adicione cobertura GUT focada em contrato render-only quando util. Valide validate.gd, GUT, smoke_session_shell.gd, smoke_battle_replay.gd e git diff --check.
```

## Agente 4 - T05-D Service Contracts

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Dependa de T05-A. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t05-service-contracts e branch codex/draxos-mobile/t05-service-contracts.

Objetivo: preparar fundacao de servicos sem implementar servico novo e sem migration. Classifique endpoints e funcoes atuais como save-scoped, account-scoped, release, telemetry ou admin-future em docs/contracts e architecture. Verifique se novos endpoints futuros devem declarar escopo explicitamente. Adicione testes Deno apenas se forem checks de contrato/escopo/idempotencia sobre comportamento existente.

Nao criar account_profiles/game_saves. Nao mudar schema, economia, ranking ou payload publico salvo correcao de documentacao. Valide deno task check em supabase/functions e server/functions, testes Deno adicionados e git diff --check.
```

## Agente 5 - T05-E Asset Pipeline

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Dependa de T05-A. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t05-asset-pipeline e branch codex/draxos-mobile/t05-asset-pipeline.

Objetivo: preparar o pipeline para assets reais sem importar arte final. Documente convencoes em assets/README.md ou docs equivalentes: pastas, nomes, formatos, tamanhos alvo, import policy Godot, fallback obrigatorio e estabilidade de ids. Revise core/asset_ids.gd para separar ids por categoria se necessario, mantendo paths atuais estaveis. Adicione teste para garantir que ids existem, paths sao estaveis e missing art continua permitido.

Nao trocar visual procedural por arte real nesta track. Nao criar assets finais. Valide validate.gd, GUT, smoke_exports.gd e git diff --check.
```

## Agente 6 - T05-F Progression Human Pack

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Dependa de T05-A. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t05-progression-human-pack e branch codex/draxos-mobile/t05-progression-human-pack.

Objetivo: preparar a rodada humana do Progression Lab antes de qualquer tuning. Criar checklist/runbook objetivo para testar 2h, 5h, 10h, 15h e 20h nos perfis free_100_rewards, freemium_basic, spender_light e max_spender, com foco obrigatorio em spender_light_10h, max_spender_10h, max_spender_20h, free_100_rewards_20h e freemium_basic_20h.

Nao alterar numeros de economia, poder, bots, loja, recompensas ou combate. Atualize docs/progression-lab e Track 05 com criterios de decisao para premium gap, janela 20h, bots ponte, recursos e pesos de poder. Valide smoke_dev_labs.gd, checks do Progression Lab quando aplicavel e git diff --check.
```

## Agente 7 - T05-G Release Ops

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Dependa de T05-A. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t05-release-ops e branch codex/draxos-mobile/t05-release-ops.

Objetivo: estabilizar a fundacao operacional de release sem publicar build nova. Revisar manifest/version gate, scripts de export/publicacao, documentacao Cloudflare Pages + Supabase Storage e smokes remotos existentes. Formalizar checklist release-ready para Android, PC e Web. Se adicionar smoke, ele deve apenas validar manifest/download/config existente e nao redeployar nada.

Nao mexer em secrets, nao publicar, nao alterar manifest remoto real, nao gerar build final. Valide smoke_exports.gd, checks de scripts quando houver modo seguro, git diff --check e documente qualquer validacao remota que exija credenciais.
```

## Agente 8 - T05-H Integracao

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. So comece depois de T05-B a T05-G entregarem. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t05-integration e branch codex/draxos-mobile/t05-integration.

Objetivo: integrar as trilhas da Track 05 em ordem segura, resolver conflitos, validar a fundacao completa e atualizar status. Preserve decisoes: sem migration account_profiles/game_saves, sem economia nova, sem assets finais, sem servicos novos de gameplay. Se alguma trilha falhar validacao, nao esconda: registre bloqueio e pare a integracao.

Validacao final obrigatoria: validate.gd, GUT completo, smoke_session_shell.gd, smoke_battle_replay.gd, smoke_dev_labs.gd, smoke_dev_lab_ui.gd, smoke_exports.gd, smokes novos da Track 05, deno task check em supabase/functions e server/functions quando aplicavel, git diff --check. Atualize current-status, Track 05 current-status e snapshots de portfolio.
```
