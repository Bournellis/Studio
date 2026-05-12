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

Proximo prompt: `P05 - Invocador Deck Activation and Class Selection Screen`.

## Progresso

- [x] P01: catalogo gerado expoe 5 classes autoradas.
- [x] P01: `ContentLibrary` expoe helpers de classe, heroi, hero power e starter deck.
- [x] P01: testes cobrem 5 starter decks de 20 cartas e validam que cada carta existe.
- [x] P01: validacao Godot verde em 2026-05-12 com 78/78 testes e 592 asserts.
- [x] P02: `GameSession.selected_class` adicionado com save/load retrocompativel.
- [x] P02: `select_class()`, `has_selected_class()`, `get_class_deck_ids()`, `initialize_deck_for_class()` implementados.
- [x] P02: snapshot pre-combate preserva e restaura `selected_class`.
- [x] P02: 8 novos testes cobrem new game, selecao valida/invalida, fallback de deck, save/load, save antigo sem campo, valor corrompido e snapshot.
- [ ] P02+P03: validacao Godot pendente (rodar localmente; `.tres` regenera automaticamente no `before_all` do GUT).
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
- [ ] P04: validacao Godot pendente (rodar localmente).

## Regras De Registro

- Atualizar o cursor e status do prompt em `linear-execution-plan.md`.
- Atualizar `Projetos/rpg-turnos/implementation/current-status.md` quando o baseline, proximo passo ou validacao mudarem.
- Atualizar `Projetos/rpg-turnos/implementation/tracks/track-02-draxos-lore-progression/current-status.md` quando o status da track mudar.
- Atualizar `08_Coordenacao_Agentes/Estado_Atual.md` quando o snapshot observavel do projeto mudar.
- Rodar validacao Godot apos mudancas de runtime, dados, cenas, recursos gerados ou testes.

## Proximo Passo

Executar P05:

1. Ativar starter deck do Invocador no fluxo de setup de sessao/deck.
2. Criar cena de selecao de classe (via script/tool, nao `.tscn` manual).
3. Rotear `Novo jogo` para selecao de classe quando nenhuma classe estiver selecionada.
4. Exibir 3 classes com nome, tagline e uma linha de comprometimento cada.
5. Confirmar selecao, persistir no save, inicializar deck de classe, entrar no mundo.
6. Adicionar testes para roteamento de cena, mutacao de sessao, carregamento de deck e round-trip save/load.
7. Rodar validacao.
