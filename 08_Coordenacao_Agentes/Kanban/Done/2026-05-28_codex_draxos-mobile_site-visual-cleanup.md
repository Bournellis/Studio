# DraxosMobile - Site Visual Cleanup

- Data: `2026-05-28`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/site-visual-cleanup`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--site-visual-cleanup`
- Projeto: `Projetos/draxos-mobile/`
- Status: concluido
- Objetivo: limpar a primeira tela do portal Internal Alpha, removendo a barra superior e textos operacionais redundantes sem remover funcoes.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`

## Arquivos Alterados

- `Projetos/draxos-mobile/portal/internal-alpha/index.html`
- `Projetos/draxos-mobile/portal/internal-alpha/README.md`

## Resultado

- Barra superior visivel removida do portal.
- Hero passou a carregar a identidade curta `Draxos Alpha` e CTAs principais.
- Home simplificada em atalhos operacionais curtos.
- Detalhes tecnicos concentrados em Status e rodape.
- `setSessionChip()` ficou seguro para elemento ausente.

## Validacao

- `publish_internal_alpha.ps1 -Mode Package -StaticSiteBaseUrl "https://draxos-mobile-internal-alpha.pages.dev" -PublicDownloads`: passou usando artefatos reais existentes e variaveis publicas de ambiente.
- `build_cloudflare_pages_package.ps1`: passou, gerando `build/internal-alpha/cloudflare-pages` e ZIP.
- Busca por placeholders pendentes no pacote Cloudflare: sem ocorrencias.
- Navegador local desktop: sem overflow horizontal, tabs/CTAs funcionais, sem topbar/session chip.
- Navegador local mobile `390x844`: sem overflow horizontal, hero/tabs/CTAs acessiveis.
- Grimorio: 74 cards, contagens `[8,20,11,9,6,6,6,8]`.
- Status: manifest remoto carregado com linhas de schema, canal, versao, minimo e links.
- Rotas locais: `/`, `/portal/index.html`, `/web` e `/web/index.html` retornaram `200`.
- `git diff --check`: passou.
