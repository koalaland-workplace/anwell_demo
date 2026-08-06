#!/usr/bin/env python3
"""Đọc SỐ TOKEN THẬT và hạn mức từ tệp phiên mà Claude Code và Codex tự ghi ra.

Trước đây đội ước lượng token bằng `số ký tự / 3`. Đó là ước lượng thô: tiếng Việt
có dấu, mã nguồn và markdown cho tỷ lệ rất khác nhau, nên sai số lớn. Trong khi
đó hai CLI đều đã ghi sẵn số thật ra đĩa:

    ~/.codex/sessions/**/rollout-*.jsonl   → payload.type == "token_count"
    ~/.claude/projects/*/*.jsonl           → message.usage

Tệp này chỉ ĐỌC. Không gọi mạng, không sửa gì.

    python3 tools/doc-token.py codex-phien <epoch_bat_dau>
        → TSV một dòng: mo_hinh  vao  dem  ra  tong  phan_tram_han_muc

    python3 tools/doc-token.py han-muc
        → phần trăm hạn mức đã dùng của gói Codex, hoặc rỗng nếu không đọc được
"""

import json
import os
import sys
from pathlib import Path

CODEX = Path.home() / ".codex" / "sessions"


def _phien_codex_moi_nhat(tu_epoch: float = 0.0):
    """Tệp rollout được ghi gần đây nhất, tính từ mốc thời gian cho trước."""
    if not CODEX.is_dir():
        return None
    ung_vien = [
        p for p in CODEX.rglob("rollout-*.jsonl")
        if p.is_file() and p.stat().st_mtime >= tu_epoch - 1
    ]
    return max(ung_vien, key=lambda p: p.stat().st_mtime, default=None)


def _doc_phien(tep: Path):
    """Trả về (thông tin token cuối cùng, hạn mức, mô hình) của một tệp phiên."""
    token = han_muc = None
    mo_hinh = ""
    try:
        with tep.open(encoding="utf-8", errors="replace") as f:
            for dong in f:
                try:
                    o = json.loads(dong)
                except (json.JSONDecodeError, ValueError):
                    continue

                # Tên mô hình thật nằm ở payload.model (vd "gpt-5.6-sol").
                # KHÔNG lấy model_provider — đó là "openai", tên nhà cung cấp,
                # không phải mô hình. Ghi nhầm nhà cung cấp thành mô hình là đúng
                # cái lỗi "tự khai gpt-codex" mà bản rà đã bắt.
                if not mo_hinh:
                    for goc in (o.get("payload") or {}, o):
                        if isinstance(goc, dict):
                            for khoa in ("model", "model_slug"):
                                if goc.get(khoa):
                                    mo_hinh = str(goc[khoa])
                                    break
                        if mo_hinh:
                            break

                p = o.get("payload") or {}
                if p.get("type") == "token_count":
                    info = p.get("info") or {}
                    if info.get("total_token_usage"):
                        token = info["total_token_usage"]
                    if p.get("rate_limits"):
                        han_muc = p["rate_limits"]
    except OSError:
        return None, None, ""
    return token, han_muc, mo_hinh


def _phan_tram(han_muc) -> str:
    """Lấy phần trăm đã dùng cao nhất trong các cửa sổ hạn mức."""
    if not isinstance(han_muc, dict):
        return ""
    cac = [
        v.get("used_percent")
        for v in han_muc.values()
        if isinstance(v, dict) and isinstance(v.get("used_percent"), (int, float))
    ]
    return f"{max(cac):.0f}" if cac else ""


def lenh_codex_phien(tu_epoch: float) -> int:
    tep = _phien_codex_moi_nhat(tu_epoch)
    if tep is None:
        print("\t\t\t\t\t")  # giữ đúng số cột để bash đọc không lệch
        return 1

    token, han_muc, mo_hinh = _doc_phien(tep)
    if not token:
        print(f"{mo_hinh}\t\t\t\t\t{_phan_tram(han_muc)}")
        return 1

    vao = int(token.get("input_tokens") or 0)
    dem = int(token.get("cached_input_tokens") or 0)
    ra = int(token.get("output_tokens") or 0)
    tong = int(token.get("total_tokens") or (vao + ra))
    # input_tokens của Codex đã GỘP phần đọc từ đệm — tách ra để so được với
    # cách Claude Code ghi (hai trường riêng).
    print(f"{mo_hinh or '(không xác định)'}\t{vao - dem}\t{dem}\t{ra}\t{tong}\t{_phan_tram(han_muc)}")
    return 0


def lenh_han_muc() -> int:
    tep = _phien_codex_moi_nhat(0)
    if tep is None:
        return 1
    _, han_muc, _ = _doc_phien(tep)
    pt = _phan_tram(han_muc)
    if not pt:
        return 1
    print(pt)
    return 0


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    lenh = sys.argv[1]
    if lenh == "codex-phien":
        try:
            tu = float(sys.argv[2]) if len(sys.argv) > 2 else 0.0
        except ValueError:
            tu = 0.0
        return lenh_codex_phien(tu)
    if lenh == "han-muc":
        return lenh_han_muc()
    print(f"Lệnh không biết: {lenh}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main())
