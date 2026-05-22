#!/usr/bin/env python3
"""
Optimize image assets by compressing PNGs and JPGs in-place.
Uses Pillow to reduce file sizes while maintaining visual quality.
"""
import os
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Installing Pillow...")
    os.system(f"{sys.executable} -m pip install Pillow")
    from PIL import Image

ASSETS_DIR = Path("assets/images")
QUALITY = 85  # JPEG/WebP quality (0-100)
MAX_DIMENSION = 1200  # Max width or height in pixels

total_before = 0
total_after = 0
files_processed = 0

def optimize_image(filepath: Path):
    global total_before, total_after, files_processed
    
    original_size = filepath.stat().st_size
    total_before += original_size
    
    try:
        img = Image.open(filepath)
        
        # Skip if too small to bother
        if original_size < 5000:  # < 5KB
            total_after += original_size
            return
        
        # Resize if too large (mobile screens don't need 4000px images)
        w, h = img.size
        if max(w, h) > MAX_DIMENSION:
            ratio = MAX_DIMENSION / max(w, h)
            new_size = (int(w * ratio), int(h * ratio))
            img = img.resize(new_size, Image.LANCZOS)
        
        ext = filepath.suffix.lower()
        
        if ext in ('.png',):
            # For PNGs: optimize without quality loss
            if img.mode == 'RGBA':
                img.save(filepath, 'PNG', optimize=True)
            else:
                img = img.convert('RGB')
                img.save(filepath, 'PNG', optimize=True)
        elif ext in ('.jpg', '.jpeg'):
            img = img.convert('RGB')
            img.save(filepath, 'JPEG', quality=QUALITY, optimize=True)
        
        new_size_bytes = filepath.stat().st_size
        total_after += new_size_bytes
        
        saved = original_size - new_size_bytes
        if saved > 0:
            pct = (saved / original_size) * 100
            files_processed += 1
            print(f"  ✅ {filepath.name}: {original_size/1024:.0f}KB → {new_size_bytes/1024:.0f}KB ({pct:.1f}% saved)")
        else:
            total_after = total_after - new_size_bytes + original_size  # revert if bigger
            
    except Exception as e:
        total_after += original_size
        print(f"  ⚠️  Skipped {filepath.name}: {e}")

def main():
    global total_before, total_after
    
    if not ASSETS_DIR.exists():
        print(f"Directory {ASSETS_DIR} not found!")
        return
    
    print(f"🖼️  Optimizing images in {ASSETS_DIR}...")
    print(f"   Quality: {QUALITY}%, Max dimension: {MAX_DIMENSION}px")
    print()
    
    extensions = {'.png', '.jpg', '.jpeg'}
    
    for filepath in sorted(ASSETS_DIR.rglob("*")):
        if filepath.suffix.lower() in extensions and filepath.is_file():
            optimize_image(filepath)
    
    print()
    print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"📊 Results:")
    print(f"   Files optimized: {files_processed}")
    print(f"   Before: {total_before/1024/1024:.1f} MB")
    print(f"   After:  {total_after/1024/1024:.1f} MB")
    saved_total = total_before - total_after
    if total_before > 0:
        print(f"   Saved:  {saved_total/1024/1024:.1f} MB ({(saved_total/total_before)*100:.1f}%)")
    print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if __name__ == "__main__":
    main()
