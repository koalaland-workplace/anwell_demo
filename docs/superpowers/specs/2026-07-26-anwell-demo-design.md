# ANWELL Demo — Thiết kế tái cấu trúc & tài liệu

Ngày: 2026-07-26
Repo: https://github.com/koalaland-workplace/anwell_demo
Site: https://koalaland-workplace.github.io/anwell_demo/

## 1. Bối cảnh

ANWELL là nền tảng trị liệu, dưỡng sinh và chăm sóc phục hồi tại nhà. Bản demo hiện có gồm 5 trang HTML "bundled" (self-contained), được tải lên GitHub bằng web UI trong một commit duy nhất.

| Trang | Vai trò | Bundled | Source thật |
|---|---|---|---|
| `index.html` | Hub chọn giao diện | 525 KB | 345 dòng |
| `app.html` | Khách hàng — 24 view | 2.674 KB | 2.151 dòng |
| `center.html` | Trung tâm đối tác | 583 KB | 993 dòng |
| `ktv.html` | Kỹ thuật viên | 583 KB | 958 dòng |
| `admin.html` | Quản trị nền tảng | 576 KB | 923 dòng |

24 view của `app.html`: onboard, discover, place, book, session, review, journey, rewards, wallet, family, care, carebook, ktv, chat, referral, reminders, report, recipe, policy, verify.

### Mục đích của bản demo

Ba mục đích, do chủ dự án xác nhận:

1. Gọi vốn / thuyết trình nhà đầu tư
2. Bán hàng / thuyết phục trung tâm đối tác
3. Kiểm chứng ý tưởng với người dùng thật

**Không** phục vụ bàn giao cho đội dev xây sản phẩm thật. Điều này quyết định phạm vi kỹ thuật: ưu tiên tốc độ tải và tính thuyết phục, không đầu tư vào kiến trúc sẵn sàng sản xuất.

### Kiểm chứng kỹ thuật đã thực hiện

Mỗi file bundled chứa một `<script type="__bundler/manifest">` (assets mã hoá base64+gzip) và một `<script type="__bundler/template">` (HTML + JS viết tay, chưa minify). Đã giải nén `index.html` thành file rời, thay UUID bằng tên file thật, phục vụ qua HTTP và mở trong trình duyệt:

- Render đúng y hệt bản bundled
- 0 lỗi console
- 0 UUID còn sót trong template

Kết luận: phương án tách file rời khả thi, rủi ro thấp.

## 2. Vấn đề cần giải quyết

| # | Vấn đề | Bằng chứng | Ảnh hưởng |
|---|---|---|---|
| 1 | `app.html` nặng 2.674 KB | 11 ảnh PNG nhúng base64 trong `window.ANWELL_IMG` = 1.867 KB | Chờ ~15 giây trên 4G — hỏng mục đích 3 |
| 2 | Font + runtime 507 KB lặp lại ở cả 5 trang | 25 asset giống hệt nhau ở mọi trang | Tour demo 5 trang tải 4.943 KB thay vì ~1.100 KB |
| 3 | `admin.html` không được link từ đâu | `index.html` chỉ có 3 thẻ | Người xem không biết portal thứ 4 tồn tại |
| 4 | Không trang nào có `<title>` | Tab trình duyệt hiện "Bundled Page" | Mất uy tín khi trình chiếu |
| 5 | Không có `og:*`, `description`, favicon | Chỉ 1 thẻ `og` trên toàn bộ 5 trang | Gửi link qua Zalo/Messenger preview trống |
| 6 | Không có source rời để sửa | Chỉ có file bundled | Không cập nhật nội dung được |

## 3. Phương án đã chọn

**Tách file rời, giữ `dc-runtime`.**

Hai phương án bị loại:

- *Viết lại bằng HTML/CSS/JS thuần* — phải viết lại 5.400 dòng, chắc chắn lệch giao diện, không mang lại lợi ích nào cho 3 mục đích đã chọn.
- *Port sang Vite + React* — chỉ đáng làm nếu bàn giao đội dev, mà mục đích đó không được chọn.

