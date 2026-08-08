#!/usr/bin/env bash
# T7 QA & Kiểm thử — chạy bằng GPT-Codex.
#
# Người viết kiểm thử phải KHÁC mô hình với người viết mã.
# Chỉ dẫn vai KHÔNG viết lại ở đây — lấy từ docs/vai/t7-qa-kiem-thu.md.
#
#   tools/kiem-thu-bang-codex.sh                    kiểm thay đổi chưa commit
#   tools/kiem-thu-bang-codex.sh main..HEAD         kiểm một khoảng commit
#   tools/kiem-thu-bang-codex.sh --dac-ta APP-B05   kèm đặc tả lấy tiêu chí nghiệm thu
#   tools/kiem-thu-bang-codex.sh --xem-tep          liệt kê tệp sẽ gửi, không gửi
#   tools/kiem-thu-bang-codex.sh --chi-soan         soạn lời nhắc rồi dừng
#
set -euo pipefail

GOC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAI="$GOC/docs/vai/t7-qa-kiem-thu.md"
SKILLS="$GOC/.claude/skills"
RA="$(mktemp "${TMPDIR:-/tmp}/anwell-kiemthu-XXXXXX")"

GIU_PROMPT=0
don_dep() { [ "$GIU_PROMPT" -eq 1 ] || rm -f "$RA"; }
trap don_dep EXIT

MO_HINH="${MO_HINH_CODEX:-gpt-5.6-sol}"
SUY_LUAN="${SUY_LUAN_CODEX:-}"   # trống = tự suy theo mức rủi ro

CHI_SOAN=0; XEM_TEP=0; PHAM_VI=""; MA_DAC_TA=""; EP="${EP:-0}"; MUC_KHAI="${MUC_KHAI:-}"; NGUOI_VIET="${NGUOI_VIET:-}"
while [ $# -gt 0 ]; do
  case "$1" in
    --chi-soan)   CHI_SOAN=1 ;;
    --xem-tep)    XEM_TEP=1 ;;
    --giu-prompt) GIU_PROMPT=1 ;;
    --ep)         EP=1 ;;
    --muc)        MUC_KHAI="${2:-}"; shift ;;
    --nguoi-viet) NGUOI_VIET="${2:-}"; shift ;;
    --dac-ta)     MA_DAC_TA="${2:-}"; shift ;;
    *)            PHAM_VI="$1" ;;
  esac
  shift
done

source "$GOC/tools/_nap-skill.sh"

# ── 1. Phạm vi ───────────────────────────────────────────────────────────────
lay_pham_vi "$PHAM_VI"
NGUON="${PHAM_VI:-thay đổi chưa commit}"
[ -z "$PV_DIFF" ] && { echo "Không có thay đổi nào để kiểm ($NGUON)." >&2; exit 0; }

echo "Phạm vi: $PV_TOM_TAT" >&2
if [ "$XEM_TEP" -eq 1 ]; then
  echo; echo "Sẽ GỬI:"; printf '%s' "$PV_TEP_GUI"
  echo; echo "Không gửi:"; printf '%s' "$PV_TEP_BO"; exit 0
fi

if [ "$PV_CO_MA" -eq 0 ]; then
  echo "Không có tệp mã nào — mức Thấp, không cần sinh kiểm thử." >&2
  exit 0
fi

# ── 2. Cổng bí mật ───────────────────────────────────────────────────────────
quet_bi_mat "$PV_DIFF"
if [ -n "$BI_MAT_THAY" ]; then
  {
    printf '%s' "$BI_MAT_THAY"   # đã có tiêu đề từ quet-bi-mat.py
    echo; echo "Gửi sang dịch vụ AI thì không thu hồi được. Gỡ ra rồi chạy lại."
  } >&2
  if [ "${TOI_CHAP_NHAN_GUI:-0}" != "1" ]; then
    ghi_nhat_ky "T7" "$MO_HINH" "" "" "" "" "" "$NGUON" "chặn-bí-mật"
    exit 3
  fi
fi

