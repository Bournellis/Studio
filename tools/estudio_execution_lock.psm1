Set-StrictMode -Version Latest

function Enter-EstudioExecutionLock {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('GodotQA', 'AndroidQA')]
        [string]$Resource,
        [ValidateRange(0, 300)]
        [int]$TimeoutSeconds = 30
    )

    $name = "Local\Estudio.$Resource.v1"
    $created = $false
    $mutex = [System.Threading.Mutex]::new($false, $name, [ref]$created)
    $acquired = $false
    try {
        try {
            $acquired = $mutex.WaitOne([TimeSpan]::FromSeconds($TimeoutSeconds))
        } catch [System.Threading.AbandonedMutexException] {
            $acquired = $true
        }
        if (-not $acquired) {
            throw "RESOURCE_BUSY resource=$Resource timeoutSeconds=$TimeoutSeconds"
        }
        Write-Host "ESTUDIO_EXECUTION_LOCK_ACQUIRED resource=$Resource"
        return $mutex
    } catch {
        if (-not $acquired) { $mutex.Dispose() }
        throw
    }
}

function Exit-EstudioExecutionLock {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Threading.Mutex]$Lock,
        [Parameter(Mandatory = $true)]
        [ValidateSet('GodotQA', 'AndroidQA')]
        [string]$Resource
    )

    try {
        $Lock.ReleaseMutex()
        Write-Host "ESTUDIO_EXECUTION_LOCK_RELEASED resource=$Resource"
    } finally {
        $Lock.Dispose()
    }
}

Export-ModuleMember -Function Enter-EstudioExecutionLock, Exit-EstudioExecutionLock
