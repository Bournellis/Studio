# Progression Clarity v1

Status: Done
Agente: Codex
Branch: codex/draxos-mobile/progression-clarity-v1
Worktree: D:\Estudio-worktrees\draxos-mobile--codex--progression-clarity-v1
Data: 2026-05-29

## Objetivo

Implementar Progression Clarity v1 para tornar nivel, poder, recompensas, proximos desbloqueios e proximo objetivo mais claros no loop atual de DraxosMobile, sem alterar backend, schema, simulador, economia, tuning, armas, spells ou conteudo jogavel.

## Escopo

- Adicionar leitura publica de progresso no Refugio.
- Reforcar preparacao com proximos marcos de progresso e poder atual.
- Melhorar battle summary com progresso da conta, recompensa e proxima meta.
- Usar apenas dados existentes de sessao, build/state e resultado de batalha.
- Evitar termos tecnicos visiveis como build, behavior, slot, endpoint, schema, snapshot, alpha e ids crus.

## Arquivos Previstos

- Projetos/draxos-mobile/modes/boot/surfaces/hub_surface_presenter.gd
- Projetos/draxos-mobile/modes/boot/surfaces/battle_replay_presenter.gd
- Projetos/draxos-mobile/modes/boot/surfaces/progression_clarity_presenter.gd
- Projetos/draxos-mobile/tests/client/*
- Projetos/draxos-mobile/docs/progression-clarity-v1.md
- Projetos/draxos-mobile/docs/documentation-index.md
- Projetos/draxos-mobile/implementation/current-status.md
- Projetos/README.md
- 08_Coordenacao_Agentes/Prioridades_Estudio.md
- 08_Coordenacao_Agentes/Estado_Atual.md

## Validacao Planejada

- GUT em tests/client.
- tools/smoke_foundation_loop.gd.
- tools/smoke_responsive_layout.gd.
- tools/validate.gd ou validate_foundation.ps1 -Profile Client.
- git diff --check.

## Handoff

Progression Clarity v1 foi implementado, validado e publicado no Internal Alpha.

Validacao concluida:

- GUT em `tests/client`: PASS, `123/123` testes e `1984` asserts.
- `tools/smoke_foundation_loop.gd`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS.
- `validate_foundation.ps1 -Profile Client`: PASS.
- `git diff --check`: PASS.
- `tools/smoke_foundation_surfaces.gd`: BLOQUEADO localmente sem Supabase local em `127.0.0.1:54321`.

Publicacao concluida:

- Release root: `internal-alpha/v0-progression-clarity-v1-20260529`.
- Web preview: `https://3cf22c65.draxos-mobile-internal-alpha.pages.dev/web`.
- APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-progression-clarity-v1-20260529/downloads/draxos-mobile-alpha.apk`.
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-progression-clarity-v1-20260529/downloads/draxos-mobile-alpha.zip`.
