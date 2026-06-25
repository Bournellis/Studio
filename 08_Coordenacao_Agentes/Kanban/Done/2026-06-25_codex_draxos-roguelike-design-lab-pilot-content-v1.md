# Design Lab Pilot Content V1

- Data: `2026-06-25`
- Agente: `Codex`
- Projeto: `Projetos/draxos-roguelike-cardgame/`
- Branch: `codex/draxos-roguelike-cardgame/design-lab-pilot-content-v1`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--design-lab-pilot-content-v1`

## Entrega

- Criado `design_lab_pilot_content_v1.json` com 13 ideias lab-only:
  - 4 Arcano, incluindo 1 mecanica futura bloqueada (`steal_mana`).
  - 3 Invocador.
  - 3 Necromante.
  - 3 cartas inimigas.
- Rodado explore completo para testar comportamento real do lab com conteudo misto.
- Rodado gate filtrado para provar fluxo de promocao de subconjunto pronto.
- Corrigido bug em `--card`/`--cards` com multiplos IDs, que antes voltava a rodar o pack inteiro.
- Melhorado `design_lab_gate.md` para separar hard blockers de variantes rejeitadas (`broken`, `risky`, `weak`).

## Resultados Do Lab

- Full explore:
  - Comando: `run_design_lab --pack=design_lab_pilot_content_v1 --mode=explore --max-variants=8 --out=user://design_lab/pilot_content_v1_explore`
  - Resultado: FAIL esperado.
  - 93 candidatos.
  - 11 recomendacoes selecionadas.
  - 1 mecanica bloqueada: `steal_mana`.
  - Rejeicoes uteis: 8 `broken`, 6 `risky`.
- Promotable subset gate:
  - Comando: `run_design_lab --pack=design_lab_pilot_content_v1 --mode=gate --max-variants=12 --card=<11 ids promotaveis> --out=user://design_lab/pilot_content_v1_gate_promotable`
  - Resultado: PASS.
  - 104 candidatos.
  - 11 recomendacoes selecionadas.
  - 0 mecanicas bloqueadas.

## Diagnosticos

- O lab ja funciona bem como ponte entre ideia e numero jogavel para mecanicas existentes.
- A mecanica `steal_mana` foi bloqueada corretamente, sem falso tuning.
- `pilot_enemy_ar_falcao_rapido` ficou fora do gate promotavel: todas as variantes foram `risky` ou `broken`, bom sinal de que o lab consegue rejeitar uma ideia implementada que ainda nao tem numero/contexto seguro.
- `pilot_arcano_eco_ether` mostrou que card-flow ainda pode precisar de scorer/assinatura mais sensivel para diferenciar quantidade de compra de cartas.
- O bug de filtro multi-card era bloqueador para workflow real de promocao parcial e ficou coberto por teste unitario.

## Validacao

- `run_design_lab.gd` full explore: PASS operacional com gate FAIL esperado.
- `run_design_lab.gd` promotable subset gate: PASS.
- `tools/validate.gd`: PASS, 226/226 testes, 1975 asserts.
- `tools/check_doc_drift.ps1`: PASS.

## Proximo Passo Recomendado

Usar esse pack como molde para criar packs reais por familia:

1. `arcano_cards_wave01`
2. `invocador_cards_wave01`
3. `necromante_cards_wave01`
4. `enemy_cards_terra_gelo_ar_wave01`

Cada pack deve separar ideias com mecanicas implementadas de mecanicas bloqueadas, rodando `explore` completo e `gate` de subconjunto promotavel antes de qualquer promocao manual.
