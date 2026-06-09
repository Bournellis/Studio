# DraxosMobile - Doc Drift Cleanup v1

- Data: 2026-06-09
- Agente: Codex + subagentes
- Branch: `codex/draxos-mobile/doc-drift-cleanup-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--doc-drift-cleanup-v1`
- Status: DONE

## Objetivo

Corrigir drift documental vivo do DraxosMobile sem alterar codigo/runtime,
mantendo `BOSQUE_BOOTSTRAP_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA` como marcador
formal e registrando que o playtest humano inicial do Bosque Bootstrap Authority
v1 foi reportado OK por Fabio em 2026-06-09.

## Verdade operacional consolidada

- Pacote atual: `Bosque Bootstrap Authority v1`.
- Release root canonico: `internal-alpha/v0-bosque-bootstrap-authority-v1-20260609-ba99e70`.
- Portal oficial: `https://draxos-mobile-internal-alpha.pages.dev/`.
- Web direto: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`.
- Evidencia: `https://0123894f.draxos-mobile-internal-alpha.pages.dev`.
- Versao: `0.0.15-alpha.0`, version code `15`, minimum supported version code `13`.
- Playtest humano inicial: reportado OK por Fabio em 2026-06-09.
- Foco imediato: drift documental corrigido/consolidado; bugs futuros voltam ao fluxo normal se aparecerem.

## Arquivos alterados

- Coordenacao/canon: `AGENTS.md`, `canon/canon-brief.md`, `08_Coordenacao_Agentes/Prioridades_Estudio.md`, `08_Coordenacao_Agentes/Estado_Atual.md`, `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`, `Projetos/README.md`.
- Docs locais vivos: `Projetos/draxos-mobile/README.md`, `Projetos/draxos-mobile/AGENTS.md`, `Projetos/draxos-mobile/implementation/current-status.md`, `Projetos/draxos-mobile/docs/agent-operating-manual.md`, `Projetos/draxos-mobile/docs/documentation-index.md`, `Projetos/draxos-mobile/docs/multi-agent-workflow.md`.
- Produto/design/arena: `Projetos/draxos-mobile/docs/product-vision.md`, `Projetos/draxos-mobile/docs/product-brief.md`, `Projetos/draxos-mobile/docs/design-pending.md`, `Projetos/draxos-mobile/docs/pve-arena-v1.md`, `Projetos/draxos-mobile/docs/minigames/autobattler.md`, `Projetos/draxos-mobile/docs/minigames/openworld.md`.
- Contratos/portal: `Projetos/draxos-mobile/docs/contracts/update-manifest.md`, `Projetos/draxos-mobile/docs/contracts/api-endpoints.md`, `Projetos/draxos-mobile/portal/internal-alpha/manifest.example.json`, `Projetos/draxos-mobile/portal/internal-alpha/index.html`.

## Decisoes aplicadas

- Nao foi criado status novo `PLAYTEST_OK`; o status formal segue publicado.
- Pacotes anteriores foram preservados como historico/baseline, nao reescritos.
- `Kanban/Done`, `Handoffs`, reports antigos, tracks historicas e `internal-alpha-v0*` foram preservados fora do escopo.
- O portal visivel passou a usar o root Bootstrap para Web/APK/PC; o manifest example e os contratos continuam documentando o fallback/default real configurado no backend.
- `implementation/current-status.md` foi compactado para snapshot decisorio, com logs longos movidos para referencia historica externa.

## Validacao

- `git diff --check`: PASS.
- `validate_foundation.ps1 -Profile DocsOnly`: PASS.
- `manifest.example.json` parseado com `ConvertFrom-Json`: PASS.
- Varredura de drift vivo: sem ocorrencias restantes de pacote antigo como atual, `0.0.1-alpha.0`, placeholders `*_PENDING_T03_P17` ou proximo passo antigo de playtest em docs vivos do DraxosMobile.
- Ocorrencias restantes de pacotes antigos existem apenas como historico preservado, default backend documentado ou lista de termos de roteamento.
