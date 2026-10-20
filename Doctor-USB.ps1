# Doctor-USB.ps1 v2.0.0 - parte 1/2
param([switch]$Quick, [switch]$Fix)
$ErrorActionPreference = 'SilentlyContinue'
$Base = Split-Path -Parent $MyInvocation.MyCommand.Path
function Section($t){ Write-Host "`n=== $t ===" -ForegroundColor Cyan }
function OK($m){ Write-Host "[OK] $m" -ForegroundColor Green }
function WARN($m){ Write-Host "[!!] $m" -ForegroundColor Yellow }
function BAD($m){ Write-Host "[XX] $m" -ForegroundColor Red }
function Is-Admin { ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) }
Section "1. Sistema Win8/10/11"
$os = Get-CimInstance Win32_OperatingSystem
Write-Host ("Windows: {0} build {1} {2}" -f $os.Caption, $os.BuildNumber, $os.OSArchitecture)
if (Is-Admin) { OK "Admin SI" } else { BAD "Admin NO - relanza como administrador" }
if (${env:ProgramFiles(x86)}) { OK "x64 WOW64 (AdjProg 32-bit emulado)" } else { OK "x86 nativo" }
$sb = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State" -ErrorAction SilentlyContinue
if ($sb) { WARN "Secure Boot activo - driver USB debe estar firmado" } else { OK "Secure Boot no detectado" }
Section "2. Motor + manifest + firma"
foreach ($f in @('AdjProg_Win10_x64ready.exe','AdjProg.exe','apdadrv.dll','StrGene.dll')) {
  $p = Join-Path $Base $f
  if (!(Test-Path $p)) { WARN "$f falta"; continue }
  $sig = (Get-AuthenticodeSignature $p).Status
  $txt = [Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes($p))
  $hasMan = $txt.Contains('8e0f7a12-bfb3-4fe8-b9a5-48fd50a15a9a')
  Write-Host ("{0} {1} bytes firma={2} manifestWin10={3}" -f $f,(Get-Item $p).Length,$sig,$hasMan)
  if ($sig -ne 'Valid') { WARN "$f sin firma -> SmartScreen/AV pueden bloquear" }
  try { Unblock-File $p -ErrorAction Stop } catch {}
}
OK "Zone.Identifier limpiado"
Section "3. Impresoras y puertos"
$printers = Get-Printer | Where-Object { $_.Name -match 'Epson|L1210|L3210|L3250|L3251|L3260|L5290' }
if (!$printers) { BAD "No hay Epson instalada"; $printers = Get-Printer }
$printers | Format-Table Name, PortName, DriverName -AutoSize | Out-String -Width 200 | Write-Host
foreach ($pr in $printers) {
  if ($pr.PortName -match '^USB') { OK ("{0} en {1} CORRECTO" -f $pr.Name,$pr.PortName) }
  elseif ($pr.PortName -match 'WSD|TCP|IP_|EP7E|Red') { BAD ("{0} en {1} = RED/WSD FALLARA, cambia a USB00x" -f $pr.Name,$pr.PortName) }
  else { WARN ("{0} en {1}" -f $pr.Name,$pr.PortName) }
}

Section "4. Conectores USB 2.0/3.x/C/Hub"
$xhci = Get-PnpDevice -Class USB -Status OK | Where-Object { $_.FriendlyName -match 'xHCI|3\.0|3\.1|3\.2|USB4|Type-C|Thunderbolt' }
$ehci = Get-PnpDevice -Class USB -Status OK | Where-Object { $_.FriendlyName -match 'EHCI|UHCI|2\.0|Enhanced|Universal' }
Write-Host "-- xHCI/3.x/C:"; $xhci | Select-Object FriendlyName | Format-Table -AutoSize | Out-String -Width 250 | Write-Host
Write-Host "-- EHCI/2.0:"; $ehci | Select-Object FriendlyName | Format-Table -AutoSize | Out-String -Width 250 | Write-Host
$hubs = Get-PnpDevice -Class USB -Status OK | Where-Object { $_.FriendlyName -match 'Hub|Concentrador|Dock' }
if ($hubs) { WARN "Hubs/Dock = Communication Error:"; $hubs | Select-Object FriendlyName | Format-Table -AutoSize | Out-String -Width 200 | Write-Host }
$eps = Get-PnpDevice | Where-Object { $_.InstanceId -match 'VID_04B8' }
if ($eps) { $okEps = $eps | Where-Object { $_.Status -eq 'OK' }; if ($okEps) { OK "Epson USB VID_04B8 conectada:"; $okEps | Select-Object FriendlyName, InstanceId | Format-Table -AutoSize -Wrap | Out-String -Width 250 | Write-Host } else { WARN "Epson USB vista pero apagada/desconectada:"; $eps | Select-Object FriendlyName, Status, InstanceId | Format-Table -AutoSize -Wrap | Out-String -Width 250 | Write-Host } }
else { BAD "Sin USB VID_04B8. Conecta USB-B directo y enciende." }
Section "5. Energia y arranque"
try { powercfg /SETDCVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 | Out-Null; powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 | Out-Null; OK "Suspension selectiva OFF" } catch { WARN $_ }
$fast = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name HiberbootEnabled -ErrorAction SilentlyContinue).HiberbootEnabled
if ($fast -eq 0) { OK "Inicio rapido OFF" } else { WARN "Desactiva Inicio rapido en Panel energia" }
Section "6. Compat + spooler"
$t = if (Test-Path (Join-Path $Base 'AdjProg_Win10_x64ready.exe')) { Join-Path $Base 'AdjProg_Win10_x64ready.exe' } else { Join-Path $Base 'AdjProg.exe' }
$k = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers'
$v = (Get-ItemProperty $k -ErrorAction SilentlyContinue).$t
if ($v -match 'WIN7RTM') { OK "Compat WIN7RTM OK" } else { WARN "Sin compat WIN7RTM"; if ($Fix) { if (!(Test-Path $k)){New-Item $k -Force|Out-Null}; Set-ItemProperty $k -Name $t -Value 'WIN7RTM HIGHDPIAWARE RUNASADMIN DISABLEDXMAXIMIZEDWINDOWEDMODE DISABLEFULLSCREENOPTIMIZATIONS DPIUNAWARE' -Force; OK "Compat aplicada" } }
try { Restart-Service Spooler -Force -ErrorAction Stop; OK "Spooler reiniciado" } catch { WARN "$_" }
Section "7. Guia conectores"
Write-Host "USB-A 2.0 negro trasero + USB-B <2m = IDEAL."
Write-Host "USB-A 3.x azul = directo sin hub + Selective Suspend OFF."
Write-Host "USB-C/Thunderbolt/USB4/Dock = adaptador CON DATOS + hub con corriente; mejor usa A 2.0."
Write-Host "Hub sin corriente / cable de movil = FALLA. WiFi/WSD/TCP = NO sirve, usa USB001."
Write-Host "`nRESUMEN: instala via EpsonReset.iss, firma con signtool, USB-B directo 2.0, Doctor -Fix, Panel Moderno."
