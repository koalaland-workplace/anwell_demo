# Bóc tài sản từ bản demo

Lập 06/08/2026. Rà bằng công cụ, không phải bằng AI — kết quả kiểm lại được.

**Mục đích:** bản demo sắp đóng băng. Tài liệu này liệt kê **thứ phải mang sang
`anwell-platform` và mang vào gói nào** — không phải liệt kê lỗi của demo.

> Số liệu trong demo là dữ liệu giả lập, sau này xoá hết. Tài liệu này **không**
> quan tâm tới số; nó quan tâm tới **luồng và logic**.

---

## 0 · Quy mô

| | |
|---|---|
| Tám trang HTML | 17.595 dòng |
| Đánh dấu | 967.783 ký tự |
| **JavaScript** | **354.174 ký tự · 27%** |

27% là mã chạy. Đó là phần phải quyết: mang sang gói nào, hay viết lại.

---

## 1 · Tính tiền nằm trong giao diện — 7 chỗ, tất cả ở `center.html`

Đây là phát hiện nặng nhất. Bảy phép tính ra **số tiền mới**, không phải định dạng
hiển thị:

```js
const tax     = Math.round(PRICE * TAX / 100);
const after   = PRICE - tax;
const base    = c.price - Math.round(c.price * VAT / 100);
const disc    = Math.round(c.price * c.promo / 100);
const paid    = c.price - disc;
const payBase = c.price - Math.round(c.price * VAT / 100);
const base    = r.n * (r.price - Math.round(r.price * VAT / 100));
```

**Phải chuyển vào `packages/money`.** Ba hàm thuần cần có:

| Hàm | Việc |
|---|---|
| `tachThue(giaGomThue, tyLeThue)` | Tách phần thuế khỏi giá đã gồm thuế |
| `tinhGiam(gia, tyLeGiam)` | Tính số tiền giảm |
| `congDonDoanhThu(cacDong)` | Cộng dồn doanh thu theo dòng |

Cùng một công thức `price - Math.round(price * VAT / 100)` đang lặp **ba lần**. Ba
bản của một quy tắc thì sớm muộn lệch nhau — đúng lỗi bảng chống chỉ định đã mắc.

**Không phải vi phạm:** khoảng 17 chỗ dùng `toFixed()` là **hàm định dạng hiển
thị** (`450000` → `"450k"`, `1200` → `"1,20 tỷ"`). `anwell-quy-tac-tien` cho phép
rõ: *"lớp hiển thị được phép định dạng và làm tròn"*. Không cần đụng.

---

## 2 · Tham số chính sách ghi cứng

| Tham số | Ở đâu | Chủ sở hữu thật | Vấn đề |
|---|---|---|---|
| **`const VAT = 8`** | `center.html` **dòng 3842 và 4016** | Nhà nước | **Khai hai chỗ.** Thuế đổi theo quy định — sửa một chỗ quên chỗ kia là sai tiền |
| `a.hours > 48` | `admin.html`, hai chỗ | Chủ nền tảng | Hạn duyệt hồ sơ |
| `d.days > 60`, `> 30` | `admin.html` | Chủ nền tảng | Ngưỡng cảnh báo chứng chỉ sắp hết hạn |
| `4.0` | `center.html`, hai chỗ | Chủ nền tảng | Ngưỡng chỉ số chất lượng |

Tất cả phải thành **tham số có chủ sở hữu và ngày hiệu lực** trong
`packages/policy`. Riêng VAT là tham số pháp lý — đổi là đổi theo luật, và mã
đang giữ hai bản.

**Tin tốt:** tỷ lệ lương khoán **30–45% không ghi cứng trong mã** — chỉ xuất hiện
trong chữ hiển thị. Chỗ nhạy cảm nhất lại đang đúng.

---

## 3 · Liên kết chết — 12 chỗ ở `index.html`

Trang giới thiệu công khai. Phân loại:

| Loại | Số | Xử lý |
|---|---|---|
| Logo về trang chủ | 2 | Không sao |
| Trang nội dung chưa dựng — *Tra cứu chứng nhận KTV · Danh sách cơ sở đã xác minh · Khoá đào tạo lên bậc* | ~8 | Dựng ở Phase tương ứng, hoặc gỡ khỏi chân trang |
| **Điều khoản sử dụng · Chính sách quyền riêng tư** | **2** | **Phải có trước khi mở cho người dùng thật** |

Hai liên kết cuối là nghĩa vụ pháp lý, không phải nội dung tiếp thị. Demo đã hứa
*"dữ liệu thuộc về bạn, xoá được bất cứ lúc nào"* từ P01 — hứa rồi thì phải có
văn bản chính sách đứng sau.

---

## 4 · Danh mục dùng chung còn nhiều bản

`docs/05-viec-dang-lam.md` đã ghi và vẫn đúng: bảng chống chỉ định có **ba bản** —
`app.html`, `ktv.html`, và `admin.html` → Danh mục chuẩn.

Đây chính là chức năng mẫu xuyên suốt đề xuất cho P00: **Danh mục chuẩn**, chạm đủ
ba tầng DB → API → màn hình, không phụ thuộc bên thứ ba nào, và là chỗ đã gây lỗi
thật — khách khai huyết áp cao mà không dịch vụ nào cảnh báo.

---

## 5 · Việc phải làm khi dựng `anwell-platform`

| | Việc | Gói đích | Vai |
|---|---|---|---|
| 1 | Ba hàm thuần tính thuế, giảm giá, cộng dồn doanh thu | `packages/money` | T5₫ |
| 2 | Bốn tham số chính sách, mỗi cái một chủ sở hữu và ngày hiệu lực | `packages/policy` | T5₫ · T3 |
| 3 | Danh mục chuẩn một nguồn, bảy danh mục | `packages/catalogs` | T5 |
| 4 | Hai văn bản chính sách bắt buộc | nội dung | chủ dự án · luật sư |
| 5 | Kiểm kê thành phần giao diện dùng chung | `packages/design-system` | T4 |

Việc 5 chưa làm — cần rà thủ công hoặc bằng T8, không tự động hoá được.

---

## 6 · Cách rà lại

Toàn bộ số liệu trên lấy bằng công cụ, không bằng phán đoán. Chạy lại được:

```bash
python3 tools/boc-tai-san.py
```

Kết quả đổi thì tài liệu này phải cập nhật theo. Con số trong đây là **ảnh chụp
ngày 06/08/2026**, không phải hằng số.
