# Estudio Lifecycle Cleanup Audit

- Data: `2026-06-29`
- Tipo: auditoria read-only registrada como documento.
- Escopo: branches/worktrees locais observados; nenhuma limpeza aplicada.

## Resultado resumido

O workspace principal estava limpo no inicio da wave e a branch principal e `main`.

Auditoria Git observada nesta wave:

- Branches locais totais: `55`
- Branches ja listadas como merged em `main`: `53`
- Worktrees observadas alem do workspace principal: `6` incluindo a worktree Hermes desta wave.
- Branch nao merged observada alem da branch Hermes atual: `codex/fpsplayground/jump-pad-force-hotfix-v1` com `3` commits desde merge-base `231a6beda309`.

## Worktrees observadas

| Branch | Head curto | Worktree |
|---|---|---|
| `main` | `e8a3f49` | `D:/Estudio` |
| `codex/draxos-roguelike-cardgame/content-wave01-design-lab` | `3e43697` | `D:/Estudio-worktrees/draxos-roguelike-cardgame--codex--content-wave01-design-lab` |
| `codex/draxos-roguelike-cardgame/design-lab-calibration-v1` | `0e9c7db` | `D:/Estudio-worktrees/draxos-roguelike-cardgame--codex--design-lab-calibration-v1` |
| `codex/draxos-roguelike-cardgame/design-lab-pilot-content-v1` | `9871e6b` | `D:/Estudio-worktrees/draxos-roguelike-cardgame--codex--design-lab-pilot-content-v1` |
| `codex/fpsplayground/track14i-human-approved-v1` | `0f98a2a` | `D:/Estudio-worktrees/FpsPlayground--codex--track14i-human-approved-v1` |
| `codex/jogodacopa/track10d-human-retest-approved-v1` | `cdade38` | `D:/Estudio-worktrees/JogoDaCopa--codex--track10d-human-retest-approved-v1` |
| `hermes/estudio-docs-dashboard-wave` | `4e3b6ab` | `D:/Estudio-worktrees/estudio--hermes--docs-dashboard-wave` |

## Classificacao preliminar

### Provavelmente candidatos a limpeza apos aprovacao

Branches/worktrees que aparecem como merged em `main` e parecem representar tracks ja documentadas em Kanban Done/Estado:

- `codex/draxos-roguelike-cardgame/content-wave01-design-lab`
- `codex/draxos-roguelike-cardgame/design-lab-calibration-v1`
- `codex/draxos-roguelike-cardgame/design-lab-pilot-content-v1`
- `codex/fpsplayground/track14i-human-approved-v1`
- `codex/jogodacopa/track10d-human-retest-approved-v1`

Nao deletar automaticamente: confirmar se Fabio quer preservar alguma dessas worktrees como area de consulta/local diff antes de limpeza.

### Precisa revisao manual/extracao

- `codex/fpsplayground/jump-pad-force-hotfix-v1`
  - Nao apareceu como merged em `main`.
  - Tem `3` commits desde merge-base `231a6beda309`.
  - Deve ser comparada com:
    - `git log --oneline $(git merge-base main codex/fpsplayground/jump-pad-force-hotfix-v1)..codex/fpsplayground/jump-pad-force-hotfix-v1`
    - `git diff --name-status $(git merge-base main codex/fpsplayground/jump-pad-force-hotfix-v1)..codex/fpsplayground/jump-pad-force-hotfix-v1`
  - Classificar depois como `preserve`, `extract_later` ou `safe_to_delete_after_fabio_approval`.

### Branch Hermes desta wave

- `hermes/estudio-docs-dashboard-wave`
  - Temporaria.
  - Deve ser removida depois do fast-forward merge e verificacao final.

## Proxima acao recomendada

Fazer uma rodada futura de cleanup lifecycle, separada desta wave:

1. Reexecutar `git status --short`, `git worktree list --porcelain` e `git branch --merged main`.
2. Para cada branch merged com worktree aberta, confirmar se Fabio quer preservar consulta local.
3. Para branches nao merged, comparar contra merge-base antes de qualquer decisao.
4. Aplicar limpeza apenas depois de aprovacao explicita:
   - remover worktree;
   - deletar branch local merged;
   - atualizar qualquer card/handoff que ainda diga worktree/branch aberta.
5. Rodar `git worktree list --porcelain` e `git status --short` no final.

## Fora de escopo desta wave

- Deletar branches.
- Remover worktrees de Codex.
- Mover cards Kanban.
- Resolver a branch `jump-pad-force-hotfix-v1`.
