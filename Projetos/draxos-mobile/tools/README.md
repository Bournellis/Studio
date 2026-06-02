# tools/

Ferramentas de desenvolvimento e validacao.

- `validate.gd` - validacao headless do projeto Godot, gerando conteudo, checando contrato client e rodando GUT.
- `validate_foundation.ps1` - runner unico Track 13/14/17/18 com perfis `DocsOnly`, `ClientQuick`, `ServerQuick`, `ModePlatform`, `DatabaseLocal`, `FullLocal`, `ReleaseDryRun`, `RemoteReadOnly` e `FullPublish`; gera relatorios em `build/validation/`. Os perfis antigos `Quick`, `Client`, `Release` e `Full` continuam como aliases.
- `check_foundation_expansion_readiness.ps1` - checker read-only da Foundation Expansion Readiness: contratos, migrations espelhadas, ruleset, shell contracts e testes obrigatorios.
- `check_release_safety.ps1` - guarda de regressao para publish seguro, parse PowerShell e manifest defaults espelhados.
- `check_android_release_keystore.ps1` - gate local de Android release keystore: tuple completa, arquivo local existente quando configurado, ausencia de senha concreta tracked e modo `ReleaseCandidate` sem `debug_fallback`.
- `check_track13_readiness.ps1` - readiness final da Track 13: docs/status, mirrors, Kanban e budgets duros de shell/presenter (`boot.gd`, `boot_runtime.gd`, `hub_surface_presenter.gd`, `hub_surface_full_presenter.gd`).
- `check_agent_ops_foundation.ps1` - readiness da Track 14: entrada de agentes, indice documental, portfolio/Kanban, terminologia viva e ausencia de entrypoints obsoletos.
- `smoke_exports.gd` - smoke leve dos presets Android Alpha, PC Windows Alpha e PC Browser Alpha.
- `export_internal_alpha.ps1` - exporta Android APK, PC Windows ZIP e Web usando `.env.internal-alpha.local`, sem commitar config real do cliente.
- `publish_internal_alpha.ps1` - gera plano/package local por default e so publica/remota com `Mode` explicito + `-ConfirmRemoteMutation`.
- `validate_mode_definitions.ps1` - valida schema estrito dos descriptors em `data/definitions/modes/*`, templates e registry paths sem tocar runtime.
- `mode_definitions/scaffold_mode.ts` - gera dry-run de scaffold futuro `planned_disabled` para descriptors/docs; `--write` so deve ser usado apos decisao de pacote.
- `build_cloudflare_pages_package.ps1` - gera o pacote hibrido para Cloudflare Pages, mantendo HTML no Cloudflare e assets grandes do Web export no Supabase Storage.
- `smoke_web_launch_remote.ps1` - abre um preview Web remoto em Chrome/Edge via CDP, espera o overlay Godot sumir, valida release root/assets criticos e salva screenshot/logs em `build/diagnostics/`.
- `generate_grimoire_catalog.ts` - gera o modulo compartilhado `grimoire_catalog.ts` para `GET /content/grimoire` a partir de `data/definitions/*.json` e a copia estatica do portal em `portal/internal-alpha/assets/grimoire-catalog.json`.
- `ops_readonly.ts` - CLI ops read-only para manifest/modes/status/audit/reward/session summaries usando publishable key + JWT de usuario, sem service role remoto.
- `smoke_dev_labs.gd` - smoke do caminho real `OS.execute` para Battle Lab e Progression Lab.
- `smoke_dev_lab_ui.gd` - smoke visual/comportamental das telas dev-only; salva screenshots quando rodado sem `--headless`.
- `capture_track15_mobile_ux.gd` - captura screenshots locais da Track 15 em `build/track15_mobile_ux_checkpoint/` quando rodado sem `--headless`.
- `smoke_runtime_config.gd` - smoke focado do parser/fallback conservador de `runtime_config_v1`.
- `smoke_foundation_surfaces.gd` - smoke focado de Base, Shop, Social e Competition usando fluxos existentes do cliente contra Supabase local/remoto configurado.
- `smoke_foundation_hardening.gd` - smoke sem rede dos contratos Track 08: rotas/back, UI mobile, session/save boundary e battle mode fullscreen.
- `smoke_responsive_layout.gd` - smoke sem rede do contrato responsivo Foundation: Entry Labs, Refugio e Batalha precisam caber em viewports Android portrait e Web/desktop.
- `content_generator.gd` - gera `data/generated/draxos_mobile_catalog.tres` a partir de `data/definitions/*.json`.
- `create_boot_scene.gd` - gera a cena boot minima via API do Godot.
- `economy_simulator/` - fonte JSON e gerador Deno/TypeScript para a planilha de economia de seasons.
- `battle_lab/` - runner Deno do laboratorio de combate, usado pelo HTML/CSV/JSON e pela tela dev-only Godot.
- `progression_lab/` - modelo, gerador e seeder local para saves saudaveis 2h-20h, relatorios, bots e Progression Lab Dev.

