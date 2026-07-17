# Cleanup and retention manifest v1

## Metadata

- status: active_classification
- authority: historical_record
- last_verified: 2026-07-17
- review_when: antes de propor limpeza ou quando os paths, hashes ou contratos locais mudarem
- supersedes: none
- superseded_by: none

## Guard

- source_ref: `codex/estudio/governanca-v21@4d0a3aad2611f5bf0a46c98cdbd78aa70523ab95`
- hash_algorithm: `SHA-256`
- manifest_mode: `classification_only`
- destructive_authorization: `not_authorized`
- history_cleanup: `forbidden`

Este registro cobre grupos rastreados com arquivos iguais de pelo menos 1 MiB no baseline. Todas as decisoes sao `preserve` ou `defer`; nenhuma exclusao foi autorizada.

## CR-001 - evidencia JogoDaCopa

- sha256: `0baa5b456f27caeba7677c6e7e9c18a8fc22692208592ad11ba30212d7edc284`
- bytes_each: `1064470`
- paths: `Projetos/JogoDaCopa/docs/playtest-reports/track-07c-data/07c-remote-first-minute-fa82cb7d.png`; `Projetos/JogoDaCopa/docs/playtest-reports/track-07c-data/07c-remote-night-evidence-fa82cb7d.png`
- classification: `preserve`
- rationale: nomes distintos podem sustentar contextos de evidencia distintos; decidir exige auditoria do report e de suas referencias
- review_when: a linhagem Track 07c for condensada por tarefa local autorizada

## CR-002 - personagem Necromante entre produtos

- sha256: `1028b1e0b9e1ee40c9ef144db7de9af639f034bbc4850fe16ad94daec9464723`
- bytes_each: `1722168`
- paths: `Projetos/draxos-mobile/assets/ux_overhaul/entry_necromante.png`; `Projetos/draxos-roguelike-cardgame/assets/ui/characters/Necromante.png`
- classification: `preserve`
- rationale: ownership, import e release continuam locais; deduplicacao criaria dependencia cross-project
- review_when: ambos os projetos adotarem explicitamente uma fonte de asset comum

## CR-003 - background ship hub entre produtos

- sha256: `9317f9c3c7f45325183876b8600e98038b30eca3fa1cab5f12e3d81cb1532f9b`
- bytes_each: `1920679`
- paths: `Projetos/draxos-mobile/assets/ux_overhaul/refuge_ship_hub.png`; `Projetos/draxos-roguelike-cardgame/assets/ui/backgrounds/ship_hub_background.png`
- classification: `preserve`
- rationale: a fronteira de produto proibe transformar igualdade de bytes em dependencia operacional
- review_when: ambos os projetos adotarem explicitamente uma fonte de asset comum

## CR-004 - Quaternius hair 1 normal

- sha256: `57fd0ad8c96a4d01b38769637e066cecaa285b456f6e48ce00863754a457affb`
- bytes_each: `4326126`
- paths: `Projetos/JogoDaCopa/assets/characters/quaternius_ubc/base/T_Hair_1_Normal_png.png`; `Projetos/JogoDaCopa/assets/characters/quaternius_ubc/hair/T_Hair_1_Normal.png`
- classification: `defer`
- rationale: paths podem representar import contracts distintos do pacote; cena, material e licenca precisam ser auditados juntos
- review_when: o pacote Quaternius for tocado por tarefa local de integridade

## CR-005 - Quaternius hair 1 base color

- sha256: `bc7aa863bd22ab0a995cd838cceb4d3a5186ee54ee2fb0108fad85d20c057e6e`
- bytes_each: `1570376`
- paths: `Projetos/JogoDaCopa/assets/characters/quaternius_ubc/base/T_Hair_1_BaseColor.png`; `Projetos/JogoDaCopa/assets/characters/quaternius_ubc/hair/T_Hair_1_BaseColor.png`
- classification: `defer`
- rationale: preservar ate provar que materiais e importadores nao dependem dos dois paths
- review_when: o pacote Quaternius for tocado por tarefa local de integridade

## CR-006 - Quaternius hair 2 normal

- sha256: `172f230aae0d4366c3cfc0402b2e6d1811b11f8487344bff28605eeacac1558d`
- bytes_each: `4710013`
- paths: `Projetos/JogoDaCopa/assets/characters/quaternius_ubc/base/T_Hair_2_Normal.png`; `Projetos/JogoDaCopa/assets/characters/quaternius_ubc/hair/T_Hair_2_Normal.png`
- classification: `defer`
- rationale: preservar ate provar que materiais e importadores nao dependem dos dois paths
- review_when: o pacote Quaternius for tocado por tarefa local de integridade

## CR-007 - Quaternius hair 2 base color

- sha256: `f9f4f2fb3eeeefb0b6f0fdef38b0770fd6607640c1c680b8139dd76697e9f9b3`
- bytes_each: `1729467`
- paths: `Projetos/JogoDaCopa/assets/characters/quaternius_ubc/base/T_Hair_2_BaseColor.png`; `Projetos/JogoDaCopa/assets/characters/quaternius_ubc/hair/T_Hair_2_BaseColor.png`
- classification: `defer`
- rationale: preservar ate provar que materiais e importadores nao dependem dos dois paths
- review_when: o pacote Quaternius for tocado por tarefa local de integridade

## CR-008 - DraxosMobile battle lab summary

- sha256: `6bc984ac8cb997ad213f491d31dfae3ce3f3b0a3507abd85b390b8a26176d8ba`
- bytes_each: `12584409`
- paths: `Projetos/draxos-mobile/docs/battle-lab/generated/battle_lab_summary.json`; `Projetos/draxos-mobile/docs/battle-lab/runs/2026-05-31_s1_arena_baseline_v01/battle_lab_summary.json`
- classification: `preserve`
- rationale: um path e projecao gerada e o outro e run historica; igualdade atual nao garante papeis intercambiaveis
- review_when: o contrato de geracao e retention do Battle Lab mudar

## CR-009 - DraxosMobile battle lab matchups

- sha256: `fb845708f301d60f19a23a0b1276dd2d4d7c85964f4455d8d840263f1aac9b29`
- bytes_each: `2660141`
- paths: `Projetos/draxos-mobile/docs/battle-lab/generated/battle_lab_matchups.csv`; `Projetos/draxos-mobile/docs/battle-lab/runs/2026-05-31_s1_arena_baseline_v01/battle_lab_matchups.csv`
- classification: `preserve`
- rationale: preservar projecao e run ate o contrato local declarar uma fonte descartavel e regeneravel
- review_when: o contrato de geracao e retention do Battle Lab mudar

## Next safe action

Recalcular paths, tamanhos, hashes, referencias e worktrees em tarefa read-only antes de qualquer proposta. Se um grupo deixar de ser identico, este manifesto permanece historia da medicao e deve ser superseded, nunca reescrito como autorizacao retroativa.
