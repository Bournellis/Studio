# DraxosMobile Done: client-shell - Refugio visual cleanup

## Metadata

- data: `2026-06-02`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `client-shell`
- mode_scope: `basebuilder`
- branch: `codex/draxos-mobile/refugio-visual-cleanup`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--refugio-visual-cleanup`

## Objetivo

Limpar visualmente a tela do Refugio sem alterar gameplay, backend, economia, conteudo ou funcoes existentes.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/foundation-responsive-layout-contract.md`
- `Projetos/draxos-mobile/docs/first-session-clarity-v1.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Escopo Entregue

- Refugio sem siglas visiveis nos icones `Arena PVE`, `Preparacao`, `Refugio`, `Social`, `Modos`, `Loja`, `Coletar` e `Energia`.
- HUD superior sem titulo `Refugio`, com altura menor e texto `Level <n> | Almas ... | Energia ... | Ossos ... | Po ...`.
- Cena central sem `ALTAR`, sem `Refugio do Mago`, sem `RefugeAltarStage`, `RefugeAltarGlow` ou `RefugeAltarCore`.
- Paineis persistentes `RefugeLoopPanel` e `RefugeProgressionPanel` removidos.
- CTA principal inferior preservado.
- `RefugeFooterPanel` preservado oculto para feedback/status de acoes.
- Smokes e testes atualizados para o novo contrato visual.

## Fora Do Escopo Preservado

- Sem gameplay, backend, schema, Supabase functions, migrations, economia, tuning ou conteudo novo.
- Sem remocao de funcoes do jogo.
- Sem mudancas visuais em outras telas alem de sugestoes registradas para proximo pacote.

## Validacao Local Inicial

- `git diff --check`: PASS.
- Godot one-time `--headless --import`: PASS, com avisos conhecidos de assets do GUT.
- `tools/smoke_responsive_layout.gd`: PASS.
- GUT `tests/client`: PASS, `174/174`, `3182` asserts.
- `tools/smoke_mobile_presentation.gd`: PASS.
- `tools/smoke_foundation_loop.gd`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick`: PASS.

## Publicacao

- release root:
  `internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0`;
- production URL:
  `https://draxos-mobile-internal-alpha.pages.dev`;
- Cloudflare deployment evidence:
  `https://f183cd39.draxos-mobile-internal-alpha.pages.dev`;
- Portal:
  `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`;
- Web:
  `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`;
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0/downloads/draxos-mobile-alpha.apk`;
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0/downloads/draxos-mobile-alpha.zip`;
- remote manifest:
  `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`.

Publicacao passou por `Mode Plan`, `Mode Package`, `Mode Upload` com
`-ConfirmRemoteMutation`, Cloudflare Pages deploy em `main` e `Mode
DeployManifest` com `StaticSiteBaseUrl=https://draxos-mobile-internal-alpha.pages.dev`.

## Validacao De Publicacao

- Android/PC/Web export: PASS; Android usa `debug_fallback`.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: PASS.
- Preview Web HTML em
  `https://f183cd39.draxos-mobile-internal-alpha.pages.dev/web/index.html`:
  `200`, aponta para `internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0/web`.
- Production fixo retorna Cloudflare Access para GET anonimo, esperado para a
  configuracao atual.
- Remote `Content-Length` bateu com local para `index.pck` (`4611176`) e
  `index.wasm` (`37695054`).
- `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly -AllowCloudflareAccess`: PASS.

## Evidencia Visual

- Antes:
  `D:\Estudio\Projetos\draxos-mobile\build\track15_mobile_ux_checkpoint\02_refugio.png`.
- Depois:
  `D:\Estudio-worktrees\draxos-mobile--codex--refugio-visual-cleanup\Projetos\draxos-mobile\build\track15_mobile_ux_checkpoint\02_refugio.png`.

## Sugestoes De Limpeza Visual

- `Modos`: traduzir/suavizar `Modes`, `Active`, `Staged`, `Internal Alpha`,
  `Power` e `Lv`.
- Base cards: trocar `[ALM]`, `[ENE]`, `[SAN]` por labels/icones mais limpos.
- Arena selection: esconder IDs tecnicos `s1_d...` atras de labels amigaveis.
- Account/update: mover build/channel/manifest para uma area advanced/debug.
- Social: reduzir `username`, `badge` e `Save Lab` no fluxo normal.
- Shop: suavizar `Battle Pass`, `Premium` e termos de teste/alpha.
- Battle summary: avaliar merge de reward/resources/progress no mobile se ficar
  empilhado demais.

## Handoff Point

Fabio assume para revisar a tela do Refugio no fluxo humano, comparando o CTA
unico, os icones sem siglas, HUD compacto, ausencia de altar/barras persistentes
e feedback de acoes preservado. Depois, decidir o proximo pacote de limpeza
visual ou retomar o playtest funcional do Openworld.
