@echo off
REM INSTALAR_EpsonReset v2.0.0 - Instalador portable sin Inno (Win8/10/11 x64) - @Ricker
setlocal EnableDelayedExpansion
cd /d "%~dp0"
net session >nul 2>&1
if %errorlevel% neq 0 (powershell -Command "Start-Process '%~f0' -Verb RunAs" & exit /b 0)
set DEST=%ProgramFiles(x86)%\EpsonReset-L1210-L5290
if not defined ProgramFiles(x86) set DEST=%ProgramFiles%\EpsonReset-L1210-L5290
echo [*] Instalando en %DEST% ...
mkdir "%DEST%" 2>nul
copy /y "AdjProg_Win10_x64ready.exe" "%DEST%\" >nul
copy /y "AdjProg.exe" "%DEST%\" >nul
copy /y "apdadrv.dll" "%DEST%\" >nul
copy /y "StrGene.dll" "%DEST%\" >nul
copy /y "AdjProg_Modern_Launcher.ps1" "%DEST%\" >nul
copy /y "Doctor-USB.ps1" "%DEST%\" >nul
copy /y "Doctor-USB.bat" "%DEST%\" >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -LiteralPath '%DEST%' | Unblock-File -ErrorAction SilentlyContinue"
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%DEST%\AdjProg_Win10_x64ready.exe" /t REG_SZ /d "WIN7RTM HIGHDPIAWARE RUNASADMIN DISABLEDXMAXIMIZEDWINDOWEDMODE DISABLEFULLSCREENOPTIMIZATIONS DPIUNAWARE" /f >nul
reg add "HKCU\Software\EpsonReset" /v Version /t REG_SZ /d "2.0.0" /f >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%ProgramData%\Microsoft\Windows\Start Menu\Programs\Epson Reset L1210-L5290.lnk'); $s.TargetPath='powershell.exe'; $s.Arguments='-NoProfile -ExecutionPolicy Bypass -File \"%DEST%\AdjProg_Modern_Launcher.ps1\"'; $s.WorkingDirectory='%DEST%'; $s.Save()"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%USERPROFILE%\Desktop\Epson Reset L1210-L5290.lnk'); $s.TargetPath='powershell.exe'; $s.Arguments='-NoProfile -ExecutionPolicy Bypass -File \"%DEST%\AdjProg_Modern_Launcher.ps1\"'; $s.WorkingDirectory='%DEST%'; $s.Save()"
echo [OK] Instalado. Ejecuta Doctor-USB.bat y luego el acceso Epson Reset.
pause
