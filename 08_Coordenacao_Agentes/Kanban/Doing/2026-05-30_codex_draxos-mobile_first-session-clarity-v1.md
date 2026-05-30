# DraxosMobile - First Session Clarity v1

- Data: 2026-05-30
- Agente: Codex
- Status: DOING
- Branch: `codex/draxos-mobile/first-session-clarity-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--first-session-clarity-v1`
- Projeto: `Projetos/draxos-mobile/`
- Base: `1534550 docs(draxos-mobile): register potions behavior baseline`

## Objetivo

Executar o pacote First Session Clarity v1 para transformar a baseline publicada de Progression Clarity v1 em uma primeira sessao mais clara: entrar, entender o Refugio, coletar, evoluir, preparar, batalhar, receber recompensa e voltar para a base com proximo passo legivel.

## Escopo

- Documentar `docs/first-session-clarity-v1.md`.
- Melhorar copy/hierarquia de Refugio, Preparacao e Resultado sem novo backend/schema/tuning.
- Reforcar a leitura de primeira sessao usando snapshots existentes.
- Adicionar ou ampliar smoke/teste sem rede para proteger a sequencia da primeira sessao.
- Atualizar status/docs vivos e publicar Internal Alpha apos validacao.

## Fora De Escopo

- Novo backend, schema ou migration.
- Tuning de XP, economia, poder, recompensa, armas, spells, pocoes ou comportamento avancado.
- Social expansion, direct chat, ajudas, contribuicoes ou moderacao.
- Account/save migration.
- Visual final, assets finais ou onboarding narrativo longo.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/foundation-app-v0-audit.md`
- `Projetos/draxos-mobile/docs/foundation-loop-audit.md`
- `Projetos/draxos-mobile/docs/product-vision.md`
- `Projetos/draxos-mobile/docs/product-brief.md`
- `Projetos/draxos-mobile/docs/design-pending.md`
- `Projetos/draxos-mobile/docs/progression-clarity-v1.md`
- `Projetos/draxos-mobile/docs/behavior-potion-crafting-v1.md`

## Validacao Planejada

```powershell
git diff --check
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Client
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools\smoke_foundation_loop.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools\smoke_responsive_layout.gd
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_agent_ops_foundation.ps1 -ProjectDir .
```

Publicacao aprovada pelo usuario nesta tarefa: usar `publish_internal_alpha.ps1` com `-ConfirmRemoteMutation` apos validacao local.

## Handoff Planejado

Entregar commit(s), publicar Internal Alpha, mover esta nota para Done e atualizar snapshots vivos apenas no necessario.
