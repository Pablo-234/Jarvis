$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker is not installed.'
}

Write-Host 'Stopping Jarvis...' -ForegroundColor Yellow
docker compose stop
Write-Host 'Jarvis stopped. Persistent model and memory volumes were kept.' -ForegroundColor Green
