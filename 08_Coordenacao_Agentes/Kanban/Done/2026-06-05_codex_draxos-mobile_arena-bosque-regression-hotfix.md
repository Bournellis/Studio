# DraxosMobile Doing: Arena/Bosque Regression Hotfix

## Metadata

- data: `2026-06-05`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/arena-bosque-regression-hotfix`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-bosque-regression-hotfix`

## Objetivo

Corrigir regressao reportada no pacote `ARENA_PVE_SEASON1_LOOP_V1_PUBLISHED_INTERNAL_ALPHA`:

- `Preparacao` sumiu da Arena antes de iniciar e entre lutas;
- Bosque nao deposita;
- Bosque nao persiste/salva o progresso de sessoes anteriores.

## Validacao Planejada

- GUT focado em Arena UI e Openworld/Bosque;
- `tools/validate.gd`;
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`;
- `git diff --check`.

## Entrega

- Restaurada `Preparacao` no topo da selecao da Arena PVE, no menu ativo e no fluxo de escolha de buff entre lutas.
- Restaurado feedback local de deposito/criacao no Bosque integrado enquanto o evento autoritativo aguarda ACK.
- Saida do Bosque integrado agora aguarda a fila de eventos pendentes antes de fechar a sessao.
- Eventos de deposito/criacao nao sao duplicados enquanto o Bosque ainda esta salvando.
- Hotfix validado localmente; publicacao remota nao foi executada nesta tarefa.

## Validacao Executada

- `git diff --check`: PASS.
- `tools/validate.gd`: PASS, 236 tests e 3710 asserts.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS.
