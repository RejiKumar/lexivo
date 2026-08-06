<#
.SYNOPSIS
Applies Alembic migrations to the database in `backend/.env`.

.DESCRIPTION
Migration 0001 runs `CREATE EXTENSION IF NOT EXISTS vector`, so the target
Postgres must have pgvector available (Supabase and the pgvector Docker image
do; a stock Windows PostgreSQL install does not).

.EXAMPLE
pwsh tool/db_migrate.ps1
pwsh tool/db_migrate.ps1 -Revision 0003_document_summaries
#>
[CmdletBinding()]
param(
    [string]$Revision = 'head'
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$backend = Join-Path $repoRoot 'backend'
$python = Join-Path $backend '.venv\Scripts\python.exe'

if (-not (Test-Path $python)) {
    throw "Backend venv missing. Run: cd backend; python -m venv .venv; .\.venv\Scripts\python.exe -m pip install -r requirements.txt"
}

Push-Location $backend
try {
    & $python -m alembic upgrade $Revision
}
finally {
    Pop-Location
}
