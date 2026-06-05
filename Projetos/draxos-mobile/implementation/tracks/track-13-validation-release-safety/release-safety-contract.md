# Track 13 - Release Safety Contract

## Contrato Do Publish Script

`tools/publish_internal_alpha.ps1` aceita:

```powershell
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Plan
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Package -ReleaseRoot "internal-alpha/v0-<package-slug>-YYYYMMDD-<shortsha>"
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Upload -ReleaseRoot "internal-alpha/v0-<package-slug>-YYYYMMDD-<shortsha>" -ConfirmRemoteMutation
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode DeployManifest -ReleaseRoot "internal-alpha/v0-<package-slug>-YYYYMMDD-<shortsha>" -ConfirmRemoteMutation
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode FullPublish -ReleaseRoot "internal-alpha/v0-<package-slug>-YYYYMMDD-<shortsha>" -ConfirmRemoteMutation
```

## Regras

- `Plan` e o default e nunca chama Storage, secrets, function deploy, Wrangler ou upload.
- `Package` prepara somente `build/internal-alpha/publish/`, release plan e manifest local, sempre sob `-ReleaseRoot` versionado.
- `Upload` pode subir Storage apenas com `-ReleaseRoot` versionado e `-ConfirmRemoteMutation`.
- `DeployManifest` pode atualizar manifest override/deploy da Edge Function apenas com `-ReleaseRoot` versionado e `-ConfirmRemoteMutation`.
- `FullPublish` combina upload, manifest/deploy e verificacoes remotas, tambem apenas com `-ReleaseRoot` versionado e `-ConfirmRemoteMutation`.
- `validate_foundation.ps1 -Profile FullPublish` e rejeitado de proposito; o runner valida, mas nao publica.
- Flags antigas (`-SkipUpload`, `-UseManifestSecret`, `-SkipManifestSecret`) sem `-Mode` rodam apenas `Plan` e emitem aviso.
- Chaves client/publicaveis sao aceitas; chaves admin/secret-like sao recusadas.

## Guardas Automatizados

`tools/check_release_safety.ps1` falha se:

- `publish_internal_alpha.ps1` deixar de ter `Mode Plan` como default.
- `ConfirmRemoteMutation` desaparecer.
- comandos mutantes aparecerem antes dos blocos de confirmacao/modo.
- `validate_foundation.ps1` voltar a chamar `publish_internal_alpha.ps1` diretamente.
- `validate_foundation.ps1 -Profile FullPublish` deixar de falhar com mensagem de perfil desabilitado.
- parse PowerShell dos scripts de release falhar.
- defaults de `server/functions/release` e `supabase/functions/release` divergirem.

## Artefatos Locais

`Mode Plan` gera:

- `build/internal-alpha/release-plan.json`
- `build/internal-alpha/release-plan.md`

`Mode Package` tambem prepara:

- `build/internal-alpha/publish/manifest.json`
- `build/internal-alpha/publish/portal/`
- `build/internal-alpha/publish/web/`
- `build/internal-alpha/publish/downloads/`
