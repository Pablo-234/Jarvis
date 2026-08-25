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
$hasPlaceholder = $envText -match '(?m)^OPENJARVIS_API_KEY=change-me.*$'
$hasApiKey = $envText -match '(?m)^OPENJARVIS_API_KEY=.+$'

if ($hasPlaceholder -or -not $hasApiKey) {
    $bytes = New-Object byte[] 48
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $rng.GetBytes($bytes)
    } finally {
        $rng.Dispose()
    }
    $secret = [Convert]::ToBase64String($bytes).Replace('+','-').Replace('/','_').TrimEnd('=')

    if ($envText -match '(?m)^OPENJARVIS_API_KEY=.*$') {
        $envText = [regex]::Replace($envText, '(?m)^OPENJARVIS_API_KEY=.*$', "OPENJARVIS_API_KEY=$secret")
    } else {
        $envText = $envText.TrimEnd() + "`r`nOPENJARVIS_API_KEY=$secret`r`n"
    }
    Write-Host 'Generated a private OpenJarvis API key in .env.' -ForegroundColor Green
}

# Upgrade only the old project default. Custom model choices are preserved.
if ($envText -match '(?m)^JARVIS_MODEL=qwen3\.5:2b\s*$') {
    $envText = [regex]::Replace($envText, '(?m)^JARVIS_MODEL=qwen3\.5:2b\s*$', 'JARVIS_MODEL=qwen3.5:9b')
    Write-Host 'Upgraded Jarvis model: qwen3.5:2b -> qwen3.5:9b.' -ForegroundColor Magenta
} elseif ($envText -notmatch '(?m)^JARVIS_MODEL=.+$') {
    $envText = $envText.TrimEnd() + "`r`nJARVIS_MODEL=qwen3.5:9b`r`n"
    Write-Host 'Configured Jarvis model: qwen3.5:9b.' -ForegroundColor Magenta
}

Set-Content '.env' $envText -Encoding UTF8

Write-Host 'Starting Jarvis + Ollama + Dashboard...' -ForegroundColor Cyan
docker compose up --build -d

Write-Host ''
Write-Host 'Jarvis is starting in the background.' -ForegroundColor Green
Write-Host 'Model:     qwen3.5:9b (unless a custom JARVIS_MODEL is set in .env)' -ForegroundColor Magenta
Write-Host 'API:       http://127.0.0.1:8000' -ForegroundColor Cyan
Write-Host 'Dashboard: http://127.0.0.1:8765' -ForegroundColor Cyan
Write-Host 'Use .\status-jarvis.ps1 to inspect it and .\stop-jarvis.ps1 to stop it.' -ForegroundColor DarkGray
