# Decisao: Push Git Nao Interativo Para Agentes

## Metadata

- data: `2026-06-14`
- decisor: `Usuario`
- projeto: `estudio`
- prioridade_portfolio: `-`

## Contexto

Fabio pediu reavaliacao do fluxo de push porque algumas tentativas do agente abriram janela/login do Git Credential Manager, enquanto outras pareciam funcionar quando o GitHub Desktop estava logado. O objetivo e permitir push por agente quando Fabio autorizar, sem abrir navegador, sem login interativo e sem PAT em prompts, logs ou arquivos.

Testes em `D:\Estudio` em 2026-06-14:

- `gh` nao esta instalado no PATH; portanto GitHub CLI/OAuth nao e o caminho operacional deste Windows.
- O CLI do GitHub Desktop (`github`) so suporta `open` e `clone`; nao existe comando suportado de push pela UI.
- `git push --dry-run origin main` com `GCM_INTERACTIVE=Never` e `GIT_TERMINAL_PROMPT=0` falhou com credencial ausente, sem abrir navegador/login.
- `git push origin main` com as mesmas guardas tambem falhou com credencial ausente, sem abrir navegador/login.
- `desktop-askpass-trampoline.exe` exige `DESKTOP_PORT`, uma variavel interna de processos filhos do Desktop; nao e um contrato publico para automacao de agente.

## Decision

- Regra padrao continua: agentes fazem git local; Fabio usa GitHub Desktop para revisar e clicar `Push origin`.
- Excecao: quando Fabio pedir explicitamente para o agente fazer push, o agente pode tentar somente o caminho nao interativo abaixo:

```powershell
$env:GCM_INTERACTIVE = 'Never'
$env:GIT_TERMINAL_PROMPT = '0'
git push origin <branch>
```

- Para diagnostico, usar o mesmo ambiente com `git push --dry-run origin <branch>` antes do push real.
- Se o comando falhar por credencial ausente, permissao, divergencia remota ou qualquer pedido de autenticacao, o agente para e declara `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
- Nunca usar `git push` sem essas variaveis, nunca iniciar `gh auth login`, nunca aceitar fluxo de login no navegador e nunca criar/colar PAT.
- O agente pode abrir o repositorio no GitHub Desktop com `github open D:\Estudio`, mas nao pode automatizar o botao `Push origin`; esse clique e humano.

## Alternatives Considered

- `git push` normal via HTTPS: rejeitado porque pode acionar GCM/browser interativo.
- GitHub CLI: indisponivel neste Windows atual (`gh` ausente).
- Reaproveitar helper interno do GitHub Desktop: rejeitado porque depende de `DESKTOP_PORT` interno e nao documentado como API de automacao.
- PAT/token manual: rejeitado por risco de vazamento.

## Impact

O agente tem um caminho testavel e seguro: tenta push sem prompt quando Fabio autorizar; se nao houver credencial compartilhada com o Git do Windows, falha limpo sem abrir navegador. O GitHub Desktop continua sendo o fallback oficial e visual.

## Review When

Revisar se `gh` for instalado e autenticado sem browser interativo, se o GitHub Desktop expuser comando oficial de push, ou se Fabio decidir provisionar credencial nao interativa segura fora do repositorio.
