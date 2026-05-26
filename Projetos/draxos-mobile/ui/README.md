# ui/

Componentes de interface do jogador. Sem logica de jogo — apenas apresentacao e input.

Organizado por tela: base_manager, batalha, perfil, social, menu.

## Batalha

- `battle_log_presenter.gd`: ordena e formata `battle_log_v1` para texto/debug.
- `battle_stage_2d.gd`: palco 2D procedural estilo luta lateral, com
  personagens parados frente a frente, slots front/middle/back e efeitos
  temporarios.
- `battle_actor_marker.gd`: silhueta procedural de combatente com barras,
  pulse de impacto e tooltip de asset futuro.
- `battle_symbol_icon.gd`: icone procedural para status, cooldowns, pets,
  summons e eventos.
- `battle_visual_mockup.gd`: mockup visual reutilizavel para tela Batalha e
  Battle Lab, consumindo apenas o log recebido e mantendo placeholders para
  personagens, ataques, spells, buffs, dano, efeitos, icons, summons, Familiar
  e HUD basica.
