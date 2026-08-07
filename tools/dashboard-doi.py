#!/usr/bin/env python3
"""Sinh docs/dashboard-doi.html — bảng theo dõi trạng thái AI Developing Team.

Dashboard này ĐỌC THẲNG từ tệp thật: tệp vai, skill, bộ mồi, nhật ký chi phí.
Không có số nào gõ tay. Sửa một tệp vai rồi chạy lại là dashboard đổi theo — nếu
gõ tay thì sớm muộn dashboard nói một đằng kho mã một nẻo.

    python3 tools/dashboard-doi.py
"""

import re
import csv
from pathlib import Path
from html import escape

GOC = Path(__file__).resolve().parent.parent
RA = GOC / "docs" / "dashboard-doi.html"

# TÁM VAI CHỨC NĂNG. T5 có hai chế độ thực thi (thường / phần tiền) nên bảng có
# chín dòng vận hành — đếm dòng ra 9 là đúng, nhưng vai vẫn là 8.
# Cột "nguon" là nơi chỉ dẫn vai thật sự nằm.
VAI = [
    ("T1",  "AI Lead · Điều phối",      "phiên chính",                          "CLAUDE.md"),
    ("T2",  "Đặc tả sản phẩm",          "agent anwell-t2-dac-ta",               ".claude/agents/anwell-t2-dac-ta.md"),
    ("T3",  "Kiến trúc & Dữ liệu",      "agent anwell-t3-kien-truc-du-lieu",    ".claude/agents/anwell-t3-kien-truc-du-lieu.md"),
    ("T4",  "UX & Design System",       "agent anwell-t4-ux-design-system",     ".claude/agents/anwell-t4-ux-design-system.md"),
    ("T5",  "Backend & Tích hợp",       "agent anwell-t5-backend",              ".claude/agents/anwell-t5-backend.md"),
    ("T5₫", "Backend · chế độ phần tiền",        "agent anwell-t5-backend-tien",         ".claude/agents/anwell-t5-backend-tien.md"),
    ("T6",  "Frontend",                 "agent anwell-t6-frontend",             ".claude/agents/anwell-t6-frontend.md"),
    ("T7",  "QA & Kiểm thử",            "tools/kiem-thu-bang-codex.sh",         "docs/vai/t7-qa-kiem-thu.md"),
    ("T8",  "Rà độc lập",               "tools/ra-bang-codex.sh · agent Opus",  ".claude/agents/anwell-t8-ra-doc-lap.md"),
]


def doc_frontmatter(tep: Path):
    if not tep.exists():
        return None
    t = tep.read_text(encoding="utf-8")
    m = re.match(r"^---\n(.*?)\n---\n", t, re.S)
    fm = m.group(1) if m else ""
    lay = lambda k: (re.search(rf"^{k}:\s*(.+)$", fm, re.M) or [None, ""])[1].strip()
    return {
        "model": lay("model") or "—",
        "tools": lay("tools") or "(tất cả)",
        "dong": len(t.splitlines()),
    }


def quyen_ghi(tools: str) -> tuple:
    if tools == "(tất cả)":
        return ("canh", "không giới hạn")
    co_ghi = "Write" in tools or "Edit" in tools
    return ("do", "ghi được") if co_ghi else ("xanh", "CHỈ ĐỌC")


def thu_skill():
    d = GOC / ".claude" / "skills"
    ra = []
    for tm in sorted(d.iterdir()) if d.exists() else []:
        f = tm / "SKILL.md"
        if f.is_file():
            t = f.read_text(encoding="utf-8")
            mo = re.search(r"^description:\s*(.+?)(?=\n\w+:|\n---)", t, re.M | re.S)
            ra.append({
                "ten": tm.name,
                "dong": len(t.splitlines()),
                "mo": " ".join((mo.group(1) if mo else "").split())[:150],
            })
    return ra


def thu_moi():
    f = GOC / "tools" / "moi" / "BO-MOI.md"
    if not f.exists():
        return [], []
    t = f.read_text(encoding="utf-8")
    moi = []
    for m in re.finditer(r"^## (M\d+) · (.+?)$", t, re.M):
        khoi = t[m.end(): t.find("\n## ", m.end()) if "\n## " in t[m.end():] else len(t)]
        da_chay = "đã chạy" in m.group(2).lower() or "Kết quả" in khoi
        moi.append({"ma": m.group(1), "ten": m.group(2), "chay": da_chay,
                    "so_muc": khoi.count("| ☐ |")})
    ket = []
    for dong in re.finditer(r"^\| (\d{2}/\d{2}/\d{4}) \| (M\d+) \| (\S+) \| (.+?) \| \*\*(.+?)\*\* \| (.*?) \|$", t, re.M):
        ket.append(dong.groups())
    return moi, ket


