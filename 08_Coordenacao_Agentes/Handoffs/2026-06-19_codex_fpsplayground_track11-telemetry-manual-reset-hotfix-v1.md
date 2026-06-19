# Handoff - FpsPlayground Track 11 Telemetry Manual Reset Hotfix V1

- Data: `2026-06-19`
- Agente: `Codex`
- Branch: `codex/fpsplayground/track11-telemetry-manual-reset-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track11-telemetry-manual-reset-hotfix-v1`
- Projeto: `D:\Estudio-worktrees\FpsPlayground--codex--track11-telemetry-manual-reset-hotfix-v1\Projetos\FpsPlayground`
- Objetivo: registrar restart manual durante rodada ativa como `round_reset reason=manual_restart` antes do novo `round_start`.
- Guardrail: hotfix de telemetria/semantica de reset apenas; nao alterar movimento, dano, bot, mapa, pickups, jump pads ou fluxo jogavel aprovado.
- Arquivos pretendidos: `D:\Estudio-worktrees\FpsPlayground--codex--track11-telemetry-manual-reset-hotfix-v1\Projetos\FpsPlayground\modes\arena\arena_root.gd`, `D:\Estudio-worktrees\FpsPlayground--codex--track11-telemetry-manual-reset-hotfix-v1\Projetos\FpsPlayground\tests\unit\test_telemetry.gd`, docs/status locais.
- Docs base lidos: `D:\Estudio\08_Coordenacao_Agentes\Prioridades_Estudio.md`, `D:\Estudio\AGENTS.md`, `D:\Estudio\Projetos\README.md`, `D:\Estudio\08_Coordenacao_Agentes\Estado_Atual.md`, `Projetos\FpsPlayground\AGENTS.md`, `Projetos\FpsPlayground\implementation\current-status.md`, `Projetos\FpsPlayground\docs\telemetry.md`.
- Entrega: `restart_round()` durante rodada ativa agora emite `round_reset reason=manual_restart` antes do novo `round_start`.
- Validacao: `tools/validate.gd` PASS `49/49`, `464 asserts`; `git diff --check` PASS; `check_doc_drift.ps1` PASS.
- Proximo handoff: commit local e aguardar aprovacao para merge.
