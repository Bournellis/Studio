# DraxosMobile

DraxosMobile e o projeto Godot/Supabase para Android, PC executavel e PC browser. O jogo e um async PVP autobattler com Refugio/Base, social, competicao e progressao de personagem. O cliente anima e opera UI; batalha, recursos e estado autoritativo ficam no servidor.

**Nao confundir com:** `Projetos/draxos-roguelike-cardgame/`, projeto Steam separado.

Status: `P2_IMPLEMENTACAO - Track 11 INTEGRATED_CONSOLIDATION_READY`

## Current Shape

| Track | Estado | Resultado |
|---|---|---|
| Track 00 | Completa | Primeiro slice server-authoritative com Godot, Supabase local, batalha, Base, Social/Competicao, Loja, exports e validacao. |
| Track 01 | Completa | Hardening do alpha PC local, telemetria client, reset local seguro e checklist de playtest. |
| Track 02 | Completa como tooling | Progression Lab/Battle Lab v1, saves saudaveis, bots e relatorios; tuning humano ainda pendente. |
| Track 03 | Completa | Internal Alpha v0 com email/senha, dois saves, Supabase remoto, manifest, Storage, Cloudflare Pages e handoff. |
| Track 04 | Integrada | Pos-handoff, presenters render-only do Hub, decisao de manter `players.save_type` no curto prazo. |
| Track 05 | Integrada | Fundacao validada, matriz de checks, asset/service readiness e release ops sem publicar. |
| Track 06 | Integrada | Feature rails, runtime config, perfil/conta, historico de batalha, rotina da Base, Social QoL e Asset Pack 01. |
| Track 07 | Integrada | App shell mobile-first, rotas, touch/scroll e apresentacao full-screen. |
| Track 08 | Integrada | Hardening de contratos de shell, session/save/cache, UI mobile, battle mode e validation harness. |
| Track 09 | Integrada | Entry/Refugio portrait, Refugio como primeira tela jogavel e menu de jogo com popups/drawers. |
| Track 10 | Integrada | Batalha portrait com palco limpo fullscreen, `Pular batalha`, summary minimo e logs proprios. |
| Track 11 | Integrada | Consolidacao documental/operacional, release state sync, readiness check e primeiro corte seguro do `boot.gd`. |

## Release Atual

- Canal: `internal_alpha`
- Versao: `0.0.1-alpha.0`
- Version code: `1`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Portal/Web estavel: protegido por Cloudflare Access.
- Preview verificado: `https://36b1d46c.draxos-mobile-internal-alpha.pages.dev`

| Artefato | Bytes | SHA256 |
|---|---:|---|
| Android APK | `27965106` | `ad6d2579ce003769cfce2536b788c1330abb283d0ae90cc785d1d016ae514ca6` |
| PC Windows ZIP | `36466312` | `ad5fb8351bb001604479d95737fc702bb9b0ff6779afb9e3e31692b7bc189031` |
| Web index | `5442` | `75fdd260b889582cb723256e87ca9867ae35b7cdd3411cbb2ca21ace5585366a` |

## Start Here

1. `AGENTS.md`
2. `implementation/current-status.md`
3. `implementation/tracks/track-11-product-foundation-consolidation/current-status.md`
4. `implementation/tracks/track-11-product-foundation-consolidation/foundation-audit.md`
5. `docs/track-11-manual-walkthrough.md`
6. `docs/product-vision.md`
7. `docs/game-design-document.md`
8. `docs/design-pending.md`
9. `docs/internal-alpha-v0-handoff.md`
10. `docs/release-ops-checklist.md`

## Directory Map

```text
draxos-mobile/
|-- AGENTS.md
|-- README.md
|-- docs/
|   |-- contracts/
|   |-- progression-lab/
|   |-- product-vision.md
|   |-- game-design-document.md
|   |-- internal-alpha-v0-handoff.md
|   |-- release-ops-checklist.md
|   `-- track-11-manual-walkthrough.md
|-- implementation/
|   |-- current-status.md
|   `-- tracks/
|       |-- track-00-first-slice-foundation/
|       |-- track-01-alpha-playtest-hardening/
|       |-- track-02-progression-lab/
|       |-- track-03-internal-alpha-v0/
|       |-- track-04-post-handoff-hardening-and-hub-modularization/
|       |-- track-05-foundation-stabilization-and-asset-service-readiness/
|       |-- track-06-feature-installation-rails-and-first-slices/
|       |-- track-07-mobile-presentation-loop-and-layout-rework/
|       |-- track-08-foundation-review-and-hardening/
|       |-- track-09-portrait-entry-refuge-scene-and-visual-loop-rework/
|       |-- track-10-battle-presentation-rework/
|       `-- track-11-product-foundation-consolidation/
|-- modes/boot/
|-- online/
|-- server/
|-- supabase/
|-- portal/internal-alpha/
|-- tools/
|-- tests/
`-- addons/
```

## Quick Validation

```powershell
cd <WORKTREE>\Projetos\draxos-mobile
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_track11_readiness.ps1 -ProjectDir .
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/validate.gd
npx -y deno check supabase/functions/release/index.ts server/functions/release/index.ts server/tests/release_artifacts_remote_smoke.ts
```
