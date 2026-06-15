# DraxosMobile Review: publish Arena UX Web+APK

## Metadata

- data: `2026-06-15`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `release`
- mode_scope: `autobattler`
- branch: `codex/draxos-mobile/publish-arena-ux-web-apk`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--publish-arena-ux-web-apk`
- status: em validacao/publicacao; movido de `Doing` para liberar o gate de release que exige ausencia de cards DraxosMobile ativos em `Doing`.

## Objective

Publicar Web+APK do candidato `Arena UX/readability/recovery` ja integrado localmente, com versionamento de Internal Alpha, release root novo, validacao e registro documental.

## Intended Files

- `Projetos/draxos-mobile/docs/release-history.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Kanban/Done/2026-06-15_codex_draxos-mobile_publish-arena-ux-web-apk.md`
- `08_Coordenacao_Agentes/Handoffs/2026-06-15_codex_draxos-mobile_publish-arena-ux-web-apk.md`
- arquivos de manifest/evidencia gerados pelo script de release, se rastreados pelo repo

## Base Docs Read

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/docs/track-13-manual-walkthrough-gate.md`

## Validation Plan

- Rodar `ClientQuick`, `ServerQuick` e `ReleaseDryRun`.
- Exportar artefatos Web/APK pelo script oficial.
- Publicar somente com `-ConfirmRemoteMutation` e `-ReleaseRoot` fresco/versionado.
- Verificar artefatos Web+APK publicados e registrar evidencias.
- Rodar `tools/check_doc_drift.ps1` apos docs.

## Boundaries

- Usuario aprovou publicacao Web+APK nesta conversa.
- Nao executar `git push`, `git fetch`, `git pull`, `gh auth login`, navegador de login ou setup de token.
- `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.

## Next Handoff Point

Depois da publicacao e validacao, mover este card para Done, criar handoff de release e deixar main limpa apos merge local.
