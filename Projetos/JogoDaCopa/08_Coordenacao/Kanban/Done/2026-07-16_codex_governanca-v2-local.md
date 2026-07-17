# Governança v2 local — JogoDaCopa

## Metadata

- closure_protocol: agent_local_merge_v3
- technical_status: complete
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
- merge_status: fast_forwarded_to_main
- worktree_status: removed_after_post_merge_validation
- branch_cleanup: deleted_and_pruned_after_merge
- validation_tier: Runtime
- validation_result: pass — Runtime 2x, 108/108 testes, 1.844 asserts, zero side effects
- global_sync_needed: yes

## Objetivo

Instalar a coordenação local-first, reduzir documentos vivos, manter uma única linhagem de release, declarar QA executável e registrar dívida sem mudar produto, prioridade, tuning ou publicação.

## Validação

- IDs de `qa_manifest.json` e `QA_INDEX.md` idênticos.
- `tools/validate.gd --profile=full` sem side effects rastreados.
- baseline preservada: 108 testes e 1.844 asserts.
- UTF-8, NUL, links, JSON e `git diff --check`.

## Resultado

- Import headless concluído; warnings históricos de UID do addon seguem para a onda mecânica de UIDs.
- Runtime integral executado duas vezes: 108/108 testes e 1.844 asserts em ambas.
- Segunda execução: status Git antes/depois vazio; nenhum side effect rastreado.
- Manifesto JSON e correspondência exata de IDs verificados.
- Nenhum pacote, remoto, publicação, tuning ou gate humano executado.
- Validação pós-merge em `main`: 108/108 testes, 1.844 asserts e árvore limpa.
