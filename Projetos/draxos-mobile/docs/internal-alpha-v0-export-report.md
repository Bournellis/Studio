# DraxosMobile - Internal Alpha v0 Export Report

- Data: `2026-05-27`
- Track: `T03-P16 - Export Android, PC E Web`
- Status: `COMPLETE - LOCAL_ARTIFACTS_GREEN`
- Canal: `internal_alpha`
- Versao in-app: `0.0.1-alpha.0`
- Version code: `1`
- Backend remoto: `https://armxgipvnbbshzqawklw.supabase.co`
- Manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

## Resultado

As tres builds locais foram exportadas com a configuracao publica do Supabase remoto injetada apenas durante o build por `online/internal_alpha_runtime_config.gd`. O arquivo temporario e removido ao final do script e segue ignorado pelo Git.

| Plataforma | Artefato local | Bytes | SHA256 |
|---|---|---:|---|
| Android APK | `build/android/draxos-mobile-alpha.apk` | `27795524` | `87533f150ffb773ef3bb7e41f6d69e98c7fdd4a85cbbf1e28544040aaade2448` |
| PC Windows ZIP | `build/pc/draxos-mobile-alpha.zip` | `36315593` | `e678fb7e2d2e984ad7356a47cbdcf4fdb12628ebe23636ab1a3b976365111082` |
| Web index | `build/web/index.html` | `5442` | `66b279ad9c9d9e1a5ae27f78880b98c8ba0dc8d788da955f1955754ab0cff71e` |

Metadata local gerado:

- `build/internal-alpha/release-artifacts.json`
- `build/internal-alpha/SHA256SUMS.txt`

## Rebuild T03-P17A - Android UI Usability Pass

Em 2026-05-27, apos o feedback de usabilidade no APK, foi gerado um rebuild local com a passada compacta do Hub/abas. Este rebuild foi aprovado por Fabio e republicado em APK/PC ZIP/manifest/Cloudflare Pages durante `T03-P17A`.

Status manual: aprovado por Fabio em 2026-05-27 como bom o suficiente para seguir para republicacao. Reexport de 2026-05-27 15:53 UTC atualizou os hashes abaixo.

| Plataforma | Artefato local | Bytes | SHA256 |
|---|---|---:|---|
| Android APK | `build/android/draxos-mobile-alpha.apk` | `27811908` | `6c39ce9a63eaf4796a67a9e5a29e9252f1f03266f713ffa58c5d2333c15102d6` |
| PC Windows ZIP | `build/pc/draxos-mobile-alpha.zip` | `36331728` | `4b7dc516bc4c5c4895930f8732ad9e97733cca85ba7574c9a0308c705982d236` |
| Web index | `build/web/index.html` | `5442` | `04c8da05bcada497128a9c506092579bf47075d8da636634ffb1722e3cbd1a1b` |

## Android

O APK foi exportado como `debug_fallback`, assinado pela debug keystore local configurada no Godot. Isso e suficiente para instalar por link no teste interno Fabio + 1 amigo, desde que as proximas builds Android usadas para update continuem saindo da mesma maquina/keystore ou que uma keystore release dedicada seja configurada antes da distribuicao.

Para gerar APK release assinado, configurar no arquivo local ignorado `.env.internal-alpha.local` ou no ambiente:

```powershell
DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PATH=D:\caminho\para\draxos-mobile-internal-alpha.keystore
DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_USER=draxosmobilealpha
DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PASSWORD=<senha-local>
```

Nunca versionar a keystore nem a senha.

## Export Config

Correcoes aplicadas nesta etapa:

- Android export exige `rendering/textures/vram_compression/import_etc2_astc=true`.
- Android preset habilita `permissions/internet` e `permissions/access_network_state`.
- Android preset usa `version/code=1` e `version/name=0.0.1` para metadata nativa, enquanto a versao in-app segue `0.0.1-alpha.0`.
- `icon.svg` foi adicionado como placeholder proprio do projeto para eliminar warning de icone ausente.
- Presets excluem ferramentas, docs, servidor, portal, scratch e `build/**`.
- Script `tools/export_internal_alpha.ps1` limpa as pastas de build antes de exportar e nao tenta release Android sem keystore release completa.

## Validacao Executada

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_exports.gd
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\export_internal_alpha.ps1 -ProjectDir . -GodotExe "D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe" -AllowAndroidDebugFallback
```

Resultado: ambos passaram. O Godot ainda emite `ObjectDB instances leaked at exit` ao sair do export headless; nao bloqueou os artefatos e permanece como ruido conhecido do processo de export local.

## Proximo Passo

`T03-P17` publicou APK/PC em links unlisted, publicou Portal/Web no Cloudflare Pages e atualizou o manifest remoto com hashes/links finais. Detalhes em `internal-alpha-v0-publication-report.md`. `T03-P18` fechou o pacote final em `internal-alpha-v0-handoff.md`.
