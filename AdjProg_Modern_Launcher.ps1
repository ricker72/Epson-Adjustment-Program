# ============================================================
# EPSON Adjustment Program - Panel Moderno v2.1
# Launcher nivel B | @Ricker
# ============================================================
param([switch]$Elevated)

$ErrorActionPreference = 'SilentlyContinue'
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

$Base = Split-Path -Parent $MyInvocation.MyCommand.Path
$ExePar = Join-Path $Base 'AdjProg_Win10_x64ready.exe'
$ExeOri = Join-Path $Base 'AdjProg.exe'

# ------------------ Funciones de utilidad ------------------
function Get-Target {
    if (Test-Path $ExePar) { return $ExePar }
    return $ExeOri
}

function Is-Admin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-EpsonStatus {
    $eps = Get-PnpDevice | Where-Object { $_.InstanceId -match 'VID_04B8' }
    $okEps = $eps | Where-Object { $_.Status -eq 'OK' }
    $pr = Get-Printer | Where-Object { $_.Name -match 'Epson|L1210|L3210|L3250|L3251|L3260|L5290|ET-|L3|L5' -and $_.PortName -match '^USB' }
    $allPr = Get-Printer | Where-Object { $_.Name -match 'Epson|L1210|L3210|L3250|L3251|L3260|L5290' }

    return [PSCustomObject]@{
        HasUsbDevice   = [bool]$okEps
        UsbDevices     = $okEps
        HasUsbPrinter  = [bool]$pr
        PrintersUSB    = $pr
        AllEpsonPrinters = $allPr
        SuggestedModel = if ($pr) { ($pr[0].Name -replace 'EPSON ','' -replace ' Series','') } else { $null }
        PortName       = if ($pr) { $pr[0].PortName } else { $null }
    }
}

function Set-CompatFlags {
    param($Target)
    $k = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers'
    if (-not (Test-Path $k)) { New-Item $k -Force | Out-Null }
    $value = 'WIN7RTM HIGHDPIAWARE RUNASADMIN DISABLEDXMAXIMIZEDWINDOWEDMODE DISABLEFULLSCREENOPTIMIZATIONS DPIUNAWARE'
    Set-ItemProperty $k -Name $Target -Value $value -Force
    try { Unblock-File $Target } catch {}
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Level) {
        "OK"    { "#22C55E" }
        "WARN"  { "#F59E0B" }
        "ERROR" { "#EF4444" }
        default { "#94A3B8" }
    }
    $script:LogBox.AppendText("[$timestamp] $Message`r`n")
    $script:LogBox.ScrollToEnd()
}

