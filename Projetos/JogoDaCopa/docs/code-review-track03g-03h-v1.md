# Code Review - Track 03G Playtest Findings V1 + Track 03H Avatar Parity & Drift V1

- Date: `2026-06-11` (recriado apos perda de untracked em fechamento de thread; conteudo original preservado)
- Reviewer: Claude (Fable 5)
- Scope: 03G (`7daf624..d00833b`, +677/-78) e 03H (`4adb4d1..078df1b`), revisao pos-merge.
- Validacao reportada: 03G 56 tests/505 asserts; 03H 57 tests/724 asserts.

## Incidente de fechamento #3 (resolvido)

Apos o fechamento da 03H: truncamento de fontes (794 del) + `.git/config` preso em delete-pending + `.git/index` com entrada null sha1. Recuperacao por Claude: revalidacao do config via rename, `git read-tree HEAD`, `git restore`, verificacao de 108 fontes. Zero perda de historico. Conclusao: `WORKTREE_VERIFIED` nao cobre corrupcao pos-impressao; mitigacao e espera humana + ritual de Claude.

Nota positiva: a thread da 03G encontrou main sujo ao iniciar, PAROU e registrou handoff (`Handoffs/*_blocked-dirty-main.md`) - conforme instruido.

## Track 03G - verificado

- F1 menu responsivo (superado depois pela 03I, que achou a causa raiz real: raiz 0x0).
- F2 selecao so na intro (decisao de Fabio).
- F3 dash tunado com paridade.
- F4 kickoff hold com liberacao central via `_notify_player_touched_ball()` (toque real libera) + defesa aerea com delay por dificuldade.
- F5 clamp de colisao na chase camera.
- F6 causa raiz DUPLA documentada: reset de RigidBody ativo (corrigido com freeze + PhysicsServer + unfreeze deferred) e spawn alternado +-9m sem sinalizacao (marcador + anunciador SAIDA).

### Issue (minor, EM ABERTO)

| # | Arquivo | Issue |
|---|---|---|
| L1 | `football_bot.gd._handle_aerial_goal_defense` | Tracking de ameaca aerea reseta o delay quando a condicao oscila (bola quicando na borda) - bot pode travar em micro-delays. Adicionar histerese/cooldown minimo (~0.5s) de tracking. Pendente para proxima track de bot. |

## Track 03H - verificado

- Causa raiz real do "bot sem modelo": a capsula primitiva do `combatant_3d` renderizava POR CIMA do modelo real. Fix minimo: `set_combatant_body_visible(false)`. Logs permanentes de fallback adicionados.
- Teste de paridade na cena montada (player E bot com modelo real) - lacuna fechada.
- Strip de root motion: implementado na 03H com manipulacao de keys; CORRIGIDO depois pela 03K (remocao de track inteira do root) apos efeitos colaterais de pose. Historico completo no review da 03K.

## Verdict

Aprovadas na epoca; o strip da 03H foi posteriormente substituido (03K). Follow-up vivo: L1 (histerese da defesa aerea).
