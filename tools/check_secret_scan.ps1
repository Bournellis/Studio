param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [string[]]$Path = @(),
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

$repoOutput = (& git -C $Root rev-parse --show-toplevel 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoOutput)) { throw "Root is not a Git worktree." }
$repoRoot = [System.IO.Path]::GetFullPath($repoOutput).TrimEnd('\', '/')
$repoPrefix = $repoRoot + [System.IO.Path]::DirectorySeparatorChar

$textExtensions = @(
    '.md', '.txt', '.gd', '.tscn', '.tres', '.cfg', '.ini', '.json', '.csv', '.tsv',
    '.ps1', '.psm1', '.py', '.js', '.mjs', '.ts', '.tsx', '.html', '.css', '.xml',
    '.yaml', '.yml', '.toml', '.plist', '.properties', '.gradle', '.env'
)
$bannedFiles = @(
    @{ Name = 'private_key_file'; Pattern = [regex]::new('\.(pem|key|keystore|jks|p12|pfx)$', 'IgnoreCase,Compiled') },
    @{ Name = 'environment_file'; Pattern = [regex]::new('(^|/)\.env($|\.)', 'IgnoreCase,Compiled') },
    @{ Name = 'google_services'; Pattern = [regex]::new('(^|/)google-services\.json$', 'IgnoreCase,Compiled') },
    @{ Name = 'google_service_info'; Pattern = [regex]::new('(^|/)GoogleService-Info\.plist$', 'IgnoreCase,Compiled') }
)
$patterns = @(
    @{ Name = 'private_key'; Pattern = [regex]::new('-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----', 'Compiled') },
    @{ Name = 'openai_key'; Pattern = [regex]::new('\bsk-(?:proj-)?[A-Za-z0-9_-]{20,}\b', 'Compiled') },
    @{ Name = 'github_token'; Pattern = [regex]::new('\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})\b', 'Compiled') },
    @{ Name = 'aws_access_key'; Pattern = [regex]::new('\b(?:AKIA|ASIA)[A-Z0-9]{16}\b', 'Compiled') },
    @{ Name = 'google_api_key'; Pattern = [regex]::new('\bAIza[0-9A-Za-z_-]{30,}\b', 'Compiled') },
    @{ Name = 'supabase_secret'; Pattern = [regex]::new('\bsb_secret_[A-Za-z0-9_-]{20,}\b', 'Compiled') },
    @{ Name = 'credential_assignment'; Pattern = [regex]::new('\b(password|passphrase|client_secret|api_key|access_token|service_role_key)\b\s*[:=]\s*[''"][^''"]{12,}[''"]', 'IgnoreCase,Compiled') }
)
$placeholderPattern = [regex]::new('(placeholder|replace[_ -]?me|redacted|example|sample|dummy|fixture|smoke|foundation[-_ ]?loop|test(?:er)?|fake|not[_ -]?set|<[^>]+>|\$\{|x{8,}|0{12,})', 'IgnoreCase,Compiled')
$placeholderFilePattern = [regex]::new('(template|sample|example|sanitized)', 'IgnoreCase,Compiled')
$newlinePattern = [regex]::new("`n", 'Compiled')

function Get-LiteralRelativePath([string]$Candidate) {
    if ([string]::IsNullOrWhiteSpace($Candidate) -or $Candidate -match '[\x00-\x1f:]') { throw "Path must be a non-empty literal relative path." }
    if ([System.IO.Path]::IsPathRooted($Candidate) -or $Candidate.StartsWith('\\')) { throw "Absolute paths are not accepted." }
    $relative = ($Candidate -replace '\\', '/')
    while ($relative.StartsWith('./')) { $relative = $relative.Substring(2) }
    $parts = @($relative -split '/')
    if ($relative -match '[*?\[\]{}]' -or $parts -contains '..' -or $parts -contains '.git') { throw "Glob, traversal and .git paths are not accepted." }
    return $relative
}

function Test-Placeholder([string]$Line) {
    return $placeholderPattern.IsMatch($Line)
}

function Get-Fingerprint([string]$Value) {
    $algorithm = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
        $hash = $algorithm.ComputeHash($bytes)
        return ([System.BitConverter]::ToString($hash).Replace('-', '').ToLowerInvariant()).Substring(0, 12)
    }
    finally { $algorithm.Dispose() }
}

