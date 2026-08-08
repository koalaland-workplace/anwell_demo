#!/usr/bin/env bash
# Thư viện dùng chung cho hai vai chạy bằng Codex: T7 kiểm thử, T8 rà độc lập.
#
#   source tools/_nap-skill.sh
#   lay_pham_vi "<khoảng git hoặc rỗng>"   # đặt: PV_DIFF · PV_CO_MA · PV_TOM_TAT · PV_TEP_GUI
#   quet_bi_mat "$PV_DIFF"                 # đặt: BI_MAT_THAY (rỗng = sạch)
#   chon_skill "$PV_DIFF"                  # đặt: SKILL_CAN[] · SKILL_VI_SAO
#   in_skill   "$SKILLS"
#   ghi_nhat_ky ...
#
# ── Bốn lỗi đã sửa, ghi lại để đừng lặp ───────────────────────────────────────
#
# ① Khớp trên tài liệu thay vì trên mã. 03/08: diff có 1.886 dòng markdown mô tả
#    chính các quy tắc này; bộ khớp trúng 35 lần "tiền" — không lần nào ở tệp mã.
#    Nạp cả 12 skill, lời nhắc phình 178.000 ký tự.
#    → Chỉ quét nội dung tệp MÃ.
#
# ② Token ngắn lọt vào giữa từ khác: "tien" khớp pa·tien·t, "vi" khớp ser·vi·ce.
#    → Chuẩn hoá rồi khớp token có dấu cách hai bên.
#
# ③ Xác định "có mã" theo DÒNG THÊM. Một diff chỉ XOÁ — gỡ kiểm quyền, gỡ
#    timeout, gỡ khoá chống trùng — không còn dòng thêm nào, bị xếp mức Thấp và
#    T7 thoát ngay. Đã kiểm chứng: gỡ `if (!kiemQuyen(...)) throw` → CO_MA = 0.
#    → Xác định theo DANH SÁCH TỆP, không theo nội dung dòng thêm.
#
# ④ Danh sách đuôi mã thiếu `.sh`, Dockerfile, migration, workflow CI. Chính ba
#    script điều khiển đội đều là .sh — sửa hỏng T8 thì không ai rà.
#    → Nhận diện theo cả đuôi lẫn đường dẫn.
#
# Viết cho bash 3.2 (bản macOS mặc định) — không dùng mảng kết hợp.

SKILL_TRAN=${SKILL_TRAN:-6}          # trần số skill trong một lời nhắc
NGUONG_RONG=${NGUONG_RONG:-2}        # từ khoá rộng: cần khớp bấy nhiêu lần
GIOI_HAN_KY_TU=${GIOI_HAN_KY_TU:-400000}   # cảnh báo khi lời nhắc quá to

# ── Nhận diện tệp mã ─────────────────────────────────────────────────────────
# Rộng hơn nhiều so với bản đầu. Thiếu ở đây nghĩa là cổng im lặng không chạy.
_DUOI_MA='\.(ts|tsx|js|jsx|mjs|cjs|vue|svelte|py|rb|go|rs|java|kt|swift|php|cs|c|h|cpp|sql|prisma|graphql|proto|sh|bash|zsh|ps1|bat|html|css|scss|less|json|jsonc|ya?ml|toml|ini|cfg|conf|tf|tfvars|gradle|lock)$'
# Theo đường dẫn hoặc tên tệp — thứ không có đuôi quen thuộc nhưng là mã hạ tầng.
_DUONG_MA='(^|/)(Dockerfile|Makefile|Procfile|\.env\.example|justfile)|^(tools|infrastructure|migrations|db/migrate|scripts)/|^\.github/workflows/|^\.claude/(agents|skills)/'
# CONTROL PLANE — tệp điều khiển hành vi của chính đội. Sửa chúng là sửa cơ chế
# kiểm soát, nên LUÔN là mã dù nằm trong docs/ và dù đuôi là .md.
#
# Vì sao tách riêng: bản rà 07/08 chỉ ra docs/quy-tac-doi.md (sinh ra CLAUDE.md,
# AGENTS.md, GEMINI.md) và docs/vai/ (chỉ dẫn T7) đang bị xếp tài liệu mức Thấp.
# Ai nới quyền T7 hoặc đổi quy trình mười bước trong đó thì KHÔNG AI RÀ.
# Đây là lần thứ hai cùng một kiểu lỗi: hôm trước là .sh, lần này là docs/vai/.
_DUONG_CONTROL='^docs/quy-tac-doi\.md$|^docs/vai/|^\.claude/(agents|skills)/|^tools/'

