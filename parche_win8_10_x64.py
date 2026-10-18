# Parche AdjProg para Win8/10/11 + x64 (WOW64). Copia a _Win10_x64ready.exe,
# sube OSVer/Subsys 4.0->6.0, activa LARGE_ADDRESS_AWARE y recalcula checksum.
# Uso: python parche_win8_10_x64.py [--check]
import os, sys, shutil
BASE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(BASE, "AdjProg.exe")
DST = os.path.join(BASE, "AdjProg_Win10_x64ready.exe")
MANIFEST = os.path.join(BASE, "AdjProg.exe.manifest")
LAA = 0x20
def diag(path):
    import pefile
    pe = pefile.PE(path); oh = pe.OPTIONAL_HEADER; fh = pe.FILE_HEADER
    print(f"== {os.path.basename(path)} ==")
    print(f" Machine=0x{fh.Machine:04X} Magic=0x{oh.Magic:03X}")
    print(f" OSVer={oh.MajorOperatingSystemVersion}.{oh.MinorOperatingSystemVersion} Subsys={oh.MajorSubsystemVersion}.{oh.MinorSubsystemVersion}")
    print(f" Char=0x{fh.Characteristics:04X} LAA={'SI' if fh.Characteristics & LAA else 'NO'} CheckSum=0x{oh.CheckSum:08X}")
    try:
        for et in pe.DIRECTORY_ENTRY_RESOURCE.entries:
            if et.id == 24:
                for e2 in et.directory.entries:
                    for e3 in e2.directory.entries:
                        off = pe.get_offset_from_rva(e3.data.struct.OffsetToData)
                        t = pe.__data__[off:off+e3.data.struct.Size].decode(errors="ignore")
                        print(f" manifest id={e2.id} size={e3.data.struct.Size} Win8={'4a2f28e3' in t} Win10={'8e0f7a12' in t}")
                        print(" ---manifest---"); print(t[:800])
    except Exception as e: print("(manifest?)", e)
    raw = open(path,"rb").read()
    print(f" GetVersionExA={raw.count(b'GetVersionExA')} GetVersion={raw.count(b'GetVersion')}")
def main():
    import pefile, struct
    if "--check" in sys.argv:
        diag(SRC)
        if os.path.exists(DST): diag(DST)
        return
    # Copia limpia (borra destino previo bloqueado por OneDrive)
    if os.path.exists(DST):
        try: os.remove(DST)
        except Exception: pass
    with open(SRC,"rb") as f: buf = bytearray(f.read())
    print(f"[1/3] Leido {len(buf)} bytes")
    e_lfanew = struct.unpack_from("<I", buf, 0x3C)[0]
    coff = e_lfanew + 4
    opt = coff + 20
    magic = struct.unpack_from("<H", buf, opt)[0]
    assert magic == 0x10B, f"Magic inesperado {hex(magic)}"
    ch = struct.unpack_from("<H", buf, coff+18)[0]
    print(f" Antes Char=0x{ch:04X} OSVer={buf[opt+40]}.{buf[opt+42]} Subsys={buf[opt+48]}.{buf[opt+50]}")
    # FILE_HEADER.Characteristics esta a coff+18 (Machine+0, NumSec+2, TimeStamp+4, PtrSym+8, NumSym+12, OptSize+16, Char+18)
    struct.pack_into("<H", buf, coff+18, ch | LAA); print(" + LAA activado (2GB->4GB en x64/WOW64)")
    # OPTIONAL PE32: MajorOS@opt+40(W), MinorOS@opt+42(W), MajorSub@opt+48(W), MinorSub@opt+50(W) -> 6.0
    struct.pack_into("<H", buf, opt+40, 6); struct.pack_into("<H", buf, opt+42, 0)
    struct.pack_into("<H", buf, opt+48, 6); struct.pack_into("<H", buf, opt+50, 0)
    # Checksum @opt+64 -> 0 temporal, calcular con pefile sobre buffer
    struct.pack_into("<I", buf, opt+64, 0)
    import tempfile
    tmp = DST + ".tmp"
    with open(tmp,"wb") as f: f.write(buf)
    pe2 = pefile.PE(tmp); cs = pe2.generate_checksum(); pe2.close()
    buf2 = bytearray(open(tmp,"rb").read())
    struct.pack_into("<I", buf2, opt+64, cs)
    # Reemplazo atomico
    if os.path.exists(DST):
        try: os.remove(DST)
        except Exception: pass
    with open(DST,"wb") as f: f.write(buf2)
    try: os.remove(tmp)
    except Exception: pass
    print(f"[2/3] Cabecera 4.0->6.0 + LAA (ASLR no tocado: binario sin relocs)")
    print(f"[3/3] CheckSum=0x{cs:08X}")
    print("IMPORTANTE: el manifest interno vacio anula el externo. Incrusta con:")
    print(f' mt.exe -manifest "{MANIFEST}" -outputresource:"{DST};1"')
    print("(Instala Windows SDK para tener mt.exe. Mientras usa el .bat)")
    diag(DST)
if __name__ == "__main__": main()
