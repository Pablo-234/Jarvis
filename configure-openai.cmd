@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0configure-openai.ps1"
if errorlevel 1 (
  echo.
  echo OpenAI configuration failed. See the message above.
)
pause
