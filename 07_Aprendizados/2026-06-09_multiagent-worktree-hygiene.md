# Aprendizado: Higiene De Worktrees Multiagente

- Data: `2026-06-09`
- Area: operacao multiagente

## Problema

O Estudio roda varias linhas de DraxosMobile e Draxos Roguelike em paralelo. Editar a arvore principal ou um worktree de outro agente aumenta o risco de sobrescrever trabalho valido.

## Regra

- Use worktree externo para trabalho substancial.
- Nomeie branch e worktree pelo projeto/agente/slug.
- Antes de editar arquivos compartilhados, rode `git status --short` e `git worktree list`.
- Registre objetivo, arquivos pretendidos, validacao e handoff em Doing ou Handoff.
- Nunca reverta mudancas que voce nao fez.

## Exemplo

```text
D:\Estudio-worktrees\draxos-mobile--codex--meu-pacote
codex/draxos-mobile/meu-pacote
```