# ------------------ XAML ------------------
[xml]$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="EPSON Adjustment Program  •  Panel Moderno v2.1  •  @Ricker"
        Width="980" Height="680" MinWidth="920" MinHeight="620"
        Background="#0F1115" WindowStartupLocation="CenterScreen"
        FontFamily="Segoe UI">

  <Window.Resources>
    <Style TargetType="Button" x:Key="PrimaryBtn">
      <Setter Property="Background" Value="#3B82F6"/>
      <Setter Property="Foreground" Value="White"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Padding" Value="14,10"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" CornerRadius="8" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
      <Style.Triggers>
        <Trigger Property="IsMouseOver" Value="True">
          <Setter Property="Background" Value="#2563EB"/>
        </Trigger>
      </Style.Triggers>
    </Style>

    <Style TargetType="Button" x:Key="SecondaryBtn">
      <Setter Property="Background" Value="#1E293B"/>
      <Setter Property="Foreground" Value="#E2E8F0"/>
      <Setter Property="Padding" Value="12,8"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" CornerRadius="8" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
      <Style.Triggers>
        <Trigger Property="IsMouseOver" Value="True">
          <Setter Property="Background" Value="#334155"/>
        </Trigger>
      </Style.Triggers>
    </Style>

    <Style TargetType="Border" x:Key="Card">
      <Setter Property="Background" Value="#1A1F2B"/>
      <Setter Property="CornerRadius" Value="12"/>
      <Setter Property="Padding" Value="18"/>
    </Style>
  </Window.Resources>

  <Grid Margin="20">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <!-- HEADER -->
    <DockPanel Grid.Row="0" Margin="0,0,0,16">
      <StackPanel>
        <TextBlock Text="EPSON Adjustment Program" FontSize="26" FontWeight="Bold" Foreground="#60A5FA"/>
        <TextBlock Text="Panel Moderno v2.1  •  L1210 · L3210 · L3250 · L3251 · L3260 · L5290  •  @Ricker" 
                   Foreground="#64748B" FontSize="13" Margin="0,2,0,0"/>
      </StackPanel>
      <StackPanel DockPanel.Dock="Right" Orientation="Horizontal" VerticalAlignment="Center">
        <Border x:Name="StatusBadge" Background="#1E293B" CornerRadius="20" Padding="12,6" Margin="0,0,10,0">
          <TextBlock x:Name="TxtStatusBadge" Text="●  Comprobando..." Foreground="#94A3B8" FontSize="12"/>
        </Border>
      </StackPanel>
    </DockPanel>

    <!-- MAIN CONTENT -->
    <Grid Grid.Row="1">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="1.1*"/>
        <ColumnDefinition Width="0.9*"/>
      </Grid.ColumnDefinitions>

      <!-- LEFT: Wizard + Actions -->
      <Border Grid.Column="0" Style="{StaticResource Card}" Margin="0,0,12,0">
        <Grid>
          <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
          </Grid.RowDefinitions>

          <TextBlock Text="Flujo recomendado" FontSize="16" FontWeight="SemiBold" Foreground="White" Margin="0,0,0,12"/>

          <!-- Steps -->
          <StackPanel Grid.Row="1">
            <Border Background="#0F172A" CornerRadius="10" Padding="14" Margin="0,0,0,10">
              <StackPanel>
                <DockPanel>
                  <Border Background="#3B82F6" Width="28" Height="28" CornerRadius="14" Margin="0,0,12,0">
                    <TextBlock Text="1" Foreground="White" HorizontalAlignment="Center" VerticalAlignment="Center" FontWeight="Bold"/>
                  </Border>
                  <StackPanel>
                    <TextBlock Text="Conectar y diagnosticar" Foreground="White" FontWeight="SemiBold"/>
                    <TextBlock Text="USB 2.0 directo + Doctor USB" Foreground="#94A3B8" FontSize="12"/>
                  </StackPanel>
                </DockPanel>
              </StackPanel>
            </Border>

            <Border Background="#0F172A" CornerRadius="10" Padding="14" Margin="0,0,0,10">
              <StackPanel>
                <DockPanel>
                  <Border Background="#334155" Width="28" Height="28" CornerRadius="14" Margin="0,0,12,0">
                    <TextBlock Text="2" Foreground="#CBD5E1" HorizontalAlignment="Center" VerticalAlignment="Center" FontWeight="Bold"/>
                  </Border>
                  <StackPanel>
                    <TextBlock Text="Lanzar Adjustment Program" Foreground="White" FontWeight="SemiBold"/>
                    <TextBlock Text="Motor original con compatibilidad aplicada" Foreground="#94A3B8" FontSize="12"/>
                  </StackPanel>
                </DockPanel>
              </StackPanel>
            </Border>

            <Border Background="#0F172A" CornerRadius="10" Padding="14" Margin="0,0,0,10">
              <StackPanel>
                <DockPanel>
                  <Border Background="#334155" Width="28" Height="28" CornerRadius="14" Margin="0,0,12,0">
                    <TextBlock Text="3" Foreground="#CBD5E1" HorizontalAlignment="Center" VerticalAlignment="Center" FontWeight="Bold"/>
                  </Border>
                  <StackPanel>
                    <TextBlock Text="Particular → Waste Ink Pad Counter" Foreground="White" FontWeight="SemiBold"/>
                    <TextBlock Text="Check → Initialize → Apagar impresora" Foreground="#94A3B8" FontSize="12"/>
                  </StackPanel>
                </DockPanel>
              </StackPanel>
            </Border>
          </StackPanel>

          <!-- Action Buttons -->
          <StackPanel Grid.Row="2" Margin="0,16,0,0">
            <Button x:Name="BtnDiagnose" Content="🔍  Diagnosticar USB ahora" Style="{StaticResource SecondaryBtn}" Margin="0,0,0,8"/>
            <Button x:Name="BtnLaunch" Content="🚀  Iniciar Adjustment Program" Style="{StaticResource PrimaryBtn}" Margin="0,0,0,8"/>
            <Button x:Name="BtnOpenFolder" Content="📂  Abrir carpeta del programa" Style="{StaticResource SecondaryBtn}" Margin="0,0,0,8"/>
            <Button x:Name="BtnHelp" Content="❓  Ayuda rápida" Style="{StaticResource SecondaryBtn}"/>
          </StackPanel>
        </Grid>
      </Border>

      <!-- RIGHT: Status + Log -->
      <Border Grid.Column="1" Style="{StaticResource Card}">
        <Grid>
          <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
          </Grid.RowDefinitions>

          <TextBlock Text="Estado del sistema" FontSize="16" FontWeight="SemiBold" Foreground="White" Margin="0,0,0,12"/>

          <!-- Status Cards -->
          <StackPanel Grid.Row="1" Margin="0,0,0,14">
            <Border Background="#0F172A" CornerRadius="8" Padding="12" Margin="0,0,0,8">
              <DockPanel>
                <TextBlock Text="Impresora USB" Foreground="#94A3B8" FontSize="12"/>
                <TextBlock x:Name="TxtPrinter" Text="—" Foreground="White" FontWeight="SemiBold" HorizontalAlignment="Right"/>
              </DockPanel>
            </Border>
            <Border Background="#0F172A" CornerRadius="8" Padding="12" Margin="0,0,0,8">
              <DockPanel>
                <TextBlock Text="Puerto" Foreground="#94A3B8" FontSize="12"/>
                <TextBlock x:Name="TxtPort" Text="—" Foreground="White" FontWeight="SemiBold" HorizontalAlignment="Right"/>
              </DockPanel>
            </Border>
            <Border Background="#0F172A" CornerRadius="8" Padding="12" Margin="0,0,0,8">
              <DockPanel>
                <TextBlock Text="Motor" Foreground="#94A3B8" FontSize="12"/>
                <TextBlock x:Name="TxtEngine" Text="—" Foreground="White" FontWeight="SemiBold" HorizontalAlignment="Right"/>
              </DockPanel>
            </Border>
            <Border Background="#0F172A" CornerRadius="8" Padding="12">
              <DockPanel>
                <TextBlock Text="Administrador" Foreground="#94A3B8" FontSize="12"/>
                <TextBlock x:Name="TxtAdmin" Text="—" Foreground="White" FontWeight="SemiBold" HorizontalAlignment="Right"/>
              </DockPanel>
            </Border>
          </StackPanel>

          <!-- Log -->
          <Grid Grid.Row="2">
            <Grid.RowDefinitions>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <TextBlock Text="Registro" Foreground="#94A3B8" FontSize="12" Margin="0,0,0,6"/>
            <TextBox x:Name="LogBox" Grid.Row="1"
                     Background="#0B0E14" Foreground="#CBD5E1"
                     FontFamily="Consolas" FontSize="12"
                     IsReadOnly="True" TextWrapping="Wrap"
                     VerticalScrollBarVisibility="Auto"
                     BorderThickness="0" Padding="10"/>
          </Grid>
        </Grid>
      </Border>
    </Grid>

    <!-- FOOTER -->
    <DockPanel Grid.Row="2" Margin="0,14,0,0">
      <TextBlock x:Name="TxtFooter" Text="Listo" Foreground="#64748B" FontSize="12" VerticalAlignment="Center"/>
      <Button x:Name="BtnExit" Content="Salir" Style="{StaticResource SecondaryBtn}" 
              DockPanel.Dock="Right" Padding="16,8" Margin="10,0,0,0"/>
    </DockPanel>
  </Grid>
