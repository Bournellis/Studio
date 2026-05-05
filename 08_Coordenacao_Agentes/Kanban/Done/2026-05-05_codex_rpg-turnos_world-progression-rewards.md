# Tarefa: World Progression And Rewards

## Metadata

- id: `2026-05-05_codex_rpg-turnos_world-progression-rewards`
- owner: `Codex`
- status: `Done`
- projeto: `rpg-turnos`

## Goal

Implementar progressao inicial de encontros e recompensas sem save/load ainda: cadeia de marcadores, rewards por encontro uma vez so, reentrada para pratica e recompensas progressivas da NPC.

## Linear Implementation Order

1. Expor `first_npc_reward_card`, `npc_reward_choices` e `reward_cards` via `ContentLibrary`.
2. Migrar `GameSession` de `is_encounter_completed` unico para estruturas por encounter id.
3. Implementar claim unico de rewards por encontro.
4. Implementar recompensa progressiva de NPC apos encontros.
5. Trocar o mundo de um marcador unico para cadeia de marcadores data-driven.
6. Ajustar result summary para mostrar cartas obtidas.
7. Adicionar/atualizar GUT.
8. Rodar validacao Godot/GUT.
9. Atualizar status vivo e coordenacao.

## Out of Scope

- Save/load persistente.
- Arte final/Phase H/J.
- Balanceamento fino.

## Acceptance Criteria

- [x] Encontros concluidos ficam em `completed_encounter_ids`.
- [x] Rewards por encontro entram uma vez em `unlocked_card_ids`.
- [x] Reentrar em encontro concluido nao duplica reward.
- [x] NPC concede `golpe_preciso` primeiro e depois `npc_reward_choices` em ordem.
- [x] Mundo apresenta cadeia linear de marcadores.
- [x] `tools/validate.gd` passa.

## Result

- Validacao Godot/GUT em `2026-05-05`: `51/51` testes passando.
- Implementado: `completed_encounter_ids`, `claimed_encounter_reward_ids`, `npc_reward_index`, rewards por encontro, NPC progressiva, cadeia linear de marcadores no mapa e resumo de cartas obtidas.
- Proximo passe linear recomendado: visual/UX hardening ou save/load minimo antes de expandir conteudo.

## Handoff Needed

`No`
