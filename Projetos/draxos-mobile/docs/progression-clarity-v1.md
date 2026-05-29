# Progression Clarity v1

- Status: `PUBLICADO`
- Data: `2026-05-29`
- Escopo: client-only

## Objetivo

Progression Clarity v1 torna o crescimento do save mais legivel no loop publicado: o jogador deve entender nivel, poder, recompensa recente, proximos marcos e proxima meta sem precisar abrir telas tecnicas ou interpretar ids.

O pacote nao altera backend, schema, migrations, simulador, economia, tuning, armas, spells, recompensas ou catalogos.

## O Que Mudou

- Refugio ganhou um painel compacto `Progresso` dentro do layout imersivo.
- Preparacao ganhou `Proximos marcos`, derivado do estado atual de preparacao e dos niveis conhecidos de desbloqueio.
- Resultado da batalha ganhou um bloco `Progresso` com nivel/poder atuais, XP da recompensa quando houver e proximo marco visivel.
- A leitura de progresso foi centralizada em `modes/boot/surfaces/progression_clarity_presenter.gd`.
- A UI usa dados existentes de `SessionStore.player`, `SessionStore.combat_build_state`, `SessionStore.base_state` e `last_battle_rewards`.

## Linguagem Publica

Usar:

- `Nivel`
- `Poder`
- `Progresso`
- `Proximos marcos`
- `habilidade`
- `doutrina`
- `familiar`
- `preparacao`

Evitar em copy visivel:

- `build`
- `behavior`
- `slot`
- `endpoint`
- `schema`
- `snapshot`
- `server-authoritative`
- ids crus quando houver nome humanizado

## Contratos

- API publica: sem mudanca.
- Supabase/schema/migration: sem mudanca.
- Simulador e recompensas: sem mudanca.
- Publicacao: cliente/export concluida no Internal Alpha.

## Validacao Executada

- GUT em `tests/client`: PASS, `123/123` testes e `1984` asserts.
- `tools/smoke_foundation_loop.gd`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS.
- `validate_foundation.ps1 -Profile Client`: PASS.
- `git diff --check`: PASS.
- `tools/smoke_foundation_surfaces.gd`: BLOQUEADO localmente sem Supabase local em `127.0.0.1:54321`.

## Publicacao

Publicacao Internal Alpha concluida em 2026-05-29.

- Release root: `internal-alpha/v0-progression-clarity-v1-20260529`.
- Web preview publico verificado: `https://3cf22c65.draxos-mobile-internal-alpha.pages.dev/web`.
- Stable Pages respondeu `200 text/html`, mas a checagem anonima nao confirmou o release root por causa da camada/roteamento do Pages; usar o preview verificado para teste direto.
- Web asset root: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-progression-clarity-v1-20260529/web`.
- APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-progression-clarity-v1-20260529/downloads/draxos-mobile-alpha.apk`.
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-progression-clarity-v1-20260529/downloads/draxos-mobile-alpha.zip`.

Observacoes de release:

- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- Cloudflare Pages deploy: PASS, preview `https://3cf22c65.draxos-mobile-internal-alpha.pages.dev`.
- HEAD remoto passou para `index.pck`, `index.wasm`, APK e ZIP no release root versionado.
- `publish_internal_alpha.ps1 -Mode DeployManifest` nao foi executado porque `SUPABASE_ACCESS_TOKEN` nao estava disponivel; o pacote Cloudflare publicado usa o manifest empacotado com os links corretos.

## Fora De Escopo

- XP bar numerica ou curva de nivel.
- Previsao de vitoria.
- Recomendacao de contra-escolha por oponente.
- Tuning de poder, economia, recompensas ou unlocks.
- Novas armas, spells, doutrinas, familiares ou estruturas.
- Novo endpoint de progressao.
