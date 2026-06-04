# DraxosMobile - Openworld Objectives Docs Handoff

- Data: `2026-06-04`
- Agente: `codex`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/openworld-objectives-docs`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--openworld-objectives-docs`
- Base: `master` @ `b61ceaf`
- Commits de trabalho:
  - `a09a55f chore: register DraxosMobile Openworld objectives docs`
  - `ed06828 docs: define DraxosMobile Openworld objectives`
- Lane: `coord-docs`
- Modo: `openworld`
- Remote mutation: `NAO`
- Publicacao: `NAO`
- Status em `master`: historico preservado; conteudo util integrado
  seletivamente em docs vivos por `codex/draxos-mobile/final-open-content-merge`.
  Nao mergear esta branch literalmente.

## Entregue

- Criado `docs/minigames/openworld-objectives.md` como autoridade de produto
  para Openworld/Bosque.
- Registrado que Openworld atual e alpha interno para testar mecanicas e
  descobrir escopo, sem promessa de Openworld completo.
- Definido Bosque como Etapa 1: minigame relaxante de coleta, build e craft,
  sem inimigos, combate, NPCs ou quests.
- Registradas Etapa 2 e Etapa 3 como candidatas futuras, nao aprovadas para
  implementacao:
  - Etapa 2: expansao do Bosque com casa/altar do mago, arredores e pequena
    cidade, trazendo menus/funcoes para dentro do mundo.
  - Etapa 3: area minima com monstros, mais NPCs e loop matar/coletar/quest.
- Atualizados Openworld doc, decision pack, mode catalog, design pending,
  product vision/brief, playtest checklist, README/status e agent docs.
- Atualizados guards locais para tratar First Access Runtime como latest
  published package e Foundation Hardening V2 como previous hardening/live-doc
  guard.

## Validacao

- `git diff --check`: PASS.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile DocsOnly`: PASS.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`: PASS.

## Fora De Escopo

- Nenhuma mudanca de runtime Godot.
- Nenhuma migracao, Edge Function, schema ou Supabase remoto.
- Nenhuma publicacao Cloudflare/Storage/manifest.
- Nenhum inimigo, NPC, quest, cidade, economia nova ou reward novo.

## Proximo Seguro

Conteudo revisado seletivamente. A direcao futura continua bloqueada por
decisoes explicitas em `docs/design-pending.md` e pelo decision pack de
Openworld; nao ha aprovacao automatica para Etapa 2 ou Etapa 3.
