#!/usr/bin/env python3
"""Quét bí mật trong phần sắp gửi ra dịch vụ AI bên ngoài.

quy-tac-doi.md điều 12b: commit nhầm bí mật thì còn gỡ khỏi lịch sử được; gửi
sang dịch vụ ngoài thì KHÔNG thu hồi được.

Viết bằng Python thay vì grep vì mẫu bí mật hay bắt đầu bằng dấu gạch
(`-----BEGIN ... PRIVATE KEY-----`) — grep hiểu đó là tham số dòng lệnh — và vì
BSD grep trên macOS xử lý ERE khác GNU grep.

    python3 tools/quet-bi-mat.py < diff.txt
    python3 tools/quet-bi-mat.py --tep "danh sách tệp" < diff.txt

Thoát 0 nếu sạch, 3 nếu thấy dấu hiệu. In phát hiện ra stderr, đã che giá trị.
"""

import re
import sys

# (tên, biểu thức, có che giá trị không)
MAU = [
    ("khoá AWS",            r"AKIA[0-9A-Z]{16}", True),
    ("khoá Anthropic",      r"sk-ant-[A-Za-z0-9_\-]{20,}", True),
    ("khoá OpenAI",         r"sk-(proj-)?[A-Za-z0-9_\-]{20,}", True),
    ("token GitHub",        r"gh[pousr]_[A-Za-z0-9]{30,}", True),
    ("token Slack",         r"xox[baprs]-[A-Za-z0-9\-]{10,}", True),
    ("khoá Google",         r"AIza[0-9A-Za-z_\-]{35}", True),
    ("khoá riêng",          r"-----BEGIN [A-Z ]*PRIVATE KEY-----", False),
    ("JWT",                 r"eyJ[A-Za-z0-9_\-]{15,}\.eyJ[A-Za-z0-9_\-]{15,}\.", True),
    ("URL có mật khẩu",     r"[a-zA-Z][\w+.\-]*://[^/\s:@]+:[^/\s:@]{3,}@", True),
    ("gán bí mật",
     r"(?i)\b(api[_\-]?key|secret|token|password|passwd|credential)\b\s*[:=]\s*"
     r"['\"][^'\"\s]{12,}['\"]", True),
    ("CCCD/CMND thật",      r"(?i)\b(cccd|cmnd)\b\s*[:=]\s*['\"]?\d{9,12}", True),
]

# Tệp không bao giờ gửi đi, dù nội dung trông vô hại.
TEP_CAM = re.compile(
    r"(^|/)(\.env(\.[\w-]+)?$|.*\.(pem|key|p12|pfx|keystore|jks|crt|cer)$"
    r"|id_rsa|id_ed25519|credentials(\.json)?$)"
)

# Giá trị hay gặp trong ví dụ và tài liệu — không phải bí mật thật.
BO_QUA = re.compile(
    r"(?i)(EXAMPLE|XXXX|YOUR[_-]?|<[^>]+>|\$\{|process\.env|os\.environ"
    r"|placeholder|dummy|fake|sample|redacted|\*{4,})"
)


def che(s: str) -> str:
    """Giữ 6 ký tự đầu, che phần còn lại — đủ nhận ra, không lộ thêm."""
    s = s.strip()
    return s[:6] + "…" + "•" * min(len(s) - 6, 8) if len(s) > 6 else "…"


def main() -> int:
    ten_tep = []
    if "--tep" in sys.argv:
        i = sys.argv.index("--tep")
        if i + 1 < len(sys.argv):
            ten_tep = [
                re.sub(r"^\s*·\s*|\s*\[.*$", "", d).strip()
                for d in sys.argv[i + 1].splitlines()
                if d.strip()
            ]

    noi_dung = sys.stdin.read()
    # Chỉ soi dòng THÊM MỚI — dòng ngữ cảnh là mã đã có, đã nằm trong kho.
    them = "\n".join(
        d[1:] for d in noi_dung.splitlines()
        if d.startswith("+") and not d.startswith("+++")
    )

    thay = []

    for t in ten_tep:
        if t and TEP_CAM.search(t):
            thay.append(f"tệp cấm gửi: {t}")

    for ten, bt, can_che in MAU:
        khop = [m.group(0) for m in re.finditer(bt, them)]
        khop = [k for k in khop if not BO_QUA.search(k)]
        if khop:
            vidu = che(khop[0]) if can_che else khop[0][:32]
            thay.append(f"{ten} ({len(khop)} chỗ): {vidu}")

    if not thay:
        return 0

    print("", file=sys.stderr)
    print("⛔ DỪNG — dấu hiệu bí mật trong phần sắp gửi ra dịch vụ ngoài:", file=sys.stderr)
    for d in thay:
        print(f"  · {d}", file=sys.stderr)
    return 3


if __name__ == "__main__":
    sys.exit(main())
