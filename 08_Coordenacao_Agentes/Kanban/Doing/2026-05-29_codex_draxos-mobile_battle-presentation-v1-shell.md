# Battle Presentation v1 Shell - Agente A

- Data: 2026-05-29
- Agente: Codex / Agente A - Battle UX Shell
- Branch: `codex/draxos-mobile/battle-presentation-v1-shell`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--battle-presentation-v1-shell`
- Projeto: `Projetos/draxos-mobile`

## Objetivo

Implementar a parte Shell/Presenter de Battle Presentation v1, client-only, sem backend/schema/API/simulador/economia.

## Escopo Pretendido

- Principal: `Projetos/draxos-mobile/modes/boot/surfaces/battle_replay_presenter.gd`
- Testes/smokes se necessario: `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`, `Projetos/draxos-mobile/tools/smoke_mobile_presentation.gd`, `Projetos/draxos-mobile/tools/smoke_responsive_layout.gd`
- Evitar alteracoes em `BattleVisualMockup`, `BattleStage2D`, `BattleLogPresenter`, salvo necessidade comprovada.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Plano De Validacao

- Teste client/GUT focado, se aplicavel.
- `tools/smoke_mobile_presentation.gd` e/ou `tools/smoke_responsive_layout.gd` por tocar Battle visual/layout.
- `git diff --check`.

## Handoff Esperado

Entregar commit logico na propria branch se a validacao basica passar; se nao passar, deixar sem commit e registrar exatamente o estado pendente.

## Resultado

- Shell running: faixa compacta `BattleDuelShellBand` com jogador vs oponente, progresso de lances e estado atual; controle unico `Pular batalha`.
- Summary: hierarquia reorganizada com resultado grande, desfecho contra oponente, recompensa, recursos/ranking opcionais e CTAs `Voltar e verificar base` / `Ver logs da batalha`.
- Logs: mantidos read-only e locais ao replay atual.
- Backend/schema/API/simulador/economia: sem alteracoes.

## Validacao Executada

- Godot import headless: PASS, com warnings conhecidos de import/GUT e leak no encerramento.
- GUT `tests/client`: PASS (`119/119`, `1891` asserts).
- `tools/smoke_mobile_presentation.gd`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS.
- `tools/smoke_foundation_hardening.gd`: PASS.
- `git diff --check`: PASS.
