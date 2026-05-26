# Track 03 - Internal Alpha v0 - Current Status

- Last Updated: `2026-05-26`
- Status: `T03-P02_REPO_READY - REMOTE SUPABASE PROJECT PENDING`
- Baseline: Track 00 completa, Track 01 completa e Track 02 com Progression Lab/Battle Lab v1 implementados. O projeto ja possui Godot 4.6.2, Supabase local, conta guest, batalha server-authoritative, Base/Social/Competicao/Monetizacao v0, telemetria client nao autoritativa, exports Android/PC/Web, Battle Visual Mockup compartilhado e laboratorios dev-only. A Track 03 prepara a transicao para uma build fechada realista com email/senha, dois saves por conta, backend remoto, updates e playtest de 2 usuarios.

## Implementado Nesta Preparacao

- Escopo da Track 03 criado.
- Plano de implementacao criado.
- Runbook operacional `docs/internal-alpha-v0.md` criado.
- Checklist de playtest `docs/playtest-internal-alpha-v0.md` criado.
- Worktree limpa de outputs gerados e ignore atualizado para novos `.uid`, `.translation` e `build/`.
- Design lock da Internal Alpha v0 registrado em `docs/internal-alpha-v0-design-lock.md`.
- Pendencias `DMOB-D048` a `DMOB-D055` resolvidas.
- Follow-ups de loja/social fechados: redeems entregam apenas Diamante, resetam a meia-noite `America/Sao_Paulo`, amigos usam username e usuarios no Lab aparecem com marcador vermelho `lab`.
- Estrategia backend registrada: Supabase para Internal Alpha v0, Backend Proprio + Postgres como plano de saida preferido e Nakama como alternativa futura apenas se realtime/social competitivo virar pilar.
- `T03-P02` preparado do lado do repo: `BackendConfig` no Godot, ambiente `internal_alpha_v0`, env vars seguras, `.env` reais ignorados, `.env.internal-alpha.example`, runbook remoto e smoke Deno remoto sem service role.

## Ainda Nao Implementado

- Auth email/senha remoto.
- Dois saves por conta no schema/runtime.
- Progression Lab aplicado ao save `progression_lab`.
- Supabase remoto real criado/configurado na conta Supabase.
- Deploy remoto de migrations/functions e smoke contra URL real.
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

Criar o projeto Supabase remoto real, aplicar migrations/functions e rodar `server/tests/internal_alpha_remote_smoke.ts`. Depois seguir para `T03-P03 - Conta Email/Senha E Dois Saves`.

## Validacao Da Preparacao

- `git diff --check`: passou em 2026-05-26.
- `npx -y deno check server/tests/internal_alpha_remote_smoke.ts`: passou em 2026-05-26.
- `tools/validate.gd`: passou em 2026-05-26 com GUT `44/44` e `264` asserts.
- `tools/smoke_exports.gd`: passou em 2026-05-26 para Android Alpha, PC Windows Alpha e PC Browser Alpha.
