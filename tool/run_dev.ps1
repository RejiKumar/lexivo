<#
.SYNOPSIS
Runs the Lexivo Flutter client in debug from the single `.env.development` file.

.DESCRIPTION
One env file drives every target. Android emulators and USB devices reach the
host API through `adb reverse`, so `API_BASE_URL=http://localhost:8000` is
correct everywhere and never needs a per-target value.

Pass -ApiHost for targets adb cannot tunnel (physical iOS device, another
machine's browser); it rewrites API_BASE_URL in `.env.development` so the file
stays the single source of truth.

.EXAMPLE
pwsh tool/run_dev.ps1 -Target android
pwsh tool/run_dev.ps1 -Target web
pwsh tool/run_dev.ps1 -Target android -DeviceId RZCXB2B0CVT
pwsh tool/run_dev.ps1 -Target ios -ApiHost 192.168.1.20
#>
[CmdletBinding()]
param(
    [ValidateSet('android', 'web', 'ios', 'windows')]
    [string]$Target = 'android',

    [string]$DeviceId,

    [string]$ApiHost,

    [int]$ApiPort = 8000,

    [switch]$Release
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $repoRoot '.env.development'
$envTemplate = Join-Path $repoRoot '.env.example'

if (-not (Test-Path $envFile)) {
    Write-Host "Creating .env.development from .env.example - fill SUPABASE_URL and SUPABASE_ANON_KEY."
    Copy-Item $envTemplate $envFile
}

function Set-EnvValue([string]$key, [string]$value) {
    $lines = Get-Content $envFile
    $updated = $false
    $lines = $lines | ForEach-Object {
        if ($_ -match "^$key=") { $updated = $true; "$key=$value" } else { $_ }
    }
    if (-not $updated) { $lines += "$key=$value" }
    Set-Content -Path $envFile -Value $lines -Encoding utf8
}

if ($ApiHost) {
    Set-EnvValue 'API_BASE_URL' "http://${ApiHost}:${ApiPort}"
    Write-Host "API_BASE_URL -> http://${ApiHost}:${ApiPort}"
}
else {
    Set-EnvValue 'API_BASE_URL' "http://localhost:${ApiPort}"
}

$missing = Get-Content $envFile |
    Where-Object { $_ -match '^(SUPABASE_URL|SUPABASE_ANON_KEY)=\s*$' } |
    ForEach-Object { ($_ -split '=')[0] }
if ($missing) {
    throw "Fill $($missing -join ', ') in .env.development before running (see README)."
}

# Gradle/Java prefer IPv6 on some Windows setups and stall dependency downloads.
$env:JAVA_OPTS = '-Djava.net.preferIPv4Stack=true'
$env:GRADLE_OPTS = '-Djava.net.preferIPv4Stack=true'

$device = $DeviceId
switch ($Target) {
    'web' { if (-not $device) { $device = 'chrome' } }
    'ios' { if (-not $device) { $device = 'ios' } }
    'windows' { if (-not $device) { $device = 'windows' } }
    'android' {
        if (-not $device) {
            $attached = (& adb devices) |
                Select-String -Pattern '^(\S+)\s+device$' |
                ForEach-Object { $_.Matches[0].Groups[1].Value }
            if (-not $attached) {
                throw 'No Android device found. Start an emulator or connect a phone with USB debugging on.'
            }
            $device = $attached[0]
            if ($attached.Count -gt 1) {
                Write-Host "Multiple devices attached; using $device (override with -DeviceId)."
            }
        }
        if (-not $ApiHost) {
            # Maps device localhost:<port> to this machine - works for emulators
            # and USB devices, and needs no firewall rule.
            & adb -s $device reverse "tcp:$ApiPort" "tcp:$ApiPort" | Out-Null
            Write-Host "adb reverse tcp:$ApiPort -> host:$ApiPort ($device)"
        }
    }
}

$flutterArgs = @('run', "--dart-define-from-file=$envFile", '-d', $device)
if ($Release) { $flutterArgs += '--release' }

Write-Host "flutter $($flutterArgs -join ' ')"
& flutter @flutterArgs
