# Governança v2 local — DraxosMobile

## Metadata

- closure_protocol: `agent_local_merge_v3`
- technical_status: `ready_for_merge`
- human_gate_required: `no`
- human_gate_status: `not_required`
- human_gate_scope: `none; os gates de produto existentes permanecem independentes`
- human_gate_evidence: `n/a`
- publication_status: `not_authorized`
- blocking_decision: `none`
- execution_mode: `delegated_agent`
- delegated_scope: `coordenação, documentação, QA e baseline de dívida locais`
- branch: `codex/draxosmobile/governanca-v2`
- worktree: `D:\Estudio-worktrees\draxosmobile--codex--governanca-v2`
- base_ref: `main@23f0da73`
- merge_status: `ready_for_merge`
- worktree_status: `open`
- branch_cleanup: `pending`
- validation_tier: `Build`
- validation_result: `pass; FastSuite 2x, Runtime 2x and Build 2x with identical tracked snapshots`
- global_sync_needed: `yes`

## Objetivo

Migrar o DraxosMobile para coordenação local-first, documentos vivos curtos, QA legível por máquina e dívida técnica sem crescimento, preservando a autoridade server-side e o resultado `ARENA_CORE_NOT_PROVEN`.

## Escopo previsto

- `08_Coordenacao/`: ciclo local, triagem, card v3, handoffs e baseline de dívida.
- `qa/`: manifesto tipado e índice humano com jornadas e gates.
- `AGENTS.md`, `README.md`, `implementation/current-status.md` e `docs/documentation-index.md`: autoridade e roteamento compactos.
- `docs/release-history.md` continua sendo a única linhagem de publicações; relatórios fechados ficam históricos e procedimentos ficam runbooks.

## Validação prevista

- Schema e correspondência exata dos IDs de QA.
- `DocsOnly`, `ServerQuick`, GUT curto, `ClientQuick`, `ModePlatform` e `ReleaseDryRun`, apenas locais.
- Perfis proporcionais executados duas vezes com snapshot Git antes/depois.
- UTF-8, links, budgets, `git diff --check` e árvore limpa.

## Resultado técnico

- FastSuite 2x: DocsOnly e ServerQuick verdes; GUT selecionado `13/13`, `170` asserts.
- Runtime 2x: cliente `287/287`, `4.208` asserts; servidor `128 + 23`; modo/plataforma `49`.
- Build 2x: `ReleaseDryRun` verde e limitado a plano local; nenhuma publicação ou mutação externa.
- Todos os snapshots rastreados antes/depois foram idênticos.
- Rebase limpo em `main@23f0da73`; validação pós-rebase proporcional executada antes do handoff.

## Hard stops

- Remoto, banco remoto, dispositivo físico, publicação, deploy ou credencial.
- Mudança de prioridade, produto, conteúdo, economia, tuning ou PVP.
- Decisão humana sobre Arena proof, visual ou release.
- Alteração fora de `Projetos/draxos-mobile/`, incluindo canon, globais, `.gitignore` e UIDs.
