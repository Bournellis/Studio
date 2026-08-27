# Decisao Historica: Teste De Push Git Nao Interativo Para Agentes

> Status: registro historico dos testes, superado por `2026-08-27_estudio_git_push_seguro_delegado_codex.md`. O corpo abaixo nao e a regra vigente.

## Metadata

- data: `2026-06-14`
- decisor: `Usuario`
- projeto: `estudio`
- prioridade_portfolio: `-`

## Contexto

Fabio pediu reavaliacao do fluxo de push porque algumas tentativas do agente abriram janela/login do Git Credential Manager, enquanto outras pareciam funcionar quando o GitHub Desktop estava logado. O objetivo era descobrir se existia um caminho confiavel para push por agente sem abrir navegador, sem login interativo e sem PAT em prompts, logs ou arquivos.

Testes em `D:\Estudio` em 2026-06-14:

- `gh` nao esta instalado no PATH; portanto GitHub CLI/OAuth nao e o caminho operacional deste Windows.
- O CLI do GitHub Desktop (`github`) so suporta `open` e `clone`; nao existe comando suportado de push pela UI.
- `git push --dry-run origin main` com `GCM_INTERACTIVE=Never` e `GIT_TERMINAL_PROMPT=0` falhou com credencial ausente, sem abrir navegador/login.
- `git push origin main` com as mesmas guardas tambem falhou com credencial ausente, sem abrir navegador/login.
- `desktop-askpass-trampoline.exe` exige `DESKTOP_PORT`, uma variavel interna de processos filhos do Desktop; nao e um contrato publico para automacao de agente.

## Decision

- Teste concluido: o caminho nao interativo falha limpo neste Windows, mas nao fornece credencial para o agente.
- Decisao final posterior: manter rede Git remota somente com Fabio pelo GitHub Desktop.
- Agentes nao devem executar `git push`, `git fetch`, `git pull`, `gh auth login`, browser login flows nem PAT/token setup para sincronizacao remota.
- O fechamento de trabalho deve declarar `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.

## Alternatives Considered

- `git push` normal via HTTPS: rejeitado porque pode acionar GCM/browser interativo.
- GitHub CLI: indisponivel neste Windows atual (`gh` ausente).
- Reaproveitar helper interno do GitHub Desktop: rejeitado porque depende de `DESKTOP_PORT` interno e nao documentado como API de automacao.
- PAT/token manual: rejeitado por risco de vazamento.

## Impact

O teste confirmou que o Desktop logado nao equivale a credencial de push disponivel para o agente. Para reduzir risco e ambiguidade operacional, Fabio fica como unico executor de `push`, `fetch` e `pull`.

## Review When

Revisar somente se Fabio decidir mudar a politica de rede Git remota, instalar um fluxo oficial nao interativo e registrar nova decisao.
