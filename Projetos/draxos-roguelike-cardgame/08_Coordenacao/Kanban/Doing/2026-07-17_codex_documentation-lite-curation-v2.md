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
- closure_mode: `integration_pending`
- technical_status: `in_progress`
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
- commit: `pending`
- merged_to: `n/a`
- merge_strategy: `ff-only planned by integration lead`
- merge_status: `pending`
- worktree_status: `open`
- branch_cleanup: `pending`
- validation_tier: `Docs`
- validation_result: `pending`
- post_merge_validation: `pending`
- closure_summary: `pending`
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
