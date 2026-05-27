# Track 06 - Agent Prompts

## Agente 1 - T06-A Coordenacao

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Use a skill estudio-workspace se disponivel. Nao edite direto em D:\Estudio: crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t06-coordenacao e branch codex/draxos-mobile/t06-coordenacao.

Objetivo: abrir oficialmente a Track 06 - Feature Installation Rails And First Feature Slices. Criar implementation/tracks/track-06-feature-installation-rails-and-first-slices/ com scope.md, current-status.md, implementation-plan.md, feature-registry.md, agent-registry.md e agent-prompts.md. Registrar Kanban/Doing. Atualizar implementation/current-status.md, AGENTS.md, Prioridades_Estudio.md, Estado_Atual.md e Projetos/README.md para indicar que Track 06 esta ativa para instalacao de features sobre a fundacao Track 05.

Escopo: documentacao/coordenacao apenas. Nao alterar Godot, Supabase, schema, economia, assets ou endpoints. Valide com git diff --check e entregue resumo dos arquivos alterados.
```

## Agente 2 - T06-B Feature Rails

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Dependa de T06-A. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t06-feature-rails e branch codex/draxos-mobile/t06-feature-rails.

Objetivo: criar o contrato padrao de instalacao de features, consolidar feature-registry.md, template/checklist por feature e regra de validacao por surface. Toda feature deve declarar owner, surface, endpoints afetados, escopo de servico, smoke/GUT obrigatorio, fallback e rollback.

Escopo: docs/contratos de instalacao e pequenos checks de documentacao se uteis. Sem runtime gameplay, sem economia, sem schema, sem asset final. Valide com git diff --check e valide Godot apenas se tocar tooling/client.
```

## Agente 3 - T06-C Runtime Config

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Dependa de T06-A. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t06-runtime-config e branch codex/draxos-mobile/t06-runtime-config.

Objetivo: implementar GET /release/config como endpoint release-scoped read-only, sem secrets e sem gameplay state mutavel, retornando runtime_config_v1 com flags para as features T06. Adicionar cliente Godot para buscar config, fallback conservador quando indisponivel, docs de contrato e smoke/GUT focado.

Nao alterar release/manifest, publicacao remota, economia, schema ou secrets. Valide Deno checks em supabase/functions e server/functions, smoke novo, validate.gd, GUT quando aplicavel e git diff --check.
```

## Agente 4 - T06-D Perfil/Conta

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Baseie-se no branch ja atualizado com T06-B. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t06-profile-account e branch codex/draxos-mobile/t06-profile-account.

Objetivo: instalar painel de perfil/conta usando estado existente: SessionStore, account/state, save ativo, username, level, poder, auth method, update state e status alpha. Use presenters render-only quando tocar surfaces. Sem endpoint novo.

Nao alterar Auth, Supabase schema, SessionStore contrato persistido, BackendConfig ou economia. Valide GUT/smoke de perfil, validate.gd, GUT completo e git diff --check.
```

## Agente 5 - T06-E Battle History

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Baseie-se no branch ja atualizado com T06-B. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t06-battle-history e branch codex/draxos-mobile/t06-battle-history.

Objetivo: implementar historico de batalhas read-only: GET /battle/history para lista recente e GET /battle/replay?battle_id=... para log completo do save ativo. Instalar UI na aba Batalha para listar batalhas recentes e reproduzir replay salvo sem reaplicar recompensa.

Nao alterar battle simulator, reward, battle_log_v1, economia, ranking ou schema salvo bloqueio documentado e parada para decisao. Valide Deno checks, smoke battle history/replay, smoke_battle_replay.gd, GUT e git diff --check.
```

## Agente 6 - T06-F Base Routine

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Baseie-se no branch ja atualizado com T06-B. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t06-base-routine e branch codex/draxos-mobile/t06-base-routine.

Objetivo: adicionar painel de rotina/proximo objetivo da Base usando payload existente: coleta pronta, jobs, slot livre e proximo upgrade legivel. Sem economia nova e sem endpoint novo.

Preserve endpoints base/*, fila dupla, mensagens existentes e presenter render-only. Valide GUT/smoke focado, smoke_foundation_surfaces.gd, validate.gd, GUT completo e git diff --check.
```

## Agente 7 - T06-G Social QoL

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Baseie-se no branch ja atualizado com T06-B. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t06-social-qol e branch codex/draxos-mobile/t06-social-qol.

Objetivo: melhorar leitura de amigos/guilda/chat, estados vazios, refresh e mensagens atuais. Sem social realtime, moderacao nova, schema novo ou endpoint novo salvo bloqueio documentado.

Preserve polling/chat/ranking, save progression_lab fora do ranking e bots fora da leaderboard. Valide GUT/smoke focado, smoke_foundation_surfaces.gd, validate.gd, GUT completo e git diff --check.
```

## Agente 8 - T06-H Asset Pack 01

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Baseie-se no branch ja atualizado com T06-B. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t06-asset-pack-01 e branch codex/draxos-mobile/t06-asset-pack-01.

Objetivo: instalar primeiro pacote visual seguro conforme assets/README.md e AssetIds: UI icons, battle icons/fx ou portraits pequenos. Missing art continua permitido e fallback obrigatorio.

Nao fazer rework visual amplo, nao trocar sistemas por arte final obrigatoria e nao quebrar exports. Valide AssetIds/fallback GUT, validate.gd, smoke_exports.gd e git diff --check.
```

## Agente 9 - T06-I Integracao

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. So comece depois de T06-C a T06-H entregarem. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t06-integration e branch codex/draxos-mobile/t06-integration.

Objetivo: integrar as trilhas da Track 06 em ordem segura, resolver conflitos, validar matriz Track 05 + smokes novos e atualizar status. Preserve decisoes: sem tuning numerico, sem migration account_profiles/game_saves, sem pagamento real, sem iOS/mobile browser, sem social realtime e sem publicacao remota.

Validacao final obrigatoria: validate.gd, GUT completo, smoke_session_shell.gd, smoke_battle_replay.gd, smoke_foundation_surfaces.gd, smoke_exports.gd, smoke runtime config, smoke battle history/replay, Deno checks em supabase/functions e server/functions quando aplicavel, git diff --check. Atualize current-status, Track 06 current-status e snapshots de portfolio.
```
