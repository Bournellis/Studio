# DraxosMobile - PVE Arena v1

- Status: `VIVO`
- Data: `2026-05-31`
- Decisao-base: `PVE_ARENA_INITIAL_DIRECTION_APPROVED`
- Escopo: contrato de produto, conteudo e regras para o primeiro pacote Arena PVE data-driven.

## Papel Do Documento

`docs/pve-arena-initial-direction.md` define a direcao de produto. Este documento transforma essa direcao em contrato inicial para docs, backend, client, Battle Lab, Progression Lab e ruleset.

Esta entrega nao implementa backend, cliente Godot, migration ou tuning final. Ela fecha o chao data-driven necessario para os proximos agentes conectarem Arena PVE sem reabrir a decisao de produto.

## Decisoes Fechadas Para v1

| Tema | Decisao v1 |
|---|---|
| Modo | `PVE_ARENA_V1` |
| Core inicial | Arena PVE antes de PVP |
| Tutorial | 1 duelo guiado |
| Primeiras arenas reais | 3 duelos |
| Limite maximo inicial | 6 duelos |
| Arena de 4 duelos | Desbloqueia depois das primeiras arenas curtas provarem dificuldade 2 |
| Arena de 6 duelos | Cap inicial; fica como conteudo contratado para dificuldade 4+ |
| HP entre duelos | Reseta para 100% antes de cada duelo |
| Loadout | Travado ao iniciar tentativa |
| Entre duelos | Escolher 1 de 3 buffs temporarios e ajustar comportamento simples |
| Troca de loadout entre duelos | Bloqueada |
| Cooldown de combate | 0 segundos |
| Controle economico | Recompensa por primeira conclusao, conclusao, recorde, bonus diario/semanal, repeticao reduzida e caps |
| PVP | Posterior; fora do pacote v1 |

## Data Sources

Novos arquivos autorados em `data/definitions/`:

| Arquivo | Collection | Papel |
|---|---|---|
| `pve_arenas.json` | `pve_arenas` | Lista de arenas, tamanho, unlock, sequencia de inimigos, reward profile e regras de tentativa |
| `pve_enemies.json` | `pve_enemies` | Inimigos PVE por arquetipo, poder alvo, papel didatico e build/base de simulacao |
| `arena_buffs.json` | `arena_buffs` | Buffs temporarios de stat oferecidos entre duelos |
| `arena_rewards.json` | `arena_rewards` | Perfis de recompensa e limites iniciais da Arena PVE |

Esses arquivos entram no `foundation_ruleset_v0` como fonte autorada. Eles nao entram automaticamente no catalogo Godot atual ate o client/package decidir consumir essas collections.

## Arenas v1

| Arena | Duels | Dificuldade | Release inicial | Papel |
|---|---:|---:|---|---|
| `arena_tutorial_cinzas` | 1 | 0 | Sim | Ensinar pedido de duelo, replay, recompensa e retorno ao Refugio |
| `arena_cinzas_curta` | 3 | 1 | Sim | Primeira arena real; apresenta buff entre duelos |
| `arena_veu_curta` | 4 | 2 | Sim | Testa controle mental, barreira e pressao de DoT |
| `arena_ossos_media` | 5 | 3 | Contratada/lockada | Primeiro aumento longo de comprimento |
| `arena_abismo_longa` | 6 | 4 | Contratada/lockada | Cap inicial de comprimento |

Regra de unlock:

- tutorial sempre disponivel;
- primeira arena curta abre apos tutorial;
- segunda arena curta abre apos primeira clear da arena curta;
- arena de 4 duelos abre apos clear de dificuldade 2;
- arena de 6 duelos abre apos clear de dificuldade 3 e continua sendo o cap inicial.

## Tentativa De Arena

Uma tentativa possui:

- `attempt_id`;
- `game_save_id`;
- `arena_id`;
- `difficulty_tier`;
- `ruleset` metadata;
- loadout travado em snapshot;
- comportamento inicial e comportamento atualizado entre duelos;
- `duel_index` atual;
- inimigo atual;
- buffs acumulados;
- ofertas de buff geradas pelo servidor;
- estado `active`, `completed`, `failed`, `abandoned` ou `claimed`;
- payload de recompensa calculado pelo servidor.

Invariantes:

- nao existe mais de uma tentativa ativa por save;
- iniciar tentativa exige `request_id` e `request_hash`;
- batalha de arena sempre carrega `attempt_id`, `arena_id`, `duel_index` e `enemy_id`;
- derrota encerra a tentativa v1;
- abandono nao concede recompensa de conclusao;
- repeticao com mesmo `request_id/request_hash` retorna o mesmo attempt ou payload.

## Inimigos PVE

O valor inicial esta em arquetipos mecanicos, nao em assets unicos.

| Enemy ID | Arquetipo | Papel didatico | Build base |
|---|---|---|---|
| `pve_aprendiz_cinzas` | `starter_instrument` | Duelo basico sem spell complexa | `bot_starter_instrument_01` |
| `pve_guardiao_barreira` | `defensive_occultist` | Mostrar Guarda/barreira e luta mais lenta | `bot_effect_trainer_01` |
| `pve_sussurrador_veu` | `mental_controller` | Ensinar controle mental inicial | `bot_mental_controller_01` |
| `pve_misturador_elemental` | `elemental_mixer` | Testar duas fontes elementais | `bot_elemental_mixer_01` |
| `pve_pressao_veneno` | `dot_pressure` | Testar pressao de dano por tempo | `bot_effect_trainer_01` |
| `pve_condutor_familiar` | `familiar_handler` | Introduzir Familiar como pressao adicional | `bot_familiar_handler_01` |
| `pve_invocador_ossario` | `summoner` | Validar summons em arena | `bot_summoner_01` |
| `pve_defensor_abissal` | `defensive_occultist` | Check defensivo de arena media/longa | `bot_familiar_handler_01` |
| `pve_finalizador_abissal` | `funeral_burst` | Finalizador do cap inicial | `bot_summoner_01` |

