# Tarefa: fechamento seguro do workspace federado

## Metadata

- id: `2026-09-07_studio-workspace-closure`
- owner: `Codex`
- status: `Doing`
- projeto: `estudio`
- prioridade_portfolio: `sem alteração; integridade autorizada por Fabio`
- coordination_scope: `documentation_alignment`
- closure_protocol: `agent_local_merge_v3`
- closure_contract: `estudio_lifecycle_v1`
- closure_mode: `in_progress`
- technical_status: `pending`
- human_gate_required: `no`
- human_gate_status: `not_required`
- human_gate_scope: `none`
- human_gate_evidence: `n/a`
- publication_status: `not_requested`
- git_sync_status: `pending_safe_push`
- blocking_decision: `none`
- execution_mode: `multi_agent`
- delegated_scope: `classificação de história, objetos residuais e retenção; líder integra`
- branch: `codex/global/closure-20260907`
- worktree: `D:\Estudio-worktrees\global--codex--closure`
- base_ref: `main@dd914833f3c1f0f5521219136dfd672fbe0cb907`
- commit: `n/a before first commit`
- merged_to: `n/a before merge`
- merge_strategy: `ff-only`
- merge_status: `pending`
- worktree_status: `open`
- branch_cleanup: `pending`
- validation_tier: `Docs`
- validation_result: `pending`
- post_merge_validation: `pending`
- closure_summary: `pending`
- global_sync_needed: `no`

## Goal

Preservar e classificar a história recuperável, indexar custódia e encerrar
resíduos operacionais sem alterar produto, prioridade ou gates.

## Scope

Fabio autorizou a execução do plano dos três ambientes em 06/09/2026.
Baseline, inventário e provas ficam em
`D:\StudioRecovery\closure-20260907\preflight.json` e subpastas.
Toda retirada depende da lista exata, custódia SHA-256 e restauração integral
do conjunto a partir da cópia independente. Receipts e locators históricos
consumidos permanecem intactos. Projetos pausados não são retomados.

## Acceptance Criteria

- [ ] Objetos encontrados classificados e protegidos por referências/custódia.
- [ ] Evidências Copa e relatórios externos com origem e recuperação exatas.
- [ ] DocsOnly AllOfficial e StudioDoctor Core aprovados tecnicamente.
- [ ] Integração ff-only, sincronização Git delegada e cleanup comprovados.
- [ ] Gates humanos e publicação de produto preservados separadamente.

## Closeout

Receipt final será adicionado em `08_Coordenacao_Agentes/Receipts/WorkspaceClosure/`.
Este card é transitório e sai da fila viva ao fechar tecnicamente.
