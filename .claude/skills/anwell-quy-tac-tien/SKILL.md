---
name: anwell-quy-tac-tien
description: Dùng khi viết bất kỳ mã nào chạm tới tiền — thanh toán, ví, gói liệu trình, lương khoán, thuế, đối soát, hoàn tiền, phí nền tảng. Nêu sáu quy tắc cứng về cách lưu tiền, chống trùng giao dịch, nguồn sự thật, và kiểm thử đối chiếu tổng.
---

# Quy tắc tiền của ANWELL

Sai một quy tắc dưới đây là sai tiền của người thật — kỹ thuật viên, trung tâm,
hoặc khách.

**Vì sao có skill này:** ANWELL có ba dòng tiền chạy song song (khách trả,
trung tâm trả KTV, nền tảng thu phí) và một cơ chế tạm giữ khi tranh chấp.
Lệch một đồng ở bất kỳ đâu là mất niềm tin không lấy lại được.

**Ranh giới:** ANWELL dựng **cơ chế** trả tiền cho đúng, KHÔNG quyết trả bao
nhiêu. Mọi tỷ lệ xem skill `anwell-tham-so-chinh-sach`.

## Khi nào dùng

- Viết hoặc sửa mã trong gói thanh toán, ví, gói liệu trình, lương, thuế, đối soát
- Thiết kế bảng dữ liệu có cột tiền
- Viết kiểm thử cho bất kỳ luồng nào ở trên
- Rà mã của người khác chạm tới tiền

## Sáu quy tắc

1. **Tiền là số nguyên, đơn vị đồng.** Không dùng số thực ở bất kỳ đâu — không
   trong CSDL, không trong API, không trong biến trung gian. `450000` chứ không
   phải `450.0`. Làm tròn chỉ ở lớp hiển thị.

2. **Mọi thay đổi tiền mang khoá chống trùng.** Khoá sinh từ nghiệp vụ
   (mã đơn + lần thử), không phải mã ngẫu nhiên mỗi lần gọi. Khách bấm hai lần,
   mạng chập chờn, máy chủ thử lại — cả ba phải ra cùng một giao dịch.

3. **Webhook là nguồn sự thật, không phải trang trả về.** Ghi nhận thanh toán
   khi nhận thông báo từ cổng, không phải khi khách quay lại trang thành công.
   Khách đóng tab; webhook thì không.

4. **Không ghi cứng tỷ lệ hay ngưỡng nào.** Xem `anwell-tham-so-chinh-sach`.

5. **Mọi tham số có ngày hiệu lực và chủ sở hữu.** Đổi quy định thì kỳ sau mới
   áp; kỳ đang mở giữ nguyên.

6. **Kiểm thử đối chiếu tổng.** Mỗi kỳ phải có kiểm thử tự động khẳng định:
   tổng lương trả KTV + phí nền tảng + thuế = đúng doanh thu ghi nhận. Không
   lệch một đồng. Đây là cách bắt lỗi làm tròn.

## Cách làm đúng

```ts
// SAI
const gia = 450.0                              // số thực
const khoa = crypto.randomUUID()               // ngẫu nhiên → thử lại tạo đơn mới
app.get('/tra-ve-thanh-cong', ghiNhanDaTra)    // tin trang trả về

// ĐÚNG
type Dong = number & { readonly __don_vi: 'VND' }
const gia = 450_000 as Dong

async function taoThanhToan(don: Don) {
  return congThanhToan.tao({
    soTien: don.tongTien,
    khoaChongTrung: `don-${don.id}-lan-${don.soLanThu}`,   // từ nghiệp vụ
  })
}

app.post('/webhook/thanh-toan', async (req) => {
  if (!xacMinhChuKy(req)) return loi(401)
  if (await daXuLy(req.body.suKienId)) return ok()        // chống xử lý hai lần
  await ghiNhanDaTra(req.body)
})
```

## Dấu hiệu đang làm sai

| Nếu anh thấy | Nghĩa là | Sửa thế nào |
|---|---|---|
| `float` / `double` / `decimal` ở cột tiền | Sai số khi cộng dồn | Số nguyên đơn vị đồng |
| `randomUUID()` làm khoá chống trùng | Thử lại tạo giao dịch mới | Sinh khoá từ mã nghiệp vụ |
| Ghi nhận trả tiền ở hàm xử lý trang trả về | Mất đơn khi khách đóng tab | Chuyển sang webhook |
| Webhook không kiểm chữ ký | Ai cũng giả được | Xác minh chữ ký, lưu mã sự kiện |
| Không có kiểm thử đối chiếu tổng | Lỗi làm tròn trôi qua | Thêm kiểm thử đối chiếu |

## Không áp dụng khi

- Hiển thị tiền cho người đọc — lớp hiển thị được phép định dạng và làm tròn
- Số liệu trong bản demo và dữ liệu thử
- Ước tính và dự báo không sinh giao dịch thật
