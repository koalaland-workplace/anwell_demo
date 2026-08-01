---
name: anwell-kien-truc
description: Dùng khi tạo tệp mới, thêm gói, đổi ranh giới giữa các gói, hoặc viết mã có thể chạy ở cả web lẫn di động. Nêu bốn quyết định kiến trúc bất biến của ANWELL và sơ đồ quyết định "mã này thuộc gói nào".
---

# Kiến trúc bất biến của ANWELL

ANWELL đi ba chặng: Web-App → PWA → React Native. Bốn quyết định dưới đây là
thứ giữ cho chặng cuối chỉ là **thay vỏ** thay vì viết lại từ đầu.

**Vì sao có skill này:** Phase 15 chuyển hai cổng sang React Native. Nếu logic
nghiệp vụ nằm lẫn trong màn hình web thì toàn bộ 188 màn phải viết lại — mất
nguyên một Phase. Bản demo hiện tại chính là ví dụ: mọi quy tắc đều trộn trong
`renderVals()`, nên không mang sang đâu được.

## Khi nào dùng

- Tạo tệp mới hoặc thư mục mới
- Thêm gói vào kho mã, hoặc di chuyển mã giữa các gói
- Viết bất kỳ hàm nào có chứa quy tắc nghiệp vụ
- Thấy mình sắp gọi `document`, `window`, hoặc `localStorage`

## Bốn quyết định bất biến

1. **Một kho mã, chia gói rõ ràng.**
   `loi/` (nghiệp vụ) · `giao-dien/` (thành phần dùng chung) · `token/` (thiết kế)
   · `app-*/` (bốn cổng) · `may-chu/`. Không gói nào ngoài `app-*` được biết
   mình đang chạy trên web hay trên điện thoại.

2. **Quy tắc nghiệp vụ là hàm thuần.** Không chạm trình duyệt, không gọi mạng,
   không đọc giờ hệ thống. Vào là dữ liệu, ra là dữ liệu. Có kiểm thử riêng.

3. **Token thiết kế là JSON dùng chung.** Màu, cỡ chữ, bo góc, khoảng cách khai
   một chỗ. Web và React Native cùng đọc tệp đó. Ba phong cách An Nhiên · Rừng
   Thẫm · Nhịp Sen là ba bộ *giá trị*, không phải ba bộ *mã*.

4. **API đứng độc lập với giao diện.** Máy chủ trả dữ liệu, không dựng trang.
   Mọi cổng và mọi chặng gọi cùng một API.

## Mã này thuộc gói nào

```
Có chứa quy tắc nghiệp vụ (tính tiền, kiểm quyền, đối chiếu)?
   → loi/          (hàm thuần, có kiểm thử)

Là thành phần hiển thị dùng ở nhiều cổng?
   → giao-dien/    (nút, thẻ, biểu mẫu, bảng)

Là màu / cỡ chữ / khoảng cách?
   → token/        (JSON)

Là màn hình cụ thể của một cổng?
   → app-khach/ · app-ktv/ · app-trung-tam/ · app-admin/

Là đường API, truy vấn CSDL, việc chạy nền?
   → may-chu/
```

## Cách làm đúng

```ts
// SAI — quy tắc nằm trong màn hình, không mang sang React Native được
function ManLuong() {
  const [tyLe, setTyLe] = useState(35)
  const luong = gia * tyLe / 100        // ← quy tắc lẫn trong giao diện
  return <div>{luong}</div>
}

// ĐÚNG — quy tắc ở gói lõi, màn hình chỉ hiển thị
// loi/luong.ts
export function tinhLuongKhoan(giaSauThue: number, tyLe: number): number {
  return Math.round(giaSauThue * tyLe / 100)
}
// app-trung-tam/ManLuong.tsx
import { tinhLuongKhoan } from '@anwell/loi'
const luong = tinhLuongKhoan(giaSauThue, tyLe)
```

## Dấu hiệu đang làm sai

| Nếu anh thấy | Nghĩa là | Sửa thế nào |
|---|---|---|
| `document` / `window` trong `loi/` | Gói lõi dính trình duyệt | Đưa phần đó ra `app-*` |
| Phép tính nghiệp vụ trong tệp `.tsx` | Quy tắc lẫn giao diện | Rút thành hàm thuần ở `loi/` |
| Mã màu viết thẳng như `#12564A` | Bỏ qua token | Dùng biến token |
| Gói `app-khach` gọi thẳng CSDL | Bỏ qua API | Gọi qua đường API |
| Cùng một quy tắc xuất hiện hai chỗ | Sắp lặp lại lỗi bảng chống chỉ định | Gom về `loi/` |

## Không áp dụng khi

- Viết mã chỉ để thử nghiệm, không nhập nhánh
- Kịch bản dựng và công cụ nội bộ trong `tools/`
- Mã của bên thứ ba trong `ANWELL-DEV-REPO/tham-khao`

## Kiểm chứng sớm

Ngay ở P00, dựng thử **một màn React Native** dùng lại gói `loi/` và `token/`.
Nếu chạy được thì kiến trúc đúng. Đừng đợi tới P15 mới biết.
