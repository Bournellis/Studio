param(
    [ValidateSet("Local", "Remote", "Both")]
    [string]$Target = "Both",
    [string]$ProjectDir = ".",
    [ValidateSet("before", "after", "snapshot")]
    [string]$Label = "snapshot",
    [int]$Samples = 3,
    [int]$TimeoutSeconds = 20,
    [string]$SupabaseUrl = "",
    [string]$PublishableKey = "",
    [string]$AccessToken = "",
    [string]$RemoteWebUrl = "https://draxos-mobile-internal-alpha.pages.dev/web/index.html",
    [string]$RemotePortalUrl = "https://draxos-mobile-internal-alpha.pages.dev/",
    [string]$DiagnosticsDir = "",
    [string]$CompareWith = ""
)

$ErrorActionPreference = "Stop"

$ProjectPath = (Resolve-Path -LiteralPath $ProjectDir).Path
if ($Samples -lt 1) {
    throw "-Samples must be at least 1."
}
if ($TimeoutSeconds -lt 1) {
    throw "-TimeoutSeconds must be at least 1."
}

if ([string]::IsNullOrWhiteSpace($DiagnosticsDir)) {
    $stamp = (Get-Date).ToUniversalTime().ToString("yyyyMMdd-HHmmss")
    $DiagnosticsDir = Join-Path $ProjectPath "build\diagnostics\latency-baseline-$Label-$stamp"
}
New-Item -ItemType Directory -Force -Path $DiagnosticsDir | Out-Null
$DiagnosticsPath = (Resolve-Path -LiteralPath $DiagnosticsDir).Path

function Import-LocalEnv {
    param([string]$Path)
    $result = @{}
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $result
    }
    foreach ($rawLine in Get-Content -LiteralPath $Path) {
        $line = $rawLine.Trim()
        if ($line.Length -eq 0 -or $line.StartsWith("#") -or -not $line.Contains("=")) {
            continue
        }
        $key = $line.Substring(0, $line.IndexOf("=")).Trim()
        $value = $line.Substring($line.IndexOf("=") + 1).Trim()
        if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
            $value = $value.Substring(1, $value.Length - 2)
        }
        if ($key.Length -gt 0) {
            $result[$key] = $value
        }
    }
    return $result
}

function First-NonEmpty {
    param([object[]]$Values)
    foreach ($value in $Values) {
        if ($null -ne $value) {
            $text = [string]$value
            if ($text.Trim().Length -gt 0) {
                return $text.Trim()
            }
        }
    }
    return ""
}

$LocalEnv = Import-LocalEnv -Path (Join-Path $ProjectPath ".env.internal-alpha.local")
$DefaultLocalUrl = "http://127.0.0.1:54321"
$DefaultLocalKey = "sb_publishable_TLjdd9X4MlzD740dtVCXNg_YTl9IMAi"
$RemoteSupabaseUrl = First-NonEmpty @(
    $SupabaseUrl,
    $env:SUPABASE_URL,
    $env:DRAXOS_MOBILE_SUPABASE_URL,
    $LocalEnv["SUPABASE_URL"],
    $LocalEnv["DRAXOS_MOBILE_SUPABASE_URL"],
    "https://armxgipvnbbshzqawklw.supabase.co"
)
$RemotePublishableKey = First-NonEmpty @(
    $PublishableKey,
    $env:SUPABASE_PUBLISHABLE_KEY,
    $env:DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY,
    $LocalEnv["SUPABASE_PUBLISHABLE_KEY"],
    $LocalEnv["DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY"]
)
$TelemetryAccessToken = First-NonEmpty @(
    $AccessToken,
    $env:DRAXOS_LATENCY_ACCESS_TOKEN,
    $env:DRAXOS_OPS_ACCESS_TOKEN,
    $env:DRAXOS_MOBILE_OPS_ACCESS_TOKEN,
    $env:DRAXOS_MOBILE_SUPABASE_ACCESS_TOKEN,
    $LocalEnv["DRAXOS_LATENCY_ACCESS_TOKEN"],
    $LocalEnv["DRAXOS_OPS_ACCESS_TOKEN"],
    $LocalEnv["DRAXOS_MOBILE_OPS_ACCESS_TOKEN"],
    $LocalEnv["DRAXOS_MOBILE_SUPABASE_ACCESS_TOKEN"]
)

