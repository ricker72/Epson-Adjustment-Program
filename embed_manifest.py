# Incrusta AdjProg.exe.manifest (RT_MANIFEST ID=1) en AdjProg_Win10_x64ready.exe
# via UpdateResourceW - sin mt.exe / SDK. + recalcula checksum. Uso: python embed_manifest.py
import os, sys, ctypes
from ctypes import wintypes
BASE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(BASE, "AdjProg_Win10_x64ready.exe")
MANIFEST = os.path.join(BASE, "AdjProg.exe.manifest")
kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
BeginUpdate = kernel32.BeginUpdateResourceW; BeginUpdate.argtypes=[wintypes.LPCWSTR,wintypes.BOOL]; BeginUpdate.restype=wintypes.HANDLE
UpdateRes = kernel32.UpdateResourceW; UpdateRes.argtypes=[wintypes.HANDLE,ctypes.c_void_p,ctypes.c_void_p,wintypes.WORD,ctypes.c_void_p,wintypes.DWORD]; UpdateRes.restype=wintypes.BOOL
EndUpdate = kernel32.EndUpdateResourceW; EndUpdate.argtypes=[wintypes.HANDLE,wintypes.BOOL]; EndUpdate.restype=wintypes.BOOL
RT_MANIFEST = 24
def main():
    assert os.path.exists(SRC), f"no existe {SRC} - corre parche_win8_10_x64.py primero"
    assert os.path.exists(MANIFEST), f"no existe {MANIFEST}"
    data = open(MANIFEST,'rb').read()
    print(f"[1/3] manifest {len(data)} bytes")
    h = BeginUpdate(SRC, False)
    if not h: print("BeginUpdate fallo", ctypes.get_last_error()); sys.exit(1)
    buf = ctypes.create_string_buffer(data)
    ok = UpdateRes(h, ctypes.c_void_p(RT_MANIFEST), ctypes.c_void_p(1), 1033, buf, len(data))
    if not ok: print("UpdateResource fallo", ctypes.get_last_error()); EndUpdate(h, True); sys.exit(1)
    if not EndUpdate(h, False): print("EndUpdate fallo", ctypes.get_last_error()); sys.exit(1)
    print("[2/3] manifest incrustado ID=1 lang=1033")
    import pefile
    pe = pefile.PE(SRC); cs = pe.generate_checksum(); pe.close()
    import struct
    with open(SRC,'r+b') as f:
        buf2 = bytearray(f.read())
        e_lfanew = struct.unpack_from("<I", buf2, 0x3C)[0]
        opt = e_lfanew + 4 + 20
        struct.pack_into("<I", buf2, opt+64, cs)
        f.seek(0); f.write(buf2)
    print(f"[3/3] CheckSum=0x{cs:08X}")
    print("OK - verifica con: python check_pe_full.py")
if __name__ == "__main__": main()
