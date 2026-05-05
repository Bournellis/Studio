# Tarefa: Foundation Runtime Alignment

## Metadata

- id: `2026-05-05_codex_rpg-turnos_foundation-runtime-alignment`
- owner: `Codex`
- status: `Done`
- projeto: `rpg-turnos`

## Goal

Alinhar o runtime Godot do cardgame C1 com as regras aceitas no GDD antes de iniciar `duelo`, expansao visual H/J, progressao de campanha ou conteudo novo.

## Pre-Implementation Checklist

- [x] Confirmar que o git esta limpo ou separar alteracoes existentes antes de editar.
- [x] Confirmar que a validacao atual falha apenas por teste obsoleto conhecido.
- [x] Corrigir referencia estrutural de roadmap/status se necessario.
- [x] Remover legado de `size` / `size_limit` de engine e testes.
- [x] Deletar `manter_linha` do catalogo ativo, recursos gerados, testes e planejamento ativo.
- [x] Renomear recompensa introdutoria para `first_npc_reward_card`, mantendo compatibilidade temporaria com `reward_card` se necessario.
- [x] Implementar energia por controlador com ramp 3->8.
- [x] Implementar mao inicial 5.
- [x] Implementar `max_hand_size` por controlador com ramp 5->7.
- [x] Implementar deck ciclico sem pilha de descarte.
- [x] Implementar fase publica `descarte` apos `fase_principal`.
- [x] Implementar descarte obrigatorio/voluntario para jogador e descarte automatico para inimigo.
- [x] Implementar gatilho imediato quando a mao chegar a 9 cartas.
- [x] Atualizar GUT para cobrir as regras novas e remover expectativas obsoletas.
- [x] Rodar `tools/validate.gd` e registrar resultado.

## Out of Scope

- Implementar `duelo` completo.
- Implementar Phase H/J visual.
- Importar assets.
- Implementar save/load.
- Expandir narrativa, mundo ou campanha.

## Acceptance Criteria

- [x] `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd` passa.
- [x] Runtime nao expoe pilha de descarte como regra ativa.
- [x] `implementation/current-status.md` separa corretamente o que foi implementado do que ainda fica pendente.
- [x] `08_Coordenacao_Agentes/Estado_Atual.md` aponta para a proxima etapa apos a fundacao.

## Result

- Validacao Godot/GUT em `2026-05-05`: `37/37` testes passando.
- Foundation Runtime Alignment completo.
- Proximo passo: selecionar entre battle-rule completion, `duelo`, ou world progression/rewards.

## Handoff Needed

`No`
