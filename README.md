# ANWELL — Bản demo tương tác

**Feel well. Live an.** — Nền tảng trị liệu, dưỡng sinh và chăm sóc phục hồi tại nhà.

Đây là bản demo bấm được, dùng để trình bày mô hình sản phẩm cho nhà đầu tư,
trung tâm đối tác và người dùng thử. **Toàn bộ số liệu là dữ liệu giả lập để
minh hoạ** — không phải kết quả kinh doanh thật.

## Xem demo

**https://koalaland-workplace.github.io/anwell_demo/**

| Giao diện | Dành cho | Mở trực tiếp |
|---|---|---|
| Khách hàng | Người đặt dịch vụ và gia đình | [app.html](https://koalaland-workplace.github.io/anwell_demo/app.html) |
| Trung tâm | Chủ cơ sở, quản lý ca, lễ tân | [center.html](https://koalaland-workplace.github.io/anwell_demo/center.html) |
| Kỹ thuật viên | KTV làm tại trung tâm hoặc tự do | [ktv.html](https://koalaland-workplace.github.io/anwell_demo/ktv.html) |
| Quản trị nền tảng | Đội vận hành ANWELL | [admin.html](https://koalaland-workplace.github.io/anwell_demo/admin.html) |

Mỗi giao diện chạy độc lập, bấm thử được mọi luồng chính. Không cần đăng nhập,
không lưu dữ liệu gì.

## Tài liệu

| Đọc gì | Khi nào |
|---|---|
| [Tổng quan sản phẩm](docs/01-tong-quan-san-pham.md) | Muốn hiểu ANWELL làm gì và vận hành ra sao |
| [Hướng dẫn xem demo](docs/02-huong-dan-xem-demo.md) | Lần đầu mở demo, không rành công nghệ |
| [Kịch bản trình diễn](docs/03-kich-ban-trinh-dien.md) | Chuẩn bị buổi gặp nhà đầu tư hoặc trung tâm |
| [Quản lý & cập nhật](docs/04-quan-ly-va-cap-nhat.md) | Cần sửa nội dung hoặc đưa bản mới lên |

## Cấu trúc kho mã

```
anwell_demo/
├─ index.html  app.html  center.html  ktv.html  admin.html   ← bản chạy
├─ assets/     fonts, ảnh
├─ vendor/     thư viện dùng chung
├─ src/pages/  ← NƠI SỬA NỘI DUNG
├─ tools/      script dựng và kiểm tra
└─ docs/       tài liệu
```

Sửa nội dung trong `src/pages/`, rồi chạy `python3 tools/build.py`. Chi tiết ở
[Quản lý & cập nhật](docs/04-quan-ly-va-cap-nhat.md).
