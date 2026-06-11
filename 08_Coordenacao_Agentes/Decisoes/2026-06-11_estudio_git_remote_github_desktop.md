# Decisao: Git Local Para Agentes E Rede Pelo GitHub Desktop

## Metadata

- data: `2026-06-11`
- decisor: `Usuario`
- projeto: `estudio`
- prioridade_portfolio: `P2_IMPLEMENTACAO`

## Contexto

A tentativa de sincronizacao inicial por agente confirmou uma falha operacional: `git push origin main` via HTTPS acionou o Git Credential Manager em prompt interativo de login, travando a sessao sem TTY confiavel. O estudio precisa manter backup no GitHub, mas agentes nao devem bloquear em autenticacao interativa nem tentar resolver divergencias remotas automaticamente.

## Decision

- Agentes fazem git LOCAL apenas: `commit`, `merge`, `branch`, `worktree`, `restore`, `status`, `diff`, `log` e verificacoes locais.
- `push`, `fetch` e `pull` sao exclusivos de Fabio via GitHub Desktop.
- O ritual de fechamento de track termina com a linha `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin` antes de `WORKTREE_VERIFIED`.
- Se o GitHub Desktop detectar divergencia, pull necessario ou historico diferente, Fabio chama Claude antes de qualquer `pull`, `rebase` ou resolucao.
- Credenciais, tokens e PATs nunca entram em arquivos do repo, prompts ou logs.

## Alternatives Considered

- Agentes executarem `git fetch` + `git push origin main`: rejeitado porque o Git Credential Manager travou em prompt interativo.
- Configurar token/PAT para agente: rejeitado para evitar vazamento em logs, prompts ou repo.
- Fabio usar apenas linha de comando: rejeitado porque o GitHub Desktop da visibilidade melhor para fetch/push e divergencias.

## Impact

O fluxo fica dividido: Codex/Claude preservam historico local limpo e verificavel; Fabio faz a sincronizacao remota visualmente pelo GitHub Desktop. O remoto pode ficar pendente ate Fabio clicar `Push origin`, por isso todo fechamento deve declarar explicitamente o push pendente.

## Review When

Revisar se houver autenticacao nao interativa confiavel para agentes, instalacao oficial do GitHub CLI autenticado, CI/CD exigindo push automatizado, ou mudanca no fluxo de backup remoto.
