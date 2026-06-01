# Openworld Bosque

- Status: `INTERNAL_ALPHA`
- Mode id: `openworld`
- Slice id: `forest`
- Ruleset: `openworld_forest_ruleset_v0`, version `1`
- Local schema: `openworld_forest_local_v0`
- Descriptor: `data/definitions/modes/openworld/metadata.json`
- Placeholder: `data/definitions/modes/openworld/placeholder.json`
- Decision pack: `docs/minigames/openworld-decision-pack.md`
- Entry action: `open_mode_shell:openworld`
- Route: `mode_shell`
- Client module: `modes/openworld/`

`Openworld Bosque` e o primeiro slice do modo `Openworld`. Ele nasceu do prototipo `Rpgsuave Bosque`, mas V1 renomeia o modo de verdade: novos payloads, rotas, settings, docs e testes usam `openworld`.

## Visao

Openworld mira um mundo continuo no longo prazo. O Bosque nao e o teto conceitual; e o primeiro espaco jogavel para validar sensacao de movimento, coleta, bolso, bau, crafting local e uma ponte controlada de recompensa.

## Escopo Atual

- mobile portrait fullscreen;
- wrapper `Control` compativel com `ModeShellLauncher`, com runtime interno
  `SubViewportContainer`/`SubViewport` e mundo `Node2D`;
- camera `Camera2D` seguindo o personagem;
- controles PC/Web por WASD ou setas;
- joystick livre por toque/mouse em area vazia do viewport;
- HUD dentro do jogo;
- mochila funcional com `Bolso`, `Bau`, `Craft` e `Sessao`;
- detalhes tecnicos escondidos em `Sessao > Detalhes tecnicos`;
- colisao local em bau, arvores grandes, rochas grandes e paredes de borda;
- recursos pequenos como `Area2D` coletaveis e sem bloqueio de movimento;
- ordenacao visual por profundidade no mundo 2D, com HUD sempre acima;
- assets procedurais em Godot, sem raster externo novo;
- backend opcional em `integrated_alpha` por `/modes/session/start` e `/modes/session/complete`;
- Reward Bridge limitado, server-authoritative, idempotente e com ledger.

## Nao Escopo

- inimigos, combate, moral system ou gore;
- mundo aberto completo;
- escrita direta do cliente em Conta/Base;
- ranking, guilda, battle pass ou premium economy do Openworld;
- promessa publica de release.
- expansao do placeholder futuro sem pacote explicito.
- inimigos, combate, mapa novo, recompensa nova, economia nova ou endpoint novo
  neste pacote de QoL.

## Descriptor Scaffold

O descriptor declarativo de `Openworld` registra apenas o slice atual
`forest`, o ruleset existente e o Reward Bridge limitado ja publicado. O
placeholder em `data/definitions/modes/openworld/placeholder.json` e
explicitamente nao jogavel e reserva futuros slices sem abrir mapa, combate,
recompensa ou backend novo.

## Decision Pack V1

`docs/minigames/openworld-decision-pack.md` registra que Bosque continua o unico
slice aprovado. Expansao de mapa, combate, risco, progressao propria ampla,
Reward Bridge novo ou fronteira nova com Basebuilder precisa de pacote proprio.

## Componentes

- `OpenworldForestModel`: regras locais, inventario, coleta, bau, crafting e payload.
- `OpenworldForestScreen`: wrapper `Control`, sessao, HUD, sheet, joystick livre,
  input map, `SubViewport` e integracao opcional.
- `OpenworldForestWorld2D`: mundo `Node2D`, camera, player, objetos, bordas,
  recursos e estado visual.
- `OpenworldPlayerController`: `CharacterBody2D`, movimento por vetor combinado e
  colisao do jogador.
- `OpenworldWorldCatalog`: catalogo local do Bosque para bau, obstaculos grandes
  e recursos, sem contrato compartilhado ainda.
- `OpenworldWorldObject`: instancia visual procedural, `StaticBody2D` quando
  bloqueante e `Area2D` quando coletavel/interativo.
- `OpenworldForestWorldView`: legado Control preservado como referencia removivel,
  sem uso runtime no fluxo novo.
- `OpenworldVirtualJoystick`: input touch/mouse livre, analogico e resetavel.
- `OpenworldInventorySheet`: bolso, bau, craft, sessao e detalhes tecnicos.

## Controles E Mundo

- Movimento final combina teclado, joystick livre e vetor de debug dos smokes,
  limitado a magnitude `1.0`.
- A velocidade continua vindo de `OpenworldForestModel.current_speed()`, mantendo
  a penalidade de peso existente.
- Toque/click no HUD, botoes ou sheet nao ativa joystick.
- O bau tem colisao fisica central menor que a area de deposito.
- Arvores e rochas grandes bloqueiam o jogador; recursos pequenos continuam
  atravessaveis e coletam quando o jogador para dentro do raio.
- Bordas invisiveis impedem saida acidental do mapa `960x1400`, com borda visual
  discreta no fundo.

## Backend

- Start: `POST /modes/session/start`
- Complete: `POST /modes/session/complete`
- Abandon: `POST /modes/session/abandon`
- State: `GET /modes/state?mode_id=openworld`
- Ruleset ativo: `openworld_forest_ruleset_v0`

Payload de complete:

```json
{
  "request_id": "<uuid>",
  "result": {
    "session_id": "<uuid>",
    "session_seconds": 120,
    "deposited_items": {"madeira": 4, "ossos_preview": 1},
    "activity_score": 80,
    "ruleset_id": "openworld_forest_ruleset_v0",
    "ruleset_version": 1
  }
}
```

O servidor valida limites, bloqueia reward real em `progression_lab`, aplica deltas por RPC/ledger e retorna resposta idempotente.

## Validacao

- `tests/client/test_openworld_mode_dev.gd`
- `tools/smoke_openworld_forest.gd`
- `tools/smoke_modes_visual_layout.gd`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`
- `server/tests/openworld_reward_bridge_test.ts`
- `server/tests/modes_platform_schema_test.ts`
