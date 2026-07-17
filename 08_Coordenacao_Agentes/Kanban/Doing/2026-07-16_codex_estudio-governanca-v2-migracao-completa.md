# Multi-Agent Doing: Governanca Estudio v2 - migracao completa

## Metadata

- id: `2026-07-16_estudio-governanca-v2`
- data: `2026-07-16`
- agente: `Codex`
- projeto: `estudio`
- prioridade_portfolio: `portfolio-preserved`
- coordination_scope: `global_governance`
- closure_protocol: `agent_local_merge_v3`
- technical_status: `in_progress`
- human_gate_required: `no`
- human_gate_status: `not_required`
- human_gate_scope: `none`
- human_gate_evidence: `n/a`
- publication_status: `not_authorized`
- blocking_decision: `none`
- execution_mode: `multi_agent`
- delegated_scope: `tooling global; reparo rpg-turnos; coordenacao e QA por projeto; revisao independente`
- branch: `codex/estudio/governanca-v2`
- worktree: `D:\Estudio-worktrees\estudio--codex--governanca-v2`
- base_ref: `main@d69456d8`
- merge_status: `pending`
- worktree_status: `open`
- branch_cleanup: `pending`
- validation_tier: `FullLocal`
- validation_result: `pending`
- global_sync_needed: `yes`

## Objetivo

Migrar o Estudio para governanca local-first, canon com fronteiras explicitas, QA verificavel, tooling deterministico e fechamento autonomo local, preservando identidade, prioridade e gates humanos de cada projeto.

## Base lida

- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`
- `canon/README.md`
- `canon/canon-brief.md`
- AGENTS/status locais dos projetos conforme o escopo delegado
- runbooks e governanca de `D:\Minigame Studio` somente como referencia read-only

## Escopo autorizado

- Governanca global, gates v3, templates, routers e portfolio sync.
- Schemas, checkers, StudioDoctor, orquestrador, FastSuite, CI e fechamento de worktrees.
- Coordenacao local, QA manifest/index e slimming documental nos seis projetos oficiais.
- Reparo de integridade do RPG Turnos sem retomada de produto.
- Separacao do canon compartilhado e do canon do RPG Isometrico.
- Versionamento de UIDs, health allowlist e politica prospectiva de evidencias/storage.
- Atualizacao das skills locais afetadas pelo cutover.

## Fora do escopo

- Mudanca de prioridade, feature, tuning, conteudo ou direcao de produto.
- Aprovacao de feel, visual, dispositivo, Arena proof ou outro gate humano.
- Push, fetch, pull, deploy, release, banco remoto, dispositivo fisico ou secret.
- Refatoracao em massa de arquivos grandes.

## Fronteiras de escrita multiagente

- Coordenador: arquivos globais, canon, integracao, portfolio sync e skills externas.
- Tooling: `tools/`, `.github/` e fixtures de teste; sem docs/projetos.
- RPG Turnos integrity: apenas runtime/testes/gerados/status historico local do projeto.
- Agentes de projeto: apenas o respectivo `Projetos/<nome>/`; nenhum hot file global.

## Plano de commits

- `docs(governance): register governance v2 program`
- `tools(governance): add machine-readable contracts and safety checks`
- `fix(rpg-turnos): restore p20 integrity and validation`
- `docs(governance): adopt local-first authority and gates v3`
- `docs(canon): separate shared lore from rpg-isometrico product canon`
- commits documentais/QA/UID por projeto
- `ci: add local-only studio validation`
- `docs(portfolio): sync governance v2 baselines`

## Validacao

- `tools/studio_doctor.ps1 -Mode Core -Project AllOfficial`
- `tools/validate_estudio.ps1 -Profile DocsOnly -Project AllOfficial`
- FastSuite/Runtime proporcionais por projeto, sempre com clean-tree guard
- testes unitarios dos checkers
- `git diff --check`
- `git status --short`

## Hard stops

- Conflito semantico em historia unica, diff inesperado de gerador, cena/binario ambiguo, segredo, remoto/publicacao, mudanca de produto/prioridade ou decisao humana nova.

## Proximo handoff

Integracao local por ondas, validacao pos-merge, cleanup de todas as worktrees e entrega final com `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
