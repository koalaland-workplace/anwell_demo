---
name: anwell-tham-so-chinh-sach
description: Dùng bất cứ khi nào định viết một con số nghiệp vụ vào mã — tỷ lệ, phần trăm, ngưỡng, thời hạn, số buổi, mức phí, giới hạn. ANWELL dựng cơ chế chứ không đặt chính sách; mọi con số là tham số có chủ sở hữu và ngày hiệu lực.
---

# Tham số chính sách — ANWELL dựng cơ chế, không đặt chính sách

Mọi con số nghiệp vụ là **tham số có chủ sở hữu**, không phải hằng số trong mã.

**Vì sao có skill này:** Bản demo đầy con số minh hoạ — lương khoán 30–45%,
chiết khấu 15%, giảm giá theo hạng 5–15%, ngưỡng chất lượng 4.0, huỷ trước 12
giờ, phân xử trong 24 giờ. **Không con số nào trong đó là quyết định của
chúng ta.** Chúng là số mồi để bản demo có gì đó hiển thị. Agent rất dễ chép
thẳng vào mã và tưởng đó là yêu cầu.

Đây cũng là lằn ranh giữa *phần mềm cho một trung tâm* và *nền tảng bán được
cho nhiều trung tâm*. Ghi cứng một con số là tự tay biến sản phẩm thành cái
thứ nhất.

## Khi nào dùng

- Sắp gõ một con số vào mã mà con số đó có ý nghĩa nghiệp vụ
- Thiết kế bảng dữ liệu có cột tỷ lệ, ngưỡng, hoặc thời hạn
- Đọc mô tả chức năng thấy có con số cụ thể

## Sơ đồ quyết định

```
Con số này AI được quyền đổi?

  Chủ sở hữu nền tảng (ANWELL)
     → bang chinh_sach_nen_tang   · ví dụ: khoảng chặn lương khoán, mức chiết khấu tối đa

  Trung tâm
     → bang tham_so_trung_tam     · ví dụ: tỷ lệ lương cụ thể, giá dịch vụ, giờ mở cửa

  Kỹ thuật viên
     → bang tham_so_ktv           · ví dụ: khu vực nhận ca, khung giờ

  KHÔNG AI được đổi, và đổi thì phải sửa mã
     → hằng số kỹ thuật           · ví dụ: độ dài mã OTP, số lần thử lại tối đa
```

Nếu phân vân giữa "chủ nền tảng đặt" và "hằng số kỹ thuật" — chọn tham số.
Biến hằng số thành tham số về sau dễ hơn ngược lại rất nhiều.

## Ba quy tắc

1. **Có chủ sở hữu.** Mỗi tham số ghi rõ ai được đổi. Kiểm quyền ở máy chủ.
2. **Có ngày hiệu lực.** Đổi thì kỳ sau mới áp; kỳ đang mở giữ nguyên để khỏi
   tính lại giữa chừng.
3. **Có nhật ký.** Ai đổi, lúc nào, từ giá trị nào sang giá trị nào.

## Cách làm đúng

```ts
// SAI — chính sách ghi cứng, đổi là phải sửa mã và triển khai lại
const MIN_LUONG = 30, MAX_LUONG = 45
const NGUONG_CHAT_LUONG = 4.0
const HAN_HUY_MIEN_PHI_GIO = 12

// ĐÚNG — khoảng chặn do chủ nền tảng đặt, trung tâm chọn mức trong đó
async function datTyLeLuong(trungTamId: string, tyLe: number, boiAi: string) {
  const chan = await chinhSach.lay('khoang_chan_luong_khoan')
  if (tyLe < chan.min || tyLe > chan.max)
    throw new LoiNghiepVu(`Tỷ lệ phải trong ${chan.min}–${chan.max}%`)
  return thamSo.dat({
    pham_vi: 'trung_tam', pham_vi_id: trungTamId,
    ten: 'ty_le_luong_khoan', gia_tri: tyLe,
    hieu_luc_tu: kyKeTiep(), boi_ai: boiAi,
  })
}
```

## Danh sách số mồi trong bản demo — KHÔNG phải luật

| Con số | Thật ra là | Ai đặt |
|---|---|---|
| Lương khoán 30–45% | Khoảng chặn ví dụ | Chủ nền tảng đặt khoảng, trung tâm chọn mức |
| Chiết khấu 18 / 15 / 12% | Ba gói ví dụ | Chủ nền tảng |
| Giảm theo hạng 5–15% | Quyền lợi ví dụ | Chủ nền tảng |
| Ngưỡng chất lượng 4.0 | Ngưỡng ví dụ | Chủ nền tảng |
| Huỷ miễn phí trước 12 giờ | Chính sách ví dụ | Chủ nền tảng |
| Phân xử trong 24 giờ | Cam kết ví dụ | Chủ nền tảng |
| Hoa hồng tư vấn gói 3% | Ví dụ | Trung tâm, trong khoảng nền tảng cho |
| Phụ cấp ca tại nhà 70k | Ví dụ | Trung tâm |

## Dấu hiệu đang làm sai

| Nếu anh thấy | Nghĩa là | Sửa thế nào |
|---|---|---|
| Số phần trăm viết thẳng trong mã | Ghi cứng chính sách | Chuyển thành tham số |
| Tham số lưu một giá trị duy nhất | Đổi là hỏng kỳ đang mở | Thêm cột ngày hiệu lực |
| Đổi tham số không để lại dấu vết | Tranh chấp không có căn cứ | Ghi nhật ký |
| Kiểm khoảng chặn chỉ ở giao diện | Gọi thẳng API là vượt được | Kiểm ở máy chủ |

## Không áp dụng khi

- Hằng số kỹ thuật thuần: độ dài mã OTP, kích thước trang, thời gian chờ mạng
- Số liệu trong bản demo và dữ liệu thử
- **Quyết định nên đặt mức bao nhiêu** — đó là việc của chủ nền tảng và trung
  tâm, không phải của mã và cũng không phải của agent