$relativeFiles = New-Object System.Collections.Generic.List[string]
if ($Path.Count -gt 0) {
    foreach ($candidate in $Path) { $relativeFiles.Add((Get-LiteralRelativePath $candidate)) | Out-Null }
}
else {
    $listed = (& git -C $repoRoot -c core.quotepath=false ls-files --cached --others --exclude-standard 2>&1 | Out-String)
    if ($LASTEXITCODE -ne 0) { throw "Unable to enumerate repository files." }
    foreach ($line in ($listed -split "`r?`n")) {
        if (-not [string]::IsNullOrWhiteSpace($line)) { $relativeFiles.Add($line.Trim()) | Out-Null }
    }
}

$findings = New-Object System.Collections.Generic.List[object]
$filesScanned = 0
$utf8 = [System.Text.UTF8Encoding]::new($false, $true)
foreach ($relative in @($relativeFiles | Sort-Object -Unique)) {
    if ($Path.Count -eq 0) { $relative = Get-LiteralRelativePath $relative }
    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot ($relative -replace '/', '\')))
    if (-not $fullPath.StartsWith($repoPrefix, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Path escapes the repository." }
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) { throw "Missing scan target: $relative" }
    $item = Get-Item -LiteralPath $fullPath -Force
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Reparse points are not accepted: $relative" }

    foreach ($rule in $bannedFiles) {
        if ($rule.Pattern.IsMatch($relative) -and -not $placeholderFilePattern.IsMatch($relative)) {
            $findings.Add([pscustomobject]@{ Path = $relative; Line = 0; Rule = $rule.Name; Fingerprint = 'n/a' }) | Out-Null
        }
    }

    if ($item.Length -gt 2097152 -or $textExtensions -notcontains $item.Extension.ToLowerInvariant()) { continue }
    $bytes = [System.IO.File]::ReadAllBytes($fullPath)
    if ([Array]::IndexOf($bytes, [byte]0) -ge 0) { continue }
    try { $text = $utf8.GetString($bytes) }
    catch [System.Text.DecoderFallbackException] {
        Write-Host "SECRET_SCAN_SKIP reason=invalid_utf8 path=$relative"
        continue
    }
    $filesScanned++
    foreach ($rule in $patterns) {
        foreach ($match in $rule.Pattern.Matches($text)) {
            $lineStart = $text.LastIndexOf("`n", $match.Index)
            if ($lineStart -lt 0) { $lineStart = 0 } else { $lineStart++ }
            $lineEnd = $text.IndexOf("`n", $match.Index)
            if ($lineEnd -lt 0) { $lineEnd = $text.Length }
            $line = $text.Substring($lineStart, $lineEnd - $lineStart)
            if (Test-Placeholder $line) { continue }
            $lineNumber = 1 + $newlinePattern.Matches($text.Substring(0, $match.Index)).Count
            $findings.Add([pscustomobject]@{
                Path = $relative
                Line = $lineNumber
                Rule = $rule.Name
                Fingerprint = Get-Fingerprint $match.Value
            }) | Out-Null
        }
    }
}

if ($findings.Count -gt 0) {
    Write-Host "SECRET_SCAN_FAIL findings=$($findings.Count) files_scanned=$filesScanned mode=read-only"
    foreach ($finding in $findings) {
        Write-Host "SECRET_FINDING path=$($finding.Path) line=$($finding.Line) rule=$($finding.Rule) fingerprint=$($finding.Fingerprint)"
    }
    Write-Host "Secret values are redacted; no files were modified."
    exit 1
}

Write-Host "SECRET_SCAN_PASS findings=0 files_scanned=$filesScanned mode=read-only"
Write-Host "No files were modified."
exit 0
