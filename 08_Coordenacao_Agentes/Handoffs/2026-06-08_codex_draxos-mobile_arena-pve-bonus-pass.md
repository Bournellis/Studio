# Handoff: DraxosMobile Arena PVE Bonus Pass

## Metadata

- data: `2026-06-08`
- agente: `Codex`
- projeto: `draxos-mobile`
- branch: `codex/draxos-mobile/arena-pve-bonus-pass`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-pve-bonus-pass`
- status: correcao local implementada e validada; sem publicacao remota.

## Entrega

- Corrigida aplicacao de buffs temporarios da Arena PVE entre duelos.
- `active_buffs` ja era persistido pelo RPC; a falha estava na conversao para combate: `+4% max_hp` virava `Math.floor(4 / 5) = 0`.
- Arena agora injeta `statModifiers` explicitos no combatente antes do simulador.
- Simulador agora aplica modificadores de HP maximo, mana maxima, regen de HP/mana, dano, mitigacao, cooldown e duracao de status.
- UI da Arena ativa agora mostra nome e efeito dos buffs ativos em vez de apenas quantidade.
- Cards de escolha aceitam `label` alem de `display_name`, alinhando payloads do servidor.

## Evidencias

- PASS: `npx -y deno test --allow-read Projetos/draxos-mobile/server/tests/first_slice_simulator_test.ts Projetos/draxos-mobile/server/tests/arena_loop_unlock_friction_test.ts`
- PASS: `npx -y deno task check` em `Projetos/draxos-mobile/server/functions`
- PASS: `npx -y deno task check` em `Projetos/draxos-mobile/supabase/functions`
- PASS: `git diff --check`
- PASS com ressalva: GUT focado do teste `selected_buff` passou com `-gfailure_error_types=`; sem essa flag, o ambiente falha por assets/imports Godot/GUT nao gerados na worktree.

## Proximo Passo Sugerido

- Playtest humano local/remoto: escolher `Vitalidade Menor`, resolver o duelo seguinte e confirmar no log/visual que `battle_start.player_max_hp` subiu.
- Antes de publicar, rodar validacao client completa em uma worktree com imports Godot/ctex saudaveis.