# Tài liệu thuần — kiểm SAU control plane, nếu không docs/vai/ lọt vào đây.
_DUONG_TAILIEU='^(docs|Tailieu-noibo|tools/moi)/'

la_tep_ma() {   # la_tep_ma <đường dẫn>  → 0 nếu là mã
  # Dùng `[[ =~ ]]` của bash, KHÔNG gọi grep.
  #
  # Bản cũ chạy bốn cặp `printf | grep` cho mỗi tệp — tức tới 8 tiến trình con.
  # Một diff 200 tệp sinh ~1.600 tiến trình chỉ để phân loại đường dẫn. Ngày
  # 07/08 máy đã dồn 2.337 tiến trình zombie và mọi lệnh báo
  # `fork: Resource temporarily unavailable`. Hàm này là thủ phạm chính vì nó
  # nằm trong vòng lặp theo tệp.
  #
  # `[[ =~ ]]` khớp ngay trong tiến trình bash — không fork lần nào.
  local t="$1"
  [[ "$t" =~ $_DUONG_CONTROL ]] && return 0
  [[ "$t" =~ $_DUONG_TAILIEU ]] && return 1
  [[ "$t" =~ $_DUONG_MA ]] && return 0
  # Đuôi tệp không phân biệt hoa thường — hạ chữ bằng khai triển tham số,
  # cũng không fork (bash 4 có ${x,,}; bash 3.2 của macOS thì dùng tr, nên
  # chuẩn hoá sẵn một lần ở đây thay vì gọi grep -i).
  local d="$t"
  case "$d" in *[A-Z]*) d="$(printf '%s' "$t" | tr '[:upper:]' '[:lower:]')" ;; esac
  [[ "$d" =~ $_DUOI_MA ]] && return 0
  return 1
}

