# DraxosMobile - Social Basico Guilda v1

- Data: 2026-05-29
- Agente: Codex
- Branch: `codex/draxos-mobile/social-guild-v1-integration`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--social-guild-v1-integration`
- Base: `master` em `40a7baf`
- Status: `CONCLUIDO`

## Objetivo

Implementar Social Basico Guilda v1 para tornar amigos, guilda e chat de guilda testaveis por pessoas reais, com auto-sync leve de 8s somente na tela Social.

## Entrega

- Tela Social reorganizada com identidade, username proprio, badge social/save, secoes Amigos/Guilda/Chat e estados vazios objetivos.
- Acao local `copy_social_username` adicionada ao contrato da shell para copiar/mostrar o username social sem tocar no servidor.
- Amigos por username, criar/entrar guilda, membros, estruturas read-only e chat de guilda preservam os endpoints existentes.
- Auto-sync leve de 8s implementado somente na tela Social, sem bloquear botoes, sem `_set_busy`, sem novo endpoint/schema/migration e pausado fora do Social, offline, sem sessao/conta, em Lab local-only, ocupado ou apos erro automatico.
- Fluxos manuais de Social e envio de chat aplicam a resposta imediatamente, limpam erro automatico e reiniciam o timer.
- Status do portfolio e current-status foram atualizados para `SOCIAL_GUILD_V1_IMPLEMENTED`.

## Fora De Escopo Preservado

- Realtime.
- Direct chat.
- Ajuda de construcao.
- Contribuicao/upgrade real de guilda.
- Chat global.
- Presenca.
- Convites/cargos avancados.
- Denuncia, bloqueio ou moderacao completa.
- Backend, schema, migration ou publicacao remota.

## Validacao

- `git diff --check`: PASS.
- `tools/validate.gd`: PASS (`117/117`, `1857` asserts).
- GUT `tests/client`: PASS (`117/117`, `1857` asserts).
- `tools/smoke_foundation_loop.gd`: PASS, com avisos esperados de telemetry HTTP local.
- `tools/smoke_responsive_layout.gd`: PASS.
- `validate_foundation.ps1 -Profile Client`: PASS.
- `tools/smoke_foundation_surfaces.gd`: bloqueado por Supabase local Edge Functions retornando `503` em `/functions/v1/healthcheck`.
- `server/tests/social_competition_smoke.ts`: nao executado porque Supabase local/remoto nao estava disponivel para esse smoke.

## Handoff

Proximo passo recomendado: validar Social Basico Guilda v1 manualmente com duas contas humanas antes de decidir publicacao ou proximo pacote.
