# Code Review PRE-MERGE - Track 04B1 Character Presentation + Track 04B2 Feel & UI

- Date: `2026-06-11`
- Reviewer: Claude (Fable 5)
- Modo: primeira rodada PARALELA (2 threads, areas disjuntas) e primeiro review PRE-merge completo. Ambas pararam na branch com handoff, como instruido.
- Incidente #7 no main durante a rodada: delecoes staged de arquivos raiz (.gitignore/.gitattributes) + index corrompido (bad signature). Recuperado: read-tree + restore; main limpo e integro. As BRANCHES nao foram afetadas.

## Track 04B1 - Character Presentation (4 commits, +802/-68)

- **Uniforme de 6 regioes via bone weights: FUNCIONA E TRANSFORMA O JOGO.** Screenshots verificados: Brasil (camisa amarela + faixa verde, shorts azuis, meias brancas, chuteira escura, pele correta, cabelo curto escuro) e Franca (tricolor, pele escura, cabelo loiro LONGO) - as 6 regioes legiveis, kits trocam sem afetar pele, penteados reais do pack integrados.
- **Chute re-autorado**: frames verificados - pe na altura joelho/quadril, perna estendida no contato, contra-balanco de bracos. Commit dedicado "keep authored kick below pelvis" com teste de altura do foot vs pelvis.
- **Toon**: outline migrado para next_pass (acompanha skinning); teste de nao-duplicata.
- Notas de polish (NAO bloqueiam): bordas de regiao serrilhadas em punhos/bainha (estetica bone-weight; aceitavel como estilo low-poly - suavizacao opcional futura); "cinto" de transicao camisa/shorts com vazamento de 1-2 vertices em alguns angulos.

## Track 04B2 - Feel & UI (3 commits, +792/-79)

- **Dash com curva** (ease-out, mesma distancia +-5%, teste de aceleracao primeiro-frame < pico) - prova numerica no teste; sensacao final e veredito de Fabio.
- **Pulos verticais puros** sem input (testes de deslocamento zero X/Z) e direcionais com input.
- **Result panel clicavel**: mouse liberado (VISIBLE) ao abrir, teste de clique real em Rematch/Menu nas 3 resolucoes + auditoria estendida a pause e intro (regra de UI agora cobre TODOS os paineis).
- **Menu sem fundo preto**: preview renderiza campo + personagem; teste anti-tela-preta por luminancia. O personagem aparece SEM o uniforme novo - esperado (branch paralela sem a 04B1); o hero shot definitivo do menu fica para polish pos-merge.

## Disjuncao confirmada

Nenhum arquivo em comum entre os diffs das duas branches (verificado por stat). Merge sem conflito esperado.

## Verdict

**Ambas APROVADAS para merge.** Ordem: 04B2 primeiro (sem assets/shader novos), 04B1 em seguida (rebase/merge trivial por disjuncao). Apos os merges: rodada de manutencao do git (mini-prompt ja entregue: tmp_obj, gc, .gitignore builds/, prune) e ENTAO playtest de Fabio com tudo integrado - uniformes no jogo real, dash novo, pulos, result panel.

Follow-ups registrados para a proxima rodada: hero shot do menu (preview com uniforme + luz + enquadramento), suavizacao opcional de bordas de regiao, sessao de design dos modos (item 7 de Fabio, pendente).

## Adendo - Track 04B3 Kick Arms Polish V1 (review pre-merge 2026-06-11): APROVADA

- Escopo minimo respeitado: 1 commit de codigo, apenas keyframes de braco do `JogoDaCopa_Kick` (+34 linhas no avatar) + teste de guarda `test_authorial_kick_keeps_hands_below_head_and_upperarms_close` (+53).
- Keyframes verificados: variacoes sutis (+-2 a 18 graus) em torno da pose de bracos baixos; pernas/tronco/timing intocados.
- Evidencia visual analisada (8 frames, lateral + frontal): bracos junto ao corpo no apice do chute, punhos na altura do quadril, contra-balanco discreto e atletico - o "moinho de vento" foi eliminado; vista frontal confirma zero abertura lateral.
- Fabio aprovou visualmente a 04B3; liberada para merge local. Apos o merge: PUSH PENDENTE via GitHub Desktop.
