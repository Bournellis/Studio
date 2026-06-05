# Done - DraxosMobile Remove Bosque Floor Circles

## Metadata

- data: `2026-06-05`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/remove-floor-circles`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--remove-floor-circles`
- base: `master` @ `7652e32`
- status: `COMPLETED_LOCAL`

## Objetivo

Remover do Bosque os marcadores decorativos de chao que aparecem como circulos duplos com seis pontos, mantendo as demais melhorias de feedback, colisao, fogueira e landmarks nao circulares.

## Entrega

- Removida a chamada dos marcadores decorativos de chao do Bosque que formavam circulos duplos com seis pontos.
- Removida a funcao dedicada `_draw_ground_marker`.
- Adicionado guard no smoke do Bosque para evitar retorno acidental desses marcadores.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Validacao

- PASS: `git diff --check`
- PASS: `smoke_openworld_forest.gd`
- PASS: `smoke_modes_visual_layout.gd`

## Handoff

Commit local preparado; publicacao remota nao executada neste ajuste estreito.