Đánh đổi đã chấp nhận: vẫn phụ thuộc `dc-runtime` (runtime đóng). Nếu về sau phát sinh nhu cầu bàn giao dev, đi từ source đã tách sạch sang React dễ hơn nhiều so với đi từ file bundled.

## 4. Kiến trúc

```
anwell_demo/
├─ index.html  app.html  center.html  ktv.html  admin.html   ← output, Pages phục vụ
├─ assets/
│  ├─ fonts/          22 file .woff2   (~300 KB, cache dùng chung)
│  └─ img/            11 ảnh .webp     (~250 KB, từ 1.400 KB PNG)
├─ vendor/
│  ├─ dc-runtime.js   269 KB, cache dùng chung
│  └─ image-slot.js
├─ src/                                     ← nơi sửa nội dung
│  ├─ pages/          5 file, 5.400 dòng
│  └─ shared/
│     ├─ meta.json    title / description / og cho từng trang, khoá theo tên trang
│     ├─ head.html    khuôn `<head>` dùng chung, có chỗ thay từ meta.json
│     └─ favicon.svg  logo sen
│     └─ demo-guide/  overlay kịch bản trình diễn
│        ├─ guide.js
│        ├─ guide.css
│        └─ tours/{investor,center}.json
├─ tools/
│  ├─ unbundle.py     chạy một lần: bundled → src/
│  ├─ build.py        src/ → output ở gốc repo
│  └─ verify.py       kiểm tra sau mỗi lần build
├─ docs/              tài liệu
├─ .gitignore         chặn Tailieu-noibo/ và .DS_Store
└─ README.md
```

### Vì sao output ở gốc repo, không phải `dist/`

GitHub Pages của repo đang cấu hình source = branch `main`, thư mục `/`. Đặt output ở gốc thì không phải đụng vào cấu hình Pages, và nếu script build hỏng thì site vẫn chạy nguyên trạng. Chuyển sang GitHub Actions sạch hơn nhưng thêm một điểm có thể gãy; ghi vào tài liệu như bước nâng cấp tuỳ chọn.

### Ranh giới các thành phần

| Thành phần | Làm gì | Phụ thuộc |
|---|---|---|
| `tools/unbundle.py` | Giải nén 5 file bundled thành `src/` + `assets/` + `vendor/`. Chạy một lần, giữ lại để tái lập được. | 5 file bundled gốc |
| `tools/build.py` | Với mỗi trang: đọc metadata từ `meta.json`, dựng `<head>` từ `head.html`, ghép vào `src/pages/<tên>.html`, chèn thẻ script demo-guide, ghi ra gốc repo. | `src/` |
| `tools/verify.py` | Kiểm tra output trước khi push. Không sửa gì, chỉ báo lỗi. | output ở gốc |
| `src/shared/demo-guide/` | Overlay dẫn dắt. Độc lập hoàn toàn với code trang, giao tiếp qua thuộc tính `data-tour`. | `tours/*.json` |

## 5. Xử lý ảnh

11 ảnh PNG trong `window.ANWELL_IMG`: `tt-01`…`tt-05` (ảnh trị liệu, ~200 KB/ảnh) và 6 ảnh chân dung KTV (`hai-yen`, `ngoc-anh`, `nguyen-minh`, `nguyen-bich`, `phuong-dung`, `quynh-anh`).

- Tách thành file `.webp` trong `assets/img/`
- Giữ nguyên `window.ANWELL_IMG` như một map key → đường dẫn file, để code trang không phải sửa
- Thêm `loading="lazy"` và khai báo `width`/`height` chống giật layout
- Chất lượng WebP: bắt đầu ở mức 82. Với mỗi ảnh, mở bản WebP và bản PNG cạnh nhau đối chiếu; ảnh nào thấy xuống cấp rõ thì nâng lên 90, vẫn xuống cấp thì giữ nguyên PNG cho riêng ảnh đó và ghi lý do vào `docs/04`

## 6. Kịch bản trình diễn trong sản phẩm

`src/shared/demo-guide/` — lớp phủ độc lập.

