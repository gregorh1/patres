#!/usr/bin/env python3
"""Generate app icon and splash PNG assets for Patres.

Run from project root: python3 tool/generate_icons.py

Produces:
  - assets/splash_icon.png (512x512)
  - assets/icon/ic_launcher.png (1024x1024 for Play Store)
  - android/app/src/main/res/mipmap-{density}/ic_launcher.png
  - assets/playstore/feature_graphic.png (1024x500)
  - assets/playstore/promo_graphic.png (180x120)
"""

import os
from PIL import Image, ImageDraw, ImageFont

# Brand colors
BURGUNDY = (107, 29, 42)
GOLD = (201, 168, 76)
PARCHMENT = (245, 235, 224)
DARK_BROWN = (59, 34, 24)
TRANSPARENT = (0, 0, 0, 0)


def draw_cross_and_book(draw, cx, cy, scale, outline_color=BURGUNDY):
    """Draw stylized cross rising from open book."""
    s = scale

    # --- Open book ---
    # Left page
    left_page = [
        (cx - 100*s, cy + 10*s),
        (cx - 100*s, cy + 100*s),
        (cx - 5*s, cy + 85*s),
        (cx - 5*s, cy + 0*s),
    ]
    draw.polygon(left_page, fill=PARCHMENT, outline=outline_color, width=max(1, int(2*s)))

    # Right page
    right_page = [
        (cx + 100*s, cy + 10*s),
        (cx + 100*s, cy + 100*s),
        (cx + 5*s, cy + 85*s),
        (cx + 5*s, cy + 0*s),
    ]
    draw.polygon(right_page, fill=PARCHMENT, outline=outline_color, width=max(1, int(2*s)))

    # Book spine
    draw.line([(cx, cy - 2*s), (cx, cy + 87*s)], fill=outline_color, width=max(1, int(2*s)))

    # Text lines on pages (gold)
    lw = max(1, int(1.5*s))
    for i in range(3):
        y_off = (30 + i * 18) * s
        # Left page lines
        draw.line([(cx - 85*s, cy + y_off + 4*s), (cx - 15*s, cy + y_off)], fill=GOLD, width=lw)
        # Right page lines
        draw.line([(cx + 15*s, cy + y_off), (cx + 85*s, cy + y_off + 4*s)], fill=GOLD, width=lw)

    # --- Cross (gold) ---
    beam_w = 10 * s

    # Vertical beam
    draw.rectangle([
        cx - beam_w/2, cy - 125*s,
        cx + beam_w/2, cy - 5*s,
    ], fill=GOLD)

    # Horizontal beam
    draw.rectangle([
        cx - 35*s, cy - 100*s,
        cx + 35*s, cy - 100*s + beam_w,
    ], fill=GOLD)


def generate_splash_icon():
    """512x512 splash icon with transparent background."""
    size = 512
    img = Image.new('RGBA', (size, size), TRANSPARENT)
    draw = ImageDraw.Draw(img)
    cx, cy = size / 2, size / 2 + 20  # shift down slightly

    # Subtle gold ring
    ring_r = 210
    draw.ellipse(
        [cx - ring_r, cy - ring_r - 20, cx + ring_r, cy + ring_r - 20],
        outline=(*GOLD, 80), width=4
    )

    draw_cross_and_book(draw, cx, cy, scale=1.0, outline_color=BURGUNDY)
    img.save('assets/splash_icon.png')
    print('  Generated assets/splash_icon.png')


def generate_app_icon():
    """1024x1024 app icon with burgundy background."""
    size = 1024
    img = Image.new('RGBA', (size, size), (*BURGUNDY, 255))
    draw = ImageDraw.Draw(img)
    cx, cy = size / 2, size / 2 + 40

    draw_cross_and_book(draw, cx, cy, scale=2.0, outline_color=PARCHMENT)
    os.makedirs('assets/icon', exist_ok=True)
    img.save('assets/icon/ic_launcher.png')
    print('  Generated assets/icon/ic_launcher.png')


def generate_mipmaps():
    """Generate legacy mipmap PNGs at each density."""
    densities = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
    }
    for name, size in densities.items():
        img = Image.new('RGBA', (size, size), (*BURGUNDY, 255))
        draw = ImageDraw.Draw(img)
        cx, cy = size / 2, size / 2 + size * 0.04
        s = size / 512

        draw_cross_and_book(draw, cx, cy, scale=s, outline_color=PARCHMENT)
        out_dir = f'android/app/src/main/res/mipmap-{name}'
        os.makedirs(out_dir, exist_ok=True)
        img.save(f'{out_dir}/ic_launcher.png')
        print(f'  Generated {out_dir}/ic_launcher.png ({size}x{size})')


def generate_playstore_assets():
    """Generate Play Store feature graphic (1024x500) and promo graphic (180x120)."""
    os.makedirs('assets/playstore', exist_ok=True)

    # Feature graphic: 1024x500
    fg = Image.new('RGB', (1024, 500), BURGUNDY)
    draw = ImageDraw.Draw(fg)

    # Subtle parchment gradient strip at bottom
    for y in range(400, 500):
        alpha = (y - 400) / 100
        r = int(BURGUNDY[0] + (PARCHMENT[0] - BURGUNDY[0]) * alpha * 0.3)
        g = int(BURGUNDY[1] + (PARCHMENT[1] - BURGUNDY[1]) * alpha * 0.3)
        b = int(BURGUNDY[2] + (PARCHMENT[2] - BURGUNDY[2]) * alpha * 0.3)
        draw.line([(0, y), (1024, y)], fill=(r, g, b))

    # Icon in the left area
    draw_cross_and_book(draw, 250, 270, scale=0.7, outline_color=PARCHMENT)

    # App name text
    try:
        font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf", 64)
        font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf", 28)
    except (IOError, OSError):
        font_large = ImageFont.load_default()
        font_small = ImageFont.load_default()

    draw.text((480, 180), "PATRES", fill=GOLD, font=font_large)
    draw.text((480, 270), "Church Fathers\n& Christian Classics", fill=PARCHMENT, font=font_small)

    fg.save('assets/playstore/feature_graphic.png')
    print('  Generated assets/playstore/feature_graphic.png (1024x500)')

    # Promo graphic: 180x120
    pg = Image.new('RGB', (180, 120), BURGUNDY)
    draw_pg = ImageDraw.Draw(pg)
    draw_cross_and_book(draw_pg, 90, 70, scale=0.18, outline_color=PARCHMENT)
    pg.save('assets/playstore/promo_graphic.png')
    print('  Generated assets/playstore/promo_graphic.png (180x120)')


if __name__ == '__main__':
    # Run from project root
    os.chdir(os.path.join(os.path.dirname(__file__), '..'))
    generate_splash_icon()
    generate_app_icon()
    generate_mipmaps()
    generate_playstore_assets()
    print('\nAll icons generated successfully.')