</Window>
"@

# ------------------ Cargar UI ------------------
$Reader = New-Object System.Xml.XmlNodeReader $Xaml
$Win = [Windows.Markup.XamlReader]::Load($Reader)

# Controles
$BtnDiagnose   = $Win.FindName('BtnDiagnose')
$BtnLaunch     = $Win.FindName('BtnLaunch')
$BtnOpenFolder = $Win.FindName('BtnOpenFolder')
$BtnHelp       = $Win.FindName('BtnHelp')
$BtnExit       = $Win.FindName('BtnExit')
$LogBox        = $Win.FindName('LogBox')
$TxtPrinter    = $Win.FindName('TxtPrinter')
$TxtPort       = $Win.FindName('TxtPort')
$TxtEngine     = $Win.FindName('TxtEngine')
$TxtAdmin      = $Win.FindName('TxtAdmin')
$TxtStatusBadge= $Win.FindName('TxtStatusBadge')
$StatusBadge   = $Win.FindName('StatusBadge')
$TxtFooter     = $Win.FindName('TxtFooter')

# ------------------ Lógica ------------------
function Refresh-UI {
    $status = Get-EpsonStatus
    $target = Get-Target

    $TxtEngine.Text = Split-Path $target -Leaf
    $TxtAdmin.Text  = if (Is-Admin) { "Sí" } else { "No (se pedirá)" }

    if ($status.HasUsbPrinter) {
        $TxtPrinter.Text = $status.PrintersUSB[0].Name
        $TxtPort.Text    = $status.PortName
        $TxtStatusBadge.Text = "●  Listo"
        $TxtStatusBadge.Foreground = "#22C55E"
        $StatusBadge.Background = "#14532D"
        Write-Log "Impresora detectada: $($status.PrintersUSB[0].Name) en $($status.PortName)" "OK"
    }
    elseif ($status.HasUsbDevice) {
        $TxtPrinter.Text = "Epson USB detectada (sin cola)"
        $TxtPort.Text    = "—"
        $TxtStatusBadge.Text = "●  USB sin cola"
        $TxtStatusBadge.Foreground = "#F59E0B"
        $StatusBadge.Background = "#422006"
        Write-Log "Epson USB presente pero no hay cola de impresión USB00x" "WARN"
    }
    else {
        $TxtPrinter.Text = "No detectada"
        $TxtPort.Text    = "—"
        $TxtStatusBadge.Text = "●  Sin USB"
        $TxtStatusBadge.Foreground = "#EF4444"
        $StatusBadge.Background = "#450A0A"
        Write-Log "No se detectó impresora Epson por USB (VID_04B8)" "ERROR"
    }

    $TxtFooter.Text = "v2.1  |  $(Split-Path $target -Leaf)  |  $(Get-Date -Format 'HH:mm')"
}

