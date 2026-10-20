# SC-T5475 Vida Util + Reset v1.0.0 - parte 1/3 cabecera + drivers + USB
param([switch]$Quick, [switch]$AbrirManual)
$ErrorActionPreference = 'SilentlyContinue'
$ToolVer = '1.0.0'
$Base = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogDir = Join-Path $Base 'Reportes'
$LogJson = Join-Path $LogDir 'SC-T5475_vida_util.json'
$ManualUrl = 'https://files.support.epson.com/docid/cpd5/cpd58955.pdf'
$ManualLocal = Join-Path $Base 'Manual_SC-T5475_cpd58955.pdf'
$DriverUrl = 'https://epson.com/Support/Printers/Single-Function-Inkjet-Printers/SureColor-Series/Epson-SureColor-T5475/s/SPT_SCT5475SR'
function Section($t){ Write-Host ("`n=== {0} ===" -f $t) -ForegroundColor Cyan }
function OK($m){ Write-Host ("[OK] {0}" -f $m) -ForegroundColor Green }
function WARN($m){ Write-Host ("[!!] {0}" -f $m) -ForegroundColor Yellow }
function BAD($m){ Write-Host ("[XX] {0}" -f $m) -ForegroundColor Red }
function INFO($m){ Write-Host ("[--] {0}" -f $m) -ForegroundColor Gray }
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
function Get-Estado {
  $epsUsb = Get-PnpDevice | Where-Object { $_.InstanceId -match 'VID_04B8' }
  $epsOk = $epsUsb | Where-Object { $_.Status -eq 'OK' }
  $colas = Get-Printer | Where-Object { $_.Name -match 'T5475|SC-T|SureColor|T5400|T3400|Epson' }
  $colaSC = $colas | Where-Object { $_.Name -match 'T5475|SC-T|SureColor' }
  $colaUsb = $colaSC | Where-Object { $_.PortName -match '^USB' }
  return @{ UsbOk=$epsOk; UsbTodos=$epsUsb; ColaSC=$colaSC; ColaUsb=$colaUsb }
}
function Test-Drivers {
  param($st)
  Section 'PASO 1/5 - Drivers oficiales (antes de todo)'
  INFO ("Descarga oficial: {0}" -f $DriverUrl)
  INFO 'En esa pagina: Drivers and Downloads > Windows > Printer Driver.'
  if (-not $st.ColaSC) {
    BAD 'Sin cola SC-T5475. Instala PRIMERO el driver oficial y repite.'
    return $false
  }
  foreach ($d in $st.ColaSC) {
    if ([string]::IsNullOrWhiteSpace($d.DriverName) -or ($d.DriverName -match 'Generic|Microsoft IPP|Class')) {
      BAD ("Cola '{0}' con driver generico. Reinstala driver Epson." -f $d.Name)
      return $false
    }
    OK ("Driver OK: {0} en {1}" -f $d.Name, $d.PortName)
  }
  return $true
}
function Test-Usb {
  param($st)
  Section 'PASO 2/5 - USB-B directo (obligatorio reset)'
  if (-not $st.UsbOk) {
    BAD 'Sin Epson USB VID_04B8. Cable USB-B <2m trasero 2.0 sin hub.'
    return $false
  }
  OK 'USB VID_04B8 OK.'
  if (-not $st.ColaUsb) {
    BAD 'Cola SC no esta en USB00x. Cambiala a USB (no WSD/TCP).'
    return $false
  }
  OK ("Cola en {0} CORRECTO." -f $st.ColaUsb[0].PortName)
  return $true
}

function Show-RepairMode {
  Section 'PASO 3/5 - Modo reparacion SELF-DIAGNOSTIC'
  Write-Host '  1. Apaga el plotter con Power.' -ForegroundColor White
  Write-Host '  2. Manten OK + Menu y enciende 5 seg sin soltar.' -ForegroundColor White
  Write-Host '  3. Panel debe decir SELF-DIAGNOSTIC / SERVICE MODE.' -ForegroundColor White
  Write-Host '  4. Conecta USB-B trasero (driver ya instalado).' -ForegroundColor White
  WARN 'Sin este modo el tool da Communication error.'
  INFO 'Errores 00000008 / 00080000 = Maintenance / Borderless lleno.'
  $r = Read-Host 'Escribe SI cuando estes en SELF-DIAGNOSTIC'
  return ($r -match '^(?i:si|s|yes|y)$')
}
function Read-VidaUtil {
  Section 'PASO 4/5 - Examinar vida util'
  $prev = $null
  if (Test-Path $LogJson) { try { $prev = Get-Content -Raw $LogJson | ConvertFrom-Json } catch {} }
  $mc = $null; $bl = $null
  if ($prev) { $mc = $prev.maintenance_cart_pct; $bl = $prev.borderless_pct }
  if ($null -eq $mc) {
    Write-Host 'Mira el panel: Maintenance Box % y Borderless %.' -ForegroundColor White
    $a = Read-Host 'Maintenance % usado 0-100 (Enter=desconocido)'
    $b = Read-Host 'Borderless % usado 0-100 (Enter=desconocido)'
    if ($a -match '^\d+$') { $mc = [int]$a } else { $mc = -1 }
    if ($b -match '^\d+$') { $bl = [int]$b } else { $bl = -1 }
  } else {
    INFO ("Ultimo: Maintenance {0}% | Borderless {1}%." -f $mc, $bl)
    $a = Read-Host 'Nuevo Maintenance % (Enter=mantener)'
    $b = Read-Host 'Nuevo Borderless % (Enter=mantener)'
    if ($a -match '^\d+$') { $mc = [int]$a }
    if ($b -match '^\d+$') { $bl = [int]$b }
  }
  if ($mc -ge 100 -or $bl -ge 100) { BAD 'Bloqueo 00000008/00080000 activo. No imprimas hasta reset.' }
  elseif ($mc -ge 90 -or $bl -ge 90) { WARN 'Mayor 90%: cambia T582000 pronto.' }
  else { OK ("Vida util: Maintenance {0}% | Borderless {1}%." -f $mc, $bl) }
  return @{ mc=$mc; bl=$bl }
}

