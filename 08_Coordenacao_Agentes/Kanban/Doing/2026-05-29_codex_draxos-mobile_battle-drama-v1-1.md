# Battle Drama v1.1

- Data: `2026-05-29`
- Projeto: `Projetos/draxos-mobile`
- Agente: Codex
- Branch: `codex/draxos-mobile/battle-drama-v1-1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--battle-drama-v1-1`
- Base: `master` em `f437fac`

## Objetivo

Executar o pacote Battle Drama v1.1, uma iteracao client-only sobre Battle Presentation v1 para tornar a batalha Web/PC mais perceptivelmente diferente: menos leitura de mock/debug, mais foco visual no lance atual, combatentes mais presentes e palco mais dramatico.

## Escopo

- `BattleVisualMockup` e/ou `BattleStage2D`: arena, combatentes, barras, chamada de impacto e reducao de ruido visual.
- Presenter/shell de batalha se necessario: faixa compacta, copy e hierarquia.
- Docs/status/release ops: publicar como parte padrao quando o teste humano exigir build.
- Publicacao Internal Alpha apos validacao local.

## Fora De Escopo

- Sem backend, Supabase schema, migrations, simulador, recompensas, ranking, economia, armas, spells, realtime ou controles avancados de replay.
- Sem assets finais.
- Sem mobile browser ou iOS.

## Validacao Planejada

- `tools/smoke_responsive_layout.gd`
- GUT/client ou `validate_foundation.ps1 -Profile Client`
- `git diff --check`
- Export/package/upload/deploy Internal Alpha com root versionado novo
- Preview Web validado por HTTP contra asset root e tamanho de `index.pck`

## Handoff

Fechar em commit logico, merge para `master`, publicar e registrar URL final validada.
