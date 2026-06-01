# Codex - Scroll Drag Release Fix

- Data: `2026-06-01`
- Projeto: `Projetos/draxos-mobile`
- Branch: `codex/draxos-mobile/scroll-drag-release-fix`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--scroll-drag-release-fix`
- Base operacional: `codex/draxos-mobile/modes-integrated-alpha`
- Commit: `c7735c5`
- Status: `IMPLEMENTED_VALIDATED`

## Objetivo

Corrigir o bug em telas com scroll onde o mouse podia ficar preso e continuar puxando a tela como se o scroll estivesse agarrado.

## Resultado

- `DraxosTouchScrollContainer` agora escuta release global de mouse/toque.
- Movimento de mouse sem o botao esquerdo pressionado limpa automaticamente o estado de drag.
- Scroll por toque passa a respeitar o indice ativo do toque.
- Testes cobrem release global e motion stale sem botao pressionado.

## Validacao

- `git diff --check`: verde.
- Godot import headless: verde.
- GUT client: `153/153` testes, `2428` asserts.
- `tools/smoke_responsive_layout.gd`: verde.
- `tools/validate.gd`: verde.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile Client`: verde.

## Proximo Passo

Entrar no build seguinte e tentar reproduzir em telas com scroll no mouse: arrastar, soltar fora da area do scroll, mover o mouse sem botao pressionado e confirmar que a tela nao continua agarrada.
