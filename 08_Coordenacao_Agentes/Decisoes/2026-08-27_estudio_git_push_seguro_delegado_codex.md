# Decisao: push Git seguro delegado ao Codex

## Metadata

- data: `2026-08-27`
- decisor: `Fabio`
- projeto: `estudio`
- escopo: `global_governance`
- status: `active`
- authority: `operational_contract`
- last_verified: `2026-08-27`
- review_when: `URL, main branch, authentication, Git LFS, remote protection or delegation changes`
- supersedes: `2026-06-14_estudio_git_remote_exclusivo_fabio.md`
- superseded_by: `none`

## Contexto

O fluxo anterior deixava commits validados aguardando sincronizacao manual. A
operacao nao interativa atual foi comprovada com o remoto oficial e pode ser
delegada sem ampliar autorizacoes de produto ou publicacao.

## Decisao

Depois de integrar e validar trabalho em `main` limpa, o coordenador global
Codex executa por padrao a sincronizacao exata de `main` para `origin/main`
descrita em `../Runbooks/GIT_SAFE_PUSH.md` e confirma igualdade literal do OID
remoto, tracking ref e `HEAD`.

A delegacao cobre somente o fetch exato de preflight e o push exato dessa ref.
Continuam proibidos `pull`, login/PAT, mudanca de credenciais, force,
force-with-lease, tags, outras refs/remotos, deploy, release, publicacao de
produto e mutacoes remotas de produto/operacao. Qualquer falha interrompe a
onda e preserva os commits locais.

## Impacto

Fechamento tecnico, sincronizacao Git e publicacao de produto permanecem
estados independentes. O handoff registra `git_sync_status`; a sincronizacao
rotineira nao pede nova autorizacao e nao aprova gate humano ou release.

## Review when

Revisar se URL, branch principal, autenticacao, Git LFS, protecao remota ou o
modelo de delegacao mudar.
