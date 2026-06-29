# Documentation Index - Estudio

- Ultima atualizacao: `2026-06-29`
- Tipo: roteador global de documentacao.
- Este arquivo nao e fonte de estado operacional; ele aponta para as fontes vivas.

## Fontes vivas globais

- `Prioridades_Estudio.md` - foco, prioridade, status aceitos e trabalho permitido por projeto.
- `Estado_Atual.md` - snapshot vivo curto por projeto e proximo passo atual.
- `FABIO_DASHBOARD.md` - sintese humana curta para Fabio decidir foco/QA sem navegar como agente; fontes vivas vencem.
- `FABIO_DASHBOARD.html` - visualizacao local em navegador do painel Fabio.

## Contrato operacional para agentes

- `../AGENTS.md` - regra global de agentes, worktrees, leitura, canon, Git local e hard stops.
- `../README.md` - mapa estavel do workspace; nao carrega estado de projeto.
- `../Projetos/README.md` - registro estavel de projetos, identidades e entrypoints.
- `Templates/` - templates oficiais de coordenacao.
- `Decisoes/` - decisoes de produto, arquitetura e processo.
- `Kanban/` - cards de trabalho e historico operacional.
- `Handoffs/` - transicoes entre agentes/rodadas.
- `Docs_Status_Slimming_Plan.md` - plano para reduzir snapshots locais longos sem apagar historico.
- `Lifecycle_Cleanup_Audit_2026-06-29.md` - auditoria read-only de branches/worktrees para limpeza futura.

## Canon e direcao compartilhada

- `../canon/canon-brief.md` - leitura rapida do canon compartilhado.
- `../canon/product/product-vision.md` - visao compartilhada de produto.
- `../canon/design/game-design-document.md` - GDD compartilhado.
- `../canon/design/progression-design.md` - progressao compartilhada.
- `../canon/architecture/shared-architecture.md` - arquitetura compartilhada.
- `../canon/architecture/game-mode-standard.md` - padrao de modos.
- `../canon/roadmap/evolution-roadmap.md` - roadmap compartilhado.
- `../canon/platform/steam-platform.md` - direcao de plataforma.

## Projetos ativos/consultaveis

Use `../Projetos/README.md` para roteamento inicial. Depois leia o `AGENTS.md` e `implementation/current-status.md` do projeto alvo.

- `../Projetos/JogoDaCopa/AGENTS.md`
- `../Projetos/JogoDaCopa/implementation/current-status.md`
- `../Projetos/JogoDaCopa/docs/documentation-index.md`
- `../Projetos/draxos-mobile/AGENTS.md`
- `../Projetos/draxos-mobile/implementation/current-status.md`
- `../Projetos/draxos-mobile/docs/documentation-index.md`
- `../Projetos/FpsPlayground/AGENTS.md`
- `../Projetos/FpsPlayground/implementation/current-status.md`
- `../Projetos/FpsPlayground/docs/documentation-index.md`
- `../Projetos/draxos-roguelike-cardgame/AGENTS.md`
- `../Projetos/draxos-roguelike-cardgame/implementation/current-status.md`

## Validadores e higiene documental

- `../tools/check_doc_drift.ps1` - garante que pointer docs nao carreguem estado e que snapshots fiquem compactos.
- Validacoes locais de projeto vivem nos `AGENTS.md` e docs de cada projeto.
- Para trabalho documental global, use no minimo:
  - `git diff --check`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./tools/check_doc_drift.ps1`

## Regras de uso

- Nao coloque status operacional, URLs de release, version codes, markers ou proximos passos neste indice.
- Se houver conflito, vencem `Prioridades_Estudio.md`, `Estado_Atual.md` e o `implementation/current-status.md` local do projeto alvo.
- Este indice e um mapa, nao um diario nem historico.
