$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

Write-Host ''
Write-Host '=====================================' -ForegroundColor DarkCyan
Write-Host '        JARVIS - ONE CLICK RUN       ' -ForegroundColor Cyan
Write-Host '=====================================' -ForegroundColor DarkCyan
Write-Host ''

& "$PSScriptRoot\start-jarvis.ps1"

$dashboardPort = 8765
if (Test-Path '.env') {
    $envText = Get-Content '.env' -Raw
    if ($envText -match '(?m)^DASHBOARD_PORT=(\d+)\s*$') {
        $dashboardPort = [int]$Matches[1]
    }
}

$dashboardUrl = "http://127.0.0.1:$dashboardPort"
Write-Host ''
Write-Host "Waiting for dashboard on $dashboardUrl ..." -ForegroundColor Yellow

$ready = $false
for ($i = 0; $i -lt 60; $i++) {
    try {
        $response = Invoke-WebRequest -Uri $dashboardUrl -UseBasicParsing -TimeoutSec 2
        if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500) {
            $ready = $true
            break
        }
    } catch {
        Start-Sleep -Seconds 1
    }
}

if ($ready) {
    Write-Host 'Jarvis dashboard is ONLINE.' -ForegroundColor Green
    Start-Process $dashboardUrl
} else {
    Write-Warning "Containers were started, but the dashboard did not answer yet. Open $dashboardUrl manually or run .\status-jarvis.ps1."
}

Write-Host ''
Write-Host 'Useful commands:' -ForegroundColor Cyan
Write-Host '  .\status-jarvis.ps1   - status'
Write-Host '  .\stop-jarvis.ps1     - stop'
Write-Host '  docker compose logs -f jarvis   - live Jarvis logs'
Write-Host ''
