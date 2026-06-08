# DraxosMobile Hardening Doing: autobattler - Arena PVE Bonus Pass

## Metadata

- data: `2026-06-08`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `mode-scaffolds`
- mode_scope: `autobattler`
- branch: `codex/draxos-mobile/arena-pve-bonus-pass`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-pve-bonus-pass`

## Objetivo

Diagnosticar a estrutura atual da Arena PVE, corrigir bônus entre lutas que não entram na próxima batalha e resolver problemas adicionais encontrados no mesmo fluxo.

## Latest Context

- latest published package: `Bosque Session Lifecycle & Durable Structures Hotfix v1`
- preserved Arena menu package: `Arena PVE Menu Flow Simplification v1`
- Arena regression focus: Preparacao, potion/buff flow, duel launch and next-fight stat projection.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/foundation-app-v0-audit.md`
- `Projetos/draxos-mobile/docs/pve-arena-v1.md`
- `Projetos/draxos-mobile/docs/arena-pve-season1-loop-v1.md`
- `Projetos/draxos-mobile/docs/arena-pve-menu-flow-simplification-v1.md`
- `Projetos/draxos-mobile/implementation/tracks/track-23-arena-pve-first-real-run/README.md`
- `Projetos/draxos-mobile/implementation/tracks/track-21-arena-loop-unlock-friction/README.md`

## Escopo

- Incluir:
  - fluxo Arena PVE entre preparacao, batalha, recompensa e proxima luta;
  - aplicacao e apresentacao de bonus persistentes de run, com foco em HP;
  - testes/labs locais existentes para Arena PVE.
- Fora do escopo:
  - worktrees de outros agentes;
  - publicacao remota ou mutacao Supabase/Cloudflare;
  - tuning amplo, economia nova, PVP, novas armas/spells ou visual final sem decisao propria.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/**` conforme diagnostico da Arena PVE.
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-08_codex_draxos-mobile_arena-pve-bonus-pass.md`
- Handoff/Done local se a correcao fechar com evidencias.

## Validation Plan

- `git diff --check`
- comandos locais de validacao da Arena PVE descobertos na documentacao/scripts;
- teste direcionado para bonus entre lutas, se existir ou for seguro adicionar.

## Resultado

- Causa raiz: `arena_choose_buff_v1` persistia `active_buffs` corretamente, mas `applyArenaBuffs` convertia bonus temporarios em `level`/`weaponLevel` com `Math.floor`. O buff `+4% max_hp` virava `Math.floor(4 / 5) = 0`, logo o HP maximo da proxima luta nao mudava.
- Correcao: Arena passa buffs como `statModifiers` explicitos para o simulador; o simulador aplica HP maximo, mana maxima, regen, dano, mitigacao, cooldown e duracao de status diretamente.
- Problema adicional 1: a UI mostrava apenas quantidade de buffs ativos, sem `+HP`; agora mostra nome e efeito do buff ativo.
- Problema adicional 2: cards de buff dependiam de `display_name`, mas o servidor tambem usa `label`; agora a UI aceita `display_name`, `label`, `name` e `title`.
- Problema adicional 3: texto gerado a partir de `stat_modifiers` era pouco legivel (`Max Hp 4`); agora formata como `+4% HP maximo`.

## Validacao Executada

- PASS: `npx -y deno test --allow-read Projetos/draxos-mobile/server/tests/first_slice_simulator_test.ts Projetos/draxos-mobile/server/tests/arena_loop_unlock_friction_test.ts`
- PASS: `npx -y deno task check` em `Projetos/draxos-mobile/server/functions`
- PASS: `npx -y deno task check` em `Projetos/draxos-mobile/supabase/functions`
- PASS: `git diff --check`
- PASS com ressalva de ambiente: GUT focado `test_arena_active_after_selected_buff_returns_to_resolve_duel` passou com `-gfailure_error_types=`. Sem essa flag, a worktree falha por imports/assets do Godot/GUT (`.ctex`, fontes do GUT, `entry_necromante.png`) antes de avaliar o patch.
- PASS: `server/functions/_shared/battle_combatants.ts`, `server/functions/_shared/battle_simulator.ts` e `server/functions/arena/index.ts` estao identicos aos espelhos em `supabase/functions`.

## Handoff Point

Entregar quando a causa do bug estiver corrigida, outros problemas do fluxo Arena PVE encontrados no mesmo diagnostico tiverem solucao aplicada ou documentada, e as evidencias locais estiverem registradas.
