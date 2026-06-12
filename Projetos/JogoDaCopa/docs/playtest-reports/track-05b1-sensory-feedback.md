# Track 05B.1 - Sensory Feedback Re-Introduction V1

- Data: `2026-06-12`
- Branch: `codex/jogodacopa/track05b1-sensory-feedback-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track05b1`
- Objetivo: devolver ao Web os efeitos sensoriais cortados na 05B sem reabrir hitches `>100ms` no primeiro minuto.

## Contexto

A Track 05B publicou `v1.0.2+ad82384b` com primeiro minuto e estabilidade PASS, mas cortou feedback transiente Web para eliminar hitches de primeiro uso e erros `PositionWorklet`. Fabio aprovou este follow-up para reintroduzir os efeitos um por vez.

Metodo aplicado:

- Iteracao curta por efeito com gate de `60s` de partida real, provocando a sequencia `apito -> gol/confetti -> chute -> countdown -> jump pad -> result/rematch`.
- Web permanece sem `AudioStreamPlayer3D`; apito/SFX transientes usam audio 2D. Para evitar `PositionWorklet` antes de gesto humano, os players Web sao criados/tocados somente apos `navigator.userActivation.hasBeenActive`.
- Warmup de primeiro uso roda dentro do frustum atras do overlay opaco, incluindo caminhos reais de gol/confetti e jump pad.
- Gates longos ficaram somente para validacao final.

## Implementacao

- `fps_feedback_controller.gd`: reintroduz efeitos Web-safe para `whistle`, `confetti`, `kick`, `countdown`, `jump_pad` e `result`; audio transiente Web usa players 2D nos buses `SFX`/`UI` apos ativacao do navegador.
- `main_menu_root.gd`: audio de menu tambem adiado no Web ate ativacao, removendo `PositionWorklet` no smoke remoto automatizado.
- `football_root.gd`: filtro `jdc_web_feedback` para ligar/desligar efeitos no probe, warmup real atras do overlay e sequencia de primeiro minuto por efeito.
- `track04f_chrome_probe.mjs`: aceita `--web-feedback`, registra stages novos, mede hitches por janela de evento com pre-window de `250ms` e limita armazenamento de frames em gates longos para nao medir crescimento de heap do proprio probe.
- `publish_web.ps1`: versao publica atualizada para `v1.0.3`.

## Diagnostico Por Efeito

| Ordem | Efeito | Evidencia curta | Custo maximo medido | Status |
| --- | --- | --- | ---: | --- |
| 1 | APITO | `track-05b1-data/05b1-local-short-01-whistle-pass.json` | `14.0ms` | Reativado |
| 2 | CONFETTI de gol | `track-05b1-data/05b1-local-short-02-whistle-confetti-pass3.json` | `20.9ms` | Reativado |
| 3 | VFX/audio de chute | `track-05b1-data/05b1-local-short-03-kick.json` | `55.6ms` | Reativado |
| 4 | Countdown tick | `track-05b1-data/05b1-local-short-04-countdown.json` | `13.9ms` no evento, max run `48.7ms` | Reativado |
| 5 | Jump pad | `track-05b1-data/05b1-local-short-05-jump-pad-pass2.json` | `14.0ms` | Reativado apos warmup do caminho real |
| 6 | Result/rematch | `track-05b1-data/05b1-local-short-06-result.json` | result `14.0ms`, rematch `7.1ms`, max run `41.7ms` | Reativado |

Falhas uteis durante a iteracao:

| Tentativa | Resultado | Diagnostico | Correcao |
| --- | --- | --- | --- |
| `05b1-local-short-02-whistle-confetti.json` | FAIL, `1889.3ms` | Confetti estava acoplado ao pacote Web pesado de gol (`goal` flash/jingle/crowd). | Manter pacote `goal` desativado no default Web e reativar somente confetti de gol. |
| `05b1-local-short-05-jump-pad.json` | FAIL, `694.6ms` | Warmup isolado do VFX passava, mas o caminho real de jump pad movendo jogador/camera ainda tinha primeiro uso. | Adicionar warmup do jogador no pad real com camera ativa atras do overlay. |

