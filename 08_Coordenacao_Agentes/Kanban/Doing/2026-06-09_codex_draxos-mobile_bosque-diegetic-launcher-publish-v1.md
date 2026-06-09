# DraxosMobile - Bosque Diegetic Launcher Publish v1

## Objetivo

Publicar Web + APK do pacote `Bosque Diegetic Launcher Foundation v1` como novo Internal Alpha remoto do DraxosMobile, mantendo o contrato de release existente para manifest/downloads e sem abrir backend/schema/tuning/economia/conteudo fora do escopo.

## Execucao

- Agente: Codex
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-diegetic-launcher-publish-v1`
- Branch: `codex/draxos-mobile/bosque-diegetic-launcher-publish-v1`
- Base: `main` atualizado em `1eb43a8`
- Data: `2026-06-09`

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `canon/canon-brief.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/implementation/tracks/track-13-validation-release-safety/release-safety-contract.md`
- `Projetos/draxos-mobile/tools/publish_internal_alpha.ps1`
- `Projetos/draxos-mobile/tools/export_internal_alpha.ps1`
- `Projetos/draxos-mobile/tools/build_cloudflare_pages_package.ps1`

## Arquivos Pretendidos

- Versionamento/manifest/scripts: `core/project_info.gd`, `tools/export_internal_alpha.ps1`, `tools/publish_internal_alpha.ps1`, `server/functions/release/index.ts`, `supabase/functions/release/index.ts`, testes associados.
- Portal/contratos: `portal/internal-alpha/index.html`, `portal/internal-alpha/manifest.example.json`, `docs/contracts/update-manifest.md`, `docs/contracts/api-endpoints.md`.
- Docs vivos: `AGENTS.md`, `README.md`, `implementation/current-status.md`, `docs/agent-operating-manual.md`, `docs/documentation-index.md`, `docs/product-vision.md`, `docs/product-brief.md`, `docs/design-pending.md`, `docs/minigames/openworld.md`, `docs/minigames/openworld-decision-pack.md`, `docs/minigames/autobattler.md`, `docs/pve-arena-v1.md`, `docs/multi-agent-workflow.md`.
- Portfolio/canon: `canon/canon-brief.md`, `Projetos/README.md`, `08_Coordenacao_Agentes/Prioridades_Estudio.md`, `08_Coordenacao_Agentes/Estado_Atual.md`, `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`.

## Validacao Planejada

- `git diff --check`
- `tools/check_release_safety.ps1`
- `tools/validate_foundation.ps1 -Profile ClientQuick`
- `tools/validate_foundation.ps1 -Profile ModePlatform`
- `tools/validate_foundation.ps1 -Profile ReleaseDryRun`, se aplicavel
- `tools/publish_internal_alpha.ps1 -Mode Plan/Package/FullPublish` com `-ConfirmRemoteMutation`
- `tools/build_cloudflare_pages_package.ps1`
- `wrangler pages deploy`
- Smokes remotos de manifest/artifacts/release/Web launch conforme checklist.

## Handoff Esperado

Publicacao remota concluida ou bloqueio explicito registrado; Doing movido para Done com release root, preview Cloudflare Pages, versao, validacoes e observacoes de escopo.
