# Track 14H - Bot Long Jump Pad Hotfix V1

- Status: `MERGED_LOCAL`
- Data: `2026-06-20`
- Branch: `codex/fpsplayground/bot-long-jump-pad-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--bot-long-jump-pad-hotfix-v1`

## Objetivo

Restaurar a confiabilidade do bot no long jump pad de `Relay Foundry V1` sem alterar a força aprovada dos jump pads para o player.

## Diagnostico

A regressao veio da troca do calculo route-aware antigo por um contrato fixo de jump pad. O contrato fixo preservou o feel do player, mas removeu do bot a compensacao por posicao real de trigger e distancia ate a plataforma. A cobertura tambem ficou fraca: validava trigger e altura, mas nao pouso na primeira tentativa.

## Implementacao

- `D:\Estudio-worktrees\FpsPlayground--codex--bot-long-jump-pad-hotfix-v1\Projetos\FpsPlayground\modes\arena\arena_pickup_jump_pad_rules.gd`: adiciona helper route-aware puro para calcular velocidade horizontal por distancia, altura, gravidade e margem.
- `D:\Estudio-worktrees\FpsPlayground--codex--bot-long-jump-pad-hotfix-v1\Projetos\FpsPlayground\modes\arena\arena_root.gd`: usa o calculo route-aware somente para `actor_id == &"bot"`; player continua com `5.8` horizontal e `8.4` vertical.
- `D:\Estudio-worktrees\FpsPlayground--codex--bot-long-jump-pad-hotfix-v1\Projetos\FpsPlayground\tests\unit\test_bootstrap.gd`: restaura cobertura de launch por rota e pouso do bot no primeiro uso.

## Validacao

- `git diff --check`: PASS
- `tools/validate.gd -- --profile=quick`: PASS, GUT `67/67`, `599 asserts`
- `tools/validate.gd`: PASS, GUT `67/67`, `599 asserts`
- `tools/check_doc_drift.ps1`: PASS

## Proximo Passo

Executar teste humano no segundo mapa para confirmar o feel visual do bot no long jump pad. Depois disso, seguir para `Multi-Arena Balance Baseline V1`.

## Handoff

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
