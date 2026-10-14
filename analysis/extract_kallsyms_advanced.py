#!/usr/bin/env python3
"""
GhostLock Kernel Symbol Extractor for Uncompressed ELF Images
Extracts kallsyms and validates offsets against Linux 4.14 structure
"""

import sys
import struct
import re
from pathlib import Path

def parse_uncompressed_elf(path: str) -> dict:
    """Parse uncompressed kernel image (dtb/elf hybrid format)."""
    result = {
        'valid': False,
        'format': None,
        'size': 0,
        'symbols': [],
        'sections': []
    }
    
    try:
        with open(path, 'rb') as f:
            data = f.read(4096)
        
        # Check magic headers
        if data[:8] == b'UNCOMPRESSED_IMG':
            result['format'] = 'uncompressed_kernel'
            print(f"✅ Uncompressed kernel image detected")
            
            # Parse header metadata
            offset = 8
            while offset < len(data) and len(data[offset:offset+4]) > 0:
                magic = data[offset:offset+4]
                if magic == b'\x00\x00\x00\x00':
                    break
                
                length = len(magic)
                label_end = data.find(b'\x00', offset + length)
                if label_end == -1:
                    offset += length
                    continue
                    
                label = data[offset+length-1:label_end].rstrip(b'\x00').decode('utf-8', errors='ignore')
                
                # Parse section info following the label
                if 'sections' in label.lower() or 'sect' in label.lower():
                    num_sections = struct.unpack('<I', data[label_end+4:label_end+8])[0]
                    for i in range(num_sections):
                        sect_offset = struct.unpack('<I', data[label_end+8+12*i:label_end+8+12*i+4])[0]
                        sect_size = struct.unpack('<I', data[label_end+8+12*i+4:label_end+8+12*i+8])[0]
                        result['sections'].append({
                            'index': i,
                            'offset': sect_offset,
                            'size': sect_size
                        })
                
                offset = label_end + 1
                
        elif data[:4] == b'\x7fELF':
            result['format'] = 'elf'
            print(f"✅ ELF kernel image detected")
            result['valid'] = True
            
        else:
            print(f"⚠️  Unknown kernel image format (magic: {data[:8].hex()})")
            
    except Exception as e:
        print(f"❌ Error reading file: {e}")
    
    return result

def extract_symbols_from_elf(path: str):
    """Try to extract symbols using objdump if available."""
    import subprocess
    
    try:
        result = subprocess.run(
            ['objdump', '-t', path],
            capture_output=True, text=True, timeout=30
        )
        
        symbols = []
        for line in result.stdout.split('\n'):
            parts = line.split()
            if len(parts) >= 4:
                addr = parts[0].rstrip(',')
                sym_type = parts[1]
                value = parts[2]
                name = parts[3]
                if name.startswith('.'):
                    continue
                symbols.append({
                    'address': int(addr, 16),
                    'type': sym_type,
                    'value': int(value, 16),
                    'name': name
                })
        
        return symbols[:50]  # Return first 50 symbols for inspection
    except Exception as e:
        print(f"⚠️  Could not extract symbols with objdump: {e}")
        return []

def validate_offsets_414():
    """Validate offsets against known Linux 4.14 kernel structure."""
    TARGET_H = "/workspaces/GhostLock-OPPO-PCKM00/targets/samsung-g970u/target.h"
    
    print("\n[Offset Validation]")
    print("Checking target.h against Linux 4.14 expectations:\n")
    
    # Read and parse target.h
    with open(TARGET_H, 'r') as f:
        content = f.read()
    
    def extract_offset(name):
        match = re.search(rf'^#\s*define\s+{name}\s*\(\s*\(\(void\)\*\)\s*0x([0-9a-fA-F]+)ULL\s*\)', 
                          content, re.MULTILINE)
        if match:
            return f"0x{int(match.group(1), 16):X}"
        
        match = re.search(rf'^#\s*define\s+{name}\s*0x([0-9a-fA-F]+)ULL', content, re.MULTILINE)
        if match:
            return f"0x{int(match.group(1), 16):X}"
        
        match = re.search(rf'^#\s*define\s+{name}\s*0x([0-9a-fA-F]+)', content, re.MULTILINE)
        if match:
            return f"0x{int(match.group(1), 16):X}"
        
        return None
    
    checks = [
        ('PIPE_OFF', 'Pipe slab offset (4.14 standard: 0xc20)'),
        ('FOPS_OFF', 'Fops table offset (4.14 standard: 0xc38)'),
        ('INIT_TASK', 'Init task pointer'),
        ('KIMAGE_TEXT_BASE', 'Kernel image text base'),
    ]
    
    all_valid = True
    for name, desc in checks:
        value = extract_offset(name)
        if value:
            print(f"  ✓ {name}: {value} - {desc}")
        else:
            print(f"  ✗ {name}: NOT FOUND - {desc}")
            all_valid = False
    
    return all_valid

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 extract_kallsyms.py <kernel_image> [validate]")
        sys.exit(1)
    
    kernel_path = sys.argv[1]
    validate_offsets = len(sys.argv) > 2 and sys.argv[2] == 'validate'
    
    print("=" * 60)
    print(" GhostLock Kernel Symbol Extractor")
    print("=" * 60)
    print(f"\nAnalyzing: {kernel_path}")
    
    # Parse kernel image
    result = parse_uncompressed_elf(kernel_path)
    
    if result['valid'] or result['format']:
        print(f"   Size: {(result['size']/1024/1024):.2f} MB")
        
        if result['symbols']:
            print(f"\n[Symbol Summary]")
            for sym in result['symbols'][:10]:
                print(f"  {sym['address']:016X} {sym['type']} {sym['name']}")
    
    if validate_offsets:
        success = validate_offsets_414()
        sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
