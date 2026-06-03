# Openworld Bosque

- Status: `ACTIVE_INTERNAL_ALPHA`
- Mode id: `openworld`
- Slice id: `forest`
- Ruleset: `openworld_forest_ruleset_v1`, version `1`
- Snapshot schema: `openworld_forest_snapshot_v1`
- Shared definition: `data/definitions/openworld/forest_ruleset_v1.json`
- Descriptor: `data/definitions/modes/openworld/metadata.json`
- Placeholder: `data/definitions/modes/openworld/placeholder.json`
- Decision pack: `docs/minigames/openworld-decision-pack.md`
- Entry action: `open_mode_shell:openworld`
- Route: `mode_shell`
- Client module: `modes/openworld/`

`Openworld Bosque` e o primeiro slice do modo `Openworld`. Ele nasceu do prototipo `Rpgsuave Bosque`, mas V1 renomeia o modo de verdade: novos payloads, rotas, settings, docs e testes usam `openworld`.

Oficial, neste documento, significa `mode_registry.status=active` dentro do canal `internal_alpha`. Nao significa release publico, troca de manifest ou publicacao remota.

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
- detalhes operacionais escondidos em `Sessao > Detalhes da operacao`;
- colisao local em bau, arvores grandes, rochas grandes e paredes de borda;
- recursos pequenos como `Area2D` coletaveis e sem bloqueio de movimento;
- ordenacao visual por profundidade no mundo 2D, com HUD sempre acima;
- assets procedurais em Godot, sem raster externo novo;
- backend opcional em `integrated_alpha` por `/modes/state`, `/modes/session/start`, `/modes/session/event`, `/modes/session/complete` e `/modes/session/abandon`;
- snapshot remoto retomavel por ate 2 horas;
- heartbeat de movimento/tempo a cada 15 segundos e eventos imediatos para acoes relevantes;
- ACK de evento com patch autoritativo seletivo, sem rollback visual de posicao
  ou coleta em andamento durante gameplay ativo;
- Reward Bridge limitado, server-authoritative, idempotente e com ledger.

## Nao Escopo

- inimigos, combate, moral system ou gore;
- mundo aberto completo;
- escrita direta do cliente em Conta/Base;
- ranking, guilda, battle pass ou premium economy do Openworld;
- promessa publica de release.
- expansao do placeholder futuro sem pacote explicito.
- inimigos, combate, mapa novo, recompensa nova, economia nova ou mundo continuo
  neste hardening.

## Descriptor Scaffold

O descriptor declarativo de `Openworld` registra apenas o slice atual
`forest`, o ruleset v1 e o Reward Bridge limitado. O
placeholder em `data/definitions/modes/openworld/placeholder.json` e
explicitamente nao jogavel e reserva futuros slices sem abrir mapa, combate,
recompensa ou backend novo.

`openworld_forest_ruleset_v0` permanece documentado como historico de prototipo local. O ruleset ativo do Bosque oficial tecnico e `openworld_forest_ruleset_v1`.

## Decision Pack V1

`docs/minigames/openworld-decision-pack.md` registra que Bosque continua o unico
slice aprovado. Expansao de mapa, combate, risco, progressao propria ampla,
Reward Bridge novo ou fronteira nova com Basebuilder precisa de pacote proprio.

## Componentes

- `OpenworldForestRuleset`: loader da definition versionada `forest_ruleset_v1.json`.
- `OpenworldForestModel`: regras locais/preview, inventario, coleta, bau, crafting, snapshot e payload.
- `OpenworldForestScreen`: wrapper `Control`, sessao, HUD, sheet, joystick livre,
  foco/input global, fallback Web para WASD/setas, `SubViewport` e integracao
  opcional com snapshot/revision.
- `OpenworldForestWorld2D`: mundo `Node2D`, camera, player, objetos, bordas,
  blockers fisicos dedicados, recursos e estado visual.
- `OpenworldPlayerController`: `CharacterBody2D`, movimento por vetor combinado e
  colisao do jogador.
- `OpenworldWorldCatalog`: catalogo local do Bosque para bau, obstaculos grandes
  e recursos derivados da definition versionada.
- `OpenworldWorldObject`: instancia visual procedural y-sorted e `Area2D` quando
  coletavel/interativo; colisao bloqueante fica no corpo fisico dedicado do
  mundo para nao depender do node visual.
- `OpenworldForestWorldView`: legado Control preservado como referencia removivel,
  sem uso runtime no fluxo novo.
- `OpenworldVirtualJoystick`: input touch/mouse livre, analogico e resetavel.
- `OpenworldInventorySheet`: bolso, bau, craft, sessao e detalhes tecnicos.

## Controles E Mundo

- Movimento final combina teclado, joystick livre e vetor de debug dos smokes,
  limitado a magnitude `1.0`.
