# Battle Drama v1.1

- Data: `2026-05-29`
- Projeto: `Projetos/draxos-mobile`
- Agente: Codex
- Branch: `codex/draxos-mobile/battle-drama-v1-1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--battle-drama-v1-1`
- Base: `master` em `f437fac`
- Status: `DONE`

## Objetivo

Executar o pacote Battle Drama v1.1, uma iteracao client-only sobre Battle Presentation v1 para tornar a batalha Web/PC mais perceptivelmente diferente: menos leitura de mock/debug, mais foco visual no lance atual, combatentes mais presentes e palco mais dramatico.

## Entrega

- `BattleStage2D`: arena com luz lateral mais forte, foco de choque, guias de piso mais suaves, callout de lance maior e leitura compacta de pressao/vida.
- `BattleActorMarker`: combatente procedural maior, com silhueta de robe, cajado, aura, barreira e pulso mais legiveis.
- Marcadores vazios de status/cooldown deixam de renderizar icone de traco que parecia placeholder/debug.
- Familiares e invocacoes ganharam presenca visual maior sem mudar contrato de replay.
- Politica operacional registrada: quando um pacote visual aprovado precisar de teste humano, publicar Internal Alpha vira etapa padrao apos validacao.

## Publicacao

- Release root: `internal-alpha/v0-battle-drama-v1-1-20260529`
- Preview Web validado: `https://7261c476.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Asset root Web: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-drama-v1-1-20260529/web`
- Android APK: `31637525` bytes, SHA256 `30c7b8c90af00221de57e63d2434c80a774ebfe888e8cc6c6119228a23c1f50d`.
- PC ZIP: `40103282` bytes, SHA256 `921795a9a3d3ffa96a41e77d39cfb1b3bee0773d42deed87bdf34d8506b8c93c`.
- Cloudflare Pages stable foi redeployado, mas leitura publica sem login ainda cai no Cloudflare Access; revisao Web deve usar o preview validado ou sessao autenticada.
- Deploy do override do release manifest ficou bloqueado antes de mutacao remota por falta de `SUPABASE_ACCESS_TOKEN`.

## Validacao

- One-time Godot `--headless --import`: PASS em worktree novo.
- GUT `tests/client`: PASS (`119/119`, `1896` asserts).
- `tools/smoke_responsive_layout.gd`: PASS.
- `validate_foundation.ps1 -Profile Client`: PASS.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- Cloudflare Pages deploy: PASS.
- Web preview/root/asset/download checks: PASS para `/web/index.html`, `index.js`, `index.pck`, `index.wasm`, APK e ZIP.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`: BLOCKED por falta de `SUPABASE_ACCESS_TOKEN`.

## Handoff

Pacote implementado, validado, publicado e documentado. Proximo passo de produto: revisao humana de Battle Drama v1.1 em Android/Windows/Web e escolha do proximo pacote.
