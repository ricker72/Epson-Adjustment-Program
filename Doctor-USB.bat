@echo off
REM Epson Reset - Doctor USB (Win8/10/11) - @Ricker
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Doctor-USB.ps1" %*
pause
