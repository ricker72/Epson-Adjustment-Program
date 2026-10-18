# Reaplica texto Opcion B (167 chars) en ambos EXE. Seguro: mismo tamano.
import os
BASE = os.path.dirname(os.path.abspath(__file__))
NEW = b"Modos de ajuste para mantenimiento del dispositivo. Siga el orden correcto tras seleccionar piezas de repuesto o reparadas. Multi-seleccion posible. Win 11 Por @Ricker"
OLD = b"SOMOS CIRUJANO"
assert len(NEW) <= 211, len(NEW)
for f in ["AdjProg.exe", "AdjProg_Win10_x64ready.exe"]:
    p = os.path.join(BASE, f)
    if not os.path.exists(p): continue
    d = bytearray(open(p, "rb").read())
    s = d.find(OLD)
    if s == -1:
        print(f, "ya parcheado o no encontrado")
        continue
    e = d.find(b"You can select particular")
    assert e - s == 212, e - s
    repl = NEW + b"\x00" + b"\x00" * (212 - len(NEW) - 1)
    d[s:e] = repl
    open(p, "wb").write(d)
    print(f, "OK")
