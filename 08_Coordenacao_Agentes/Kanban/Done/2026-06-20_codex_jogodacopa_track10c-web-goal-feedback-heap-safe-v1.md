# Track 10C - Web Goal Feedback Heap-Safe V1

- Data: 2026-06-20
- Agente: Codex
- Branch: `codex/jogodacopa/track10c-web-goal-feedback-heap-safe-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track10c-web-goal-feedback-heap-safe-v1`
- Base local: `3adcc7be` (`merge(jogodacopa): record track10b publication rollback`)
- Commit candidato local: `39054f31` (`feat(jogodacopa): add heap-safe web goal feedback`)
- Status: publicado no Cloudflare Pages com gates remotos PASS; reteste humano pendente.

## Escopo Executado

- Diagnostiquei a falha remota da 10B (`js_heap_growth +13.85%`, limite `<10%`) como risco ligado ao pacote default Web com audio de gol.
- Mantive o feedback visual de gol Web via `goal_visual`, usando os marcadores visuais em pool ja existentes.
- Removi audio de gol do caminho Web default; `goal_audio` e o legado `goal` seguem como opt-in diagnostico.
- Preservei gameplay, fisica, bot, bola, scoring, SUPER, HUD, camera, assets pesados, tuning e pacote completo de gol PC/Windows.

## Arquivos Principais

- `Projetos/JogoDaCopa/presentation/feedback/fps_feedback_controller.gd`
- `Projetos/JogoDaCopa/tests/unit/test_render_profile.gd`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-10c-web-goal-feedback-heap-safe.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-10c-publication.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-10c-data/`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/work-plan.md`
- `Projetos/JogoDaCopa/docs/publication-readiness.md`
- `Projetos/JogoDaCopa/docs/release-history.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`

## Validacao Local

- Import headless editor: PASS.
- `tools/validate.gd`: PASS, `108/108` testes, `1840` asserts, `62` fontes.
- Web export/gzip: PASS, `30.62 MiB / 50.00 MiB`.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Chrome local 90s visual-only: PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Chrome local 5min visual-only: PASS, `js_heap_growth -8.10%`, pico `+1.10%`, pior janela 5s `137.4 FPS`.
- Modo observado: `feedback.web_goal_mode visual=true audio=false`.

## Publicacao E Gates Remotos

- Publicado como `Super Campeao v1.2.1+39054f31`.
- Release root: `web/v1-copa-arena-futebol-20260620-39054f31`.
- Deploy final: `https://c50815e2.copa-arena-futebol.pages.dev`.
- URL estavel: `https://copa-arena-futebol.pages.dev/`.
- Remote menu: PASS, release root conferiu, `menu.ready.end`, erros `0`.
- Remote first-minute: PASS, release root conferiu, `event.visible_match_start`, `firstMinuteHitches=0`, erros `0`.
- Remote 5min stability: PASS, `js_heap_growth -0.59%`, pico `+2.31%`, `wasmSampleCount=0`, pior janela 5s `142.2 FPS`.
- Remote luma: PASS, `luma_0_255=6.525 < 90`.
- Stable URL confirmation: PASS, dominio estavel servindo o release root 10C.

## Resultado

- Track 10C recupera satisfacao visual no gol Web sem reintroduzir freeze ou crescimento de heap acima do gate.
- Audio de gol Web default ficou desativado por seguranca; PC/Windows continua com pacote completo.
- Track 10A permanece fallback aprovado ate Fabio/tester aprovar a 10C manualmente.
- `PUSH PENDENTE`: Fabio - GitHub Desktop - Push origin.
