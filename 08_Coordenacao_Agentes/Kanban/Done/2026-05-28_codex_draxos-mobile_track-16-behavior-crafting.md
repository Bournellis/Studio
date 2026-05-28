# Track 16 - DraxosMobile Behavior And Potion Crafting

- status: `Done`
- projeto: `draxos-mobile`
- agente: `Codex`
- branch: `codex/draxos-mobile/track-16-behavior-crafting`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--track-16-behavior-crafting`
- base: `master` at `5922fcb`
- data: `2026-05-28`

## Objetivo

Implementar comportamento configuravel para spells e pocoes, reescalar Ossos para inteiros, adicionar Po de Osso, crafting inicial de Pocoes e a primeira Pocao de Vida server-authoritative.

## Fora De Escopo

- iOS, mobile browser, publicacao remota, pagamento real, account/save migration e tuning numerico amplo.
- Alterar autoridade do cliente sobre recursos, crafting, comportamento, batalha ou cura.
- Dar pocoes gratis no estado inicial.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/docs/`
- `Projetos/draxos-mobile/data/definitions/`
- `Projetos/draxos-mobile/tools/content_generator.gd`
- `Projetos/draxos-mobile/supabase/migrations/`
- `Projetos/draxos-mobile/server/schema/migrations/`
- `Projetos/draxos-mobile/supabase/functions/`
- `Projetos/draxos-mobile/server/functions/`
- `Projetos/draxos-mobile/modes/boot/`
- `Projetos/draxos-mobile/ui/`
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/server/tests/`
- `Projetos/draxos-mobile/tools/`
- `08_Coordenacao_Agentes/`
- `Projetos/README.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/economy/README.md`
- `Projetos/draxos-mobile/docs/contracts/api-endpoints.md`
- `Projetos/draxos-mobile/docs/contracts/database-schema.md`
- `Projetos/draxos-mobile/docs/contracts/battle-event-log.md`
- `Projetos/draxos-mobile/docs/contracts/content-definitions.md`
- plano aprovado pelo usuario para comportamento, Po de Osso e crafting de pocoes

## Validacao Planejada

```powershell
cd D:\Estudio-worktrees\draxos-mobile--codex--track-16-behavior-crafting\Projetos\draxos-mobile
npx -y deno task --cwd server/functions check
npx -y deno task --cwd supabase/functions check
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { .\tools\validate_foundation.ps1 -ProjectDir . -Profile Client -RequireClean:`$false }"
git diff --check
git status --short
```

## Estado Atual

Implementacao local concluida e validada em 2026-05-28. Nada foi publicado remotamente.

Entregue:

- schema/migrations espelhadas, Edge Functions `crafting` e `build`, simulador de batalha com comportamento/pocao, UI Godot de crafting/preparacao, docs/contratos e modelos de economia/Progression Lab reescalados;
- `pocao_vida` cura `20%` em `5s`, com um uso por batalha por slot e consumo de inventario server-authoritative;
- reset/apply do Progression Lab limpam estado Track 16 via Edge Function, e novos players recebem slot de pocao default por trigger.

Validacao executada:

- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `npx -y deno test --allow-read server/tests/first_slice_simulator_test.ts`
- `npx -y deno test tools/progression_lab`
- `npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`
- `powershell -NoProfile -ExecutionPolicy Bypass -Command "& { .\tools\validate_foundation.ps1 -ProjectDir . -Profile Client -RequireClean:`$false }"`
- `git diff --check`

## Handoff

Track 16 ficou como ultimo pacote tecnico local, concluido e validado, sem publicacao remota. A etapa ativa de produto foi reorientada para `FOUNDATION_AUDIT_ACTIVE`; este card sai de Doing para nao induzir agentes a tratar Track 16 como foco operacional atual.
