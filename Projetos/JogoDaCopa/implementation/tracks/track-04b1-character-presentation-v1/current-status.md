# Track 04B1 - Character Presentation & Animation V1

- Data: `2026-06-11`
- Status: `WORKTREE_VERIFIED_FOR_CLAUDE_REVIEW`
- Branch: `codex/jogodacopa/track04b1-character-presentation-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04b1-character-presentation-v1`
- Marker alvo: `JOGO_DA_COPA_TRACK_04B1_CHARACTER_PRESENTATION_V1_WORKTREE_VERIFIED`

## Objetivo

Entregar o personagem real do `Copa Arena Futebol` com leitura clara de uniforme por regioes, cabelo real anexado ao rig, toon sem corpo duplicado e chute autoral com amplitude humana.

## Entregas

- Uniforme procedural por vertex color no `ArrayMesh` skinned: pele, camisa, shorts, meia e chuteira classificados por bone dominante em runtime.
- Shader novo `gameplay/avatar/avatar_uniform.gdshader`, usando textura original apenas como detalhe de pele e cores solidas para uniforme.
- `apply_appearance` separado por responsabilidade: pele altera apenas `skin_color`; kit altera camisa/shorts/meia; chuteira usa cor escura padrao.
- Catalogo/API de cabelo com estilos reais de `assets/characters/quaternius_ubc/hair/`, cor de cabelo, default do player e cabelo fixo diferente para bot.
- Cabelo carregado como glTF e anexado ao bone `Head` via `BoneAttachment3D`.
- Toon outline migrado para `next_pass` de material, sem `MeshInstance3D` duplicado em T-pose.
- `JogoDaCopa_Kick` reautorado para `0.36s`, com easing cubico, blend times suavizados e teste garantindo `foot_r` abaixo de `pelvis`.
- Testes unitarios cobrindo regioes/uniforms, independencia de skin/kit, cabelo, toon next-pass e limite de altura do chute.

## Evidencias

- Capturas de uniforme: `docs/screenshots/track-04b1-character-presentation-v1/brazil-simple-front.png`, `brazil-simple-side.png`, `brazil-simple-back.png`.
- Capturas de kit/penteado alternativo: `france-long-front.png`, `france-long-side.png`, `france-long-back.png`.
- Sequencia do chute: `kick-frame-00.png` a `kick-frame-03.png`.
- Toon ON: `toon-on-next-pass-no-duplicate.png`.
- Relatorio: `docs/playtest-reports/track-04b1-character-presentation-v1.md`.

## Validacao

- Preparacao da worktree: import headless do editor Godot concluido.
- Full validation final: PASS, `68/68` tests, `838` asserts, source integrity `29` `.gd/.gdshader` files outside `addons/`.
- `git diff --check`: PASS.
- `tools/check_doc_drift.ps1`: PASS.

## Proximo Passo

Claude review na branch desta worktree. Nao mergeado em `main`.
