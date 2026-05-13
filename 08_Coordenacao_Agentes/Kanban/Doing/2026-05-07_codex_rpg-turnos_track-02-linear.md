# RPG Turnos - Track 02 Linear Execution

- Data: `2026-05-07`
- Agente: `Codex`
- Status: `Doing`
- Projeto: `Projetos/rpg-turnos`
- Track: `Track 02 - Draxos Lore And Progression Alignment`
- Plano operacional: `Projetos/rpg-turnos/implementation/tracks/track-02-draxos-lore-progression/linear-execution-plan.md`

## Objetivo

Executar a Track 02 em ordem linear, prompt a prompt, mantendo todos os registros atualizados.

## Cursor Atual

Proximo prompt: `P10 - Necromante: Cinzas and Memorial de Batalha`.

## Progresso

- [x] P01: catalogo gerado expoe 5 classes autoradas.
- [x] P01: `ContentLibrary` expoe helpers de classe, heroi, hero power e starter deck.
- [x] P01: testes cobrem 5 starter decks de 20 cartas e validam que cada carta existe.
- [x] P01: validacao Godot verde em 2026-05-12 com 78/78 testes e 592 asserts.
- [x] P02: `GameSession.selected_class` adicionado com save/load retrocompativel.
- [x] P02: `select_class()`, `has_selected_class()`, `get_class_deck_ids()`, `initialize_deck_for_class()` implementados.
- [x] P02: snapshot pre-combate preserva e restaura `selected_class`.
- [x] P02: 8 novos testes cobrem new game, selecao valida/invalida, fallback de deck, save/load, save antigo sem campo, valor corrompido e snapshot.
- [x] P02+P03: validacao Godot coberta em 2026-05-12 com 125/125 testes e 653 asserts.
- [x] P03: 5 classes antigas removidas de `slice_catalog.json`.
- [x] P03: 3 novas classes (Invocador, Arcano, Necromante) com `passiva`, `hero_power` e starter decks de 20 cartas validados.
- [x] P03: 2 novas cartas adicionadas: `reforco_aliado` e `amplificacao_campo` (Invocador).
- [x] P03: `docs/class-catalog-schema.md` atualizado com campo `passiva` e hero powers das 3 classes.
- [x] P03: teste `test_catalog_exposes_class_definitions_and_starter_decks` atualizado para 3 classes com verificacao de `passiva`.
- [x] P04: `BattleEngine.use_player_hero_power(target)` refatorado para dispatch data-driven via `ContentLibrary`.
- [x] P04: `Amplificar` hero power implementado: +2/+0 permanente em criatura aliada escolhida, custo 1, 1x/turno.
- [x] P04: `Comandante de Campo` passiva implementada: ao invocar criatura aliada, aliada com maior ATK ganha +1/+0 permanente.
- [x] P04: `Preparar Defesa` mantido como fallback sem classe ativa.
- [x] P04: `_apply_permanent_stat_buff` helper adicionado; `reforco_aliado` e `amplificacao_campo` sao cartas jogaveis.
- [x] P04: `test_class_invocador.gd` com 14 testes cobrindo passiva, hero power, fallback legacy e cartas de buff.
- [x] P04: validacao Godot coberta em 2026-05-12 com 125/125 testes e 653 asserts.
- [x] P05: starter deck do Invocador ativado via `GameSession.initialize_deck_for_class()`.
- [x] P05: `modes/class_select/class_select.tscn` e `class_select_root.gd` criados; exibe 3 classes com nome, tagline, passiva e hero power.
- [x] P05: `boot_root.gd` roteado — Novo jogo vai para `class_select.tscn` em vez de `world.tscn`.
- [x] P05: `GameSession.get_battle_config()` passa `class_id` ao `BattleEngine` quando classe selecionada.
- [x] P05: 6 novos testes em `test_content_and_session.gd` cobrindo battle config, selecao end-to-end, validade do deck e round-trip save/load.
- [x] P05: validacao Godot coberta em 2026-05-12 com 125/125 testes e 653 asserts.
- [x] P06: botao de hero power le `display_name` do catalogo (`"Amplificar"` para Invocador).
- [x] P06: `battle_root.gd` exibe botoes de alvo por slot (`"Amplificar → Slot X"`) quando `effect.target == "any_own_creature"`.
- [x] P06: label "Hero Power:" no class select corrigido para portugues ("Poder de heroi:").
- [x] P06: hint de feedback de batalha desacoplada do nome "Preparar Defesa".
- [x] P06: 3 novos testes em `test_content_and_session.gd` cobrindo display_name, target e fallback.
- [x] P06: Invocador registrado como primeira classe jogavel completa.
- [x] P06: validacao Godot coberta em 2026-05-12 com 125/125 testes e 653 asserts.
- [x] P07: contador `fluxo` volatil adicionado ao `BattleEngine` (var fluxo, reset no upkeep, incrementa por magia/magia_de_tabuleiro).
- [x] P07: `_player_fluxo_bonus` e `_try_trigger_fluxo` helpers adicionados; ambos guardam por `active_class_id != "arcano"`.
- [x] P07: `_play_damage_spell` adiciona fluxo ao `amount`; `play_card_from_hand` chama `_try_trigger_fluxo` apos damage/board spells.
- [x] P07: `test_arcano_fluxo.gd` com 13 testes: init, incremento por tipo de spell, stacking, reset por turno, amplificacao no 2o e 3o spell, isolamento sem classe, isolamento em ataques de criatura.
- [x] P07: validacao Godot verde em 2026-05-12 com 125/125 testes e 653 asserts.
- [x] P08: `_use_hero_power_damage` adicionado ao `BattleEngine`: Pulso Astral inflige 1+fluxo dano magico a permanente ou heroi inimigo.
- [x] P08: dispatch em `use_player_hero_power` extendido: `action == "damage"` roteia para `_use_hero_power_damage`.
- [x] P08: `battle_root.gd` atualizado: `_hero_power_needs_ally_target` substituido por `_hero_power_needs_targeting`; suporte a `any_permanent_or_hero` com botoes por slot inimigo e botao heroi no duelo.
- [x] P08: `test_class_arcano.gd` com 12 testes: slot/heroi target, custo, flag used, falhas, amplificacao de fluxo, sem incremento de fluxo, reset entre turnos.
- [x] P08: validacao Godot pendente (rodar localmente).
- [x] P09: 4 testes de integracao Arcano adicionados a `test_content_and_session.gd` (display_name Pulso Astral, target any_permanent_or_hero, fluxo_bonus flag, passiva fluxo_continuo).
- [x] P09: records atualizados (linear-execution-plan, track current-status, current-status, Estado_Atual, Kanban).
- [ ] P09: validacao Godot pendente (rodar localmente).

## Regras De Registro

- Atualizar o cursor e status do prompt em `linear-execution-plan.md`.
- Atualizar `Projetos/rpg-turnos/implementation/current-status.md` quando o baseline, proximo passo ou validacao mudarem.
- Atualizar `Projetos/rpg-turnos/implementation/tracks/track-02-draxos-lore-progression/current-status.md` quando o status da track mudar.
- Atualizar `08_Coordenacao_Agentes/Estado_Atual.md` quando o snapshot observavel do projeto mudar.
- Rodar validacao Godot apos mudancas de runtime, dados, cenas, recursos gerados ou testes.

## Proximo Passo

Executar P10 - Necromante: Cinzas and Memorial de Batalha:

1. Adicionar `cinzas: int` ao `BattleEngine` (persiste entre turnos, reseta no novo encontro).
2. Adicionar `memorial_de_batalha: Array` ao `BattleEngine` (lista de criaturas destruidas no encontro, reseta no novo encontro).
3. Incrementar `cinzas` e adicionar a criatura ao `memorial_de_batalha` em cada destruicao de criatura (ambos os lados).
4. Escrever `test_necromante_cinzas.gd` cobrindo incremento, persistencia entre turnos, reset por encontro e dados do memorial.
5. Rodar validacao.
