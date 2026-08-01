#!/usr/bin/env python3
"""Kiểm tra output trước khi push.

    python3 tools/verify.py

Chỉ báo lỗi, không sửa gì. Thoát với mã 1 nếu có lỗi.
"""

import json
import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse

PAGES = ["index", "demo", "app", "center", "ktv", "bd", "admin"]
ROOT = Path(__file__).resolve().parent.parent
MAX_HTML_KB = 400

UUID_RE = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")
REF_RE = re.compile(r"""(?:src|href)=["']([^"']+)["']|url\(["']?([^"')]+)["']?\)""")

errors: list[str] = []
warnings: list[str] = []


def check(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def local_refs(html: str):
    for m in REF_RE.finditer(html):
        ref = m.group(1) or m.group(2)
        if not ref or ref.startswith(("http://", "https://", "data:", "#", "mailto:", "//")):
            continue
        if "{{" in ref or "{" in ref:  # biểu thức của template, không phải đường dẫn tĩnh
            continue
        yield unquote(urlparse(ref).path)


def main() -> None:
    for page in PAGES:
        path = ROOT / f"{page}.html"
        if not path.exists():
            errors.append(f"{page}.html: thiếu file")
            continue
        html = path.read_text(encoding="utf-8")
        size_kb = len(html.encode()) // 1024

        check(size_kb <= MAX_HTML_KB, f"{page}.html: {size_kb} KB, vượt ngưỡng {MAX_HTML_KB} KB")

        leftover = UUID_RE.findall(html)
        check(not leftover, f"{page}.html: còn {len(leftover)} UUID chưa thay")

        title = re.search(r"<title>(.*?)</title>", html, re.S)
        check(bool(title and title.group(1).strip()), f"{page}.html: thiếu <title>")
        check(
            bool(re.search(r'<meta name="description" content="[^"]+"', html)),
            f"{page}.html: thiếu meta description",
        )
        check(
            bool(re.search(r'<meta property="og:title" content="[^"]+"', html)),
            f"{page}.html: thiếu og:title",
        )

        for ref in local_refs(html):
            if not (ROOT / ref).exists():
                errors.append(f"{page}.html: đường dẫn hỏng → {ref}")

    # Tài liệu nội bộ không được lọt vào output
    if (ROOT / "Tailieu-noibo").exists():
        gitignore = (ROOT / ".gitignore").read_text(encoding="utf-8")
        check(
            "Tailieu-noibo/" in gitignore,
            "Tailieu-noibo/ tồn tại nhưng KHÔNG nằm trong .gitignore — nguy cơ lộ ra repo public",
        )

    for w in warnings:
        print(f"  cảnh báo  {w}")
    if errors:
        print(f"\n✗ {len(errors)} lỗi:")
        for e in errors:
            print(f"  {e}")
        sys.exit(1)
    print(f"✓ {len(PAGES)} trang đạt: có title/description/og, không UUID sót, đường dẫn hợp lệ")


if __name__ == "__main__":
    main()