function Endpoint-Definitions {
    return @(
        @{ Surface = "release"; Endpoint = "healthcheck"; Method = "GET"; Path = "/functions/v1/healthcheck"; Auth = $false },
        @{ Surface = "release"; Endpoint = "release/manifest"; Method = "GET"; Path = "/functions/v1/release/manifest"; Auth = $false },
        @{ Surface = "release"; Endpoint = "release/config"; Method = "GET"; Path = "/functions/v1/release/config"; Auth = $false },
        @{ Surface = "account"; Endpoint = "account/state"; Method = "GET"; Path = "/functions/v1/account/state"; Auth = $true },
        @{ Surface = "base"; Endpoint = "base/state"; Method = "GET"; Path = "/functions/v1/base/state"; Auth = $true },
        @{ Surface = "arena"; Endpoint = "arena/pve/state"; Method = "GET"; Path = "/functions/v1/arena/pve/state"; Auth = $true },
        @{ Surface = "battle"; Endpoint = "battle/latest"; Method = "GET"; Path = "/functions/v1/battle/latest"; Auth = $true },
        @{ Surface = "battle"; Endpoint = "battle/history"; Method = "GET"; Path = "/functions/v1/battle/history?limit=5"; Auth = $true },
        @{ Surface = "build"; Endpoint = "build/state"; Method = "GET"; Path = "/functions/v1/build/state"; Auth = $true },
        @{ Surface = "crafting"; Endpoint = "crafting/state"; Method = "GET"; Path = "/functions/v1/crafting/state"; Auth = $true },
        @{ Surface = "competition"; Endpoint = "competition/ranking/current"; Method = "GET"; Path = "/functions/v1/competition/ranking/current"; Auth = $true },
        @{ Surface = "monetization"; Endpoint = "monetization/state"; Method = "GET"; Path = "/functions/v1/monetization/state"; Auth = $true },
        @{ Surface = "social"; Endpoint = "social/state"; Method = "GET"; Path = "/functions/v1/social/state"; Auth = $true },
        @{ Surface = "mode"; Endpoint = "modes/registry"; Method = "GET"; Path = "/functions/v1/modes/registry"; Auth = $true },
        @{ Surface = "mode"; Endpoint = "modes/state"; Method = "GET"; Path = "/functions/v1/modes/state?mode_id=openworld"; Auth = $true },
        @{ Surface = "release"; Endpoint = "release/download:android"; Method = "GET"; Path = "/functions/v1/release/download?artifact=android"; Auth = $true },
        @{ Surface = "release"; Endpoint = "release/download:pc_windows"; Method = "GET"; Path = "/functions/v1/release/download?artifact=pc_windows"; Auth = $true }
    )
}

function Web-Definitions {
    param([string]$PortalUrl, [string]$WebUrl)
    return @(
        @{ Surface = "portal"; Endpoint = "portal"; Method = "GET"; Url = $PortalUrl; Auth = $false },
        @{ Surface = "web"; Endpoint = "web/index.html"; Method = "GET"; Url = $WebUrl; Auth = $false }
    )
}

function Headers-For {
    param(
        [string]$Key,
        [bool]$RequiresAuth,
        [string]$Token
    )
    $headers = @{
        "Accept" = "application/json"
        "apikey" = $Key
        "x-draxos-api-version" = "1"
        "x-draxos-save-type" = "normal"
    }
    if ($RequiresAuth -and $Token.Trim().Length -gt 0) {
        $headers["Authorization"] = "Bearer $Token"
    }
    return $headers
}

