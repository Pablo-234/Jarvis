$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker is not installed.'
}

Write-Host 'Jarvis services:' -ForegroundColor Cyan
docker compose ps
Write-Host ''
Write-Host 'Recent Jarvis logs:' -ForegroundColor Cyan
docker compose logs --tail 25 jarvis
