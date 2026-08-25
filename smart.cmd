@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0smart-jarvis.ps1" %*
if errorlevel 1 (
  echo.
  echo Hybrid Jarvis returned an error. See the message above.
)
pause
