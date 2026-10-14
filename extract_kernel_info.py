#!/usr/bin/env python3
"""Extract kernel metadata from uploaded images."""
import struct
import sys

def parse_android_bootimg(path):
    """Parse Android boot image to find kernel partition."""
    with open(path, 'rb') as f:
        data = f.read()
    
    if len(data) < 64 or data[:4] != b'ANDROID!':
        return None
    
    kernel_offset = struct.unpack('<I', data[8:12])[0]
    kernel_size = struct.unpack('<I', data[12:16])[0]
    
    if kernel_offset == 0 or kernel_size == 0:
        return None
    
    kernel_data = data[kernel_offset:kernel_offset+kernel_size]
    
    if len(kernel_data) < 8 or kernel_data[:4] != b'UNCOMPRESSED_IMG':
        return None
    
    return {
        'offset': kernel_offset,
        'size': kernel_size,
        'data': kernel_data
    }

def parse_xbl_config(path):
    """Parse xbl_config ELF for cmdline and symbols."""
    with open(path, 'rb') as f:
        data = f.read()
    
    if len(data) < 52 or data[:4] != b'\x7fELF':
        return None
    
    ei_class = data[4]
    if ei_class != 2:
        return None
    
    # Parse ELF headers to find cmdline section
    e_shoff = struct.unpack('<Q', data[48+0x1c:48+0x20])[0]
    e_shentsize = struct.unpack('<H', data[48+0x2e:48+0x30])[0]
    e_shnum = struct.unpack('<H', data[48+0x30:48+0x32])[0]
    
    if e_shoff == 0 or e_shnum == 0:
        return None
    
    # Find .cmdline section
    for i in range(e_shnum):
        shoff = e_shoff + (i * e_shentsize)
        if shoff + 24 > len(data):
            break
        
        sh_type = struct.unpack('<H', data[shoff+8:shoff+10])[0]
        sh_offset = struct.unpack('<Q', data[shoff+0x10:shoff+0x18])[0]
        sh_size = struct.unpack('<Q', data[shoff+0x18:shoff+0x20])[0]
        
        if sh_type == 7 and 0 < sh_size <= 512 and sh_offset >= 0:
            cmdline_data = data[sh_offset:min(sh_offset+sh_size, len(data))]
            return {
                'cmdline': cmdline_data.decode('utf-8', errors='ignore').strip(),
                'section_idx': i
            }
    
    return None

def analyze_steady_bin(path):
    """Basic analysis of steady.bin vendor blob."""
    try:
        with open(path, 'rb') as f:
            data = f.read(4096)
        
        magic = data[:8].lower().hex()
        return {
            'size': len(data),
            'magic': magic,
            'first_bytes': data[:16].hex()
        }
    except Exception as e:
        return {'error': str(e)}

print("=" * 70)
print(" GHOSTLOCK KERNEL IMAGE ANALYSIS")
print("=" * 70)

kernel_info = parse_android_bootimg('boot.img')
xbl_info = parse_xbl_config('xbl_config.img')
steady_info = analyze_steady_bin('steady.bin')

print(f"\n[1] boot.img Analysis")
if kernel_info:
    print(f"   ✅ Found uncompressed kernel at offset 0x{kernel_info['offset']:X}")
    print(f"   Size: {kernel_info['size']:,} bytes ({kernel_info['size']/1024:.2f} KB)")
else:
    print(f"   ⚠️  Could not parse boot.img")

print(f"\n[2] xbl_config.img Analysis")
if xbl_info:
    print(f"   ✅ Found .cmdline section")
    cmdline = xbl_info['cmdline']
    print(f"   Content ({len(cmdline)} chars):")
    
    # Parse kernel parameters
    params = {}
    for part in cmdline.split():
        if '=' in part:
            key, val = part.split('=', 1)
            params[key] = val
    
    relevant = {k: v for k, v in params.items() if any(x in k.lower() for x in ['kernel', 'androidboot', 'init', 'root'])}
    if relevant:
        print(f"   Relevant parameters:")
        for k, v in relevant.items():
            print(f"      {k}={v}")
else:
    print(f"   ⚠️  Could not parse xbl_config.img")

print(f"\n[3] steady.bin Analysis")
if steady_info.get('error'):
    print(f"   Error: {steady_info['error']}")
elif 'magic' in steady_info:
    magic_upper = steady_info['magic'].upper()
    if '7f454c46' in magic_upper:
        print(f"   ✅ Appears to be ELF/statically linked binary")
    elif 'uncompress' in magic_upper or 'img' in magic_upper:
        print(f"   ⚠️  Uncompressed kernel/dtb hybrid")
    else:
        print(f"   ℹ️  Binary blob, magic={magic_upper}")

print("\n" + "=" * 70)
print(" SUMMARY")
print("=" * 70)
if kernel_info and xbl_info:
    print(f"✅ Kernel extraction ready - use offset 0x{kernel_info['offset']:X}, size {kernel_info['size']:,}")
    print(f"✅ Boot cmdline extracted with {len([p for p in xbl_info['cmdline'].split() if '=' in p])} parameters")

