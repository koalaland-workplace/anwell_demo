---
name: anwell-du-lieu-ca-nhan
description: Dùng khi xử lý CCCD, hồ sơ sức khoẻ, giấy tờ, số điện thoại, địa chỉ, hoặc bất kỳ dữ liệu nào của người thật. Nêu bốn nghĩa vụ theo Nghị định 13/2023 và nguyên tắc thu tới đâu giữ tới đó.
---

# Dữ liệu cá nhân

ANWELL giữ ba thứ nhạy cảm cùng lúc: **dữ liệu sức khoẻ**, **giấy tờ tuỳ thân**,
và **dòng tiền**. Dữ liệu sức khoẻ là nhóm nhạy cảm theo Nghị định 13/2023, có
nghĩa vụ riêng và mức phạt riêng.

**Vì sao có skill này:** Bản demo đã **hứa với khách ngay trong app** từ Phase
đầu: *"Dữ liệu thuộc về bạn. Bạn xoá được bất cứ lúc nào."* Hứa rồi thì phải
làm — và nếu chưa làm được thì phải sửa câu chữ, không để nguyên.

## Khi nào dùng

- Thiết kế bảng chứa dữ liệu người thật
- Viết mã đọc hoặc ghi hồ sơ sức khoẻ, CCCD, giấy tờ
- Làm chức năng xuất, xoá, hoặc chia sẻ dữ liệu
- Viết câu chữ nói với người dùng về dữ liệu của họ

## Bốn nghĩa vụ

1. **Thu tới đâu giữ tới đó.** Trung tâm chỉ thấy **bốn số cuối** CCCD kèm dấu
   đã xác minh. Bản đầy đủ chỉ ANWELL giữ — bên chịu trách nhiệm thẩm định.
   Trung tâm cần biết người này là thật, không cần giữ số định danh của họ.

2. **Mã hoá khi lưu.** CCCD, hồ sơ sức khoẻ, ảnh giấy tờ, lý lịch tư pháp.
   Khoá mã hoá không nằm cùng chỗ với dữ liệu.

3. **Ghi nhật ký ai xem hồ sơ sức khoẻ.** Ai, lúc nào, vì ca nào. Khách xem
   được nhật ký của chính mình — đây vừa là điểm tin cậy vừa là nghĩa vụ.

4. **Khách xem, xuất và xoá được dữ liệu của mình**, trong hạn luật định. Có
   đồng hồ đếm hạn ở hàng chờ xử lý; quá hạn là vi phạm.

## Xoá — và ngoại lệ

Xoá theo yêu cầu phải cân với nghĩa vụ giữ chứng từ. Quy tắc:

| Loại dữ liệu | Xoá được | Vì sao |
|---|---|---|
| Hồ sơ sức khoẻ, ghi chú, ảnh | Có | Không phải chứng từ |
| Tên, số điện thoại, địa chỉ | Ẩn danh hoá | Đơn hàng cũ vẫn cần tồn tại |
| Bản ghi giao dịch, hoá đơn | Không | Nghĩa vụ kế toán và thuế |
| Nhật ký thao tác, bản ghi định vị | Không | Căn cứ phân xử — xem `anwell-du-lieu-bat-bien` |

Khi từ chối xoá một phần, **phải nói rõ lý do cho khách**, không im lặng.

## Cách làm đúng

```ts
// SAI — trả CCCD đầy đủ cho mọi vai
return { ten, cccd: ktv.cccd }

// ĐÚNG — che theo vai, ghi nhật ký khi xem bản đầy đủ
export async function xemHoSoKtv(ktvId: string, nguoiXem: NguoiDung) {
  const ktv = await layKtv(ktvId)
  if (nguoiXem.vai === 'anwell') {
    await nhatKyTruyCap.ghi({ ktvId, boiAi: nguoiXem.id, lyDo: 'tham_dinh' })
    return { ...ktv, cccd: giaiMa(ktv.cccdMaHoa) }
  }
  return { ...ktv, cccd: `•••• •••• ${ktv.cccdBonSoCuoi}`, daXacMinh: true }
}
```

## Dấu hiệu đang làm sai

| Nếu anh thấy | Nghĩa là | Sửa thế nào |
|---|---|---|
| CCCD đầy đủ trong màn của trung tâm | Vi phạm tối thiểu hoá dữ liệu | Che còn bốn số cuối |
| Hồ sơ sức khoẻ lưu dạng chữ thường | Không mã hoá | Mã hoá khi lưu |
| Xem hồ sơ sức khoẻ không để lại dấu vết | Thiếu nhật ký truy cập | Ghi nhật ký |
| Ô ghi chú tự do chứa thông tin sức khoẻ vào nhật ký hệ thống | Rò dữ liệu nhạy cảm | Loại khỏi nhật ký và thông báo đẩy |
| Không có đường xoá dù đã hứa trong app | Vi phạm và thất hứa | Làm, hoặc sửa câu chữ |

## Không áp dụng khi

- Dữ liệu tổng hợp không nêu danh tính
- Dữ liệu thử và dữ liệu giả lập
