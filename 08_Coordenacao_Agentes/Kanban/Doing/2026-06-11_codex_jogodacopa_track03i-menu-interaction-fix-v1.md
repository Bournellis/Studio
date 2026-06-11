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

- `Projetos/JogoDaCopa/tests/unit/test_bootstrap.gd`
- `Projetos/JogoDaCopa/modes/menu/main_menu_root.gd`
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

Fase 2 reproduzida: todos os controles clicaveis falham porque `MainMenuRoot` esta com rect de hit-test `0x0`. Isso colapsa `MenuSafeArea` para altura `36.0` e `MenuScroll` para altura `0.0`; os botoes/sliders existem e tem rect visual, mas ficam fora da area valida dos ancestrais e `gui_get_hovered_control()` retorna `<none>`.

## Progresso

- [x] Fase 1: main limpo, worktree/branch criadas, card Doing registrado.
- [x] Fase 2: teste vermelho de clique real criado, executado e marcado `pending()` para commit.
- [x] Fase 3: menu simplificado e teste verde nas tres resolucoes.
- [x] Fase 4: regra permanente de UI documentada e screenshots gerados.
- [ ] Fase 5: validacao, status, merge, card Done, prune e `WORKTREE_VERIFIED`.

## Proximo Handoff

Fechar coordenacao: atualizar snapshots, mover card para Done, mergear em `main`, podar worktree e executar o check final `WORKTREE_VERIFIED`.
