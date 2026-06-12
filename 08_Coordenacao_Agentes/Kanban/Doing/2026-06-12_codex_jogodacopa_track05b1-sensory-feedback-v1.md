# Track 05B.1 - Sensory Feedback Re-Introduction V1

- Data: `2026-06-12`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track05b1-sensory-feedback-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track05b1`
- Projeto: `Projetos/JogoDaCopa/`
- Objetivo: devolver ao Web os efeitos sensoriais cortados na 05B sem reabrir hitches no primeiro minuto.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/code-review-track05b-first-minute-v1.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-05b-first-minute-smoothness.md`

## Arquivos Pretendidos

- Runtime/warmup Web: `Projetos/JogoDaCopa/modes/football/football_root.gd`
- Feedback sensorial: `Projetos/JogoDaCopa/presentation/feedback/fps_feedback_controller.gd`, HUD/result/countdown se necessario
- Probe Chrome/gates: `Projetos/JogoDaCopa/tools/track04f_chrome_probe.mjs`
- Release: `Projetos/JogoDaCopa/tools/publish_web.ps1`, `Projetos/JogoDaCopa/docs/release-history.md`
- Evidencias/docs: `Projetos/JogoDaCopa/docs/playtest-reports/track-05b1-*`, `Projetos/JogoDaCopa/implementation/current-status.md`

## Validacao Planejada

- Reativar na ordem: APITO -> CONFETTI de gol -> VFX de chute -> countdown -> jump pad -> result.
- Para cada efeito: warmup real dentro do frustum atras do overlay e gate curto de primeiro minuto `60s`; avancar somente com `0` hitches `>100ms`.
- Manter Web sem `AudioStreamPlayer3D`; transientes de audio Web em 2D com decode pre-aquecido no loading.
- Gates longos apenas no final: primeiro minuto completo local/remoto, estabilidade 5min, luminancia, validate full, export Web, publish v1.0.3 e smoke remoto.

## Handoff

- Parar na branch para review pre-merge da Claude.
- Fechamento esperado: `git status --short`, `git diff --check`, `WORKTREE_VERIFIED`.
- Rede git proibida; `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
