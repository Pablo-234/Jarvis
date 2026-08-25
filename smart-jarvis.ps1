param(
    [ValidateSet('auto', 'local', 'strategic')]
    [string]$Mode = 'auto',

    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$PromptParts
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

function Get-DotEnvValue {
    param([string]$Name, [string]$Default = '')
    if (-not (Test-Path '.env')) { return $Default }
    $text = Get-Content '.env' -Raw
    $match = [regex]::Match($text, "(?m)^$([regex]::Escape($Name))=(.*)$")
    if (-not $match.Success) { return $Default }
    return $match.Groups[1].Value.Trim()
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker Desktop is required.'
}

docker info | Out-Null

$running = docker compose ps --status running --services 2>$null
if ($running -notcontains 'jarvis') {
    throw 'Jarvis is not running. Start it first with run.cmd.'
}

$Prompt = ($PromptParts -join ' ').Trim()
if ([string]::IsNullOrWhiteSpace($Prompt)) {
    Write-Host ''
    $Prompt = Read-Host 'Jarvis'
}
if ([string]::IsNullOrWhiteSpace($Prompt)) {
    throw 'Prompt is empty.'
}

$localModel = Get-DotEnvValue 'JARVIS_MODEL' 'qwen3.5:9b'
$strategicModel = Get-DotEnvValue 'JARVIS_STRATEGIC_MODEL' 'gpt-5.6'
$openAiKey = Get-DotEnvValue 'OPENAI_API_KEY' ''
$hasStrategic = -not [string]::IsNullOrWhiteSpace($openAiKey)
$openAiKey = $null

$route = $Mode.ToUpperInvariant()

if ($Mode -eq 'auto') {
    if ($hasStrategic) {
        Write-Host 'Routing task with local Qwen...' -ForegroundColor DarkGray
        $routerOutput = & docker compose exec -T `
            -e "JARVIS_ROUTER_PROMPT=$Prompt" `
            -e "JARVIS_LOCAL_MODEL=$localModel" `
            jarvis python /opt/jarvis-profile/smart_router.py 2>$null | Out-String

        if ($routerOutput.Trim().ToUpperInvariant() -match 'STRATEGIC') {
            $route = 'STRATEGIC'
        } else {
            $route = 'LOCAL'
        }
    } else {
        $route = 'LOCAL'
    }
}

if ($route -eq 'STRATEGIC' -and -not $hasStrategic) {
    throw 'GPT-5.6 Sol is not configured yet. Run .\configure-openai.ps1 first.'
}

$tools = 'think,calculator,web_search,http_request,file_read,memory_store,memory_search,memory_retrieve'

if ($route -eq 'STRATEGIC') {
    $engine = 'cloud'
    $model = $strategicModel
    Write-Host "`nBRAIN: GPT-5.6 Sol ($model)" -ForegroundColor Magenta
} else {
    $engine = 'ollama'
    $model = $localModel
    Write-Host "`nBRAIN: Local $model" -ForegroundColor Cyan
}

& docker compose exec -T `
    -e "JARVIS_TASK_PROMPT=$Prompt" `
    -e "JARVIS_TASK_ENGINE=$engine" `
    -e "JARVIS_TASK_MODEL=$model" `
    -e "JARVIS_TASK_TOOLS=$tools" `
    jarvis sh -lc 'uv run jarvis --quiet ask "$JARVIS_TASK_PROMPT" --engine "$JARVIS_TASK_ENGINE" --model "$JARVIS_TASK_MODEL" --agent orchestrator --persona jarvis --tools "$JARVIS_TASK_TOOLS" --max-tokens 4000'

$exit = $LASTEXITCODE

if ($exit -ne 0 -and $route -eq 'STRATEGIC') {
    Write-Warning 'Strategic model failed. Falling back to local Qwen.'
    & docker compose exec -T `
        -e "JARVIS_TASK_PROMPT=$Prompt" `
        -e "JARVIS_TASK_MODEL=$localModel" `
        -e "JARVIS_TASK_TOOLS=$tools" `
        jarvis sh -lc 'uv run jarvis --quiet ask "$JARVIS_TASK_PROMPT" --engine ollama --model "$JARVIS_TASK_MODEL" --agent orchestrator --persona jarvis --tools "$JARVIS_TASK_TOOLS" --max-tokens 4000'
}
