# Governança v2.1 — QA mobile por intenção

## Metadata

- closure_protocol: `agent_local_merge_v3`
- technical_status: `in_progress`
- human_gate_required: `no`
- human_gate_status: `not_required`
- human_gate_scope: `nenhum novo; Arena proof, QA física, visual final e promoção permanecem gates independentes`
- human_gate_evidence: `n/a`
- publication_status: `not_authorized`
- blocking_decision: `none`
- execution_mode: `delegated_agent`
- delegated_scope: `contratos e roteamento de QA mobile locais ao DraxosMobile`
- branch: `codex/draxosmobile/v21-mobile-qa`
- worktree: `D:\Estudio-worktrees\draxosmobile--codex--v21-mobile-qa`
- base_ref: `codex/estudio/governanca-v21@4d0a3aad`
- merge_status: `pending`
- worktree_status: `open`
- branch_cleanup: `pending`
- validation_tier: `DocsOnly`
- validation_result: `pending`
- global_sync_needed: `no; o coordenador global da Governança v2.1 mantém o closeout do programa`

## Objetivo

Definir QA mobile por intenção, matriz de emuladores/API, recibos imutáveis de candidato e promoção por hash e baseline de gaps de acessibilidade sem executar export, dispositivo físico, publicação ou decisão de produto.

## Escopo previsto

- Criar contratos locais sob `qa/mobile/` para `DocsCheck`, `Iterate`, `VisualCheck`, `AndroidCheck`, `CandidatePrepare` e `PhysicalGate`.
- Adaptar a matriz ao produto e aos contratos locais do DraxosMobile, sem importar aparelhos ou políticas do Minigame Studio.
- Atualizar `qa/qa_manifest.json` e `qa/QA_INDEX.md` usando somente runners existentes e capacidades `manual`/`gap` quando não houver execução local.
- Atualizar o índice/triagem local apenas se necessário para roteamento e preservação dos gates.

## Arquivos pretendidos

- `qa/mobile/**`
- `qa/qa_manifest.json`
- `qa/QA_INDEX.md`
- `08_Coordenacao/documentation-index.md`
- `08_Coordenacao/TRIAGE.md`
- este card local e o handoff/registro de fechamento correspondente

## Validação prevista

- Validação JSON e schema v1 do manifesto.
- Correspondência exata dos IDs do manifesto e do QA Index.
- `DocsOnly` local/Estudio quando disponível.
- Links locais, `git diff --check` e snapshot Git sem efeitos colaterais.

## Hard stops

- Nenhum Android real, dispositivo físico, export, rebuild, deploy, remoto ou publicação.
- Nenhuma feature, tuning, conteúdo, prioridade ou aprovação de Arena.
- Nenhum segredo, keystore, credencial ou dado de aparelho real em documentação ou recibos.
- Nenhuma edição fora de `Projetos/draxos-mobile/`.
