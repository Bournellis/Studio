# Thread Cheat Sheet

This is the short version of the Codex workflow guide for day-to-day thread opening.

Use this file when you want the fastest way to choose the right thread format and opening prompt.

For the full explanation, see `materiais/guides/codex-workflow-guide.md`.

## Quick

Use when:
- small bugfix
- local adjustment
- short follow-up on the same problem

Thread rule:
- usually keep the same thread if the goal and touched files are still the same

Prompt:

```text
Tipo: Quick
Objetivo: corrigir {bug curto}
Rota: bounded read order; sem mudancas de canon
```

## Review

Use when:
- you want risk and regression analysis only
- you do not want code changes yet

Thread rule:
- usually open a new thread if you are switching from implementation to review

Prompt:

```text
Tipo: Review
Objetivo: revisar {arquivos/tema}
Rota: bounded read order; nao implemente nada ainda
```

## Implementation

Use when:
- bounded implementation
- local feature or fix
- the task still fits inside the active surface without redefining canon

Thread rule:
- keep the same thread if it is still the same package of work

Prompt:

```text
Tipo: Implementation
Objetivo: implementar {feature/fix}
Rota: bounded read order se seguro; sem canon change sem me avisar
Validacao: validate.gd + GUT conforme o risco
```

## Gate

Use when:
- gate planning
- active slice execution
- operational status or next implementation package

Thread rule:
- usually open a new thread

Prompt:

```text
Tipo: Gate
Objetivo: planejar/executar {gate ou slice}
Rota: deep route + active track/gate
```

## Canon

Use when:
- product rule changes
- architecture changes
- networking or persistence rule changes
- platform or workflow changes

Thread rule:
- always open a new thread

Prompt:

```text
Tipo: Canon
Objetivo: atualizar/decidir {regra}
Rota: leia a rota canonica completa; pode atualizar docs
```

## Historical

Use when:
- historical lookup
- closed phase research
- comparing old behavior without treating it as active canon

Thread rule:
- usually open a new thread unless the active task explicitly depends on the lookup

Prompt:

```text
Tipo: Historical
Objetivo: consultar {tema historico}
Rota: bounded read order + caminhos historicos explicitos; nao tratar como canon atual
```

## The 5-Line Starter

This is the default opening structure for almost every new thread:

```text
Tipo: {Quick/Review/Implementation/Gate/Canon/Historical}
Objetivo: {uma frase}
Rota: {bounded read order / deep route}
Escopo: {arquivos ou pastas}
Regra: {sem canon changes / pode atualizar canon} + {validacao esperada}
```

## Execution Rule

For active implementation threads on the Godot surface:

- read `D:\Estudio\AGENTS.md`
- read `D:\Estudio\Projetos\rpg-isometrico\AGENTS.md`
- read `D:\Estudio\Projetos\rpg-isometrico\implementation\current-status.md`
- read the active track status, implementation map, and active gate only when `implementation/current-status.md` names one
- update active operational docs and `implementation/execution-log.md` when state or handoff context changes
- do not treat the thread as finished until validation status and operational state are clear

## Good Example

```text
Tipo: Implementation
Objetivo: ajustar copy e resultado do slice ativo selecionado
Rota: bounded read order se seguro
Escopo: Projetos/rpg-isometrico/modes/frontend/ e Projetos/rpg-isometrico/presentation/results/
Regra: sem mudancas de canon; valide com validate.gd + GUT se tocar runtime/testes
```

## Quick Rule Of Thumb

- If you can describe the task in one sentence and point to a small file set, use the bounded route.
- If you need to redefine the problem before coding, open a new thread and use the deep route.
- If the work changes nature, open a new thread instead of dragging the old one.
- If you are unsure, start from `D:\Estudio\AGENTS.md` and `implementation/current-status.md`.
- Use normal `rg` for active-surface searches; use explicit paths or `rg --no-ignore` only when historical material is intentionally needed.
