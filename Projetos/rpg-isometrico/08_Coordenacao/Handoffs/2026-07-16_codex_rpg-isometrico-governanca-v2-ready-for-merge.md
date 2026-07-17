# Handoff — Governança v2 do RPG Isométrico

## Metadata

- closure_protocol: agent_local_merge_v3
- technical_status: ready_for_merge
- human_gate_required: no
- human_gate_status: not_required
- human_gate_scope: none
- human_gate_evidence: n/a
- publication_status: not_authorized
- blocking_decision: none
- execution_mode: governance_migration
- delegated_scope: coordenação, documentação, QA, dívida e determinismo do gerador local
- branch: codex/rpg-isometrico/governanca-v2
- worktree: D:\Estudio-worktrees\rpg-isometrico--codex--governanca-v2
- base_ref: main@d42ad3c9
- merge_status: pending
- worktree_status: open
- branch_cleanup: pending
- validation_tier: Runtime
- validation_result: PASS — duas execuções limpas, 63/63 testes, 1.310 asserts e cenas byte-estáveis
- global_sync_needed: yes

## Resultado

- A coordenação local-first, o índice documental, o estado técnico curto e o contrato de QA estão instalados.
- O projeto continua `PAUSADO_INDEFINIDO`, sem track ou gate humano ativo.
- O canon de produto isométrico reside em `docs/canon/`; lore e fronteiras compartilhadas permanecem globais.
- O baseline de dívida registra `frontend_root.gd` (1.920), `campaign_root.gd` (947) e `test_frontend_flow.gd` (716), sem refatoração em massa.
- O gerador preserva os `unique_id` das dez cenas oficiais e o validador prova estabilidade em uma segunda geração.

## Validação

- `python tools/check_qa_contract.py --project RpgIsometrico`: PASS.
- Runtime integral após rebase: 2x PASS, `63/63`, `1.310 asserts`.
- Snapshot Git antes/depois das duas execuções: idêntico.
- `git diff --check`: PASS.

Nenhuma prioridade, feature, conteúdo, tuning, release ou baseline humano foi aprovada.
