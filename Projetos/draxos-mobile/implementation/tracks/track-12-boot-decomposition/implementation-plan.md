# Track 12 - Implementation Plan

## Sequencia Executada

1. Preparacao e seguranca: worktree/branch dedicadas, Doing registrado, baseline Godot verde.
2. Contrato de actions: ids, prefixos, payload, update gate e replay gate extraidos para `AppShellActionContract`.
3. Conta/sessao/update: guest, email auth, refresh/reset, save selection/creation e manifest/runtime checks extraidos para `AccountSessionFlow`.
4. Superficies online: Base, Social, Competition e Shop extraidos para `SurfaceActionFlow`.
5. Batalha/replay: request, latest/history, replay, skip, summary e logs extraidos para `BattleLifecycleFlow`.
6. Helpers de superficie: helpers visuais compartilhados extraidos para `SurfaceUiHelpers` e fronteira registrada em `surfaces/README.md`.
7. Guardas: testes estruturais para impedir retorno do monolito.

## Regras Mantidas

- Nada de alteracao perceptivel de UX, rotas, textos ou telas.
- Nada de simulacao de combate no cliente.
- Nada de mutacao local de recursos/recompensas/matchmaking/compras fora das respostas do servidor.
- Nada de edicao manual de cenas `.tscn`.
- Commits separados por etapa logica.
