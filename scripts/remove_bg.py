"""
Step 1: Resize DESCANSO.gif to a manageable size (max 480px wide).
Step 2: Remove black background (R<30, G<30, B<30 -> transparent).
Saves result in place.
"""
from PIL import Image, ImageSequence

INPUT     = r'assets\images\letreros\DESCANSO.gif'
OUTPUT    = r'assets\images\letreros\DESCANSO.gif'
MAX_WIDTH = 480   # target width; height scales proportionally
THRESHOLD = 30    # black threshold per channel

def process(input_path, output_path, max_width=480, threshold=30):
    src = Image.open(input_path)
    orig_w, orig_h = src.size

    # Compute scale
    scale  = max_width / orig_w
    new_w  = max_width
    new_h  = int(orig_h * scale)
    print(f"Resizing {orig_w}x{orig_h} -> {new_w}x{new_h} ({scale:.2f}x)")

    frames    = []
    durations = []

    for frame in ImageSequence.Iterator(src):
        duration = frame.info.get('duration', 50)

        # Resize then convert to RGBA
        small = frame.resize((new_w, new_h), Image.LANCZOS)
        rgba  = small.convert('RGBA')
        data  = list(rgba.getdata())

        # Replace black/near-black with transparent
        new_data = [
            (0, 0, 0, 0) if (r < threshold and g < threshold and b < threshold) else (r, g, b, 255)
            for r, g, b, a in data
        ]
        rgba.putdata(new_data)
        frames.append(rgba)
        durations.append(duration)

    frames[0].save(
        output_path,
        format='GIF',
        save_all=True,
        append_images=frames[1:],
        loop=0,
        duration=durations,
        disposal=2,
    )
    print("Done! Saved", len(frames), "frames ->", output_path)

if __name__ == '__main__':
    process(INPUT, OUTPUT, MAX_WIDTH, THRESHOLD)
