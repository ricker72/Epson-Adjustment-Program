import pefile, os, re
base=r'c:\Users\samatha\OneDrive\Desktop\L1210, L3210, L3250, L3251, L3260, L5290 RAW 1.0.1.1'
exe=os.path.join(base,'AdjProg.exe')
pe=pefile.PE(exe)
print("== RESOURCE TYPES ==")
if hasattr(pe,'DIRECTORY_ENTRY_RESOURCE'):
    for et in pe.DIRECTORY_ENTRY_RESOURCE.entries:
        tname=str(et.name) if et.name else str(et.id)
        print("Type id=%s name=%s count=%d" % (et.id, tname, len(et.directory.entries)))
        for e2 in et.directory.entries[:20]:
            lang_info=[]
            if hasattr(e2,'directory'):
                for e3 in e2.directory.entries:
                    lang_info.append("lang=%s size=%d rva=%s" % (e3.id, e3.data.struct.Size, hex(e3.data.struct.OffsetToData)))
            print("   entry id=%s name=%s -> %s" % (e2.id, e2.name, "; ".join(lang_info[:4])))
else:
    print("sin recursos")
import datetime
ts=pe.FILE_HEADER.TimeDateStamp
print("\nTimeStamp %s UTC = %s" % (hex(ts), datetime.datetime.utcfromtimestamp(ts)))
# dump interesting ascii strings
data=open(exe,'rb').read()
texts=re.findall(rb'[\x20-\x7E]{6,}', data)
uniq=[]
seen=set()
keywords=[b'Waste',b'EEPROM',b'Model',b'Ink',b'Head',b'Cleaning',b'Counter',b'Reset',b'Adjustment',b'Port',b'USB',b'Error',b'Password',b'Key',b'SelectModel']
print("\n== STRINGS INTERESANTES (%d totales ascii>=6) ==" % len(texts))
outs=[]
for t in texts:
    s=t.decode(errors='ignore')
    if any(k.decode() in s for k in [b'Waste',b'EEPROM',b'Model',b'Ink charge',b'Head ID',b'Cleaning',b'Counter',b'Adjustment',b'EPSON Adjustment']):
        if s not in seen:
            seen.add(s)
            outs.append(s)
for s in outs[:200]:
    print(s)
open(os.path.join(base,'strings_interesantes.txt'),'w',encoding='utf-8').write("\n".join(outs))
print("\nGuardado strings_interesantes.txt con %d lineas" % len(outs))
