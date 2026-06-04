# DraxosMobile - Behavior And Potion Crafting v1

- Status: `IMPLEMENTADO_COMO_BASE_TECNICA`
- Data: `2026-05-29`
- Track fonte: `implementation/tracks/track-16-behavior-crafting/`
- Papel atual: referencia viva para pocoes, crafting inicial e comportamento simples; nao e a etapa ativa de produto.

## Leitura Atual

Behavior And Potion Crafting v1 registra o pacote tecnico que introduziu o primeiro fluxo server-authoritative de consumiveis e comportamento no DraxosMobile.

O pacote existe no produto atual como base tecnica: parte dele foi promovida para a Internal Alpha por Ossos Inteiros v1 e Battle Preparation Complete v1. Isso nao promove tuning, economia, novas pocoes, novas spells ou comportamento avancado como foco atual.

Use este documento quando a tarefa tocar:

- Ossos inteiros, Po de Osso ou crafting inicial;
- Pocao de Vida, inventario de consumiveis ou slot de pocao;
- comportamento simples de habilidade ou pocao;
- eventos de batalha `consumable_use` ou cura de consumivel;
- UI de Ossario/Base ou Preparacao dentro da Arena PVE que exponha esses controles.

## O Que Existe

- Ossos usam escala inteira na base atual.
- `po_osso` existe como recurso inteiro criado ao triturar Ossos.
- `pocao_vida` existe como primeiro consumivel de batalha.
- `craft_pocao_vida` custa `50 po_osso` e cria `1 pocao_vida`.
- O save tem inventario de consumiveis e um slot de pocao.
- O slot 1 de pocao fica vazio por padrao e pode equipar/remover `pocao_vida`.
- Habilidades equipadas podem ter comportamento simples salvo.
- A pocao equipada pode ter comportamento simples salvo.
- A batalha pode consumir no maximo uma pocao por slot por batalha.
- `pocao_vida` dispara cura em cinco ticks de `4%` da vida maxima, sem ultrapassar a vida maxima.
- O log/replay aceita `consumable_use` e eventos `heal` de consumivel.
- Base/Ossario expoe triturar Ossos e crafting inicial.
- Preparacao dentro da Arena PVE expoe pocao equipada, equip/remover e preferencias simples de uso.

## Contratos Vivos

Os detalhes tecnicos vivem nos contratos abaixo:

- `docs/contracts/api-endpoints.md`:
  - `GET /crafting/state`
  - `POST /crafting/crush-bones`
  - `POST /crafting/craft`
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
  - `craft_pocao_vida`
- `docs/contracts/battle-event-log.md`:
  - `consumable_use`
  - `heal` com `item_id`, `effect_id` e `max_hp` quando a cura vem de consumivel.

## Estado Publicado

Track 16 nasceu como pacote tecnico local em `2026-05-28`. Depois disso:

- Ossos Inteiros v1 aplicou a migration remota `202605280001_behavior_crafting.sql`, redeployou funcoes e publicou o subconjunto necessario para remover a leitura de `0.1 osso`.
- Battle Preparation Complete v1 publicou a Preparacao como editor real de loadout; a navegacao viva atual mantem os controles de pocao e comportamento simples dentro da Arena PVE.
- O hotfix de equip feedback manteve/reabriu a Preparacao apos acoes de equipar e comportamento, exibindo `Ultima escolha: ...` para que a acao nao pareca silenciosa.
- Progression Clarity v1 roda por cima desses dados sem alterar backend, schema, simulador, economia, tuning ou conteudo.

## Guardrails

Permitido sem nova decisao de pacote:

- corrigir bug nos fluxos existentes de pocao/comportamento;
- ajustar documentacao e contratos para refletir o comportamento implementado;
- validar que UI, contratos e simulador continuam coerentes;
- melhorar copy sem mudar regra, economia ou tuning.

Bloqueado ate decisao explicita:

- novas pocoes ou novos consumiveis;
- tuning de custo, cura, thresholds, poder, economia ou recompensa;
- comportamento por inimigo;
- prioridades avancadas de spells;
- thresholds customizados pelo jogador;
- bots usando pocoes por padrao;
- previsao de vitoria ou contra-escolha por oponente;
- migration estrutural de conta/save;
- expansao de crafting alem do primeiro slice.

## Linguagem

Copy publica deve preferir termos como `Pocao`, `Preparacao`, `em uso`, `usar quando a vida estiver baixa` e `preferencia de uso`.

Evite mostrar `behavior`, `slot`, `endpoint`, `schema`, ids crus ou nomes de tabela na UI, exceto em telas tecnicas/labs.

## Validacao De Referencia

Consulte `implementation/current-status.md` para a validacao publicada mais recente.

Historicamente:

- Track 16 passou validacao local em `2026-05-28`.
- Ossos Inteiros v1 validou migration, funcoes, catalogos e release remoto em `2026-05-29`.
- Battle Preparation Complete v1 validou `POST /build/equip`, Preparacao e publicacao Internal Alpha em `2026-05-29`.
- O hotfix de equip feedback validou o fluxo Web real de `Equipar` e as acoes de comportamento em `2026-05-29`.