# ── Phạm vi rà ───────────────────────────────────────────────────────────────
# Gồm cả TỆP CHƯA THEO DÕI. `git diff HEAD` không thấy chúng: một agent tạo API
# hoặc migration mới mà chưa `git add` thì cả T7 lẫn T8 đều bỏ qua trong im lặng.
# Đã kiểm chứng: src/thanh-toan-moi.ts có PHI_NEN_TANG = 0.18 → vô hình.
lay_pham_vi() {   # lay_pham_vi [khoảng git]
  local khoang="${1:-}" f
  PV_DIFF=""; PV_TEP_GUI=""; PV_TEP_BO=""
  local n_moi=0 n_sua=0 n_xoa=0 n_ma=0 n_tl=0

  # 1. Tệp đã theo dõi
  local raw trang tep
  if [ -n "$khoang" ]; then
    raw="$(git -C "$GOC" diff --name-status "$khoang")"
  else
    raw="$(git -C "$GOC" diff --name-status HEAD)"
  fi
  while IFS=$'\t' read -r trang tep _; do
    [ -z "${tep:-}" ] && continue
    case "$trang" in A*) n_moi=$((n_moi+1));; D*) n_xoa=$((n_xoa+1));; *) n_sua=$((n_sua+1));; esac
    if la_tep_ma "$tep"; then
      n_ma=$((n_ma+1)); PV_TEP_GUI="$PV_TEP_GUI  · $tep [$trang]"$'\n'
    else
      n_tl=$((n_tl+1)); PV_TEP_BO="$PV_TEP_BO  · $tep [$trang]"$'\n'
    fi
  done <<< "$raw"

  if [ -n "$khoang" ]; then
    PV_DIFF="$(git -C "$GOC" diff "$khoang")"
  else
    PV_DIFF="$(git -C "$GOC" diff HEAD)"
  fi

  # 2. Tệp chưa theo dõi — dựng diff giả bằng --no-index, KHÔNG đụng vào index
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    # Bỏ tệp nhị phân
    if [ -f "$GOC/$f" ] && ! grep -Iq . "$GOC/$f" 2>/dev/null; then continue; fi
    n_moi=$((n_moi+1))
    if la_tep_ma "$f"; then
      n_ma=$((n_ma+1)); PV_TEP_GUI="$PV_TEP_GUI  · $f [MỚI · chưa git add]"$'\n'
      PV_DIFF="$PV_DIFF"$'\n'"$(git -C "$GOC" diff --no-index -- /dev/null "$f" 2>/dev/null || true)"
    else
      n_tl=$((n_tl+1)); PV_TEP_BO="$PV_TEP_BO  · $f [MỚI · chưa git add]"$'\n'
    fi
  done <<< "$(git -C "$GOC" ls-files --others --exclude-standard)"

  PV_CO_MA=$([ "$n_ma" -gt 0 ] && echo 1 || echo 0)
  PV_TOM_TAT="$n_moi mới · $n_sua sửa · $n_xoa xoá — trong đó $n_ma tệp mã, $n_tl tệp tài liệu"
}

