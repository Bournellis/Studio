# DraxosMobile Handoff: First Access Runtime

## Metadata

- data: `2026-06-02`
- agente: `Codex`
- projeto: `draxos-mobile`
- branch: `codex/draxos-mobile/first-access-runtime`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--first-access-runtime`
- base_commit: `ad6dce4`
- status: `DELIVERED_LOCAL`

## Objetivo

Executar a parte tecnica paralela ao playtest humano: melhorar a
responsividade de primeiro acesso sem cache e investigar a pendencia historica
de `BOOT_ERROR` no Edge Runtime local.

## Escopo Pretendido

- Primeiro acesso sem cache:
  - auditar `surface_action_flow.gd`, `arena_lifecycle_flow.gd`,
    presenters/shells e testes relacionados;
  - evitar tela passiva de espera quando nao existe snapshot persistido;
  - manter server-authoritative semantics para economia, recompensa e batalha;
  - adicionar cobertura client para a renderizacao inicial sem cache.
- Edge Runtime local:
  - tentar reproduzir os smokes locais que falharam por `BOOT_ERROR`;
  - identificar se o problema e env, import, runtime local ou script;
  - corrigir quando houver causa local clara ou registrar bloqueio reproduzivel.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `AGENTS.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/foundation-app-v0-audit.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Validacao Planejada

- `git diff --check`
- Deno checks/testes focados se tocar server/supabase/tools
- GUT client focado nos presenters/flows alterados
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ModePlatform` se modo/openworld for tocado
- Tentativa documentada de reproduzir local Edge Runtime quando aplicavel

## Remote Mutation

Nao aprovada para esta frente. Nao executar publish, deploy, secrets, upload ou
`-ConfirmRemoteMutation`.

## Entregue

- Primeiro acesso sem cache agora renderiza uma superficie local imediatamente
  antes do fetch remoto, sem marcar telemetria/cache como `rendered_from_cache`.
- Arena sem snapshot remoto usa um shell de sincronizacao, sem botoes de
  fallback dev local ou tentativa local antes da resposta do servidor.
- Testes de client cobrem:
  - shell de Arena em primeiro acesso sem cache;
  - refresh de superficie sem cache com render local e flag de cache falsa.
- `server/tests/modes_platform_live_test.ts` foi alinhado ao contrato publicado
  do Bosque v1:
  - `openworld` ativo com `release_channel = internal_alpha`;
  - `active_ruleset_id = openworld_forest_ruleset_v1`;
  - coleta de teste suficiente para atravessar o limiar de recompensa v1;
  - comparacao idempotente ignora apenas `cache.generated_at`, que e metadado
    volatil do envelope de responsividade;
  - caso de revisao forjada usa conta separada para nao conflitar com cooldown
    legitimo de start.

## Diagnostico Edge/DatabaseLocal

- O `BOOT_ERROR` historico do Edge Runtime local foi reproduzido e isolado como
  problema de stack local stale: o container `supabase_edge_runtime_draxos-mobile`
  estava montado em uma worktree antiga/removida
  (`draxos-mobile--codex--foundation-hardening-v2`).
- `supabase stop` + `supabase start` a partir deste worktree corrigiu o mount
  do Edge para:
  `D:\Estudio-worktrees\draxos-mobile--codex--first-access-runtime\Projetos\draxos-mobile`.
- Apos corrigir o mount, o healthcheck local respondeu `ok:true`.
- O banco local anterior tambem estava inconsistente: o historico dizia que
  migrations de Arena/Mode haviam sido aplicadas, mas tabelas/funcoes estavam
  ausentes. Foi necessario `supabase db reset --local` para reconstruir a base
  local a partir das migrations do repositorio.
- Depois do reset, `DatabaseLocal` voltou a executar o fluxo completo:
  transactional RPC, Edge RPC, mode platform live proof e admin RLS smoke.

## Validacao Executada

- `deno check .\server\tests\modes_platform_live_test.ts`: PASS.
- `git diff --check`: PASS.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile DatabaseLocal`: PASS.
  - inclui local Supabase transactional RPC live proof;
  - local Edge transactional RPC adapter smoke;
  - local mode platform live proof;
  - local admin RLS live smoke.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: PASS.
  - 181/181 testes GUT;
  - 3249 asserts;
  - `smoke_runtime_config.gd`, `smoke_foundation_hardening.gd`,
    `smoke_responsive_layout.gd`, `smoke_exports.gd`: PASS.

## Pendencias

- Nenhuma pendencia local desta frente.
- Publicacao remota nao foi executada nesta branch.
- O playtest humano remoto segue como validacao externa em paralelo.