function Reset-Zero {
  param($vals)
  Section 'PASO 5/5 - Reset a 0 (cartucho nuevo + modo reparacion)'
  WARN 'Si T582000 sigue lleno fisico, NO resetees: derrame.'
  $c1 = Read-Host 'Cambiaste Maintenance T582000 por uno nuevo? (SI/NO)'
  if ($c1 -notmatch '^(?i:si|s|yes|y)$') { BAD 'Cambialo primero (ver manual).'; return $false }
  $c2 = Read-Host 'SELF-DIAGNOSTIC + USB + driver OK? (SI/NO)'
  if ($c2 -notmatch '^(?i:si|s|yes|y)$') { BAD 'Completa pasos 1-3.'; return $false }
  $exeSC = Join-Path $Base 'AdjProg_SC-T5475.exe'
  $anySC = Get-ChildItem $Base -Filter *.exe -ErrorAction SilentlyContinue | Select-Object -First 1
  if ((Test-Path $exeSC) -or $anySC) {
    $tool = $(if (Test-Path $exeSC) { $exeSC } else { $anySC.FullName })
    OK ("Abriendo Service Tool: {0}" -f (Split-Path $tool -Leaf))
    INFO 'En tool: SC-T5475 > Particular > Maintenance counter > Check > Initialize > Finish.'
    try { Start-Process $tool -WorkingDirectory $Base } catch { BAD $_; return $false }
  } else {
    WARN 'Sin Service Tool: hago reset LOGICO local a 0.'
  }
  $r = Read-Host 'Confirma RESET A 0. Escribe RESET0'
  if ($r -ne 'RESET0') { WARN 'Cancelado.'; return $false }
  $rec = [pscustomobject]@{
    modelo='SC-T5475'; fecha=(Get-Date).ToString('s'); tool=$ToolVer
    maintenance_cart_pct=0; borderless_pct=0
    previo_mc=$vals.mc; previo_bl=$vals.bl
    manual=$ManualUrl
  }
  $rec | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 $LogJson
  OK ("Puesto a 0. Reporte: {0}" -f $LogJson)
  OK 'Apaga 15 seg > enciende > verifica sin 00000008.'
  return $true
}
function Show-Manual {
  Section 'Manual oficial cpd58955'
  INFO ("URL: {0}" -f $ManualUrl)
  if (Test-Path $ManualLocal) { OK ("PDF local: {0}" -f $ManualLocal) }
  else { WARN 'Guarda el PDF como Manual_SC-T5475_cpd58955.pdf aqui para offline.' }
  $k = Read-Host 'M para abrir manual, Enter seguir'
  if ($k -match '^(?i:m)$') { try { Start-Process $ManualUrl } catch {} }
}
Section ("SC-T5475 Vida Util + Reset v{0}" -f $ToolVer)
INFO 'Errores 00000008 / 00080000 = Maintenance / Borderless lleno.'
$st = Get-Estado
if (-not (Test-Drivers $st)) {
  $q = Read-Host 'Abrir drivers oficiales ahora? (SI/NO)'
  if ($q -match '^(?i:si|s|yes|y)$') { try { Start-Process $DriverUrl } catch {} }
  if (-not $Quick) { Write-Host 'Instala driver y repite.'; return }
}
if (-not (Test-Usb $st)) { if (-not $Quick) { Write-Host 'Corrige USB y repite.'; return } }
if (-not $Quick) { if (-not (Show-RepairMode)) { WARN 'Sin modo reparacion no hay reset.'; return } }
$vals = Read-VidaUtil
Show-Manual
$ok = Reset-Zero $vals
if ($ok) { OK 'Completado. Guarda el JSON.' } else { WARN 'No completado.' }

