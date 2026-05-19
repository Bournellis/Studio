# DraxosMobile - Reuse Map

- Ultima atualizacao: `2026-05-19`
- Estrategia: reuso conservador
- Regra central: usar padroes, ferramentas e infraestrutura; nao copiar gameplay incompativel

Este documento registra o que DraxosMobile pode aprender, adaptar ou vetar dos outros projetos Godot do estudio.

## Reutilizar Diretamente

| Origem | Uso em DraxosMobile | Status |
|---|---|---|
| `draxos-roguelike-cardgame/.gutconfig.json` e `rpg-turnos/.gutconfig.json` | Configuracao GUT com diretorio de testes, subdiretorios e exit controlado | Adotado em `.gutconfig.json` com `res://tests/client` |
| `draxos-roguelike-cardgame/tools/validate.gd` e `rpg-turnos/tools/validate.gd` | Padrao de validate que gera conteudo, valida contrato e roda GUT | Adotado em `tools/validate.gd` |
| `draxos-roguelike-cardgame/core/ui_tokens.gd` | Centralizacao de cores/tokens por autoload | Adaptado como `core/ui_tokens.gd` |
| `draxos-roguelike-cardgame/core/asset_ids.gd` | Manifesto de asset ids com fallback para arte ausente | Adaptado como `core/asset_ids.gd` |

## Adaptar Com Cuidado

| Origem | Referencia util | Aplicacao local |
|---|---|---|
| `rpg-isometrico/tools/content_generator.gd` | Definicoes multi-arquivo e resources gerados | `data/definitions/*.json` gera `data/generated/draxos_mobile_catalog.tres` |
| `draxos-roguelike-cardgame/data/content_library.gd` e `rpg-turnos/data/content_library.gd` | Autoload que garante catalogo carregado antes da UI | `data/content_library.gd` carrega o catalogo DraxosMobile |
| `rpg-isometrico` mode/session split | Separacao entre launch, session, loop e presenter | Referencia futura para account/session e battle replay |
| `rpg-turnos/core/game_session.gd` e `draxos-roguelike-cardgame/core/save_manager.gd` | Versionamento local e migracoes de cache | Usar apenas para cache local nao autoritativo em `T00-P06` |

## Proibido Copiar

| Origem | Nao reutilizar | Motivo |
|---|---|---|
| Draxos Roguelike Cardgame | BattleEngine, deck, mana, run map, loja de almas, recompensa de cartas | DraxosMobile e async autobattler server-authoritative |
| RPG Turnos | Board slots, cardgame de turnos, classes, NPC/world exploration | Contratos mecanicos nao pertencem ao mobile |
| RPG Isometrico | Action combat, loadout race/weapon/skills/potions, campanha PvE, controle isometrico | Outro genero e outra autoridade de runtime |
| Todos | Saves locais autoritativos | DraxosMobile persiste progressao e economia no servidor |

## Contratos Locais Adotados

- Cliente Godot pode centralizar tokens, asset ids e leitura de catalogo.
- Cliente Godot pode gerar resources a partir de JSON local para UI, fixtures e testes.
- Cliente Godot nao calcula vencedor, recompensa, recursos, XP, ranking, producao da base ou estado economico final.
- Fixtures `MVP_ONLY` existem para provar arquitetura, nao para resolver balanceamento.
- Qualquer regra importada precisa ser registrada neste documento e no contrato local afetado.