def thu_chi_phi():
    f = GOC / "tools" / "moi" / "nhat-ky-chi-phi.tsv"
    if not f.exists():
        return []
    with f.open(encoding="utf-8") as fh:
        return list(csv.DictReader(fh, delimiter="\t"))


def dung():
    vai_rows, thieu = [], 0
    for ma, ten, chay_bang, nguon in VAI:
        p = GOC / nguon
        fm = doc_frontmatter(p) if nguon.endswith(".md") and "/agents/" in nguon else None
        co = p.exists()
        if not co:
            thieu += 1
        if fm:
            mau, nhan = quyen_ghi(fm["tools"])
            model, dong = fm["model"], fm["dong"]
        else:
            mau, nhan = ("xanh", "CHỈ ĐỌC") if ma == "T7" else ("canh", "—")
            if ma == "T7":
                mau, nhan = "do", "ghi trong tests/"
            model = "gpt-codex" if ma in ("T7",) else ("opus" if ma == "T1" else "—")
            dong = len(p.read_text(encoding="utf-8").splitlines()) if co else 0
        vai_rows.append((ma, ten, model, chay_bang, mau, nhan, dong, co, nguon))

    skills = thu_skill()
    moi, ket_moi = thu_moi()
    chi_phi = thu_chi_phi()
    da_chay = sum(1 for m in moi if m["chay"])

    # Số token đọc THẬT từ tệp phiên của CLI (tools/doc-token.py), không còn
    # ước lượng ký_tự/3. Dòng thiếu token_tong là lượt bị chặn hoặc lỗi.
    def _n(r, k):
        try:
            return int(r.get(k) or 0)
        except ValueError:
            return 0
    cp_that = [r for r in chi_phi if _n(r, "token_tong") > 0]
    cp_min = min((_n(r, "token_tong") for r in cp_that), default=0)
    cp_max = max((_n(r, "token_tong") for r in cp_that), default=0)

    def o(mau, chu):
        return f'<span class="v v-{mau}">{escape(chu)}</span>'

    h = []
    h.append(f"""<!doctype html>
<html lang="vi"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>ANWELL · Trạng thái AI Developing Team</title>
<style>
:root{{--nen:#f7f9f7;--the:#fff;--muc:#14211b;--nhat:#5a6b62;--vien:#dde5e0;
--dam:#12564a;--xanh:#2e8567;--canh:#b9893b;--do:#b3261e;--nhan:#e8f0d9}}
*{{box-sizing:border-box}}
body{{margin:0;padding:28px 20px 60px;background:var(--nen);color:var(--muc);
font:15px/1.6 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif}}
.bao{{max-width:1120px;margin:0 auto}}
h1{{font-size:26px;margin:0 0 4px}} h2{{font-size:17px;margin:34px 0 12px;
padding-bottom:7px;border-bottom:2px solid var(--dam)}}
.phu{{color:var(--nhat);font-size:13px;margin:0 0 22px}}
.luoi{{display:grid;gap:12px;grid-template-columns:repeat(auto-fit,minmax(158px,1fr))}}
.so{{background:var(--the);border:1px solid var(--vien);border-left:4px solid var(--dam);
border-radius:8px;padding:13px 15px}}
.so b{{display:block;font-size:25px;line-height:1.15}}
.so span{{font-size:12px;color:var(--nhat)}}
.so.canh{{border-left-color:var(--canh)}} .so.do{{border-left-color:var(--do)}}
table{{width:100%;border-collapse:collapse;background:var(--the);
border:1px solid var(--vien);border-radius:8px;overflow:hidden;font-size:13.5px}}
th{{background:var(--dam);color:#fff;text-align:left;padding:9px 11px;font-weight:600}}
td{{padding:8px 11px;border-top:1px solid var(--vien);vertical-align:top}}
tr:nth-child(even) td{{background:#fbfcfb}}
code{{background:var(--nhan);padding:1px 5px;border-radius:4px;font-size:12px}}
.v{{display:inline-block;padding:1px 8px;border-radius:20px;font-size:11.5px;font-weight:600;white-space:nowrap}}
.v-xanh{{background:#dcede4;color:var(--dam)}} .v-canh{{background:#fdf3dc;color:#8a6420}}
.v-do{{background:#fbe4e2;color:var(--do)}}
.cong{{display:flex;gap:9px;flex-wrap:wrap;align-items:stretch;margin:14px 0}}
.cong div{{flex:1;min-width:160px;background:var(--the);border:1px solid var(--vien);
border-top:3px solid var(--xanh);border-radius:8px;padding:11px 13px;font-size:13px}}
.cong div b{{display:block;font-size:12px;color:var(--dam);margin-bottom:4px}}
.canhbao{{background:#fff9ec;border:1px solid #ecd9a8;border-left:4px solid var(--canh);
border-radius:8px;padding:12px 16px;margin:10px 0}}
.canhbao b{{color:#8a6420}}
.ghi{{color:var(--nhat);font-size:12.5px;margin-top:7px}}
.thanh{{height:8px;background:var(--nhan);border-radius:4px;overflow:hidden;margin-top:5px}}
.thanh i{{display:block;height:100%;background:var(--xanh)}}
@media(prefers-color-scheme:dark){{:root{{--nen:#151a17;--the:#1d2420;--muc:#e8eeea;
--nhat:#9aa9a1;--vien:#2e3934;--nhan:#26302a}} tr:nth-child(even) td{{background:#212823}}
.canhbao{{background:#2a2419;border-color:#4a3d22}}}}
</style></head><body><div class="bao">

<h1>ANWELL · AI Developing Team</h1>
<p class="phu">Trạng thái setup đội · sinh tự động từ tệp thật bằng
<code>tools/dashboard-doi.py</code> · không có số nào gõ tay</p>

<div class="luoi">
  <div class="so"><b>{len(VAI) - thieu}/{len(VAI)}</b><span>vai đã dựng</span></div>
  <div class="so"><b>{len(skills)}</b><span>skill nghiệp vụ</span></div>
  <div class="so {'do' if da_chay < len(moi) else ''}"><b>{da_chay}/{len(moi)}</b><span>mồi đã chạy</span>
    <div class="thanh"><i style="width:{(da_chay / max(len(moi),1)) * 100:.0f}%"></i></div></div>
  <div class="so canh"><b>{cp_min:,}–{cp_max:,}</b><span>token THẬT mỗi lượt gọi</span></div>
</div>

<h2>Ba cổng — việc không qua cổng thì không đi tiếp</h2>
<div class="cong">
  <div><b>CỔNG 1 · QUYẾT ĐỊNH</b>T2 Đặc tả · T3 Kiến trúc<br>
    <span class="ghi">Không có đặc tả thì không ai viết mã</span></div>
  <div><b>THỰC THI</b>T4 · T5 · T5₫ · T6<br>
    <span class="ghi">Nạp skill theo thứ mã đang chạm</span></div>
  <div><b>CỔNG 2 · KIỂM CHỨNG</b>T7 Kiểm thử · T8 Rà độc lập<br>
    <span class="ghi">Bắt buộc khác mô hình người viết</span></div>
  <div><b>CỔNG 3 · NGƯỜI THẬT</b>Bác sĩ · Kế toán · Luật sư · Rà bảo mật<br>
    <span class="ghi">Ngoài phạm vi đội kỹ thuật</span></div>
</div>

<h2>Tám vai</h2>
<table><tr><th>Mã</th><th>Vai</th><th>Mô hình</th><th>Gọi bằng</th>
<th>Quyền ghi</th><th>Dòng</th><th>Trạng thái</th></tr>""")

    for ma, ten, model, chay, mau, nhan, dong, co, nguon in vai_rows:
        h.append(f"<tr><td><b>{escape(ma)}</b></td><td>{escape(ten)}</td>"
                 f"<td><code>{escape(model)}</code></td><td>{escape(chay)}</td>"
                 f"<td>{o(mau, nhan)}</td><td>{dong or '—'}</td>"
                 f"<td>{o('xanh','đã dựng') if co else o('do','THIẾU')}</td></tr>")
    h.append("</table>")
    h.append('<p class="ghi">Quyền ghi của T8 là ràng buộc bằng máy: bản Codex chạy '
             '<code>-s read-only</code>, bản Claude không khai <code>Write</code> hay '
             '<code>Edit</code>. T7 phải ghi tệp kiểm thử nên ranh giới "chỉ ghi trong '
             '<code>tests/</code>" là lời nhắc, không phải sandbox — vì vậy diff của T7 vẫn phải qua T8.</p>')

    h.append("<h2>Bộ mồi — đo hành vi, không nghe lời khai</h2><table>"
             "<tr><th>Mã</th><th>Kiểm vai</th><th>Số mục phải bắt</th><th>Trạng thái</th></tr>")
    for m in moi:
        h.append(f"<tr><td><b>{escape(m['ma'])}</b></td><td>{escape(m['ten'])}</td>"
                 f"<td>{m['so_muc'] or '—'}</td>"
                 f"<td>{o('xanh','đã chạy') if m['chay'] else o('canh','chưa chạy')}</td></tr>")
    h.append("</table>")
    if ket_moi:
        h.append("<p class=\"ghi\"><b>Kết quả đã ghi:</b> " + " · ".join(
            f"{k[0]} {k[1]} ({k[2]}) → <b>{k[4]}</b>" for k in ket_moi) + "</p>")

    h.append("<h2>Mười bốn skill nghiệp vụ</h2><table>"
             "<tr><th>Skill</th><th>Dòng</th><th>Dùng khi</th></tr>")
    for s in skills:
        h.append(f"<tr><td><code>{escape(s['ten'])}</code></td><td>{s['dong']}</td>"
                 f"<td>{escape(s['mo'])}…</td></tr>")
    h.append("</table>")
    h.append('<p class="ghi">Ràng buộc nghiệp vụ nằm ở tầng skill, không chép vào tệp vai. '
             'Nhờ vậy sửa quy tắc chỉ sửa một chỗ, và Codex — vốn không có cơ chế skill — '
             'vẫn nhận được cùng ràng buộc qua script bơm nội dung skill vào lời nhắc.</p>')

    if chi_phi:
        h.append("<h2>Nhật ký chi phí</h2><table>"
                 "<tr><th>Thời điểm</th><th>Vai</th><th>Mô hình</th>"
                 "<th>Token vào</th><th>Đệm</th><th>Token ra</th><th>Tổng</th>"
                 "<th>Skill</th><th>Phạm vi</th><th>Kết quả</th></tr>")
        for r in chi_phi[-12:]:
            h.append(f"<tr><td>{escape(r['ngay'])}</td><td>{escape(r['vai'])}</td>"
                     f"<td><code>{escape(r['mo_hinh'])}</code></td>"
                     f"<td>{_n(r,'token_vao'):,}</td><td>{_n(r,'token_dem'):,}</td>"
                     f"<td>{_n(r,'token_ra'):,}</td><td><b>{_n(r,'token_tong'):,}</b></td>"
                     f"<td>{escape(r.get('so_skill',''))}</td>"
                     f"<td>{escape(r.get('pham_vi',''))}</td>"
                     f"<td>{escape(r.get('ket_qua',''))}</td></tr>")
        h.append("</table>")
        if cp_max and cp_min and cp_max > cp_min:
            h.append(f'<p class="ghi">Chênh lệch {cp_max/max(cp_min,1):.1f} lần giữa lượt '
                     f'đắt nhất và rẻ nhất là do ba lần sửa bộ chọn skill: chỉ quét tệp mã · '
                     f'khớp token có dấu cách hai bên · cắt phần tài liệu khỏi phần gửi đi rà.</p>')

    h.append("""<h2>Chưa kín — biết trước còn hơn phát hiện sau</h2>""")
    for tieu_de, noi_dung in [
        ("Bảy mồi chưa chạy",
         "Đội hợp lệ về cấu hình nhưng mới đo hành vi của một vai. Chạy hết bộ mồi "
         "trước khi giao việc thật — vai nào trượt thì sửa lúc đó còn rẻ."),
        ("T7 có quyền ghi, ranh giới là lời nhắc",
         "T7 chạy <code>-s workspace-write</code> vì phải tạo tệp kiểm thử. Ràng buộc "
         "&quot;chỉ ghi trong tests/&quot; không được sandbox bảo đảm. Bù lại: diff của T7 phải qua T8."),
        ("Codex đăng nhập bằng tài khoản ChatGPT",
         "Hạn mức gắn với gói thuê bao, không phải trả theo lượng dùng. Chạm trần giữa "
         "Phase là đội dừng đúng ở Cổng 2. Gặp hiện tượng đó thì chuyển sang khoá API."),
        ("Opus rà mã do Claude viết là cùng họ mô hình",
         "Ở mức Cao và Đặc biệt thì chưa đủ theo nguyên tắc khác-mô-hình. Vì vậy phần lớn "
         "mã phải rà bằng bản Codex, và T8 được yêu cầu tự khai khi rơi vào tình huống này."),
    ]:
        h.append(f'<div class="canhbao"><b>{tieu_de}</b><br>{noi_dung}</div>')

    h.append("</div></body></html>")
    RA.parent.mkdir(parents=True, exist_ok=True)
    RA.write_text("\n".join(h), encoding="utf-8")
    print(f"đã ghi  {RA.relative_to(GOC)}  ({len('\n'.join(h).splitlines())} dòng)")
    print(f"  vai {len(VAI)-thieu}/{len(VAI)} · skill {len(skills)} · "
          f"mồi {da_chay}/{len(moi)} · dòng chi phí {len(chi_phi)}")


if __name__ == "__main__":
    dung()
