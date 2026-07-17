# Handoff: DraxosMobile Governance v2.1 Mobile QA

## Metadata

- from: `Codex - DraxosMobile project agent`
- to: `Codex - Governance v2.1 lead`
- date: `2026-07-17`
- projeto: `DraxosMobile`
- coordination_scope: `project_local`
- closure_protocol: `agent_local_merge_v3`
- technical_status: `complete`
- human_gate_required: `no`
- human_gate_status: `not_required`
- human_gate_scope: `existing Arena, visual, physical QA and release gates remain independent`
- human_gate_evidence: `n/a`
- publication_status: `not_authorized`
- blocking_decision: `none`
- execution_mode: `multi_agent`
- delegated_scope: `all writes under Projetos/draxos-mobile`
- branch: `codex/draxosmobile/v21-mobile-qa`
- worktree: `D:\Estudio-worktrees\draxosmobile--codex--v21-mobile-qa`
- base_ref: `codex/estudio/governanca-v21@a1f38d3e`
- merge_status: `merged_into_governance_v21@edcd0fa8`
- worktree_status: `removed`
- branch_cleanup: `deleted`
- validation_tier: `DocsOnly`
- validation_result: `post-merge 6/6 tests, QA contract and git diff PASS; tracked snapshot unchanged`
- global_sync_needed: `no`

## Resultado

A frente local entrega QA mobile por intenção, matriz Android derivada do candidato, gaps de acessibilidade explícitos e recibos imutáveis por hash.

O helper não constrói nem publica: prepara e verifica registros locais, em dry-run por padrão.

Promoção significa somente um registro local após decisão humana resolvida. Ela exige qualificações aprovadas `android_check` e `physical_gate` sobre o mesmo artefato. `PhysicalGate` e autorização de promoção rejeitam identidades de agente.

## Commits para integração

1. `29b0133f` — registro operacional local.
2. `11889d2b` — helper, schemas e testes.
3. `ebe736ba` — contratos, manifesto/índice QA e roteamento.
4. `edcd0fa8` — handoff e card Done integrados pelo líder.

## Evidência

- `python -m unittest discover`: `6/6` verde; snapshot sem resíduos.
- Três schemas Draft 2020-12: meta-validação verde.
- QA manifest/index: `PASS`, correspondência exata de runners e capabilities.
- DraxosMobile `DocsOnly`: `PASS`, snapshot rastreado idêntico.
- Links locais, budgets dos arquivos tocados e `git diff --check`: `PASS`.
- Wrapper Estudio: QA, UIDs, storage, evidence, dashboard, links e docs-health verdes.
- Única falha do wrapper: `WORKTREE_OVERLAP` esperado entre as worktrees v2.1 paralelas nos arquivos globais do programa; nenhum overlap envolve arquivo editado por esta frente.

## Limitações e gates preservados

- O preset atual não fixa `minSdk` ou `targetSdk`; o candidato deve extrair e registrar os valores reais antes de qualquer matriz.
- Nenhum emulador, APK, aparelho físico, export ou serviço remoto foi usado.
- Contraste, reduced motion, locale, safe area do SO, lifecycle Android e haptics permanecem gaps registrados, não features aprovadas.
- Arena proof, tuning, economia, PVP, direção visual, QA física, promoção real e publicação continuam humanos e fora desta tarefa.

## Fechamento pelo líder

Os quatro commits foram integrados em `codex/estudio/governanca-v21`; a validação pós-merge passou e a worktree/branch delegada foi removida. Nenhum push ou publicação está autorizado.
