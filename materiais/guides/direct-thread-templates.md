# Direct Thread Templates

This file is the most direct copy-paste set for opening new Codex threads on the active Godot surface.

Use this when you already know the active track or gate and want the shortest prompt that still preserves execution discipline.

## Global Rule For Active Godot Threads

Every active implementation thread should:

- read `D:\Estudio\AGENTS.md`
- read `D:\Estudio\Projetos\rpg-isometrico\AGENTS.md`
- read `D:\Estudio\Projetos\rpg-isometrico\implementation\current-status.md`
- read the active track status and implementation map
- read the active gate named by `implementation/current-status.md` only when one is explicitly selected
- implement end-to-end when the request is implementation work
- update `implementation/current-status.md`, active track docs, relevant gate docs, and `implementation/execution-log.md` when operational state changes
- run or preserve `validate.gd + GUT` when code changes

## Generic Direct Template

```text
Execute {TASK_OR_GATE_SLICE} em D:\Estudio\Projetos\rpg-isometrico.

Leia e siga:
- D:\Estudio\AGENTS.md
- D:\Estudio\Projetos\rpg-isometrico\AGENTS.md
- D:\Estudio\Projetos\rpg-isometrico\implementation\current-status.md
- D:\Estudio\Projetos\rpg-isometrico\implementation\tracks\track-02-canonical-product-foundation\current-status.md
- D:\Estudio\Projetos\rpg-isometrico\implementation\tracks\track-02-canonical-product-foundation\implementation-map.md
- o gate ativo indicado por implementation/current-status.md, se houver um gate explicitamente selecionado
- D:\Estudio\Projetos\rpg-isometrico\docs\validation.md

Implemente end-to-end agora.
Nada de so planejar.
Atualize os arquivos operacionais se o estado mudar.
Rode validate.gd + GUT quando tocar runtime/testes.
No final: mudancas, validacao, pendencias.
```

## F11-E Extra Mode Framing (Completed Reference)

F11-E is complete. Use this block only for historical review or regression context, not as a current implementation template.

```text
Revise a slice F11-E concluida em D:\Estudio\Projetos\rpg-isometrico:
D:\Estudio\Projetos\rpg-isometrico\implementation\tracks\track-02-canonical-product-foundation\gates\gate-f11-campaign-first-runtime-alignment.md

Leia e siga:
- D:\Estudio\AGENTS.md
- D:\Estudio\Projetos\rpg-isometrico\AGENTS.md
- D:\Estudio\Projetos\rpg-isometrico\implementation\current-status.md
- D:\Estudio\Projetos\rpg-isometrico\implementation\tracks\track-02-canonical-product-foundation\current-status.md
- D:\Estudio\Projetos\rpg-isometrico\implementation\tracks\track-02-canonical-product-foundation\implementation-map.md
- D:\Estudio\Projetos\rpg-isometrico\implementation\tracks\track-02-canonical-product-foundation\gates\gate-f11-campaign-first-runtime-alignment.md
- D:\Estudio\Projetos\rpg-isometrico\docs\validation.md

Foque em Survival como desafio de resistencia, Boss como pratica de dominio/execucao, e Arena Bot como treino/teste de kit.
Nao promova PvP, matchmaking, ranked, co-op, Steam lobby, nova raca, nova arma ou Hard route.
Nao implemente runtime a partir deste template historico.
Use para revisar regressao ou entender contexto F11-E ja concluido.
No final: observacoes, riscos e arquivos que precisariam de novo gate se houver mudanca futura.
```

## Canon / Operational Alignment Audit

```text
Tipo: Canon + Operational audit
Objetivo: revisar skill, AGENTS.md, guias de thread e docs operacionais para remover contradicoes com o projeto atual.

Leia e siga:
- D:\Estudio\AGENTS.md
- D:\Estudio\canon\product\product-vision.md
- D:\Estudio\canon\design\game-design-document.md
- D:\Estudio\canon\design\progression-design.md
- D:\Estudio\canon\architecture\shared-architecture.md
- D:\Estudio\canon\architecture\game-mode-standard.md
- D:\Estudio\canon\roadmap\evolution-roadmap.md
- D:\Estudio\canon\roadmap\release-horizons.md
- D:\Estudio\canon\platform\steam-platform.md
- D:\Estudio\Projetos\rpg-isometrico\AGENTS.md
- D:\Estudio\Projetos\rpg-isometrico\implementation\current-status.md

Verifique referencias antigas a Unity, D:\RPG Isometrico, Phase 1, Phase 7, Assets/Game, Execution Script, passives, weapon swap, PvP publico, ranked, matchmaking e dedicated servers.
Corrija docs ativos; preserve arquivos historicos apenas quando estiverem claramente marcados como historicos.
Use rg normal para a superficie ativa; use caminhos explicitos ou rg --no-ignore somente quando a auditoria precisar incluir historico.
No final: arquivos alterados, contradicoes encontradas, pendencias.
```