- WASD/setas usam `InputMap` e fallback manual por `keycode`/`physical_keycode`
  para Web/PC quando o canvas nao entrega action strength de forma confiavel.
- A velocidade continua vindo de `OpenworldForestModel.current_speed()`, mantendo
  a penalidade de peso existente.
- Joystick fica invisivel quando inativo; toque/click/drag em area livre cria o
  joystick no ponto usado, arrasto atualiza vetor e release zera/oculta.
- Toque/click no HUD, botoes ou sheet nao ativa joystick.
- O bau tem colisao fisica central menor que a area de deposito.
- Arvores e rochas grandes bloqueiam o jogador; recursos pequenos continuam
  atravessaveis e coletam quando o jogador para dentro do raio.
- Bordas invisiveis impedem saida acidental do mapa `960x1400`, com borda visual
  discreta no fundo.

## Backend

- State/resume: `GET /modes/state?mode_id=openworld`
- Start: `POST /modes/session/start`
- Event: `POST /modes/session/event`
- Complete: `POST /modes/session/complete`
- Abandon: `POST /modes/session/abandon`
- Ruleset ativo: `openworld_forest_ruleset_v1`

`GET /modes/state?mode_id=openworld` retorna `active_session` quando existe sessao `started` nao expirada, incluindo `snapshot_payload`, `snapshot_revision`, `expires_at` e `last_event_at`.

`POST /modes/session/event` retorna `type=mode_event_ack` dentro do envelope
comum de modos. Esse ACK confirma o evento e a revisao, mas nao deve ser tratado
como snapshot completo de retomada pelo client. Durante gameplay ativo:

- `snapshot_patch` e a unica parte aplicada ao inventario/estado economico;
- `player_position` continua client-authoritative e nao entra no patch;
- `active_collection` continua client-authoritative ate sair, retomar ou
  resync stale explicito;
- `collect_start` pode confirmar revisao sem zerar barra de coleta;
- `collect_complete` confirma bolso e `collected_nodes`;
- `deposit_all` confirma bolso/bau;
- `craft` confirma bau/upgrades;
- stale revision bloqueia `Completar`, mostra mensagem discreta e aciona resync
  por `/modes/state`.

Eventos aceitos:

- `move_heartbeat`
- `collect_start`
- `collect_cancel`
- `collect_complete`
- `deposit_all`
- `craft`
- `complete_requested`
- `abandon_requested`

Payload de evento:

```json
{
  "request_id": "<uuid>",
  "session_id": "<uuid>",
  "mode_id": "openworld",
  "slice_id": "forest",
  "event_type": "collect_complete",
  "expected_revision": 3,
  "event_payload": {
    "node_id": "node_galho_01",
    "item_id": "galho",
    "position": {"x": 330, "y": 420},
    "session_seconds": 42
  }
}
```

Resposta de evento:

```json
{
  "ok": true,
  "type": "mode_event_ack",
  "mode_id": "openworld",
  "slice_id": "forest",
  "session_id": "<uuid>",
  "event_type": "collect_complete",
  "request_id": "<uuid>",
  "expected_revision": 3,
  "revision_after": 4,
  "applied": true,
  "resync_required": false,
  "snapshot_patch": {
    "pocket": {"galho": 1},
    "collected_nodes": {"node_galho_01": true},
    "last_message": "+1 Galho no bolso."
  },
  "authoritative_fields": ["collected_nodes", "last_message", "pocket"],
  "visual_authority": {
    "player_position": "client_during_active_play",
    "active_collection": "client_until_resume_or_resync"
  }
}
```

Payload de complete:

```json
{
  "request_id": "<uuid>",
  "session_id": "<uuid>",
  "mode_id": "openworld",
  "slice_id": "forest",
  "ruleset_id": "openworld_forest_ruleset_v1",
  "ruleset_version": 1,
  "expected_revision": 9
}
```

O servidor valida limites, rejeita stale write, bloqueia reward real em `progression_lab`, calcula recompensa exclusivamente de `snapshot_payload`, aplica deltas por RPC/ledger e retorna resposta idempotente. `deposited_items` enviado pelo cliente nao e autoridade de recompensa.

Fallback offline/sem auth entra em preview sem recompensa. A tela pode continuar jogavel localmente, mas `Completar` fica bloqueado enquanto a sessao integrada estiver sem sync.

## Validacao

- `tests/client/test_openworld_mode_dev.gd`
- `tools/smoke_openworld_forest.gd`
- `tools/smoke_modes_visual_layout.gd`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`
- `server/tests/openworld_reward_bridge_test.ts`
- `server/tests/openworld_ruleset_definition_test.ts`
- `server/tests/modes_platform_schema_test.ts`
