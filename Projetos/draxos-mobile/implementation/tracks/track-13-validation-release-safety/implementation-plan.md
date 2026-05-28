# Track 13 - Implementation Plan

## Sequencia Executada

1. Criar worktree dedicada a partir da Track 12 e registrar Doing.
2. Rodar baseline nao mutante: Godot import quando necessario, `tools/validate.gd`, GUT client, Deno check de smokes de release e `git diff --check`.
3. Criar `tools/validate_foundation.ps1` com perfis `Quick`, `Client`, `Release` e `Full`.
4. Endurecer `tools/publish_internal_alpha.ps1` com `Mode Plan/Package/Upload/DeployManifest/FullPublish`.
5. Criar `tools/check_release_safety.ps1` para impedir retorno de publicacao mutante por default.
6. Criar `tools/check_track13_readiness.ps1` para validar docs, status, mirrors, budget de `boot.gd` e Kanban.
7. Criar gate manual `docs/track-13-manual-walkthrough-gate.md`.
8. Atualizar docs locais, status do projeto e coordenacao do estudio.
9. Rodar validacao final e mover Doing para Done.

## Validacao Alvo

```powershell
cd <WORKTREE>\Projetos\draxos-mobile
.\tools\validate_foundation.ps1 -ProjectDir . -Profile Full -RequireClean:$false
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
npx -y deno task --cwd server/functions check
npx -y deno task --cwd supabase/functions check
npx -y deno check server/tests/release_manifest_smoke.ts server/tests/release_artifacts_remote_smoke.ts server/tests/internal_alpha_remote_smoke.ts
git diff --check
```

Remote read-only e opcional:

```powershell
.\tools\validate_foundation.ps1 -ProjectDir . -Profile Release -IncludeRemoteReadOnly
```

## Risco Controlado

- O runner serializa checks Godot/GUT para evitar disputa do app userdata.
- `publish_internal_alpha.ps1` gera plano local mesmo sem artefatos, com bloqueios claros para modos Package/remotos.
- `Upload`, `DeployManifest` e `FullPublish` falham imediatamente sem `-ConfirmRemoteMutation`.
- Readiness final falha se `boot.gd` passar de `1500` linhas, mirrors divergirem ou docs/status sairem da Track 13.
