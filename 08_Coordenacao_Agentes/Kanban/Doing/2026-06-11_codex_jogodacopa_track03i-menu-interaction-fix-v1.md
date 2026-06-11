# Track 03I - Menu Interaction Fix V1

- Data: `2026-06-11`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/JogoDaCopa/track03i-menu-interaction-fix-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03i-menu-interaction-fix-v1`
- Base: `main` em `078df1b` (`merge(jogodacopa): complete track 03h avatar parity drift`)
- Main workspace: estava limpo no momento da criacao da worktree; mudancas preexistentes foram preservadas em `stash@{0}` (`preserve-pre-track03i-main-dirty-state`)

## Objetivo

Reproduzir primeiro a falha real de clique no menu principal e, somente depois, corrigir por simplificacao radical da estrutura do menu.

## Contexto

Track aberta porque o menu principal ficou inutilizavel apos a 03G: nenhum controle responde a clique. Esta e a segunda falha consecutiva de UI, entao a evidencia minima desta track e teste de clique real via `Viewport.push_input`, atravessando o hit-test do Godot.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/tests/test_bootstrap.gd`
- `Projetos/JogoDaCopa/scenes/main_menu.tscn` ou gerador correspondente em `Projetos/JogoDaCopa/tools/`
- `Projetos/JogoDaCopa/docs/architecture-overview.md`
- `Projetos/JogoDaCopa/docs/screenshots/track-03i-menu/`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/implementation/tracks/track-03i-menu-interaction-fix-v1/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- Este card Kanban

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `AGENTS.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`

## Plano De Validacao

1. Adicionar teste vermelho de clique real em `test_bootstrap.gd`, cobrindo Futebol, Quit, setas de dificuldade, setas de modo e sliders de volume.
2. Rodar o teste antes do fix e registrar o controle bloqueador com `gui_get_hovered_control` ou mecanismo equivalente.
3. Simplificar o menu para hierarchy nativa de containers, com `IGNORE` explicito somente no preview e shade.
4. Parametrizar o teste real nas resolucoes `1920x1080`, `1366x768` e `1280x720`.
5. Rodar todos os testes existentes e `tools/validate.gd`.
6. Gerar screenshots do menu nas tres resolucoes.
7. Rodar `git diff --check`, `tools/check_doc_drift.ps1`, `git status --short` e integridade final.

## Causa Raiz

Pendente da Fase 2: deve registrar qual node bloqueia/intercepta o clique e por que.

## Progresso

- [x] Fase 1: main limpo, worktree/branch criadas, card Doing registrado.
- [ ] Fase 2: teste vermelho de clique real criado e executado.
- [ ] Fase 3: menu simplificado e teste verde nas tres resolucoes.
- [ ] Fase 4: regra permanente de UI documentada e screenshots gerados.
- [ ] Fase 5: validacao, status, merge, card Done, prune e `WORKTREE_VERIFIED`.

## Proximo Handoff

Se a Fase 2 passar no codigo atual, parar a track e registrar handoff pedindo mais dados de Fabio sobre resolucao, foco, pause ou ambiente especifico. Se falhar, seguir para a correcao por simplificacao.
