# Mode Documentation Template

- Status: `TEMPLATE`
- Descriptor template: `data/definitions/modes/_template/metadata.template.json`
- Placeholder template: `data/definitions/modes/_template/placeholder.template.json`

Use this template when a future mode or slice needs a contract scaffold. Keep the
first version non-playable unless the user explicitly selected an implementation
package.

Preferred generator:

```powershell
npx -y deno run --allow-read --allow-write tools/mode_definitions/scaffold_mode.ts --mode-id <mode_id> --display-name "<Mode Name>" --summary "<summary>"
```

The generator prints dry-run output by default. `--write` should only be used
after a package decision approves creating the staged files.

## Header

```text
# <Mode Name>

- Status: `PLANNED_DISABLED`
- Mode id: `<mode_id>`
- Slice id: `tbd`
- Descriptor: `data/definitions/modes/<mode_id>/metadata.json`
- Placeholder: `data/definitions/modes/<mode_id>/placeholder.json`
- Entry action: `mode_disabled:<mode_id>`
- Route: none
```

## Required Sections

- Current scope.
- Freeze for this scaffold.
- Future gate.
- Ownership and data strategy.
- Validation plan.

## Required Freeze

The first scaffold must not add:

- gameplay;
- tuning;
- rewards;
- backend mutations;
- schema changes;
- public CTA changes.
