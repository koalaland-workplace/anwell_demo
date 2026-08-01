---
name: anwell-an-toan-ca-tai-nha
description: Dùng khi viết bất kỳ mã nào liên quan ca tại nhà — đặt lịch tại nhà, mã xác minh, check-in định vị, chia sẻ vị trí, SOS, báo sự cố, tổng đài che số. Nêu năm chốt chặn an toàn và ba ranh giới thiết kế không được gộp.
---

# An toàn ca tại nhà

Ca tại nhà là việc thật ngoài đời, nhiều khi có người già ở một mình. Đây là
nhóm mà lỗi phần mềm thành hại người thật.

**Vì sao có skill này:** Mã xác minh bốn số là chi tiết an toàn tốt nhất của
sản phẩm và là thứ nên nói đầu tiên khi bán cho gia đình có người già. Trong
bản demo, nút SOS ở cả hai cổng đều **bấm không làm gì** — đó là rủi ro thật
nếu đem cho người dùng thử.

## Khi nào dùng

- Đặt ca tại nhà, khai địa điểm, tìm KTV theo bán kính
- Check-in, check-out, ghi toạ độ
- Mã xác minh buổi
- Chia sẻ vị trí, SOS, báo sự cố
- Gọi điện giữa KTV và khách

## Năm chốt chặn

1. **Không gõ đúng mã bốn số thì KHÔNG check-in được.** Khách đọc mã trên app
   của họ. Gõ sai thì hiện hướng dẫn khách mở lại app, không cho đi tiếp. Cần
   đường thay thế qua tổng đài trung tâm cho khách già không mở được app.

2. **Bản ghi định vị bất biến.** Chỉ ghi thêm, không ai sửa được, kể cả quản
   trị viên. Xem `anwell-du-lieu-bat-bien`. Đây là *bên thứ ba* khi phân xử.

3. **Trừ thời gian di chuyển giữa hai ca.** Động cơ lịch phải trừ quãng đường
   khi tính khung giờ trống. Không trừ thì KTV luôn trễ ca sau — lỗi kinh điển
   của app đặt lịch tận nơi.

4. **Địa chỉ chỉ mở vào ngày có ca.** Xem `anwell-ba-nhom-khach`.

5. **Số điện thoại đi qua tổng đài che số.** KTV gọi được khi cần, số khách
   không rơi vào sổ điện thoại riêng.

## Ba ranh giới KHÔNG được gộp

| | Là gì | Vì sao tách |
|---|---|---|
| **SOS** | "Tôi thấy không an toàn" — gọi ngay, không hỏi lại | Gộp với báo sự cố thì KTV ngại bấm vì sợ làm to chuyện, đúng lúc cần bấm nhất |
| **Báo sự cố** | "Ca gặp trục trặc nhưng tôi vẫn ổn" — năm loại, có mô tả | |
| **Chia sẻ vị trí** | Bật từ đầu ca, chạy nền, điều phối viên thấy | SOS là lúc đã muộn; cái này là phòng ngừa |

Ba thứ này là ba bảng dữ liệu riêng, ba luồng xử lý riêng, ba nút riêng.

## Hai điều phải nói rõ với người dùng

- **Với KTV:** vị trí được ghi nhận khi check-in, và ai đang xem được vị trí đó.
  Cho KTV biết mình đang bị ai xem là chuyện riêng tư đúng đắn.
- **Với khách:** ai xem được buổi khi bật chia sẻ cho nhóm gia đình, và họ thấy
  gì (trạng thái buổi và ghi chú, **không** thấy thông tin thanh toán).

## Cách làm đúng

```ts
// SAI — cho check-in rồi kiểm mã sau
await batDauCa(caId)
if (!kiemMa(ma)) canhBao()

// ĐÚNG — mã là điều kiện, không phải cảnh báo
export async function checkIn(caId: string, ma: string, toaDo: ToaDo) {
  const ca = await layCa(caId)
  if (!await maHopLe(ca, ma))
    throw new LoiNghiepVu('Mã không đúng. Đề nghị khách mở lại app ANWELL.')
  return db.checkin.create({ data: { caId, toaDo, luc: new Date() } })  // chỉ ghi thêm
}
```

## Dấu hiệu đang làm sai

| Nếu anh thấy | Nghĩa là | Sửa thế nào |
|---|---|---|
| Nút SOS chưa nối vào đâu | Nút an toàn để trưng bày | Nối ngay, ưu tiên số một |
| SOS và báo sự cố dùng chung luồng | KTV sẽ ngại bấm SOS | Tách hẳn |
| Check-in không kiểm mã | Mất chốt chặn an toàn tốt nhất | Kiểm trước khi ghi |
| Lịch không trừ thời gian di chuyển | KTV luôn trễ ca sau | Thêm vào động cơ lịch |
| Chia sẻ vị trí không tự tắt | Theo dõi KTV ngoài giờ làm | Tự tắt khi check-out |

## Không áp dụng khi

- Ca tại cơ sở — ở cơ sở luôn có người khác quanh đó, rủi ro khác hẳn
- Màn hình chỉ hiển thị lịch sử ca đã xong
