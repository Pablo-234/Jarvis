$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker Desktop is required. Install/start Docker Desktop and run this script again.'
}

if (-not (Test-Path '.env')) {
    Copy-Item '.env.example' '.env'
    Write-Host 'Created .env from .env.example.' -ForegroundColor Yellow
    Write-Host 'Set a long OPENJARVIS_API_KEY in .env, then run this script again.' -ForegroundColor Yellow
    exit 1
}

$envText = Get-Content '.env' -Raw
if ($envText -match 'OPENJARVIS_API_KEY=change-me') {
    throw 'Replace the placeholder OPENJARVIS_API_KEY in .env before starting Jarvis.'
}

Write-Host 'Starting Jarvis + Ollama...' -ForegroundColor Cyan
docker compose up --build
