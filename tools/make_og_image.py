#!/usr/bin/env python3
"""Tạo ảnh xem trước khi chia sẻ link (Open Graph), 1200x630.

    python3 tools/make_og_image.py

Chạy lại khi đổi khẩu hiệu hoặc màu thương hiệu. Ghi ra assets/img/og-cover.png.
Không dùng font Cormorant Garamond của site vì font đó ở dạng woff2, Pillow
không đọc được; dùng Didot của macOS — cùng nhóm serif cổ điển, gần nhất.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "img" / "og-cover.png"

W, H = 1200, 630
BG = (10, 21, 18)          # #0A1512
CREAM = (231, 206, 151)    # #E7CE97
GOLD = (216, 169, 78)      # #D8A94E
BRONZE = (185, 137, 59)    # #B9893B
MUTED = (169, 196, 179)    # #A9C4B3

SERIF = "/System/Library/Fonts/Supplemental/Didot.ttc"
SANS = "/System/Library/Fonts/Supplemental/Arial.ttf"


def petal(size: int, color: tuple, alpha: int, angle: float) -> Image.Image:
    """Một cánh sen: hình bầu dục hẹp, gốc ở đáy, xoay quanh gốc đó."""
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    w = size * 0.20
    d.ellipse(
        [(size - w) / 2, size * 0.06, (size + w) / 2, size * 0.98],
        fill=color + (alpha,),
    )
    # xoay quanh đáy chứ không quanh tâm
    big = Image.new("RGBA", (size * 2, size * 2), (0, 0, 0, 0))
    big.paste(layer, (size // 2, 0), layer)
    return big.rotate(-angle, resample=Image.BICUBIC, center=(size, size * 0.98))


def draw_lotus(canvas: Image.Image, cx: int, cy: int, size: int) -> None:
    for angle, color, alpha in (
        (-56, BRONZE, 128), (-28, GOLD, 204), (0, CREAM, 255),
        (28, GOLD, 204), (56, BRONZE, 128),
    ):
        p = petal(size, color, alpha, angle)
        canvas.alpha_composite(p, (cx - size, cy - int(size * 0.98)))


def tracked_text(d, xy, text, font, fill, tracking) -> int:
    """Vẽ chữ có giãn ký tự. Trả về tổng bề rộng."""
    x, y = xy
    for ch in text:
        d.text((x, y), ch, font=font, fill=fill)
        x += d.textlength(ch, font=font) + tracking
    return int(x - tracking - xy[0])


def text_width(d, text, font, tracking) -> int:
    return int(sum(d.textlength(c, font=font) for c in text) + tracking * (len(text) - 1))


def main() -> None:
    img = Image.new("RGBA", (W, H), BG + (255,))

    # quầng sáng dịu quanh logo
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    for r, a in ((300, 8), (220, 10), (150, 12)):
        gd.ellipse([W // 2 - r, 150 - r, W // 2 + r, 150 + r], fill=CREAM + (a,))
    img.alpha_composite(glow)

    draw_lotus(img, W // 2, 215, 150)

    d = ImageDraw.Draw(img)
    f_brand = ImageFont.truetype(SERIF, 96)
    f_tag = ImageFont.truetype(SERIF, 40)
    f_sub = ImageFont.truetype(SANS, 25)

    track = 17
    w = text_width(d, "ANWELL", f_brand, track)
    tracked_text(d, ((W - w) // 2, 268), "ANWELL", f_brand, CREAM, track)

    tag = "Feel well. Live an."
    d.text(((W - d.textlength(tag, font=f_tag)) / 2, 392), tag, font=f_tag, fill=GOLD)

    d.line([(W // 2 - 60, 462), (W // 2 + 60, 462)], fill=BRONZE, width=2)

    sub = "Nền tảng trị liệu, dưỡng sinh và chăm sóc phục hồi tại nhà"
    d.text(((W - d.textlength(sub, font=f_sub)) / 2, 492), sub, font=f_sub, fill=MUTED)

    f_note = ImageFont.truetype(SANS, 19)
    note = "BẢN DEMO TƯƠNG TÁC"
    nt = 5
    nw = text_width(d, note, f_note, nt)
    tracked_text(d, ((W - nw) // 2, 552), note, f_note, BRONZE, nt)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(OUT, "PNG", optimize=True)
    print(f"{OUT.relative_to(ROOT)}  {OUT.stat().st_size // 1024} KB  {W}x{H}")


if __name__ == "__main__":
    main()
