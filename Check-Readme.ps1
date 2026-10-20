# Check-Readme.ps1 - valida README v2.0.0
$c = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'README.md') -Raw
Write-Host ("lineas={0} bytes={1}" -f ($c -split "`n").Count, $c.Length)
Write-Host ("headers={0}" -f ([regex]::Matches($c,'^##?\s','Multiline').Count))
foreach ($k in @('Novedades v2.0.0','Actualización segura','Doctor-USB','INSTALAR_EpsonReset','EpsonReset.iss','v2.0.0')) {
  if ($c.Contains($k)) { Write-Host ("[OK] {0}" -f $k) -ForegroundColor Green }
  else { Write-Host ("[XX] falta {0}" -f $k) -ForegroundColor Red }
}
