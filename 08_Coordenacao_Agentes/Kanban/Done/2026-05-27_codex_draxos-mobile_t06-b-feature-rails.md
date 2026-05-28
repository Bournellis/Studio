# DraxosMobile - T06-B Feature Rails

- Data: `2026-05-27`
- Agente: Codex
- Projeto: `Projetos/draxos-mobile/`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t06-feature-rails`
- Branch: `codex/draxos-mobile/t06-feature-rails`
- Status: `READY_FOR_HANDOFF`

## Objetivo

Criar o contrato padrao de instalacao de feature da Track 06, consolidar `feature-registry.md`, definir template/checklist por feature e regra de validacao por surface.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/implementation-plan.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/agent-registry.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/agent-prompts.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/implementation-plan.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/agent-registry.md`
- `Projetos/draxos-mobile/docs/contracts/` se um contrato auxiliar for necessario

## Validacao Planejada

```powershell
git diff --check
```

`validate.gd` fica fora do escopo salvo toque acidental em tooling/client.

## Validacao Executada

- `git diff --check`: passou.
- `validate.gd`: nao executado; pacote docs/status/contratos, sem toque em tooling/client.

## Handoff

Ao finalizar, T06-D a T06-H devem conseguir copiar o template/checklist, declarar owner/surface/endpoints/service scope/validacao/fallback/rollback e escolher a validacao obrigatoria por surface antes de implementar.
