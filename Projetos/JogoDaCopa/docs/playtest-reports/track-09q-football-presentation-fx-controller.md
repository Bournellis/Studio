# Track 09Q - Football Presentation FX Controller V1

- Data: `2026-06-19`
- Branch: `codex/jogodacopa/track09q-football-presentation-fx-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09q-football-presentation-fx-controller-v1`
- Base publica preservada: `Super Campeao v1.2.1+8863c5b9` / Track 09P
- Status: local validado; nao publicado

## Escopo

Extrair a apresentacao visual/gamefeel fria do modo Futebol para `football_presentation_fx_controller.gd`, mantendo `FootballRoot` como fachada de compatibilidade.

Movido para o novo controller:

- `_trigger_arcade_emote`
- `_update_player_presentation_fx`
- `_set_player_persistent_vfx`
- `_trigger_goal_gamefeel`
- `_update_goal_slowmo`
- `_cycle_skin_tone`
- `_cycle_country_kit`
- `_apply_selected_player_appearance`
- `_update_avatar_states`

Fora de escopo e preservado:

- `_physics_process` ordering
- contato passivo com bola
- dash/body contact
- chute, charged kick e SUPER
- bot
- scoring, timer, golden goal e restart state
- Web loading/boot async
- HUD visual
- assets, shaders e constantes de tuning

## Arquivos Tocados

- `modes/football/football_root.gd`
- `modes/football/football_presentation_fx_controller.gd`
- `docs/architecture-overview.md`
- `docs/documentation-index.md`
- `implementation/current-status.md`
- `docs/work-plan.md`
- `docs/playtest-reports/track-09q-football-presentation-fx-controller.md`
- `docs/playtest-reports/track-09q-data/09q-local-web-boot.json`
- `docs/playtest-reports/track-09q-data/09q-local-web-boot.png`
- `08_Coordenacao_Agentes/Kanban/Done/2026-06-19_codex_jogodacopa_track09q-football-presentation-fx-controller-v1.md`

## Contagem

- `FootballRoot`: `974 -> 919` linhas (`-55`)
- `football_presentation_fx_controller.gd`: `98` linhas

## Validacao

- Import headless editor: PASS.
- `tools/validate.gd` antes do Web build: PASS, `104/104` testes, `1826` asserts, `60` fontes.
- Web export release: primeira tentativa falhou porque `builds/web/` nao existia na worktree nova; a pasta foi criada e o mesmo export passou.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- `tools/validate.gd` depois do Web build: PASS, gzip `30.61 MiB / 50.00 MiB`, `104/104` testes, `1826` asserts, `60` fontes.
- Chrome Web smoke 90s: PASS.
  - Evidencia: `docs/playtest-reports/track-09q-data/09q-local-web-boot.json`
  - Screenshot: `docs/playtest-reports/track-09q-data/09q-local-web-boot.png`
  - `pageErrors=0`
  - `consoleErrorCount=0`
  - `firstMinuteHitches=0`
  - `stabilityPassed=true`
  - `js_heap_growth -10.20%`
  - `peakGrowthRatio +1.37%`
  - `wasmSampleCount=0`

## Observacoes

- O novo controller nao guarda estado proprio; opera sobre o estado existente do `FootballRoot`.
- O import headless em worktree nova registrou warnings/erros conhecidos do GUT durante import de recursos, mas saiu com codigo `0`; `tools/validate.gd` passou depois.
- A tentativa inicial do Chrome probe falhou por falta de `--chrome`; a repeticao com `C:\Program Files\Google\Chrome\Application\chrome.exe` passou e gerou JSON/PNG.
- Nenhum comportamento publico novo foi intencionalmente introduzido.

## Proxima Decisao

Track 09Q esta localmente validada. A proxima decisao e publicar/testar 09Q ou parar para nova reavaliacao. Ate publicacao e reteste humano da 09Q, Track 09P permanece a baseline publica aprovada.
