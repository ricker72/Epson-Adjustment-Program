; Epson Reset L1210-L5290 v2.0.0 - Instalador Win8/8.1/10/11 x86/x64 (WOW64)
; Requiere Inno Setup 6. Compilar: iscc EpsonReset.iss
#define MyAppName "EPSON Adjustment Program - L1210 L3210 L3250 L3251 L3260 L5290"
#define MyAppVersion "2.0.0"
#define MyPublisher "@Ricker"
[Setup]
AppId={{3A8B1C2D-EpsonReset-L1210-L5290-v200}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyPublisher}
DefaultDirName={pf32}\EpsonReset-L1210-L5290
DefaultGroupName=Epson Reset
OutputBaseFilename=EpsonReset-L1210-L5290-v2.0.0-Setup
Compression=lzma2/max
SolidCompression=yes
ArchitecturesAllowed=x86 x64 arm64
ArchitecturesInstallIn64BitMode=x64 arm64
PrivilegesRequired=admin
MinVersion=6.2
UninstallDisplayName={#MyAppName} v{#MyAppVersion}
VersionInfoVersion=2.0.0.0
VersionInfoCompany=SEIKO EPSON + @Ricker launcher
VersionInfoDescription=Adjustment Program Waste Ink Pad Reset USB
VersionInfoCopyright=Uso tecnico. Solo USB directo.
WizardStyle=modern
DisableProgramGroupPage=yes
[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
[Files]
Source: "AdjProg_Win10_x64ready.exe"; DestDir: "{app}"; Flags: ignoreversion; AfterInstall: SetCompat('{app}\AdjProg_Win10_x64ready.exe')
Source: "AdjProg.exe"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "apdadrv.dll"; DestDir: "{app}"; Flags: ignoreversion regserver noregerror
Source: "StrGene.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "AdjProg_Modern_Launcher.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "Doctor-USB.ps1"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "MANUAL_EPSON_RESET.md"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
[Icons]
Name: "{group}\Epson Reset - Panel Moderno"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\AdjProg_Modern_Launcher.ps1"""; WorkingDir: "{app}"; IconFilename: "{app}\AdjProg_Win10_x64ready.exe"
Name: "{group}\Epson Reset - Doctor USB"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Doctor-USB.ps1"""; WorkingDir: "{app}"
Name: "{group}\Epson Reset - AdjProg directo (admin)"; Filename: "{app}\AdjProg_Win10_x64ready.exe"; WorkingDir: "{app}"
Name: "{commondesktop}\Epson Reset L1210-L5290"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\AdjProg_Modern_Launcher.ps1"""; WorkingDir: "{app}"; Tasks: desktopicon
[Tasks]
Name: desktopicon; Description: "Crear icono en escritorio"; GroupDescription: "Accesos:"
[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"; ValueType: string; ValueName: "{app}\AdjProg_Win10_x64ready.exe"; ValueData: "WIN7RTM HIGHDPIAWARE RUNASADMIN DISABLEDXMAXIMIZEDWINDOWEDMODE DISABLEFULLSCREENOPTIMIZATIONS DPIUNAWARE"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\EpsonReset"; ValueType: string; ValueName: "Version"; ValueData: "2.0.0"; Flags: uninsdeletekey
[Run]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -Command ""Get-ChildItem '{app}\AdjProg*.exe','{app}\*.dll' | Unblock-File -ErrorAction SilentlyContinue"""; Flags: runhidden; StatusMsg: "Desbloqueando archivos..."
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Doctor-USB.ps1"" -Quick"; Flags: postinstall skipifsourcedoesntexist runascurrentuser; Description: "Ejecutar Doctor USB ahora"; StatusMsg: "Diagnosticando USB..."
[UninstallDelete]
Type: files; Name: "{app}\*.log"
[Code]
procedure SetCompat(Path: String);
var
  K: String;
begin
  K := 'Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers';
  RegWriteStringValue(HKCU, K, Path, 'WIN7RTM HIGHDPIAWARE RUNASADMIN DISABLEDXMAXIMIZEDWINDOWEDMODE DISABLEFULLSCREENOPTIMIZATIONS DPIUNAWARE');
end;
function IsSecureBoot(): Boolean;
begin
  Result := False;
  try
    Result := RegValueExists(HKLM, 'SYSTEM\CurrentControlSet\Control\SecureBoot\State', 'UEFISecureBootEnabled');
  except
  end;
end;
function InitializeSetup(): Boolean;
begin
  Result := True;
  if IsSecureBoot then
    MsgBox('Secure Boot activo: el driver USB firmado es obligatorio.'#13#10'Usa solo cable USB-B directo a puerto USB 2.0 trasero, sin hub.', mbInformation, MB_OK);
end;
