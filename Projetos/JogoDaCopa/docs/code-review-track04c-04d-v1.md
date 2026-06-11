# Code Review PRE-MERGE - Track 04C Stadium Visual + Track 04D Match Completeness

- Date: `2026-06-11`
- Reviewer: Claude (Fable 5)
- Segunda rodada paralela. Ambas pararam na branch com handoff e evidencia completa.

## Track 04C - Stadium Visual Upgrade (+624/-74)

- Arquibancadas em camadas com recuo visivel nas vistas lateral/alta; blocos de torcida nas CORES DOS KITS da partida (amarelo/azul visiveis atraves do vidro ao nivel do campo); `crowd_excitement` exposto no builder com frame de festa capturado (blocos deslocados em onda); teloes/bandeiras/halos entregues; budget web respeitado (sem luzes novas com sombra).
- Nota N1 (nao bloqueia): a skyline do horizonte ficou MUITO timida/escura na vista alta - quase invisivel contra o ceu noturno. Aceitavel como "noite fechada"; se Fabio quiser presenca, e ajuste de emissive/altura em track de polish.
- Integracao pendente registrada (como instruido, sem tocar root): ligar `set_crowd_excitement(1.0)` ao evento de gol - item de 5 linhas para a proxima track que tocar o root.

## Track 04D - Match Completeness (+1169/-61)

- **Hero shot do menu: o melhor frame do jogo ate aqui** - personagem uniformizado de costas em primeiro plano, bola e gol neon ao fundo, painel a direita; composicao de capa de jogo. Teste anti-tela-preta mantido.
- Result screen rica verificada: VITORIA 3-1 com bandeiras, gols por periodo, chutes, posse por toques, supers usados, maior sequencia; Rematch/Sair com teste de clique real. Estatisticas como dados puros testaveis (test_rule_helpers +25).
- Pause menu completo com clique real; transicoes fade em 3 frames de evidencia; capture tool dedicado da track (`capture_track04d_match_completeness.gd`).

## Conflito previsto no segundo merge (licao de processo)

As duas branches editaram `tests/unit/test_bootstrap.gd` (adicao de testes em ambas) - falha de especificacao MINHA na divisao de areas. Resolucao trivial: manter AMBOS os blocos de teste. LICAO REGISTRADA: proximas rodadas paralelas reservam arquivo de teste proprio por track (ex.: test_stadium.gd / test_match_flow.gd).

## Verdict

**Ambas APROVADAS para merge**, ordem: 04D primeiro (maior; merge limpo), 04C em seguida (resolver o conflito de test_bootstrap mantendo os dois blocos; validate integrado obrigatorio pos-resolucao). Apos os merges + push: Track 04E (web spike) - a reta final.
