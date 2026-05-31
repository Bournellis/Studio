# Multi-Agent Doing: DraxosMobile Track 18 PVE Arena Integration

## Metadata

- data: `2026-05-31`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/pve-arena-integration`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--pve-arena-integration`

## Objetivo

Implementar a virada completa para Arena PVE inicial, mantendo Foundation Final Polish como base e separando PVE de PVP/ranking.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`

## Escopo

- Incluir: Track 18, contratos, dados, backend transacional, Edge Functions, cliente Godot, labs, testes, validacao e handoff de release local.
- Fora do escopo: publicacao remota sem aprovacao explicita, PVP como core inicial, novas armas/spells/pocoes/assets finais, economia ampla e comportamento avancado por inimigo.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/docs/`
- `Projetos/draxos-mobile/docs/contracts/`
- `Projetos/draxos-mobile/data/definitions/`
- `Projetos/draxos-mobile/server/`
- `Projetos/draxos-mobile/supabase/`
- `Projetos/draxos-mobile/modes/`
- `Projetos/draxos-mobile/online/`
- `Projetos/draxos-mobile/tools/`
- `Projetos/draxos-mobile/tests/`
- `08_Coordenacao_Agentes/`

## Plano De Commit

- `docs: start track 18 pve arena coordination`
- `contracts: define pve arena contracts and content`
- `backend: add server-authoritative pve arena state`
- `client: add pve arena shell flow`
- `test: validate pve arena labs and gates`

## Validacao

- `git diff --check`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Full -RequireClean`

## Proximo Handoff

Track 18 integrado localmente em `codex/draxos-mobile/pve-arena-integration`.

## Resultado

- Contratos/dados/backend das branches `arena-contracts` e `arena-backend` integrados.
- Shell Godot da Arena PVE, estado de sessão, endpoints cliente e labs integrados direto na branch de integração.
- Battle Lab agora gera `battle_lab_arena_sequences.csv`.
- Progression Lab agora gera `arena_progression_checks.csv`.
- Godot `tools/validate.gd` passou com 134/134 testes depois de import headless dos assets.
- Pendente pós-commit: rodar `check_foundation_expansion_readiness.ps1`, `validate_foundation.ps1 -Profile Full -RequireClean` e pacote local Internal Alpha.