function Invoke-LatencyRequest {
    param(
        [hashtable]$Definition,
        [string]$TargetName,
        [string]$BaseUrl,
        [string]$Key,
        [string]$Token,
        [int]$SampleIndex
    )
    $requiresAuth = [bool]$Definition.Auth
    $url = if ($Definition.ContainsKey("Url")) {
        [string]$Definition.Url
    } else {
        "$($BaseUrl.TrimEnd('/'))$($Definition.Path)"
    }
    if ($requiresAuth -and $Token.Trim().Length -eq 0) {
        return [ordered]@{
            target = $TargetName
            surface = [string]$Definition.Surface
            endpoint = [string]$Definition.Endpoint
            method = [string]$Definition.Method
            sample = $SampleIndex
            skipped = $true
            skip_reason = "access_token_missing"
            duration_ms = 0
            response_code = 0
            ok = $false
            fail = $true
            used_cache = $false
            rendered_from_cache = $false
            server_timing = $null
        }
    }
    if (-not $Definition.ContainsKey("Url") -and $Key.Trim().Length -eq 0) {
        return [ordered]@{
            target = $TargetName
            surface = [string]$Definition.Surface
            endpoint = [string]$Definition.Endpoint
            method = [string]$Definition.Method
            sample = $SampleIndex
            skipped = $true
            skip_reason = "publishable_key_missing"
            duration_ms = 0
            response_code = 0
            ok = $false
            fail = $true
            used_cache = $false
            rendered_from_cache = $false
            server_timing = $null
        }
    }

    $headers = @{}
    if (-not $Definition.ContainsKey("Url")) {
        $headers = Headers-For -Key $Key -RequiresAuth $requiresAuth -Token $Token
    }
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $statusCode = 0
    $bodyText = ""
    $serverTiming = $null
    $ok = $false
    $errorText = ""
    try {
        $response = Invoke-WebRequest -Uri $url -Method ([string]$Definition.Method) -Headers $headers -TimeoutSec $TimeoutSeconds -UseBasicParsing
        $stopwatch.Stop()
        $statusCode = [int]$response.StatusCode
        $bodyText = [string]$response.Content
        if ($null -ne $response.Headers["Server-Timing"]) {
            $serverTiming = [string]$response.Headers["Server-Timing"]
        }
        $ok = $statusCode -ge 200 -and $statusCode -lt 300
    } catch {
        $stopwatch.Stop()
        $errorText = $_.Exception.Message
        if ($_.Exception.Response -ne $null) {
            $statusCode = [int]$_.Exception.Response.StatusCode
            try {
                $stream = $_.Exception.Response.GetResponseStream()
                if ($stream -ne $null) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $bodyText = $reader.ReadToEnd()
                    $reader.Dispose()
                }
            } catch {
                $bodyText = ""
            }
        }
    }

    $bodyOk = $null
    $bodyServerTiming = $null
    if ($bodyText.Trim().StartsWith("{")) {
        try {
            $json = $bodyText | ConvertFrom-Json
            if ($json.PSObject.Properties.Name -contains "ok") {
                $bodyOk = [bool]$json.ok
            }
            if ($json.PSObject.Properties.Name -contains "server_timing") {
                $bodyServerTiming = $json.server_timing
            }
        } catch {
            $bodyOk = $null
        }
    }
    if ($null -ne $bodyOk) {
        $ok = $ok -and $bodyOk
    }
    if ($null -ne $bodyServerTiming) {
        $serverTiming = $bodyServerTiming
    }

    return [ordered]@{
        target = $TargetName
        surface = [string]$Definition.Surface
        endpoint = [string]$Definition.Endpoint
        method = [string]$Definition.Method
        sample = $SampleIndex
        skipped = $false
        skip_reason = ""
        duration_ms = [math]::Round($stopwatch.Elapsed.TotalMilliseconds, 2)
        response_code = $statusCode
        ok = [bool]$ok
        fail = -not [bool]$ok
        used_cache = $false
        rendered_from_cache = $false
        server_timing = $serverTiming
        error = $errorText
    }
}

function Summarize-Rows {
    param([object[]]$Rows)
    $summary = @()
    $groups = $Rows | Group-Object -Property {
        "{0}|{1}|{2}|{3}" -f $_["target"], $_["surface"], $_["endpoint"], $_["method"]
    }
    foreach ($group in $groups) {
        $items = @($group.Group)
        $first = $items[0]
        $measured = @($items | Where-Object { -not $_.skipped })
        $durations = @($measured | ForEach-Object { [double]$_.duration_ms } | Sort-Object)
        $avg = 0
        $p95 = 0
        $min = 0
        $max = 0
        if ($durations.Count -gt 0) {
            $avg = [math]::Round((($durations | Measure-Object -Average).Average), 2)
            $min = [math]::Round([double]$durations[0], 2)
            $max = [math]::Round([double]$durations[$durations.Count - 1], 2)
            $p95Index = [math]::Ceiling($durations.Count * 0.95) - 1
            if ($p95Index -lt 0) { $p95Index = 0 }
            if ($p95Index -ge $durations.Count) { $p95Index = $durations.Count - 1 }
            $p95 = [math]::Round([double]$durations[$p95Index], 2)
        }
        $summary += [ordered]@{
            target = $first.target
            surface = $first.surface
            endpoint = $first.endpoint
            method = $first.method
            samples = $items.Count
            measured = $measured.Count
            skipped = @($items | Where-Object { $_.skipped }).Count
            ok = @($measured | Where-Object { $_.ok }).Count
            fail = @($measured | Where-Object { $_.fail }).Count
            min_ms = $min
            avg_ms = $avg
            p95_ms = $p95
            max_ms = $max
            response_codes = (($measured | ForEach-Object { [string]$_.response_code } | Sort-Object -Unique) -join ",")
            skip_reasons = (($items | Where-Object { $_.skipped } | ForEach-Object { [string]$_.skip_reason } | Sort-Object -Unique) -join ",")
        }
    }
    return $summary
}