- **Kích hoạt bằng URL**: `?tour=investor`, `?tour=center`. Không có tham số thì không hiển thị gì. Cho phép dùng cùng một site cho hai việc: link sạch gửi người dùng thử, link `?tour=` cho buổi pitch.
- **Hiển thị**: khung tô sáng phần tử cần bấm; hộp thoại góc màn hình gồm tiêu đề bước, gợi ý thao tác, nút Tiếp / Lùi / Thoát, bộ đếm "Bước 4/12".
- **Lời thoại gợi ý**: nằm trong hộp thoại, ẩn/hiện bằng phím `N`. Khi chiếu màn hình thì khán giả cũng thấy — đây là giới hạn của trình duyệt, không có cách giấu thật sự.
- **Xuyên trang**: tour đi qua nhiều file HTML; lưu tiến độ vào `sessionStorage`, sang trang mới tự nối đúng bước.
- **Bám phần tử**: qua thuộc tính `data-tour="..."` thêm vào `src/pages/`, không dùng selector CSS. Lý do: `dc-runtime` render DOM động, phần tử bị vẽ lại thì selector CSS mất hiệu lực.
- **Sửa lời thoại không cần biết code**: mỗi tour là một file JSON.

### Hai tour

**`investor.json` — Nhà đầu tư (5–7 phút).** Một buổi trị liệu nhìn từ bốn phía: `app` khách đặt lịch → `ktv` nhận ca và check-in tại nhà → `center` điều phối và đối soát → `admin` GMV toàn nền tảng.

**`center.json` — Trung tâm đối tác (8–10 phút).** Tập trung `center` + `ktv`: công suất, việc tồn đọng, bảng điều phối, đối soát sau chiết khấu, chỉ số chất lượng.

## 7. Tài liệu

| File | Cho ai | Nội dung |
|---|---|---|
| `README.md` | Người mở repo | ANWELL là gì, link demo, bảng 4 portal, mục lục tài liệu |
| `docs/01-tong-quan-san-pham.md` | Nhà đầu tư + trung tâm | Vấn đề & giải pháp, sơ đồ 4 vai trò, mô hình hai lớp, cơ chế doanh thu, hạng ANP, danh mục tính năng đã dựng |
| `docs/02-huong-dan-xem-demo.md` | Người không rành công nghệ | Mở link nào, máy tính vs điện thoại, mỗi portal bấm gì thấy gì, cảnh báo dữ liệu là giả |
| `docs/03-kich-ban-trinh-dien.md` | Chủ dự án khi đi pitch | Hai kịch bản, từng bước: bấm gì + nói gì + số liệu cần nhấn |
| `docs/04-quan-ly-va-cap-nhat.md` | Chủ dự án về sau | Sửa chữ/số ở đâu, thay ảnh, build → verify → push, xử lý sự cố |

### Nguyên tắc bảo mật nội dung — bắt buộc

Thư mục `Tailieu-noibo/` (4 tài liệu: hồ sơ mời đầu tư, chiến lược tổng thể, đề án tổng thể, lộ trình platform) **nằm trong `.gitignore` và không bao giờ được commit**. Repo này là public.

Các tài liệu đó được dùng làm tư liệu tham khảo khi viết tài liệu công khai, nhưng bản công khai **không được chứa**:

- Định giá, điều khoản gọi vốn, tỷ lệ cổ phần
- Dự toán ngân sách, chi phí
- Danh tính cổ đông sáng lập
- Phân tích đối thủ cạnh tranh
- Bất kỳ con số nào gắn nhãn GIẢ ĐỊNH trong tài liệu gốc
- Cổng KPI nội bộ và đánh giá rủi ro

Được phép dùng: định vị sản phẩm, mô tả vấn đề thị trường có nguồn công khai, cấu trúc mô hình vận hành, danh mục tính năng.

## 8. Kiểm thử

`verify.py` chạy sau mỗi lần build, kiểm tra:

1. Đủ 5 file HTML ở gốc repo
2. Không còn chuỗi UUID chưa thay trong output
3. Mọi đường dẫn `src=` / `href=` / `url()` trỏ tới file có thật
4. Mỗi trang có `<title>` không rỗng, có `description`, có `og:title`
5. Không file HTML nào vượt 400 KB

Ngoài script, kiểm thử thủ công trước khi báo hoàn thành:

