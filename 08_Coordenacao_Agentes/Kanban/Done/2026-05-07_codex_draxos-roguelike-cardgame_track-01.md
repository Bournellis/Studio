# Tarefa: Draxos Roguelike Cardgame Track 01

## Metadata

- id: `2026-05-07_codex_draxos-roguelike-cardgame_track-01`
- owner: `Codex`
- status: `Done`
- projeto: `draxos-roguelike-cardgame`

## Goal

Evoluir o checkpoint da Track 00 para o primeiro slice jogavel coerente: iniciar run, escolher Classe real do slice, navegar no mapa, resolver batalha, retornar com estado visivel, usar almas/cura e validar decks contra encontros.

## Technical Scope

- `RunSession`
- `ShipHub`
- `RunMap`
- `Battle`
- `slice_catalog.json`
- `track-01-playable-run-loop`

## Acceptance Criteria

- [x] P01: escolha de 3 Classes antes da run.
- [x] P01: `RunSession` registra classe, deck, vida e run ativa.
- [x] P01: RunMap fica bloqueado ate inicio explicito de run.
- [x] P02: retorno e estado visivel depois da batalha.
- [x] P03: recompensa placeholder pos-combate.
- [x] P04: almas e cura no ShipHub.
- [x] P04: classes `arcano`, `invocador`, `necromante` substituem placeholders.
- [x] P04: decks mockup de 15 cartas e encontros `limpar_mesa`/`ondas` entram no slice.
- [x] P04: passivas/spells iniciais implementadas em versao mecanica.
- [x] P04: decks sao embaralhados no inicio da batalha e ao reciclar descarte.
- [x] P05: target UX implementado com drag-and-drop, preview de cartas e modal do Necromante.
- [x] P05: run linear de 13 mapas, recompensas fixas/escolhiveis e combate frontal validados.
- [x] P05: menu principal com 3 saves, escolha obrigatoria de classe, ShipHub visual, Deck/Almas dedicados e recompensa de vitoria em modal.
- [x] P05: HUD de batalha estavel, nome do jogador no save e combate em 4 etapas visiveis.
- [x] P05: rota expandida para 13 mapas com recompensas fixas e escolhas de recompensa.
- [x] P05: upgrades reais Lvl 2/Lvl 3, 2 cartas novas por classe, save v3, mapa 6 sem upgrade, escolhas automaticas pos-combate adiadas, menus translucidos e dificuldade 7-13 reforcada.
- [x] P05: tuning de playtest com descarte pre-combate, raridades, loja de upgrades, save v4, Diabrete/Suicida, alvos de mesa aliada e inimigos +20%.
- [x] P05: slice mecanico validado e congelado como baseline para Track 02.

## Handoff Needed

`Yes - to Codex`

## Notes

Target UX validado em 2026-05-08 com 28/28 testes. Em 2026-05-12, a run linear de 10 mapas foi validada com 41/41 testes. Em 2026-05-13, menus/saves, ShipHub visual, Deck/Almas, recompensa pos-vitoria, HUD de batalha, nome do jogador, combate em 4 etapas, IA de duelo e balanceamento Arcano foram validados em passos sucessivos. Em seguida, sacrificio confirmado, troca adjacente, Necromante por niveis, Barreira Arcana Defensor, defesa reworkada e Sobreviver buffado foram validados.

Em 2026-05-15, a rota foi expandida para 13 mapas, depois recebeu upgrades reais Lvl 2/Lvl 3, 2 cartas novas por classe, save v3, menus translucidos, escolhas automaticas adiadas e dificuldade 7-13 reforcada, validado com 65/65 testes e 511 asserts.

Em 2026-05-15, o tuning P05 adicionou descarte pre-combate, raridades 70/25/5, loja de upgrades por 20 almas, save v4, Diabrete/Suicida, alvo de mesa aliada para Atacar/Acelerar, Ordem de Guerra custo 0, inimigos +20% e defesa com pressao nas side lanes; validado com 67/67 testes e 536 asserts.

Em 2026-05-18, a Track 01 foi congelada como baseline validada para a Track 02 - Complete Run Evolution. O proximo trabalho ativo deve seguir `Projetos/draxos-roguelike-cardgame/implementation/tracks/track-02-complete-run-evolution/implementation-prompts.md`.