Observacao: o pacote Web pesado de `goal` (flash + jingle + crowd boost) continua fora do default publico; o requisito desta track era `CONFETTI de gol`, que voltou.

## Gates Locais

| Gate | Evidencia | Resultado |
| --- | --- | --- |
| Primeiro minuto final local | `track-05b1-data/05b1-local-final-first-minute-after-menu-audio-defer.json` | PASS, `0` hitches `>100ms`, runtime/page errors `0`, max frame `41.7ms` |
| Estabilidade local 5min | `track-05b1-data/05b1-local-final-stability-5min.json` | PASS, 338 browser samples, 328 Godot samples, runtime/page errors `0`, max frame `48.6ms` |
| Luminancia | `tools/capture_track04e_web_spike.gd` | PASS: kickoff/play `58.8`, goal `63.2`, result `75.4`, teto `90` |
| Validate full | `tools/validate.gd` | PASS, 86/86 testes, 1272 asserts, Web gzip `30.32 MiB / 50.00 MiB` |
| Export Web | `--export-release "Web" "builds/web/index.html"` | PASS |

Loading local primeira visita medido:

- Primeiro minuto final local: `17.81s`.
- Estabilidade local 5min: `18.32s`.

Esse custo aumentou em relacao a 05B por causa do warmup real dos efeitos reintroduzidos e permanece acima do teto local de `8s`; fica registrado para decisao de Fabio. A suavidade do primeiro minuto foi preservada.

## Publicacao

Publicacao autorizada pela decisao vigente e executada como `v1.0.3+ef9c5baa`.

- Projeto Cloudflare Pages: `copa-arena-futebol`.
- Preview publicado: `https://f66e2003.copa-arena-futebol.pages.dev`.
- URL estavel: `https://copa-arena-futebol.pages.dev/`.
- Release root: `web/v1-copa-arena-futebol-20260612-ef9c5baa`.
- Relatorio de publicacao: `docs/playtest-reports/track-05-data/05c-publication-report.json`.

## Gates Remotos

| Gate | Evidencia | Resultado |
| --- | --- | --- |
| Primeiro minuto remoto | `track-05b1-data/05b1-remote-first-minute-gate-final-ef9c5baa.json` | PASS, release root conferiu, `event.rematch` visto, page errors `0`, console errors `0`, `0` hitches `>100ms`, max frame `41.6ms` |
| Estabilidade remota 5min | `track-05b1-data/05b1-remote-stability-5min-final-ef9c5baa-pass2.json` | PASS, release root conferiu, `event.rematch` visto, page errors `0`, console errors `0`, gate de estabilidade PASS |

Falhas uteis de publicacao/smoke:

| Tentativa | Resultado | Diagnostico | Correcao |
| --- | --- | --- | --- |
| `91dfc0b4` remoto | FAIL `PositionWorklet` | Audio Web tocava antes de ativacao do usuario. | Gatear SFX Web por `navigator.userActivation.hasBeenActive`. |
| `aacb46af` remoto 5min | FAIL `PositionWorklet` no menu | Pool de audio do menu ainda era criado cedo no Web. | Adiar pool de audio do menu ate ativacao. |
| `05b1-remote-stability-5min-final-ef9c5baa.json` | FAIL apenas heap | Probe guardava `47.546` objetos de frame e contaminava o gate de heap. | Limitar janela de frames em gates longos; `pass2` ficou verde. |

## Fechamento

- Todos os efeitos solicitados foram reativados no perfil Web default, exceto o pacote pesado completo de `goal`, que continua fora do default publico; o `CONFETTI de gol` voltou.
- Audio automatizado em Web permanece silencioso ate ativacao do navegador para obedecer a politica de autoplay e evitar `PositionWorklet`; em sessao humana, o clique do menu desbloqueia os players 2D.
- Proximo passo: review pre-merge da Claude na branch `codex/jogodacopa/track05b1-sensory-feedback-v1`.
