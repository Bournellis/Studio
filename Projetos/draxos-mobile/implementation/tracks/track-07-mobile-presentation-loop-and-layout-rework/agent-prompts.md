# Track 07 - Agent Prompts

## Agente 1 - T07-A Coordenacao

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Nao edite direto em D:\Estudio: crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t07-coordenacao e branch codex/draxos-mobile/t07-coordenacao.

Objetivo: abrir Track 07 - Mobile Presentation Loop And Layout Rework. Criar docs da track, registrar Kanban/Doing, atualizar implementation/current-status.md, Prioridades_Estudio.md, Estado_Atual.md e Projetos/README.md. Escopo: documentacao/coordenacao apenas. Sem Godot runtime, backend, schema, economia ou assets finais. Valide com git diff --check.
```

## Agente 2 - T07-B App Shell/Foundation

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t07-app-shell-foundation e branch codex/draxos-mobile/t07-app-shell-foundation. Dependa de T07-A.

Objetivo: criar a fundacao de apresentacao mobile: contrato de rotas, back stack, helpers de orientacao, helpers de scroll/touch e shell sem nav global tipo abas. App fora de jogo deve suportar portrait/landscape; battle_running deve declarar landscape. Nao alterar backend nem presenters de conteudo alem do necessario para plugar no novo shell. Valide validate.gd, GUT e git diff --check.
```

## Agente 3 - T07-C Refugio/Home

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t07-refugio-home e branch codex/draxos-mobile/t07-refugio-home. Dependa de T07-B.

Objetivo: transformar o Refugio em home full screen com altar/ambiente central e hotspots para Batalha, Base, Social, Competicao, Loja, Perfil/Conta e Labs dev. Reorganizar login/registro para painel de conta sem lista redundante. Progression Lab deve aparecer quando dev tools/editor estiverem habilitados. Preservar acoes existentes no boot.gd. Valide GUT de Refugio/conta/labs, smoke_session_shell.gd, validate.gd e git diff --check.
```

## Agente 4 - T07-D App Screens

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t07-app-screens e branch codex/draxos-mobile/t07-app-screens. Dependa de T07-B.

Objetivo: adaptar Base, Social, Competicao e Loja para telas internas abertas a partir do Refugio, com Voltar, portrait/landscape, scroll confortavel e sem lista de abas. Pode manter presenters render-only, mas deve ajustar layout para tela completa ou painel parcial quando fizer sentido. Nao alterar endpoints, schema, economia, ranking ou mensagens de contrato. Valide smoke_foundation_surfaces.gd, validate.gd, GUT e git diff --check.
```

## Agente 5 - T07-E Battle Fullscreen

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t07-battle-fullscreen e branch codex/draxos-mobile/t07-battle-fullscreen. Dependa de T07-B.

Objetivo: fazer a batalha/replay do autobattler abrir em fullscreen landscape. Em Android, forcar landscape durante battle_running e restaurar orientacao do app ao sair. Em PC/Web, renderizar layout landscape funcional dentro da janela. Botao Pular fixo no canto inferior direito; apos pular/finalizar, mostrar summary com estatisticas e Voltar ao Refugio. Nao alterar simulador, recompensa, battle_log_v1 ou endpoints. Valide smoke_battle_replay.gd, GUT de battle fullscreen/summary, validate.gd e git diff --check.
```

## Agente 6 - T07-F PC/Web + Validation

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t07-pc-web-validation e branch codex/draxos-mobile/t07-pc-web-validation. Dependa de T07-C, T07-D e T07-E.

Objetivo: adicionar smoke de apresentacao/layout para portrait, landscape, PC e browser. Cobrir back stack, scroll sobre botoes, Refugio home, Progression Lab dev, battle fullscreen e summary. Nao mudar produto; apenas cobertura e pequenos ajustes de compatibilidade se necessario. Valide smoke_mobile_presentation.gd, smoke_exports.gd, validate.gd, GUT e git diff --check.
```

## Agente 7 - T07-G Integracao

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t07-integration e branch codex/draxos-mobile/t07-integration. So comece depois de T07-C a T07-F entregarem.

Objetivo: integrar a Track 07 completa, resolver conflitos, validar tudo e atualizar status/portfolio. Guardrails: sem backend, sem schema, sem tuning, sem publicacao remota, sem mobile browser como alvo primario. Validacao final: validate.gd, GUT completo, smoke_session_shell.gd, smoke_battle_replay.gd, smoke_foundation_surfaces.gd, smoke_exports.gd, smoke_mobile_presentation.gd e git diff --check.
```
