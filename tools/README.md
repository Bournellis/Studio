# Estudio Governance Tooling

The v2 toolchain is dependency-free beyond Python 3.11, PowerShell 5.1 and
Git/Git LFS. It never publishes, authenticates, contacts a project backend or
probes a physical device.

## Public commands

```powershell
.\tools\studio_doctor.ps1 -Mode Core -Project AllOfficial
.\tools\validate_estudio.ps1 -Profile DocsOnly -Project AllOfficial
.\tools\validate_estudio.ps1 -Profile FastSuite -Project Active -GodotExe <path>
.\tools\validate_estudio.ps1 -Profile Runtime -Project JogoDaCopa -GodotExe <path>
```

`-AuditOnly` reports the same findings but returns success during the migration
window. It is forbidden in CI. A normal run remains strict and never prints a
false PASS for an unmet contract.

Typed project runners live in `qa/qa_manifest.json`. Their human index must use
the marker forms shown below. Allowed runner
types are `godot_script`, `gut_scripts`, `powershell`, `python`, `deno` and
`node`; arbitrary shell commands are not accepted.

```text
- runner_id: `<id>`
- capability_id: `<id>`
```

FastSuite calibration is explicit:

```powershell
python .\tools\calibrate_fast_suite.py --project JogoDaCopa --godot-exe <path>
python .\tools\calibrate_fast_suite.py --project JogoDaCopa --godot-exe <path> --write-baseline
```

The first command is a dry run. Validation and worktree closure never mutate or
recalibrate the baseline.

## Safety contracts

- Every runner is wrapped in an exact Git snapshot. Any tracked or untracked
  change becomes `VALIDATOR_SIDE_EFFECT`; files are never restored implicitly.
- UID, health, storage and evidence policies are prospective and preserve
  historical assets and debt through explicit baselines.
- `close_worktree_powershell.ps1` supports only local fast-forward integration,
  requires pre/post validation and never invokes a remote command.
- `check_doc_drift.ps1` remains available as a compatibility alias for the
  complete `DocsOnly` profile.
