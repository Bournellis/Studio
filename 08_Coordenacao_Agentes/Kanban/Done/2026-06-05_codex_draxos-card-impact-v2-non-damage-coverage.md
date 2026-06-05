# Card Impact V2 Non-Damage Coverage

- Data: `2026-06-05`
- Agente: `Codex`
- Projeto: `Projetos/draxos-roguelike-cardgame/`
- Branch: `codex/draxos-roguelike-cardgame/card-impact-v2-non-damage-coverage`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--card-impact-v2-non-damage-coverage`
- Base: `codex/draxos-roguelike-cardgame/card-redesign-batch-01`

## Objetivo

Fortalecer o Card Impact V2 para detectar deltas non-damage em cartas do jogador: summons, buffs, debuffs, controle, economia/card-flow, escolhas/sacrificio e contaminacao por cartas de suporte, mantendo enemy signatures em report-only e gate estrutural conservador.

## Decisoes Confirmadas

- Evoluir `track02_card_impact_v2.json`; nao criar V3 nesta etapa.
- Ambiguidade e contaminacao por suporte geram WARN/report, nao FAIL.
- Gate continua falhando apenas por regressao estrutural.
- Probes temporarios podem ser usados durante implementacao, mas nao entram no commit.
- Enemy-card signatures continuam report-only.
- Execucao com agente unico.

## Arquivos Pretendidos

- `Projetos/draxos-roguelike-cardgame/tools/lab/battle_effect_signature.gd`
- `Projetos/draxos-roguelike-cardgame/tools/lab/card_impact_runner.gd`
- `Projetos/draxos-roguelike-cardgame/tools/lab/card_impact_reporter.gd`
- `Projetos/draxos-roguelike-cardgame/tools/lab/lab_diff_reporter.gd`
- `Projetos/draxos-roguelike-cardgame/data/lab/card_impact/track02_card_impact_v2.json`
- `Projetos/draxos-roguelike-cardgame/tests/unit/test_card_impact_tooling.gd`
- `Projetos/draxos-roguelike-cardgame/docs/autorun-lab.md`
- `Projetos/draxos-roguelike-cardgame/tools/README.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/validation-and-tuning-notes.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`

## Docs Lidos

- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-roguelike-cardgame/AGENTS.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/current-status.md`
- `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/validation-and-tuning-notes.md`

## Validacao Planejada

- `run_card_impact --phase=before --mode=gate --pack=track02_card_impact_v2 --cards=all --components=battle,scenario,run_lab`
- `run_card_impact --phase=after --mode=gate --pack=track02_card_impact_v2 --cards=all --components=battle,scenario,run_lab`
- `run_card_impact --phase=compare --mode=gate --pack=track02_card_impact_v2 --cards=all --components=battle,scenario,run_lab`
- `run_battle_lab --mode=gate --pack=track02_battle_core_v1`
- `run_scenarios --mode=gate --pack=track02_core_v1`
- `run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1`
- `run_lab --mode=gate --preset=quick --baseline=track02_quick_v1`
- `tools/validate.gd`

## Handoff

## Resultado

Implementado em `Projetos/draxos-roguelike-cardgame/`:

- `BattleEffectSignature` agora deriva deltas non-damage para summon, buff, debuff, controle, economia/card-flow, escolhas/sacrificio, logs/eventos e metadados de qualidade.
- `card_focus_legal` e `BattleRunner` registram sequencia de cartas, indice da carta alvo, suporte antes/depois do alvo e confianca da assinatura.
- `CardImpactRunner` agrega qualidade de assinatura por familia e inclui a leitura da execucao `after` tambem no `compare`.
- `CardImpactReporter` gera matriz non-damage e secao de contaminacao por suporte no Markdown.
- `track02_card_impact_v2.json` declara `effect_signatures.schema_version=2` e os novos campos comparaveis.
- Testes GUT cobrem deltas derivados, suporte assistido, compare non-damage e Markdown.

Resumo observado no compare final:

- Card Impact V2 gate PASS para `84/84` cartas ativas cobertas.
- Assinaturas: `54` cartas do jogador required, `30` cartas inimigas report-only/missing esperado.
- Qualidade de assinaturas: `45` clean, `9` support-assisted, `47` ambiguous por multiplas jogadas da carta alvo, `30` missing enemy report-only.
- Familias non-damage presentes no relatorio: `buff`, `control`, `debuff`, `economy`, `keyword`, `summon`.

## Validacao Executada

- PASS: `run_card_impact --pack=track02_card_impact_v2 --phase=before --mode=gate --out=user://card_impact/track02_card_impact_v2_non_damage_coverage`
- PASS: `run_card_impact --pack=track02_card_impact_v2 --phase=after --mode=gate --out=user://card_impact/track02_card_impact_v2_non_damage_coverage`
- PASS: `run_card_impact --pack=track02_card_impact_v2 --phase=compare --mode=gate --out=user://card_impact/track02_card_impact_v2_non_damage_coverage`
- PASS: `run_battle_lab --mode=gate --pack=track02_battle_core_v1` (`9 PASS`, `3 WARN`, `0 FAIL`)
- PASS: `run_scenarios --mode=gate --pack=track02_core_v1` (`9 PASS`, `3 WARN`, `0 FAIL`)
- PASS: `run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1`
- PASS: `run_lab --mode=gate --preset=quick --baseline=track02_quick_v1`
- PASS: `tools/validate.gd` (`157/157` GUT)

Observacoes nao bloqueantes:

- `tools/validate.gd` preserva os avisos ja conhecidos de assets visuais opcionais e alpha debts do ship overlay.
- GUT emite warnings conhecidos de recursos do addon, sem falha.

## Proxima Recomendacao

Antes de iniciar novo redesign grande de cartas, reduzir a ambiguidade do `card_focus_legal` com uma opcao de captura isolada por carta alvo: jogar suporte minimo necessario, jogar a carta alvo uma vez, capturar assinatura e encerrar a fase de cartas do turno. Isso deve diminuir o bloco `ambiguous` e tornar os deltas de Batch 02 mais precisos.
