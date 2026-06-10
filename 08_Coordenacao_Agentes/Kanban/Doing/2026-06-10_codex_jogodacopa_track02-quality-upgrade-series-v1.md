# Tarefa: JogoDaCopa - Track 02 Quality Upgrade Series V1 (02A-02G)

## Metadata

- id: `2026-06-10_jogodacopa-track02-quality-upgrade-series-v1`
- owner: `Codex`
- status: `Doing`
- projeto: `JogoDaCopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/jogodacopa/track02-quality-upgrade-series-v1`
- worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track02-quality-upgrade-series-v1`
- started_at: `2026-06-10`
- current_track: `02E HUD & Menu Polish V1`

## Execution Registration

- Base docs read: `08_Coordenacao_Agentes/Prioridades_Estudio.md`, `Projetos/README.md`, `08_Coordenacao_Agentes/Estado_Atual.md` (JogoDaCopa), `Projetos/JogoDaCopa/AGENTS.md`, `Projetos/JogoDaCopa/implementation/current-status.md`, `Projetos/JogoDaCopa/docs/quality-upgrade-plan.md`, this card.
- Intended files: `Projetos/JogoDaCopa/modes/football/`, `Projetos/JogoDaCopa/gameplay/football/`, `Projetos/JogoDaCopa/gameplay/avatar/`, `Projetos/JogoDaCopa/presentation/`, `Projetos/JogoDaCopa/modes/menu/`, `Projetos/JogoDaCopa/tests/`, `Projetos/JogoDaCopa/docs/`, `Projetos/JogoDaCopa/implementation/`, plus coordination status/card files.
- Validation plan: run `Projetos/JogoDaCopa/tools/validate.gd` after each track before advancing; measure editor performance after `02A` and `02D`; run `git diff --check` and `git status --short` before handoff.
- Next handoff point: after `02A` if validation/performance blocks progression; otherwise after the completed `02A-02G` series with final status/docs/card updates.

## Progress Log

- `2026-06-10` - `02A Render & Lighting Foundation V1` complete. `tools/validate.gd` PASS (24 tests, 219 asserts). Performance sample Windows/Forward+ after warmup: average `143.9fps`, min warmed instant `63.6fps`, `0/360` frames below 60. Status file: `Projetos/JogoDaCopa/implementation/tracks/track-02a-render-lighting-foundation-v1/current-status.md`.
- `2026-06-10` - `02B Pitch & Arena Material Pass V1` complete. `tools/validate.gd` PASS (24 tests, 230 asserts). Status file: `Projetos/JogoDaCopa/implementation/tracks/track-02b-pitch-arena-material-pass-v1/current-status.md`.
- `2026-06-10` - `02C Ball & Character Assets V1` complete. Asset import spike PASS for `assets/football/football_ball_panels.gdshader`; `tools/validate.gd` PASS (24 tests, 240 asserts). Licenses recorded in `Projetos/JogoDaCopa/docs/asset-licenses.md`. Status file: `Projetos/JogoDaCopa/implementation/tracks/track-02c-ball-character-assets-v1/current-status.md`.
- `2026-06-10` - `02D VFX & Game Feel V1` complete. `tools/validate.gd` PASS (26 tests, 250 asserts). Performance sample Windows/Forward+ with VFX spawned after warmup: average `144.2fps`, min warmed instant `63.3fps`, `0/360` frames below 60. Status file: `Projetos/JogoDaCopa/implementation/tracks/track-02d-vfx-game-feel-v1/current-status.md`.

## Goal

Implementar a serie completa de upgrade de qualidade do JogoDaCopa (Tracks 02A a 02G) conforme o plano aprovado em `Projetos/JogoDaCopa/docs/quality-upgrade-plan.md`, em uma unica thread de implementacao, com um commit por track e validacao entre tracks. Caminho visual hibrido aprovado por Fabio em 2026-06-10: arena/luz/VFX procedurais + assets CC0 apenas para personagem animado e bola (Track 02C e a track de authored assets explicitamente autorizada).

## Technical Scope

Resumo por track (detalhes e criterios de aceite no plano):

- `02A Render & Lighting Foundation`: full `WorldEnvironment` (night procedural sky, ACES tonemap, glow/bloom, light SSAO, subtle fog), stadium light rig (key DirectionalLight + 4 SpotLight3D on existing light rig positions), MSAA 4x, emission pass on glass/arena frames.
- `02B Pitch & Arena Material Pass`: single-mesh pitch with ShaderMaterial (stripes, noise, field lines) replacing stripe/line boxes, translucent grid net shader, crowd color-variation shader with subtle motion, Label3D country banners, functional SubViewport scoreboards bound to real score state.
- `02C Ball & Character Assets` (authored assets APPROVED): CC0 football texture/model + ball trail + impact squash; CC0 low-poly rigged humanoid with `AnimationTree` (idle/run/kick/celebrate) preserving `apply_appearance`/`play_kick`/`play_celebrate`/`set_move_state` contracts; licenses logged in `docs/asset-licenses.md`.
- `02D VFX & Game Feel`: goal explosion/kick spark/boost trail/skid dust particles, camera shake + boost FOV kick, 0.4s goal slow-mo + ball zoom, kickoff 3-2-1 countdown with input lock, CC0 SFX replacing synthetic audio (kick, bounce, glass, crowd loop, whistle, goal stinger).
- `02E HUD & Menu Polish`: broadcast-style score HUD with kit flags/colors, off-screen ball indicator, themed stamina, 3D arena background menu with avatar/kit preview, end-of-match result screen with rematch.
- `02F Bot & Match Flow`: ball position prediction (velocity * t), positioned defensive retreat, bot boost usage, 3 difficulty levels, alternating kickoff.
- `02G Product Identity`: final module name, icon, splash, Windows export preset, build smoke test, `publication-readiness.md` update.

## Out of Scope

- Multiplayer, backend, Web/mobile, matchmaking, economia.
- Armas/FPS (vive em `FpsPlayground`).
- Logos oficiais FIFA/Copa ou assets sem licenca CC0/CC-BY documentada.
- Mudancas no feel aprovado de bola/chute/boost fora do que o plano pede.
- Hand-edit de `.tscn` gerado (regra do AGENTS.md local).

## Expected Files

- `Projetos/JogoDaCopa/modes/football/football_root.gd` (environment/lighting)
- `Projetos/JogoDaCopa/modes/football/football_field_builder.gd` (shader pitch, crowd, scoreboards)
- `Projetos/JogoDaCopa/gameplay/football/football_ball.gd` (ball visual/trail)
- `Projetos/JogoDaCopa/gameplay/avatar/` (asset-based avatar preserving contracts)
- `Projetos/JogoDaCopa/gameplay/football/football_bot.gd` (prediction/difficulty)
- `Projetos/JogoDaCopa/presentation/` (camera shake/FOV, HUD, feedback/VFX/audio)
- `Projetos/JogoDaCopa/modes/menu/` (polished menu)
- `Projetos/JogoDaCopa/assets/` (new: CC0 character/ball/SFX)
- `Projetos/JogoDaCopa/docs/asset-licenses.md` (new)
- `Projetos/JogoDaCopa/docs/quality-upgrade-plan.md` (progress markers per track)
- `Projetos/JogoDaCopa/implementation/tracks/track-02*/current-status.md` (one per completed track)
- `Projetos/JogoDaCopa/implementation/current-status.md`, `docs/work-plan.md` (status updates)
- `Projetos/JogoDaCopa/tests/` (updated/new GUT coverage)

## Acceptance Criteria

- [ ] Tracks implementadas em ordem 02A -> 02B -> 02C -> 02D -> 02E -> 02F -> 02G, um commit logico por track. (`02A`, `02B`, `02C`, `02D` complete)
- [ ] `tools/validate.gd` PASS apos cada track (nao apenas no final). (`02A`, `02B`, `02C`, `02D` PASS)
- [ ] Contratos preservados: avatar API, regras de gol com altura, feel de chute/boost cobertos por testes existentes.
- [x] Track 02C: spike de import de 1 asset antes de comprometer a track; licencas em `docs/asset-licenses.md`.
- [x] 60fps no editor com glow+SSAO+particulas (medir apos 02A e 02D; reduzir custo se cair). (`02A` and `02D` samples above 60 after warmup)
- [ ] Cada track concluida ganha `implementation/tracks/track-02x-*/current-status.md` no padrao das tracks 01A-01C. (`02A`, `02B`, `02C`, `02D` created)
- [ ] Docs e este card atualizados no final; card movido para Done.
- [ ] Se a thread atingir limite antes de 02G, registrar Handoff com a proxima track exata e estado.

## Handoff Needed

`Yes - to Usuario` (playtest humano no editor ao final da serie ou de cada bloco visual)

## Notes

- Plano autoritativo: `Projetos/JogoDaCopa/docs/quality-upgrade-plan.md` (analise, direcao visual "arena de Copa festiva a noite", criterios e riscos por track).
- Decisao de assets hibrida registrada no plano; e a aprovacao explicita exigida por `architecture-overview.md` para a primeira authored-asset track.
- Preferir texturas/padroes gerados por script quando o resultado for equivalente, para minimizar binarios no repo (bola pode ser textura procedural de gomos).
