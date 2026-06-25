# Design Lab Calibration V1

- Data: `2026-06-25`
- Agente: `Codex`
- Projeto: `Projetos/draxos-roguelike-cardgame/`
- Branch: `codex/draxos-roguelike-cardgame/design-lab-calibration-v1`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--design-lab-calibration-v1`
- Status: `DONE_LOCAL_VALIDATED`

## Objetivo

Calibrar o Design Lab antes da criacao de novos packs de conteudo real, fortalecendo scoring, mechanic registry, context templates, reporter e packs/testes de calibracao.

## Entregue

- Baseline oficial de cartas para comparar prototipos contra vizinhos oficiais.
- Scorer calibrado com curva por custo, timing de entrada, risco de substituicao, redundancia e teto de papel.
- Registry de mecanicas V2 com actions, keywords, hooks, context templates e gates de promocao.
- `context_templates.json` para autoria por intent sem repetir harness em cada pack.
- Reporter e promotion manifest enriquecidos com vizinhos oficiais, riscos, falhas de contexto e perguntas de revisao.
- Packs de calibracao player/enemy/mechanics.
- Testes unitarios do Design Lab ampliados.
- Docs/status locais atualizados.

## Validacao

- `run_design_lab --pack=design_lab_sample_v1 --mode=gate --max-variants=3`: PASS, 9 candidates, 3 recommendations, 0 blocked.
- `run_design_lab --pack=design_lab_calibration_player_v1 --mode=explore --max-variants=8`: PASS, inclui recommended/viable/risky/broken.
- `run_design_lab --pack=design_lab_calibration_enemy_v1 --mode=explore --max-variants=8`: PASS, 16 candidates, 2 recommendations.
- `run_design_lab --pack=design_lab_calibration_mechanics_v1 --mode=explore --max-variants=4`: FAIL esperado, 1 blocked mechanic (`steal_mana`).
- `validate.gd`: PASS, 225/225 tests, 1969 asserts.

## Handoff

Proximo passo recomendado: criar o primeiro pack real de cartas por classe usando `context_template_ids`, com 3-5 ideias por classe e pelo menos uma ideia inimiga simples para validar o fluxo completo de autoria.
