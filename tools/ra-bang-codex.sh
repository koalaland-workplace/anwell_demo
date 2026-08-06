#!/usr/bin/env bash
# T8 Rà độc lập — bản chạy bằng GPT-Codex.
#
# Dùng khi mã do Claude viết. Mã do Codex viết thì rà bằng agent
# `anwell-t8-ra-doc-lap` (Claude Opus). Nguyên tắc là NGƯỢC với người viết.
#
# Chỉ dẫn rà KHÔNG viết lại ở đây — lấy thẳng từ tệp vai, một nguồn duy nhất.
#
#   tools/ra-bang-codex.sh                 rà thay đổi chưa commit (gồm tệp chưa git add)
#   tools/ra-bang-codex.sh main..HEAD      rà một khoảng commit
#   tools/ra-bang-codex.sh --xem-tep       chỉ liệt kê tệp sẽ gửi đi, không gửi
#   tools/ra-bang-codex.sh --chi-soan      soạn lời nhắc rồi dừng
#   tools/ra-bang-codex.sh --giu-prompt    không xoá tệp lời nhắc sau khi chạy
#
set -euo pipefail

GOC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAI="$GOC/.claude/agents/anwell-t8-ra-doc-lap.md"
SKILLS="$GOC/.claude/skills"
RA="$(mktemp "${TMPDIR:-/tmp}/anwell-ra-codex-XXXXXX")"

# Lời nhắc chứa toàn bộ mã. Xoá khi thoát, trừ khi được yêu cầu giữ lại.
GIU_PROMPT=0
don_dep() { [ "$GIU_PROMPT" -eq 1 ] || rm -f "$RA"; }
trap don_dep EXIT

# Mô hình và mức suy luận CỐ ĐỊNH ở đây, không để phụ thuộc ~/.codex/config.toml.
# Máy hiện đặt model_reasoning_effort = "low" — hợp cho việc cơ học, không hợp
# cho cổng kiểm chứng ở mức Cao và Đặc biệt.
MO_HINH="${MO_HINH_CODEX:-gpt-5.6-sol}"
# SUY_LUAN để trống = tự suy theo mức rủi ro (xem muc_suy_luan). Đặt biến
# SUY_LUAN_CODEX để ép một mức cố định.
SUY_LUAN="${SUY_LUAN_CODEX:-}"

CHI_SOAN=0; XEM_TEP=0; PHAM_VI=""; EP="${EP:-0}"
for t in "$@"; do
  case "$t" in
    --chi-soan)   CHI_SOAN=1 ;;
    --xem-tep)    XEM_TEP=1 ;;
    --giu-prompt) GIU_PROMPT=1 ;;
    --ep)         EP=1 ;;
    *)            PHAM_VI="$t" ;;
  esac
done

source "$GOC/tools/_nap-skill.sh"

# ── 1. Phạm vi — gồm cả tệp chưa theo dõi ────────────────────────────────────
lay_pham_vi "$PHAM_VI"
NGUON="${PHAM_VI:-thay đổi chưa commit}"

if [ -z "$PV_DIFF" ]; then
  echo "Không có thay đổi nào để rà ($NGUON)." >&2
  exit 0
fi

echo "Phạm vi: $PV_TOM_TAT" >&2
if [ "$XEM_TEP" -eq 1 ]; then
  echo; echo "Sẽ GỬI đi rà:"; printf '%s' "$PV_TEP_GUI"
  echo; echo "Không gửi (tài liệu, mức Thấp):"; printf '%s' "$PV_TEP_BO"
  exit 0
fi

if [ "$PV_CO_MA" -eq 0 ]; then
  echo "Không có tệp mã nào — mức Thấp, không cần rà độc lập." >&2
  printf '%s' "$PV_TEP_BO" >&2
  exit 0
fi

# ── 2. Cổng bí mật — chặn TRƯỚC khi soạn lời nhắc ────────────────────────────
quet_bi_mat "$PV_DIFF"
if [ -n "$BI_MAT_THAY" ]; then
  {
    printf '%s' "$BI_MAT_THAY"   # đã có tiêu đề từ quet-bi-mat.py
    echo
    echo "Commit bí mật thì còn gỡ lịch sử được. Gửi sang dịch vụ AI thì KHÔNG thu hồi được."
    echo "Gỡ bí mật ra khỏi mã rồi chạy lại. Xem tệp nào sẽ gửi: $0 --xem-tep"
    echo "Nếu chắc chắn là báo nhầm: TOI_CHAP_NHAN_GUI=1 $0 $*"
  } >&2
  if [ "${TOI_CHAP_NHAN_GUI:-0}" != "1" ]; then
    ghi_nhat_ky "T8" "$MO_HINH" "" "" "" "" "" "$NGUON" "chặn-bí-mật"
    exit 3
  fi
  echo "⚠  Người dùng chấp nhận gửi dù có cảnh báo bí mật." >&2
fi

# ── 3. Soạn lời nhắc ─────────────────────────────────────────────────────────
chon_skill "$PV_DIFF"
loc_diff_ma "$PV_DIFF"
muc_suy_luan
[ -z "$SUY_LUAN" ] && SUY_LUAN="$SUY_LUAN_AUTO"
echo "Mức rủi ro suy từ skill: $MUC_RUI_RO → suy luận $SUY_LUAN" >&2

