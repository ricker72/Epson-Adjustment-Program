# Firmar-Setup.ps1 - autofirma local para quitar SmartScreen en TUS PCs (no valida en otros sin instalar cert)
# Para distribucion real compra certificado Authenticode. Uso: powershell -File Firmar-Setup.ps1 [-InstalarCert]
param([switch]$InstalarCert)
$ErrorActionPreference = 'Stop'
$Base = Split-Path -Parent $MyInvocation.MyCommand.Path
$cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -eq 'CN=EpsonReset Local, OU=@Ricker' } | Select-Object -First 1
if (!$cert) {
  Write-Host "Creando certificado autofirmado local..."
  $cert = New-SelfSignedCertificate -Type CodeSigningCert -Subject "CN=EpsonReset Local, OU=@Ricker" -CertStoreLocation Cert:\CurrentUser\My -NotAfter (Get-Date).AddYears(5) -KeyUsage DigitalSignature -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3")
}
Write-Host ("Cert: {0} exp {1}" -f $cert.Thumbprint, $cert.NotAfter)
if ($InstalarCert) {
  $store = New-Object Security.Cryptography.X509Certificates.X509Store("TrustedPublisher","CurrentUser"); $store.Open("ReadWrite"); $store.Add($cert); $store.Close()
  $store2 = New-Object Security.Cryptography.X509Certificates.X509Store("Root","CurrentUser"); $store2.Open("ReadWrite"); $store2.Add($cert); $store2.Close()
  Write-Host "Cert instalado en TrustedPublisher + Root (solo este PC)."
}
foreach ($f in @('AdjProg_Win10_x64ready.exe','AdjProg.exe','Doctor-USB.bat')) {
  $p = Join-Path $Base $f
  if (!(Test-Path $p)) { continue }
  if ($p -match '\.exe$') { Set-AuthenticodeSignature $p $cert -TimestampServer "http://timestamp.digicert.com" | Select-Object Status, Path | Format-List | Out-String | Write-Host }
}
Write-Host "NOTA: autofirma NO quita SmartScreen en PCs ajenos. Para eso: signtool sign /fd SHA256 /a setup.exe con cert de pago."
