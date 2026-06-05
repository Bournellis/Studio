# DraxosMobile - Arena Duel Flow Hotfix

- Data: `2026-06-05`
- Agente: `codex`
- Branch: `codex/draxos-mobile/arena-duel-flow`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-duel-flow`
- Objetivo: corrigir dois problemas encontrados no playtest da Arena PVE publicada.

## Problemas

1. `Preparacao` nao aparece dentro do menu inicial do duelo.
2. Depois de receber o buff da vitoria, o proximo menu deveria mostrar `Resolver duelo`, mas volta a mostrar `Escolher buff`.

## Escopo Previsto

- Auditar presenter/lifecycle/action router da Arena.
- Corrigir o estado/CTA do menu inicial de duelo.
- Corrigir transicao apos selecao de buff para o proximo duelo resolvivel.
- Adicionar/ajustar testes client-side e, se necessario, contrato server-side focado.

## Validacao Prevista

- GUT focado em Arena/session shell.
- `smoke_runtime_config.gd` se fluxo tocar guards.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`.
- `git diff --check`.

## Resultado

- `Preparacao`/comportamento agora fica dentro do menu ativo do duelo, sem CTA solto `Ajustar comportamento`.
- Resposta de buff escolhido com `selected_buff` deixa de ser tratada como oferta pendente.
- Cache local antigo com oferta ja resolvida e buffs temporarios suficientes e destravado para estado `active`.
- Menu ativo pos-buff volta a exibir `Resolver duelo`.
- Hotfix validado localmente; publicacao remota nao executada.

## Validacao Executada

- `git diff --check`: PASS.
- GUT client suite: PASS, 232 testes / 3666 asserts.
- `tools/validate.gd`: PASS, 232 testes / 3666 asserts.
- `tools/smoke_responsive_layout.gd`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick -RequireClean:$false`: PASS.

## Handoff

- Done local. Nao publicar remotamente sem confirmacao explicita do usuario.
