# Draxos Roguelike Cardgame - AutoRun Lab V1

- Data: `2026-06-05`
- Agente: `Codex`
- Projeto: `draxos-roguelike-cardgame`
- Branch: `codex/draxos-roguelike-cardgame/autorun-lab-v1`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--autorun-lab-v1`
- Base: `master` em `782dc45`

## Objetivo

Transformar o Run Lab atual em uma fundacao estruturada para testes automaticos de gameplay, com matriz de casos, presets, politicas macro, relatorios agregados e baseline estatistico, preservando compatibilidade com a validacao/golden atual da Track 02.

## Arquivos Previstos

- `Projetos/draxos-roguelike-cardgame/tools/run_lab.gd`
- `Projetos/draxos-roguelike-cardgame/tools/route_pacing_simulator.gd`
- `Projetos/draxos-roguelike-cardgame/tools/run_lab_golden_metrics.gd`
- `Projetos/draxos-roguelike-cardgame/tools/lab/`
- `Projetos/draxos-roguelike-cardgame/tests/unit/`
- `Projetos/draxos-roguelike-cardgame/docs/`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/`

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-roguelike-cardgame/AGENTS.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/validation-and-tuning-notes.md`
- `Projetos/draxos-roguelike-cardgame/docs/architecture.md`
- `Projetos/draxos-roguelike-cardgame/docs/foundation-closeout.md`

## Validacao Planejada

- Rodar `tools/run_lab.gd -- --preset=smoke --compare-golden --require-golden`.
- Rodar um preset ampliado do AutoRun Lab, no minimo `quick`, gerando JSON/CSV/Markdown.
- Rodar `tools/validate.gd` headless completo.

## Entrega

- AutoRun Lab V1 modularizado em `tools/lab/`.
- `tools/run_lab.gd` preserva compatibilidade com golden atual e passa a suportar presets, politicas macro, baseline estatistico e relatorios agregados.
- `tools/route_pacing_simulator.gd` ganhou politicas parametrizadas e timeline por mapa sem alterar o baseline `baseline`.
- Documentacao nova em `Projetos/draxos-roguelike-cardgame/docs/autorun-lab.md`.
- Status local, arquitetura, notas de validacao, handoff da Track 02 e coordenacao do estudio atualizados.

## Validacao Executada

- `tools/run_lab.gd -- --preset=smoke --compare-golden --require-golden --out=user://run_lab/autorun_lab_smoke`
  - Resultado: PASS, `3/3` golden checks sem mismatch.
- `tools/run_lab.gd -- --preset=quick --seed-start=20260518 --seed-count=10 --out=user://run_lab/autorun_lab_quick --compare-baseline`
  - Resultado: PASS, `30` casos macro-route dentro do baseline estatistico default.
- `tools/validate.gd`
  - Resultado: PASS, `108/108` testes, `1304` asserts.

## Handoff

Trabalho pronto para merge em `master`. Proximo passo de produto permanece playtest humano da Track 02 completa, agora com AutoRun Lab V1 disponivel para regressao e tuning macro antes de novas mudancas sistemicas.
