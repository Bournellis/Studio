# Multi-Agent Doing: Documentation Lite v2

## Metadata

- id: `2026-07-17_estudio_documentation_lite_v2`
- data: `2026-07-17`
- agente: `Codex`
- projeto: `estudio`
- prioridade_portfolio: `unchanged`
- coordination_scope: `global_governance`
- closure_protocol: `agent_local_merge_v3`
- closure_contract: `estudio_lifecycle_v1`
- closure_mode: `merged_pending_human_review`
- technical_status: `pass`
- human_gate_required: `yes`
- human_gate_status: `pending`
- human_gate_scope: `approve the exact cleanup manifest hash before Execute`
- human_gate_evidence: `08_Coordenacao_Agentes/Registers/documentation-lite-v2/index.json`
- publication_status: `not_authorized`
- blocking_decision: `Fabio approves the exact manifest hash and retained-authority map`
- execution_mode: `multi_agent`
- delegated_scope: `tooling and audits; active projects; paused projects; independent review`
- branch: `codex/estudio/documentation-lite-v2`
- worktree: `D:\Estudio-worktrees\estudio--codex--documentation-lite-v2`
- base_ref: `main@94559fa90e0b682bfa31c678dfb4b0d72da9907e`
- commit: `program preparation through 9b1fe891`
- merged_to: `codex/estudio/documentation-lite-v2@9b1fe891`
- merge_strategy: `ff-only`
- merge_status: `merged`
- worktree_status: `open`
- branch_cleanup: `pending`
- validation_tier: `FullLocal`
- validation_result: `62/62 governance checker tests; per-project DocsOnly pre/post integration; direct DraxosMobile documentation tests`
- post_merge_validation: `pending`
- closure_summary: `six project curations integrated and worktrees cleaned; exact strict cleanup index is the remaining human gate`
- global_sync_needed: `no`

## Objective

Curar o historico global e dos seis projetos, implantar recuperacao verificavel, remover apenas narrativa autorizada e concluir o cutover strict com merge local final.

## Base Read

- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`
- autoridades, QA e coordenacao local dos seis projetos

## Writer Boundaries

- Lead: decisao, tooling, schemas, indices, manifests globais, integracao e fechamento.
- Active-project agents: somente JogoDaCopa, FpsPlayground e DraxosMobile em worktrees disjuntas.
- Paused-project agents: somente Roguelike, RPG Isometrico e RPG Turnos; sem retomada de produto.
- Review agents: auditoria read-only de manifests, authorities, gates e recuperacao.

## Intended Files

- `tools/`, `.github/workflows/`, `AGENTS.md`, routers e templates globais.
- `08_Coordenacao_Agentes/{History,Registers,Receipts}/`.
- Authorities e historia compacta sob cada projeto; nenhum runtime salvo o retarget documental test-only do DraxosMobile.
- Skills pessoais atualizadas separadamente com `skill-creator`, fora do Git do Estudio.

## Commit And Validation Plan

- Decisao e registro operacional.
- Contratos, checker, wrapper e testes em commits separados.
- Curadoria por projeto em branches independentes.
- Manifestos literais e autorizacao por hash antes de qualquer exclusao.
- Um commit por batch destrutivo; `Verify` duas vezes.
- Strict lifecycle, portfolio sync de roteamento, validacao integral e merge `ff-only` em `main`.

## Hard Stops And Handoff

Parar o batch afetado em conflito semantico, retained authority ausente, source drift, Review protegida, segredo, cena/binario inesperado, remoto/publicacao, produto/prioridade ou decisao humana. O proximo gate global e a aprovacao do hash exato do manifesto antes de `Execute`.