# Giữ lại phần diff của tệp mã. Dùng cho lời nhắc — tài liệu chỉ liệt kê tên.
loc_diff_ma() {   # loc_diff_ma "$PV_DIFF"
  DIFF_MA="$(printf '%s' "$1" | awk -v duoima="$_DUOI_MA" -v duongma="$_DUONG_MA" -v ctl="$_DUONG_CONTROL" -v tl="$_DUONG_TAILIEU" '
    /^diff --git / {
      tep = $4; sub(/^b\//, "", tep)
      giu = (tep ~ ctl) || ((tep !~ tl) && ((tep ~ duongma) || (tolower(tep) ~ tolower(duoima))))
    }
    giu { print }')"
}

# ── Quét bí mật trước khi gửi ra dịch vụ ngoài ───────────────────────────────
# Logic nằm ở tools/quet-bi-mat.py. Viết bằng Python vì mẫu khoá riêng bắt đầu
# bằng dấu gạch (grep hiểu là tham số) và vì BSD grep xử lý ERE khác GNU grep —
# cả hai đã làm cổng này im lặng không chặn ở lần chạy đầu.
quet_bi_mat() {   # quet_bi_mat "$PV_DIFF"   → BI_MAT_THAY rỗng nghĩa là sạch
  local ra
  # `|| true` KHÔNG thừa: quét thấy bí mật thì python trả mã 3, mà dưới `set -e`
  # phép gán thừa hưởng mã đó và giết script ngay tại đây. Mã thoát 3 trùng với
  # mã "đã chặn" nên nhìn như chạy đúng — thực ra thông báo không in, nhật ký
  # không ghi, và người dùng không biết vì sao bị dừng.
  ra="$(printf '%s' "$1" | python3 "$GOC/tools/quet-bi-mat.py" --tep "$PV_TEP_GUI" 2>&1 >/dev/null || true)"
  BI_MAT_THAY="$ra"
}

# ── Chọn skill ───────────────────────────────────────────────────────────────
_chuan_hoa() {
  sed -E 's/([a-z0-9])([A-Z])/\1 \2/g' \
    | tr -c '[:alnum:]\n' ' ' \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/^/ /; s/$/ /'
}

# Quét CẢ dòng thêm lẫn dòng xoá của tệp mã. Xoá một quy tắc tiền vẫn là việc
# chạm tiền — phải nạp skill tiền để người rà biết cái vừa bị gỡ là gì.
_loc_ma() {
  awk -v duoima="$_DUOI_MA" -v duongma="$_DUONG_MA" -v ctl="$_DUONG_CONTROL" -v tl="$_DUONG_TAILIEU" '
    /^\+\+\+ / {
      tep = $2; sub(/^b\//, "", tep)
      la_ma = (tep ~ ctl) || ((tep !~ tl) && ((tep ~ duongma) || (tolower(tep) ~ tolower(duoima))))
      next
    }
    la_ma && /^[+-]/ && !/^(\+\+\+|---)/ { print substr($0, 2) }
  '
}

chon_skill() {
  local ma ma_tho diem_ds="" ten so
  ma_tho="$(printf '%s' "$1" | _loc_ma)"          # dòng mã còn nguyên chữ hoa và dấu
  ma="$(printf '%s' "$ma_tho" | _chuan_hoa)"

  # Chỉ MỘT skill nền. `danh-muc-chuan` từng luôn được nạp, nhưng sửa CI hay CSS
  # thì nó là token thừa — chuyển sang nạp theo từ khoá như mọi skill khác.
  SKILL_CAN=("anwell-muc-do-phase")
  SKILL_VI_SAO="nền: muc-do-phase"

  if [ "${PV_CO_MA:-1}" -eq 0 ]; then
    SKILL_VI_SAO="$SKILL_VI_SAO · không có tệp mã"
    return 0
  fi

  # HAI TẦNG NGƯỠNG.
  # Tầng CAO — một lần khớp là đủ. Đây là những dấu hiệu mà bỏ sót thì hỏng thật:
  # `const taxRate = 1.1` chỉ khớp một lần nhưng là vi phạm tham số chính sách.
  # Tầng RỘNG — từ chung chung, cần khớp nhiều lần mới đáng kéo cả skill vào.
  _cao()  { _dem "$ma" "$1" "$2" 1; }
  _rong() { _dem "$ma" "$1" "$2" "$NGUONG_RONG"; }
  # Khớp trên dòng mã CÒN NGUYÊN — cần cho những mẫu mà chuẩn hoá làm mất:
  # tên hằng viết hoa, dấu chấm thập phân, phép nhân.
  _tho()  { _dem "$ma_tho" "$1" "$2" 1; }
  _dem() {
    local n; n=$( { printf '%s' "$1" | grep -oE "$3" || true; } | wc -l | tr -d ' ')
    [ "$n" -ge "$4" ] && diem_ds="$diem_ds$n $2"$'\n'
    return 0
  }

  # ── Ba mẫu bắt "con số nghiệp vụ ghi cứng" ─────────────────────────────────
  # Đây là vi phạm tốn kém nhất và cũng khó thấy nhất — nó chỉ là một dòng gán.
  # Test tự phát hiện: `PHI_NEN_TANG = 0.18` trước đây không kéo được skill nào.
  #
  # ① hằng viết hoa gán bằng số:  const TY_LE_LUONG = 30
  _tho anwell-tham-so-chinh-sach \
    '(const|let|var|final|static|readonly)[[:space:]]+[A-Z][A-Z_0-9]{2,}[[:space:]]*(:[^=]*)?=[[:space:]]*-?[0-9]'
  # ② số thực trong biểu thức tính — vi phạm quy tắc tiền số nguyên
  _tho anwell-quy-tac-tien '[*/+-][[:space:]]*[0-9]*\.[0-9]+|[0-9]*\.[0-9]+[[:space:]]*[*/]'
  # ③ phần trăm hoặc tỷ lệ viết thẳng
  _tho anwell-tham-so-chinh-sach '[0-9]+(\.[0-9]+)?[[:space:]]*(%|percent)|\/[[:space:]]*100\b'

  _cao  anwell-quy-tac-tien \
    ' (thanhtoan|payment|payroll|invoice|wallet|idempot) |thanh toan|doi soat|hoan tien|hoa don|khoa chong trung|phi nen tang|phi dich vu'
  _rong anwell-quy-tac-tien \
    ' (tien|gia|thue|luong|phi|fee|amount|price|money|tax|refund|commission|vnd) '
  _cao  anwell-tham-so-chinh-sach \
    ' (taxrate|rate|percent|nguong|threshold|hieuluc) |ty le|han muc|so buoi|thoi han|[0-9]+ (percent|phan tram)'
  _rong anwell-tham-so-chinh-sach ' (limit|min|max|expir|config) '
  _cao  anwell-du-lieu-ca-nhan \
    ' (cccd|cmnd|pii) |ho so suc khoe|health record|giay to|so dien thoai|dia chi'
  _rong anwell-du-lieu-ca-nhan ' (phone|address|personal|document|identity) '
  _cao  anwell-du-lieu-bat-bien \
    ' (immutable|appendonly) |audit log|nhat ky thao tac|check in|check out|toa do|bien dong vi|update .* set|delete from'
  _rong anwell-du-lieu-bat-bien ' (coordinate|ledger|log) '
  _cao  anwell-an-toan-ca-tai-nha \
    ' (sos|geofence) |ma xac minh|verify code|chia se vi tri|share location|che so|tai nha|home visit'
  _rong anwell-an-toan-ca-tai-nha ' (location|gps|dinh vi|tracking) '
  _cao  anwell-ba-nhom-khach \
    ' (masksdt|maskphone) |nhom khach|khach rieng|khach cua trung tam|customer group'
  _rong anwell-ba-nhom-khach ' (khach|customer|client|ktv|technician) '
  _cao  anwell-suc-khoe-chong-chi-dinh \
    ' (contraindication) |chong chi dinh|the chuan bi|bac nang luc|certification tier'
  _rong anwell-suc-khoe-chong-chi-dinh ' (health|suc khoe|bac|tier|chung chi) '
  _cao  anwell-viet-tieng-viet ' (arialabel|placeholder) |thong bao loi|nhan nut'
  _rong anwell-viet-tieng-viet ' (label|nhan|message|title|button|toast|alert) '
  _cao  anwell-kien-truc \
    ' (migration) |create table|alter table|drop table|packages /'
  _rong anwell-kien-truc ' (schema|module|import|export) '
  _cao  anwell-danh-muc-chuan \
    ' (danhmuc|catalog) |danh muc|loai hinh dich vu|hang thiet bi'
  _rong anwell-danh-muc-chuan ' (enum|const .* \[|dich vu|service type) '

  # Gộp điểm trùng tên (một skill có thể trúng cả hai tầng), xếp giảm dần.
  while read -r so ten; do
    [ -z "$ten" ] && continue
    case " ${SKILL_CAN[*]} " in *" $ten "*) continue;; esac
    if [ "${#SKILL_CAN[@]}" -ge "$SKILL_TRAN" ]; then
      SKILL_VI_SAO="$SKILL_VI_SAO · (cắt ở trần $SKILL_TRAN)"; break
    fi
    SKILL_CAN+=("$ten")
    SKILL_VI_SAO="$SKILL_VI_SAO · ${ten#anwell-}=${so}"
  done <<< "$(printf '%s' "$diem_ds" | awk '{t[$2]+=$1} END{for(k in t) print t[k], k}' | sort -rn)"

  unset -f _cao _rong _dem
}

in_skill() {
  local thu_muc="$1" ten tep
  echo "Bạn không có cơ chế nạp skill tự động. Nội dung skill được chép sẵn dưới đây."
  for ten in "${SKILL_CAN[@]}"; do
    tep="$thu_muc/$ten/SKILL.md"
    if [ -f "$tep" ]; then
      echo; echo "───── skill: $ten ─────"; cat "$tep"
    else
      echo "CẢNH BÁO: thiếu $tep" >&2
    fi
  done
}

# ── Tra sẵn: tìm hộ Codex thay vì để nó tự đọc cả kho ────────────────────────
# Logic ở tools/tra-san.py. Viết bằng Python vì bản bash dùng `git grep` trong
# vòng lặp cộng process substitution đã vỡ trên BSD grep — đúng kiểu lỗi đã gặp
# ở quét bí mật. Bash không hợp để xử lý danh sách và biểu thức.
tra_san() {   # tra_san "$PV_DIFF"  → TRA_KQ
  TRA_KQ="$(printf '%s' "$1" | python3 "$GOC/tools/tra-san.py" --tep "$PV_TEP_GUI" 2>/dev/null || true)"
}

# ── Mức suy luận theo mức rủi ro ─────────────────────────────────────────────
# Ghim cứng "medium" cho mọi lượt là lãng phí: phép thử mồi M8 đạt 5/5 khi máy
# đang để "low". Phần lớn đầu việc là mức Trung bình.
# Suy mức rủi ro từ chính bộ skill đã chọn — tín hiệu đã có sẵn, không thêm khái niệm.
muc_suy_luan() {   # → MUC_RUI_RO · SUY_LUAN_AUTO
  # Suy từ bộ skill đã chọn. ĐÂY LÀ PHỎNG ĐOÁN, không phải phân mức chính thức:
  # quy trình nói T1 phân mức trước khi bắt đầu (quy-tac-doi.md mục 4).
  # Một diff xoá kiểm tra quyền có thể không chứa từ khoá nào đủ rõ.
  local s=" ${SKILL_CAN[*]} "
  case "$s" in
    *quy-tac-tien*|*du-lieu-bat-bien*|*an-toan-ca-tai-nha*)
      MUC_RUI_RO="Đặc biệt/Cao"; SUY_LUAN_AUTO="high" ;;
    *du-lieu-ca-nhan*|*ba-nhom-khach*|*suc-khoe-chong-chi-dinh*|*kien-truc*)
      MUC_RUI_RO="Cao";          SUY_LUAN_AUTO="medium" ;;
    *)
      MUC_RUI_RO="Trung bình";   SUY_LUAN_AUTO="low" ;;
  esac

  # Mức do người khai (--muc) là NGUỒN CHÍNH. Phỏng đoán chỉ được NÂNG lên,
  # không được hạ xuống — nếu không thì một suy đoán hụt sẽ âm thầm biến việc
  # mức Đặc biệt thành lượt rà qua loa.
  if [ -n "${MUC_KHAI:-}" ]; then
    local h_khai h_doan
    case "$MUC_KHAI" in
      thap)       h_khai=0; SUY_LUAN_KHAI="low" ;;
      trung-binh) h_khai=1; SUY_LUAN_KHAI="low" ;;
      cao)        h_khai=2; SUY_LUAN_KHAI="medium" ;;
      dac-biet)   h_khai=3; SUY_LUAN_KHAI="high" ;;
      *) echo "Mức không hợp lệ: $MUC_KHAI (thap|trung-binh|cao|dac-biet)" >&2; return 1 ;;
    esac
    case "$SUY_LUAN_AUTO" in low) h_doan=1 ;; medium) h_doan=2 ;; *) h_doan=3 ;; esac
    if [ "$h_doan" -gt "$h_khai" ]; then
      MUC_RUI_RO="$MUC_KHAI → NÂNG lên $MUC_RUI_RO (phỏng đoán thấy dấu hiệu nặng hơn)"
    else
      MUC_RUI_RO="$MUC_KHAI (do người khai)"; SUY_LUAN_AUTO="$SUY_LUAN_KHAI"
    fi
  else
    MUC_RUI_RO="$MUC_RUI_RO · PHỎNG ĐOÁN — chưa ai khai mức bằng --muc"
  fi
}

