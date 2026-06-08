# DraxosMobile Hardening Doing: mode-scaffolds/client-shell - Bosque Feel & Spawn Authority v1

## Metadata

- data: `2026-06-08`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `mode-scaffolds + client-shell + validation-release`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/bosque-feel-spawn-authority-v1`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-feel-spawn-authority-v1`

## Objetivo

Corrigir os regressos de spawn/feel do Bosque apos Persistence Rebase v1 mantendo o servidor como autoridade duravel, mas devolvendo ao cliente a autoridade de preview, coleta fluida, reconciliacao sem rollback visual e botoes sem busy global desnecessario.

## Latest Context

- latest remote package: `Bosque Persistence Rebase v1`
- latest release root: `internal-alpha/v0-bosque-persistence-rebase-v1-20260608-bc23f74`
- Openworld contract source: `docs/minigames/openworld.md`
- Openworld decision source: `docs/minigames/openworld-decision-pack.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`
- release safety source: `implementation/tracks/track-13-validation-release-safety/`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-decision-pack.md`

## Escopo

- Incluir:
  - separar autoridade canonica do servidor de overlay local de coleta/cooldown;
  - remover `collected_nodes` legado do bloqueio principal de interacao v2;
  - usar offset de `server_time` para disponibilidade de nodes;
  - tornar coleta sticky e tolerante a movimento dentro do raio;
  - impedir flicker/rollback visual de nodes pendentes;
  - permitir fluxo mais livre de deposito/craft usando preview local honesto;
  - reduzir busy global de menu/acoes onde for seguro;
  - atualizar testes, docs, versao, release e publicacao Web/APK.
- Fora do escopo:
  - novo conteudo, mapa, inimigos, quests, economia ampla, PVP ou tuning numerico;
  - alterar segredo, service role ou credencial em docs/Git;
  - trabalhar em worktree de outro agente.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/openworld/*`
- `Projetos/draxos-mobile/modes/boot/*`
- `Projetos/draxos-mobile/online/session/*`
- `Projetos/draxos-mobile/tests/client/*openworld*`
- `Projetos/draxos-mobile/server/tests/*openworld*`
- `Projetos/draxos-mobile/server/functions/*`
- `Projetos/draxos-mobile/supabase/functions/*`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/minigames/openworld-decision-pack.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/core/project_info.gd`
- `Projetos/draxos-mobile/export_presets.cfg`
- `Projetos/draxos-mobile/server/functions/release/index.ts`
- `Projetos/draxos-mobile/supabase/functions/release/index.ts`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`

## Validation Plan

- Targeted GUT OpenWorld tests.
- Full GUT client when feasible.
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- Targeted OpenWorld server/Deno tests.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`
- release safety scripts, package/upload/deploy manifest, Cloudflare Pages deploy, remote smokes.
- `git diff --check`

## Handoff Point

Handoff apenas se a reconciliacao client/server ou a publicacao remota bloquear por credencial/infra indisponivel. Caso contrario, finalizar com commits logicos, fast-forward para `main`, publicacao Web/APK na URL principal e docs de status atualizados.
