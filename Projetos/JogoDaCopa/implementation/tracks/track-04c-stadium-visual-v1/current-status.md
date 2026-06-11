# Track 04C - Stadium Visual Upgrade V1

- Data: 2026-06-11
- Branch local: `codex/JogoDaCopa/track04c-stadium-visual-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04c-stadium-visual-v1`
- Status: `READY_FOR_REVIEW`
- Base: `main` em `b715f743` (`docs(jogodacopa): close track04b3 after merge`)

## Objetivo

Upgrade visual do estadio antes do web publish, mantendo modos para pos-lancamento. Esta track fecha na branch para review de Claude e aprovacao visual de Fabio; nao houve merge em `main`.

## Implementado

- Arquibancadas config-driven com `stadium_tier_count`, 3+ aneis por lado, recuo e altura crescente, mureta frontal e corredores.
- Torcida viva com blocos por lado/tier, cores dos dois kits (`player_kit_color` e `bot_kit_color`) e material shader com `crowd_excitement` entre `0.0` e `1.0`.
- Metodo publico `FootballFieldBuilder.set_crowd_excitement(parent, crowd_excitement)` para o root chamar depois de eventos de gol.
- Teloes maiores com `SubViewport` reposicionado/escalado e resolucao `1024x384`.
- Bandeiroes com nomes de paises via `Label3D`.
- Mastros com bandeiras simples animadas por shader de vertex wave.
- Halos/billboards sutis nos refletores por material emissive, sem novas luzes.
- Horizonte low-poly com skyline barato atras do vidro, sem sombras.
- Testes proprios cobrindo configuracao do estadio, materiais da torcida, clamp/update de `crowd_excitement` e ausencia de novas luzes com sombra.

## Integracao Posterior Registrada

Nao editar `football_root` nesta track por causa da 04D em paralelo. Para a integracao posterior:

- O root deve passar as cores reais da partida no `config` do builder (`player_kit_color` e `bot_kit_color`).
- O root pode chamar `FootballFieldBuilder.set_crowd_excitement(self, 1.0)` no gol e reduzir para `0.0`/decair durante o reset ou apos alguns segundos.
- Se o root mantiver uma referencia direta do estadio, tambem pode chamar o metodo usando esse node como `parent`; o metodo percorre recursivamente os materiais da torcida.

## Suavizacao Opcional Do Uniforme

O shader `gameplay/avatar/avatar_uniform.gdshader` recebeu um teste local de blend de borda, mas a comparacao visual nao mostrou melhoria clara. O experimento foi revertido e nao faz parte da branch final. Evidencias preservadas:

- `docs/screenshots/track-04c-stadium-visual-v1/06-uniform-edge-before-hard.png`
- `docs/screenshots/track-04c-stadium-visual-v1/07-uniform-edge-after-soft.png`

## Evidencia Visual

- `docs/screenshots/track-04c-stadium-visual-v1/01-lateral-deep-stands.png`
- `docs/screenshots/track-04c-stadium-visual-v1/02-behind-goal-scoreboards.png`
- `docs/screenshots/track-04c-stadium-visual-v1/03-high-diagonal-skyline.png`
- `docs/screenshots/track-04c-stadium-visual-v1/04-field-level-crowd.png`
- `docs/screenshots/track-04c-stadium-visual-v1/05-crowd-excitement-1.png`
- `docs/screenshots/track-04c-stadium-visual-v1/06-uniform-edge-before-hard.png`
- `docs/screenshots/track-04c-stadium-visual-v1/07-uniform-edge-after-soft.png`

## Validacao

- Import headless da worktree nova: PASS.
- `tools/validate.gd --profile=structure`: PASS.
- `tools/validate.gd`: PASS, 77 testes, 1128 asserts.
- `tools/performance_sample.gd --label=track04c-stadium-visual-v1`: PASS, media 728.8fps, minimo aquecido 452.3fps, 0/360 frames abaixo de 60fps, windowed 1920x1080.
- `git diff --check`: PASS.

## Arquivos Tocadas Pela Track

- `modes/football/football_field_builder.gd`
- `tests/unit/test_bootstrap.gd`
- `implementation/tracks/track-04c-stadium-visual-v1/current-status.md`
- `docs/playtest-reports/track-04c-stadium-visual-v1.md`
- `docs/screenshots/track-04c-stadium-visual-v1/*.png`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-11_codex_jogodacopa_track04c-stadium-visual-v1.md`
- `08_Coordenacao_Agentes/Handoffs/2026-06-11_codex_jogodacopa_track04c-stadium-visual-v1.md`

## Worktree

`WORKTREE_VERIFIED`: branch local pronta para review, sem merge em `main`, sem `push`/`fetch`/`pull` e sem `git clean`.

## Proximo Passo

Claude deve revisar a branch e Fabio deve aprovar visualmente as evidencias antes de qualquer merge/publicacao. Depois da aprovacao, a integracao do root para passar cores reais e disparar `crowd_excitement` deve ser feita em uma thread propria ou na consolidacao com 04D.
