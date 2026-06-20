# Track 10B - Web Goal Feel Reintroduction V1

- Agente: Codex
- Branch: `codex/JogoDaCopa/track10b-web-goal-feel-reintroduction-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track10b-web-goal-feel-reintroduction-v1`
- Projeto: `Projetos/JogoDaCopa/`
- Base: Track 10A aprovada (`Super Campeao v1.2.1+fc3c72bb`) sobre `main` local atual.

## Objetivo

Reintroduzir sensacao de gol mais satisfatoria no Web sem aceitar freezes durante a partida.

## Escopo

- Criar um caminho Web-safe de gol mais expressivo que o marcador atual.
- Tentar reativar audio 2D de gol no Web; se reabrir hitch/freeze, remover o audio e preservar apenas visual seguro.
- Manter PC/Windows com o pacote completo de gol existente.
- Nao alterar gameplay, fisica, bot, bola, scoring, SUPER, tuning, camera de movimento ou HUD funcional.

## Metricas De Aceite

- Loading pode aumentar e sera documentado.
- Partida ativa nao pode ter freeze:
  - `firstMinuteHitches=0` com threshold `>100ms`.
  - Nenhum frame `>100ms` na janela de gol observada pelo probe.
  - `pageErrors=0`, `consoleErrorCount=0`.
  - Gate local de estabilidade 5min verde antes de fechar.
  - `js_heap_growth < 10%` no gate final.
- Se uma variante com audio falhar e a variante visual passar, fechar sem audio.

## Validacao Planejada

- Import headless do editor em worktree nova.
- `tools/validate.gd`.
- Web export.
- `node --check tools/track04f_chrome_probe.mjs`.
- Probes Chrome locais:
  - 60-90s first-minute com variante final.
  - 5min stability com variante final.
- `git diff --check`.
- `D:\Estudio\tools\check_doc_drift.ps1`.

## Handoff

- Relatorio em `Projetos/JogoDaCopa/docs/playtest-reports/track-10b-web-goal-feel-reintroduction.md`.
- Evidencias em `Projetos/JogoDaCopa/docs/playtest-reports/track-10b-data/`.
- Fechar em `Kanban/Done`, commit local e merge local se os gates passarem.
- PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.

## Fechamento

- Resultado: `LOCAL_VALIDATED`.
- Implementacao: Web `goal` voltou ao default com pacote leve; PC manteve pacote completo.
- Audio: `goal_jingle` mantido no Web; `crowd_goal` continua fora do caminho default Web.
- GUT: PASS, `108/108`, `1838` asserts.
- Web export/gzip: PASS, `30.62 MiB / 50.00 MiB`.
- Chrome 90s default: PASS, `firstMinuteHitches=0`.
- Chrome 90s audio-unlock: PASS, `goal_jingle` carregou/tocou sem hitch.
- Chrome 5min stability: PASS, `firstMinuteHitches=0`, `js_heap_growth -8.36%`, worst 5s FPS `121`.
- Active-match goal windows: `hitchCount=0`, max frame observado ~`13.8ms`.
- Publicacao remota: pendente.