# ③ Đã rà đúng nội dung này chưa?
bam_pham_vi "$DIFF_MA" T8 "$MO_HINH" "$SUY_LUAN"
if [ "$EP" -eq 0 ] && [ -f "$BAM_TEP" ]; then
  echo "Đã rà đúng nội dung này lúc $(date -r "$BAM_TEP" '+%d/%m %H:%M') — dùng lại kết quả." >&2
  echo "Muốn rà lại: $0 --ep $*" >&2
  cat "$BAM_TEP"
  exit 0
fi

# ① Tra sẵn — để Codex khỏi phải tự đọc kho
tra_san "$PV_DIFF"

{
  echo "Bạn là T8 Người rà độc lập của ANWELL Developing Team."
  echo "Làm đúng theo chỉ dẫn dưới đây. Trả về đúng khuôn đầu ra được yêu cầu."
  echo
  echo "QUAN TRỌNG: bạn CHỈ ĐỌC. Không sửa tệp nào, không chạy lệnh ghi."
  echo "Mã dưới đây do Claude viết — bạn là mô hình khác, đó là lý do bạn được gọi."
  echo
  echo "Phạm vi lần này: $PV_TOM_TAT"
  echo "Lưu ý: diff có thể chứa tệp MỚI chưa được git theo dõi, và thay đổi CHỈ XOÁ."
  echo "Xoá một kiểm tra quyền, một timeout hay một khoá chống trùng là thay đổi"
  echo "rủi ro cao — soi kỹ phần bị xoá ngang phần được thêm."
  echo
  echo "══════════ CHỈ DẪN VAI ══════════"
  awk 'thanbai {print} /^---$/ {dem++; if (dem==2) thanbai=1}' "$VAI"

  echo
  echo "══════════ RÀNG BUỘC NGHIỆP VỤ ANWELL ══════════"
  in_skill "$SKILLS"

  echo
  echo "══════════ TỆP TRONG PHẠM VI ══════════"
  printf '%s' "$PV_TEP_GUI"
  if [ -n "$PV_TEP_BO" ]; then
    echo "Tệp tài liệu cũng đổi (mức Thấp, không gửi nội dung):"
    printf '%s' "$PV_TEP_BO"
  fi

  echo
  echo "══════════ TRA SẴN — ĐỪNG TỰ ĐỌC LẠI KHO MÃ ══════════"
  echo "Script đã tra hộ: mỗi định danh mới trong diff đã được tìm khắp kho."
  echo "CHỈ mở thêm tệp khi kết quả dưới đây chưa đủ để kết luận."
  echo
  printf '%s' "$TRA_KQ"

  echo
  echo "══════════ THAY ĐỔI CẦN RÀ ($NGUON) ══════════"
  echo '```diff'
  echo "$DIFF_MA"
  echo '```'
} > "$RA"

KY_TU=$(wc -c <"$RA" | tr -d ' ')
echo "Skill đã nạp (${#SKILL_CAN[@]}): ${SKILL_CAN[*]}" >&2
echo "Vì sao: $SKILL_VI_SAO" >&2
echo "Lời nhắc: $KY_TU ký tự" >&2
[ "$KY_TU" -gt "$GIOI_HAN_KY_TU" ] && \
  echo "⚠  Lời nhắc rất lớn. Cân nhắc rà theo từng tệp: $0 <khoảng nhỏ hơn>" >&2

if [ "$CHI_SOAN" -eq 1 ]; then
  GIU_PROMPT=1
  echo "--chi-soan: dừng, chưa gọi Codex. Lời nhắc giữ ở $RA" >&2
  exit 0
fi

if ! command -v codex >/dev/null 2>&1; then
  echo "Chưa cài Codex CLI. Cài: npm install -g @openai/codex" >&2
  exit 127
fi

canh_bao_han_muc

# ── 4. Gọi Codex ─────────────────────────────────────────────────────────────
# -s read-only : sandbox tầng tiến trình — Codex KHÔNG ghi được tệp nào.
# -m / -c      : cố định mô hình và mức suy luận, không phụ thuộc cấu hình máy.
# -            : đọc lời nhắc từ stdin (tham số dòng lệnh giới hạn ~256KB).
BAT_DAU=$(date +%s)
set +e
mkdir -p "$BO_NHO"
codex exec -s read-only -m "$MO_HINH" -c model_reasoning_effort="$SUY_LUAN" \
           -C "$GOC" - < "$RA" | tee "$BAM_TEP.tmp"
MA_THOAT=${PIPESTATUS[0]}
[ $MA_THOAT -eq 0 ] && mv "$BAM_TEP.tmp" "$BAM_TEP" || rm -f "$BAM_TEP.tmp"
set -e

# ── 5. Ghi nhật ký bằng SỐ TOKEN THẬT ────────────────────────────────────────
DO="$(python3 "$GOC/tools/doc-token.py" codex-phien "$BAT_DAU" 2>/dev/null || true)"
IFS=$'\t' read -r M_THAT T_VAO T_DEM T_RA T_TONG T_PT <<< "${DO:-}"
[ -z "${M_THAT:-}" ] && M_THAT="(không xác định)"
ghi_nhat_ky "T8" "$M_THAT" "${T_VAO:-}" "${T_DEM:-}" "${T_RA:-}" "${T_TONG:-}" \
            "${#SKILL_CAN[@]}" "$NGUON" "$([ $MA_THOAT -eq 0 ] && echo xong || echo "lỗi-$MA_THOAT")"
[ -n "${T_TONG:-}" ] && echo "Token thật: vào ${T_VAO:-?} · đệm ${T_DEM:-?} · ra ${T_RA:-?} · tổng ${T_TONG}" >&2
exit $MA_THOAT
