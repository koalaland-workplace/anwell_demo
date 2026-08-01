---
name: anwell-viet-tieng-viet
description: Dùng khi viết bất kỳ chữ nào người dùng đọc — nhãn nút, thông báo lỗi, câu giải thích, nội dung email và tin nhắn, tài liệu. Nêu văn phong ANWELL, bảng thuật ngữ chuẩn, và nguyên tắc nhãn nút phải viết thẳng hệ quả.
---

# Viết tiếng Việt cho ANWELL

Giọng văn của bản demo là một tài sản — nó **giải thích** thay vì **ra lệnh**.
Agent viết tiếng Việt máy móc sẽ phá cái đó.

**Vì sao có skill này:** Người dùng ANWELL gồm cả người cao tuổi và kỹ thuật
viên không rành công nghệ. Một câu khó hiểu ở màn SOS hay màn cảnh báo chống
chỉ định không phải chuyện thẩm mỹ — nó là chuyện an toàn.

## Khi nào dùng

- Viết nhãn nút, tiêu đề, thông báo lỗi, câu hướng dẫn
- Soạn nội dung email, tin nhắn ZNS/SMS, thông báo đẩy
- Viết tài liệu và chú thích trong mã
- Dịch bất kỳ nội dung nào sang tiếng Việt

## Sáu nguyên tắc

1. **Nhãn nút viết thẳng hệ quả, không viết "Duyệt".**
   ❌ `Duyệt` → ✅ `Tính công KTV · thu 50% phí khách`
   Người bấm phải biết mình đang quyết cái gì.

2. **Giải thích trước khi người dùng bấm, không phải sau.**
   Đặt câu giải thích ngay cạnh nút, không giấu trong trang trợ giúp.

3. **Nói rõ hệ quả, kể cả hệ quả bất lợi.**
   "Việc huỷ ca ảnh hưởng tỷ lệ nhận ca 92% — chỉ số này quyết định thứ hạng
   hiển thị khi khách tìm KTV." Nói trước thì người ta tính được đường dài.

4. **Câu ngắn. Một ý một câu.** Người đọc trên điện thoại, đang vội, đôi khi
   đang lo lắng.

5. **Cấm dịch máy.** Không "Vui lòng thử lại sau", không "Đã xảy ra lỗi không
   xác định". Viết như người nói với người: "Mã không đúng. Đề nghị khách mở
   lại app ANWELL, mã nằm ngay màn buổi hẹn."

6. **Không hứa hiệu quả điều trị.** Ràng buộc pháp lý với ngành sức khoẻ.
   "Hỗ trợ phục hồi" được; "chữa khỏi đau vai gáy" thì không.

## Bảng thuật ngữ chuẩn

| Dùng | Không dùng | Ghi chú |
|---|---|---|
| kỹ thuật viên · KTV | nhân viên, thợ, therapist | |
| buổi | session, lần |  |
| ca | shift, slot | *ca* là việc KTV làm; *buổi* là thứ khách mua |
| liệu trình | course, phác đồ | |
| gói | package, combo | |
| trung tâm | cơ sở, chi nhánh, spa | *cơ sở* dùng khi nói địa điểm vật lý |
| đối soát | reconcile, quyết toán | |
| lương khoán | hoa hồng, chia sẻ doanh thu | |
| đặt lịch | booking, đặt chỗ | |
| chống chỉ định | contraindication, cấm kỵ | |

## Ví dụ

```
❌ "Thao tác thất bại. Vui lòng thử lại sau."
✅ "Chưa gửi được — mạng đang chập chờn. Ghi chú của anh vẫn được giữ,
    thử lại khi có sóng."

❌ "Xác nhận"
✅ "Xác nhận đúng — việc này khoá thời gian tính phí"

❌ "Bạn có chắc chắn muốn huỷ?"
✅ "Huỷ buổi Trị liệu cổ vai gáy · Thứ 5, 24/07 · 09:00?
    Huỷ trước 12 giờ được hoàn 100%."
```

## Dấu hiệu đang làm sai

| Nếu anh thấy | Nghĩa là | Sửa thế nào |
|---|---|---|
| Nhãn nút chỉ có "Duyệt", "OK", "Xác nhận" | Người bấm không biết hệ quả | Viết thẳng việc sẽ xảy ra |
| "Vui lòng", "Đã xảy ra lỗi" | Dịch máy | Viết lại như người nói |
| Câu dài quá hai dòng trên điện thoại | Không ai đọc | Cắt ngắn |
| Từ tiếng Anh xen giữa câu tiếng Việt | Không nhất quán | Tra bảng thuật ngữ |
| Hứa kết quả điều trị | Rủi ro pháp lý | Đổi sang "hỗ trợ", "cải thiện" |

## Không áp dụng khi

- Tên biến, tên hàm, tên bảng trong mã — những thứ đó viết tiếng Anh hoặc tiếng
  Việt không dấu, theo quy ước kỹ thuật
- Thông báo lỗi chỉ dành cho lập trình viên
