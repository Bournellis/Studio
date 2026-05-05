# Decisao: Regras pendentes do cardgame

## Metadata

- data: `2026-05-05`
- decisor: `Usuario`
- projeto: `rpg-turnos`

## Contexto

A revisao documental encontrou divergencias entre o GDD atualizado, o runtime Godot e documentos de status. Algumas inconsistencias exigiam decisao do usuario antes de consolidar os documentos e preparar a proxima implementacao.

## Decision

- `manter_linha` deve ser removida do plano ativo. A proxima implementacao deve deletar a carta do catalogo, generated resources, referencias de teste e asset planning ativo.
- A fase publica `descarte` deve existir no MVP.
- O descarte voluntario alem do minimo deve existir no MVP dentro da fase `descarte`.
- `golpe_preciso` deve ser tratado como recompensa introdutoria da NPC, separada da lista progressiva `npc_reward_choices`, mas ainda contado como carta unica desbloqueavel.
- O catalogo deve separar copias de deck, designs unicos, rewards unicas, enemy-only cards e entradas duplicadas de recompensa.
- `reward_card` deve ser substituido por `first_npc_reward_card`, mantendo compatibilidade temporaria se necessario.
- Encontros especificados mas ainda nao suportados devem permanecer documentados como `specified / not playable`, nao removidos silenciosamente.
- Save/load minimo fica documentado como proximo trabalho de progressao, nao requisito imediato desta rodada documental.
- `defensor` significa "nao ataca"; nao e `taunt/provocar`.
- Movimento de criaturas e regra geral de engine, mas sua exposicao de UI pode entrar apenas quando `duelo` ou boards neutros exigirem.
- `magia_de_tabuleiro` permanece tipo separado de `magia`.
- Reentrada em encontros concluidos para pratica deve existir no MVP, sem segunda recompensa.

## Alternatives Considered

- Manter `manter_linha` como carta futura ou experimental.
- Tratar `golpe_preciso` como uma carta normal da progressao progressiva da NPC.
- Adiar descarte voluntario para depois do MVP.
- Transformar `defensor` em `taunt/provocar`.

## Impact

Os documentos devem orientar a proxima implementacao para corrigir primeiro fundacoes de regra e estado: recursos, mao, deck ciclico, fase `descarte`, remocao de `size`, remocao de `manter_linha`, progressao por encontro e validacao. Trabalho visual, `duelo` e expansao de conteudo devem depender de status claro.

## Review When

Revisar depois que a proxima implementacao de engine passar validacao Godot/GUT e atualizar `implementation/current-status.md`.
