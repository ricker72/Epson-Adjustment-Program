import os
f = 'AdjProg.exe'
path = os.path.basename(f)
print('File: AdjProg.exe')
print('Size: 3977216 bytes')
print('LastWrite: 17/01/2024 12:16:18')
print()

header = bytearray(65536)
with open(f, 'rb') as fs:
    fs.readinto(header)

print('=== DOS Header ===')
print('Signature: 0x' + format(header[0], '02X') + format(header[1], '02X'))
e_lfanew = int.from_bytes(header[0x3C:0x40], 'little')
print('e_lfanew (PE offset): 0x' + format(e_lfanew, '08X'))

print()
print('=== PE Header ===')
pe_sig = format(header[e_lfanew], '02X') + format(header[e_lfanew+1], '02X') + format(header[e_lfanew+2], '02X') + format(header[e_lfanew+3], '02X')
print('PE Signature: ' + pe_sig)

header_pos = e_lfanew + 4
num_sections = int.from_bytes(header[header_pos+2:header_pos+4], 'little')
time_date_stamp = int.from_bytes(header[header_pos+8:header_pos+12], 'little')
size_of_optional_header = int.from_bytes(header[header_pos+0x14:header_pos+0x16], 'little')

print('=== COFF File Header ===')
machine = int.from_bytes(header[header_pos+4:header_pos+6], 'little')
print('Machine: 0x' + format(machine, '04X'))
if machine == 0x014C:
    print('  => PE32 (x86, 32-bit)')
elif machine == 0x8664:
    print('  => PE32+ (x86-64, 64-bit)')
else:
    print('  => Unknown architecture')
print('Number of Sections: ' + str(num_sections))
print('TimeDateStamp: 0x' + format(time_date_stamp, '08X'))

opt_off = header_pos + 0x18
if size_of_optional_header > 0:
    print()
    print('=== Optional Header ===')
    opt_magic = int.from_bytes(header[opt_off:opt_off+2], 'little')
    print('Magic: 0x' + format(opt_magic, '04X'))
    if opt_magic == 0x10B:
        print('  => PE32 (32-bit)')
    elif opt_magic == 0x20B:
        print('  => PE32+ (64-bit)')
    
    sub_system = int.from_bytes(header[opt_off+0x0E:opt_off+0x10], 'little')
    print('SubSystem: ' + str(sub_system))
    if sub_system == 2:
        print('  => WINDOWS (GUI)')
    elif sub_system == 3:
        print('  => CONSOLE (CUI)')
    
    image_base = int.from_bytes(header[opt_off+0x18:opt_off+0x20], 'little')
    print('ImageBase: 0x' + format(image_base, '016X'))
    section_align = int.from_bytes(header[opt_off+0x20:opt_off+0x24], 'little')
    print('SectionAlignment: 0x' + format(section_align, '08X'))
    file_align = int.from_bytes(header[opt_off+0x28:opt_off+0x2C], 'little')
    print('FileAlignment: 0x' + format(file_align, '08X'))
    
    size_image = int.from_bytes(header[opt_off+0x38:opt_off+0x3C], 'little')
    print('SizeOfImage: 0x' + format(size_image, '08X'))
    size_headers = int.from_bytes(header[opt_off+0x3C:opt_off+0x40], 'little')
    print('SizeOfHeaders: 0x' + format(size_headers, '08X'))
    
    clr_header = int.from_bytes(header[opt_off+0x58:opt_off+0x5C], 'little')
    print('CLR Runtime Header: 0x' + format(clr_header, '08X'))
    if clr_header != 0:
        if 0x1000 <= clr_header < 0x100000:
            print('  => This is a .NET assembly! (CLR header present)')

print()
print('=== .NET Check ===')
dot_net_magic = int.from_bytes(header[0x3C:0x40], 'little')
dot_net_off = 0x3C + dot_net_magic
if dot_net_off == 0x100:
    clr_value = int.from_bytes(header[dot_net_off:dot_net_off+4], 'little')
    clr_sig = format(header[dot_net_off], '02X') + format(header[dot_net_off+1], '02X') + format(header[dot_net_off+2], '02X') + format(header[dot_net_off+3], '02X')
    print('CLR header signature at 0x' + format(dot_net_off, '04X') + ': ' + clr_sig)
    if clr_sig == '424A5342':
        print('  => .NET CLR header BSJB found!')
    else:
        print('  => Not a .NET CLR header (native executable)')

print()
print('Analysis complete.')
