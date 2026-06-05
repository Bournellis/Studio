# Draxos Roguelike Cardgame - AutoRun Gate Pack V1

- Data: `2026-06-05`
- Agente: `Codex`
- Projeto: `draxos-roguelike-cardgame`
- Branch: `codex/draxos-roguelike-cardgame/autorun-gate-pack-v1`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--autorun-gate-pack-v1`
- Base: `master` em `1617043`

## Objetivo

Transformar o AutoRun Lab V1 em contrato operacional de regressao por meio de baselines oficiais versionados, modo gate explicito, scorecard humano de tuning e testes unitarios do envelope de aceitacao.

## Arquivos Previstos

- `Projetos/draxos-roguelike-cardgame/tools/run_lab.gd`
- `Projetos/draxos-roguelike-cardgame/tools/lab/`
- `Projetos/draxos-roguelike-cardgame/data/lab/baselines/`
- `Projetos/draxos-roguelike-cardgame/tests/unit/`
- `Projetos/draxos-roguelike-cardgame/docs/autorun-lab.md`
- `Projetos/draxos-roguelike-cardgame/docs/architecture.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-roguelike-cardgame/AGENTS.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/current-status.md`
- `Projetos/draxos-roguelike-cardgame/docs/autorun-lab.md`

## Validacao Planejada

- Rodar `tools/run_lab.gd -- --mode=gate --baseline=track02_smoke_v1`.
- Rodar `tools/run_lab.gd -- --mode=gate --baseline=track02_quick_v1`.
- Rodar `tools/run_lab.gd -- --preset=quick --scorecard`.
- Rodar `tools/validate.gd` headless completo.

## Entrega

- Baselines oficiais criados em `Projetos/draxos-roguelike-cardgame/data/lab/baselines/track02_smoke_v1.json` e `track02_quick_v1.json`.
- `tools/run_lab.gd` ganhou `--mode=gate`/`--gate`, resolucao de baseline oficial por nome e falha com exit code `1` em mismatch.
- `tools/lab/lab_baseline_store.gd` passou a comparar summary, grupos por classe e grupos por politica com mensagens acionaveis.
- `tools/lab/lab_scorecard.gd` gera scorecard JSON/Markdown para leitura humana de sobrevivencia, rota, economia, deck, classes, politicas e risk maps.
- `tools/lab/lab_reporter.gd` escreve `run_lab_scorecard.json` e `run_lab_scorecard.md`.
- Testes unitarios cobrem baseline oficial, falha de gate e scorecard.
- Docs/status/coordenacao atualizados sem alterar balanceamento ou runtime de gameplay.

## Validacao Executada

- `tools/run_lab.gd -- --mode=gate --preset=smoke --baseline=track02_smoke_v1`
  - Resultado: PASS.
- `tools/run_lab.gd -- --mode=gate --preset=quick --baseline=track02_quick_v1`
  - Resultado: PASS, `30` casos e scorecard gerado.
- `tools/validate.gd`
  - Primeiro uso na worktree exigiu import headless de editor, caso conhecido.
  - Resultado apos import: PASS, `111/111` testes, `1313` asserts.

## Handoff

Trabalho pronto para commit e merge em `master`. Proximo passo de produto permanece playtest humano da Track 02 completa; proximo passo de ferramenta recomendado e Scenario Fixtures ou Gameplay Lab depois que o gate for usado em pelo menos um ciclo real de tuning/playtest.
