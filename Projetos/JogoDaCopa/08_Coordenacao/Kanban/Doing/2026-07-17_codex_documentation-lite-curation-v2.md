# Documentation Lite v2 — curadoria pré-cutover do JogoDaCopa

## Metadata

- id: `2026-07-17_codex_jogodacopa_documentation-lite-curation-v2`
- data: `2026-07-17`
- agente: `Codex`
- projeto: `JogoDaCopa`
- prioridade_portfolio: `P0 TEMP / P2_IMPLEMENTACAO`
- coordination_scope: `documentation_alignment`
- closure_protocol: `agent_local_merge_v3`
- closure_contract: `estudio_lifecycle_v1`
- closure_mode: `integration_pending`
- technical_status: `complete`
- human_gate_required: `no`
- human_gate_status: `not_required`
- human_gate_scope: `none`
- human_gate_evidence: `n/a`
- publication_status: `not_authorized`
- blocking_decision: `none`
- execution_mode: `delegated_project_writer`
- delegated_scope: `Codex -> Projetos/JogoDaCopa/**; curadoria documental pré-cutover sem remoções históricas`
- branch: `codex/jogodacopa/documentation-lite-v2`
- worktree: `D:\Estudio-worktrees\jogodacopa--codex--documentation-lite-v2`
- base_ref: `codex/estudio/documentation-lite-v2@2fb87a8b`
- commit: `5428772e + final release-history commit at branch tip`
- merged_to: `n/a`
- merge_strategy: `ff-only planned by integration lead`
- merge_status: `pending`
- worktree_status: `open`
- branch_cleanup: `pending`
- validation_tier: `Docs`
- validation_result: `pass local — links 62/27, docs health, QA contract, UID 142/142, secrets 0, diff check; full profile awaits corrected overlap detector on integration branch`
- post_merge_validation: `pending`
- closure_summary: `50 tracks, 23 reviews, 6 plans and 46 reports curated; release lineage compacted; zero historical removals`
- global_sync_needed: `no`

## Objetivo

Consolidar a história durável do JogoDaCopa antes do cutover estrito, sem remover tracks, reviews, planos, relatórios, evidências, Done ou Handoffs e sem aprovar feel, visual ou publicação.

## Base lida

- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/08_Coordenacao/TRIAGE.md`
- `Projetos/JogoDaCopa/qa/QA_INDEX.md`

## Limites do escritor

- Escrita somente em `Projetos/JogoDaCopa/**`.
- Nenhum runtime, cena, asset, evidência bruta, screenshot ou licença será alterado.
- Nenhum caminho histórico será removido neste card.
- Aprovações humanas já registradas serão preservadas; nenhuma nova decisão será inferida.

## Plano de commits e validação

1. `docs(jogodacopa): consolidate product and implementation lineage`
2. `docs(jogodacopa): compact release and evidence history`
3. `DocsOnly JogoDaCopa`, links locais, `git diff --check` e árvore limpa.

## Hard stops e handoff

Parar diante de conflito semântico em aprovação, fallback ou história única. O handoff termina na branch limpa para revisão e integração do coordenador global.

## Resultado técnico

- `implementation/history.md` absorve decisões, reversões e autoridades retidas dos 50 documentos de track.
- `docs/release-history.md` preserva 28 release roots, aprovações, rollbacks, supersessões, fallbacks e ponteiros de evidência.
- Routers locais apontam para as autoridades curadas sem remover as fontes pré-cutover.
- Nenhum runtime, evidência, screenshot, licença, gate humano ou publicação foi alterado.
