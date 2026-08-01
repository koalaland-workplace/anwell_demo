# ANWELL — Bản demo tương tác

**Feel well. Live an.** — Nền tảng trị liệu, dưỡng sinh và chăm sóc phục hồi tại nhà.

Đây là bản demo bấm được, dùng để trình bày mô hình sản phẩm cho nhà đầu tư,
trung tâm đối tác và người dùng thử. **Toàn bộ số liệu là dữ liệu giả lập để
minh hoạ** — không phải kết quả kinh doanh thật.

## Xem demo

**https://koalaland-workplace.github.io/anwell_demo/**

Trang chủ là **ANWELL Portal** — trang giới thiệu công khai. Mục *Nền tảng* trên
đó có năm khối, bốn khối bấm thẳng vào bản demo tương ứng.

| Trang | Là gì | Mở trực tiếp |
|---|---|---|
| `index.html` | ANWELL Portal — trang giới thiệu, mặt tiền công khai | [mở](https://koalaland-workplace.github.io/anwell_demo/) |
| `app.html` | Web-App Khách hàng · 5 mục ở thanh đáy | [mở](https://koalaland-workplace.github.io/anwell_demo/app.html) |
| `center.html` | Quản trị Trung tâm · 14 trang / 5 nhóm | [mở](https://koalaland-workplace.github.io/anwell_demo/center.html) |
| `ktv.html` | Quản trị Kỹ thuật viên · 5 mục, hai chế độ | [mở](https://koalaland-workplace.github.io/anwell_demo/ktv.html) |
| `admin.html` | Management Portal · 14 trang / 5 nhóm | [mở](https://koalaland-workplace.github.io/anwell_demo/admin.html) |
| `demo.html` | Trang gom bốn cổng, tiện khi demo trực tiếp | [mở](https://koalaland-workplace.github.io/anwell_demo/demo.html) |

Mỗi giao diện chạy độc lập, bấm thử được mọi luồng chính. Không cần đăng nhập,
không lưu dữ liệu gì.

**Cổng Giám đốc Kinh doanh đã có bản riêng** tại `bd.html` — sáu mục, trong đó
mục *Link & mã giới thiệu* là chỗ Giám đốc Kinh doanh lấy link và mã để gửi cho
đối tác đăng ký thành trung tâm hoặc kỹ thuật viên tự do. Khối số 03 trên Portal
mở thẳng vào đây. Tab *Màn GĐKD nhìn thấy* trong `admin.html` giữ bản
rút gọn, kèm nút mở sang cổng đầy đủ.

## Tài liệu

| Đọc gì | Khi nào |
|---|---|
| [Tổng quan sản phẩm](docs/01-tong-quan-san-pham.md) | Muốn hiểu ANWELL làm gì và vận hành ra sao |
| [Hướng dẫn xem demo](docs/02-huong-dan-xem-demo.md) | Lần đầu mở demo, không rành công nghệ |
| [Kịch bản trình diễn](docs/03-kich-ban-trinh-dien.md) | Chuẩn bị buổi gặp nhà đầu tư hoặc trung tâm |
| [Quản lý & cập nhật](docs/04-quan-ly-va-cap-nhat.md) | Cần sửa nội dung hoặc đưa bản mới lên |
| [Việc đang làm & còn treo](docs/05-viec-dang-lam.md) | **Tiếp nhận công việc** — còn treo gì, đã chốt gì, số nào phải khớp nhau |

## Cấu trúc kho mã

```
anwell_demo/
├─ index.html  demo.html  app.html  center.html  ktv.html  admin.html  ← bản chạy
├─ assets/     fonts, ảnh
├─ vendor/     thư viện dùng chung
├─ src/pages/  ← NƠI SỬA NỘI DUNG
├─ tools/      script dựng và kiểm tra
└─ docs/       tài liệu
```

Sửa nội dung trong `src/pages/`, rồi chạy `python3 tools/build.py`. Chi tiết ở
[Quản lý & cập nhật](docs/04-quan-ly-va-cap-nhat.md).

## Quy tắc bắt buộc khi sửa

1. Sửa trong `src/pages/`, **không bao giờ** sửa file ở gốc — `build.py` sẽ ghi đè
2. `python3 tools/build.py && python3 tools/verify.py`
3. **Mở trình duyệt rà cả 6 trang và mọi tab** trước khi commit — `verify.py` chỉ
   kiểm cấu trúc file, không chạy được JavaScript. Đã nhiều lần một trang trắng
   hoàn toàn mà `verify.py` vẫn báo đạt
4. Commit rồi `git push`; GitHub Pages tự dựng sau khoảng một phút
