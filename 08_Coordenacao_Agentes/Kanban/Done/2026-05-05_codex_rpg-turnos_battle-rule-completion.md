# Tarefa: Battle Rule Completion

## Metadata

- id: `2026-05-05_codex_rpg-turnos_battle-rule-completion`
- owner: `Codex`
- status: `Done`
- projeto: `rpg-turnos`

## Goal

Completar as regras de batalha que bloqueiam uma implementacao linear segura do `duelo` e da progressao: tipos de dano, `voadora`, queimando em slot/criatura, rotas avancadas e cobertura consistente.

## Linear Implementation Order

1. Corrigir status documental para separar Foundation Runtime Alignment de Battle Rule Completion.
2. Implementar sistema de tipos de dano: `fisico_melee`, `fisico_alcance`, `magico`.
3. Aplicar cobertura apenas a `fisico_alcance`, com stack de terreno + keyword.
4. Implementar `queimando` como status de slot e de criatura.
5. Implementar `voadora`: entra pronta, pode alcancar `alto`, nao recebe `fisico_melee`, fica transparente para roteamento melee.
6. Implementar `fallback_slots` de rota.
7. Atualizar testes GUT para cada regra.
8. Rodar validacao Godot/GUT.
9. Atualizar `implementation/current-status.md`, Track 01, Roadmap e `Estado_Atual.md`.

## Out of Scope

- `duelo` oficial completo.
- Progressao/recompensas de mundo.
- Phase H/J visual.
- Assets.

## Acceptance Criteria

- [x] `tools/validate.gd` passa.
- [x] `BattleEngine` nao mistura regras de dano com apresentacao.
- [x] `voadora` tem cobertura GUT.
- [x] `queimando` dual tem cobertura GUT.
- [x] Rotas com `fallback_slots` tem cobertura GUT.
- [x] Status vivo aponta para o proximo passe linear.

## Result

- Validacao Godot/GUT em `2026-05-05`: `45/45` testes passando.
- Implementado: tipos de dano, cobertura por terreno/keyword, `voadora`, queimando em slot/criatura, `fallback_slots`, magia de tabuleiro para `chuva_brasas` e `chamado_hostes`.
- Proximo passe linear recomendado: `duelo` oficial.

## Handoff Needed

`No`
