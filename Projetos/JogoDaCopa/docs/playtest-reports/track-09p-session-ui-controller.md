# Track 09P - Football Session UI Controller V1

- Data: `2026-06-19`
- Branch: `codex/jogodacopa/track09p-session-ui-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09p-session-ui-controller-v1`
- Base publica preservada: `Super Campeao v1.2.1+5c6520ba` / Track 09N
- Status: local validado; publicado depois em `track-09p-publication.md`

## Escopo

Extrair a orquestracao fria de sessao/UI do modo Futebol para `football_session_ui_controller.gd`, mantendo `FootballRoot` como fachada de compatibilidade.

Movido para o novo controller:

- `_input`
- `_get_escape_target`
- `_start_match`
- `_set_intro_open`
- `_set_menu_open`
- `_return_to_main_menu`
- `_return_to_main_menu_async`
- `_capture_mouse_if_playing`

Fora de escopo e preservado:

- `_physics_process`
- contato com bola
- chute, charged kick e SUPER
- bot
- scoring, timer, golden goal e restart state
- boost pads e jump pads
- HUD visual
- assets, constantes de tuning e field builder

## Arquivos Tocados

- `modes/football/football_root.gd`
- `modes/football/football_session_ui_controller.gd`
- `docs/architecture-overview.md`
- `docs/documentation-index.md`
- `implementation/current-status.md`
- `docs/work-plan.md`
- `docs/playtest-reports/track-09p-session-ui-controller.md`
- `docs/playtest-reports/track-09p-data/09p-local-web-boot.json`
- `docs/playtest-reports/track-09p-data/09p-local-web-boot.png`
- `08_Coordenacao_Agentes/Kanban/Done/2026-06-19_codex_jogodacopa_track09p-session-ui-controller-v1.md`

## Contagem

- `FootballRoot`: `1051 -> 974` linhas (`-77`)
- `football_session_ui_controller.gd`: `115` linhas

## Validacao

- Import headless editor: PASS.
- `tools/validate.gd` antes do Web build: PASS, `104/104` testes, `1826` asserts, `59` fontes.
- Web export release: PASS.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- `tools/validate.gd` depois do Web build: PASS, gzip `30.60 MiB / 50.00 MiB`, `104/104` testes, `1826` asserts, `59` fontes.
- Chrome Web smoke 90s: PASS.
  - Evidencia: `docs/playtest-reports/track-09p-data/09p-local-web-boot.json`
  - Screenshot: `docs/playtest-reports/track-09p-data/09p-local-web-boot.png`
  - `pageErrors=0`
  - `consoleErrorCount=0`
  - `firstMinuteHitches=0`
  - `stabilityPassed=true`
  - `js_heap_growth -1.26%`

## Observacoes

- A primeira tentativa de export falhou porque `builds/web/` nao existia na worktree nova; a pasta foi criada e o mesmo export passou.
- Uma tentativa auxiliar com `--profile=size-only` foi descartada porque o projeto nao possui esse perfil; a validacao oficial completa foi rerodada com sucesso depois do Web build.
- O perfil temporario do Chrome gerado pelo probe foi ignorado pelo Git; apenas JSON e PNG de evidencia fazem parte da track.
- Nenhum comportamento publico novo foi intencionalmente introduzido.

## Proxima Decisao

Track 09P foi publicada depois deste fechamento tecnico. Ver `track-09p-publication.md` e `track-09p-data/` para os gates remotos. O proximo passo e reteste humano antes de abrir nova reducao local; 09N permanece fallback aprovado ate a aprovacao humana da 09P.