Validacao local:

```powershell
.\tools\validate_foundation.ps1 -ProjectDir . -Profile DocsOnly
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick -GodotExe "D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe"
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ServerQuick
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ModePlatform
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun
.\tools\validate_foundation.ps1 -ProjectDir . -Profile FullLocal
.\tools\validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_mode_definitions.ps1 -ProjectDir .
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_agent_ops_foundation.ps1 -ProjectDir .
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_android_release_keystore.ps1 -ProjectDir . -Mode InternalAlpha
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_runtime_config.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_surfaces.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_hardening.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_loop.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_dev_labs.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_dev_lab_ui.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_exports.gd
```

Observacao de hardening: `DocsOnly` e os perfis compostos falham se `boot_runtime.gd` passar de 1200 linhas ou `hub_surface_full_presenter.gd` passar de 900 linhas. Esse estouro e bloqueio de split, nao estado final aceito.

Checkpoint visual Track 15:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --path . -s res://tools/capture_track15_mobile_ux.gd
```

Export Internal Alpha v0:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\export_internal_alpha.ps1 -ProjectDir . -GodotExe "D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe" -AllowAndroidDebugFallback
```

Para Android release-signed, configurar no `.env.internal-alpha.local` ignorado:

```powershell
DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PATH=D:\caminho\para\draxos-mobile-internal-alpha.keystore
DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_USER=draxosmobilealpha
DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PASSWORD=<senha-local>
```

Antes de ampliar distribuicao Android para alem do teste interno:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_android_release_keystore.ps1 -ProjectDir . -Mode ReleaseCandidate
```

Release plan seguro Internal Alpha v0:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Plan
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Package
```

`Mode Plan` e default e nunca publica. `Mode Package` so prepara arquivos locais em `build/internal-alpha/`.

Publicacao remota exige tarefa aprovada e confirmacao explicita:

```powershell
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Upload -ConfirmRemoteMutation
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode DeployManifest -ConfirmRemoteMutation
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode FullPublish -ConfirmRemoteMutation
```

O script usa `SUPABASE_PROJECT_REF`, `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY` de `.env.internal-alpha.local` para modos remotos. Supabase Storage/Edge Functions nao servem HTML como pagina.

Para Cloudflare Pages, gere o pacote hibrido primeiro:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_cloudflare_pages_package.ps1 -ProjectDir .
```

Depois do deploy Cloudflare Pages, valide o hash preview liberado como prova tecnica do Web abrindo:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\smoke_web_launch_remote.ps1 -WebUrl "https://<preview>.draxos-mobile-internal-alpha.pages.dev/web/index.html" -ExpectedReleaseRoot "internal-alpha/<release-root>"
```

Checklist operacional antes de qualquer publicacao nova: `docs/release-ops-checklist.md`.

Ops read-only:

```powershell
npx -y deno run --allow-net --allow-env tools/ops_readonly.ts --target manifest,modes,status,audit,rewards,sessions --mode-id openworld --format pretty
```

Publique `build/internal-alpha/cloudflare-pages/` ou `build/internal-alpha/draxos-mobile-cloudflare-pages.zip` no Cloudflare Pages. Depois rode:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode DeployManifest -StaticSiteBaseUrl "https://draxos-mobile-internal-alpha.pages.dev" -ConfirmRemoteMutation
```

Grimorio do site alpha:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno run --allow-read --allow-write tools/generate_grimoire_catalog.ts
```

Simulador de economia:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno run --allow-read --allow-write tools/economy_simulator/generate.ts
```

Battle Lab:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --compare-with 2026-05-21_archetype_source_tuning_v02
```

Progression Lab:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts
npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all
```
