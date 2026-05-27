# Track 04 - Prompts Para Agentes Paralelos

- Data: `2026-05-27`
- Status: `ACTIVE_POST_ALPHA_EVOLUTION`
- Uso: copiar um prompt por nova thread/agente.
- Regra: cada agente deve criar/usar worktree propria fora de `D:\Estudio`.

## Agente 1 - Coordenacao T04-A

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Use a skill estudio-workspace se disponivel. O Internal Alpha v0 ja foi testado por Fabio + tester e passou. Sua tarefa e apenas documentacao/coordenacao: criar worktree propria em D:\Estudio-worktrees\draxos-mobile--codex--t04-coordenacao, branch codex/draxos-mobile/t04-coordenacao, registrar a entrada em Kanban/Doing, atualizar current-status, Track 04 current-status/implementation-plan, Prioridades_Estudio.md, Estado_Atual.md e Projetos/README.md para marcar Track 04 como ACTIVE_POST_ALPHA_EVOLUTION. Nao altere codigo Godot/backend. Valide com git diff --check e entregue resumo dos arquivos alterados.
```

## Agente 2 - Hub Scaffold T04-B

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Dependa da atualizacao T04-A. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t04-hub-scaffold, branch codex/draxos-mobile/t04-hub-scaffold. Objetivo: mapear modes/boot/boot.gd e criar o scaffold de modularizacao do Hub sem mudanca funcional. Use presenters render-only em modes/boot/surfaces/, com host: Node chamando helpers existentes. Nao mova actions/network ainda. Atualize/adicione plano local da modularizacao na Track 04. Valide com Godot validate, GUT e git diff --check.
```

## Agente 3 - Shell/Login/Update T04-C

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Baseie-se no branch ja atualizado com T04-B. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t04-shell-login-update, branch codex/draxos-mobile/t04-shell-login-update. Objetivo: extrair renderizacao de shell, login, save ativo, status de sessao e update gate para presenter em modes/boot/surfaces/. Nao altere Auth, Supabase, manifest, SessionStore ou BackendConfig. Actions continuam em boot.gd. Valide smoke_session_shell.gd, validate.gd, GUT e git diff --check.
```

## Agente 4 - Base/Loja T04-D

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Baseie-se no branch com T04-C. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t04-base-loja, branch codex/draxos-mobile/t04-base-loja. Objetivo: extrair renderizacao da Base e da Loja para presenters render-only. Preserve endpoints base/* e monetization/*, economia, fila dupla, redeems e mensagens existentes. Nao mude schema nem contratos. Valide validate.gd, GUT, smoke alpha loop relevante se existir, e git diff --check.
```

## Agente 5 - Social/Competicao T04-E

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Baseie-se no branch com T04-C. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t04-social-competicao, branch codex/draxos-mobile/t04-social-competicao. Objetivo: extrair renderizacao de Social e Competicao para presenters render-only. Preserve polling/chat/ranking, save progression_lab fora do ranking, bots fora da leaderboard e mensagens atuais. Nao mude backend, schema ou contratos. Valide validate.gd, GUT e git diff --check.
```

## Agente 6 - Batalha/Replay T04-F

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Baseie-se no branch com T04-C. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t04-batalha-replay, branch codex/draxos-mobile/t04-batalha-replay. Objetivo: extrair renderizacao/controles da aba Batalha para presenter render-only, preservando BattleLogPresenter, BattleVisualMockup e BattleStage2D. Nao altere battle simulator, reward, battle_log_v1 ou endpoints battle/*. Valide smoke_battle_replay.gd, GUT de battle visual/stage e git diff --check.
```

## Agente 7 - Progression/Economia T04-G

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t04-progression-economia, branch codex/draxos-mobile/t04-progression-economia. Objetivo: rodar/registrar rodada humana ou tecnica do Progression Lab para 2h, 5h, 10h, 15h e 20h nos perfis free, freemium, light e max. Produza recomendacoes documentadas para premium gap, janelas 15h/20h, poder, bots e recursos. Nao altere numeros de economia ainda sem decisao explicita. Valide labs quando aplicavel.
```

## Agente 8 - Account/Save Gate T04-H

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t04-account-save-gate, branch codex/draxos-mobile/t04-account-save-gate. Objetivo: avaliar o modelo atual players.save_type depois do alpha aprovado e decidir documentadamente se ele continua ou se devemos planejar account_profiles + game_saves. Nao implemente migration. Analise docs/contracts/database-schema.md, architecture.md, current-status e funcoes account/social/competition/monetization. Entregue decisao, riscos e plano de migration somente se necessario.
```
