# Track 09R - Foot And Camera Hotfix V1

- Data: 2026-06-19
- Agente: Codex
- Branch: `codex/jogodacopa/track09r-foot-camera-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09r-foot-camera-hotfix-v1`
- Status: local validado; nao publicado.

## Objetivo

Pausar reducoes do `FootballRoot` e corrigir dois problemas de playtest antes de continuar:

- pe/apoio visual do avatar entrando no campo;
- camera com pull/tilt estranho ao usar A/D em movimento lateral.

## Resultado

- Corrigido o clipping visual dos pes levantando somente `AvatarParts` em `0.05m`.
- Corrigido o feel lateral da camera reduzindo o foco na bola quando o strafe domina e mantendo horizonte nivelado.
- Gameplay, colisao, fisica, scoring, bot, SUPER, HUD, assets e tuning preservados.
- 09Q registrada como baseline publica aprovada por Fabio/tester.

## Validacao

- Import headless: PASS.
- Red tests antes da correcao:
  - avatar feet min_y `-0.009`, esperado `>= 0.025`;
  - lateral strafe ball focus `0.08`, esperado `<= 0.025`.
- `tools/validate.gd`: PASS, `106/106` testes, `1831` asserts.
- Web export: PASS.
- Web gzip gate: PASS, `30.61 MiB / 50.00 MiB`.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Chrome local 90s Web smoke: PASS, `pageErrors=0`, `consoleErrorCount=0`, `stabilityPassed=true`.
- Evidencia: `Projetos/JogoDaCopa/docs/playtest-reports/track-09r-foot-camera-hotfix.md` e `Projetos/JogoDaCopa/docs/playtest-reports/track-09r-data/`.

## Handoff

- Proximo passo: Fabio/tester retestar a 09R e decidir publicacao antes de novas reducoes.
- PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