Inimigos PVE:

- nao sao jogadores;
- nao aparecem em leaderboard PVP;
- nao recebem recompensa;
- podem reutilizar bot builds como base tecnica;
- devem ter `enemy_id`, `archetype`, `target_power`, `target_level`, `teaching_goal` e `source_bot_build_id`.

## Buffs Temporarios

Buffs v1 sao apenas stats. Cada escolha e leve; o valor vem do acumulo ao longo da tentativa.

Regras:

- 1 escolha entre 3 opcoes apos cada vitoria, exceto quando nao houver proximo duelo;
- servidor sorteia ou seleciona ofertas a partir de `arena_buffs.json`;
- jogador escolhe exatamente 1;
- buff entra no proximo duelo e dura ate a tentativa acabar;
- buffs nao entram em save permanente, inventario, ranking ou loja;
- stacking e aditivo dentro da tentativa.

Familias v1:

- Vida maxima;
- Potencia Ritual;
- Guarda;
- Mana maxima;
- Regen de mana;
- Celeridade Ritual;
- Vontade;
- Controle Ritual.

## Recompensas

Arena PVE nao usa cooldown. A economia e controlada por perfil de recompensa:

- `first_clear_multiplier`;
- `completion_multiplier`;
- `record_bonus`;
- `repeat_multiplier`;
- `daily_bonus_key`;
- `weekly_cap_key`;
- `season_cap_key`;
- `resources`;
- `xp`;
- ledger source `arena_pve_v1`.

Valores de `arena_rewards.json` sao `CALIBRAVEL_ALPHA`. Eles existem para destravar implementacao e labs, nao para declarar economia final.

## API Contratada

Status dos endpoints neste pacote: `contratado`, nao implementado nesta branch.

| Metodo | Endpoint logico | Escopo | Idempotencia | Papel |
|---|---|---|---|---|
| GET | `/arena/pve/state` | `save-scoped` | Nao | Ler arenas, unlocks, tentativa ativa e recordes |
| POST | `/arena/pve/start` | `save-scoped` | `request_id/request_hash` | Criar tentativa, travar loadout e gerar primeiro inimigo |
| POST | `/arena/pve/duel/request` | `save-scoped` | `request_id/request_hash` | Resolver proximo duelo da tentativa via simulador server-authoritative |
| POST | `/arena/pve/buff/select` | `save-scoped` | `request_id/request_hash` | Escolher 1 buff de uma oferta apos vitoria |
| POST | `/arena/pve/claim` | `save-scoped` | `request_id/request_hash` | Aplicar recompensa de conclusao/recorde/primeira clear |
| POST | `/arena/pve/abandon` | `save-scoped` | `request_id/request_hash` | Encerrar tentativa sem recompensa de conclusao |

Comportamento simples entre duelos deve reutilizar `build/spell-behavior` e `build/potion-behavior` enquanto nao houver comportamento de arena proprio.

## Battle Log

Cada duelo da Arena PVE continua usando `battle_log_v1`. O replay deve receber metadata:

- `mode: "PVE_ARENA_V1"`;
- `attempt_id`;
- `arena_id`;
- `duel_index`;
- `duel_count`;
- `enemy_id`;
- `temporary_buffs`;
- `locked_loadout_hash`;
- `hp_reset: true`;
- `ruleset`.

O log de batalha anima apenas o duelo. Buff offer, escolha de buff, tentativa completa e claim pertencem ao estado da arena e aos endpoints de arena.

## Labs

Battle Lab precisa modelar sequencias de arena, nao duelos isolados:

- sequencia de inimigos por arena;
- HP resetado a cada duelo;
- loadout travado;
- buffs acumulados entre duelos;
- comportamento alteravel antes do proximo inimigo;
- resultado por duelo e por tentativa.

Progression Lab precisa modelar:

- primeira clear;
- repeat reward reduzido;
- bonus diario/semanal;
- recorde de maior duelo;
- efeito de upgrades/base/build sobre a chance de clear;
- desbloqueio de arena 4 e 5.

## Fora De Escopo v1

- Campanha PVE tradicional;
- cooldown de combate;
- sobrevivencia de HP entre duelos;
- troca de loadout entre duelos;
- buffs complexos de roguelike;
- inimigos com comportamento customizado por script;
- novas armas, spells, pocoes ou economia final;
- PVP, ranking PVP, leaderboard publica de bots;
- client Godot ou backend nesta branch documental/data-driven.

## Aceite Para Proximos Agentes

Um pacote backend/client que consome este contrato deve provar:

- endpoints novos usam `account_profiles/game_saves`, ruleset metadata e idempotencia v1;
- nenhum endpoint concede recompensa sem ledger `arena_pve_v1`;
- `battle_log_v1` preserva replay de duelo sem rerodar simulador;
- tentativa ativa sobrevive a retry;
- tutorial de 1 duelo e arena de 3 duelos funcionam sem cooldown;
- loadout fica travado durante tentativa;
- comportamento simples pode mudar entre duelos sem trocar loadout;
- rewards de repeticao sao reduzidos ou limitados;
- labs conseguem simular pelo menos tutorial e `arena_cinzas_curta`.
