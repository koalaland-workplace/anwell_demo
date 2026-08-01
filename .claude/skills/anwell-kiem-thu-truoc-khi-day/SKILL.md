---
name: anwell-kiem-thu-truoc-khi-day
description: Dùng trước mọi lần nhập nhánh hoặc đưa mã lên môi trường thật. Nêu ba tầng kiểm thử bắt buộc xanh và danh sách luồng không được phép đỏ. Nhắc rõ công cụ kiểm cấu trúc báo đạt không có nghĩa là trang hiện được.
---

# Kiểm thử trước khi đẩy

Ba tầng kiểm thử phải xanh trước khi nhập nhánh. Không có ngoại lệ.

**Vì sao có skill này:** Trong bản demo, đã **ba lần** một thay đổi nhỏ làm
trắng hoàn toàn những trang không liên quan — mà công cụ kiểm tra vẫn báo đạt.
Nguyên nhân: công cụ đó chỉ kiểm cấu trúc tệp, không chạy JavaScript. Với nhịp
34 điểm mỗi tuần của đội AI, đây là lưới chắn duy nhất.

## Khi nào dùng

- Trước khi nhập nhánh
- Trước khi đưa lên staging hoặc production
- Sau mỗi thay đổi chạm tới cấu trúc: thêm bớt trang, gộp mục, di chuyển khối

## Ba tầng bắt buộc

| Tầng | Kiểm gì | Bắt buộc xanh |
|---|---|---|
| **Đơn vị** | Quy tắc nghiệp vụ trong gói `loi/` — mỗi quy tắc một bộ | Toàn bộ |
| **API** | Mọi đường API: mã trạng thái, hình dạng dữ liệu, quyền | Toàn bộ |
| **Đầu–cuối** | Chạy trình duyệt thật, đi hết luồng chính | Danh sách dưới |

## Luồng đầu–cuối không được phép đỏ

Nhóm này đỏ thì **không lên production**, không có ngoại lệ:

- Trung tâm đăng ký → ANWELL duyệt → khai dịch vụ → khách đặt được buổi
- Trung tâm phân ca → KTV xác nhận → làm xong → vào báo cáo
- Khách trả tiền → tiền vào đúng nơi → huỷ đúng hạn thì hoàn được
- **Mã xác minh sai thì KHÔNG check-in được**
- **SOS gửi được cảnh báo**
- **Bản ghi định vị không sửa được**
- **Khai huyết áp cao thì dịch vụ nhiệt bị cảnh báo**
- **KTV bậc 1 không nhận được ca bậc 3**
- Chốt kỳ lương: tổng lương + phí nền tảng + thuế = doanh thu ghi nhận

Sáu dòng in đậm là nhóm an toàn và y tế — đỏ ở đây nghĩa là lỗi phần mềm có
thể thành hại người thật.

## Ba điều phải nhớ

1. **Kiểm cấu trúc không thay được kiểm chạy thật.** Tệp đúng cú pháp mà trang
   trắng là chuyện đã xảy ra ba lần.

2. **Rà cả hệ thống, không chỉ phần vừa sửa.** Cả ba lần trang trắng đều xảy ra
   ở trang *không liên quan* tới thay đổi.

3. **Chạy nhanh thì bỏ kiểm thử là chậm hơn.** Lỗi lọt tới tuần 25 đắt gấp
   nhiều lần bắt ở tuần 5.

## Cách làm đúng

```bash
# Trước khi nhập nhánh — cả ba tầng
pnpm test:don-vi && pnpm test:api && pnpm test:dau-cuoi

# Nhóm an toàn chạy riêng, không được đỏ
pnpm test:dau-cuoi --nhom=an-toan
```

## Dấu hiệu đang làm sai

| Nếu anh thấy | Nghĩa là | Sửa thế nào |
|---|---|---|
| Chỉ chạy kiểm thử đơn vị rồi nhập nhánh | Bỏ hai tầng | Chạy đủ ba |
| Bỏ qua một kiểm thử đỏ vì "không liên quan" | Đúng kiểu lỗi đã xảy ra ba lần | Sửa hoặc dừng |
| Quy tắc nghiệp vụ không có kiểm thử riêng | Không kiểm được | Viết kiểm thử trước |
| Kiểm thử đầu–cuối không chạy trình duyệt thật | Không bắt được trang trắng | Dùng Playwright |

## Không áp dụng khi

- Mã thử nghiệm không nhập nhánh
- Sửa tài liệu và chú thích thuần
