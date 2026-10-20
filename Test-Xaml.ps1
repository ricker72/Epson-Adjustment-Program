# Test-Xaml.ps1 - valida solo el XAML del launcher
$c = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'AdjProg_Modern_Launcher.ps1') -Raw
$m = [regex]::Match($c, '\[xml\]\$Xaml = @"(?s)(.*)"@')
$x = $m.Groups[1].Value
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
try { [Windows.Markup.XamlReader]::Parse($x) | Out-Null; Write-Host 'XAML launcher OK' }
catch { Write-Host ("XAML ERROR: " + $_.Exception.Message) }
