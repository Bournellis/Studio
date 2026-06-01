# Codex - DraxosMobile Arena PVE Sequence Fix

- Data: `2026-06-01`
- Projeto: `Projetos/draxos-mobile`
- Branch final: `codex/draxos-mobile/scroll-drag-release-fix`
- Hotfix branch integrada: `codex/draxos-mobile/arena-pve-sequence-fix`
- Worktree final: `D:\Estudio-worktrees\draxos-mobile--codex--scroll-drag-release-fix`
- Status: `PUBLISHED_BACKEND_HOTFIX`

## Objetivo

Corrigir o bloqueio real em que o jogador conclui o tutorial da Arena PVE, abre
a primeira Arena real, vence o duelo 1, perde o duelo 2 e nao consegue progredir
para a proxima dificuldade.

## Resultado

- Reproducao real remota confirmada antes do patch.
- Causa raiz corrigida: o runtime da Arena usava a build bruta do bot fonte,
  sem aplicar a leitura jogavel dos `legal_unlocks` dos inimigos iniciais.
- Primeiro runway real da Arena agora usa oponentes pre-familiar legiveis.
- Primeira clear de Arena real rank 0 nao e mais reduzida como repeticao do
  tutorial.
- Hotfix branch mergeada por fast-forward na branch publicada mais recente.
- Edge Function `arena` publicada no remoto `armxgipvnbbshzqawklw`.

## Validacao

- `npx -y deno test --allow-read server/tests/arena_pve_sequence_tuning_test.ts server/tests/arena_loop_unlock_friction_test.ts server/tests/arena_consistency_pass_schema_test.ts server/tests/battle_combatants_test.ts`:
  passou com `20` testes.
- `npx -y deno lint server/functions/_shared/pve_arena_combatants.ts supabase/functions/_shared/pve_arena_combatants.ts server/tests/arena_pve_sequence_tuning_test.ts server/tests/arena_loop_unlock_friction_test.ts`:
  passou.
- `npx -y deno task --cwd server/functions check`: passou.
- `npx -y deno task --cwd supabase/functions check`: passou.
- `git diff --check`: passou.
- `npx -y supabase functions deploy arena --project-ref armxgipvnbbshzqawklw`:
  passou.
- Smoke remoto real pos-deploy: tutorial vencedor `player`; duelos 1, 2 e 3
  de `arena_cinzas_curta:s1_d00_intro` vencedores `player`;
  `arena_cinzas_curta:s1_d01_aprendiz` desbloqueada.

## Proximo Passo

Playtest humano da sequencia publicada: tutorial -> primeira Arena real
completa -> proxima dificuldade desbloqueada. Tuning numerico fino fica para
depois desse loop estar confirmado em mao.
