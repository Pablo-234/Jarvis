$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker Desktop is required. Install and start Docker Desktop, then run this script again.'
}

try {
    docker info | Out-Null
} catch {
    throw 'Docker is installed, but the Docker engine is not running. Start Docker Desktop first.'
}

if (-not (Test-Path '.env')) {
    Copy-Item '.env.example' '.env'
}

$envText = Get-Content '.env' -Raw
if ($envText -match 'OPENJARVIS_API_KEY=change-me' -or $envText -notmatch 'OPENJARVIS_API_KEY=') {
    $bytes = New-Object byte[] 48
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $rng.GetBytes($bytes)
    } finally {
        $rng.Dispose()
    }
    $secret = [Convert]::ToBase64String($bytes).Replace('+','-').Replace('/','_').TrimEnd('=')

    if ($envText -match 'OPENJARVIS_API_KEY=change-me') {
        $envText = $envText -replace 'OPENJARVIS_API_KEY=change-me', "OPENJARVIS_API_KEY=$secret"
    } else {
        $envText = $envText.TrimEnd() + "`r`nOPENJARVIS_API_KEY=$secret`r`n"
    }
    Set-Content '.env' $envText -Encoding UTF8
    Write-Host 'Generated a private OpenJarvis API key in .env.' -ForegroundColor Green
}

Write-Host 'Starting Jarvis + Ollama...' -ForegroundColor Cyan
docker compose up --build -d

Write-Host ''
Write-Host 'Jarvis is starting in the background.' -ForegroundColor Green
Write-Host 'API: http://127.0.0.1:8000' -ForegroundColor Cyan
Write-Host 'Use .\status-jarvis.ps1 to inspect it and .\stop-jarvis.ps1 to stop it.' -ForegroundColor DarkGray