function Comparison-Rows {
    param(
        [object[]]$CurrentSummary,
        [string]$PreviousPath
    )
    if ($PreviousPath.Trim().Length -eq 0) {
        return @()
    }
    if (-not (Test-Path -LiteralPath $PreviousPath -PathType Leaf)) {
        throw "-CompareWith file not found: $PreviousPath"
    }
    $previous = Get-Content -LiteralPath $PreviousPath -Raw | ConvertFrom-Json
    $previousSummary = @($previous.summary)
    $comparison = @()
    foreach ($current in $CurrentSummary) {
        $match = $previousSummary | Where-Object {
            $_.target -eq $current.target -and
            $_.surface -eq $current.surface -and
            $_.endpoint -eq $current.endpoint -and
            $_.method -eq $current.method
        } | Select-Object -First 1
        if ($null -eq $match) {
            continue
        }
        $comparison += [ordered]@{
            target = $current.target
            surface = $current.surface
            endpoint = $current.endpoint
            method = $current.method
            before_avg_ms = [double]$match.avg_ms
            after_avg_ms = [double]$current.avg_ms
            delta_avg_ms = [math]::Round(([double]$current.avg_ms - [double]$match.avg_ms), 2)
            before_p95_ms = [double]$match.p95_ms
            after_p95_ms = [double]$current.p95_ms
            delta_p95_ms = [math]::Round(([double]$current.p95_ms - [double]$match.p95_ms), 2)
        }
    }
    return $comparison
}

function Write-MarkdownReport {
    param(
        [string]$Path,
        [hashtable]$Metadata,
        [object[]]$Summary,
        [object[]]$Comparison,
        [object[]]$Blockers
    )
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# DraxosMobile Latency Baseline") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("- generated_at: ``$($Metadata.generated_at)``") | Out-Null
    $lines.Add("- label: ``$($Metadata.label)``") | Out-Null
    $lines.Add("- target: ``$($Metadata.target)``") | Out-Null
    $lines.Add("- samples: ``$($Metadata.samples)``") | Out-Null
    $lines.Add("- remote_web_url: ``$($Metadata.remote_web_url)``") | Out-Null
    $lines.Add("- remote_portal_url: ``$($Metadata.remote_portal_url)``") | Out-Null
    $lines.Add("") | Out-Null
    if ($Blockers.Count -gt 0) {
        $lines.Add("## Blockers") | Out-Null
        foreach ($blocker in $Blockers) {
            $lines.Add("- $blocker") | Out-Null
        }
        $lines.Add("") | Out-Null
    }
    $lines.Add("## Summary") | Out-Null
    $lines.Add("| target | surface | endpoint | method | measured | ok | fail | avg_ms | p95_ms | response_codes | notes |") | Out-Null
    $lines.Add("|---|---|---|---|---:|---:|---:|---:|---:|---|---|") | Out-Null
    foreach ($row in $Summary) {
        $notes = if ([string]$row.skip_reasons -ne "") { [string]$row.skip_reasons } else { "" }
        $lines.Add(("| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} | {8} | {9} | {10} |" -f `
            $row.target, $row.surface, $row.endpoint, $row.method, $row.measured, $row.ok, $row.fail, $row.avg_ms, $row.p95_ms, $row.response_codes, $notes)) | Out-Null
    }
    if ($Comparison.Count -gt 0) {
        $lines.Add("") | Out-Null
        $lines.Add("## Comparison") | Out-Null
        $lines.Add("| target | surface | endpoint | method | before_avg_ms | after_avg_ms | delta_avg_ms | before_p95_ms | after_p95_ms | delta_p95_ms |") | Out-Null
        $lines.Add("|---|---|---|---|---:|---:|---:|---:|---:|---:|") | Out-Null
        foreach ($row in $Comparison) {
            $lines.Add(("| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} | {8} | {9} |" -f `
                $row.target, $row.surface, $row.endpoint, $row.method, $row.before_avg_ms, $row.after_avg_ms, $row.delta_avg_ms, $row.before_p95_ms, $row.after_p95_ms, $row.delta_p95_ms)) | Out-Null
        }
    }
    Set-Content -LiteralPath $Path -Value $lines -Encoding UTF8
}