function Do-Diagnose {
    Write-Log "Ejecutando diagnóstico USB..." "INFO"
    $status = Get-EpsonStatus

    if ($status.HasUsbDevice) {
        Write-Log "Dispositivo USB Epson (VID_04B8) encontrado" "OK"
        foreach ($d in $status.UsbDevices) {
            Write-Log "  → $($d.FriendlyName)" "INFO"
        }
    } else {
        Write-Log "No hay dispositivo USB Epson. Conecta cable USB-B directo y enciende la impresora." "ERROR"
    }

    if ($status.HasUsbPrinter) {
        Write-Log "Cola de impresión correcta: $($status.PortName)" "OK"
    } else {
        Write-Log "No hay impresora en puerto USB00x. Si usas WiFi/WSD el reset no funcionará." "WARN"
    }

    # Aplicar fixes rápidos
    $target = Get-Target
    Set-CompatFlags $target
    Write-Log "Compatibilidad WIN7RTM + DPI aplicada" "OK"

    try {
        powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 | Out-Null
        powercfg /SETDCVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 | Out-Null
        Write-Log "Suspensión selectiva USB desactivada" "OK"
    } catch {}

    Refresh-UI
}

function Do-Launch {
    $target = Get-Target

    if (-not (Is-Admin)) {
        Write-Log "Solicitando privilegios de administrador..." "WARN"
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`" -Elevated" -Verb RunAs
        return
    }

    $status = Get-EpsonStatus
    if (-not $status.HasUsbDevice) {
        $r = [System.Windows.MessageBox]::Show(
            "No se detecta ninguna impresora Epson por USB.`n`n¿Quieres lanzar el programa de todas formas?",
            "USB no detectado",
            "YesNo",
            "Warning"
        )
        if ($r -ne "Yes") { return }
    }

    Set-CompatFlags $target
    Write-Log "Lanzando $(Split-Path $target -Leaf)..." "INFO"

    try {
        Start-Process $target -WorkingDirectory $Base
        Write-Log "Motor original iniciado correctamente" "OK"
        Write-Log "→ En el programa: Select → tu modelo → Particular Adjustment Mode → Waste Ink Pad Counter" "INFO"
    }
    catch {
        Write-Log "Error al lanzar: $_" "ERROR"
    }
}

# Eventos
$BtnDiagnose.Add_Click({ Do-Diagnose })
$BtnLaunch.Add_Click({ Do-Launch })
$BtnOpenFolder.Add_Click({ Start-Process explorer.exe $Base })
$BtnHelp.Add_Click({
    [System.Windows.MessageBox]::Show(
@"
Flujo recomendado:

1. Conecta la impresora con cable USB-B corto a un puerto USB 2.0 (negro).
2. Pulsa "Diagnosticar USB ahora".
3. Pulsa "Iniciar Adjustment Program".
4. En la ventana antigua:
   - Select → elige tu modelo → OK
   - Particular Adjustment Mode
   - Waste Ink Pad Counter
   - Marca las 3 casillas → Check
   - Initialize → apaga la impresora → Finish

El panel moderno solo mejora la experiencia. El motor de reset sigue siendo el oficial de Epson.
"@, "Ayuda rápida", "OK", "Information")
})
$BtnExit.Add_Click({ $Win.Close() })

# Inicio
Write-Log "Panel Moderno v2.1 iniciado" "INFO"
Write-Log "Motor: $(Split-Path (Get-Target) -Leaf)" "INFO"
Refresh-UI

[void]$Win.ShowDialog()