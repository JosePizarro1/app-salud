#!/usr/bin/env python3
"""
Vitali – Compresor de audios de meditación guiada.
Reduce el peso de archivos MP3 re-encodificándolos a 64 kbps mono (ideal para voz).
Requiere: ffmpeg instalado en el sistema.
"""
import os
import subprocess
import shutil

BASE_DIR = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "assets", "audio", "AUDIOS DE MEDITACIÓN GUIADA"
)

BITRATE = "64k"   # 64 kbps – excelente para voz, reduce ~60-75 %
CHANNELS = "1"     # Mono – la voz no necesita estéreo
SAMPLE_RATE = "44100"  # Mantener sample rate estándar

def human_size(size_bytes):
    """Convierte bytes a formato legible."""
    for unit in ['B', 'KB', 'MB']:
        if size_bytes < 1024.0:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024.0
    return f"{size_bytes:.1f} GB"


def get_mp3_files(base_dir):
    """Recorre recursivamente y devuelve lista de (ruta_absoluta, tamaño_bytes)."""
    files = []
    for root, _, filenames in os.walk(base_dir):
        for fname in sorted(filenames):
            if fname.lower().endswith('.mp3'):
                full_path = os.path.join(root, fname)
                size = os.path.getsize(full_path)
                files.append((full_path, size))
    return files


def compress_mp3(input_path, output_path):
    """Comprime un MP3 usando ffmpeg."""
    cmd = [
        "ffmpeg", "-y",        # Sobrescribir si existe
        "-i", input_path,
        "-codec:a", "libmp3lame",
        "-b:a", BITRATE,
        "-ac", CHANNELS,
        "-ar", SAMPLE_RATE,
        output_path
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"  ❌ Error comprimiendo {input_path}: {result.stderr[:200]}")
        return False
    return True


def main():
    print("=" * 65)
    print("🎵  Vitali – Compresor de Audios de Meditación Guiada")
    print("=" * 65)

    # 1. Listar archivos originales
    files = get_mp3_files(BASE_DIR)
    if not files:
        print("⚠️  No se encontraron archivos MP3.")
        return

    print(f"\n📂 Directorio base: {BASE_DIR}")
    print(f"📁 Archivos encontrados: {len(files)}\n")

    print("─" * 65)
    print(f"{'Archivo':<45} {'Tamaño Original':>18}")
    print("─" * 65)

    total_original = 0
    for fpath, fsize in files:
        rel = os.path.relpath(fpath, BASE_DIR)
        total_original += fsize
        print(f"  {rel:<43} {human_size(fsize):>16}")

    print("─" * 65)
    print(f"  {'TOTAL ORIGINAL':<43} {human_size(total_original):>16}")
    print("─" * 65)

    # 2. Comprimir cada archivo
    print(f"\n🔧 Comprimiendo a {BITRATE} mono...\n")

    results = []
    for fpath, original_size in files:
        rel = os.path.relpath(fpath, BASE_DIR)
        # Crear archivo temporal
        tmp_path = fpath + ".tmp.mp3"
        
        print(f"  ⏳ {rel}...", end=" ", flush=True)
        
        success = compress_mp3(fpath, tmp_path)
        
        if success and os.path.exists(tmp_path):
            new_size = os.path.getsize(tmp_path)
            # Reemplazar original con comprimido
            shutil.move(tmp_path, fpath)
            reduction = ((original_size - new_size) / original_size) * 100
            print(f"✅ {human_size(original_size)} → {human_size(new_size)} (-{reduction:.0f}%)")
            results.append((rel, original_size, new_size))
        else:
            # Limpiar temporal si falló
            if os.path.exists(tmp_path):
                os.remove(tmp_path)
            print("❌ Falló")
            results.append((rel, original_size, original_size))

    # 3. Resumen final
    total_new = sum(r[2] for r in results)
    total_saved = total_original - total_new
    pct = (total_saved / total_original) * 100 if total_original > 0 else 0

    print("\n" + "=" * 65)
    print("📊  RESUMEN DE COMPRESIÓN")
    print("=" * 65)
    print(f"{'Archivo':<35} {'Antes':>10} {'Después':>10} {'Ahorro':>8}")
    print("─" * 65)

    for rel, orig, new in results:
        saved = ((orig - new) / orig) * 100 if orig > 0 else 0
        print(f"  {rel:<33} {human_size(orig):>8} {human_size(new):>8} {saved:>5.0f}%")

    print("─" * 65)
    print(f"  {'TOTAL':<33} {human_size(total_original):>8} {human_size(total_new):>8} {pct:>5.0f}%")
    print(f"\n  💾 Espacio ahorrado: {human_size(total_saved)}")
    print("=" * 65)
    print("\n✨ ¡Compresión completada! Los archivos originales fueron reemplazados.\n")


if __name__ == "__main__":
    main()
