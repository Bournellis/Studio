# Track 03K - Animation Pose Restore V2

- Data: `2026-06-11`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/track03k-animation-pose-restore-v2`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03k-animation-pose-restore-v2`
- Status: `DONE`

## Objetivo

Corrigir o hotfix de animacao da Track 03H removendo a manipulacao manual de keyframes do root motion. A nova abordagem deve apagar tracks completas de position/rotation do bone `root` nos clipes carregados, preservando pelvis e demais bones originais para restaurar a pose em pe e a vida da animacao.

## Escopo

- Teste primeiro para reproduzir personagem deitado/enterrado apos `Idle`.
- Remover `_strip_root_motion` e auxiliares que editam valores de keyframes.
- Deletar tracks de position/rotation apontando para o bone `root` ao copiar clipes UAL.
- Manter reset de pose na troca de estado.
- Adicionar guarda objetiva: clipes sem tracks do `root` e com pelvis vivo em `Jog_Fwd`.
- Nao alterar tuning, materiais, bot, UI, audio, arena ou assets.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/gameplay/avatar/player_avatar_3d.gd`
- `Projetos/JogoDaCopa/tests/...` (testes de avatar/animacao existentes)
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/implementation/tracks/track-03k-animation-pose-restore-v2/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- Este card, movido para `Kanban/Done` no fechamento

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/code-review-track03i-menu-v1.md`

## Validacao Planejada

- Rodar o novo teste primeiro e confirmar falha no codigo atual.
- Rodar o teste apos o fix e confirmar PASS.
- Rodar `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`.
- Rodar `git diff --check`.
- Rodar `tools/check_doc_drift.ps1`.
- Confirmar `git status --short` limpo no worktree e `WORKTREE_VERIFIED`.

## Progresso

- [x] Fase 1: review 03I commitado em `main`, branches `codex/*` mergeadas deletadas, worktree/branch criadas e card Doing registrado.
- [x] Fase 2: teste primeiro de pose vertical criado e falha confirmada no codigo atual (`pelvis.y = 0.0`, `spine_03`/`hand_l` abaixo da base).
- [x] Fase 3: strip manual de keyframes removido; clipes UAL agora removem tracks completas do bone `root`; `pelvis` preservado.
- [x] Fase 4: status/docs atualizados, validacao principal PASS e proximo passo definido como playtest humano do Fabio.

## Fechamento

- Teste focado de pose: PASS, `1/1`, `23` asserts.
- Teste focado de drift/root/pelvis: PASS, `1/1`, `96` asserts.
- `tools/validate.gd`: PASS, `59/59` tests, `733` asserts, integridade de `27` fontes.
- Causa raiz documentada em `Projetos/JogoDaCopa/implementation/tracks/track-03k-animation-pose-restore-v2/current-status.md`.

## Proximo Handoff

Fabio deve fazer playtest de confirmacao de pose e vida da animacao. O juiz final de qualidade da animacao e o olho humano; os testes cobrem drift e regressao objetiva.
