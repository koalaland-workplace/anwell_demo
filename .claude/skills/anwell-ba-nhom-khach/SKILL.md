---
name: anwell-ba-nhom-khach
description: Dùng khi viết bất kỳ đoạn nào trả dữ liệu khách cho kỹ thuật viên, hoặc màn hình KTV hiển thị thông tin khách. Nêu bảng ba nhóm khách với tám mức quyền khác nhau — ràng buộc thương mại cốt lõi của ANWELL.
---

# Ba nhóm khách, ba mức quyền

Không phải hai nhóm mà **ba**, và chúng khác nhau ở **quyền** chứ không chỉ ở nhãn.

**Vì sao có skill này:** Đây là ràng buộc làm trung tâm dám giao khách cho KTV.
Nếu KTV lấy được số điện thoại khách của trung tâm thì cả mô hình thu phí nền
tảng sụp. Bản demo hiện cho KTV nhắn thẳng mọi khách — chưa phân biệt ba nhóm.

## Khi nào dùng

- Viết đường API trả dữ liệu khách cho cổng KTV
- Dựng màn hình danh sách khách hoặc hồ sơ khách bên KTV
- Làm chức năng gọi điện, nhắn tin, hoặc xem địa chỉ
- Xử lý việc KTV rời trung tâm

## Bảng quyền

| | Khách tại trung tâm | Khách tại nhà · TT phân công | Khách riêng của KTV |
|---|---|---|---|
| Hồ sơ sức khoẻ | Xem trong ca | Xem trong ca | Xem đầy đủ |
| Số điện thoại | Che, gọi qua tổng đài | Che, gọi qua tổng đài | Hiện, gọi thẳng |
| Địa chỉ | Không cần | **Chỉ mở vào ngày có ca** | Xem đầy đủ |
| Nhắn tin | Qua trung tâm | Qua trung tâm | Trực tiếp |
| Đổi / huỷ lịch | TT duyệt | TT duyệt | KTV tự quyết |
| Giá | TT đặt | TT đặt | KTV đặt |
| Tiền về | Qua trung tâm | Qua trung tâm | Khách trả thẳng, nền tảng thu phí |
| **Khi KTV rời TT** | Mất quyền xem | Mất quyền xem | Giữ nguyên |

## Bốn quy tắc thực thi

1. **Ràng ở API, không ở giao diện.** API không được trả trường số điện thoại
   thật cho khách nhóm 1 và 2 — không phải trả rồi ẩn ở màn hình.

2. **Che số theo mẫu `0903 ••• ••12`.** Đủ để KTV nhận ra đúng người khi trung
   tâm nhắc, không đủ để gọi thẳng. Cuộc gọi đi qua tổng đài che số.

3. **Địa chỉ mở theo cửa sổ thời gian.** Chỉ mở vào ngày có ca, đóng lại sau
   khi check-out. Không phải cờ bật/tắt vĩnh viễn.

4. **Rời trung tâm là cắt sạch, và nói trước.** Khi `ktv_employment.ended_at`
   được đặt, toàn bộ quyền xem khách nhóm 1 và 2 mất ngay. Điều này **phải
   được nói rõ trong app từ lúc KTV mới vào**, không để tới lúc nghỉ mới biết.

## Cách làm đúng

```ts
// SAI — trả hết rồi để giao diện tự ẩn
return { ten, soDienThoai, diaChi, hoSoSucKhoe }

// ĐÚNG — lọc ở tầng nghiệp vụ theo nhóm khách
export function locThongTinKhach(khach: Khach, ktv: Ktv, ngay: Date) {
  const nhom = xacDinhNhom(khach, ktv)          // 'tai_tt' | 'tai_nha_tt_phan' | 'rieng'
  return {
    ten: khach.ten,
    soDienThoai: nhom === 'rieng' ? khach.soDienThoai : cheSo(khach.soDienThoai),
    diaChi: nhom === 'rieng' ? khach.diaChi
          : (nhom === 'tai_nha_tt_phan' && coCaTrongNgay(khach, ktv, ngay))
            ? khach.diaChi : null,
    duongNhanTin: nhom === 'rieng' ? 'truc_tiep' : 'qua_trung_tam',
  }
}
```

## Dấu hiệu đang làm sai

| Nếu anh thấy | Nghĩa là | Sửa thế nào |
|---|---|---|
| API trả `soDienThoai` đầy đủ cho mọi khách | Lộ tài sản của trung tâm | Lọc ở tầng nghiệp vụ |
| Nút nhắn tin giống nhau cho ba nhóm | Chưa phân biệt đường đi | Tách `truc_tiep` và `qua_trung_tam` |
| Địa chỉ là cờ boolean | Không có cửa sổ thời gian | Tính theo ngày có ca |
| Rời trung tâm mà dữ liệu còn | Quyền không bị thu hồi | Kiểm `ended_at` ở mọi truy vấn |

## Không áp dụng khi

- Cổng Trung tâm và cổng Admin — hai cổng đó thấy đủ theo quyền riêng của họ
- Dữ liệu tổng hợp không nêu danh tính (đếm số khách, tỷ lệ quay lại)
