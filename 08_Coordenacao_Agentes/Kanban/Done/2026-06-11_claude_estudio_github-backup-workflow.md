# Tarefa: Estudio - Backup GitHub + Fluxo GitHub Desktop

## Metadata

- id: `2026-06-11_claude_estudio_github-backup-workflow`
- owner: `Claude`
- status: `Done`
- projeto: `estudio`
- prioridade_portfolio: `-`
- branch: `main` (trabalho direto autorizado por Fabio)
- worktree: `D:\Estudio`

## Goal

Criar o backup remoto do estudio e estabelecer o fluxo de versionamento com GitHub Desktop.

## Delivered

- Repo privado `https://github.com/Bournellis/Studio` criado por Fabio; push inicial de 937 commits (main `eb1447c`) executado por Claude via OAuth device flow (client do GitHub CLI) e clone bare em sandbox, contornando `.git/config` corrompido no workspace.
- Push de delta ate `078df1b` (Tracks 03F-03H do JogoDaCopa) apos retomada do trabalho do Codex.
- Loop de login do Git Credential Manager diagnosticado e resolvido: a URL errada do remote (`estudio.git` em vez de `Studio.git`) fazia o GCM reinterpretar acesso negado como credencial invalida. Config recriado limpo com a URL correta.
- Fabio adotou o GitHub Desktop como painel de revisao/fetch/push; Codex reconfigurou o ambiente na pasta `D:\Estudio`.
- Registro permanente: Decisao `Decisoes/2026-06-11_estudio_github-backup-desktop.md`, Aprendizado `07_Aprendizados/2026-06-11_git-escritor-unico.md`, regra de push e escritor unico no `AGENTS.md` raiz, nota de backup no `README.md` raiz.

## Validation

- `git ls-remote origin refs/heads/main` igual ao `main` local em cada etapa (`eb1447c`, `078df1b` e o commit final desta task).
- Blobs do HEAD verificados sem bytes NUL apos cada commit feito do sandbox.
- Checagem de segredos pre-push: somente placeholders rastreados; `.env.*.local` ignorado; nenhum arquivo >40MB rastreado.

## Follow-ups

- Rodar `tools/check_doc_drift.ps1` uma vez em PowerShell real no Windows.
- Habito diario: zerar o `Push origin` do GitHub Desktop ao encerrar o dia.
