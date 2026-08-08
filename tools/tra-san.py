#!/usr/bin/env python3
"""Tra sẵn: tìm hộ người rà, để nó khỏi phải tự đọc cả kho mã.

Đo được 06/08/2026: một lượt T8 tốn 151.762 token đầu vào mới, trong đó lời nhắc
chỉ khoảng 40.000. Ba phần tư còn lại là Codex TỰ ĐỌC kho — vì chính chỉ dẫn T8
bảo nó "Grep tìm trước khi kết luận là mới". Nó làm đúng lời dặn.

Chạy sẵn phép tìm đó ở đây thì nó không còn lý do lang thang.

    python3 tools/tra-san.py --tep "<danh sách tệp đang sửa>" < diff.txt

In ra stdout một bảng ngắn: định danh mới nào đã tồn tại ở đâu trong kho.
"""

import re
import subprocess
import sys
from pathlib import Path

TRAN = 25          # số định danh tra tối đa — đủ để bắt trùng lặp, không phình
TOI_DA_NOI = 3     # mỗi định danh chỉ liệt kê tối đa bấy nhiêu nơi

KHAI_BAO = re.compile(
    r"\b(?:async\s+)?(?:function|const|let|var|class|interface|type|def|struct|enum)"
    r"\s+([A-Za-z_][A-Za-z0-9_]{3,})"
)


def tep_dang_sua(tho: str):
    ra = set()
    for d in (tho or "").splitlines():
        d = re.sub(r"^\s*·\s*", "", d)
        d = re.sub(r"\s*\[.*$", "", d).strip()
        if d:
            ra.add(d)
    return ra


def main() -> int:
    dang_sua = set()
    if "--tep" in sys.argv:
        i = sys.argv.index("--tep")
        if i + 1 < len(sys.argv):
            dang_sua = tep_dang_sua(sys.argv[i + 1])

    diff = sys.stdin.read()
    them = "\n".join(
        d[1:] for d in diff.splitlines()
        if d.startswith("+") and not d.startswith("+++")
    )

    ten = sorted({m.group(1) for m in KHAI_BAO.finditer(them)})[:TRAN]
    if not ten:
        print("(không có định danh mới nào để tra)")
        return 0

    goc = Path(__file__).resolve().parent.parent
    dong = []
    for t in ten:
        try:
            r = subprocess.run(
                ["git", "grep", "-l", "-w", "--", t],
                cwd=goc, capture_output=True, text=True, timeout=20,
            )
            noi = [
                d for d in r.stdout.splitlines()
                if d and d not in dang_sua
            ][:TOI_DA_NOI]
        except (subprocess.SubprocessError, OSError):
            noi = []
        if noi:
            dong.append(f"  · {t} — ĐÃ CÓ ở: {' · '.join(noi)}")
        else:
            dong.append(f"  · {t} — không thấy nơi khác trong kho")

    trung = sum(1 for d in dong if "ĐÃ CÓ" in d)
    print(f"Đã tra {len(ten)} ĐỊNH DANH KHAI BÁO MỚI nhận diện được. {trung} cái trùng tên với chỗ khác.")
    print("Chưa tra: endpoint · tên bảng · route · quyền · event · queue · khoá")
    print("cấu hình · ràng buộc SQL · quy tắc không có khai báo riêng.")
    print("KHÔNG coi đây là bằng chứng đã rà hết kho.")
    print("\n".join(dong))
    if trung:
        print()
        print("Định danh trùng tên KHÔNG chắc là viết lại — có thể chỉ trùng tên.")
        print("Nhưng đó là chỗ đáng mở ra xem trước tiên.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
