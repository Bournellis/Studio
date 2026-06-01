# Codex - DraxosMobile hardening client shell

- Data: `2026-06-01`
- Branch: `codex/draxos-mobile/hardening-client-shell`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--hardening-client-shell`
- Objetivo: descongestionar `modes/boot/boot_runtime.gd` e `modes/boot/surfaces/hub_surface_full_presenter.gd`, criando presenter dedicado para Mode Hub e launcher dedicado para Mode Shell sem alterar rotas/UI.
- Escopo pretendido: client Godot em `Projetos/draxos-mobile/modes/boot/`, testes GUT/smokes relacionados a Hub/staged/disabled, e esta nota de coordenacao.
- Fora de escopo: backend, schema remoto, session store, publicacao remota e alteracoes de produto.
- Docs base lidos: `Prioridades_Estudio.md`, `AGENTS.md`, `Projetos/README.md`, `canon/canon-brief.md`, `Estado_Atual.md`.
- Validacao planejada: testes GUT/smokes focados em hub, staged e disabled; validacao local disponivel do projeto se aplicavel.
- Handoff esperado: commits coerentes com arquivos alterados, validacoes executadas e blockers documentados no final.
