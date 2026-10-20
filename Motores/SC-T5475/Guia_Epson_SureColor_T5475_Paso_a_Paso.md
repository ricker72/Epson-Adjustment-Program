# 🖨️ Guía Paso a Paso - EPSON SureColor T5475
### 🔧 Reseteo Vida Útil a 0 | USB + Modo Reparación + Driver + Admin
Versión 1.0 - Octubre 2026 - Español

> 🎯 En 4 pasos: 1) Conecta USB, 2) Modo Reparación,
> 3) Descarga Drivers, 4) Ejecuta T5475_Reset_Studio.exe como Admin, diagnostica y resetea a 0.

## 1️⃣ PASO 1 - Conectar por USB
1. Apaga impresora y PC.
2. Desconecta RED y desactiva WiFi (Panel > Red > Desactivar).
3. Conecta USB-B cuadrado atrás T5475 a USB trasero PC, sin hub.
4. Enciende impresora (espera 100%), luego PC.
5. Verifica en Dispositivos e impresoras: EPSON SC-T5475 Series.
## 2️⃣ PASO 2 - Modo Reparación
1. Apaga total (Power 3 seg, espera 10 seg).
2. Mantén [Home + Ayuda (?) + Power] 5-7 seg.
   Variante: [Atrás + Home + Power].
3. Al ver logo suelta Power, sigue Home+Ayuda 5 seg.
4. Pantalla muestra Service Mode. ¡Listo!
⚠️ No toques Clear All / Init EEPROM. Solo entra al modo,
el PROGRAMA hace el reset desde PC.

## 3️⃣ PASO 3 - Descargar Drivers
1. Ve a epson.com/Support, busca T5475 > Drivers Win10/11 64-bit.
2. Descarga Printer Driver SC-T5475 (obligatorio).
3. Instala con USB conectado: USB Directo > Finalizar.
4. Verifica puerto USB001/USB002 (NO WSD). Reinicia PC.

## 4️⃣ PASO 4 - Admin + Diagnóstico + Reset 0
1. Clic DERECHO en T5475_Reset_Studio.exe > Ejecutar como administrador.
2. SELECT: Model: **SC-T5475** (o T5470/T5475M). Port: **USB001** > OK.
3. PARTICULAR ADJUSTMENT MODE > Waste Ink / Maintenance Box > OK.
4. Marca 3 casillas + CHECK = diagnostica vida útil (ej. 100%).
5. Marca 3 casillas + INITIALIZE > OK > APAGA impresora 10-15 seg.
6. FINISH > Enciende normal. CHECK de nuevo = 0.00%. 🎉

✅ Verificación: imprime Nozzle Check + plano A1.
Cualquier duda contáctanos con modelo + Windows + foto error.
FIN - T5475 USB + Reparación + Driver + Admin + Reset 0%

