# T05-G - DraxosMobile Release Ops

- Data: `2026-05-27`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/t05-release-ops`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t05-release-ops`
- Status: `READY_FOR_INTEGRATION`

## Objetivo

Estabilizar a fundacao operacional de release da Track 05 sem publicar build nova: revisar manifest/version gate, scripts de export/publicacao, documentacao Cloudflare Pages + Supabase Storage e smokes remotos existentes; formalizar checklist release-ready para Android, PC e Web.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/implementation-plan.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- Docs existentes de release somente se necessario:
  - `Projetos/draxos-mobile/docs/internal-alpha-release-plan.md`
  - `Projetos/draxos-mobile/docs/internal-alpha-static-hosting.md`
  - `Projetos/draxos-mobile/docs/supabase-remote-tutorial.md`
- Este registro Doing.

## Fora De Escopo

- Secrets, service role ou credenciais novas.
- Publicacao, redeploy, alteracao do manifest remoto real ou upload para Storage.
- Build final ou mudanca nos artefatos publicados.
- Mudanca de schema, economia, assets finais ou servicos novos.

## Validacao Planejada

- `tools/smoke_exports.gd`
- Checks seguros de scripts de export/publicacao quando houver modo sem publicar.
- `git diff --check`
- Documentar validacoes remotas que exigem credenciais em vez de executa-las.

## Proximo Handoff

Entregar checklist release-ready e lacunas de validacao remota para T05-H integrar com a matriz de validacao e os demais pacotes Track 05.

## Resultado

- Checklist release-ready criado para Android, PC Windows e Web.
- Smoke remoto somente leitura `release_artifacts_remote_smoke.ts` adicionado para manifest, APK/ZIP, Portal e Web build ja publicados.
- Docs de release/hosting/tools/server tests apontam o novo checklist e smoke.
- Nenhuma publicacao, upload, redeploy, secret, build final ou manifest remoto real foi alterado.
- Validado com `tools/smoke_exports.gd`, checks Deno de `supabase/functions` e `server/functions`, `deno check/lint` do novo smoke, parse seguro dos scripts PowerShell e `git diff --check`.
