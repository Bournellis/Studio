# DraxosMobile - Bosque Offline-First Checkpoint v1

- Data: `2026-06-05`
- Agente coordenador: `Codex`
- Branch final: `codex/draxos-mobile/bosque-offline-first-checkpoint-v1`
- Worktree final: `D:\Estudio-worktrees\draxos-mobile--validation--bosque-checkpoint-v1`
- Projeto: `Projetos/draxos-mobile`
- Status: `DOING`

## Objetivo

Implementar `Bosque Offline-First Checkpoint v1`: movimento, coleta, bolso, deposito, craft e guidance ficam local-first; servidor valida checkpoints compactos e continua dono de conclusao, reward, caps e ledger.

## Workstreams

- Backend/Contracts: `D:\Estudio-worktrees\draxos-mobile--backend--bosque-checkpoint-v1`, branch `codex/draxos-mobile/bosque-checkpoint-backend`.
- Client/Godot: `D:\Estudio-worktrees\draxos-mobile--client--bosque-checkpoint-v1`, branch `codex/draxos-mobile/bosque-checkpoint-client`.
- Validation/Release: `D:\Estudio-worktrees\draxos-mobile--validation--bosque-checkpoint-v1`, branch `codex/draxos-mobile/bosque-offline-first-checkpoint-v1`.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/contracts/database-schema.md`
- `Projetos/draxos-mobile/docs/product-vision.md`

## Escopo Previsto

- Criar endpoint/RPC de checkpoint para `openworld/forest`.
- Trocar o cliente Bosque para checkpoint-only durante gameplay normal.
- Persistir snapshot local do Bosque por save/sessao/ruleset.
- Manter legacy `collect_batch` compativel.
- Atualizar docs/status e publicar novo Web/APK ao final.

## Validacao Planejada

- `git diff --check`
- Deno check/test para functions e tests de modes/openworld.
- GUT focado em `test_openworld_*`.
- `tools/validate.gd`
- `validate_foundation.ps1 -Profile ReleaseDryRun`
- Migration dry-run e apply remoto com aprovacao ja fornecida pelo pedido.
- Export Web/APK, upload, Cloudflare Pages deploy e RemoteReadOnly.

## Handoff

Integrar commits dos workers, resolver conflitos, validar localmente, mover este cartao para Done e registrar publicacao em `current-status`, portfolio e docs.
