# Codex - Temporary JogoDaCopa Focus

Status: Done

Branch: `codex/estudio/temporary-jogodacopa-focus`
Worktree: `D:\Estudio-worktrees\Estudio--codex--temporary-jogodacopa-focus`

## Objective

Pausar temporariamente todos os projetos ativos exceto `Projetos/JogoDaCopa/`, tornando JogoDaCopa o foco operacional unico do estudio por alguns dias.

## Delivered

- `AGENTS.md` atualizado com a regra temporaria de roteamento para `Projetos/JogoDaCopa/`.
- `08_Coordenacao_Agentes/Prioridades_Estudio.md` atualizado para marcar JogoDaCopa como foco unico temporario e pausar temporariamente Draxos Roguelike, DraxosMobile e FpsPlayground.
- `08_Coordenacao_Agentes/Estado_Atual.md` atualizado com o snapshot compacto da pausa temporaria.
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html` atualizado para refletir JogoDaCopa como foco atual no painel humano.
- `Projetos/README.md` atualizado com a regra de foco temporario e status dos projetos.
- `Projetos/JogoDaCopa/implementation/current-status.md` atualizado para registrar `TEMPORARY_SOLE_ACTIVE_PROJECT`.

## Validation

- `rg` para marcadores `FOCO_TEMPORARIO`, `PAUSADO_TEMPORARIO`, `TEMPORARY_SOLE` e `JogoDaCopa`: PASS.
- `git diff --check`: PASS.

## Handoff

Enquanto esta regra estiver ativa, agentes devem assumir `Projetos/JogoDaCopa/` para trabalho tecnico, design, documentacao, validacao e playtest quando o usuario nao explicitar outro projeto.

Draxos Roguelike Cardgame, DraxosMobile e FpsPlayground permanecem preservados para consulta historica ou retomada explicita do usuario.
