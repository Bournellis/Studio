# DraxosMobile Handoff: Integrated Runtime Fix

## Metadata

- data: `2026-06-02`
- agente: `Codex`
- projeto: `draxos-mobile`
- branch: `codex/draxos-mobile/integrated-runtime-fix`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--integrated-runtime-fix`
- base_commit: `eff0997`
- status: `LOCAL_GATES_IN_PROGRESS`

## Objetivo

Corrigir o pacote integrado App/Arena/Bosque, validar o runtime real e publicar um unico Internal Alpha integrado na URL principal.

## Escopo Aplicado

- Bosque online:
  - serializa eventos autoritativos em fila;
  - usa a revisao mais recente depois de cada ACK;
  - evita mutacao local otimista de coleta, deposito e craft antes do servidor confirmar;
  - ressincroniza em erro nao transient e tenta novamente em erro de rede.
- Mode Platform:
  - `/modes/session/event` agora retorna envelope comum `stateEnvelope(...)`, igual aos outros endpoints de modo.
- Arena:
  - battle log autoritativo de duelo PVE agora inclui `metadata.mode = "PVE_ARENA_V1"`, permitindo que o cliente reconheca replay/resumo de Arena.
- Validacao:
  - smokes Bosque remoto/local agora exercitam `collect_start` antes de `collect_complete`;
  - contratos Deno exigem envelope em session/event, fila serial no client e metadata de Arena.

## Evidencia Local Ate Aqui

- `npx -y deno test --allow-read server/tests/modes_platform_schema_test.ts server/tests/arena_consistency_pass_schema_test.ts server/tests/modes_domain_test.ts`: PASS, 22 testes.
- `npx -y deno check server/functions/modes/mode_handler.ts supabase/functions/modes/mode_handler.ts server/functions/arena/index.ts supabase/functions/arena/index.ts server/tests/internal_alpha_remote_smoke.ts server/tests/modes_platform_live_test.ts`: PASS.
- Godot import headless: PASS.
- `Godot --headless --path . -s res://tools/validate.gd`: PASS, 179 testes.
- `Godot --headless --path . -s res://tools/smoke_openworld_forest.gd`: PASS.
- `Godot --headless --path . -s res://tools/smoke_responsive_layout.gd`: PASS.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`: PASS.

## Pendencias Antes De Fechar

- Repetir `ReleaseDryRun` sem card em `Kanban/Doing/`.
- Rodar `ClientQuick`/`ModePlatform` conforme tempo de gate.
- Exportar, empacotar, publicar, deployar Cloudflare Pages e manifest com `-ConfirmRemoteMutation`.
- Rodar smokes remotos autenticados de release, Arena e Bosque.
- Atualizar `implementation/current-status.md`, portfolio docs e este handoff com release root final.

## Remote Mutation Approval

Fabio aprovou em `2026-06-02` um unico release integrado na URL principal:

- `https://draxos-mobile-internal-alpha.pages.dev/`

Inclui Supabase DB push se necessario, Edge Functions, Supabase Storage, Cloudflare Pages, release manifest e contas/saves descartaveis de teste. Todos os comandos remotos ainda devem usar `-ConfirmRemoteMutation` quando exigido pelos scripts.
