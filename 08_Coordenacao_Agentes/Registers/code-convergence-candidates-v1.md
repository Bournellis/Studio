# Convergence candidates registry v1

## Metadata

- status: active_observation
- authority: historical_record
- last_verified: 2026-07-17
- review_when: dois consumidores estiverem ativos e existir proposta de adocao local
- supersedes: none
- superseded_by: none

## Baseline

- source_ref: `codex/estudio/governanca-v21@4d0a3aad2611f5bf0a46c98cdbd78aa70523ab95`
- hash_algorithm: `SHA-256`
- registry_mode: `read_only`
- shared_core_status: `not_authorized`
- extraction_status: `none`

Os hashes abaixo foram recalculados nos arquivos do baseline. Igualdade de bytes e somente evidencia de convergencia; nao cria ownership compartilhado nem autoriza extracao.

## Candidates

### CV-001 - deck slot control

- status: `candidate/deferred`
- sha256: `361e6edae17601f5e027f04e628139c668868ba69ba0c06b376aa16dd74c5796`
- bytes_each: `2521`
- path_a: `Projetos/draxos-roguelike-cardgame/ui/controls/deck_slot_control.gd`
- path_b: `Projetos/rpg-turnos/ui/controls/deck_slot_control.gd`
- review_when: ambos os projetos forem consumidores ativos e uma adocao local for proposta

### CV-002 - UI tokens

- status: `candidate/deferred`
- sha256: `a895a3c763b3268f892273a862e1e0175828041a216a5b195898b2b6a10d18b1`
- bytes_each: `1154`
- path_a: `Projetos/draxos-roguelike-cardgame/core/ui_tokens.gd`
- path_b: `Projetos/rpg-turnos/core/ui_tokens.gd`
- excluded_observation: `Projetos/draxos-mobile/core/ui_tokens.gd` tem SHA-256 `f089056c57fc2de0f04889045f399a80cdec00b6287e3286a26a4c7b9bea0ca7` e `10603` bytes; nao e equivalente
- review_when: ambos os projetos forem consumidores ativos e uma adocao local for proposta

### CV-003 - enemy hero drop zone

- status: `candidate/deferred`
- sha256: `e91818d34f3a3a212df55bd58952aeb5673bea5fdc327b773bc457fa3a91020b`
- bytes_each: `472`
- path_a: `Projetos/draxos-roguelike-cardgame/ui/controls/enemy_hero_drop_zone.gd`
- path_b: `Projetos/rpg-turnos/ui/controls/enemy_hero_drop_zone.gd`
- review_when: ambos os projetos forem consumidores ativos e uma adocao local for proposta

### CV-004 - card pool drop zone

- status: `candidate/deferred`
- sha256: `70cb0185c6e7ca34a83ce58c9fc6bdde6d2da139f620c2b4bcbce267c7e310cb`
- bytes_each: `408`
- path_a: `Projetos/draxos-roguelike-cardgame/ui/controls/card_pool_drop_zone.gd`
- path_b: `Projetos/rpg-turnos/ui/controls/card_pool_drop_zone.gd`
- review_when: ambos os projetos forem consumidores ativos e uma adocao local for proposta

### CV-005 - bootstrap scene generator

- status: `candidate/deferred`
- sha256: `7e0625601dfac256c259f1daa02f8d24fdcf160722e77752a46bdb4996eccd9b`
- bytes_each: `464`
- path_a: `Projetos/FpsPlayground/tools/create_bootstrap_scene.gd`
- path_b: `Projetos/JogoDaCopa/tools/create_bootstrap_scene.gd`
- review_when: os dois consumidores continuarem ativos e uma adocao local for proposta

## Decision

Nenhum grupo sera extraido nesta onda. Uma revisao futura deve recalcular hashes, comparar comportamento e testes, e usar o recibo global antes de qualquer escrita cross-project.
