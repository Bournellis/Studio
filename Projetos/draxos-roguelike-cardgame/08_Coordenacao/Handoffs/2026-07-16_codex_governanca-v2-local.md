# Handoff - Governanca v2 local do Draxos Roguelike Cardgame

## Metadata

- from: `Codex`
- to: `coordenador Governanca Estudio v2`
- date: `2026-07-16`
- projeto: `draxos-roguelike-cardgame`
- coordination_scope: `project_local`
- closure_protocol: `agent_local_merge_v3`
- technical_status: `complete`
- human_gate_required: `no`
- human_gate_status: `not_required`
- human_gate_scope: `none para a migracao; gates de produto preservados em Review`
- human_gate_evidence: `../Kanban/Review/`
- publication_status: `not_authorized`
- blocking_decision: `none`
- execution_mode: `multi_agent_program`
- delegated_scope: `coordenacao, documentacao e QA locais`
- branch: `codex/draxos-roguelike/governanca-v2`
- worktree: `D:\Estudio-worktrees\draxos-roguelike--codex--governanca-v2`
- base_ref: `main@20542ce3`
- merge_status: `integrated_ff_only`
- worktree_status: `cleanup_after_closure_commit`
- branch_cleanup: `cleanup_after_closure_commit`
- validation_tier: `Runtime`
- validation_result: `pass - Fast e Runtime integrais, incluindo pós-merge; labs separados; zero side effects rastreados`
- global_sync_needed: `yes`
- commits: `f345c807 coordenacao; 8edf3da0 documentacao; b0647696 QA/divida; 41535e2d Fast honesto`

## Resultado

A migracao local esta pronta para merge. O projeto continua `PAUSADO_TEMPORARIO`, Track 02 permanece `T02-P09_COMPLETE`, e nenhum candidato de Design Lab, balanceamento ou sensacao da run recebeu aprovacao.

## Superficie alterada

- `08_Coordenacao/`: ciclo local, tres gates humanos, card e handoff v3;
- `AGENTS.md`, `README.md`, `implementation/` e routers: autoridades e pausa alinhadas;
- `docs/`: metadata de documentos vivos, historia curada e duplicata de status removida;
- `qa/`: manifesto tipado, indice humano, Fast/Runtime e labs separados;
- `implementation/engineering-health-baseline.md`: sete arquivos grandes registrados com contagem exata.

## Validacao e evidencia

- `python tools/check_qa_contract.py --root . --project DraxosRoguelike`: PASS.
- `python tools/check_local_doc_links.py --root . --workspace estudio`: PASS.
- GUT completo Fast: PASS `226/226`, `1.975` asserts, Git limpo.
- `tools/validate.gd` duas vezes apos rebase: PASS `226/226`, `1.975`, rota `29/29`, Git limpo antes/depois.
- Run Lab smoke: PASS `29/29` para Arcano, Invocador e Necromante.
- Scenario Fixtures: 9 PASS, 3 WARN esperados, 0 FAIL.
- Battle Lab: 9 PASS, 3 WARN esperados, 0 FAIL.
- Card Impact V5 before gate: PASS, zero erros estruturais, novas falhas ou removidos.
- Design Lab sample: PASS, 9 candidatos, 3 recomendacoes, 0 mecanicas bloqueadas.
- `git diff --check`: PASS.

## Proximo passo

Coordenador: confirmar `main`, rebasear novamente se necessario, integrar com `ff-only`, rodar Runtime pos-merge e entao mover o card tecnico para Done, remover a worktree e apagar a branch.

Os tres cards em Review permanecem ate decisao humana explicita.
