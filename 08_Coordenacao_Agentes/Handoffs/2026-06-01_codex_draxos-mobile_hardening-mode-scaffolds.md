# DraxosMobile - Hardening Mode Scaffolds

- Status: `ENTREGUE_LOCAL`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/hardening-mode-scaffolds`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--hardening-mode-scaffolds`
- Base commit: `ceedd20`
- Objetivo: entregar scaffolds declarativos de modos para Basebuilder, Autobattler, Openworld, Towerdefense e Cardgame, com template de futuros modos, docs/minigames por modo, placeholders nao jogaveis em `data/definitions/modes/<mode_id>/` e testes minimos de descriptor/registry.
- Freeze: sem gameplay, tuning, reward novo, schema/backend remoto ou publicacao.

## Escopo Pretendido

- `Projetos/draxos-mobile/data/definitions/modes/`
- `Projetos/draxos-mobile/docs/minigames/`
- registry/loader minimo de modos, se necessario.
- testes locais de descriptor/registry.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/foundation-app-v0-audit.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Validacao Planejada

- `git diff --check`
- teste minimo de descriptor/registry identificado ou criado nesta lane.
- `validate_foundation.ps1 -Profile Quick` se os checks estruturais cobrirem os novos docs/dados.

## Proximo Handoff

- Descriptors declarativos adicionados para `basebuilder`, `autobattler`,
  `openworld`, `towerdefense` e `cardgame`.
- Placeholders nao jogaveis adicionados para os cinco modos.
- Template de future mode descriptor/doc adicionado.
- Docs por modo adicionadas em `docs/minigames/`.
- Registry client passou a expor paths/helpers de descriptor e placeholder.
- Testes minimos adicionados para descriptor/registry.

## Validacao Executada

- `npx -y deno fmt server/tests/mode_descriptors_contract_test.ts`: PASS.
- `npx -y deno lint server/tests/mode_descriptors_contract_test.ts`: PASS.
- `npx -y deno test --allow-read server/tests/modes_registry_contract_test.ts server/tests/mode_descriptors_contract_test.ts`: PASS (`4` tests).
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --import`: PASS; import em worktree fresco emitiu warnings conhecidos de assets GUT antes da reimportacao.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`: PASS (`156/156`, `2519` asserts).
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick`: PASS (`71` Deno foundation tests; descriptor check included through `modes_registry_contract_test.ts`).
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_mode_hub.gd`: PASS.

## Blockers

- Nenhum blocker local.
- Remote publish, backend/schema mutation, tuning, rewards e gameplay novo ficaram fora de escopo por freeze.
