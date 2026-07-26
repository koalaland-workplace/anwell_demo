#!/usr/bin/env python3
"""Giải nén 5 file HTML bundled thành source rời.

Chạy MỘT LẦN để khởi tạo src/, assets/, vendor/ từ các file bundled gốc.
Sau đó sửa nội dung trong src/pages/ và dùng build.py để dựng lại.

    python3 tools/unbundle.py <thư-mục-chứa-file-bundled>

Mỗi file bundled chứa hai khối:
  <script type="__bundler/manifest">  — assets, base64 + gzip, khoá theo UUID
  <script type="__bundler/template">  — HTML + JS thật, tham chiếu asset bằng UUID

Script này ghi asset ra file có tên thật rồi thay UUID trong template bằng
đường dẫn tương ứng. Asset trùng nội dung ở nhiều trang chỉ ghi một lần.
"""

import base64
import gzip
import hashlib
import json
import re
import sys
from pathlib import Path

PAGES = ["index", "app", "center", "ktv", "admin"]

# mime -> (thư mục con, đuôi file)
ASSET_KINDS = {
    "text/javascript": ("vendor", ".js"),
    "application/javascript": ("vendor", ".js"),
    "text/css": ("assets/css", ".css"),
    "font/woff2": ("assets/fonts", ".woff2"),
    "application/font-woff2": ("assets/fonts", ".woff2"),
    "image/png": ("assets/img", ".png"),
    "image/jpeg": ("assets/img", ".jpg"),
    "image/webp": ("assets/img", ".webp"),
    "image/svg+xml": ("assets/img", ".svg"),
}

# Tên dễ đọc cho các asset lớn nhận diện được qua nội dung.
KNOWN_JS = [
    ("dc-runtime", "GENERATED from dc-runtime/src"),
    ("react-dom", "react-dom.production.min.js"),
    ("react", "react.production.min.js"),
    ("image-slot", "<image-slot>"),
    ("anwell-img", "window.ANWELL_IMG"),
]

# Chất lượng WebP khởi điểm. Ảnh nào xuống cấp rõ thì thêm vào KEEP_PNG.
WEBP_QUALITY = 82
KEEP_PNG: set[str] = set()

UUID_RE = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")


def extract_block(html: str, kind: str) -> str:
    m = re.search(rf'<script type="__bundler/{kind}">(.*?)</script>', html, re.S)
    if not m:
        raise SystemExit(f"không tìm thấy khối __bundler/{kind}")
    return json.loads(m.group(1).strip())


def decode_asset(entry: dict) -> bytes:
    raw = base64.b64decode(entry["data"])
    if entry.get("compressed"):
        try:
            return gzip.decompress(raw)
        except OSError:
            pass  # cờ compressed sai — dùng nguyên bản
    return raw


def name_for(blob: bytes, mime: str, index: int) -> str:
    """Đặt tên file: ưu tiên tên nhận diện được, còn lại dùng hash nội dung."""
    _, ext = ASSET_KINDS.get(mime, ("assets/misc", ".bin"))
    if ext == ".js":
        head = blob[:4000].decode("utf-8", "ignore")
        for label, marker in KNOWN_JS:
            if marker in head:
                return label + ext
    if ext == ".woff2":
        return f"font-{index:02d}{ext}"
    return hashlib.sha1(blob).hexdigest()[:10] + ext


def split_embedded_images(root: Path) -> None:
    """Tách window.ANWELL_IMG thành file ảnh rời.

    Trước:  ANWELL_IMG = {"tt-01": "data:image/png;base64,..."}   1.867 KB trong JS
    Sau:    ANWELL_IMG = {"tt-01": "assets/img/tt-01.webp"}       ~250 KB tải riêng, cache được
    """
    from io import BytesIO

    from PIL import Image

    js_path = root / "vendor" / "anwell-img.js"
    if not js_path.exists():
        return
    text = js_path.read_text(encoding="utf-8")
    data = json.loads(text[text.index("{"): text.rindex("}") + 1])

    img_dir = root / "assets" / "img"
    img_dir.mkdir(parents=True, exist_ok=True)
    mapping, before, after = {}, 0, 0

    for key, uri in data.items():
        m = re.match(r"data:([^;]+);base64,(.*)", uri)
        if not m:
            mapping[key] = uri  # không phải data URI — giữ nguyên
            continue
        blob = base64.b64decode(m.group(2))
        before += len(blob)
        img = Image.open(BytesIO(blob))
        if key in KEEP_PNG:
            name = f"{key}.png"
            img.save(img_dir / name, "PNG", optimize=True)
        else:
            name = f"{key}.webp"
            img.save(img_dir / name, "WEBP", quality=WEBP_QUALITY, method=6)
        after += (img_dir / name).stat().st_size
        mapping[key] = f"assets/img/{name}"

    js_path.write_text(
        "// Sinh bởi tools/unbundle.py — ánh xạ khoá ảnh sang đường dẫn file.\n"
        "window.ANWELL_IMG = " + json.dumps(mapping, ensure_ascii=False, indent=2) + ";\n",
        encoding="utf-8",
    )
    pct = 100 - after * 100 // before if before else 0
    print(f"ảnh: {len(mapping)} tệp, {before // 1024} KB → {after // 1024} KB (giảm {pct}%)")


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    src_dir = Path(sys.argv[1]).resolve()
    root = Path(__file__).resolve().parent.parent

    (root / "src" / "pages").mkdir(parents=True, exist_ok=True)

    written: dict[str, str] = {}  # sha1 nội dung -> đường dẫn tương đối
    font_n = 0
    report = []

    for page in PAGES:
        bundled = src_dir / f"{page}.html"
        if not bundled.exists():
            raise SystemExit(f"thiếu file {bundled}")
        html = bundled.read_text(encoding="utf-8", errors="ignore")
        manifest = extract_block(html, "manifest")
        template = extract_block(html, "template")

        for uuid, entry in manifest.items():
            blob = decode_asset(entry)
            sha = hashlib.sha1(blob).hexdigest()
            if sha not in written:
                mime = entry["mime"]
                subdir, _ = ASSET_KINDS.get(mime, ("assets/misc", ".bin"))
                if mime.endswith("woff2"):
                    font_n += 1
                fname = name_for(blob, mime, font_n)
                out = root / subdir / fname
                out.parent.mkdir(parents=True, exist_ok=True)
                out.write_bytes(blob)
                written[sha] = f"{subdir}/{fname}"
            template = template.replace(uuid, written[sha])

        leftover = UUID_RE.findall(template)
        if leftover:
            raise SystemExit(
                f"{page}: còn {len(leftover)} UUID chưa thay, ví dụ {leftover[0]}"
            )

        (root / "src" / "pages" / f"{page}.html").write_text(template, encoding="utf-8")
        report.append((page, len(template.encode()), len(manifest)))

    split_embedded_images(root)

    print(f"{'trang':10}{'source':>10}{'#asset':>9}")
    for page, size, n in report:
        print(f"{page:10}{size // 1024:>8} KB{n:>9}")
    total = sum(
        (root / p).stat().st_size for p in written.values()
    )
    print(f"\n{len(written)} asset duy nhất, {total // 1024} KB")


if __name__ == "__main__":
    main()
