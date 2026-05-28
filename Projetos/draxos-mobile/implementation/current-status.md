# DraxosMobile - Current Status

- Last Updated: `2026-05-28`
- Active Project Name: `draxos-mobile`
- Active Surface: `Foundation validation and release safety`
- Active Track: `Track 13 - Foundation Validation And Release Safety`
- Active Track Status: `TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`
- Portfolio Status: `P2_IMPLEMENTACAO`
- Current Build Channel: `internal_alpha`
- Current Version: `0.0.1-alpha.0`
- Current Version Code: `1`

## Baseline Atual

DraxosMobile saiu bem da fase de crescimento rapido: Track 00 a Track 13 estao integradas sobre Godot 4.6.2 + Supabase, com cliente Android/PC/Web, conta email/senha, dois saves por conta (`normal` e `progression_lab`), batalha server-authoritative, Base/Social/Competicao/Loja alpha, Progression Lab/Battle Lab, Refugio portrait como primeira tela jogavel, batalha fullscreen portrait, summary minimo, logs em tela propria, `boot.gd` decomposto em contratos/flows/helpers menores e validacao/release protegidos por runner e guardas automatizados.

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

## Track 12 Entregue

Track 12 nao adiciona feature jogavel; ela reduz risco arquitetural do app shell. Entregas:

- `modes/boot/boot.gd` reduzido para `1301` linhas e coberto por orçamento permanente de `1500` linhas.
- Action ids, prefixos, update gate, replay gate e payload de telemetria centralizados em `modes/boot/ui/app_shell_action_contract.gd`.
- Conta, sessao, save e update/runtime checks extraidos para `modes/boot/flows/account_session_flow.gd`.
- Acoes online de Base, Social, Competicao e Loja extraidas para `modes/boot/flows/surface_action_flow.gd`, mantendo autoridade no servidor.
- Request/latest/history/replay/skip/summary/logs de batalha extraidos para `modes/boot/flows/battle_lifecycle_flow.gd`, sem simulacao client-side.
- Helpers visuais compartilhados extraidos para `modes/boot/surfaces/surface_ui_helpers.gd` e fronteira de presenters atualizada em `modes/boot/surfaces/README.md`.
- Guardas em `tests/client/test_boot_mobile_ui.gd` impedem regressao estrutural de linhas, actions, rede/mutacao em presenters e UI criada dentro de flows.

## Track 13 Entregue

Track 13 nao adiciona feature jogavel; ela transforma validacao e release em fundacao auditavel. Entregas:

- `tools/validate_foundation.ps1` centraliza perfis `Quick`, `Client`, `Release` e `Full`, com relatorios locais em `build/validation/`.
- `tools/publish_internal_alpha.ps1` agora usa `Mode Plan` por default e nao faz upload, deploy, secret update ou verificacao remota sem modo explicito.
- `Mode Package` prepara apenas arquivos locais; `Upload`, `DeployManifest` e `FullPublish` exigem `-ConfirmRemoteMutation`.
- `tools/check_release_safety.ps1` valida parse, default seguro, guarda de mutacao e manifest defaults espelhados.
- `tools/check_track13_readiness.ps1` valida docs/status, `boot.gd` abaixo de `1500` linhas, mirrors server/supabase e Kanban sem card obsoleto.
- `docs/track-13-manual-walkthrough-gate.md` define o gate manual Android/Windows/Web; a execucao real fica como proximo passo, sem bloquear a track.

## O Que Nao Esta Bom Ainda

- A fronteira entre presenters, helpers e host ainda usa muitos callbacks dinamicos (`host.call`). Esta aceitavel para nao mexer em UX agora, mas pode virar uma etapa futura de tipagem/ports menores.
- O modelo `players.save_type` segue como atalho alpha. A migracao para `account_profiles` + `game_saves` ainda precisa de decisao e pacote proprio.
- Progression/Economia segue em `REVIEW`: sem tuning numerico ate uma rodada humana no Godot com save real e Progression Lab.
- Assets finais, UX Android em aparelho real, keystore release e live ops ainda nao sao maturidade de produto. O jogo esta pronto para alpha fechado, nao para beta publico.
- O walkthrough manual real Android/Windows/Web ainda precisa acontecer usando o gate da Track 13 antes de novas features.
- O release flow agora e seguro por default, mas ainda precisa de uma rodada real de `Mode Package` com artefatos frescos antes de virar rotina de publicacao.

## Proximo Passo

Executar walkthrough manual real em Android, Windows e Web autenticado/preview usando `docs/track-13-manual-walkthrough-gate.md`:

1. `Entry`: login/criar conta e recuperacao de save.
2. `Refugio`: primeira tela, hotspots, Base embutida, Loja/Social/Competicao.
3. `Batalha`: iniciar, assistir/pular, summary minimo, logs.
4. `Conta`: update gate, save normal, Progression Lab isolado.
5. Registrar bloqueios, friccao e qualquer diferenca entre Android, Windows e Web.

Nao abrir feature nova, tuning numerico ou migration de conta/save antes desse walkthrough.

## Validacao Recomendada

```powershell
cd <WORKTREE>\Projetos\draxos-mobile
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
.\tools\validate_foundation.ps1 -ProjectDir . -Profile Full -RequireClean:$false
npx -y deno check supabase/functions/release/index.ts server/functions/release/index.ts server/tests/release_artifacts_remote_smoke.ts
git diff --check
```

## Read Next

1. `../AGENTS.md`
2. `implementation/tracks/track-13-validation-release-safety/current-status.md`
3. `implementation/tracks/track-13-validation-release-safety/scope.md`
4. `implementation/tracks/track-13-validation-release-safety/validation-matrix.md`
5. `implementation/tracks/track-13-validation-release-safety/release-safety-contract.md`
6. `docs/track-13-manual-walkthrough-gate.md`
7. `docs/release-ops-checklist.md`
