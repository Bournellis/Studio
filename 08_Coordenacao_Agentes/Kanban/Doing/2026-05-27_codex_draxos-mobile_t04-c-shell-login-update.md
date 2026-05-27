# T04-C - DraxosMobile Shell/Login/Update

- Data: `2026-05-27`
- Agente sugerido: `Codex`
- Branch sugerida: `codex/draxos-mobile/t04-shell-login-update`
- Worktree sugerida: `D:\Estudio-worktrees\draxos-mobile--codex--t04-shell-login-update`
- Status: `DONE_INTEGRATED`

## Objetivo

Extrair renderizacao de sessao, login, save ativo e update gate para presenter render-only.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/boot.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/`
- Testes client relevantes, se precisar cobrir a superficie extraida.

## Guardrails

- Nao alterar Auth, Supabase, manifest, `SessionStore` ou `BackendConfig`.
- Actions/network continuam no `boot.gd`.

## Validacao Planejada

- `tools/smoke_session_shell.gd`
- Godot `tools/validate.gd`
- GUT client
- `git diff --check`

## Proximo Handoff

Liberar `T04-D`, `T04-E` e `T04-F` para extrairem superficies visuais em paralelo.
