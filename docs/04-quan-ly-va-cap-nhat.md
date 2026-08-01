# Quản lý & cập nhật

Tài liệu cho người bảo trì bản demo.

## Nguyên tắc quan trọng nhất

**Sửa trong `src/pages/`, không bao giờ sửa trực tiếp file ở gốc.**

Sáu file HTML ở gốc kho mã (`index.html`, `demo.html`, `app.html`, `center.html`,
`ktv.html`, `admin.html`) là **kết quả dựng ra**. Sửa thẳng vào đó thì lần chạy
`build.py` tiếp theo sẽ ghi đè mất.

```
src/pages/ktv.html   ← sửa ở đây
        ↓ python3 tools/build.py
     ktv.html        ← file này tự sinh ra
```

## Quy trình cập nhật

```bash
python3 tools/build.py && python3 tools/verify.py
```

`verify.py` kiểm tra trước khi cho đi tiếp: đủ 6 trang, không còn mã định danh
chưa thay, mọi đường dẫn ảnh và font đều tồn tại, mỗi trang có tiêu đề và mô tả,
không file nào vượt 400 KB.

Đạt hết rồi mới đẩy lên:

```bash
git add -A && git commit -m "Mô tả ngắn thay đổi" && git push
```

Trang web tự cập nhật sau khoảng một phút.

## ⚠️ Kiểm tra bằng trình duyệt trước khi đẩy

`verify.py` chỉ kiểm tra **cấu trúc file**, không chạy được mã JavaScript. Đã có
lần trang bị vỡ trắng hoàn toàn mà `verify.py` vẫn báo đạt — nguyên nhân là
thiếu một khoá dữ liệu, chỉ lộ ra khi mở trình duyệt.

**Luôn mở thử trước khi đẩy:**

```bash
python3 -m http.server 8877
```

Rồi mở `http://127.0.0.1:8877/ktv.html?v=1` — **nhớ thêm `?v=1`** và đổi số mỗi
lần, vì trình duyệt giữ bản cũ rất dai. Mở Console (phím `F12`) xem có báo lỗi
đỏ không.

Xong thì dừng máy chủ bằng `Ctrl + C`.

### Rà cả 6 trang, không chỉ trang vừa sửa

Đây là bài học đắt nhất của kho mã này. Đã **ba lần** một thay đổi nhỏ làm trắng
những trang không liên quan, mà `verify.py` vẫn báo đạt:

| Việc đã làm | Hậu quả |
|---|---|
| Gộp hai mục thành một, thẻ `sc-if` bọc nhầm | 6 trang trắng |
| Đặt sai chỗ hai thẻ đóng | 4 trang trắng |
| Đổi menu mà quên thanh nav dưới còn trỏ trang cũ | trang trắng hoàn toàn |

Cả ba đều **chỉ lộ ra khi mở đúng trang bị ảnh hưởng**. Nên mỗi lần đụng tới cấu
trúc — thêm bớt trang, gộp mục, di chuyển khối — phải mở lần lượt **cả 6 trang và
mọi tab bên trong**, xem trang nào trống thì sửa trước khi commit.

### Hai bẫy hay gặp khi sửa `src/pages/`

**Bẫy 1 — huy hiệu ở menu đọc thẳng từ `state`.** Trỏ vào một giá trị tính trong
`renderVals()` thì lúc dựng menu nó chưa tồn tại và trang trắng ngay. Dùng hàm
`navCount()` có sẵn ở cả `center.html` và `admin.html`.

**Bẫy 2 — thay thế theo mốc quá rộng.** Cắt từ mốc A tới mốc B mà mốc B trùng
nhiều chỗ thì nuốt mất khối logic ở giữa. Đã hai lần mất nguyên một trang vì thế.
Sửa từng đoạn nhỏ và kiểm dựng sau mỗi bước thì an toàn hơn.

## Sửa những thứ hay gặp

| Muốn sửa | Sửa ở đâu |
|---|---|
| Tiêu đề trang, mô tả khi chia sẻ link | `src/shared/meta.json` |
| Chữ, số, tên người trong giao diện | `src/pages/<tên-trang>.html` — tìm bằng chính đoạn chữ đó |
| Ảnh | Thay file trong `assets/img/`, giữ nguyên tên |
| Ảnh xem trước khi gửi link | `python3 tools/make_og_image.py` sau khi sửa file đó |
| Màu sắc, phong cách | Khối `.app[data-theme="..."]` trong `src/pages/` |

**Mẹo tìm nhanh:** muốn sửa dòng chữ nào, cứ chép nguyên dòng đó rồi tìm trong
`src/pages/`. Toàn bộ chữ hiển thị đều nằm nguyên văn trong đó.

## Cấu trúc kho mã

