# Handoff - DraxosMobile Refugio Visual Cleanup

## Resumo

- branch: `codex/draxos-mobile/refugio-visual-cleanup`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--refugio-visual-cleanup`
- commit client: `03f3fb0 Clean up Refugio visual shell`
- release root: `internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0`
- production URL: `https://draxos-mobile-internal-alpha.pages.dev`
- deployment evidence: `https://f183cd39.draxos-mobile-internal-alpha.pages.dev`

## Entregue

- Refugio sem siglas visiveis nos icones do menu.
- HUD superior compacto sem titulo `Refugio`, iniciando com `Level <n>`.
- Centro sem `ALTAR`, `Refugio do Mago` e caixas/glows do altar.
- Bottom sem paineis persistentes de loop/progressao; CTA principal preservado.
- Feedback/status oculto preservado para resultados e erros de acoes.
- Testes e smokes ajustados para o novo contrato visual.

## Publicacao

- `Mode Plan`: PASS.
- `Mode Package`: PASS.
- `Mode Upload -ConfirmRemoteMutation`: PASS apos link local da Supabase CLI no
  worktree para `armxgipvnbbshzqawklw`.
- Cloudflare Pages deploy `main`: PASS,
  `https://f183cd39.draxos-mobile-internal-alpha.pages.dev`.
- `Mode DeployManifest -ConfirmRemoteMutation`: PASS com
  `StaticSiteBaseUrl=https://draxos-mobile-internal-alpha.pages.dev`.

## Validacao

- `git diff --check`: PASS.
- Godot `--headless --import`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS.
- GUT client: PASS, `174/174`, `3182` asserts.
- `tools/smoke_mobile_presentation.gd`: PASS.
- `tools/smoke_foundation_loop.gd`: PASS.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: PASS.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: PASS.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly -AllowCloudflareAccess`: PASS.
- Remote asset sizes: `index.pck` `4611176` bytes and `index.wasm` `37695054`
  bytes match local files.

## Evidencia Visual

- Antes:
  `D:\Estudio\Projetos\draxos-mobile\build\track15_mobile_ux_checkpoint\02_refugio.png`.
- Depois:
  `D:\Estudio-worktrees\draxos-mobile--codex--refugio-visual-cleanup\Projetos\draxos-mobile\build\track15_mobile_ux_checkpoint\02_refugio.png`.

## Sugestoes Para Proximo Pacote

- `Modos`: traduzir/suavizar `Modes`, `Active`, `Staged`, `Internal Alpha`,
  `Power` e `Lv`.
- Base cards: trocar bracket codes `[ALM]`, `[ENE]`, `[SAN]` por labels/icones.
- Arena selection: esconder IDs tecnicos `s1_d...` atras de labels amigaveis.
- Account/update: mover build/channel/manifest para advanced/debug.
- Social: reduzir `username`, `badge` e `Save Lab` no fluxo normal.
- Shop: suavizar `Battle Pass`, `Premium` e linguagem de teste/alpha.
- Battle summary: avaliar merge de reward/resources/progress no mobile.

## Proximo Check Humano

Abrir o pacote publicado e revisar Refugio no fluxo real: icones sem siglas,
HUD compacto, area central vazia, bottom com CTA unico e feedback de acoes
funcionando. Depois decidir se o proximo pacote e mais limpeza visual ou retorno
ao playtest funcional do Openworld.
