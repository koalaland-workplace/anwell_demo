---
name: anwell-danh-muc-chuan
description: Dùng khi cần bất kỳ danh mục nào — loại hình dịch vụ, tình trạng sức khoẻ, chống chỉ định, chứng chỉ, bậc kỹ thuật viên, hãng thiết bị, tỉnh thành phường xã. Cấm ghi cứng danh mục trong mã; mọi cổng đọc từ một nguồn duy nhất.
---

# Danh mục chuẩn — một nguồn duy nhất

Mọi danh mục dùng chung đọc từ **Danh mục chuẩn** qua API. Không cổng nào được
giữ bản sao trong mã.

**Vì sao có skill này:** Trong bản demo, bảng chống chỉ định có **ba bản** —
một ở app khách, một ở app KTV, một ở Danh mục chuẩn của admin. Hậu quả thật:
khách khai huyết áp cao mà không dịch vụ nào cảnh báo. Đây là lỗi tốn kém nhất
đã xảy ra trong dự án này.

## Khi nào dùng

- Cần danh sách để đổ vào ô chọn, thẻ lọc, hoặc nhãn
- Đối chiếu dữ liệu người dùng khai với một danh mục
- Thấy mình sắp gõ một mảng chuỗi cố định trong mã

## Bảy danh mục và nguồn của chúng

| Danh mục | Đường API | Ai sửa được |
|---|---|---|
| Loại hình dịch vụ | `/danh-muc/dich-vu` | ANWELL |
| Tình trạng sức khoẻ | `/danh-muc/suc-khoe` | ANWELL (bác sĩ duyệt) |
| Chống chỉ định (dịch vụ × tình trạng) | `/danh-muc/chong-chi-dinh` | ANWELL (bác sĩ duyệt) |
| Loại chứng chỉ | `/danh-muc/chung-chi` | ANWELL |
| Bậc kỹ thuật viên và phạm vi | `/danh-muc/bac` | ANWELL |
| Hãng thiết bị | `/danh-muc/hang-thiet-bi` | ANWELL |
| Tỉnh · phường xã | `/danh-muc/hanh-chinh` | ANWELL, theo nguồn nhà nước |

## Ba quy tắc

1. **Cấm ghi cứng.** Không mảng chuỗi cố định, không `enum` cho các danh mục
   trên. Kể cả khi chỉ có ba giá trị và "chắc không đổi đâu".

2. **Đệm được, sao chép thì không.** Cổng được phép đệm kết quả để chạy nhanh và
   để dùng khi mất mạng — nhưng phải có hạn và phải làm mới. Đệm khác với ghi
   cứng: đệm hết hạn thì tự lấy lại, ghi cứng thì nằm đó mãi.

3. **Danh mục hành chính có ngày hiệu lực.** Địa giới Việt Nam vừa thay đổi
   lớn. Bản ghi cũ phải giữ được tên phường xã tại thời điểm phát sinh.

## Cách làm đúng

```ts
// SAI — ghi cứng, và đây đúng là cách bản demo đang làm
const LOAI_HINH = ['Cổ vai gáy', 'Massage chân', 'Toàn thân', 'Thư giãn']

// SAI — enum cũng là ghi cứng
enum TinhTrang { HuyetApCao, TimMach, TieuDuong }

// ĐÚNG — đọc từ nguồn chuẩn, có đệm
const dichVu = await danhMuc.lay('dich-vu')          // có đệm 1 giờ
const canTranh = await danhMuc.chongChiDinh({
  dichVuId: ca.dichVuId,
  tinhTrang: hoSo.tinhTrang,                          // lọc theo ca, không đổ cả danh sách
})
```

## Dấu hiệu đang làm sai

| Nếu anh thấy | Nghĩa là | Sửa thế nào |
|---|---|---|
| Mảng chuỗi tên dịch vụ / bệnh trong mã | Đang tạo bản sao thứ hai | Gọi API danh mục |
| `enum` cho tình trạng sức khoẻ | Như trên, chỉ khác cú pháp | Như trên |
| Hai cổng có cùng một danh sách | Đã lặp — sắp lệch nhau | Gom về một nguồn |
| Tên phường xã lưu dạng chuỗi tự do | Không đối chiếu được | Lưu mã, hiện tên theo ngày |

## Không áp dụng khi

- Danh sách chỉ dùng trong một màn và không có nghĩa nghiệp vụ (ví dụ nhãn của
  ba tab trên cùng một trang)
- Dữ liệu mẫu trong kiểm thử
- Hằng số kỹ thuật thuần (mã lỗi HTTP, tên sự kiện)