- Mở lần lượt 5 trang trong trình duyệt, xác nhận 0 lỗi console
- Chụp màn hình đối chiếu với bản bundled gốc
- Chạy trọn hai tour từ đầu đến cuối
- Kiểm tra trên khung hình điện thoại (375×812)

Không tuyên bố hoàn thành khi chưa chạy và chưa nhìn thấy kết quả.

## 9. Quy trình cập nhật

```bash
python3 tools/build.py && python3 tools/verify.py
git add -A && git commit -m "..." && git push
```

Site cập nhật sau khoảng một phút.

## 10. Ngoài phạm vi

- Port sang React / Vue
- Thêm màn hình nghiệp vụ mới (chủ dự án sẽ liệt kê sau khi xem bản sạch)
- Backend, lưu dữ liệu thật, đăng nhập
- Đa ngôn ngữ
- Đưa tài liệu nội bộ lên site, kể cả sau lớp mật khẩu JavaScript

Lý do loại mục cuối: GitHub Pages là hosting tĩnh, mật khẩu phía trình duyệt không phải bảo vệ thật — file vẫn tải được bằng URL trực tiếp, và bản mã công khai thì dò được ngoại tuyến không giới hạn số lần thử.

## 11. Rủi ro

| Rủi ro | Mức | Xử lý |
|---|---|---|
| Thêm `data-tour` vào `src/pages/` làm hỏng render | Thấp | Chỉ thêm thuộc tính, không đổi cấu trúc; verify sau mỗi trang |
| WebP làm giảm chất lượng ảnh trị liệu | Thấp | Đối chiếu trực quan; ảnh nào xuống cấp rõ thì giữ PNG |
| `dc-runtime` phụ thuộc thứ tự nạp asset khi tách rời | Trung bình | Đã kiểm chứng thành công trên `index.html`; làm từng trang một, verify ngay |
| Tour xuyên trang mất tiến độ | Thấp | `sessionStorage`; nếu mất thì tour tự về bước đầu của trang hiện tại |
| Chủ dự án lỡ commit `Tailieu-noibo/` | Cao nếu xảy ra | `.gitignore` + ghi cảnh báo trong `docs/04` |

## 12. Nhật ký thay đổi giao diện

Ghi lại các thay đổi nghiệp vụ sau khi tách source, để về sau biết vì sao bản
demo khác bản gốc.

### KTV — 2026-07-26

| Thay đổi | Lý do |
|---|---|
| Nhãn nav ô đầu: "Ca làm" (tại trung tâm) và "Việc" (tự do) → **"Tổng quan"** | Cùng một chức năng mà hai tên gọi khác nhau giữa hai chế độ |
| Mục Tôi → "Khung giờ nhận khách" lấy từ dữ liệu sống thay vì chuỗi cứng `T2–T7 · 8:00–20:00`, bấm vào mở trang lịch | Thông tin trong Tôi phải khớp với thực tế và với màn Tổng quan |
| Thêm trang **Lịch nhận khách** cho chế độ tự do | KTV tự do cần tự khai báo khi nào, ở đâu, làm dịch vụ gì |

Trang Lịch nhận khách gồm: công tắc tạm dừng nhận khách (chế độ bận, giữ nguyên
các khung giờ đã đặt); danh sách khung giờ với thao tác tạo / sửa / xoá /
bật-tắt từng khung; mỗi khung có khu vực, ngày trong tuần, giờ bắt đầu–kết
thúc, loại hình dịch vụ và ghi chú. Không lưu được nếu thiếu ngày hoặc khu vực.

Ô thứ tư của nav vẫn khác nhau giữa hai chế độ — "Thu nhập" khi làm tại trung
tâm, "Lộ trình" khi làm tự do — vì hai chế độ có nhu cầu khác nhau. Chờ chủ dự
án quyết có gộp hay không.

## 13. Trạng thái hiện tại

- PAT đã tạo (fine-grained, Contents: Read and write), đã nạp vào `gh`, xác nhận `viewerPermission: ADMIN`
- Git local đã init, nối `origin`, đồng bộ với `main` — 5 file local trùng khớp hoàn toàn với repo
- Commit `9234f6f` giữ nguyên trạng 5 file bundled, đóng vai trò bản sao lưu
