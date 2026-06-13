# Handoff: JogoDaCopa Track 06C - Menu Broadcast V1 bloqueada por Kenney Fonts

## Metadata

- from: `Codex`
- to: `Fabio`
- date: `2026-06-13`
- projeto: `JogoDaCopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO - FOCO TEMPORARIO UNICO`
- branch: `nao criada - bloqueio em pre-requisito`
- worktree: `nao criada - planejada D:\Estudio-worktrees\jogodacopa-track06c`

## Contexto

A Track 06C foi solicitada para transformar o menu principal em um match card de transmissao de Copa, em paralelo com a 06D e com area exclusiva em `modes/menu/*`, `tests/unit/test_menu_visual.gd`, `docs/asset-licenses.md` e `docs/screenshots/track-06c/`.

O prompt define como pre-requisito bloqueante a presenca das Kenney Fonts em `Projetos/JogoDaCopa/assets/fonts/kenney/`, com download manual por Fabio. O pre-requisito nao esta atendido; portanto a implementacao foi parada antes de criar branch/worktree.

## Current State

- `main` contem a Track 06B mergeada: `5f947f2f close jogodacopa track06b after merge` e `0935529d merge(jogodacopa): track06b esc menu v1`.
- `D:\Estudio\Projetos\JogoDaCopa\assets\fonts\kenney\` nao existe.
- Busca em `Projetos/JogoDaCopa/assets` encontrou Kenney em audio/personagens, mas nenhum arquivo de fonte (`.ttf`, `.otf`, `.woff`, `.woff2`) e nenhuma pasta `assets/fonts/kenney`.
- Nenhuma branch, worktree ou arquivo de implementacao da 06C foi criado.

## Changed Files

- `08_Coordenacao_Agentes/Handoffs/2026-06-13_codex_jogodacopa_track06c-menu-broadcast-v1.md`

## Decisions Made

- `stop_on_missing_kenney_fonts`: cumprir o bloqueio do prompt e aguardar Fabio baixar as fontes.
- `no_worktree_created`: evitar abrir `D:\Estudio-worktrees\jogodacopa-track06c` enquanto a track nao pode iniciar.

## Open Questions

- Fabio pode baixar Kenney Fonts (CC0) e colocar os arquivos em `Projetos/JogoDaCopa/assets/fonts/kenney/`?
- Preferencia confirmada para as candidatas do plano: Kenney Future / Future Narrow para titulo e numeros.

## Recommended Next Step

1. Fabio baixar Kenney Fonts manualmente.
2. Colocar as fontes em `Projetos/JogoDaCopa/assets/fonts/kenney/`.
3. Retomar a Track 06C com branch `codex/jogodacopa/track06c-menu-broadcast-v1` e worktree `D:\Estudio-worktrees\jogodacopa-track06c`.

## Validation

- `git status --short`: limpo antes do handoff.
- `git worktree list`: main em `D:\Estudio`; worktrees antigas 04F2 preservadas, nenhuma 06C.
- `git log --oneline main | Select-String -Pattern '06b'`: confirmou 06B em `main`.
- `Get-ChildItem -Force 'D:\Estudio\Projetos\JogoDaCopa\assets\fonts\kenney'`: falhou porque o caminho nao existe.
- `rg --files 'D:\Estudio\Projetos\JogoDaCopa\assets' | Select-String -Pattern 'kenney|font|\.ttf$|\.otf$|\.woff$|\.woff2$'`: sem fontes; apenas assets Kenney de audio/personagens.
