---
name: anwell-du-lieu-bat-bien
description: Dùng khi thiết kế hoặc sửa ba nhóm bảng bất biến — nhật ký thao tác, bản ghi check-in check-out định vị, và biến động ví. Ba bảng này chỉ ghi thêm, cấm cập nhật và cấm xoá ở tầng cơ sở dữ liệu.
---

# Ba bảng chỉ ghi thêm

Ba nhóm bảng dưới đây **chỉ ghi thêm** — cấm `UPDATE`, cấm `DELETE`, ở tầng
cơ sở dữ liệu chứ không chỉ ở tầng ứng dụng.

**Vì sao có skill này:** Cả cơ chế phân xử tranh chấp của ANWELL đứng trên bản
ghi định vị. Khi khách khai giờ khác với hệ thống ghi, trung tâm phân xử bằng
cách đối chiếu với bản ghi đó — nó là *bên thứ ba*. Nếu sửa được thì nó không
chứng minh được gì, và cả mô hình niềm tin sụp theo.

## Khi nào dùng

- Thiết kế hoặc sửa lược đồ ba bảng dưới
- Viết mã ghi vào chúng
- Thấy mình cần "sửa lại" một bản ghi đã có

## Ba nhóm bảng

| Bảng | Dùng làm căn cứ cho | Phase |
|---|---|---|
| `nhat_ky_thao_tac` | Phân xử khiếu nại: ai trừ gói, ai đổi giá, lúc nào | P02 → P15 |
| `session_checkin` · `session_checkout` | Phân xử tranh chấp giờ giữa khách và KTV | P10 |
| `bien_dong_vi` | Đối soát tiền, chứng minh dòng tiền | P07 |

## Bốn quy tắc

1. **Chặn ở tầng CSDL.** Thu hồi quyền `UPDATE` và `DELETE` trên ba bảng này
   với mọi tài khoản ứng dụng. Chặn ở tầng ứng dụng là không đủ — một lệnh SQL
   viết vội là qua được.

2. **Sửa bằng cách ghi thêm.** Cần đính chính thì ghi bản ghi mới có
   `dinh_chinh_cho` trỏ về bản cũ. Bản cũ nằm nguyên.

3. **Chuỗi băm nối tiếp cho nhật ký.** Mỗi dòng chứa băm của dòng trước. Ai
   chèn hoặc xoá giữa chừng là chuỗi đứt và phát hiện được.

4. **Kể cả tài khoản chủ trung tâm cũng không xoá được.** Nếu chủ trung tâm xoá
   được nhật ký thì nhật ký vô nghĩa khi chính họ là bên tranh chấp.

## Cách làm đúng

```sql
-- Chặn ở tầng CSDL, không chỉ ở ứng dụng
REVOKE UPDATE, DELETE ON nhat_ky_thao_tac FROM ung_dung;
REVOKE UPDATE, DELETE ON session_checkin  FROM ung_dung;
REVOKE UPDATE, DELETE ON bien_dong_vi     FROM ung_dung;

CREATE TRIGGER chan_sua_nhat_ky
  BEFORE UPDATE OR DELETE ON nhat_ky_thao_tac
  FOR EACH ROW EXECUTE FUNCTION bao_loi('Bảng chỉ ghi thêm');
```

```ts
// SAI — sửa bản ghi cũ
await db.nhatKy.update({ where: { id }, data: { ghiChu: 'sửa lại' } })

// ĐÚNG — ghi bản đính chính, bản cũ nằm nguyên
await db.nhatKy.create({ data: {
  loai: 'dinh_chinh', dinhChinhCho: id,
  ghiChu: 'Ghi nhầm mã ca, đúng là CA-8821', boiAi: nguoiDung.id,
}})
```

## Dấu hiệu đang làm sai

| Nếu anh thấy | Nghĩa là | Sửa thế nào |
|---|---|---|
| `UPDATE` trên ba bảng này | Bản ghi mất giá trị làm chứng | Ghi bản đính chính |
| Chỉ chặn ở tầng ứng dụng | SQL viết tay là qua được | Thu hồi quyền ở CSDL |
| Nhật ký không có chuỗi băm | Chèn giữa chừng không phát hiện được | Thêm băm nối tiếp |
| Có đường xoá "dọn dữ liệu cũ" | Xoá được là chứng minh không được | Lưu trữ, đừng xoá |

## Không áp dụng khi

- Bảng vận hành thường (đặt chỗ, hồ sơ, lịch) — những bảng đó sửa bình thường
- Bảng đệm và bảng tạm
- Yêu cầu xoá dữ liệu cá nhân theo Nghị định 13 — xem `anwell-du-lieu-ca-nhan`,
  trường hợp đó có quy trình riêng và phải cân với nghĩa vụ lưu giữ chứng từ
