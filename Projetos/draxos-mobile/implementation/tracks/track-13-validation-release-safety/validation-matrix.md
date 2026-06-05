# Track 13 - Validation Matrix

## Perfis

`tools/validate_foundation.ps1` agora separa os gates por intencao operacional. Os perfis antigos (`Quick`, `Client`, `Release`, `Full`) continuam aceitos como aliases de compatibilidade.

| Profile | Conteudo | Remoto | Uso |
|---|---|---|---|
| `DocsOnly` | `git diff --check`, parse PowerShell, readiness estrutural, budgets reais de shell/presenter, drift baseline, termos legados e secret-scan local | Nao | Pre-commit de docs/tools e sanity rapido |
| `ClientQuick` | `DocsOnly` + Godot `validate.gd`, GUT client e smokes client sem rede | Nao | Validacao client/foundation sem modo platform dedicado |
| `ServerQuick` | `DocsOnly` + mirrors server/supabase, registry/ruleset mirrors, Deno typecheck, tests fundacionais, PVE Arena contracts e tasks de functions | Nao | Backend/contracts/Track 17/18 sem banco local vivo |
| `ModePlatform` | `DocsOnly` + contracts do Mode Platform e smokes Godot de Mode Hub/Openworld/Ops | Nao | Track de modos e registry V1 |
| `DatabaseLocal` | `DocsOnly` + RPC transacional local, Edge local, mode platform live proof e admin/RLS local | Nao remoto; exige stack local | Provas locais de database/RLS/RPC |
| `ReleaseDryRun` | `DocsOnly` + manifest typecheck, `publish_internal_alpha.ps1 -Mode Plan`, secret-scan pos-plano, release safety, Track 13 readiness e Track 14 agent ops | Nao | Dry-run seguro de release |
| `RemoteReadOnly` | `ReleaseDryRun` + `release_artifacts_remote_smoke.ts` com publishable key | Sim, somente leitura | Smoke remoto sem mutacao |
| `FullLocal` | `DocsOnly` + `ServerQuick` + `ClientQuick` + `ModePlatform` + `DatabaseLocal` + `ReleaseDryRun` | Nao remoto | Gate local completo, com stack local esperada |
| `FullPublish` | Desabilitado no runner; publicacao real vive em `publish_internal_alpha.ps1 -Mode FullPublish -ReleaseRoot <root> -ConfirmRemoteMutation` | Sim, mutante fora do runner | Rejeitar no runner e publicar somente pelo script de publish em tarefa aprovada |

Aliases de compatibilidade:

| Alias antigo | Equivalente novo |
|---|---|
| `Quick` | `ServerQuick` + compatibilidade com o antigo preflight server-heavy |
| `Client` | `ClientQuick`, preservando o preflight server-heavy antigo |
| `Release` | `ReleaseDryRun`, preservando o preflight server-heavy antigo |
| `Full` | `FullLocal` |

## Comandos

```powershell
.\tools\validate_foundation.ps1 -ProjectDir . -Profile DocsOnly
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick -GodotExe "D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe"
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ServerQuick
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ModePlatform
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun
.\tools\validate_foundation.ps1 -ProjectDir . -Profile FullLocal -RequireClean:$false
```

Database local:

```powershell
.\tools\validate_foundation.ps1 -ProjectDir . -Profile DatabaseLocal
```

Remote read-only:

```powershell
$env:SUPABASE_URL='https://<project-ref>.supabase.co'
$env:SUPABASE_PUBLISHABLE_KEY='sb_publishable_<public-key>'
.\tools\validate_foundation.ps1 -ProjectDir . -Profile RemoteReadOnly
```

Full publish nao roda pelo runner. Validar primeiro e publicar pelo script de publish:

```powershell
.\tools\validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun
.\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode FullPublish -ReleaseRoot "internal-alpha/v0-<package-slug>-YYYYMMDD-<shortsha>" -ConfirmRemoteMutation
```

## Relatorios

- JSON: `build/validation/foundation-validation-latest.json`
- Markdown: `build/validation/foundation-validation-latest.md`

O relatorio registra `requested_profile`, `effective_profile`, stages habilitados, flags locais/remotas, resumo PASS/FAIL/SKIP e uma secao `Failed Or Blocked Steps` quando houver falhas.

Budgets de shell/presenter sao gates duros: `boot.gd <= 1200`, `boot_runtime.gd <= 1200`, `hub_surface_presenter.gd <= 900` e `hub_surface_full_presenter.gd <= 900`. Estouro em `boot_runtime.gd` ou `hub_surface_full_presenter.gd` deve ser tratado como bloqueio de hardening, nao como baseline aceito.

## Falhas Com Mensagem Clara

- Godot exe ausente.
- Deno/Supabase CLI indisponivel.
- Drift nos marcadores vivos de baseline/status.
- Divergencia em mirrors server/supabase, ruleset ou catalogo Arena PVE.
- Budgets reais de shell/presenter estourados, especialmente runtime/presenter quente acima do limite.
- Termos legados em docs vivos de entrada/produto.
- Secret-like values em cliente, portal, manifest, artefatos locais ou env publico.
- Env remoto ausente no `RemoteReadOnly`.
- Cloudflare Access precisa de preview liberado ou flag/documento apropriado.
- Tentativa de `FullPublish` pelo runner.
- Tentativa de `publish_internal_alpha.ps1 -Mode FullPublish` sem `-ReleaseRoot` ou sem `-ConfirmRemoteMutation`.
