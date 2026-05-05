# Tarefa: Duelo Oficial

## Metadata

- id: `2026-05-05_codex_rpg-turnos_duelo-oficial`
- owner: `Codex`
- status: `Done`
- projeto: `rpg-turnos`

## Goal

Implementar o modo oficial `duelo` depois da fundacao de regras, sem reintroduzir variantes antigas ou o `Duelo antigo`.

## Linear Implementation Order

1. Confirmar o estado parcial atual do `duelo`.
2. Implementar poder heroico inimigo `Golpe Direto`.
3. Ajustar IA agressiva deterministica: poder, jogar carta, atacar, passar.
4. Garantir uso do deck customizado do encontro `duelista_bandido`.
5. Implementar movimento de criaturas como acao normal.
6. Implementar slots neutros no engine quando o board definir `neutral_slots`.
7. Expor entrada para `duelista_bandido` como encontro oficial, nao como variante antiga.
8. Adicionar/atualizar GUT.
9. Rodar validacao Godot/GUT.
10. Atualizar status vivo e coordenacao.

## Out of Scope

- Cadeia completa de progressao/recompensas.
- Save/load.
- Phase H/J visual.
- Assets.

## Acceptance Criteria

- [x] `duelo` tem heroi inimigo com 20 HP.
- [x] IA usa `Golpe Direto` uma vez no proprio turno.
- [x] IA usa deck customizado do encontro.
- [x] Ataques em rota vazia no `duelo` atingem heroi.
- [x] Movimento de criaturas funciona como acao normal.
- [x] Slots neutros existem no engine quando o board define.
- [x] `tools/validate.gd` passa.

## Result

- Validacao Godot/GUT em `2026-05-05`: `49/49` testes passando.
- `duelo` oficial implementado no engine e exposto no fluxo como proximo encontro apos a emboscada inicial, sem restaurar seletor de variantes.
- Proximo passe linear recomendado: world progression/rewards.

## Handoff Needed

`No`
