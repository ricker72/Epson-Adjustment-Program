# Verificar-Instalacion.ps1 - checklist final Win8/10/11 + USB
$ErrorActionPreference='SilentlyContinue'
$Base=Split-Path -Parent $MyInvocation.MyCommand.Path
function OK($m){Write-Host "[OK] $m" -ForegroundColor Green}
function BAD($m){Write-Host "[XX] $m" -ForegroundColor Red}
$fail=0
$t=Join-Path $Base 'AdjProg_Win10_x64ready.exe'
if(!(Test-Path $t)){BAD "falta $t";$fail++}else{
  $raw=[IO.File]::ReadAllBytes($t);$txt=[Text.Encoding]::ASCII.GetString($raw)
  if($txt.Contains('8e0f7a12-bfb3-4fe8-b9a5-48fd50a15a9a')){OK "manifest Win8/10/11 embebido"}else{BAD "manifest no embebido - corre embed_manifest.py";$fail++}
  if($txt.Contains('requireAdministrator')){OK "requireAdministrator OK"}else{BAD "sin requireAdmin";$fail++}
}
foreach($f in @('EpsonReset.iss','INSTALAR_EpsonReset.bat','Doctor-USB.ps1','AdjProg_Modern_Launcher.ps1','Firmar-Setup.ps1')){
  if(Test-Path (Join-Path $Base $f)){OK $f}else{BAD "falta $f";$fail++}
}
$u=Get-PnpDevice | Where-Object{$_.InstanceId -match 'VID_04B8' -and $_.Status -eq 'OK'}
$p=Get-Printer | Where-Object{$_.Name -match 'Epson' -and $_.PortName -match '^USB'}
if($u -and $p){OK ("Epson USB {0}" -f $p[0].PortName)}else{BAD "enciende Epson por USB-B directo";$fail++}
if($fail -eq 0){OK "TODO LISTO - instala con INSTALAR_EpsonReset.bat (admin)"}else{BAD "$fail pendientes arriba"}
