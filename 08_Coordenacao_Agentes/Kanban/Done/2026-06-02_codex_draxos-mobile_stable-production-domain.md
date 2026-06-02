# DraxosMobile Done: validation-release - stable production domain

## Metadata

- data: `2026-06-02`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `validation-release`
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/stable-production-domain`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--stable-production-domain`

## Resultado

O dominio production fixo do Cloudflare Pages agora e o contrato oficial de playtest/publicacao do Internal Alpha.

- official Portal:
  `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- official Web:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- deployment evidence:
  `https://95f403c5.draxos-mobile-internal-alpha.pages.dev`
- release root preservado:
  `internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129`

## Entregue

- Manifest remoto repontado para o production fixo com
  `StaticSiteBaseUrl=https://draxos-mobile-internal-alpha.pages.dev`.
- `tools/publish_internal_alpha.ps1` agora usa o production fixo como default de `StaticSiteBaseUrl`.
- Defaults da Edge Function `release` alinhados ao pacote Openworld QoL hotfix e ao production fixo.
- Runbook `docs/release-ops-checklist.md` documenta que hash URLs sao evidencia tecnica, nao link de playtest.
- `implementation/current-status.md`, portfolio, snapshot e registry atualizados com production URL + deployment evidence.
- Portal manifest example atualizado para a regra production.

## Validacao

- Remote manifest GET: PASS, `portal_url` e `artifacts.web.url` apontam para production fixo.
- Production CORS origin GET/OPTIONS: PASS para
  `https://draxos-mobile-internal-alpha.pages.dev`.
- PowerShell parser check dos scripts de release tocados: PASS.
- Deno check de `server/functions/release/index.ts`,
  `supabase/functions/release/index.ts`,
  `server/tests/release_manifest_smoke.ts` e
  `server/tests/release_artifacts_remote_smoke.ts`: PASS.
- `release_manifest_smoke.ts`: PASS.
- `release_artifacts_remote_smoke.ts`: PASS com
  `DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS=1`; production Portal/Web retornam
  Cloudflare Access em acesso anonimo, como protecao esperada.
- Primeiro `validate_foundation.ps1 -Profile RemoteReadOnly`: remote smokes PASS,
  mas falhou antes em release safety por texto do script contendo `Wrangler` e
  em agent ops pelo Doing ativo; ambos foram corrigidos para rerun final.

## Observacao Operacional

Se Cloudflare Access estiver ativo, acesso anonimo ao production pode mostrar a
tela de Access. Isso nao e troca de dominio nem rollback de build. A validacao
de conteudo deve ser feita com sessao autenticada, enquanto o hash URL fica
apenas como evidencia tecnica do deployment production.
