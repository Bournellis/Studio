# Track 06G - Countdown Directo E Restart Confirmado V1

- Data: `2026-06-13`
- Agente: `Codex`
- Branch: `codex/JogoDaCopa/track06g-countdown-restart-flow-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track06g-countdown-restart-flow-v1`
- Status: `PUBLICADO_RETEST_HUMANO_PENDENTE`

## Objetivo

Corrigir dois pontos cirurgicos do v1.1.0 sem alterar fisica, bot, camera, scoring ou tuning de gameplay:

- countdown de kickoff direto, sem aparecer `4` depois do `3` inicial;
- remover reinicio direto por `R`; reinicio agora passa pelo menu ESC e exige confirmacao.

## Causa Raiz

- O countdown iniciava com `KICKOFF_COUNTDOWN_DURATION = 3.15`, `countdown_last_number = 0` e depois usava `ceilf(kickoff_countdown_remaining)`. No primeiro tick fisico, o restante ainda podia ser maior que `3.0`, entao o HUD recebia `4` depois do `3` inicial.
- O reinicio direto ainda existia em tres lugares: `AppBootstrap.ACTIONS`, `_input()` de `FootballRoot` e `FootballHud.CONTROL_HINTS`. Alem disso, o botao `Reiniciar partida` do pause emitia `restart_requested` imediatamente.

## Mudancas

- `KICKOFF_COUNTDOWN_DURATION` agora e `3.0` e o ultimo numero exibido nasce como `3`, impedindo o tick `4`.
- `restart_round` foi removido do bootstrap e do `_input()` da partida.
- A tabela de controles nao lista mais `Reiniciar / R`.
- O botao `Reiniciar partida...` agora apenas abre `RestartConfirmBox`.
- `Confirmar reinicio` e o unico controle que emite `restart_requested`; `Cancelar` fecha a confirmacao.

## Evidencia Local

| Gate | Resultado |
| --- | --- |
| Import headless de worktree nova | PASS |
| `tools/validate.gd` | PASS, `103` testes / `1842` asserts |
| Captura desktop 06G | PASS, 6 PNGs em `docs/screenshots/track-06g-countdown-restart-flow-v1/` |
| Luminancia das capturas | PASS, `0.3996` a `0.5399` contra minimo `0.025` |
| Export Web release | PASS, `builds/web/index.html` |
| Chrome Web boot local | PASS, `docs/playtest-reports/track-06g-data/06g-local-web-boot.json`, `pageErrors=0`, `consoleErrorCount=0`, `expectedStageSeen=true` |

## Merge E Publicacao

- Merge em `main`: `dff246ac` (`merge(jogodacopa): track06g countdown restart flow`).
- Hotfix de publicacao: `be453dc3` (`fix(jogodacopa): lazy load menu audio on web`) para manter o menu Web sem inicializar streams de UI antes da ativacao do navegador.
- Release root final: `web/v1-copa-arena-futebol-20260613-be453dc3`.
- Hash publico final: `be453dc3`.
- URL publica: `https://copa-arena-futebol.pages.dev/`.
- Preview do deploy final: `https://d9b1e3e1.copa-arena-futebol.pages.dev`.

## Evidencia Remota

| Gate | Resultado |
| --- | --- |
| Menu publico na URL real | PASS, `docs/playtest-reports/track-06g-data/06g-remote-menu-user-url-be453dc3.json`, `pageErrors=0`, `consoleErrorCount=0`, root `be453dc3` |
| Primeiro minuto remoto | PASS, `docs/playtest-reports/track-06g-data/06g-remote-first-minute-be453dc3.json`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0` |
| Estabilidade remota 5min | PASS, `docs/playtest-reports/track-06g-data/06g-remote-stability-5min-be453dc3.json`, heap `+9.03%` (`44,903,273 -> 48,959,558`, limite `<10%`), nodes/caches estaveis, pior janela 5s `121.4 FPS` |
| Luminancia noturna | PASS, `docs/playtest-reports/track-06g-data/06g-remote-night-luma-gate-be453dc3.json`, `17.413 < 90` na captura `06g-remote-night-evidence-be453dc3.png` |

Observacao: tentativas de menu com `jdc_perf=1` sem rota de partida geraram `AbortError` de AudioWorklet no Chrome headless, mas a URL publica real sem parametros passou limpa e os gates de partida instrumentados passaram com `0` erros. A evidencia final de menu usa a URL real do jogador.

## Evidencia Visual

- `docs/screenshots/track-06g-countdown-restart-flow-v1/pause-controls-no-r-1920x1080.png`
- `docs/screenshots/track-06g-countdown-restart-flow-v1/pause-controls-no-r-1366x768.png`
- `docs/screenshots/track-06g-countdown-restart-flow-v1/pause-controls-no-r-1280x720.png`
- `docs/screenshots/track-06g-countdown-restart-flow-v1/pause-restart-confirm-1920x1080.png`
- `docs/screenshots/track-06g-countdown-restart-flow-v1/pause-restart-confirm-1366x768.png`
- `docs/screenshots/track-06g-countdown-restart-flow-v1/pause-restart-confirm-1280x720.png`

## Publicacao

Publicada em Cloudflare Pages por `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260613-be453dc3 -ConfirmRemoteMutation`.
