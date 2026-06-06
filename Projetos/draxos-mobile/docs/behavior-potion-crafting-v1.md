# DraxosMobile - Behavior And Potion Crafting

- Status: `VIVO`
- Data: `2026-06-06`
- Track fonte: `implementation/tracks/track-16-behavior-crafting/`
- Papel atual: referencia viva para pocoes, crafting, estacoes e comportamento simples.

## Leitura Atual

Behavior And Potion Crafting registra o pacote tecnico que introduziu o primeiro fluxo server-authoritative de consumiveis e comportamento no DraxosMobile, e agora registra a ponte Bosque -> Fogueira -> Arena.

Bosque Fogueira Potion Crafting v1 muda a fronteira: a Base/Ossario continua criando `po_osso`, mas pocoes globais sao preparadas somente na `Fogueira Estavel I` do Bosque. O craft de estacao e server-authoritative porque cria consumiveis globais da conta; movimento, coleta, deposito, construcoes locais e cache do Bosque continuam offline-first.

Use este documento quando a tarefa tocar:

- Ossos inteiros, Po de Osso ou trituracao no Ossario/Base;
- Fogueira do Bosque como estacao de crafting;
- Pocao de Vida, Pocao de Foco, Pocao de Resguardo, inventario de consumiveis ou slot de pocao;
- comportamento simples de habilidade ou pocao;
- eventos de batalha `consumable_use`, `heal`, `potion_mana_restore` ou `potion_barrier_gain`;
- UI de Ossario/Base, Fogueira do Bosque ou Preparacao dentro da Arena PVE que exponha esses controles.

## O Que Existe

- Ossos usam escala inteira na base atual.
- `po_osso` existe como recurso inteiro criado ao triturar Ossos.
- A Base/Ossario expoe `Triturar Ossos`; ela nao cria mais `Pocao de Vida` diretamente.
- `Fogueira Estavel I` existe como estrutura duravel do Bosque e como `station_id = fogueira_estavel_1`.
- O craft de estacao exige checkpoint aceito do Bosque antes de consumir materiais do Bau e recursos globais.
- Materiais de estacao saem do `Bau` duravel do Bosque, nao da mochila/bolso.
- Receitas de estacao v1:
  - `craft_pocao_vida`: `folha x2`, `cogumelo x1` do Bau + `po_osso x25` da conta -> `pocao_vida x1`;
  - `craft_pocao_foco`: `fungo x1`, `inseto x1` do Bau + `po_osso x15` da conta -> `pocao_foco x1`;
  - `craft_pocao_resguardo`: `resina x1`, `pedra_pequena x1` do Bau + `po_osso x20` da conta -> `pocao_resguardo x1`.
- O save tem inventario de consumiveis e um slot de pocao.
- O slot 1 de pocao fica vazio por padrao e pode equipar/remover qualquer item listado em `POTIONS`.
- Habilidades equipadas podem ter comportamento simples salvo.
- A pocao equipada pode ter comportamento simples salvo.
- A batalha pode consumir no maximo uma pocao por slot por batalha.
- `pocao_vida` dispara cura em cinco ticks de `4%` da vida maxima, sem ultrapassar a vida maxima.
- `pocao_foco` restaura `25%` da mana maxima quando o comportamento default ve mana baixa.
- `pocao_resguardo` concede barreira de `12%` do HP maximo quando o comportamento default ve risco de vida.
- O log/replay aceita `consumable_use`, `heal`, `potion_mana_restore` e `potion_barrier_gain`.
- Preparacao dentro da Arena PVE expoe pocao equipada, equip/remover e preferencias simples de uso.

## Contratos Vivos

Os detalhes tecnicos vivem nos contratos abaixo:

- `docs/contracts/api-endpoints.md`:
  - `GET /crafting/state`
  - `POST /crafting/crush-bones`
  - `POST /crafting/craft`
  - `POST /crafting/station-craft`
  - `GET /build/state`
  - `POST /build/spell-behavior`
  - `POST /build/potion/equip`
  - `POST /build/potion-behavior`
- `docs/contracts/database-schema.md`:
  - `player_consumables`
  - `player_potion_slots`
  - `player_spell_behaviors`
  - `item_transactions`
  - `po_osso` como recurso inteiro
- `docs/contracts/content-definitions.md`:
  - `potions.json`
  - `crafting_recipes.json`
  - `pocao_vida`
  - `pocao_foco`
  - `pocao_resguardo`
  - `craft_pocao_vida`
  - `craft_pocao_foco`
  - `craft_pocao_resguardo`
- `docs/contracts/battle-event-log.md`:
  - `consumable_use`
  - `heal` com `item_id`, `effect_id` e `max_hp` quando a cura vem de consumivel;
  - eventos legiveis de mana/barreira para pocoes simples.

## Estado Publicado

Track 16 nasceu como pacote tecnico local em `2026-05-28`. Depois disso:

- Ossos Inteiros v1 aplicou a migration remota `202605280001_behavior_crafting.sql`, redeployou funcoes e publicou o subconjunto necessario para remover a leitura de `0.1 osso`.
- Battle Preparation Complete v1 publicou a Preparacao como editor real de loadout; a navegacao viva atual mantem os controles de pocao e comportamento simples dentro da Arena PVE.
- O hotfix de equip feedback manteve/reabriu a Preparacao apos acoes de equipar e comportamento, exibindo `Ultima escolha: ...` para que a acao nao pareca silenciosa.
- Progression Clarity v1 roda por cima desses dados sem alterar backend, schema, simulador, economia, tuning ou conteudo.
- Bosque Fogueira Potion Crafting v1 move o craft de pocoes para a `Fogueira Estavel I`, adiciona a ponte transacional `crafting/station-craft` e generaliza a Arena para `pocao_vida`, `pocao_foco` e `pocao_resguardo`.

## Guardrails

Permitido sem nova decisao de pacote:

- corrigir bug nos fluxos existentes de pocao/comportamento;
- ajustar documentacao e contratos para refletir o comportamento implementado;
- validar que UI, contratos e simulador continuam coerentes;
- melhorar copy sem mudar regra, economia ou tuning.

Bloqueado ate decisao explicita:

- novas pocoes ou novos consumiveis alem de `pocao_vida`, `pocao_foco` e `pocao_resguardo`;
- tuning de custo, cura, thresholds, poder, economia ou recompensa;
- comportamento por inimigo;
- prioridades avancadas de spells;
- thresholds customizados pelo jogador;
- bots usando pocoes por padrao;
- previsao de vitoria ou contra-escolha por oponente;
- migration estrutural de conta/save;
- expansao de crafting alem da Fogueira v1.

## Linguagem

Copy publica deve preferir termos como `Pocao`, `Preparacao`, `Fogueira`, `em uso`, `usar quando a vida estiver baixa` e `preferencia de uso`.

Evite mostrar `behavior`, `slot`, `endpoint`, `schema`, ids crus ou nomes de tabela na UI, exceto em telas tecnicas/labs.

## Validacao De Referencia

Consulte `implementation/current-status.md` para a validacao publicada mais recente.

Historicamente:

- Track 16 passou validacao local em `2026-05-28`.
- Ossos Inteiros v1 validou migration, funcoes, catalogos e release remoto em `2026-05-29`.
- Battle Preparation Complete v1 validou `POST /build/equip`, Preparacao e publicacao Internal Alpha em `2026-05-29`.
- O hotfix de equip feedback validou o fluxo Web real de `Equipar` e as acoes de comportamento em `2026-05-29`.
