# Contrato de intenções de QA mobile

## Metadata

- status: `living`
- authority: `technical_contract`
- last_verified: `2026-07-17`
- review_when: `a mobile QA lane, runner, artifact flow or human gate changes`
- supersedes: `ad hoc mobile validation selection`
- superseded_by: `none`

Cada tarefa declara exatamente uma intenção primária. Uma intenção limita o trabalho; ela não concede autoridade para a intenção seguinte.

## Intenções

| Intenção | Entrada mínima | Ações permitidas | Saída exigida |
|---|---|---|---|
| `DocsCheck` | worktree e escopo documental | schema/IDs, links, metadata, DocsOnly e `git diff --check` | relatório local e snapshot Git preservado |
| `Iterate` | source SHA e hipótese técnica estreita | editor/headless, GUT curto, `ClientQuick` e `ServerQuick` proporcionais | testes verdes; nenhuma conclusão visual ou física |
| `VisualCheck` | source SHA, viewport e roteiro | inspeção humana local, captura temporária e comparação em `360x800`, `390x844` e desktop | observações por viewport; visual final continua não aprovado |
| `AndroidCheck` | preset ou candidato identificado | preflight local e, quando já existir APK, emuladores da matriz usando o mesmo SHA256 | resultado por perfil/API; nenhum suporte ou device físico inferido |
| `CandidatePrepare` | commit limpo, validações verdes e autorização local explícita | um export futuro, cálculo de SHA256 e recibo de candidato | artefato imutável + recibo; sem upload, deploy ou publicação |
| `PhysicalGate` | candidato e recibo exatos | instalação e roteiro manual por Fabio/tester em aparelho físico | veredito ligado ao SHA256; sem rebuild, promoção ou publicação implícita |

## Transições seguras

`DocsCheck` e `Iterate` podem repetir. `VisualCheck` e o preflight de `AndroidCheck` podem ocorrer antes de um candidato. A validação de APK em emulador acontece somente depois de `CandidatePrepare`, usando o hash registrado.

`PhysicalGate` consome o mesmo artefato que passou pelo AndroidCheck de candidato. Se o arquivo ou hash divergir, o gate para; não se recompila para “corrigir” a evidência.

## Mapeamento para runners existentes

- `DocsCheck`: `docs_contracts_fast`.
- `Iterate`: `client_gut_short_fast`, `client_quick_runtime` e `server_quick_local` conforme o escopo.
- `VisualCheck`: `client_quick_runtime` é precondição técnica; inspeção permanece manual.
- `AndroidCheck`: `release_dry_run_build` prova apenas preset/plano local; emulador permanece manual.
- `CandidatePrepare`: `release_dry_run_build` é precondição; nenhum runner do manifesto cria artefato. O helper de recibos é local, dry-run por padrão e não é runner.
- `PhysicalGate`: manual, fora de `FullLocal` e de qualquer automação do agente.

## Hard stops

- `CandidatePrepare` não roda em tarefa de docs, iteração ou visual.
- `AndroidCheck` nunca usa aparelho físico ou credencial remota.
- `PhysicalGate` não aprova Arena, tuning, economia, PVP, visual final ou release.
- Promoção e publicação exigem tarefa separada, decisão humana e os guardrails de `../../docs/release-ops-checklist.md`.
