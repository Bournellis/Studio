# Tarefa: Draxos Roguelike Cardgame Track 01

## Metadata

- id: `2026-05-07_codex_draxos-roguelike-cardgame_track-01`
- owner: `Codex`
- status: `Doing`
- projeto: `draxos-roguelike-cardgame`

## Goal

Evoluir o checkpoint da Track 00 para o primeiro slice jogavel coerente: iniciar run, escolher Classe real do slice, navegar no mapa, resolver batalha, retornar com estado visivel, usar almas/cura e validar decks mockup contra encontros iniciais.

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
- [x] P05: run linear de 10 mapas, recompensas automaticas e combate frontal validados.
- [x] P05: menu principal com 3 saves, escolha obrigatoria de classe, ShipHub visual, Deck/Almas dedicados e recompensa de vitoria em modal.
- [x] P05: HUD de batalha estavel, nome do jogador no save e combate em 4 etapas visiveis.
- [ ] P05: playtest e tuning do slice mecanico.

## Handoff Needed

`No`

## Notes

Target UX validado em 2026-05-08 com 28/28 testes. Em 2026-05-12, a run linear de 10 mapas foi validada com 41/41 testes: mana inicial 2, starter decks sem custo 3, recompensas automaticas nos mapas 2/3/5/7, combate frontal por lanes, `iniciativa`, passiva no mapa 5 e ativa no mapa 7. Ainda em 2026-05-12, o Battle recebeu slots/cartas com custo/ATK/HP flutuantes e uma HUD objetiva com HP/mana/recurso funcional, botao flutuante de turno, menu ESC, log compacto e comandante inimigo visual por flag nos duelos; validado com 48/48 testes. Em 2026-05-13, menus/saves foram reformulados com 3 slots, SaveManager, escolha de classe por imagem, ShipHub visual Deck/Mapa/Almas, Deck/Almas dedicados, recompensa pos-vitoria e validacao 18/18. Ainda em 2026-05-13, HUD de batalha estavel, nome do jogador, combate em 4 etapas, mock FX/logs e balanceamento Arcano foram validados com 43/43 testes e 316 asserts. Depois, ordem de sobra sequencial, IA de duelo pos-combate, alvos compactos e labels `Save` foram validados com 47/47 testes e 337 asserts. O slice ainda precisa de playtest/tuning e redesign completo das cartas.
