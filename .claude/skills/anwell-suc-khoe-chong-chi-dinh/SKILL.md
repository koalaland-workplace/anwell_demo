---
name: anwell-suc-khoe-chong-chi-dinh
description: Dùng khi viết mã hoặc nội dung liên quan hồ sơ sức khoẻ, cảnh báo chống chỉ định, thẻ chuẩn bị trước ca, hoặc bậc năng lực kỹ thuật viên. Nêu ba ràng buộc y tế bắt buộc, trong đó có việc nội dung khuyến cáo phải do bác sĩ ký duyệt.
---

# Sức khoẻ và chống chỉ định

Đây là chức năng có giá trị nhất của ANWELL — và cũng là chỗ rủi ro pháp lý
cao nhất.

**Vì sao có skill này:** Bảng chống chỉ định trong bản demo do người **không có
chuyên môn y tế** soạn. Nội dung kiểu "nhiệt cao làm giãn mạch, dễ tụt huyết áp
đột ngột" nghe hợp lý — nhưng hợp lý không phải là đúng. Sai một dòng ở đây là
hại người thật, không phải lỗi phần mềm.

## Khi nào dùng

- Viết mã đối chiếu dịch vụ với tình trạng sức khoẻ
- Soạn hoặc sửa nội dung khuyến cáo
- Làm thẻ chuẩn bị trước ca
- Làm phần bậc năng lực và phạm vi được phép làm

## Ba ràng buộc

1. **Nội dung y khoa phải do bác sĩ ký duyệt.** Agent chỉ soạn nháp. Bảng
   chống chỉ định, nội dung khuyến cáo, và định nghĩa phạm vi ba bậc ANWELL Care
   đều phải có bác sĩ phục hồi chức năng duyệt trước khi phát hành. **Không có
   ngoại lệ, không có "tạm dùng bản nháp".**

2. **Cảnh báo lọc theo dịch vụ của ca, không đổ cả danh sách bệnh.** Khách khai
   năm tình trạng, ca này là massage chân — chỉ hiện cảnh báo liên quan tới
   massage chân. Đổ cả năm thì KTV lướt qua và không đọc gì.

3. **Hệ thống chỉ điều phối ca nằm trong phạm vi bậc.** Ràng ở tầng dữ liệu,
   không dựa tự giác. KTV bậc 1 không được nhận ca bậc 3, kể cả khi trung tâm
   muốn phân. Chứng chỉ hết hạn thì tự động không nhận được ca thuộc phạm vi đó.

## Bốn nguyên tắc phụ

- **Soi hồ sơ của đúng người nhận.** Đặt cho người nhà thì soi hồ sơ người nhà,
  không phải người đặt.
- **Cảnh báo hiện ngay lúc chọn dịch vụ**, không đợi tới bước xác nhận.
- **KTV đọc lại đúng cảnh báo đó** ở thẻ chuẩn bị trước ca — cùng một nguồn.
- **Một khách nhiều hồ sơ** — của mình và của nhiều người thân.

## Cách làm đúng

```ts
// SAI — đổ hết tình trạng khách khai
return hoSo.tinhTrang.map(t => canhBao(t))

// ĐÚNG — lọc theo dịch vụ của ca, lấy từ Danh mục chuẩn
export async function canhBaoChoCa(ca: Ca, hoSo: HoSoSucKhoe) {
  const bang = await danhMuc.chongChiDinh({ dichVuId: ca.dichVuId })
  return bang
    .filter(cc => hoSo.tinhTrang.includes(cc.tinhTrangId))
    .map(cc => ({
      canTranh: cc.canTranh,          // nội dung đã bác sĩ duyệt
      viSao: cc.viSao,
      viKhachKhai: cc.tenTinhTrang,
    }))
}

// Ràng buộc bậc — ở tầng nghiệp vụ, không phải ở giao diện
export function ktvNhanDuocCa(ktv: Ktv, ca: Ca, homNay: Date): boolean {
  if (ktv.bac < ca.bacYeuCau) return false
  return ktv.chungChi.some(c => c.phamVi.includes(ca.loai) && c.hetHan > homNay)
}
```

## Dấu hiệu đang làm sai

| Nếu anh thấy | Nghĩa là | Sửa thế nào |
|---|---|---|
| Nội dung khuyến cáo chưa có bác sĩ duyệt | Rủi ro hại người thật | Dừng, chờ duyệt |
| Bảng chống chỉ định ghi cứng trong mã | Sắp lặp lỗi ba bản | Lấy từ Danh mục chuẩn |
| Hiện hết tình trạng khách khai | KTV lướt qua, không đọc | Lọc theo dịch vụ của ca |
| Kiểm bậc chỉ ở giao diện | Gọi API là vượt được | Kiểm ở tầng nghiệp vụ |
| Chứng chỉ hết hạn vẫn nhận ca | Rủi ro pháp lý | Kiểm hạn ở mọi lần phân ca |

## Không áp dụng khi

- Nội dung tiếp thị và giới thiệu dịch vụ — nhưng vẫn cấm hứa hiệu quả điều trị
- Dữ liệu thử

## Câu miễn trừ bắt buộc

Mọi màn hiển thị cảnh báo phải kèm: *"Đây là khuyến cáo chung, không thay thế
ý kiến bác sĩ."* ANWELL là nền tảng trung gian, không phải cơ sở khám chữa bệnh.
