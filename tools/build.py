#!/usr/bin/env python3
"""Dựng các trang HTML ở gốc repo từ src/.

    python3 tools/build.py

Với mỗi trang:
  1. Đọc src/pages/<tên>.html
  2. Dựng <head> đầy đủ từ src/shared/meta.json (title, description, og, favicon)
  3. Chèn thẻ nạp demo-guide nếu thư mục đó tồn tại
  4. Ghi ra <tên>.html ở gốc repo — nơi GitHub Pages phục vụ

Không sửa gì trong src/. Chạy bao nhiêu lần cũng ra kết quả như nhau.
"""

import json
import re
import shutil
from pathlib import Path

PAGES = ["index", "demo", "app", "center", "ktv", "bd", "admin"]
ROOT = Path(__file__).resolve().parent.parent
SHARED = ROOT / "src" / "shared"

HEAD_TEMPLATE = """<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<meta name="description" content="{description}">
<link rel="icon" type="image/svg+xml" href="{prefix}assets/favicon.svg">
<meta property="og:type" content="website">
<meta property="og:site_name" content="{site_name}">
<meta property="og:locale" content="{locale}">
<meta property="og:title" content="{title}">
<meta property="og:description" content="{description}">
<meta property="og:url" content="{page_url}">
<meta property="og:image" content="{og_image_url}">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="{title}">
<meta name="twitter:description" content="{description}">
<meta name="twitter:image" content="{og_image_url}">"""

GUIDE_TAG = (
    '<link rel="stylesheet" href="assets/demo-guide.css">\n'
    '<script defer src="assets/demo-guide.js" data-page="{page}"></script>'
)


def esc(text: str) -> str:
    return (
        text.replace("&", "&amp;")
        .replace('"', "&quot;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )


def build_head(page: str, meta: dict) -> str:
    common = meta["_chung"]
    page_meta = meta[page]
    base = common["base_url"].rstrip("/") + "/"
    return HEAD_TEMPLATE.format(
        title=esc(page_meta["title"]),
        description=esc(page_meta["description"]),
        site_name=esc(common["site_name"]),
        locale=common["locale"],
        page_url=base + ("" if page == "index" else f"{page}.html"),
        og_image_url=base + common["og_image"],
        prefix="",
    )


def copy_shared_assets() -> None:
    """Chép tài nguyên dùng chung sang assets/ để trang tải được."""
    target = ROOT / "assets"
    target.mkdir(exist_ok=True)
    shutil.copyfile(SHARED / "favicon.svg", target / "favicon.svg")
    guide = SHARED / "demo-guide"
    if guide.is_dir():
        for name in ("demo-guide.css", "demo-guide.js"):
            src = guide / name
            if src.exists():
                shutil.copyfile(src, target / name)
        tours_src = guide / "tours"
        if tours_src.is_dir():
            tours_dst = target / "tours"
            shutil.rmtree(tours_dst, ignore_errors=True)
            shutil.copytree(tours_src, tours_dst)


def build_page(page: str, meta: dict) -> int:
    source = (ROOT / "src" / "pages" / f"{page}.html").read_text(encoding="utf-8")

    head_open = source.index("<head>") + len("<head>")
    head_close = source.index("</head>")
    old_head = source[head_open:head_close]

    # Giữ nguyên mọi thứ trong <head> gốc TRỪ những thẻ build.py tự dựng lại:
    # meta, title và link rel=icon. Cách loại trừ này giữ được cả khối <style>
    # — bản whitelist cũ chỉ nhận <script> và <link> nên nuốt mất CSS của trang.
    drop = re.compile(
        r'^\s*(?:<meta\b|<title\b|<link[^>]*\brel="(?:icon|apple-touch-icon)")',
        re.I,
    )
    keep_lines, in_title = [], False
    for line in old_head.splitlines():
        if in_title:
            if "</title>" in line:
                in_title = False
            continue
        if drop.match(line):
            if line.lstrip().startswith("<title") and "</title>" not in line:
                in_title = True
            continue
        keep_lines.append(line)
    keep = "\n".join(keep_lines).strip("\n")

    new_head = "\n" + build_head(page, meta) + "\n" + keep + "\n"
    if (SHARED / "demo-guide").is_dir():
        new_head += GUIDE_TAG.format(page=page) + "\n"

    out = source[:head_open] + new_head + source[head_close:]
    dest = ROOT / f"{page}.html"
    dest.write_text(out, encoding="utf-8")
    return len(out.encode())


def main() -> None:
    meta = json.loads((SHARED / "meta.json").read_text(encoding="utf-8"))
    copy_shared_assets()
    print(f"{'trang':10}{'kích thước':>12}")
    for page in PAGES:
        size = build_page(page, meta)
        print(f"{page:10}{size // 1024:>9} KB")


if __name__ == "__main__":
    main()