# ── Bỏ qua nếu đã rà đúng nội dung này rồi ───────────────────────────────────
# Nhật ký từng có ba dòng trùng do chạy thử lại — đó là tiền vứt đi.
BO_NHO="${BO_NHO:-$GOC/tools/moi/.da-ra}"

bam_pham_vi() {   # bam_pham_vi <diff mã> <vai> <mô hình> <suy luận> [tệp vai] [tệp đặc tả]
  # Khoá phải gồm NỘI DUNG, không chỉ tên. Bản đầu chỉ băm tên skill — sửa quy
  # tắc trong một SKILL.md rồi chạy lại thì vẫn nhận kết quả rà cũ, vì tên
  # không đổi. Cache trả lời sai còn tệ hơn không có cache.
  local noi_dung="" s
  for s in "${SKILL_CAN[@]}"; do
    [ -f "$GOC/.claude/skills/$s/SKILL.md" ] && noi_dung="$noi_dung$(cat "$GOC/.claude/skills/$s/SKILL.md")"
  done
  [ -n "${5:-}" ] && [ -f "$5" ] && noi_dung="$noi_dung$(cat "$5")"          # tệp vai
  [ -n "${6:-}" ] && [ -f "$6" ] && noi_dung="$noi_dung$(cat "$6")"          # đặc tả
  # Phiên bản chính script và thư viện — sửa cách rà thì kết quả cũ hết giá trị
  noi_dung="$noi_dung$(cat "$GOC/tools/_nap-skill.sh" "$GOC/tools/quet-bi-mat.py" 2>/dev/null)"

  BAM="$(printf '%s|%s|%s|%s|%s|%s' "$1" "$2" "$3" "$4" "${SKILL_CAN[*]}" "$noi_dung" \
        | shasum -a 256 | cut -c1-16)"
  BAM_TEP="$BO_NHO/$BAM.txt"
}


