# Hotfix 04E.1 - Night Capture & Source Integrity

- Data: `2026-06-11`
- Agente: Codex
- Projeto: `Projetos/JogoDaCopa/`
- Branch: `codex/jogodacopa/track04e-web-spike-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track04e`
- Status: `DOING`

## Motivo

Review pre-merge da Claude em `Projetos/JogoDaCopa/docs/code-review-track04e-web-spike-v1.md` marcou a Track 04E como **NAO APROVADA AINDA**: as capturas de jogo desktop/Web ficaram lavadas/claras, apesar do jogo real no editor manter a arena noturna aprovada. O review tambem encontrou BOM U+FEFF em cinco fontes.

## Ordem Obrigatoria

1. Criar primeiro teste vermelho para o bug de captura: `WorldEnvironment` correto em modo captura e luminancia do ceu noturno capturado `< 90`.
2. Confirmar o teste vermelho antes de qualquer fix.
3. Rodar captura com console/debugger e documentar a causa raiz antes de corrigir.
4. Corrigir e deixar o teste verde.
5. Remover BOM dos cinco arquivos citados e fazer o source-integrity rejeitar BOM em `.gd/.gdshader`.
6. Promover o check de luminancia para o gate Web permanente.
7. Recapturar desktop + Web: menu hero, kickoff, goal, result e play.
8. Refazer o inventario de paridade em `docs/playtest-reports/track-04e-web-spike.md`.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/docs/code-review-track04e-web-spike-v1.md`
- `Projetos/JogoDaCopa/tests/`
- `Projetos/JogoDaCopa/tools/`
- `Projetos/JogoDaCopa/modes/`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-04e-web-spike.md`
- `Projetos/JogoDaCopa/docs/screenshots/track-04e-web-spike/`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/docs/validation.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Handoffs/`
- `08_Coordenacao_Agentes/Kanban/`

## Validacao Planejada

- Teste vermelho do bug antes do fix.
- Teste verde apos o fix.
- `tools/validate.gd` completo PASS.
- Web export PASS.
- Chrome smoke PASS.
- Capturas desktop/Web refeitas e verificadas por luminancia.
- `git diff --check`.
- `git status --short` limpo.
- Integridade de fontes.
- `WORKTREE_VERIFIED`.

## Handoff Point

Parar na mesma branch em Review com handoff atualizado para novo review pre-merge da Claude e veredito visual de Fabio.
