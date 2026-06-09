param(
    [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$EnvFile = "",
    [string]$BucketName = "draxos-internal-alpha",
    [string]$PrivateDownloadBucketName = "draxos-internal-alpha-private",
    [string]$ReleaseRoot = "",
    [string]$StaticSiteBaseUrl = "https://draxos-mobile-internal-alpha.pages.dev",
    [ValidateSet("Plan", "Package", "Upload", "DeployManifest", "FullPublish")]
    [string]$Mode = "Plan",
    [switch]$ConfirmRemoteMutation,
    [switch]$UseManifestSecret,
    [switch]$SkipUpload,
    [switch]$SkipManifestSecret,
    [switch]$PublicDownloads
)

$ErrorActionPreference = "Stop"

$ModeProvided = $PSBoundParameters.ContainsKey("Mode")
$LegacyFlagUsed = $SkipUpload.IsPresent -or $UseManifestSecret.IsPresent -or $SkipManifestSecret.IsPresent
$IsRemoteMutation = $Mode -in @("Upload", "DeployManifest", "FullPublish")
$ShouldPackage = $Mode -in @("Package", "Upload", "DeployManifest", "FullPublish")
$ShouldUpload = $Mode -in @("Upload", "FullPublish")
$ShouldDeployManifest = $Mode -in @("DeployManifest", "FullPublish")
$ShouldSetManifestSecret = ($ShouldDeployManifest -or $UseManifestSecret.IsPresent) -and -not $SkipManifestSecret.IsPresent

if (-not $ModeProvided -and $LegacyFlagUsed) {
    Write-Warning "Legacy publish flags were supplied without -Mode. Track 13 protects the old mutating flow: running Mode Plan only."
}

if ($IsRemoteMutation -and -not $ConfirmRemoteMutation) {
    throw "Mode $Mode mutates remote release state. Re-run with -ConfirmRemoteMutation after reviewing the generated release plan."
}
if ($ShouldDeployManifest -and $SkipManifestSecret.IsPresent) {
    throw "-SkipManifestSecret is disabled for DeployManifest/FullPublish. Normal release deploys must update the manifest override secret."
}

function Read-DotEnv {
    param([string]$Path)
    $values = @{}
    if (-not (Test-Path -LiteralPath $Path)) {
        return $values
    }
    foreach ($rawLine in Get-Content -LiteralPath $Path) {
        $line = $rawLine.Trim()
        if ($line.Length -eq 0 -or $line.StartsWith("#") -or -not $line.Contains("=")) {
            continue
        }
        $parts = $line.Split("=", 2)
        $key = $parts[0].Trim()
        $value = $parts[1].Trim().Trim('"').Trim("'")
        if ($key.Length -gt 0) {
            $values[$key] = $value
        }
    }
    return $values
}

function Env-Value {
    param(
        [hashtable]$Values,
        [string[]]$Keys,
        [string]$Fallback = ""
    )
    foreach ($key in $Keys) {
        $processValue = [Environment]::GetEnvironmentVariable($key, "Process")
        if ($processValue -and $processValue.Trim().Length -gt 0) {
            return $processValue.Trim()
        }
        if ($Values.ContainsKey($key) -and [string]$Values[$key] -ne "") {
            return ([string]$Values[$key]).Trim()
        }
    }
    return $Fallback
}

function Assert-Client-Key {
    param([string]$Key)
    $normalized = $Key.Trim().ToLowerInvariant()
    if ($normalized.Length -eq 0) {
        throw "SUPABASE_PUBLISHABLE_KEY or DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY is required for remote modes."
    }
    if ($normalized.StartsWith("sb_secret_") -or
        $normalized.StartsWith("sb_service_") -or
        $normalized.Contains("service_role") -or
        $normalized.Contains("secret")) {
        throw "Publication refuses admin or secret-like Supabase keys for client/manifest validation."
    }
}

function Assert-VersionedReleaseRoot {
    param([string]$Root, [string]$ModeLabel)
    $normalized = $Root.Trim().Trim("/")
    if ($normalized.Length -eq 0) {
        throw "ReleaseRoot is required for Mode $ModeLabel. Use a fresh versioned root like internal-alpha/v0-package-slug-YYYYMMDD-<shortsha>."
    }
    if ($normalized -notmatch '^internal-alpha/v[0-9]+-[a-z0-9][a-z0-9._-]*-[0-9]{8}-[0-9a-f]{7,}$') {
        throw "ReleaseRoot must be a versioned Internal Alpha root: internal-alpha/v0-name-YYYYMMDD-<shortsha>. Got: $Root"
    }
    return $normalized
}

function Assert-NoSecretLikeText {
    param([string]$Text, [string]$Label)
    $patterns = @(
        "service_role",
        "sb_secret_",
        "sb_service_",
        "SUPABASE_SERVICE_ROLE_KEY",
        "DATABASE_PASSWORD",
        "DB_PASSWORD",
        "KEYSTORE_PASSWORD",
        "DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PASSWORD"
    )
    foreach ($pattern in $patterns) {
        if ($Text.IndexOf($pattern, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            throw "$Label contains forbidden secret-like text: $pattern"
        }
    }
}

function Assert-UnderDirectory {
    param([string]$Path, [string]$Root, [string]$Label)
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $fullRoot = [System.IO.Path]::GetFullPath($Root)
    if (-not $fullRoot.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $fullRoot = $fullRoot + [System.IO.Path]::DirectorySeparatorChar
    }
    if (-not $fullPath.StartsWith($fullRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Label must stay under $fullRoot, got $fullPath"
    }
}

function Invoke-Supabase {
    param([string[]]$Arguments)
    $package = if ($script:SupabaseCliPackage) { $script:SupabaseCliPackage } else { "supabase" }
    & npx -y $package @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Supabase CLI failed with exit code $LASTEXITCODE`: supabase $($Arguments -join ' ')"
    }
}

function Invoke-SupabaseOptional {
    param([string[]]$Arguments)
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $package = if ($script:SupabaseCliPackage) { $script:SupabaseCliPackage } else { "supabase" }
        & npx -y $package @Arguments *> $null
        return $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
}

function Content-TypeFor {
    param([string]$Path)
    $extension = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
    switch ($extension) {
        ".html" { return "text/html; charset=utf-8" }
        ".js" { return "application/javascript; charset=utf-8" }
        ".json" { return "application/json; charset=utf-8" }
        ".wasm" { return "application/wasm" }
        ".pck" { return "application/octet-stream" }
        ".apk" { return "application/vnd.android.package-archive" }
        ".zip" { return "application/zip" }
        ".png" { return "image/png" }
        ".jpg" { return "image/jpeg" }
        ".jpeg" { return "image/jpeg" }
        ".webp" { return "image/webp" }
        ".svg" { return "image/svg+xml" }
        ".css" { return "text/css; charset=utf-8" }
        ".txt" { return "text/plain; charset=utf-8" }
        default { return "application/octet-stream" }
    }
}

function Copy-DirectoryFiles {
    param(
        [string]$SourceDir,
        [string]$DestinationDir,
        [string[]]$ExcludeExtensions = @()
    )
    if (-not (Test-Path -LiteralPath $SourceDir -PathType Container)) {
        throw "Required directory is missing: $SourceDir"
    }
    New-Item -ItemType Directory -Force -Path $DestinationDir | Out-Null
    foreach ($file in Get-ChildItem -LiteralPath $SourceDir -File) {
        if ($ExcludeExtensions -contains $file.Extension.ToLowerInvariant()) {
            continue
        }
        Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $DestinationDir $file.Name) -Force
    }
}

function Artifact-Record {
    param(
        [string]$Path,
        [string]$Label,
        [string]$Url,
        [long]$ExpectedMinimumBytes = 0
    )
    $record = [ordered]@{
        label = $Label
        path = [System.IO.Path]::GetFullPath($Path)
        url = $Url
        exists = $false
        bytes = 0
        sha256 = ""
        expected_minimum_bytes = $ExpectedMinimumBytes
    }
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $item = Get-Item -LiteralPath $Path
        $record.exists = $true
        $record.bytes = $item.Length
        $record.sha256 = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    return $record
}

function Require-Artifact {
    param([hashtable]$Record)
    if (-not [bool]$Record.exists) {
        throw "Required artifact is missing: $($Record.path)"
    }
    if ([long]$Record.expected_minimum_bytes -gt 0 -and [long]$Record.bytes -lt [long]$Record.expected_minimum_bytes) {
        throw "$($Record.label) is smaller than expected: $($Record.bytes) bytes."
    }
}

function Build-Manifest {
    param(
        [hashtable]$AndroidRecord,
        [hashtable]$PcRecord,
        [hashtable]$WebRecord,
        [string]$PortalUrl,
        [string]$WebUrl
    )
    return [ordered]@{
        schema_version = "internal_alpha_manifest_v1"
        channel = "internal_alpha"
        latest_version = "0.0.15-alpha.0"
        latest_version_code = 15
        minimum_supported_version = "0.0.13-alpha.0"
        minimum_supported_version_code = 13
        released_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        requires_save_reset = $false
        portal_url = $PortalUrl
        notes = @(
            "Bosque Bootstrap Authority v1 publicado na URL principal de Internal Alpha.",
            "APK Android, PC ZIP e Web compartilham o mesmo backend remoto.",
            "Bosque integrado oculta o viewport jogavel ate receber bootstrap canonico remoto/cache, evitando flash full-spawn ao reentrar.",
            "Arena PVE agora exporta e exibe HP/Mana iniciais buffados no replay da proxima luta.",
            "Openworld/Bosque usa operations v2 com ACK obrigatorio e retry local.",
            "Nodes coletaveis mantem cooldown por item via node_state.next_spawn_at e rejeicoes terminais nao ficam presas na fila.",
            "Coleta ativa nao reinicia por movimento leve e ACKs nao fazem rollback visual da mesma sessao.",
            "Menu usa busy por escopo para nao congelar acoes independentes durante requisicoes pendentes.",
            "Fogueira Estavel I so libera receitas apos ACK de structures.fogueira_estavel_1.",
            $(if ($PublicDownloads) { "Portal/Web rodam no Cloudflare Pages; downloads e assets grandes continuam no Supabase Storage." } else { "Portal/Web rodam no Cloudflare Pages; downloads usam login alpha e URLs assinadas temporarias." }),
            "Progression Lab usa save separado e nao pontua ranking."
        )
        artifacts = [ordered]@{
            android = [ordered]@{
                label = "Android APK"
                url = $AndroidRecord.url
                sha256 = $AndroidRecord.sha256
                auth_required = (-not $PublicDownloads)
            }
            pc_windows = [ordered]@{
                label = "PC Windows ZIP"
                url = $PcRecord.url
                sha256 = $PcRecord.sha256
                auth_required = (-not $PublicDownloads)
            }
            web = [ordered]@{
                label = "Web"
                url = $WebUrl
            }
        }
        known_issues = @(
            "Layout Android paisagem ainda precisa de ergonomia real no aparelho.",
            "APK desta publicacao usa debug_fallback enquanto a keystore release dedicada nao estiver configurada.",
            "Web usa hospedagem hibrida Cloudflare Pages + Supabase Storage; validar / e /web/index.html apos cada deploy.",
            "Dominio estavel do Cloudflare Pages pode exigir Cloudflare Access; validacao publica anonima deve usar preview liberado ou sessao autenticada."
        )
    }
}

function Write-TextUtf8NoBom {
    param([string]$Path, [string]$Text)
    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
}

function Write-ReleasePlan {
    param(
        [hashtable]$Plan,
        [string]$JsonPath,
        [string]$MarkdownPath
    )
    $json = $Plan | ConvertTo-Json -Depth 12
    Assert-NoSecretLikeText -Text $json -Label "release plan JSON"
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $JsonPath) | Out-Null
    Write-TextUtf8NoBom -Path $JsonPath -Text $json

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# DraxosMobile Internal Alpha Release Plan") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add(("- Generated at: ``{0}``" -f $Plan.generated_at)) | Out-Null
    $lines.Add(("- Mode: ``{0}``" -f $Plan.mode)) | Out-Null
    $lines.Add(("- Remote mutation: ``{0}``" -f $Plan.remote_mutation)) | Out-Null
    $lines.Add(("- Ready for selected mode: ``{0}``" -f $Plan.ready_for_selected_mode)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("| Artifact | Exists | Bytes | SHA256 | URL |") | Out-Null
    $lines.Add("|---|---:|---:|---|---|") | Out-Null
    foreach ($artifact in $Plan.artifacts) {
        $lines.Add(("| {0} | {1} | {2} | ``{3}`` | {4} |" -f $artifact.label, $artifact.exists, $artifact.bytes, $artifact.sha256, $artifact.url)) | Out-Null
    }
    if ($Plan.blocking_issues.Count -gt 0) {
        $lines.Add("") | Out-Null
        $lines.Add("## Blocking Issues") | Out-Null
        foreach ($issue in $Plan.blocking_issues) {
            $lines.Add("- $issue") | Out-Null
        }
    }
    if ($Plan.warnings.Count -gt 0) {
        $lines.Add("") | Out-Null
        $lines.Add("## Warnings") | Out-Null
        foreach ($warning in $Plan.warnings) {
            $lines.Add("- $warning") | Out-Null
        }
    }
    $markdown = ($lines -join [Environment]::NewLine) + [Environment]::NewLine
    Assert-NoSecretLikeText -Text $markdown -Label "release plan markdown"
    Write-TextUtf8NoBom -Path $MarkdownPath -Text $markdown
}

function Assert-UrlOk {
    param(
        [string]$Url,
        [string]$Label,
        [string]$ExpectedText = ""
    )
    $response = Invoke-WebRequest -Method Get -Uri $Url -UseBasicParsing
    if ($response.StatusCode -lt 200 -or $response.StatusCode -ge 300) {
        throw "$Label returned HTTP $($response.StatusCode): $Url"
    }
    if ($ExpectedText -ne "" -and -not $response.Content.Contains($ExpectedText)) {
        throw "$Label does not contain expected text: $ExpectedText"
    }
}

function Assert-HeadOk {
    param(
        [string]$Url,
        [string]$Label,
        [long]$ExpectedMinimumBytes
    )
    $response = Invoke-WebRequest -Method Head -Uri $Url -UseBasicParsing
    if ($response.StatusCode -lt 200 -or $response.StatusCode -ge 300) {
        throw "$Label returned HTTP $($response.StatusCode): $Url"
    }
    $lengthHeader = $response.Headers["Content-Length"]
    if ($lengthHeader -and [long]$lengthHeader -lt $ExpectedMinimumBytes) {
        throw "$Label content length is smaller than expected."
    }
}

$ProjectDir = (Resolve-Path -LiteralPath $ProjectDir).Path
if ($EnvFile -eq "") {
    $EnvFile = Join-Path $ProjectDir ".env.internal-alpha.local"
}

if ($ShouldPackage -or $IsRemoteMutation) {
    $ReleaseRoot = Assert-VersionedReleaseRoot -Root $ReleaseRoot -ModeLabel $Mode
} else {
    $ReleaseRoot = $ReleaseRoot.Trim().Trim("/")
    if ($ReleaseRoot.Length -eq 0) {
        $ReleaseRoot = "internal-alpha/<release-root>"
    }
}

$envValues = Read-DotEnv -Path $EnvFile
$script:SupabaseCliPackage = Env-Value $envValues @("DRAXOS_MOBILE_SUPABASE_CLI_PACKAGE") "supabase@2.98.0"
$projectRef = Env-Value $envValues @("SUPABASE_PROJECT_REF")
$supabaseUrl = (Env-Value $envValues @("DRAXOS_MOBILE_SUPABASE_URL", "SUPABASE_URL")).TrimEnd("/")
$publishableKey = Env-Value $envValues @("DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY", "SUPABASE_PUBLISHABLE_KEY")

$warnings = New-Object System.Collections.Generic.List[string]
$blockingIssues = New-Object System.Collections.Generic.List[string]

if ($supabaseUrl.Trim().Length -eq 0 -and $projectRef.Trim().Length -gt 0) {
    $supabaseUrl = "https://$projectRef.supabase.co"
}
if ($supabaseUrl.Trim().Length -eq 0) {
    $supabaseUrl = "https://<project-ref>.supabase.co"
    $blockingIssues.Add("Supabase URL is missing; set SUPABASE_URL or DRAXOS_MOBILE_SUPABASE_URL before packaging or publishing.") | Out-Null
} elseif (-not $supabaseUrl.StartsWith("https://")) {
    $blockingIssues.Add("Supabase URL must be https for release planning: $supabaseUrl") | Out-Null
}
if ($IsRemoteMutation -and $projectRef.Trim().Length -eq 0) {
    $blockingIssues.Add("SUPABASE_PROJECT_REF is required for remote mutation modes.") | Out-Null
}
if ($IsRemoteMutation) {
    Assert-Client-Key -Key $publishableKey
} elseif ($publishableKey.Trim().Length -gt 0) {
    Assert-Client-Key -Key $publishableKey
}

$buildDir = Join-Path $ProjectDir "build"
$internalAlphaDir = Join-Path $buildDir "internal-alpha"
$androidApk = Join-Path $buildDir "android\draxos-mobile-alpha.apk"
$pcZip = Join-Path $buildDir "pc\draxos-mobile-alpha.zip"
$webDir = Join-Path $buildDir "web"
$webIndex = Join-Path $webDir "index.html"
$portalDir = Join-Path $ProjectDir "portal\internal-alpha"
$portalIndex = Join-Path $portalDir "index.html"
$publishDir = Join-Path $internalAlphaDir "publish"
$portalPublishDir = Join-Path $publishDir "portal"
$webPublishDir = Join-Path $publishDir "web"
$downloadsPublishDir = Join-Path $publishDir "downloads"
$planPath = Join-Path $internalAlphaDir "release-plan.json"
$planMarkdownPath = Join-Path $internalAlphaDir "release-plan.md"
$publicationReportPath = Join-Path $internalAlphaDir "publication-report.json"

$storageBaseUrl = "$supabaseUrl/storage/v1/object/public/$BucketName/$ReleaseRoot"
$protectedDownloadBaseUrl = "$supabaseUrl/functions/v1/release/download"
$normalizedStaticSiteBaseUrl = $StaticSiteBaseUrl.Trim().TrimEnd("/")
$portalUrl = ""
$webUrl = ""
if ($normalizedStaticSiteBaseUrl -ne "") {
    $portalUrl = "$normalizedStaticSiteBaseUrl/"
    $webUrl = "$normalizedStaticSiteBaseUrl/web/index.html"
} else {
    $warnings.Add("StaticSiteBaseUrl is empty; Portal/Web URLs remain pending in the planned manifest.") | Out-Null
}
$androidUrl = if ($PublicDownloads) { "$storageBaseUrl/downloads/draxos-mobile-alpha.apk" } else { "${protectedDownloadBaseUrl}?artifact=android" }
$pcUrl = if ($PublicDownloads) { "$storageBaseUrl/downloads/draxos-mobile-alpha.zip" } else { "${protectedDownloadBaseUrl}?artifact=pc_windows" }

$androidRecord = Artifact-Record -Path $androidApk -Label "Android APK" -Url $androidUrl -ExpectedMinimumBytes 1000000
$pcRecord = Artifact-Record -Path $pcZip -Label "PC Windows ZIP" -Url $pcUrl -ExpectedMinimumBytes 1000000
$webRecord = Artifact-Record -Path $webIndex -Label "Web Index" -Url $webUrl
$artifactRecords = @($androidRecord, $pcRecord, $webRecord)

foreach ($record in $artifactRecords) {
    if (-not [bool]$record.exists) {
        $blockingIssues.Add("Missing local artifact for $($record.label): $($record.path)") | Out-Null
    } elseif ([long]$record.expected_minimum_bytes -gt 0 -and [long]$record.bytes -lt [long]$record.expected_minimum_bytes) {
        $blockingIssues.Add("$($record.label) is smaller than expected: $($record.bytes) bytes.") | Out-Null
    }
}
if (-not (Test-Path -LiteralPath $portalIndex -PathType Leaf)) {
    $blockingIssues.Add("Portal template is missing: $portalIndex") | Out-Null
}

$manifest = Build-Manifest -AndroidRecord $androidRecord -PcRecord $pcRecord -WebRecord $webRecord -PortalUrl $portalUrl -WebUrl $webUrl
$manifestJson = $manifest | ConvertTo-Json -Depth 8 -Compress
Assert-NoSecretLikeText -Text $manifestJson -Label "planned manifest"

$readyForSelectedMode = $true
if ($ShouldPackage -or $IsRemoteMutation) {
    $readyForSelectedMode = $blockingIssues.Count -eq 0
} else {
    $readyForSelectedMode = $true
}

$plan = [ordered]@{
    schema_version = "internal_alpha_release_plan_v1"
    generated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    mode = $Mode
    project_dir = $ProjectDir
    env_file = $EnvFile
    remote_mutation = $IsRemoteMutation
    confirm_remote_mutation = $ConfirmRemoteMutation.IsPresent
    legacy_flags_protected = (-not $ModeProvided -and $LegacyFlagUsed)
    bucket = $BucketName
    private_download_bucket = $(if ($PublicDownloads) { $null } else { $PrivateDownloadBucketName })
    release_root = $ReleaseRoot
    downloads_protected = (-not $PublicDownloads)
    supabase_url = $supabaseUrl
    manifest_url = "$supabaseUrl/functions/v1/release/manifest"
    storage_base_url = $storageBaseUrl
    static_site_base_url = $normalizedStaticSiteBaseUrl
    cloudflare_access = [ordered]@{
        production_domain = "https://draxos-mobile-internal-alpha.pages.dev"
        production_domain_is_canonical = $true
        stable_domain_may_be_access_protected = $true
        validation_note = "O manifest deve apontar para o dominio production fixo. Use o hash de deployment apenas como evidencia tecnica; se Cloudflare Access estiver ativo, valide conteudo com sessao autenticada ou confirme o deployment Production na listagem do Cloudflare Pages."
    }
    app = [ordered]@{
        channel = "internal_alpha"
        version = "0.0.15-alpha.0"
        version_code = 15
        requires_save_reset = $false
    }
    artifacts = $artifactRecords
    planned_manifest = $manifest
    warnings = @($warnings.ToArray())
    blocking_issues = @($blockingIssues.ToArray())
    ready_for_selected_mode = $readyForSelectedMode
}

Write-ReleasePlan -Plan $plan -JsonPath $planPath -MarkdownPath $planMarkdownPath

if (-not $readyForSelectedMode -and $ShouldPackage) {
    throw "Mode $Mode cannot continue. Review blocking issues in $planPath."
}

if ($Mode -eq "Plan") {
    Write-Host "[publish-internal-alpha] Plan generated. No local package, upload, secret update, deploy or remote verification was executed."
    Write-Host "Plan: $planPath"
    Write-Host "Plan MD: $planMarkdownPath"
    if ($blockingIssues.Count -gt 0) {
        Write-Host "Blocking issues for Package/remote modes:" -ForegroundColor Yellow
        foreach ($issue in $blockingIssues) {
            Write-Host "  - $issue" -ForegroundColor Yellow
        }
    }
    exit 0
}

New-Item -ItemType Directory -Force -Path $internalAlphaDir | Out-Null
Assert-UnderDirectory -Path $publishDir -Root $internalAlphaDir -Label "PublishDir"
if (Test-Path -LiteralPath $publishDir -PathType Container) {
    Remove-Item -LiteralPath $publishDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $portalPublishDir, $webPublishDir, $downloadsPublishDir | Out-Null

Copy-DirectoryFiles -SourceDir $webDir -DestinationDir $webPublishDir -ExcludeExtensions @(".import")
Copy-Item -LiteralPath $androidApk -Destination (Join-Path $downloadsPublishDir "draxos-mobile-alpha.apk") -Force
Copy-Item -LiteralPath $pcZip -Destination (Join-Path $downloadsPublishDir "draxos-mobile-alpha.zip") -Force

Get-ChildItem -LiteralPath $portalDir -Recurse -File | Where-Object {
    @(".html", ".json", ".svg", ".png", ".jpg", ".jpeg", ".webp", ".css", ".js") -contains $_.Extension.ToLowerInvariant()
} | ForEach-Object {
    $relative = $_.FullName.Substring($portalDir.Length + 1)
    $target = Join-Path $portalPublishDir $relative
    $targetParent = Split-Path -Parent $target
    if (-not (Test-Path -LiteralPath $targetParent -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $targetParent | Out-Null
    }
    Copy-Item -LiteralPath $_.FullName -Destination $target -Force
}

$portalPublishIndexPath = Join-Path $portalPublishDir "index.html"
$portalText = Get-Content -LiteralPath $portalPublishIndexPath -Raw
$portalText = $portalText.Replace("WEB_GAME_URL_PENDING_T03_P17", $(if ($webUrl -ne "") { $webUrl } else { "STATIC_HOST_PENDING_T03_P17" }))
$portalText = $portalText.Replace("ANDROID_APK_URL_PENDING_T03_P17", $androidUrl)
$portalText = $portalText.Replace("PC_ZIP_URL_PENDING_T03_P17", $pcUrl)
$portalText = $portalText.Replace("SUPABASE_URL_PENDING_T03_P17", $supabaseUrl)
$portalText = $portalText.Replace("SUPABASE_PUBLISHABLE_KEY_PENDING_T03_P17", $publishableKey)
Assert-NoSecretLikeText -Text $portalText -Label "portal package"
Write-TextUtf8NoBom -Path $portalPublishIndexPath -Text $portalText

$manifestPath = Join-Path $publishDir "manifest.json"
Write-TextUtf8NoBom -Path $manifestPath -Text $manifestJson

$portalManifestPath = Join-Path $portalPublishDir "manifest.example.json"
if (Test-Path -LiteralPath $portalManifestPath) {
    Write-TextUtf8NoBom -Path $portalManifestPath -Text $manifestJson
}

if ($Mode -eq "Package") {
    Write-Host "[publish-internal-alpha] Package ready. No upload, secret update or deploy was executed."
    Write-Host "Publish dir: $publishDir"
    Write-Host "Plan: $planPath"
    exit 0
}

if ($ShouldUpload -and $SkipUpload) {
    Write-Warning "Mode $Mode requested upload, but -SkipUpload was supplied. Storage upload will be skipped."
}

if ($ShouldUpload -and -not $SkipUpload) {
    foreach ($file in Get-ChildItem -LiteralPath $publishDir -Recurse -File) {
        $relative = $file.FullName.Substring($publishDir.Length + 1).Replace("\", "/")
        $sourcePath = Resolve-Path -LiteralPath $file.FullName -Relative
        $targetBucket = $BucketName
        if (-not $PublicDownloads -and $relative.StartsWith("downloads/")) {
            $targetBucket = $PrivateDownloadBucketName
        }
        $destination = "ss:///$targetBucket/$ReleaseRoot/$relative"
        $contentType = Content-TypeFor -Path $file.FullName
        [void](Invoke-SupabaseOptional -Arguments @(
            "storage", "rm",
            "--linked",
            "--experimental",
            "--yes",
            $destination
        ))
        Invoke-Supabase -Arguments @(
            "storage", "cp",
            "--linked",
            "--experimental",
            $sourcePath,
            $destination,
            "--content-type",
            $contentType,
            "--cache-control",
            "no-store"
        )
    }
}

if ($ShouldDeployManifest) {
    if ($ShouldSetManifestSecret) {
        $manifestBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($manifestJson))
        Invoke-Supabase -Arguments @(
            "secrets", "set",
            "--project-ref",
            $projectRef,
            "RELEASE_MANIFEST_OVERRIDE_ENABLED=1",
            "RELEASE_MANIFEST_JSON_BASE64=$manifestBase64"
        )
    } else {
        Write-Warning "Manifest override secret was skipped. The release function will serve code defaults unless another override already exists."
    }

    Invoke-Supabase -Arguments @(
        "functions", "deploy",
        "release",
        "--project-ref",
        $projectRef,
        "--no-verify-jwt"
    )
}

if ($ShouldUpload -and -not $SkipUpload -and $PublicDownloads) {
    Assert-HeadOk -Url $androidUrl -Label "Android APK" -ExpectedMinimumBytes 1000000
    Assert-HeadOk -Url $pcUrl -Label "PC ZIP" -ExpectedMinimumBytes 1000000
} elseif ($ShouldUpload -and -not $SkipUpload) {
    Write-Host "Protected downloads enabled; direct HEAD validation is skipped for APK/ZIP."
}

if ($ShouldDeployManifest) {
    $remoteManifestResponse = Invoke-WebRequest -Method Get -Uri "$supabaseUrl/functions/v1/release/manifest" -Headers @{
        apikey = $publishableKey
    } -UseBasicParsing
    $remoteManifest = $remoteManifestResponse.Content | ConvertFrom-Json
    if ($remoteManifest.portal_url -ne $portalUrl) {
        throw "Remote manifest portal_url does not match planned portal URL."
    }
    if ($remoteManifest.artifacts.android.url -ne $androidUrl -or $remoteManifest.artifacts.android.sha256 -ne $androidRecord.sha256) {
        throw "Remote manifest Android artifact does not match planned artifact."
    }
    if ($remoteManifest.artifacts.pc_windows.url -ne $pcUrl -or $remoteManifest.artifacts.pc_windows.sha256 -ne $pcRecord.sha256) {
        throw "Remote manifest PC artifact does not match planned artifact."
    }
    if ($remoteManifest.artifacts.web.url -ne $webUrl) {
        throw "Remote manifest Web artifact does not match planned artifact."
    }
}

if ($Mode -eq "FullPublish") {
    if ($portalUrl -ne "") {
        Assert-UrlOk -Url $portalUrl -Label "Portal" -ExpectedText "DraxosMobile"
    }
    if ($webUrl -ne "") {
        Assert-UrlOk -Url $webUrl -Label "Web build" -ExpectedText "GODOT_CONFIG"
    }
}

$report = [ordered]@{
    schema_version = "internal_alpha_publication_v2"
    channel = "internal_alpha"
    app_version = "0.0.15-alpha.0"
    app_version_code = 15
    mode = $Mode
    generated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    bucket = $BucketName
    private_download_bucket = $(if ($PublicDownloads) { $null } else { $PrivateDownloadBucketName })
    release_root = $ReleaseRoot
    downloads_protected = (-not $PublicDownloads)
    portal_url = $portalUrl
    web_url = $webUrl
    manifest_url = "$supabaseUrl/functions/v1/release/manifest"
    artifacts = $artifactRecords
    release_plan = $planPath
}
$reportJson = $report | ConvertTo-Json -Depth 8
Assert-NoSecretLikeText -Text $reportJson -Label "publication report"
Write-TextUtf8NoBom -Path $publicationReportPath -Text $reportJson

Write-Host "[publish-internal-alpha] OK ($Mode)"
if ($portalUrl -ne "") {
    Write-Host "Portal: $portalUrl"
} else {
    Write-Host "Portal: pending external static host"
}
if ($webUrl -ne "") {
    Write-Host "Web: $webUrl"
} else {
    Write-Host "Web: pending external static host"
}
Write-Host "Android APK: $androidUrl"
Write-Host "PC ZIP: $pcUrl"
Write-Host "Manifest: $supabaseUrl/functions/v1/release/manifest"
Write-Host "Plan: $planPath"
Write-Host "Report: $publicationReportPath"
