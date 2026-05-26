# Track 03 - Internal Alpha v0 - Current Status

- Last Updated: `2026-05-26`
- Status: `READY_FOR_IMPLEMENTATION - DOCUMENTATION AND WORKSPACE PREP`
- Baseline: Track 00 completa, Track 01 completa e Track 02 com Progression Lab/Battle Lab v1 implementados. O projeto ja possui Godot 4.6.2, Supabase local, conta guest, batalha server-authoritative, Base/Social/Competicao/Monetizacao v0, telemetria client nao autoritativa, exports Android/PC/Web, Battle Visual Mockup compartilhado e laboratorios dev-only. A Track 03 prepara a transicao para uma build fechada realista com email/senha, dois saves por conta, backend remoto, updates e playtest de 2 usuarios.

## Implementado Nesta Preparacao

- Escopo da Track 03 criado.
- Plano de implementacao criado.
- Runbook operacional `docs/internal-alpha-v0.md` criado.
- Checklist de playtest `docs/playtest-internal-alpha-v0.md` criado.
- Worktree limpa de outputs gerados e ignore atualizado para novos `.uid`, `.translation` e `build/`.

## Ainda Nao Implementado

- Auth email/senha remoto.
- Dois saves por conta no schema/runtime.
- Progression Lab aplicado ao save `progression_lab`.
- Supabase remoto configurado para internal alpha.
- Manifest de updates em Supabase Storage.
- Base/Social/Competicao/Loja refinados para build fechada.
- Export/publicacao das tres builds finais.

## Decisoes Ja Travadas

- Supabase Free remoto primeiro.
- Email + senha.
- Email confirmation desligado no alpha interno.
- Dois saves por conta: `normal` e `progression_lab`.
- Reset separado por save.
- Progression Lab exportado apenas como ferramenta interna/gated.
- Loja com redeem alpha fixo para testar premium.
- Web link pode ser publico/unlisted, mas jogo exige login e acesso alpha.
- Android usa keystore dedicada de Internal Alpha.

## Proximo Passo

Executar `T03-P01 - Design Lock Da Build Interna`, resolvendo as pendencias `DMOB-D048` a `DMOB-D055` antes de escrever codigo funcional amplo.

## Validacao Da Preparacao

- `git diff --check`: passou em 2026-05-26.
- `tools/validate.gd`: passou em 2026-05-26 com GUT `41/41` e `253` asserts.
