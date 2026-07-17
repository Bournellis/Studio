# Documentation Lite v2 - curadoria pre-cutover do Draxos Roguelike

## Metadata

- id: `2026-07-17_codex_draxos-roguelike_documentation-lite-curation-v2`
- data: `2026-07-17`
- agente: `Codex`
- projeto: `DraxosRoguelike`
- prioridade_portfolio: `Pausa / PAUSADO_TEMPORARIO`
- coordination_scope: `documentation_alignment`
- closure_protocol: `agent_local_merge_v3`
- closure_contract: `estudio_lifecycle_v1`
- closure_mode: `merged_not_required_done`
- technical_status: `pass`
- human_gate_required: `no`
- human_gate_status: `not_required`
- human_gate_scope: `none`
- human_gate_evidence: `n/a`
- publication_status: `not_authorized`
- blocking_decision: `none`
- execution_mode: `delegated_project_writer`
- delegated_scope: `Codex -> Projetos/draxos-roguelike-cardgame/**; curadoria documental pre-cutover sem remocoes historicas`
- branch: `codex/draxos-roguelike/documentation-lite-v2`
- worktree: `D:\Estudio-worktrees\draxos-roguelike--codex--documentation-lite-v2`
- base_ref: `codex/estudio/documentation-lite-v2@b27f59b2`
- commit: `c166c326; 91b14990`
- merged_to: `codex/estudio/documentation-lite-v2@91b14990`
- merge_strategy: `ff-only`
- merge_status: `merged`
- worktree_status: `removed`
- branch_cleanup: `deleted`
- validation_tier: `Docs`
- validation_result: `pass local - DocsOnly DraxosRoguelike: 13 pass, 4 warn, 0 fail; links 63/27; docs health 0 warnings; UID 181/181; secrets 0; overlap 0; no side effects`
- post_merge_validation: `DocsOnly DraxosRoguelike PASS; Review hashes unchanged; no validator side effects`
- closure_summary: `18 track files and 9 historical docs curated into implementation/history.md; promoted contracts reconciled; zero source removals; 3 Review cards preserved byte-identical`
- global_sync_needed: `no`

## Objetivo

Consolidar a historia duravel do Draxos Roguelike antes do cutover estrito, sem remover tracks, propostas, notas de encontro, evidencias, Done ou Handoffs e sem retomar produto ou resolver gates humanos.

## Base lida

- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-roguelike-cardgame/AGENTS.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
- `Projetos/draxos-roguelike-cardgame/08_Coordenacao/TRIAGE.md`
- `Projetos/draxos-roguelike-cardgame/qa/QA_INDEX.md`

## Limites do escritor

- Escrita somente em `Projetos/draxos-roguelike-cardgame/**`.
- Nenhum runtime, cena, asset, evidencia bruta ou baseline de lab sera alterado.
- Nenhum caminho historico sera removido neste card.
- Os tres cards em `Kanban/Review/` permanecem pendentes e byte-identical.
- Nenhuma promocao de Design Lab, mudanca de balance ou retomada sera inferida.

## Plano de commits e validacao

1. `docs(roguelike): reconcile promoted track contracts`
2. `docs(roguelike): record track and lab lineage`
3. `DocsOnly DraxosRoguelike`, links locais, hashes de Review, `git diff --check` e arvore limpa.

## Hard stops e handoff

Parar diante de conflito semantico em conteudo promovido, evidencia de rejeicao ou gate humano. O handoff termina na branch limpa para revisao e integracao do coordenador global.

## Resultado tecnico

- `docs/game-design-document.md` diferencia contrato promovido de proposta, probe e tuning historico.
- `docs/architecture.md` preserva o closeout como evidencia e mantem ownership/divida nas autoridades vivas.
- `implementation/history.md` absorve a linhagem das Tracks 00-02, Foundation Hardening, AutoRun, Scenario, Battle Lab, Card Impact V1-V5 e Design Lab Wave 01.
- O probe de Choque, o probe Terra revertido, as hipoteses sem playtest e as mecanicas bloqueadas permanecem explicitamente nao promovidos.
- Nenhuma fonte historica, gate humano, runtime, produto, tuning, prioridade, publicacao ou remoto foi alterado.
