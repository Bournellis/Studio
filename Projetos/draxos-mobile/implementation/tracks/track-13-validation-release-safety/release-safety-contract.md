# Track 13 - Release Safety Contract

## Contrato Do Publish Script

`tools/publish_internal_alpha.ps1` aceita:

```powershell
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Plan
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Package
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Upload -ConfirmRemoteMutation
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode DeployManifest -ConfirmRemoteMutation
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode FullPublish -ConfirmRemoteMutation
```

## Regras

- `Plan` e o default e nunca chama Storage, secrets, function deploy, Wrangler ou upload.
- `Package` prepara somente `build/internal-alpha/publish/`, release plan e manifest local.
- `Upload` pode subir Storage apenas com `-ConfirmRemoteMutation`.
- `DeployManifest` pode atualizar manifest override/deploy da Edge Function apenas com `-ConfirmRemoteMutation`.
- `FullPublish` combina upload, manifest/deploy e verificacoes remotas, tambem apenas com `-ConfirmRemoteMutation`.
- Flags antigas (`-SkipUpload`, `-UseManifestSecret`, `-SkipManifestSecret`) sem `-Mode` rodam apenas `Plan` e emitem aviso.
- Chaves client/publicaveis sao aceitas; chaves admin/secret-like sao recusadas.

## Guardas Automatizados

`tools/check_release_safety.ps1` falha se:

- `publish_internal_alpha.ps1` deixar de ter `Mode Plan` como default.
- `ConfirmRemoteMutation` desaparecer.
- comandos mutantes aparecerem antes dos blocos de confirmacao/modo.
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
