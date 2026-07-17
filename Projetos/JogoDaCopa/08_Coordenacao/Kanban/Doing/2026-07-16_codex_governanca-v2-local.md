# Governança v2 local — JogoDaCopa

## Metadata

- closure_protocol: agent_local_merge_v3
- technical_status: in_progress
- human_gate_required: no
- human_gate_status: not_required
- human_gate_scope: none
- human_gate_evidence: n/a
- publication_status: not_authorized
- blocking_decision: none
- execution_mode: multi_agent_program
- delegated_scope: coordenação, documentação e QA locais
- branch: codex/jogodacopa/governanca-v2
- worktree: D:\Estudio-worktrees\jogodacopa--codex--governanca-v2
- base_ref: main@d69456d8
- merge_status: pending
- worktree_status: open
- branch_cleanup: pending
- validation_tier: Runtime
- validation_result: pending
- global_sync_needed: yes

## Objetivo

Instalar a coordenação local-first, reduzir documentos vivos, manter uma única linhagem de release, declarar QA executável e registrar dívida sem mudar produto, prioridade, tuning ou publicação.

## Validação

- IDs de `qa_manifest.json` e `QA_INDEX.md` idênticos.
- `tools/validate.gd --profile=full` sem side effects rastreados.
- baseline preservada: 108 testes e 1.844 asserts.
- UTF-8, NUL, links, JSON e `git diff --check`.