# ── Nhật ký chi phí ──────────────────────────────────────────────────────────
# Tệp này bị .gitignore. Lý do: T8 là vai CHỈ ĐỌC, mà ghi vào cây làm việc thì
# lần rà sau lại thấy chính dòng nhật ký của lần trước trong diff.
# Số token là SỐ THẬT đọc từ tệp phiên của CLI, không phải ước lượng ký tự/3.
NHAT_KY="${NHAT_KY:-$GOC/tools/moi/nhat-ky-chi-phi.tsv}"

ghi_nhat_ky() {   # ghi_nhat_ky <vai> <mô hình> <vào> <đệm> <ra> <tổng> <số skill> <phạm vi> <kết quả>
  [ -f "$NHAT_KY" ] || printf 'ngay\tvai\tmo_hinh\ttoken_vao\ttoken_dem\ttoken_ra\ttoken_tong\tso_skill\tpham_vi\tket_qua\n' > "$NHAT_KY"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$(date '+%Y-%m-%d %H:%M')" "$1" "${2:-(không xác định)}" \
    "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}" "${9:-}" >> "$NHAT_KY"
}

# Cảnh báo hạn mức gói thuê bao. Chạm trần là T7/T8 dừng — cổng hỏng mà không
# báo lỗi rõ ràng, kiểu hỏng khó chẩn đoán nhất.
canh_bao_han_muc() {
  local pt
  pt="$(python3 "$GOC/tools/doc-token.py" han-muc 2>/dev/null || true)"
  [ -z "$pt" ] && return 0
  if [ "$pt" -ge "${NGUONG_HAN_MUC:-80}" ]; then
    echo "⚠  HẠN MỨC CODEX ĐÃ DÙNG ${pt}% — chạm trần là T7 và T8 dừng." >&2
    echo "   Chuẩn bị khoá API OpenAI làm đường lùi." >&2
  else
    echo "hạn mức Codex: ${pt}%" >&2
  fi
}
