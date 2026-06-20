# Track 10C - Web Goal Feedback Heap-Safe V1

- Data: 2026-06-20
- Agente: Codex
- Branch: `codex/jogodacopa/track10c-web-goal-feedback-heap-safe-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track10c-web-goal-feedback-heap-safe-v1`
- Base local: `3adcc7be` (`merge(jogodacopa): record track10b publication rollback`)
- Objetivo: tentar reintroduzir feedback de gol Web de forma heap-safe depois do bloqueio remoto da 10B.

## Escopo

- Diagnosticar a falha remota da 10B (`js_heap_growth +13.85%`, limite `<10%`).
- Criar candidato mais conservador que a 10B, preferindo flags/contratos separados para visual e audio.
- Preservar gameplay, fisica, bot, bola, scoring, SUPER, HUD, camera, assets pesados e tuning.
- Manter 10A como baseline publica ate uma candidata passar gates locais/remotos e reteste humano.

## Guardrails

- Nao reativar `crowd_goal`, particle burst ou dynamic light no Web.
- Nao publicar candidato que falhe o gate 5min remoto.
- Se o candidato precisar mexer em gameplay ou tuning, parar e registrar handoff.
- Sem `git push`, `git fetch` ou `git pull`; Fabio faz rede pelo GitHub Desktop.

## Plano De Validacao

- Import headless editor da worktree nova.
- `tools/validate.gd`.
- Web export.
- `node --check tools/track04f_chrome_probe.mjs`.
- Chrome local 90s.
- Chrome local 5min antes de qualquer publicacao.
- Se local passar, publicar candidato com `tools/publish_web.ps1 -ConfirmRemoteMutation`.
- Remote menu, first-minute e 5min stability.
- Rollback imediato para 10A se qualquer gate remoto bloquear.
- `git diff --check`.
- `D:\Estudio\tools\check_doc_drift.ps1`.

## Handoff Esperado

- Se a candidata passar remoto: publicar, registrar evidencias e aguardar reteste humano.
- Se bloquear: rollback para 10A e registrar causa/decisao.
- `PUSH PENDENTE`: Fabio - GitHub Desktop - Push origin.
