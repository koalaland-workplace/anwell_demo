#!/usr/bin/env bash
# Kiểm HÀNH VI của thư viện điều khiển đội, không soi mẫu mã nguồn.
#
# Vì sao có tệp này: bản rà 07/08 tìm ra bảy lỗ, và lần đầu em tự kiểm bằng cách
# grep mẫu trong mã. Cách đó sai ở chỗ nó xác nhận "mã trông giống đã sửa" chứ
# không xác nhận "chạy ra kết quả đúng" — sửa xong thì chính bộ kiểm báo sai.
#
#   tests/team/kiem-control-plane.sh
#
set -uo pipefail
GOC="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$GOC/tools/_nap-skill.sh"

DAT=0; TRUOT=0
ok()   { DAT=$((DAT+1));     printf '  ĐẠT   %s\n' "$1"; }
sai()  { TRUOT=$((TRUOT+1)); printf '  TRƯỢT %s\n     → %s\n' "$1" "${2:-}"; }
kiem() { [ "$2" = "$3" ] && ok "$1" || sai "$1" "mong '$3', nhận '$2'"; }

echo "═══ 3.1 · Control plane phải được coi là mã ═══"
for f in docs/quy-tac-doi.md docs/vai/t7-qa-kiem-thu.md \
         .claude/agents/anwell-t8-ra-doc-lap.md tools/ra-bang-codex.sh; do
  la_tep_ma "$f" && kiem "$f là mã" "mã" "mã" || sai "$f là mã" "bị xếp tài liệu"
done
la_tep_ma "docs/01-tong-quan-san-pham.md" \
  && sai "docs thường vẫn là tài liệu" "bị xếp mã" \
  || ok "docs/01-tong-quan-san-pham.md vẫn là tài liệu"

echo
echo "═══ 3.2 · Quét bí mật phủ dòng xoá và dòng ngữ cảnh ═══"
# Ghép chuỗi lúc chạy để MÃ NGUỒN tệp này không chứa mẫu hoàn chỉnh.
# Nếu viết thẳng, chính tệp kiểm sẽ làm cổng bí mật chặn mọi lượt rà của kho —
# đã gặp thật. Không nới lỏng bộ quét để chiều tệp kiểm: bộ quét đang đúng.
K="sk-""proj-abcdefghij1234567890abcdef"
D="postgres""://u:MatKhau12@h:5432/p"
q() { printf '%s' "$1" | python3 "$GOC/tools/quet-bi-mat.py" >/dev/null 2>&1; echo $?; }
kiem "bí mật ở dòng THÊM bị chặn" \
  "$(q 'diff --git a/a.ts b/a.ts
+++ b/a.ts
+const K = "'"$K"'"')" "3"
kiem "bí mật ở dòng XOÁ bị chặn" \
  "$(q 'diff --git a/a.ts b/a.ts
+++ b/a.ts
-const K = "'"$K"'"')" "3"
kiem "bí mật ở dòng NGỮ CẢNH bị chặn" \
  "$(q 'diff --git a/a.ts b/a.ts
+++ b/a.ts
 const D = "'"$D"'"')" "3"
kiem "diff sạch KHÔNG báo nhầm" \
  "$(q 'diff --git a/a.ts b/a.ts
index ab12cd3..ef45gh6 100644
+++ b/a.ts
+const a = 2')" "0"

echo
echo "═══ 3.3 · Khoá cache đổi khi NỘI DUNG skill đổi ═══"
SKILL_CAN=("anwell-quy-tac-tien")
bam_pham_vi "diff giả" T8 m low; TRUOC="$BAM"
TEP="$GOC/.claude/skills/anwell-quy-tac-tien/SKILL.md"
cp "$TEP" "$TEP.sao"
printf '\n<!-- đổi thử -->\n' >> "$TEP"
bam_pham_vi "diff giả" T8 m low; SAU="$BAM"
mv "$TEP.sao" "$TEP"
[ "$TRUOC" != "$SAU" ] && ok "sửa SKILL.md làm khoá cache đổi" \
  || sai "sửa SKILL.md làm khoá cache đổi" "khoá giữ nguyên $TRUOC"

echo
echo "═══ 3.4 · Mức khai là nguồn chính, phỏng đoán chỉ được NÂNG ═══"
SKILL_CAN=("anwell-muc-do-phase"); MUC_KHAI="dac-biet"; muc_suy_luan
kiem "khai dac-biet, phỏng đoán thấp → giữ high" "$SUY_LUAN_AUTO" "high"
SKILL_CAN=("anwell-quy-tac-tien"); MUC_KHAI="trung-binh"; muc_suy_luan
kiem "khai trung-binh, phỏng đoán nặng → NÂNG lên high" "$SUY_LUAN_AUTO" "high"
MUC_KHAI=""; SKILL_CAN=("anwell-muc-do-phase"); muc_suy_luan
case "$MUC_RUI_RO" in *PHỎNG\ ĐOÁN*) ok "không khai --muc thì nói rõ là phỏng đoán";;
  *) sai "không khai --muc thì nói rõ là phỏng đoán" "$MUC_RUI_RO";; esac

echo
echo "═══ 3.7 · Ảnh chụp T7 phủ cả tệp bị gitignore ═══"
CHUP="$( cd "$GOC" && find . -type f -not -path './.git/*' -not -path './tests/*' \
        -not -path './node_modules/*' -not -name '.DS_Store' -print0 2>/dev/null \
        | xargs -0 shasum -a 1 2>/dev/null )"
for f in assets/doi-ai.js tools/moi/nhat-ky-chi-phi.tsv; do
  if [ -f "$GOC/$f" ]; then
    printf '%s' "$CHUP" | grep -q "$f" \
      && ok "$f (bị gitignore) nằm trong ảnh chụp" \
      || sai "$f nằm trong ảnh chụp" "không thấy"
  fi
done

echo
echo "───────────────────────────────"
printf 'ĐẠT %d · TRƯỢT %d\n' "$DAT" "$TRUOT"
[ "$TRUOT" -eq 0 ]
