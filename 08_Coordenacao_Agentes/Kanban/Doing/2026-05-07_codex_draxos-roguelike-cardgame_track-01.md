# Tarefa: Draxos Roguelike Cardgame Track 01

## Metadata

- id: `2026-05-07_codex_draxos-roguelike-cardgame_track-01`
- owner: `Codex`
- status: `Doing`
- projeto: `draxos-roguelike-cardgame`

## Goal

Evoluir o checkpoint da Track 00 para o primeiro loop jogavel coerente: iniciar run, escolher Classe placeholder, navegar no mapa, resolver batalha, retornar com estado visivel e preparar recompensas/cura placeholder.

## Technical Scope

- `RunSession`
- `ShipHub`
- `RunMap`
- `Battle`
- `slice_catalog.json`
- `track-01-playable-run-loop`

## Acceptance Criteria

- [x] P01: escolha de 3 Classes placeholder antes da run.
- [x] P01: `RunSession` registra classe, deck, vida e run ativa.
- [x] P01: RunMap fica bloqueado ate inicio explicito de run.
- [x] P02: retorno e estado visivel depois da batalha.
- [x] P03: recompensa placeholder pos-combate.
- [ ] P04: almas e cura placeholder no ShipHub.
- [ ] P05: checkpoint do loop jogavel endurecido.

## Handoff Needed

`No`

## Notes

Classes seguem como placeholders ate sessao de design dedicada.
