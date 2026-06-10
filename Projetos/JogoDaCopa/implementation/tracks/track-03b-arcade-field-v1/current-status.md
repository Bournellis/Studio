# Track 03B - Arcade Field V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_03B_ARCADE_FIELD_V1_COMPLETE`
- Branch: `codex/jogodacopa/track03-arcade-series-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03-arcade-series-v1`

## Goal

Adicionar campo de arena arcade com boost pads, jump pads e rampas simples, mantendo bot com coleta equivalente e sem impulsos novos na bola fora de `FootballBall3D.kick()`.

## Delivered

- `FootballFieldBuilder` agora gera 6 boost pads pequenos, 2 grandes, 2 jump pads e rampas de parede/canto sem assets externos.
- `FootballRoot` coleta e reseta os nós de campo, aplica respawn de boost pad em 4s e atualiza jump pads durante a física.
- Boost pad pequeno adiciona `25` stamina; boost pad grande faz refill completo.
- Bot recebe a lista dos pads ativos, desvia para pads próximos da rota atual e registra coleta pelos mesmos eventos de campo.
- Jump pads aplicam impulso vertical em player/bot e não interagem com a bola.
- Rampas usam caixas estáticas procedurais com bounce reduzido.
- Testes cobrem presença dos nós de arena, respawn de pads, refill pequeno/grande, coleta de bot por rota e jump pad sem chute/impulso na bola.

## Validation

- `tools/validate.gd`: PASS, 39 tests, 358 asserts.
- Performance sample Windows/Forward+: average `1097.6fps`, min warmed instant `607.2fps`, `0/360` frames below 60.
- Known noise: GUT UID/text-path warnings during validation.

## Out Of Scope

- Timer/golden goal/announcer flavor.
- Toon look experiment.
- Power-ups classicos de campo.
- Assets externos, audio real ou authored scene edits.

## Next Step

Implementar `Track 03D - Arcade Match Flavor V1`.
