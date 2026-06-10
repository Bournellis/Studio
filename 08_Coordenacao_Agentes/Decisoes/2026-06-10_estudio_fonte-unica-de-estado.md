# Decisao: Fonte Unica De Estado Operacional

## Metadata

- data: `2026-06-10`
- decisor: `Usuario`
- projeto: `estudio`
- prioridade_portfolio: `-`

## Contexto

O snapshot de portfolio vivia duplicado em 6+ documentos (README raiz, CLAUDE.md, canon-brief, AGENTS raiz e locais, Projetos/README) e ja apresentava drift real: pacotes e tracks defasados em varios deles. Cada update exigia tocar 3+ arquivos. Diagnostico completo em `Avaliacao_Estudio_2026-06-10.md`.

## Decision

Estado operacional vive somente em `Prioridades_Estudio.md` (foco/prioridade/trabalho permitido) e `Estado_Atual.md` (snapshot por projeto, max ~12 linhas). Todos os outros documentos de entrada sao ponteiros sem estado: sem markers, URLs de release, version codes ou proximos passos. Historia de pacotes vai para `docs/release-history.md` do projeto. `tools/check_doc_drift.ps1` verifica a regra.

## Alternatives Considered

- Manter replicacao com checklist manual de update (regra anterior): falhou na pratica, drift ocorreu.
- Gerar todos os docs a partir de uma base unica por script: mais robusto, porem mais infra; pode evoluir para isso depois.

## Impact

Updates de status tocam 1-2 arquivos. Agentes leem menos tokens e nao encontram versoes conflitantes. O painel HTML e o canon-brief deixam de carregar estado.

## Review When

Se o drift check gerar falsos positivos frequentes, ou se o estudio adotar geracao automatica de docs.
