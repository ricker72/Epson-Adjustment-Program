@echo off
REM ============================================================
REM  AdjProg Launcher - Soporte Windows 7 / 8 / 8.1 / 10 / 11 + x64
REM  Corrige crash al iniciar en Windows moderno (32-bit sobre WOW64)
REM ============================================================
setlocal EnableDelayedExpansion
cd /d "%~dp0"

set EXE=AdjProg.exe
if not exist "%EXE%" (
  echo [ERROR] No se encontro %EXE% en %CD%
  pause
  exit /b 1
)

REM ---- 1. Forzar directorio de trabajo (apdadrv.dll y StrGene.dll deben estar al lado) ----
if not exist "apdadrv.dll" echo [AVISO] Falta apdadrv.dll al lado del EXE - el programa se cerrara.
if not exist "StrGene.dll" echo [AVISO] Falta StrGene.dll al lado del EXE - el programa se cerrara.

REM ---- 2. Pedir admin (obligatorio en Win8/10: acceso USB + HKLM + Spooler) ----
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo [*] Solicitando permisos de Administrador...
  powershell -Command "Start-Process '%~f0' -Verb RunAs"
  exit /b 0
)

REM ---- 3. Detectar arquitectura ----
if defined ProgramFiles(x86) (
  set ARCH=x64
  echo [*] Windows 64-bit detectado - se usara WOW64 ^(emulacion 32-bit^). No se puede compilar a x64 nativo sin codigo fuente.
) else (
  set ARCH=x86
  echo [*] Windows 32-bit detectado.
)
ver | findstr /i "10\. 11\." >nul && echo [*] Windows 10/11 detectado.

REM ---- 4. Limpiar capa de compatibilidad heredada que causa crash (WINXPSP3 etc) ----
REM Si antes lo pusiste en modo XP, eso lo mata en Win10. Lo borramos y ponemos WIN7RTM + DPI safe.
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%CD%\%EXE%" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%CD%\%EXE%" /f >nul 2>&1

REM WIN7RTM es el modo mas estable para este AdjProg MFC del 2002-2007 en Win8/10/11
REM HIGHDPIAWARE=off + DPIUNAWARE evita ventanas negras; RUNASADMIN exige admin; DISABLEDXMAXIMIZEDWINDOWEDMODE evita crash DWM
set COMPAT_LAYERS=WIN7RTM HIGHDPIAWARE RUNASADMIN DISABLEDXMAXIMIZEDWINDOWEDMODE DISABLEFULLSCREENOPTIMIZATIONS
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%CD%\%EXE%" /t REG_SZ /d "%COMPAT_LAYERS%" /f >nul

REM ---- 5. Desactivar escalado DPI a nivel sistema para este EXE (fix crash GDI) ----
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%CD%\%EXE%" /t REG_SZ /d "%COMPAT_LAYERS% DPIUNAWARE" /f >nul

REM ---- 6. Variables para evitar virtualizacion y redireccion WOW64 ----
set __COMPAT_LAYER=%COMPAT_LAYERS%
REM Evita que System32 apunte a SysWOW64 en llamadas spooler 32-bit (fix EnumPortsA/OpenPrinterA)
set COMSPEC=%SystemRoot%\SysWOW64\cmd.exe

REM ---- 7. Desbloquear archivos copiados de internet (Zone.Identifier causa crash silencioso) ----
powershell -Command "Unblock-File -Path '%CD%\%EXE%','%CD%\apdadrv.dll','%CD%\StrGene.dll' -ErrorAction SilentlyContinue"

REM ---- 8. Verificar Visual C++ / MFC runtime que necesita (MFC42 / MSVCRT) ----
where mt.exe >nul 2>&1
sfc /scanfile="%SystemRoot%\SysWOW64\mfc42.dll" >nul 2>&1

REM ---- 9. Lanzar (usa version parcheada si existe) ----
set TARGET=%EXE%
if exist "AdjProg_Win10_x64ready.exe" set TARGET=AdjProg_Win10_x64ready.exe
echo [*] Lanzando !TARGET! con compatibilidad %COMPAT_LAYERS% ...
echo [*] IMPORTANTE: Conecta la impresora por USB ANTES de abrir el menu. Usa puerto USB 2.0, cable corto.
start "" "%CD%\!TARGET!"
exit /b 0
