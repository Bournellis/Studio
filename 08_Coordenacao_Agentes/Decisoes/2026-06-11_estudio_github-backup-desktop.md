# Decisao: Backup Remoto No GitHub E Fluxo Com GitHub Desktop

## Metadata

- data: `2026-06-11`
- decisor: `Usuario`
- projeto: `estudio`
- prioridade_portfolio: `-`

## Contexto

O estudio existia somente em `D:\` (937 commits sem remote) - risco existencial apontado pela avaliacao externa de 2026-06-10. Durante a configuracao, dois problemas apareceram: processos simultaneos escrevendo no mesmo `.git` corromperam `index` e `config`, e o nome errado do repo no remote (`estudio` vs `Studio`) causou loop de login no Git Credential Manager.

## Decision

- Remote oficial: `origin` = `https://github.com/Bournellis/Studio.git` (privado).
- Fluxo de versionamento do Fabio: GitHub Desktop como painel de revisao, fetch e push.
- Autenticacao: Git Credential Manager com login via navegador (sem senha de conta, sem PAT manual).
- Rotina: apos merge em `main`, `git push origin main` (agente executor) ou botao `Push origin` do Desktop (Fabio). Zerar commits pendentes ao encerrar o dia.
- Commits continuam sendo feitos por quem executa a task; o Desktop nao e usado para commit/stage/discard durante tasks de agentes (regra do escritor unico).

## Alternatives Considered

- Continuar sem remote: rejeitado; defeito de disco apagaria o estudio.
- `gh` CLI no Windows: valido, mas o Desktop atende melhor o perfil visual do fluxo.

## Impact

Backup continuo do estudio inteiro, historico navegavel no GitHub e base pronta para CI futura.

## Review When

Se o estudio adotar CI/CD, repos separados por projeto ou colaboradores externos.
