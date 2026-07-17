# Governança v2.1 — QA mobile por intenção

## Metadata

- closure_protocol: `agent_local_merge_v3`
- technical_status: `complete`
- human_gate_required: `no`
- human_gate_status: `not_required`
- human_gate_scope: `nenhum novo; Arena proof, QA física, visual final e promoção permanecem gates independentes`
- human_gate_evidence: `n/a`
- publication_status: `not_authorized`
- blocking_decision: `none`
- execution_mode: `delegated_agent`
- delegated_scope: `contratos, schemas, helper e roteamento de QA mobile locais ao DraxosMobile`
- branch: `codex/draxosmobile/v21-mobile-qa`
- worktree: `D:\Estudio-worktrees\draxosmobile--codex--v21-mobile-qa`
- base_ref: `codex/estudio/governanca-v21@4d0a3aad`
- merge_status: `pending_governance_lead`
- worktree_status: `open_for_lead_integration`
- branch_cleanup: `pending_after_merge`
- validation_tier: `DocsOnly`
- validation_result: `local pass; Studio wrapper blocked only by expected concurrent-worktree overlap; tracked snapshots unchanged`
- global_sync_needed: `no; o coordenador global da Governança v2.1 mantém o closeout do programa`

## Objetivo concluído

DraxosMobile agora possui contratos locais para `DocsCheck`, `Iterate`, `VisualCheck`, `AndroidCheck`, `CandidatePrepare` e `PhysicalGate`, sem importar aparelhos ou políticas de outro workspace.

A matriz Android deriva APIs do APK candidato, os gaps de acessibilidade estão explícitos e o fluxo de candidato/qualificação/promoção local preserva o mesmo SHA256 sem rebuild ou publicação.

## Entregas

- Contrato de intenções e matriz de emuladores/API orientada ao produto.
- Baseline de touch, contraste, reduced motion, locale, safe areas, lifecycle e haptics.
- Três schemas v1 e helper tipado, dry-run por padrão, para recibos append-only.
- Seis testes de imutabilidade, alteração de artefato/evidência e gates humanos.
- Manifesto e índice QA com IDs exatamente alinhados; triagem e índice local atualizados.

## Commits técnicos

- `bbd2f2ed` — helper, schemas e testes de recibos imutáveis.
- `0f6da8ba` — contratos mobile, QA manifest/index e roteamento local.

## Validação

- Helper: `6/6` testes `unittest` verdes, sem `__pycache__` com `PYTHONDONTWRITEBYTECODE=1`.
- Schemas: três documentos Draft 2020-12 meta-validados.
- QA manifest/index: `PASS`, IDs exatos.
- DraxosMobile `DocsOnly`: `PASS`; snapshot rastreado preservado.
- Links locais: `PASS`, `14` arquivos e `14` links.
- Linhas Markdown alteradas: nenhuma acima de `240` caracteres; helper com `698` linhas.
- Estudio `DocsOnly -Project DraxosMobile`: oito passos verdes e snapshot preservado; falhou somente no detector de overlap das worktrees paralelas v2.1.
- `git diff --check`: `PASS`.

## Limites preservados

Nenhum APK, export, emulador, aparelho físico, rebuild, remote, deploy ou publicação foi executado. Nenhuma API Android foi declarada suportada sem candidato, e nenhum gate humano ou decisão de produto foi aprovado.
