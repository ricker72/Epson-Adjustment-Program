# EPSON Adjustment Program v2.0.0 - Panel moderno nativo (WPF, sin Python) - @Ricker
# Uso: doble clic ABRIR_Panel_Moderno_v2.bat
param([switch]$Elevated)
$ErrorActionPreference = 'SilentlyContinue'
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
$Base = Split-Path -Parent $MyInvocation.MyCommand.Path
$ExePar = Join-Path $Base 'AdjProg_Win10_x64ready.exe'
$ExeOri = Join-Path $Base 'AdjProg.exe'
function Get-Target { if (Test-Path $ExePar) { $ExePar } else { $ExeOri } }
function Is-Admin {
  ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
[xml]$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="EPSON Adjustment Program  v2.0.0  |  Win 11 ready  |  @Ricker"
        Width="900" Height="600" MinWidth="860" MinHeight="560"
        Background="#1E2126" WindowStartupLocation="CenterScreen">
  <Grid Margin="24,18,24,16">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>
    <StackPanel Grid.Row="0">
      <DockPanel>
        <TextBlock Text="EPSON Adjustment Program" Foreground="#3B82F6" FontSize="28" FontWeight="Bold" FontFamily="Segoe UI"/>
        <TextBlock Text="v2.0.0" Foreground="#9AA3B2" FontSize="14" Margin="12,14,0,0" FontFamily="Segoe UI"/>
      </DockPanel>
      <TextBlock Text="L1210  L3210  L3250  L3251  L3260  L5290   |   Win 8 / 10 / 11  x64 (WOW64)   |   @Ricker" Foreground="#9AA3B2" FontSize="12" FontFamily="Segoe UI" Margin="0,2,0,0"/>
    </StackPanel>
    <Grid Grid.Row="1" Margin="0,14,0,0">
      <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
      <Border Grid.Column="0" Background="#262B33" CornerRadius="10" Margin="0,0,8,0" Padding="18">
        <StackPanel>
          <TextBlock Text="Modos de ajuste" Foreground="White" FontSize="16" FontWeight="Bold" FontFamily="Segoe UI"/>
          <TextBlock Text="Modos de ajuste para mantenimiento del dispositivo. Siga el orden correcto tras seleccionar piezas de repuesto o reparadas. Multi-seleccion posible. Win 11 Por @Ricker" Foreground="#E8ECF1" FontSize="13" FontFamily="Segoe UI" TextWrapping="Wrap" Margin="0,10,0,14"/>
          <Button x:Name="BtnStart" Content="Iniciar modo secuencial (recomendado)" Background="#2F7CF6" Foreground="White" FontSize="13" FontWeight="Bold" Padding="10" Margin="0,4,0,4" BorderThickness="0" Cursor="Hand"/>
          <Button x:Name="BtnOpen" Content="Abrir AdjProg (motor original)" Padding="8" Margin="0,4,0,4" FontSize="12"/>
          <Button x:Name="BtnExit" Content="Salir" Padding="8" Margin="0,4,0,0" FontSize="12"/>
          <TextBlock Text="Conecte la impresora por USB 2.0 ANTES de elegir modelo." Foreground="#9AA3B2" FontSize="11" TextWrapping="Wrap" Margin="0,14,0,0"/>
        </StackPanel>
      </Border>
      <Border Grid.Column="1" Background="#262B33" CornerRadius="10" Margin="8,0,0,0" Padding="18">
        <Grid>
          <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
          <TextBlock Grid.Row="0" Text="Estado del sistema" Foreground="White" FontSize="16" FontWeight="Bold" FontFamily="Segoe UI"/>
          <TextBox x:Name="TxtStatus" Grid.Row="1" Background="#1B1F25" Foreground="#E8ECF1" FontFamily="Consolas" FontSize="12" Margin="0,10,0,10" IsReadOnly="True" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto" BorderThickness="0" Padding="8"/>
          <StackPanel Grid.Row="2" Orientation="Horizontal">
            <Button x:Name="BtnDiag" Content="Diagnosticar" Padding="10,6" Margin="0,0,6,0"/>
            <Button x:Name="BtnCompat" Content="Aplicar compat" Padding="10,6" Margin="0,0,6,0"/>
            <Button x:Name="BtnHelp" Content="Ayuda" Padding="10,6"/>
          </StackPanel>
        </Grid>
      </Border>
    </Grid>
    <TextBlock x:Name="LblBar" Grid.Row="2" Foreground="#9AA3B2" FontSize="11" Margin="0,12,0,0" Text="Listo"/>
  </Grid>
</Window>
"@
#MARK2

$Reader = New-Object System.Xml.XmlNodeReader $Xaml
$Win = [Windows.Markup.XamlReader]::Load($Reader)
$BtnStart = $Win.FindName('BtnStart'); $BtnOpen = $Win.FindName('BtnOpen')
$BtnExit = $Win.FindName('BtnExit'); $Txt = $Win.FindName('TxtStatus')
$BtnDiag = $Win.FindName('BtnDiag'); $BtnCompat = $Win.FindName('BtnCompat')
$BtnHelp = $Win.FindName('BtnHelp'); $Bar = $Win.FindName('LblBar')
function Write-St($m) { $Txt.AppendText("$m`r`n"); $Txt.ScrollToEnd() }
function Refresh-St {
  $Txt.Clear()
  $t = Get-Target
  Write-St ("EXE: {0} ({1} bytes)" -f (Split-Path $t -Leaf), (Get-Item $t).Length)
  Write-St ("Admin: {0}" -f ($(if (Is-Admin) { 'SI' } else { 'NO (se pedira)' })))
  Write-St ("Windows: {0}" -f ($(if (${env:ProgramFiles(x86)}) { 'x64 (WOW64)' } else { 'x86' })))
  foreach ($f in @('apdadrv.dll','StrGene.dll')) {
    Write-St ("{0}: {1}" -f $f, ($(if (Test-Path (Join-Path $Base $f)) { 'OK' } else { 'FALTA (causa crash)' })))
  }
  $raw = [IO.File]::ReadAllBytes($t)
  $txt = [Text.Encoding]::ASCII.GetString($raw)
  Write-St ("Texto Opcion B: {0}" -f ($(if ($txt.Contains('Modos de ajuste')) { 'OK' } else { 'no aplicado' })))
  $c = ([regex]::Matches($txt,'2\.0\.0')).Count
  Write-St ("Version 2.0.0: {0} ({1} refs)" -f ($(if ($c -ge 4) { 'OK' } else { 'revisar' }), $c))
  Write-St ''; Write-St 'Conecte la impresora por USB 2.0 ANTES de elegir modelo.'
  $Bar.Text = "Listo  |  $((Split-Path $t -Leaf))  |  v2.0.0"
  $u = Test-UsbEpson
  if ($u.Usb -and $u.Prn) { $Bar.Text += ("  |  USB {0}" -f $u.Prn[0].PortName) }
  elseif ($u.Usb) { $Bar.Text += "  |  USB sin cola" } else { $Bar.Text += "  |  sin USB" }
}
function Set-Compat($t) {
  $k = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers'
  if (-not (Test-Path $k)) { New-Item $k -Force | Out-Null }
  Set-ItemProperty $k -Name $t -Value 'WIN7RTM HIGHDPIAWARE RUNASADMIN DISABLEDXMAXIMIZEDWINDOWEDMODE DISABLEFULLSCREENOPTIMIZATIONS DPIUNAWARE' -Force
  try { Unblock-File $t } catch {}
}
function Test-UsbEpson {
  $eps = Get-PnpDevice | Where-Object { $_.InstanceId -match 'VID_04B8' -and $_.Status -eq 'OK' }
  $pr = Get-Printer | Where-Object { $_.Name -match 'Epson|L1210|L3210|L3250|L3251|L3260|L5290' -and $_.PortName -match '^USB' }
  return @{ Usb=$eps; Prn=$pr }
}
function Launch {
  $t = Get-Target
  if (-not (Is-Admin)) {
    Write-St 'Solicitando administrador...'
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    return
  }
  Set-Compat $t
  $chk = Test-UsbEpson
  if (-not $chk.Usb) { Write-St 'AVISO: sin Epson USB VID_04B8. Conecta y enciende.'; if ([System.Windows.MessageBox]::Show('No veo Epson por USB. Conecta USB-B directo y enciende. Lanzar igual?','USB no detectada', 'YesNo','Warning') -ne 'Yes') { return } }
  elseif (-not $chk.Prn) { Write-St 'AVISO: Epson USB vista pero sin cola USB00x.' }
  else { Write-St (('Epson OK: {0} en {1}' -f $chk.Prn[0].Name, $chk.Prn[0].PortName)) }
  Write-St ("Lanzando {0} ..." -f (Split-Path $t -Leaf))
  Start-Process $t -WorkingDirectory $Base
}
$BtnStart.Add_Click({ Launch }); $BtnOpen.Add_Click({ Launch })
$BtnExit.Add_Click({ $Win.Close() })
$BtnDiag.Add_Click({ Refresh-St })
$BtnCompat.Add_Click({ Set-Compat (Get-Target); [System.Windows.MessageBox]::Show('Compatibilidad Win7RTM + DPI off aplicada.'); Refresh-St })
$BtnHelp.Add_Click({ [System.Windows.MessageBox]::Show("1. USB 2.0 conectado.`n2. Boton azul (pide admin).`n3. Select > modelo > Particular adjustment mode.") })
Refresh-St
[void]$Win.ShowDialog()
