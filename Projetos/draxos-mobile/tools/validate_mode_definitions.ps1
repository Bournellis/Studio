param(
  [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

$ProjectPath = (Resolve-Path -LiteralPath $ProjectDir).Path

function Invoke-Checked {
  param(
    [string]$Name,
    [scriptblock]$ScriptBlock
  )
  Write-Host "[RUN] $Name" -ForegroundColor Cyan
  Push-Location -LiteralPath $ProjectPath
  try {
    & $ScriptBlock
    if ($LASTEXITCODE -ne 0) {
      throw "$Name exited with code $LASTEXITCODE."
    }
    Write-Host "[PASS] $Name" -ForegroundColor Green
  } finally {
    Pop-Location
  }
}

Write-Host "DraxosMobile mode definitions validation"
Write-Host "Project: $ProjectPath"

Invoke-Checked "mode definitions typecheck" {
  & npx -y deno check `
    tools/mode_definitions/schema.ts `
    tools/mode_definitions/scaffold.ts `
    tools/mode_definitions/scaffold_mode.ts `
    tools/mode_definitions/validate.ts
}

Invoke-Checked "mode definitions strict schema tests" {
  & npx -y deno test --allow-read `
    server/tests/mode_definitions_schema_test.ts `
    server/tests/mode_descriptors_contract_test.ts `
    server/tests/modes_registry_contract_test.ts
}

Write-Host "DraxosMobile mode definitions validation OK." -ForegroundColor Green