```
anwell_demo/
├─ index.html  demo.html  app.html  center.html  ktv.html  admin.html  ← kết quả dựng
├─ assets/
│  ├─ fonts/     22 file chữ, dùng chung cả 5 trang
│  ├─ img/       ảnh WebP + ảnh xem trước khi chia sẻ
│  └─ favicon.svg
├─ vendor/       thư viện chạy nền, không sửa
├─ src/
│  ├─ pages/     ← NƠI SỬA NỘI DUNG
│  └─ shared/    meta.json, favicon
├─ tools/
│  ├─ unbundle.py      chạy một lần lúc khởi tạo, không cần chạy lại
│  ├─ build.py         dựng src/ thành file ở gốc
│  ├─ verify.py        kiểm tra sau khi dựng
│  └─ make_og_image.py tạo ảnh xem trước khi chia sẻ link
└─ docs/         tài liệu
```

## Không đưa lên kho mã công khai

Kho mã này **công khai** — ai cũng đọc được, Google lập chỉ mục được, và mọi thứ
từng đẩy lên đều nằm trong lịch sử vĩnh viễn dù có xoá sau.

`.gitignore` đang chặn thư mục `Tailieu-noibo/`. **Đừng gỡ dòng đó.**

Tuyệt đối không đưa lên:

- Hồ sơ mời đầu tư, định giá, điều khoản gọi vốn, tỷ lệ cổ phần
- Dự toán ngân sách, chi phí
- Danh tính cổ đông sáng lập
- Phân tích đối thủ cạnh tranh
- Cổng KPI nội bộ và đánh giá rủi ro
- Thông tin cá nhân thật của khách hàng hoặc kỹ thuật viên

**Nếu lỡ đẩy nhầm:** xoá file rồi commit lại là **chưa đủ** — nội dung vẫn nằm
trong lịch sử. Phải viết lại lịch sử kho mã hoặc tạo kho mới. Báo ngay để xử lý
sớm.

> Đừng đặt tài liệu nhạy cảm sau lớp mật khẩu JavaScript. Trang tĩnh không có
> mật khẩu thật: file vẫn tải được bằng địa chỉ trực tiếp, và bản mã công khai
> thì dò được ngoại tuyến không giới hạn số lần thử.

## Quyền truy cập

Kho mã thuộc tổ chức `koalaland-workplace`. Cần quyền ghi mới đẩy lên được.

Kiểm tra quyền hiện tại:

```bash
gh repo view koalaland-workplace/anwell_demo --json viewerPermission
```

Cần thấy `WRITE` hoặc `ADMIN`. Nếu ra `READ` thì tài khoản chưa được cấp quyền.

Mã truy cập cá nhân (PAT) có hạn dùng. Khi hết hạn, đẩy lên sẽ báo lỗi xác thực
— vào https://github.com/settings/tokens gia hạn hoặc tạo mới, rồi chạy lại
`gh auth login`.

## Xử lý sự cố

| Hiện tượng | Nguyên nhân thường gặp | Cách xử lý |
|---|---|---|
| Đã đẩy nhưng web chưa đổi | Trình duyệt giữ bản cũ | `Cmd + Shift + R`, hoặc thêm `?v=2` vào địa chỉ |
| Đã đẩy nhưng web vẫn cũ sau 5 phút | GitHub Pages chưa dựng xong | `gh api repos/koalaland-workplace/anwell_demo/pages/builds/latest --jq .status` — cần thấy `built` |
| Trang trắng, không hiện gì | Lỗi JavaScript | Mở Console (`F12`) xem báo lỗi. Thường do thiếu một khoá dữ liệu |
| Ảnh vỡ | Sai tên file trong `assets/img/` | Chạy `python3 tools/verify.py`, nó chỉ ra đường dẫn hỏng |
| `verify.py` báo lỗi kích thước | File vượt 400 KB | Kiểm tra có ảnh nào bị nhúng thẳng vào HTML không |
| Đẩy lên báo lỗi xác thực | PAT hết hạn | Gia hạn rồi `gh auth login` lại |

## Nâng cấp có thể làm sau

Những việc chưa làm, ghi lại để không quên:

| Việc | Ghi chú |
|---|---|
| Dựng tự động bằng GitHub Actions | Hiện phải chạy `build.py` thủ công trước khi đẩy. Tự động hoá được nhưng thêm một điểm có thể hỏng |
| Nút trang trí chưa nối | Chuông thông báo ở `center` và `admin`, avatar ở `admin`, vài nút chuyển màn hình phụ ở `ktv`. Các nút thao tác chính đều chạy thật |
| Đồng bộ vỏ trang cho `center` và `admin` | Hai trang này là bảng điều khiển máy tính, chưa dùng khung điện thoại như `app` và `ktv`. Font và cỡ chữ thì đã thống nhất |
| Trung tâm: kho sản phẩm bán ra, thu chi & công nợ | Đã bỏ POS theo yêu cầu. Giá vốn mỗi buổi đã có, đủ nền để sau này tính lợi nhuận thật |
| Bộ chọn vai trò chi phối cả portal | Hiện chỉ ảnh hưởng trang Lương khoán. Muốn lễ tân không thấy Doanh thu thì phải gài quyền ở mọi trang |
| Kịch bản dẫn dắt trong sản phẩm | Từng có trong thiết kế ban đầu: lớp phủ tô sáng nút cần bấm, bật bằng `?tour=`. Chưa dựng — hiện dùng kịch bản giấy ở `docs/03` |
