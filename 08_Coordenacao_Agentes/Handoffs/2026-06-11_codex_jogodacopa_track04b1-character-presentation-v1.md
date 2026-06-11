# Handoff - JogoDaCopa Track 04B1 Character Presentation

- Data: `2026-06-11`
- Agente: `Codex`
- Status: `WORKTREE_VERIFIED`
- Branch: `codex/jogodacopa/track04b1-character-presentation-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04b1-character-presentation-v1`
- Base main: `8d4bcaa`
- Review alvo: Claude
- Merge em main: NAO realizado

## Escopo Entregue

- Uniforme procedural por regioes no mesh skinned do avatar.
- Shader de uniforme por vertex color.
- Catalogo/API de cabelo e anexacao via `BoneAttachment3D` no bone `Head`.
- Toon outline por material `next_pass`, removendo a duplicata em T-pose.
- `JogoDaCopa_Kick` reautorado para `0.36s`, sem track de posicao artificial no pe.
- Testes unitarios e capturas de evidencia.

## Arquivos Principais

- `Projetos/JogoDaCopa/gameplay/avatar/avatar_appearance.gd`
- `Projetos/JogoDaCopa/gameplay/avatar/avatar_catalog.gd`
- `Projetos/JogoDaCopa/gameplay/avatar/player_avatar_3d.gd`
- `Projetos/JogoDaCopa/gameplay/avatar/avatar_uniform.gdshader`
- `Projetos/JogoDaCopa/tests/unit/test_avatar_system.gd`
- `Projetos/JogoDaCopa/implementation/tracks/track-04b1-character-presentation-v1/current-status.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-04b1-character-presentation-v1.md`
- `Projetos/JogoDaCopa/docs/screenshots/track-04b1-character-presentation-v1/`

## Validacao

- Import headless inicial da worktree: PASS.
- Full validation final:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

- Resultado: PASS, `68/68` tests, `838` asserts, source integrity `29` `.gd/.gdshader` files outside `addons/`.
- `git diff --check`: PASS.
- `tools/check_doc_drift.ps1`: PASS.

## Evidencia Visual

- `brazil-simple-front.png`, `brazil-simple-side.png`, `brazil-simple-back.png`
- `france-long-front.png`, `france-long-side.png`, `france-long-back.png`
- `kick-frame-00.png` a `kick-frame-03.png`
- `toon-on-next-pass-no-duplicate.png`

## Notas Para Review

- A area paralela 04B2 (controller/root/HUD/menu) nao foi tocada.
- `assets/characters/**` foi usado somente como leitura.
- A intro UI ainda nao recebeu seletores de cabelo; a API ficou pronta em avatar/catalog para integracao posterior.
- Branch pronta para review; nao fazer merge sem aprovacao.
