# DraxosMobile - T06-C Runtime Config

- Data: `2026-05-27`
- Agente: Codex
- Projeto: `Projetos/draxos-mobile/`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t06-runtime-config`
- Branch: `codex/draxos-mobile/t06-runtime-config`
- Status: `READY_FOR_MERGE`

## Objetivo

Implementar `GET /release/config` como endpoint release-scoped read-only, sem secrets e sem gameplay state mutavel, retornando `runtime_config_v1` com flags conservadoras para features T06.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-05-27_codex_draxos-mobile_t06-coordenacao.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/supabase/functions/release/`
- `Projetos/draxos-mobile/server/functions/release/`
- `Projetos/draxos-mobile/online/supabase_client.gd`
- `Projetos/draxos-mobile/modes/boot/boot.gd` ou surface presenter existente, se necessario
- `Projetos/draxos-mobile/docs/contracts/api-endpoints.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/`
- Smokes/testes focados para runtime config

## Validacao Planejada

```powershell
npx -y deno task --cwd supabase/functions check
npx -y deno task --cwd server/functions check
# novo smoke runtime config
godot --headless --path . --script tools/validate.gd
# GUT se cliente for tocado
git diff --check
```

## Entregue

- `GET /release/config` adicionado ao release service espelhado em `supabase/functions/release/` e `server/functions/release/`.
- Payload `runtime_config_v1` com flags T06 allowlisted e defaults conservadores.
- Cliente Godot com `RuntimeConfig`, URL derivada em `BackendConfig`, `SupabaseClient.fetch_runtime_config()`, fallback no `SessionStore` e fetch inicial no Boot.
- Contrato atualizado em `docs/contracts/api-endpoints.md`.
- Smoke TS e smoke Godot focados adicionados.

## Validacao Executada

```powershell
npx -y deno task --cwd supabase/functions check
npx -y deno task --cwd server/functions check
npx -y deno check server/tests/runtime_config_smoke.ts
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-runtime-config\Projetos\draxos-mobile -s res://tools/smoke_runtime_config.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-runtime-config\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-runtime-config\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
```

Resultados:

- Deno checks passaram.
- `tools/smoke_runtime_config.gd` passou.
- `tools/validate.gd` passou com `66/66` testes e `722` asserts.
- GUT client passou com `66/66` testes e `722` asserts.
- `release_manifest_smoke.ts` e `runtime_config_smoke.ts` passaram contra `server/functions/release/index.ts` servido localmente por Deno em `127.0.0.1:8000`.
- `runtime_config_smoke.ts` passou contra `supabase/functions/release/index.ts` servido localmente por Deno em `127.0.0.1:8000`.

Nota: Supabase local em `127.0.0.1:54321` estava servindo a funcao antiga e retornou `404 Unknown release endpoint` para `/release/config`; nao reiniciei nem publiquei a funcao para evitar tocar runtime compartilhado/remoto.

## Handoff

Pronto para merge/integracao com T06-B/T06-I. Pendencia operacional: atualizar/reiniciar Supabase local ou redeploy remoto somente no pacote de integracao/publicacao autorizado.
