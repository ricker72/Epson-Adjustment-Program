# Build-Zip.ps1 - empaqueta distribucion v2.0.0
$Src = $PSScriptRoot
$Dst = Join-Path ([IO.Path]::GetDirectoryName($Src)) 'EpsonReset-v2.0.0-Win8-10-11-USB.zip'
$files = @('AdjProg_Win10_x64ready.exe','AdjProg.exe','apdadrv.dll','StrGene.dll','AdjProg_Modern_Launcher.ps1','Doctor-USB.ps1','Doctor-USB.bat','INSTALAR_EpsonReset.bat','ABRIR_Panel_Moderno_v2.bat','EpsonReset.iss','Firmar-Setup.ps1','Verificar-Instalacion.ps1') | ForEach-Object { Join-Path $Src $_ } | Where-Object { Test-Path $_ }
if (Test-Path $Dst) { Remove-Item $Dst -Force }
Compress-Archive -LiteralPath $files -DestinationPath $Dst
Get-Item $Dst | Select-Object Name, Length, LastWriteTime | Format-List | Out-String -Width 200 | Write-Host
