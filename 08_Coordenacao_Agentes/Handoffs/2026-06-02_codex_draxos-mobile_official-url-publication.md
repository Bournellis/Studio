# DraxosMobile - Official URL Publication Hotfix

Data: 2026-06-02
Agente: Codex
Branch: `codex/draxos-mobile/official-url-publication`
Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--official-url-publication`

## Objetivo

Investigar por que `https://draxos-mobile-internal-alpha.pages.dev/` nao aparentou refletir a publicacao integrada App + Arena + Bosque e, se o problema for roteamento/publicacao da URL oficial, ajustar pacote, documentos e publicar novamente.

## Contexto lido

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `canon/canon-brief.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/tools/build_cloudflare_pages_package.ps1`

## Arquivos pretendidos

- `Projetos/draxos-mobile/tools/build_cloudflare_pages_package.ps1`, se houver falha de raiz/roteamento.
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`, se a URL oficial precisar ser documentada como entrada canonica.
- `Projetos/draxos-mobile/implementation/current-status.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Validacao planejada

- Comparar raiz oficial, `/portal/index.html` e `/web/index.html` contra preview hash e producao.
- Consultar Cloudflare Pages deployments via Wrangler.
- Reempacotar Cloudflare Pages se necessario.
- Publicar no projeto `draxos-mobile-internal-alpha` com branch de producao correta.
- Validar raiz oficial e preview pos-publicacao.
- Rodar validacao documental local aplicavel.

## Handoff

Concluido e registrado em `08_Coordenacao_Agentes/Kanban/Done/2026-06-02_codex_draxos-mobile_official-url-publication.md`.

Resultado: o pacote Pages integrado ja estava em Production/main/source `99304ed`, mas o manifest/docs ainda apontavam `portal_url` para `/portal/index.html`. O hotfix republished `release` com `portal_url=https://draxos-mobile-internal-alpha.pages.dev/`, manteve Web direto em `/web/index.html`, preservou release root `internal-alpha/v0-integrated-app-arena-bosque-20260602-99304ed` e confirmou Cloudflare Access anonimo como esperado no dominio oficial.
