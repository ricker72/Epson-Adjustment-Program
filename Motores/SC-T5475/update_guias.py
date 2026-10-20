# -*- coding: utf-8 -*-
import os

BASE = r"c:\Users\samatha\OneDrive\Desktop\L1210, L3210, L3250, L3251, L3260, L5290 RAW 1.0.1.1"
F = os.path.join(BASE, "Motores", "SC-T5475")

# ============ Guía Paso a Paso (TXT) ============
p = os.path.join(F, "Guia_Epson_SureColor_T5475_Paso_a_Paso.txt")
lines = open(p, encoding="utf-8").read().split("\n")

lines[8] = "4) Ejecutas T5475_Reset_Studio.exe (doble clic, Administrador) para diagnosticar VIDA UTIL y RESETEAR A 0."

for i, l in enumerate(lines):
    if "Nuestro programa T5475 + dlls" in l:
        lines[i] = "T5475_Reset_Studio.exe + sus DLLs en MISMA carpeta, desbloqueados."
    elif "Programa T5475 + dlls" in l:
        lines[i] = "T5475_Reset_Studio.exe + sus DLLs en MISMA carpeta."
    elif "sobre programa" in l and "Clic DERECHO" in l:
        lines[i] = l.replace("sobre programa", "sobre T5475_Reset_Studio.exe")
    elif "Model: SC-T5475 o T5475" in l and "Port" in l:
        lines[i] = "4. Marca SC-T5475 (o T5470/T5475M). Port: USB001."
    elif "Usa el programa T5475" in l and "carpeta" in l:
        lines[i] = "Usa T5475_Reset_Studio.exe (desbloqueado)."
    elif "Se cierra solo: usa .bat" in l:
        lines[i] = "Se cierra solo: da doble clic al .exe."
    elif "FIN - T5475 USB" in l:
        lines[i] = "FIN - T5475 USB + Modo Reparacion + Driver + Admin + Reset 0 (T5475_Reset_Studio.exe)"

open(p, "w", encoding="utf-8").write("\n".join(lines))
print("OK TXT")

# ============ Guía Paso a Paso (MD) ============
p = os.path.join(F, "Guia_Epson_SureColor_T5475_Paso_a_Paso.md")
t = open(p, encoding="utf-8").read()
t = t.replace("Ejecuta como Admin", "Ejecuta T5475_Reset_Studio.exe como Admin")
t = t.replace("nuestro programa T5475 + dlls juntos", "T5475_Reset_Studio.exe + sus DLLs juntos")
t = t.replace("Sirve AdjProg L1210/L5290? NO", "Sirve T5475_Reset_Studio.exe? SI")
t = t.replace("1. Clic DERECHO programa > Ejecutar como administrador.",
              "1. Clic DERECHO en T5475_Reset_Studio.exe > Ejecutar como administrador.")
t = t.replace("Model SC-T5475, Port USB001 > OK.",
              "Model: **SC-T5475** (o T5470/T5475M). Port: **USB001** > OK.")
t = t.replace("nuestro programa desde la PC", "nuestro programa (T5475_Reset_Studio.exe) desde la PC")
open(p, "w", encoding="utf-8").write(t)
print("OK MD P1")

# ============ Guía Profesional (MD) ============
p = os.path.join(F, "Guia_T5475_PROFESIONAL.md")
t = open(p, encoding="utf-8").read()

t = t.replace(
    "Si usas ese programa te dará `Communication error / Model mismatch`.",
    "Si usas L-series te dará `Communication error`."
)
t = t.replace("SCT5475_ServiceTool.exe", "T5475_Reset_Studio.exe")
t = t.replace("deja que **NUESTRO PROGRAMA desde la PC** haga el reset",
              "deja que **T5475_Reset_Studio.exe** haga el reset")
t = t.replace(
    "👑 <b>Nuestro programa T5475 + dlls juntos, desbloqueados</b>",
    "👑 <b>T5475_Reset_Studio.exe</b> (doble clic, Administrador)"
)
open(p, "w", encoding="utf-8").write(t)
print("OK MD PRO")

