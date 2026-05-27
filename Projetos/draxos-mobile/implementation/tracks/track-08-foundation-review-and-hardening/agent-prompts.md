# Track 08 - Agent Prompts

## Agente 1 - T08-A Coordenacao/Audit

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Não edite direto em D:\Estudio: crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t08-coordenacao e branch codex/draxos-mobile/t08-coordenacao.

Objetivo: abrir Track 08 - Foundation Review And Hardening. Criar docs da track, agent registry, prompts e foundation-gap-report.md. Atualizar implementation/current-status.md, AGENTS.md, Prioridades_Estudio.md, Estado_Atual.md e Projetos/README.md para indicar Track 08 ativa. Escopo docs/coordenação apenas; sem Godot runtime, backend, schema, economia, assets finais ou publicação. Valide com git diff --check.
```

## Agente 2 - T08-B App Shell Lifecycle

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t08-app-shell-lifecycle e branch codex/draxos-mobile/t08-app-shell-lifecycle. Dependa de T08-A.

Objetivo: consolidar o contrato interno de rotas/back/orientação pós-Track 07. Extrair helper pequeno e testável para rotas se isso reduzir risco, mantendo boot.gd como orquestrador. Cobrir aliases legacy, Refúgio como root, back stack, battle_running landscape e summary/refuge return. Não alterar backend, gameplay, schema ou UI visual ampla. Valide validate.gd, GUT e git diff --check.
```

## Agente 3 - T08-C Session/Save Boundary

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t08-session-save-boundary e branch codex/draxos-mobile/t08-session-save-boundary. Dependa de T08-A.

Objetivo: endurecer invariantes de SessionStore/SupabaseClient: save normal vs progression_lab, cache local-only, runtime config fallback, snapshot por surface e reset/troca de save. Pode adicionar diagnostics_snapshot sem secrets para debug interno. Não mudar Auth, contratos HTTP, schema, players.save_type ou payload público. Valide tests/client/test_session_shell.gd, validate.gd, GUT e git diff --check.
```

## Agente 4 - T08-D Mobile UI Contract

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t08-mobile-ui-contract e branch codex/draxos-mobile/t08-mobile-ui-contract. Dependa de T08-A.

Objetivo: centralizar regras de UI mobile: alvo mínimo de botão, drag threshold, scrollbar/touch policy e layout portrait/landscape. Reusar DraxosTouchScrollContainer e aplicar helper comum onde já existe botão/scroll do shell. Não fazer redesign visual nem trocar assets. Valide GUT de touch/scroll/buttons, smoke_mobile_presentation.gd, validate.gd e git diff --check.
```

## Agente 5 - T08-E Battle Mode Contract

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t08-battle-mode-contract e branch codex/draxos-mobile/t08-battle-mode-contract. Dependa de T08-B.

Objetivo: formalizar batalha/replay como gameplay mode: fullscreen sem app chrome, landscape em battle_running, skip seguro, summary obrigatório, replay/histórico read-only e retorno ao Refúgio. Não alterar simulador, battle_log_v1, recompensa, ranking ou endpoints battle/*. Valide smoke_battle_replay.gd, GUT battle fullscreen/summary, validate.gd e git diff --check.
```

## Agente 6 - T08-F Service/Asset Contract Checks

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t08-service-asset-contracts e branch codex/draxos-mobile/t08-service-asset-contracts. Dependa de T08-A.

Objetivo: adicionar checagens leves de fundação para docs/contracts, feature registry e AssetIds. Garantir que endpoint matrix declare escopo, novos feature cards não tenham campos vazios, e asset ids/fallback continuem estáveis. Não criar endpoint, schema, migration, asset final ou serviço novo. Valide Deno checks quando adicionar teste, validate.gd/GUT se tocar client, e git diff --check.
```

## Agente 7 - T08-G Validation Harness

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t08-validation-harness e branch codex/draxos-mobile/t08-validation-harness. Dependa de T08-B a T08-F.

Objetivo: criar tools/smoke_foundation_hardening.gd e atualizar tools/README.md/matriz quick/full/release para Track 08. O smoke deve cobrir rotas, back stack, session/save boundary, touch/layout contract e battle mode sem depender de rede quando possível. Não mudar produto. Valide smoke_foundation_hardening.gd, validate.gd, GUT e git diff --check.
```

## Agente 8 - T08-H Integracao

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t08-integration e branch codex/draxos-mobile/t08-integration. Só comece depois de T08-B a T08-G entregarem.

Objetivo: integrar Track 08 completa, resolver conflitos, validar matriz final e atualizar status/portfolio. Guardrails: sem gameplay novo, sem tuning, sem backend endpoint novo, sem schema, sem migration account_profiles/game_saves, sem assets finais e sem publicação remota. Validação final: validate.gd, GUT completo, smoke_session_shell.gd, smoke_runtime_config.gd, smoke_mobile_presentation.gd, smoke_foundation_hardening.gd, smoke_foundation_surfaces.gd, smoke_battle_replay.gd, smoke_exports.gd, Deno checks se aplicável e git diff --check.
```