# ── 3. Chụp cây làm việc TRƯỚC khi chạy ──────────────────────────────────────
# T7 cần quyền ghi để tạo tệp kiểm thử, nên sandbox phải là workspace-write.
# Ranh giới "chỉ ghi trong tests/" vì thế là lời nhắc, không phải ràng buộc máy.
# Chụp trước — so sau là cách bắt được nếu nó ghi ra ngoài, ngay lập tức, thay
# vì chờ T8 phát hiện sau khi thay đổi đã xảy ra.
TRUOC="$(mktemp "${TMPDIR:-/tmp}/anwell-t7-truoc-XXXXXX")"
SAU="$(mktemp "${TMPDIR:-/tmp}/anwell-t7-sau-XXXXXX")"
chup_cay() {   # chup_cay <tệp đích> — hash mọi tệp NGOÀI tests/
  # Duyệt HỆ TỆP THẬT, không dùng `git ls-files`. Bản đầu dùng git nên bỏ sót
  # mọi tệp bị .gitignore — mà chính assets/doi-ai.js và nhật ký chi phí nằm ở
  # đó. T7 sửa chúng thì không ai biết. Tệp .env hay credential tạm cũng vậy.
  ( cd "$GOC" && find . -type f \
      -not -path './.git/*' -not -path './tests/*' \
      -not -path './node_modules/*' -not -path './.venv/*' \
      -not -name '.DS_Store' \
      -print0 2>/dev/null \
    | xargs -0 shasum -a 1 2>/dev/null | sort ) > "$1"
}
don_dep_t7() { rm -f "$TRUOC" "$SAU"; don_dep; }
trap don_dep_t7 EXIT

# ── 4. Soạn lời nhắc ─────────────────────────────────────────────────────────
chon_skill "$PV_DIFF"
SKILL_CAN+=("anwell-kiem-thu-truoc-khi-day")   # T7 luôn cần skill kiểm thử
loc_diff_ma "$PV_DIFF"
muc_suy_luan
[ -z "$SUY_LUAN" ] && SUY_LUAN="$SUY_LUAN_AUTO"
echo "Mức rủi ro suy từ skill: $MUC_RUI_RO → suy luận $SUY_LUAN" >&2

bam_pham_vi "$DIFF_MA" T7 "$MO_HINH" "$SUY_LUAN" "$VAI" "${TEP_DT:-}"
if [ "$EP" -eq 0 ] && [ -f "$BAM_TEP" ]; then
  echo "Đã sinh kiểm thử cho đúng nội dung này lúc $(date -r "$BAM_TEP" '+%d/%m %H:%M')." >&2
  echo "Muốn chạy lại: $0 --ep $*" >&2
  cat "$BAM_TEP"; exit 0
fi

tra_san "$PV_DIFF"

{
  echo "Bạn là T7 QA & Kiểm thử của ANWELL Developing Team."
  # Không khẳng định bừa ai viết. Bản đầu ghi cứng "do Claude viết" — nếu mã do
  # Codex viết mà Codex rà thì nguyên tắc ② đã mất, trong khi lời nhắc vẫn nói
  # ngược lại. Khai sai còn tệ hơn không khai.
  case "${NGUOI_VIET:-}" in
    claude) echo "Mã dưới đây do CLAUDE viết — bạn là mô hình khác, đó là lý do bạn được gọi." ;;
    codex)  echo "CẢNH BÁO ĐỘC LẬP: mã dưới đây do CODEX viết, và bạn cũng là Codex."
            echo "Nguyên tắc người-rà-khác-mô-hình KHÔNG được thoả ở lượt này."
            echo "Hãy ghi rõ điều đó trong kết luận và đề nghị rà lại bằng Claude Opus." ;;
    human|gemini) echo "Mã dưới đây do ${NGUOI_VIET} viết — bạn là mô hình khác." ;;
    *)      echo "CHƯA KHAI ai viết mã (thiếu --nguoi-viet). Không chứng minh được"
            echo "tính độc lập giữa người viết và người rà. Ghi rõ điều này trong kết luận;"
            echo "nếu việc ở mức Cao hoặc Đặc biệt thì coi như CHƯA qua Cổng 2." ;;
  esac
  echo
  echo "RANH GIỚI: bạn CHỈ được ghi tệp trong thư mục tests/."
  echo "Mọi tệp ngoài tests/ sẽ bị đối chiếu hash sau khi bạn chạy xong; sửa ra"
  echo "ngoài là lỗi và sẽ bị báo. Kiểm thử đỏ nghĩa là mã sai hoặc đặc tả sai —"
  echo "cả hai đều không phải việc bạn tự sửa. Báo lại, đừng sửa cho xanh."
  echo
  echo "Phạm vi lần này: $PV_TOM_TAT"
  echo
  echo "══════════ CHỈ DẪN VAI ══════════"
  cat "$VAI"

  echo; echo "══════════ ĐẶC TẢ ══════════"
  if [ -n "$MA_DAC_TA" ]; then
    TEP_DT="$GOC/docs/specifications/$MA_DAC_TA.md"
    if [ -f "$TEP_DT" ]; then
      echo "Viết kiểm thử THẲNG TỪ mục 'Tiêu chí nghiệm thu' dưới đây, không viết từ mã."
      echo; cat "$TEP_DT"
    else
      echo "CẢNH BÁO: không thấy $TEP_DT. Báo lại là thiếu đặc tả, đừng tự suy."
    fi
  else
    echo "Không truyền mã đặc tả. Nếu thay đổi này ở mức Trung bình trở lên thì"
    echo "phải có đặc tả — báo lại là thiếu, đừng tự suy tiêu chí nghiệm thu."
  fi

  echo; echo "══════════ RÀNG BUỘC NGHIỆP VỤ ANWELL ══════════"
  in_skill "$SKILLS"

  echo; echo "══════════ TỆP TRONG PHẠM VI ══════════"
  printf '%s' "$PV_TEP_GUI"

  echo; echo "══════════ TRA SẴN — ĐỪNG TỰ ĐỌC LẠI KHO MÃ ══════════"
  echo "Script đã tra hộ mọi định danh mới. CHỈ mở thêm tệp khi chưa đủ kết luận."
  echo; printf '%s' "$TRA_KQ"

  echo; echo "══════════ THAY ĐỔI CẦN KIỂM ($NGUON) ══════════"
  echo '```diff'; echo "$DIFF_MA"; echo '```'
} > "$RA"

