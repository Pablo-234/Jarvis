$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not (Test-Path '.env')) {
    Copy-Item '.env.example' '.env'
}

Write-Host ''
Write-Host 'Configure GPT-5.6 Sol for Jarvis' -ForegroundColor Cyan
Write-Host 'The key is saved only in your local .env file (ignored by git).' -ForegroundColor DarkGray
Write-Host ''

$secure = Read-Host 'Paste your OpenAI API key' -AsSecureString
$ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try {
    $key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
}

if ([string]::IsNullOrWhiteSpace($key)) {
    throw 'No API key was entered.'
}

$envText = Get-Content '.env' -Raw

if ($envText -match '(?m)^OPENAI_API_KEY=.*$') {
    $envText = [regex]::Replace($envText, '(?m)^OPENAI_API_KEY=.*$', "OPENAI_API_KEY=$key")
} else {
    $envText = $envText.TrimEnd() + "`r`nOPENAI_API_KEY=$key`r`n"
}

if ($envText -match '(?m)^JARVIS_STRATEGIC_MODEL=.*$') {
    $envText = [regex]::Replace($envText, '(?m)^JARVIS_STRATEGIC_MODEL=.*$', 'JARVIS_STRATEGIC_MODEL=gpt-5.6')
} else {
    $envText = $envText.TrimEnd() + "`r`nJARVIS_STRATEGIC_MODEL=gpt-5.6`r`n"
}

Set-Content '.env' $envText -Encoding UTF8
$key = $null

Write-Host ''
Write-Host 'GPT-5.6 Sol configured.' -ForegroundColor Green
Write-Host 'Strategic model: gpt-5.6 -> GPT-5.6 Sol' -ForegroundColor Magenta

if (Get-Command docker -ErrorAction SilentlyContinue) {
    try {
        docker info | Out-Null
        $running = docker compose ps --status running --services 2>$null
        if ($running -contains 'jarvis') {
            Write-Host 'Recreating the Jarvis container so it receives the new key...' -ForegroundColor Yellow
            docker compose up -d --no-deps --force-recreate jarvis
        }
    } catch {
        Write-Warning 'Key was saved, but Jarvis was not restarted. Run run.cmd when Docker is ready.'
    }
}

Write-Host ''
Write-Host 'Use .\smart.cmd to talk to the hybrid Jarvis.' -ForegroundColor Cyan
