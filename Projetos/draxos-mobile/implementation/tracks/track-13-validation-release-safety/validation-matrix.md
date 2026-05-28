# Track 13 - Validation Matrix

## Perfis

| Profile | Conteudo | Remoto | Uso |
|---|---|---|---|
| `Quick` | `git diff --check`, parse PowerShell, mirrors server/supabase, Deno release check leve, readiness estrutural | Nao | Pre-commit rapido |
| `Client` | `Quick` + `tools/validate.gd`, GUT client, `smoke_runtime_config.gd`, `smoke_foundation_hardening.gd`, `smoke_exports.gd` | Nao | Validacao client/foundation |
| `Release` | `Quick` + manifest typecheck, release plan local, secrets/client scan, release safety, Track 13 readiness | Nao por default | Validacao release-safe |
| `Full` | `Client` + `Release` | Nao por default | Gate local completo |
| Remote read-only | `release_artifacts_remote_smoke.ts` | Sim, somente leitura | Apenas com `-IncludeRemoteReadOnly` e env publico |

## Comandos

```powershell
.\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick
.\tools\validate_foundation.ps1 -ProjectDir . -Profile Client -GodotExe "D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe"
.\tools\validate_foundation.ps1 -ProjectDir . -Profile Release
.\tools\validate_foundation.ps1 -ProjectDir . -Profile Full -RequireClean:$false
```

Remote read-only:

```powershell
$env:SUPABASE_URL='https://<project-ref>.supabase.co'
$env:SUPABASE_PUBLISHABLE_KEY='sb_publishable_<public-key>'
.\tools\validate_foundation.ps1 -ProjectDir . -Profile Release -IncludeRemoteReadOnly
```

## Relatorios

- JSON: `build/validation/foundation-validation-latest.json`
- Markdown: `build/validation/foundation-validation-latest.md`

Cada step registra `PASS`, `FAIL` ou `SKIP`, duracao, comando, profile/stage e motivo.

## Falhas Com Mensagem Clara

- Godot exe ausente.
- Deno/Supabase CLI indisponivel.
- Artefatos locais ausentes em `Mode Package` ou modo remoto.
- Env remoto ausente com `-IncludeRemoteReadOnly`.
- Cloudflare Access precisa de preview liberado ou flag/documento apropriado.
- Chave Supabase com aparencia de admin/secret.
- Tentativa de `Upload`, `DeployManifest` ou `FullPublish` sem `-ConfirmRemoteMutation`.
