# Tarefa: Estudio - Auditoria Do Fluxo De Push Git

## Metadata

- id: `2026-06-14_codex_estudio_git-push-policy-audit`
- owner: `Codex`
- status: `Done`
- projeto: `estudio`
- branch: `main`
- worktree: `D:\Estudio`

## Goal

Reavaliar como agentes devem fazer push para `origin` sem abrir login no navegador, registrar o metodo correto e preservar o fallback pelo GitHub Desktop.

## Delivered

- Lida a politica antiga `2026-06-11_estudio_git_remote_github_desktop.md` e o aprendizado `2026-06-11_git-escritor-unico.md`.
- Confirmado que `gh` nao esta instalado no PATH.
- Confirmado que o CLI do GitHub Desktop so suporta `open` e `clone`, nao `push`.
- Testado `git push --dry-run origin main` com `GCM_INTERACTIVE=Never` e `GIT_TERMINAL_PROMPT=0`: falhou por credencial ausente sem abrir navegador/login.
- Testado `git push origin main` com as mesmas guardas: falhou por credencial ausente sem abrir navegador/login.
- Confirmado que `desktop-askpass-trampoline.exe` exige `DESKTOP_PORT`, helper interno do Desktop.
- Registrada nova decisao em `Decisoes/2026-06-14_estudio_git_push_nao_interativo_agentes.md`.
- Atualizados `AGENTS.md` e `07_Aprendizados/2026-06-11_git-escritor-unico.md`.

## Final Rule

Agente so tenta push quando Fabio pedir explicitamente, usando guardas nao interativos:

```powershell
$env:GCM_INTERACTIVE = 'Never'
$env:GIT_TERMINAL_PROMPT = '0'
git push origin <branch>
```

Se falhar por credencial/permissao/divergencia/autenticacao, parar e declarar `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.

## Validation

- `git push --dry-run origin main` com prompt desativado: falha segura, sem browser.
- `git push origin main` com prompt desativado: falha segura, sem browser.
- `github --help`: sem comando de push.
- `tools/check_doc_drift.ps1`: PASS.
- `git diff --check`: PASS.
