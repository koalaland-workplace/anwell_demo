#!/usr/bin/env python3
"""Sinh CLAUDE.md · AGENTS.md · GEMINI.md từ một nguồn duy nhất.

Ba công cụ AI đọc ba tên tệp khác nhau nhưng cần đúng một bộ quy tắc. Viết tay ba
tệp là tự tạo ra ba nguồn sự thật — sửa một chỗ quên hai chỗ kia.

Nguồn:  docs/quy-tac-doi.md
Dùng:   python3 tools/sinh-lenh-doi.py
Kiểm:   python3 tools/sinh-lenh-doi.py --kiem   (không ghi, chỉ báo lệch)
"""

import sys
import hashlib
from pathlib import Path

GOC = Path(__file__).resolve().parent.parent
NGUON = GOC / "docs" / "quy-tac-doi.md"

# Mỗi công cụ có một câu mở đầu riêng, phần thân giống hệt nhau.
DICH = {
    "CLAUDE.md": (
        "Bạn đang làm việc trong kho mã ANWELL. Skill nghiệp vụ nạp tự động từ "
        "`.claude/skills/` — xem bảng ở mục 5 để biết việc nào cần skill nào."
    ),
    "AGENTS.md": (
        "Bạn đang làm việc trong kho mã ANWELL. Bạn KHÔNG có cơ chế nạp skill tự "
        "động — skill là tệp văn bản thường ở `.claude/skills/<tên>/SKILL.md`. "
        "Xem bảng ở mục 5, rồi **đọc thẳng tệp SKILL.md tương ứng** trước khi viết mã."
    ),
    "GEMINI.md": (
        "Bạn đang làm việc trong kho mã ANWELL. Bạn KHÔNG có cơ chế nạp skill tự "
        "động — đọc thẳng `.claude/skills/<tên>/SKILL.md` theo bảng ở mục 5."
    ),
}

CANH_BAO = (
    "<!-- TỆP NÀY ĐƯỢC SINH TỰ ĐỘNG — ĐỪNG SỬA TAY.\n"
    "     Nguồn: docs/quy-tac-doi.md\n"
    "     Sinh lại: python3 tools/sinh-lenh-doi.py -->\n"
)


def dung_noi_dung(ten: str, than: str) -> str:
    return f"{CANH_BAO}\n# ANWELL — Lệnh thường trực\n\n{DICH[ten]}\n\n---\n\n{than}\n"


def bam(s: str) -> str:
    return hashlib.sha256(s.encode("utf-8")).hexdigest()[:12]


def main() -> int:
    chi_kiem = "--kiem" in sys.argv

    if not NGUON.exists():
        print(f"LỖI: không thấy nguồn {NGUON.relative_to(GOC)}")
        return 1

    than = NGUON.read_text(encoding="utf-8")
    lech = []

    for ten in DICH:
        dich = GOC / ten
        moi = dung_noi_dung(ten, than)
        cu = dich.read_text(encoding="utf-8") if dich.exists() else ""

        if cu == moi:
            print(f"  khớp    {ten}")
            continue

        lech.append(ten)
        if chi_kiem:
            trang_thai = "chưa có" if not cu else f"lệch (đang là {bam(cu)})"
            print(f"  LỆCH    {ten} — {trang_thai}")
        else:
            dich.write_text(moi, encoding="utf-8")
            print(f"  đã ghi  {ten}  ({len(moi.splitlines())} dòng)")

    if chi_kiem and lech:
        print(f"\n{len(lech)} tệp lệch với nguồn. Chạy lại không có --kiem để sinh.")
        return 1

    if not lech:
        print("\nCả ba tệp đã khớp nguồn.")
    else:
        print(f"\nXong. Nguồn: docs/quy-tac-doi.md ({len(than.splitlines())} dòng)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
