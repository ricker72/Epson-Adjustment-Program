import pefile, os
base=r'c:\Users\samatha\OneDrive\Desktop\L1210, L3210, L3250, L3251, L3260, L5290 RAW 1.0.1.1'
exe=os.path.join(base,'AdjProg.exe')
pe=pefile.PE(exe)
print("Machine=%s NumSec=%d TimeStamp=%s" % (hex(pe.FILE_HEADER.Machine), pe.FILE_HEADER.NumberOfSections, hex(pe.FILE_HEADER.TimeDateStamp)))
print("Magic=%s ImageBase=%s Subsystem=%d Entry=%s" % (hex(pe.OPTIONAL_HEADER.Magic), hex(pe.OPTIONAL_HEADER.ImageBase), pe.OPTIONAL_HEADER.Subsystem, hex(pe.OPTIONAL_HEADER.AddressOfEntryPoint)))
print("CLR RVA=%s Size=%d" % (hex(pe.OPTIONAL_HEADER.DATA_DIRECTORY[14].VirtualAddress), pe.OPTIONAL_HEADER.DATA_DIRECTORY[14].Size))
print("\n== SECTIONS ==")
for s in pe.sections:
    nm=s.Name.decode(errors='ignore').strip('\x00')
    print(nm, hex(s.VirtualAddress), "VSz=%d RawSz=%d Ent=%.2f" % (s.Misc_VirtualSize, s.SizeOfRawData, s.get_entropy()))
print("\n== IMPORTS ==")
for entry in pe.DIRECTORY_ENTRY_IMPORT:
    dll=entry.dll.decode(errors='ignore')
    funcs=[]
    for f in entry.imports[:40]:
        if f.name:
            funcs.append(f.name.decode(errors='ignore'))
        else:
            funcs.append("ord%d" % f.ordinal)
    print("%s (%d): %s" % (dll, len(entry.imports), ", ".join(funcs[:15])))
print("\n== RICH HEADER? ==")
try:
    print(pe.parse_rich_header())
except Exception as e:
    print("no rich / err:", e)
print("\n== UNICODE HITS ==")
data=open(exe,'rb').read()
u16=data.decode('utf-16le',errors='ignore')
for pat in ['Borland','Delphi','VCL','TForm','TButton','DVCLAL','PACKAGEINFO','Embarcadero','CodeGear','TApplication','Forms','Controls','StdCtrls']:
    print(pat, u16.count(pat))
print("\n== ASCII HITS ==")
asc=data.decode('latin1',errors='ignore')
for pat in ['Borland','Delphi','VCL','mscorlib','Microsoft Visual C','MFC','Qt5','Qt6','UPX','ASPack','Themida','Enigma','VMProtect','SEIKO','EPSON']:
    print(pat, asc.count(pat))
