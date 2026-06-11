# Tarefa: JogoDaCopa Track 03F Quality Hotfix V1

## Metadata

- id: `2026-06-10_codex_jogodacopa_track03f-quality-hotfix-v1`
- owner: `Codex`
- status: `Done`
- projeto: `JogoDaCopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/jogodacopa/track03f-quality-hotfix-v1`
- worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03f-quality-hotfix-v1`

## Goal

Implementar `Track 03F - Quality Hotfix V1`: fixes consolidados dos code reviews das series Track 03 e Track 02C-bis/02D-bis, tuning objetivo de playtest de Fabio quando houver notas, validacao reforcada e fechamento seguro.

## Delivered

- Super do jogador so consome barra/cota quando o chute conecta.
- Avatar real preserva materiais PBR/texturas por surface, com tint global de kit.
- Sobrancelha usa tom neutro escuro em vez de cor do kit.
- Performance sampler documenta metodologia de janela real 1920x1080/vsync off e imprime display/resolucao/modo.
- `validate.gd` checa integridade de `.gd` e `.gdshader` fora de `addons/`.
- Sem notas objetivas de playtest de Fabio nesta thread; nenhum tuning subjetivo foi aplicado.
- Toon permanece experimento em toggle OFF ate decisao explicita.

## Validation

- `tools/validate.gd`: PASS, 50 tests, 466 asserts.
- Source integrity: PASS, 26 `.gd/.gdshader` files loaded outside `addons/`.
- Performance sample: PASS, windowed 1920x1080, vsync off, display `Windows`, average `730.8fps`, min warmed instant `488.8fps`, `0/360` frames below 60.
- `git diff --check`: PASS.

## Commits

- `7daf624 chore(jogodacopa): register track 03f hotfix`
- `6c6bf73 fix(jogodacopa): apply track 03f review hotfixes`
- `8e35a62 docs(jogodacopa): record track 03f playtest tuning status`

## Next Step

Playtest de confirmacao do hotfix + decisao da proxima serie com Claude.
