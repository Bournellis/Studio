# tools/

Ferramentas de desenvolvimento e validacao.

- `validate.gd` - validacao headless do projeto Godot, gerando conteudo, checando contrato client e rodando GUT.
- `smoke_exports.gd` - smoke leve dos presets Android Alpha, PC Windows Alpha e PC Browser Alpha.
- `export_internal_alpha.ps1` - exporta Android APK, PC Windows ZIP e Web usando `.env.internal-alpha.local`, sem commitar config real do cliente.
- `publish_internal_alpha.ps1` - publica APK/ZIP no Supabase Storage unlisted, prepara portal/Web para host estatico externo e valida `release/manifest`.
- `build_cloudflare_pages_package.ps1` - gera o pacote hibrido para Cloudflare Pages, mantendo HTML no Cloudflare e assets grandes do Web export no Supabase Storage.
- `smoke_dev_labs.gd` - smoke do caminho real `OS.execute` para Battle Lab e Progression Lab.
- `smoke_dev_lab_ui.gd` - smoke visual/comportamental das telas dev-only; salva screenshots quando rodado sem `--headless`.
- `smoke_runtime_config.gd` - smoke focado do parser/fallback conservador de `runtime_config_v1`.
- `smoke_foundation_surfaces.gd` - smoke focado de Base, Shop, Social e Competition usando fluxos existentes do cliente contra Supabase local/remoto configurado.
- `smoke_foundation_hardening.gd` - smoke sem rede dos contratos Track 08: rotas/back, UI mobile, session/save boundary e battle mode fullscreen.
- `content_generator.gd` - gera `data/generated/draxos_mobile_catalog.tres` a partir de `data/definitions/*.json`.
- `create_boot_scene.gd` - gera a cena boot minima via API do Godot.
- `economy_simulator/` - fonte JSON e gerador Deno/TypeScript para a planilha de economia de seasons.
- `battle_lab/` - runner Deno do laboratorio de combate, usado pelo HTML/CSV/JSON e pela tela dev-only Godot.
- `progression_lab/` - modelo, gerador e seeder local para saves saudaveis 2h-20h, relatorios, bots e Progression Lab Dev.

Validacao local:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_runtime_config.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_foundation_surfaces.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_foundation_hardening.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_dev_labs.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_dev_lab_ui.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_exports.gd
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

Publicacao Internal Alpha v0:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y supabase db push
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir .
```

O script usa `SUPABASE_PROJECT_REF`, `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY` de `.env.internal-alpha.local`, publica no bucket `draxos-internal-alpha`, valida APK/ZIP via Storage e redeploya `release`. Supabase Storage/Edge Functions nao servem HTML como pagina.

Para Cloudflare Pages, gere o pacote hibrido primeiro:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_cloudflare_pages_package.ps1 -ProjectDir .
```

Checklist operacional antes de qualquer publicacao nova: `docs/release-ops-checklist.md`.

Publique `build/internal-alpha/cloudflare-pages/` ou `build/internal-alpha/draxos-mobile-cloudflare-pages.zip` no Cloudflare Pages. Depois rode:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -ProjectDir . -StaticSiteBaseUrl "https://draxos-mobile-internal-alpha.pages.dev" -SkipUpload -UseManifestSecret
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
