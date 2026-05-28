# DraxosMobile - Current Status

- Last Updated: `2026-05-28`
- Active Project Name: `draxos-mobile`
- Active Surface: `Product/foundation consolidation`
- Active Track: `Track 11 - Product Foundation Consolidation`
- Active Track Status: `INTEGRATED_CONSOLIDATION_READY`
- Portfolio Status: `P2_IMPLEMENTACAO`
- Current Build Channel: `internal_alpha`
- Current Version: `0.0.1-alpha.0`
- Current Version Code: `1`

## Baseline Atual

DraxosMobile saiu bem da fase de crescimento rapido: Track 00 a Track 10 estao integradas sobre Godot 4.6.2 + Supabase, com cliente Android/PC/Web, conta email/senha, dois saves por conta (`normal` e `progression_lab`), batalha server-authoritative, Base/Social/Competicao/Loja alpha, Progression Lab/Battle Lab, Refugio portrait como primeira tela jogavel, batalha fullscreen portrait, summary minimo e logs em tela propria.

As builds Internal Alpha foram republicadas em 2026-05-28:

| Artefato | Bytes | SHA256 |
|---|---:|---|
| Android APK | `27965106` | `ad6d2579ce003769cfce2536b788c1330abb283d0ae90cc785d1d016ae514ca6` |
| PC Windows ZIP | `36466312` | `ad5fb8351bb001604479d95737fc702bb9b0ff6779afb9e3e31692b7bc189031` |
| Web index | `5442` | `75fdd260b889582cb723256e87ca9867ae35b7cdd3411cbb2ca21ace5585366a` |

Links vivos:

- Supabase remoto: `https://armxgipvnbbshzqawklw.supabase.co`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`
- Portal estavel: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web estavel: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Cloudflare preview mais recente verificado: `https://36b1d46c.draxos-mobile-internal-alpha.pages.dev`

Observacao: o dominio estavel do Cloudflare Pages esta protegido por Cloudflare Access. Validacao anonima publica deve usar preview nao protegido ou uma sessao autenticada no Access.

## Track 11 Entregue

Track 11 nao adiciona feature jogavel; ela consolida a fundacao para a proxima etapa longa. Entregas:

- Estado vivo sincronizado: portfolio, README local, AGENTS local, `implementation/current-status.md`, docs de release e painel do estudio apontam para Track 11 e para as builds publicadas corretas.
- Kanban antigo de DraxosMobile foi arquivado para `Done`, removendo dezenas de cards obsoletos de `Doing`.
- Nova trilha oficial em `implementation/tracks/track-11-product-foundation-consolidation/` com escopo, plano, auditoria, status e registro de pacotes paralelos.
- Runbook manual de walkthrough em `docs/track-11-manual-walkthrough.md`.
- Primeiro corte seguro do monolito `modes/boot/boot.gd`: contrato de erro do app shell extraido para `modes/boot/ui/app_shell_error_contract.gd`, com teste dedicado.
- Release ops alinhado ao estado publicado de 2026-05-28: defaults de manifest, manifest exemplo, docs de handoff/publicacao e smoke remoto aceitam o cenario real de Cloudflare Access quando explicitamente autorizado.
- Readiness check local em `tools/check_track11_readiness.ps1` para impedir drift entre docs, release defaults, mirrors server/supabase e Kanban.

## O Que Nao Esta Bom Ainda

- `modes/boot/boot.gd` continua grande demais. Track 11 fez apenas o primeiro corte seguro; proximas etapas devem extrair action ids, lifecycle de batalha, presenters restantes e fluxo de conta em contratos menores antes de mudar produto.
- O modelo `players.save_type` segue como atalho alpha. A migracao para `account_profiles` + `game_saves` ainda precisa de decisao e pacote proprio.
- Progression/Economia segue em `REVIEW`: sem tuning numerico ate uma rodada humana no Godot com save real e Progression Lab.
- Assets finais, UX Android em aparelho real, keystore release e live ops ainda nao sao maturidade de produto. O jogo esta pronto para alpha fechado, nao para beta publico.
- O script de publicacao ainda mistura preparacao, upload e redeploy de release; deve ganhar modo dry-run/plan antes de virar rotina segura de release.

## Proximo Passo

Executar walkthrough manual real em Android, Windows e Web autenticado/preview:

1. `Entry`: login/criar conta e recuperacao de save.
2. `Refugio`: primeira tela, hotspots, Base embutida, Loja/Social/Competicao.
3. `Batalha`: iniciar, assistir/pular, summary minimo, logs.
4. `Conta`: update gate, save normal, Progression Lab isolado.
5. Registrar bloqueios, friccao e qualquer diferenca entre Android, Windows e Web.

Nao abrir feature nova, tuning numerico ou migration de conta/save antes desse walkthrough.

## Validacao Recomendada

```powershell
cd <WORKTREE>\Projetos\draxos-mobile
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_track11_readiness.ps1 -ProjectDir .
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
npx -y deno check supabase/functions/release/index.ts server/functions/release/index.ts server/tests/release_artifacts_remote_smoke.ts
git diff --check
```

## Read Next

1. `../AGENTS.md`
2. `implementation/tracks/track-11-product-foundation-consolidation/current-status.md`
3. `implementation/tracks/track-11-product-foundation-consolidation/foundation-audit.md`
4. `implementation/tracks/track-11-product-foundation-consolidation/implementation-plan.md`
5. `docs/track-11-manual-walkthrough.md`
6. `docs/internal-alpha-v0-handoff.md`
7. `docs/release-ops-checklist.md`
