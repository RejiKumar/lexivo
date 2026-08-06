<#
.SYNOPSIS
Starts the Lexivo API for local debug, refusing to add a second listener.

.DESCRIPTION
Windows lets a process bind 127.0.0.1:8000 while another holds 0.0.0.0:8000, and
the narrower socket wins. A forgotten instance then serves every request with
stale env, which looks like broken auth or config. This script fails fast when
port 8000 is already taken (use -Force to stop the existing listeners first).

.EXAMPLE
pwsh tool/run_api.ps1
pwsh tool/run_api.ps1 -Force
#>
[CmdletBinding()]
param(
    [int]$Port = 8000,
    [switch]$Force,
    [switch]$Reload
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$backend = Join-Path $repoRoot 'backend'
$python = Join-Path $backend '.venv\Scripts\python.exe'

if (-not (Test-Path $python)) {
    throw "Backend venv missing. Run: cd backend; python -m venv .venv; .\.venv\Scripts\python.exe -m pip install -r requirements.txt"
}
if (-not (Test-Path (Join-Path $backend '.env'))) {
    throw "backend/.env missing. Copy backend/.env.example to backend/.env and fill your keys."
}

$listeners = @(Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue)
if ($listeners) {
    $pids = $listeners.OwningProcess | Sort-Object -Unique
    if (-not $Force) {
        throw "Port $Port already has listener(s): $($pids -join ', '). Stop them or re-run with -Force."
    }
    foreach ($processId in $pids) {
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 2
}

# 0.0.0.0 so emulators, USB devices (via adb reverse), and the host all reach it.
$uvicornArgs = @('-m', 'uvicorn', 'app.main:app', '--host', '0.0.0.0', '--port', "$Port", '--log-level', 'info')
if ($Reload) { $uvicornArgs += '--reload' }

Push-Location $backend
try {
    & $python @uvicornArgs
}
finally {
    Pop-Location
}
