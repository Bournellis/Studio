# Handoff: Estudio Ops Doc Hardening

## Metadata

- from: `Codex`
- to: `Usuario / proximo agente`
- date: `2026-06-09`
- workspace: `D:\Estudio`
- branch: `codex/estudio/ops-doc-hardening`
- worktree: `D:\Estudio-worktrees\estudio--codex--ops-doc-hardening`
- status: `READY_TO_MERGE`

## Contexto

Este handoff fecha a limpeza operacional de documentacao do Estudio apos a publicacao de `Bosque Diegetic Launcher Foundation v1`. A mudanca nao altera runtime, build, deploy, Supabase ou Cloudflare.

## Entregue

- Root README alinhado ao pacote atual `BOSQUE_DIEGETIC_LAUNCHER_FOUNDATION_V1_PUBLISHED_INTERNAL_ALPHA`.
- Templates DraxosMobile atualizados para separar pacote publicado, etapa local, contexto Arena preservado, decisao aberta, mutacao remota e perfil de validacao.
- Guias atuais adicionados em `materiais/guides/*-current.md`.
- Guias antigos marcados como historicos.
- `07_Aprendizados/` criado para drift documental, compactacao de snapshot e higiene de worktree.
- `draxos-roguelike-cardgame/implementation/current-status.md` compactado, com historico preservado na track.
- Encoding confirmado corrigido em linhas pontuais.

## Validacao

- `git diff --check`: `PASS`
- Drift checks por `rg`: `PASS`
- Godot/build/deploy: `NOT RUN` por escopo docs-only.

## Proximo Passo

Mergear `codex/estudio/ops-doc-hardening` em `main` se a revisao humana aceitar o diff.
