---
name: anwell-muc-do-phase
description: Dùng trước khi bắt đầu bất kỳ chức năng nào. Tra chức năng trong bảng 15 Phase để biết đang làm Mức 1 Cơ bản hay Mức 2 Đầy đủ, và đọc danh sách những thứ Phase này CỐ Ý CHƯA LÀM. Cấm làm quá mức đã định.
---

# Làm đúng mức của Phase

Mỗi chức năng có một **mức độ** ứng với Phase đang chạy. Làm quá mức là cách
chắc chắn nhất để vỡ tiến độ 32 tuần.

**Vì sao có skill này:** Agent luôn có xu hướng làm cho trọn vẹn — thấy trang
đăng ký trung tâm thì muốn làm luôn KYC, giấy phép hành nghề, vòng đời sáu
trạng thái. Nhưng ở P01 PILOT, tất cả những thứ đó **cố ý bị bỏ qua** để có
người dùng thật sớm. Ba mươi hai tuần chỉ đủ nếu mỗi Phase làm đúng phần của nó.

## Khi nào dùng

- Trước khi viết dòng mã đầu tiên cho bất kỳ chức năng nào
- Khi thấy một chức năng "còn thiếu" thứ gì đó
- Khi định thêm trường vào biểu mẫu, thêm trạng thái vào luồng, thêm kiểm tra

## Quy trình năm bước

1. **Tra mã chức năng** (dạng `APP-B05`, `TT-L05`, `KTV-C08`) trong
   `Tailieu-noibo/ANWELL-15-phase-theo-muc-do.xlsx` → sheet *Chức năng theo Phase*.


2. **Đọc cột "Mức độ"** — Mức 1 Cơ bản, Mức 2 Đầy đủ, hay Mức 3 Nâng cao.

3. **Đọc cột "Phạm vi làm ở mức này"** — đây là ranh giới. Làm đúng chừng đó.

4. **Kiểm danh sách CẮT SẴN** — sheet *Cắt sẵn theo mốc ngân sách* trong cùng
   file. 22 chức năng đã bị cắt hẳn khỏi P01–P04 và 6 nhóm bị hạ từ Mức 2 xuống
   Mức 1. Chủ dự án đã chốt. Làm một chức năng nằm trong đó là làm việc đã huỷ.
   Sheet đó cũng có mục **TUYỆT ĐỐI KHÔNG CẮT** — sáu thứ không được bỏ dù bị ép
   tiến độ, vì chạm sức khoẻ người thật, nghĩa vụ pháp lý, hoặc bằng chứng khi
   tranh chấp.

5. **Đọc cột "CỐ Ý CHƯA LÀM" của Phase** ở sheet *15 Phase* — đây là danh sách
   những thứ **không** được làm bây giờ.

## Ba mức

| Mức | Nghĩa | Thái độ |
|---|---|---|
| **1 · Cơ bản** | Bản tối thiểu để chạy được và có người dùng thật | Cố ý bỏ thủ tục, kiểm tra, trường hợp biên |
| **2 · Đầy đủ** | Đủ nghiệp vụ như mô tả trong bản demo | Phần lớn chức năng làm thẳng ở mức này |
| **3 · Nâng cao** | Chỉ có nghĩa khi đã có app thật hoặc dữ liệu tích luỹ | Đừng làm sớm |

## Ví dụ — đăng ký trung tâm

| | Mức 1 · P01 (T5–8) | Mức 2 · P04 (T15–16) |
|---|---|---|
| Thông tin khai | Tên, địa chỉ, dịch vụ, ảnh | Đủ bốn nhóm gồm fanpage, hoạt động, pháp lý |
| Giấy phép hành nghề | Không hỏi | Bật có điều kiện theo loại dịch vụ |
| Duyệt | ANWELL duyệt tay, hai trạng thái | Vòng đời sáu trạng thái, khoá nút khi thiếu giấy tờ |
| KYC | Không có | Có, kèm che CCCD còn bốn số cuối |

Ở P01, viết thêm phần KYC **không phải là làm tốt hơn** — đó là làm sai Phase.

## Khi thấy thiếu thứ gì

Đừng tự thêm. Làm ba bước:

1. Kiểm xem thứ đó có nằm ở Mức 2 hoặc Phase sau không → nếu có thì để yên
2. Nếu không thấy ở đâu → báo điều phối viên, đừng tự quyết
3. Ghi vào danh sách phát hiện để rà lại cuối Phase

## Dấu hiệu đang làm sai

| Nếu anh thấy | Nghĩa là | Sửa thế nào |
|---|---|---|
| Thêm trường không có trong "Phạm vi làm ở mức này" | Làm quá mức | Bỏ ra, ghi vào danh sách phát hiện |
| Làm thứ nằm trong cột "CỐ Ý CHƯA LÀM" | Như trên | Như trên |
| Không tra bảng trước khi viết mã | Không biết ranh giới | Tra trước |
| "Làm luôn cho đủ, sau khỏi sửa" | Nhầm — sửa sau rẻ hơn chậm ra mắt | Làm đúng mức |

## Không áp dụng khi

- Sửa lỗi trong phần đã làm ở Phase trước
- Việc hạ tầng và kiểm thử — những thứ đó làm đủ ngay từ đầu, không chia mức
