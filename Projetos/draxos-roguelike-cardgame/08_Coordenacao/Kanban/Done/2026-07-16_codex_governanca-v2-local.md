# Governanca v2 local - Draxos Roguelike Cardgame

## Metadata

- id: `2026-07-16_draxos-roguelike-governanca-v2-local`
- data: `2026-07-16`
- agente: `Codex`
- projeto: `draxos-roguelike-cardgame`
- prioridade_portfolio: `PAUSADO_TEMPORARIO`
- coordination_scope: `project_local`
- closure_protocol: `agent_local_merge_v3`
- technical_status: `complete`
- human_gate_required: `no`
- human_gate_status: `not_required`
- human_gate_scope: `none`
- human_gate_evidence: `n/a`
- publication_status: `not_authorized`
- blocking_decision: `none`
- execution_mode: `multi_agent_program`
- delegated_scope: `coordenacao, documentacao e QA locais do Draxos Roguelike Cardgame`
- branch: `codex/draxos-roguelike/governanca-v2`
- worktree: `D:\Estudio-worktrees\draxos-roguelike--codex--governanca-v2`
- base_ref: `main@20542ce3`
- merge_status: `integrated_ff_only`
- worktree_status: `cleanup_after_closure_commit`
- branch_cleanup: `cleanup_after_closure_commit`
- validation_tier: `Runtime`
- validation_result: `pass - QA e links; Fast 226/226; Runtime 2x pré-merge e 1x pós-merge 226/226, 1.975, rota 29/29, zero side effects; cinco labs verdes`
- global_sync_needed: `yes`

## Objetivo

Instalar coordenacao local-first, reduzir documentos vivos, declarar QA executavel, preservar gates humanos e registrar divida sem retomar o produto.

## Base lida

- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-roguelike-cardgame/AGENTS.md`
- `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`

## Fronteiras de escrita

- somente `Projetos/draxos-roguelike-cardgame/`
- nenhum UID, arquivo global, outro projeto, remoto, publicacao ou mudanca de produto

## Plano de commits e validacao

- coordenacao local e gates v3;
- curadoria documental e routers;
- QA e baseline de divida;
- schema QA, links, docs locais, FastSuite e Runtime integral duas vezes sem side effects.

## Hard stops e handoff

Parar diante de conflito semantico, diff gerado inesperado, cena/binario ambiguo, segredo, remoto, retomada ou nova decisao humana. Entregar commits rebased e arvore limpa ao coordenador global.

## Resultado tecnico

- documentacao viva curta e alinhada ao `PAUSADO_TEMPORARIO`;
- snapshot detalhado pre-cutover preservado na historia da Track 02;
- resumo duplicado removido do HEAD com recuperacao pelo Git;
- Fast e Runtime preservam `226/226` testes, `1.975` asserts e rota `29/29`;
- segunda execucao Runtime deixa o mesmo estado Git vazio;
- gates humanos continuam pendentes em `Kanban/Review/`;
- nenhum produto, tuning, promocao, remoto ou publicacao executado.
