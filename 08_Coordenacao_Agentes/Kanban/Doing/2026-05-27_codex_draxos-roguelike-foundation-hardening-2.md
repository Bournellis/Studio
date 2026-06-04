# Draxos Roguelike Cardgame - Foundation Hardening 2

- Data: `2026-05-27`
- Agente: `Codex`
- Branch: `codex/draxos-roguelike-cardgame/foundation-hardening-2`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--foundation-hardening-2`
- Base: `33be2ff` (`codex/draxos-roguelike-cardgame/foundation-hardening`)

## Objetivo

Executar a segunda passada de fundacao do Draxos Roguelike Cardgame sem conteudo novo nem rebalanceamento: limpar documentacao satelite obsoleta, criar checklist de playtest Track 02, extrair a simulacao de pacing para um servico compartilhado entre validacao e Run Lab, preservar metricas atuais e atualizar snapshots/handoff.

## Arquivos Pretendidos

- `Projetos/draxos-roguelike-cardgame/docs/`
- `Projetos/draxos-roguelike-cardgame/tools/`
- `Projetos/draxos-roguelike-cardgame/tests/unit/`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-roguelike-cardgame/AGENTS.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/current-status.md`

## Validacao Planejada

- Rodar `tools/validate.gd` duas vezes em headless e confirmar worktree limpa.
- Rodar `tools/run_lab.gd -- --classes=arcano,invocador,necromante --seeds=20260518`.
- Verificar busca final de termos obsoletos (`Track 01`, `13 mapas`, `save v4`, `save version 4`, `v3`, `1126`, `93/93`) aceitando apenas usos historicos.

## Handoff

Status parcial:

- Simulador compartilhado criado em `tools/route_pacing_simulator.gd`.
- `validate.gd` e `run_lab.gd` usam o mesmo simulador.
- GUT dedicado cobre schema/paridade do simulador.
- Docs satelite obsoletos foram limpos ou marcados como historicos.
- Checklist humano criado em `docs/playtest-track-02.md`.
- Validacao final dupla verde: 96/96 GUT, 1206 asserts, smoke 29/29.
- Run Lab final verde para Arcano/Invocador/Necromante seed `20260518`.
- Busca final de termos obsoletos manteve apenas usos historicos ou de outros projetos.

Handoff esperado: commit logico, validacao verde dupla, Run Lab verde e resumo dos arquivos alterados.
