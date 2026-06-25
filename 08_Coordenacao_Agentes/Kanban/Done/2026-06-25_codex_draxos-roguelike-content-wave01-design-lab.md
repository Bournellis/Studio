# Draxos Roguelike Content Wave 01 Design Lab

- Data: `2026-06-25`
- Agente: `Codex`
- Projeto: `Projetos/draxos-roguelike-cardgame/`
- Branch: `codex/draxos-roguelike-cardgame/content-wave01-design-lab`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--content-wave01-design-lab`
- Status: `DONE - aguardando merge local e push Fabio`

## Objetivo

Criar a primeira wave real de proposal packs para testar o Design Lab como ponte entre ideia de carta/mecanica/inimigo e candidato numerico jogavel, sem promover conteudo oficial.

## Entregas

- `arcano_cards_wave01.json`: 8 ideias Arcano com dano, controle, economia, card-flow e summon.
- `invocador_cards_wave01.json`: 8 ideias Invocador com summon, defensor, corpos de lane e buffs.
- `necromante_cards_wave01.json`: 8 ideias Necromante com summon, poison, economia e buff.
- `enemy_cards_wave01.json`: 12 ideias inimigas Terra/Gelo/Ar/Fogo com assinatura causal e AI contexts.
- `mechanics_backlog_wave01.json`: 6 ideias futuras bloqueadas corretamente por falta de suporte real.
- `mechanic_registry.json`: backlog de `lane_shift`, `copy_last_spell`, `summon_from_discard` e `life_payment` adicionado como `blocked_missing_engine_support`.
- `docs/design-lab.md`, `implementation/current-status.md` e `Estado_Atual.md` atualizados para Content Wave 01.

## Resultado Dos Labs

- Arcano explore: PASS, 48 candidatos, 8 recomendacoes, 1 variante broken rejeitada.
- Arcano gate promotavel: PASS, 83 candidatos, 8 recomendacoes.
- Invocador explore: PASS, 48 candidatos, 8 recomendacoes.
- Invocador gate promotavel: PASS, 96 candidatos, 8 recomendacoes.
- Necromante explore: PASS, 48 candidatos, 8 recomendacoes, 6 variantes broken rejeitadas.
- Necromante gate promotavel: PASS, 86 candidatos, 8 recomendacoes.
- Enemy explore: FAIL esperado/diagnostico, 72 candidatos, 8 recomendacoes, 24 variantes risky/broken. Ideias rejeitadas: `enemy_w01_ar_faisca_viva`, `enemy_w01_ar_turbilhao_brutal`, `enemy_w01_fogo_brasa_raivosa`, `enemy_w01_fogo_colosso_carvao`.
- Enemy gate promotavel: PASS, 78 candidatos, 8 recomendacoes.
- Mechanics backlog explore: FAIL esperado, 6 cartas bloqueadas, 5 mecanicas bloqueadas, 0 tuning falso.

## Validacao

- JSON parse dos 5 proposal packs e mechanic registry: PASS.
- Card Impact V5 official before gate: PASS, 0 structural errors, 0 new failures, 0 removed records.
- Run Lab smoke official gate: PASS, baseline `track02_smoke_v1`.
- Run Lab quick official gate: PASS, baseline `track02_quick_v1`.
- `validate.gd`: PASS, 226/226 testes, 1975 asserts. Primeiro run em worktree novo exigiu import headless do editor para registrar classes globais/GUT.
- `tools/check_doc_drift.ps1`: PASS.

## Handoff

Proxima etapa recomendada: abrir uma rodada de revisao dos promotion manifests da Wave 01, escolher manualmente quais dos 32 candidatos recomendados devem virar conteudo oficial, decidir se as 4 ideias inimigas rejeitadas serao redesenhadas ou movidas para perfil mid/boss, e priorizar uma primeira mecanica bloqueada para implementacao real no engine/lab.

`PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`
