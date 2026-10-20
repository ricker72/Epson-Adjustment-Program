import pefile, os
base = r'c:\Users\samatha\OneDrive\Desktop\L1210, L3210, L3250, L3251, L3260, L5290 RAW 1.0.1.1'
for name in ['AdjProg.exe','AdjProg_Win10_x64ready.exe','apdadrv.dll','StrGene.dll']:
    p = os.path.join(base, name)
    if not os.path.exists(p):
        print(name, 'NO EXISTE'); continue
    pe = pefile.PE(p)
    fh = pe.FILE_HEADER; oh = pe.OPTIONAL_HEADER
    print(f"== {name} ==")
    print(f" Machine=0x{fh.Machine:04X} Char=0x{fh.Characteristics:04X} LAA={'SI' if fh.Characteristics & 0x20 else 'NO'} DynBase={'SI' if fh.Characteristics & 0x40 else 'NO'}")
    print(f" Magic=0x{oh.Magic:03X} OSVer={oh.MajorOperatingSystemVersion}.{oh.MinorOperatingSystemVersion} Subsys={oh.MajorSubsystemVersion}.{oh.MinorSubsystemVersion} Subsystem={oh.Subsystem} CheckSum=0x{oh.CheckSum:08X}")
    print(f" CLR RVA=0x{oh.DATA_DIRECTORY[14].VirtualAddress:X} Size={oh.DATA_DIRECTORY[14].Size}")
    if hasattr(pe, 'DIRECTORY_ENTRY_RESOURCE'):
        for et in pe.DIRECTORY_ENTRY_RESOURCE.entries:
            if et.id == 24:
                print(f" RT_MANIFEST count={len(et.directory.entries)}")
                for e2 in et.directory.entries:
                    for e3 in e2.directory.entries:
                        off = pe.get_offset_from_rva(e3.data.struct.OffsetToData)
                        sz = e3.data.struct.Size
                        t = pe.__data__[off:off+sz].decode(errors='ignore')
                        print(f"  id={e2.id} lang={e3.id} size={sz} Win8={'4a2f28e3' in t} Win10={'8e0f7a12' in t} requireAdmin={'requireAdministrator' in t}")
                        print("  ---head---"); print(t[:600].replace('\n',' | '))
    else:
        print(" sin DIRECTORY_ENTRY_RESOURCE")
    raw = open(p,'rb').read()
    print(f" GetVersionExA={raw.count(b'GetVersionExA')} GetVersion={raw.count(b'GetVersion')} SetupDi={raw.count(b'SetupDi')} USB={raw.count(b'USB')} Epson={raw.count(b'EPSON')}")
    print()
