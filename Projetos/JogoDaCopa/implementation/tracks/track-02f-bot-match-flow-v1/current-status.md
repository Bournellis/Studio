# Track 02F - Bot & Match Flow V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_02F_BOT_MATCH_FLOW_V1_COMPLETE`
- Branch: `codex/jogodacopa/track02-quality-upgrade-series-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track02-quality-upgrade-series-v1`

## Goal

Melhorar a partida contra bot com predicao simples, defesa mais legivel, boost de bot, dificuldade em tres niveis e kickoff alternado, sem mudar contratos de gol/bola/chute.

## Delivered

- Bot passa a mirar a posicao futura da bola (`linear_velocity * prediction_time`) para chase/attack/defense.
- Defesa do bot usa alvo na linha entre o proprio gol e a bola prevista, com clamp dentro do campo.
- Bot ganhou boost deterministico em chase/attack/defense quando ha distancia suficiente.
- Bot ganhou presets `easy`, `normal` e `hard` alterando velocidade, forca, erro de mira, cooldown, predicao e boost.
- `FootballRoot` expoe e aplica dificuldade do bot via debug/API interna.
- Kickoff alterna entre `player` e `bot` apos reset de gol; bola e spawns mudam para favorecer o dono da saida.
- HUD mostra dono da saida e dificuldade atual do bot na linha de fluxo.
- Testes cobrem dificuldade hard, predicao, boost e kickoff alternado apos gol.

## Validation

- `tools/validate.gd`: PASS, 28 tests, 279 asserts.
- Known noise: GUT UID/text-path warnings after fresh worktree import, accepted by `docs/validation.md`.

## Out Of Scope

- Match timer/overtime completo.
- Persistencia ou seletor de dificuldade no menu.
- Product identity/export/build smoke test (Track 02G).
