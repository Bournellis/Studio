# Tarefa: Governanca Estudio v2.1

## Metadata

- id: `2026-07-17_estudio-governanca-v21`
- owner: `Codex`
- status: `Doing`
- projeto: `AllOfficial`
- prioridade_portfolio: `unchanged`
- coordination_scope: `global_governance`
- closure_protocol: `agent_local_merge_v3`
- technical_status: `pending`
- human_gate_required: `no`
- human_gate_status: `not_required`
- human_gate_scope: `none`
- human_gate_evidence: `n/a`
- publication_status: `not_authorized`
- blocking_decision: `none`
- execution_mode: `multi_agent`
- delegated_scope: `documentation and closure tooling; DraxosMobile mobile QA contracts; visual, evidence and security tooling`
- branch: `codex/estudio/governanca-v21`
- worktree: `D:\Estudio-worktrees\estudio--codex--governanca-v21`
- base_ref: `main@4bcb012b`
- merge_status: `pending`
- worktree_status: `open`
- branch_cleanup: `pending`
- validation_tier: `QA`
- validation_result: `pending`
- global_sync_needed: `yes`

## Goal

Completar as camadas de integridade, QA mobile, producao visual e ergonomia operacional que ficaram fora da Governanca v2 sem mudar produto, prioridade ou gates humanos.

## Scope

- Include: higiene documental, closure v3 executavel, lifecycle, locks, QA user data, resultados estruturados, QA mobile, acessibilidade, producao visual, evidencia/LFS, secret scan, convergencia e readiness inativo.
- Exclude: exclusao historica, shared core, device fisico, publicacao, remoto, release, tuning, feature, produto e prioridade.

## Intended files

- `AGENTS.md`, `.rgignore`, `materiais/guides/`, `canon/studio-conventions/`, `08_Coordenacao_Agentes/`, `tools/`.
- `Projetos/draxos-mobile/qa/`, contratos tecnicos e coordenacao local estritamente necessaria.
- Coordenacao local do RPG Turnos somente para completar o ledger da migracao v2.

## Validation plan

- Testes unitarios dos checkers e helpers.
- `StudioDoctor Core`, `DocsOnly AllOfficial`, contract checks, secret scan e `git diff --check`.
- Testes dry-run de lifecycle, evidence, LFS e mobile candidate; nenhum remoto ou device fisico.

## Acceptance Criteria

- [ ] Documentos vivos e buscas comuns apontam primeiro para contratos atuais.
- [ ] Closure v3, worktrees e Portfolio Sync possuem validacao executavel.
- [ ] Runners concorrentes possuem locks e namespace de QA isolado.
- [ ] DraxosMobile possui intencoes mobile, matriz e recibos sem executar device QA.
- [ ] Pipeline visual, proveniencia, evidencia/LFS e secret scan estao tipados e testados.
- [ ] Nenhum segredo, remoto, publicacao ou mudanca de produto ocorreu.

## Closeout

- Commits: `pending`
- Handoff: `pending`
- Push: `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`