$Rows = @()
$Blockers = New-Object System.Collections.Generic.List[string]
$RunLocal = $Target -eq "Local" -or $Target -eq "Both"
$RunRemote = $Target -eq "Remote" -or $Target -eq "Both"

if ($RunLocal) {
    foreach ($definition in (Endpoint-Definitions)) {
        foreach ($sample in 1..$Samples) {
            $Rows += Invoke-LatencyRequest -Definition $definition -TargetName "local" -BaseUrl $DefaultLocalUrl -Key $DefaultLocalKey -Token $TelemetryAccessToken -SampleIndex $sample
        }
    }
}

if ($RunRemote) {
    if ($RemotePublishableKey.Trim().Length -eq 0) {
        $Blockers.Add("remote_supabase_publishable_key_missing: set SUPABASE_PUBLISHABLE_KEY or DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY for remote Supabase endpoint baseline") | Out-Null
    }
    foreach ($definition in (Endpoint-Definitions)) {
        foreach ($sample in 1..$Samples) {
            $Rows += Invoke-LatencyRequest -Definition $definition -TargetName "remote" -BaseUrl $RemoteSupabaseUrl -Key $RemotePublishableKey -Token $TelemetryAccessToken -SampleIndex $sample
        }
    }
    foreach ($definition in (Web-Definitions -PortalUrl $RemotePortalUrl -WebUrl $RemoteWebUrl)) {
        foreach ($sample in 1..$Samples) {
            $Rows += Invoke-LatencyRequest -Definition $definition -TargetName "remote-web" -BaseUrl "" -Key "" -Token "" -SampleIndex $sample
        }
    }
}

if ($TelemetryAccessToken.Trim().Length -eq 0) {
    $Blockers.Add("approved_account_access_token_missing: authenticated surface endpoints were skipped; provide DRAXOS_LATENCY_ACCESS_TOKEN, DRAXOS_OPS_ACCESS_TOKEN or DRAXOS_MOBILE_OPS_ACCESS_TOKEN from an already-approved account") | Out-Null
}

$Summary = @(Summarize-Rows -Rows $Rows)
$Comparison = @(Comparison-Rows -CurrentSummary $Summary -PreviousPath $CompareWith)
$GeneratedAt = (Get-Date).ToUniversalTime().ToString("o")
$Metadata = @{
    schema_version = "latency_baseline_v1"
    generated_at = $GeneratedAt
    label = $Label
    target = $Target
    samples = $Samples
    project_dir = $ProjectPath
    remote_supabase_url_configured = $RemoteSupabaseUrl.Trim().Length -gt 0
    remote_publishable_key_configured = $RemotePublishableKey.Trim().Length -gt 0
    access_token_configured = $TelemetryAccessToken.Trim().Length -gt 0
    remote_web_url = $RemoteWebUrl
    remote_portal_url = $RemotePortalUrl
}
$Report = [ordered]@{
    schema_version = "latency_baseline_v1"
    generated_at = $GeneratedAt
    metadata = $Metadata
    rows = $Rows
    summary = $Summary
    comparison = $Comparison
    blockers = @($Blockers.ToArray())
}

$JsonPath = Join-Path $DiagnosticsPath "latency-baseline-$Label.json"
$MarkdownPath = Join-Path $DiagnosticsPath "latency-baseline-$Label.md"
$Report | ConvertTo-Json -Depth 24 | Set-Content -LiteralPath $JsonPath -Encoding UTF8
Write-MarkdownReport -Path $MarkdownPath -Metadata $Metadata -Summary $Summary -Comparison $Comparison -Blockers @($Blockers.ToArray())

Write-Host "Latency baseline written:"
Write-Host "JSON: $JsonPath"
Write-Host "Markdown: $MarkdownPath"
if ($Blockers.Count -gt 0) {
    Write-Host "Blockers:"
    foreach ($blocker in $Blockers) {
        Write-Host "- $blocker"
    }
}