KY_TU=$(wc -c <"$RA" | tr -d ' ')
echo "Skill đã nạp (${#SKILL_CAN[@]}): ${SKILL_CAN[*]}" >&2
echo "Vì sao: $SKILL_VI_SAO" >&2
echo "Đặc tả: ${MA_DAC_TA:-(không có)}" >&2
echo "Lời nhắc: $KY_TU ký tự" >&2

if [ "$CHI_SOAN" -eq 1 ]; then
  GIU_PROMPT=1
  echo "--chi-soan: dừng, chưa gọi Codex. Lời nhắc ở $RA" >&2
  exit 0
fi

command -v codex >/dev/null 2>&1 || { echo "Chưa cài Codex CLI." >&2; exit 127; }
canh_bao_han_muc

chup_cay "$TRUOC"
BAT_DAU=$(date +%s)
set +e
mkdir -p "$BO_NHO"
codex exec -s workspace-write -m "$MO_HINH" -c model_reasoning_effort="$SUY_LUAN" \
           -C "$GOC" - < "$RA" | tee "$BAM_TEP.tmp"
MA_THOAT=${PIPESTATUS[0]}
[ $MA_THOAT -eq 0 ] && mv "$BAM_TEP.tmp" "$BAM_TEP" || rm -f "$BAM_TEP.tmp"
set -e
chup_cay "$SAU"

# ── 5. Kiểm T7 có ghi ra ngoài tests/ không ──────────────────────────────────
VI_PHAM="$(comm -3 "$TRUOC" "$SAU" | awk '{print $NF}' | sort -u | grep -v '^$' || true)"
if [ -n "$VI_PHAM" ]; then
  {
    echo
    echo "⛔ T7 ĐÃ SỬA TỆP NGOÀI tests/ — vi phạm ranh giới vai:"
    printf '  · %s\n' $VI_PHAM
    echo
    echo "KHÔNG tự hoàn tác, và script cũng không gợi ý lệnh hoàn tác."
    echo "Lý do: cây làm việc có thể đang chứa thay đổi hợp lệ chưa commit của"
    echo "anh ở đúng những tệp đó. Một lệnh khôi phục gộp sẽ xoá luôn cả phần"
    echo "đó — mất dữ liệu nặng hơn chính vi phạm đang báo."
    echo
    echo "Xem T7 đã đổi gì trước khi quyết:"
    for _f in $VI_PHAM; do echo "    git diff -- $_f"; done
  } >&2
  MA_THOAT=4
fi

DO="$(python3 "$GOC/tools/doc-token.py" codex-phien "$BAT_DAU" 2>/dev/null || true)"
IFS=$'\t' read -r M_THAT T_VAO T_DEM T_RA T_TONG T_PT <<< "${DO:-}"
[ -z "${M_THAT:-}" ] && M_THAT="(không xác định)"
ghi_nhat_ky "T7" "$M_THAT" "${T_VAO:-}" "${T_DEM:-}" "${T_RA:-}" "${T_TONG:-}" \
            "${#SKILL_CAN[@]}" "$NGUON" \
            "$([ -n "$VI_PHAM" ] && echo "ghi-ngoài-tests" || { [ $MA_THOAT -eq 0 ] && echo xong || echo "lỗi-$MA_THOAT"; })"
[ -n "${T_TONG:-}" ] && echo "Token thật: vào ${T_VAO:-?} · đệm ${T_DEM:-?} · ra ${T_RA:-?} · tổng ${T_TONG}" >&2
exit $MA_THOAT
