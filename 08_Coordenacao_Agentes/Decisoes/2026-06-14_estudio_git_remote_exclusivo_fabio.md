# Decisao: Rede Git Remota Exclusiva De Fabio

## Metadata

- data: `2026-06-14`
- decisor: `Usuario`
- projeto: `estudio`
- prioridade_portfolio: `-`
- status: `superseded`
- superseded_by: `2026-08-27_estudio_git_push_seguro_delegado_codex.md`

## Contexto

Em 2026-06-14, Codex auditou tentativas anteriores de push e confirmou que o GitHub Desktop esta logado, mas nao expoe um comando CLI de push nem compartilha credencial com o `git.exe` do agente. O teste com `GCM_INTERACTIVE=Never` e `GIT_TERMINAL_PROMPT=0` falhou sem abrir navegador, o que e seguro, mas nao resolve a operacao.

Fabio decidiu manter o fluxo simples: agentes trabalham localmente e Fabio faz a sincronizacao remota.

## Decision

- Agentes fazem git local apenas: `status`, `diff`, `log`, `branch`, `worktree`, `add`, `commit`, `merge` e validacoes locais dentro do escopo da tarefa.
- `push`, `fetch` e `pull` sao exclusivos de Fabio via GitHub Desktop.
- Agentes nao executam `git push`, `git fetch`, `git pull`, `gh auth login`, fluxo de login no navegador, configuracao de PAT/token ou automacao do botao `Push origin`.
- Fechamentos de track devem declarar: `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
- Se houver divergencia remota, necessidade de pull/rebase ou conflito no Desktop, Fabio chama um agente antes de resolver.

## Alternatives Considered

- Push nao interativo por agente: testado; falhou por credencial ausente e ainda criaria excecao operacional.
- Usar CLI do GitHub Desktop: rejeitado porque so suporta `open` e `clone`.
- Instalar/autenticar `gh`: fora do fluxo atual e pode reabrir login interativo.
- PAT/token manual: rejeitado por risco de vazamento.

## Impact

O processo volta a ser previsivel: agentes deixam commits locais e evidencias; Fabio revisa e empurra pelo GitHub Desktop. Reduz risco de login travado, credencial em prompt/log e escrita concorrente no `.git`.

## Review When

Revisar apenas se Fabio quiser mudar explicitamente o modelo de sincronizacao remota ou adotar um fluxo oficial nao interativo com credenciais provisionadas fora do repositorio.
