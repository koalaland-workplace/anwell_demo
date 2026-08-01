# Việc đang làm & còn treo

Cập nhật 31/07/2026. Đây là chỗ ghi **những gì chưa xong và vì sao**, để người
tiếp nhận không phải đọc lại toàn bộ lịch sử trò chuyện.

## Trạng thái hiện tại

Sáu trang, tất cả đã đẩy lên và chạy trên
**https://koalaland-workplace.github.io/anwell_demo/**

| Trang | Quy mô | Tình trạng |
|---|---|---|
| `index.html` | ANWELL Portal | Xong |
| `demo.html` | Trang gom các cổng | Xong · không có link nào từ Portal, mở bằng địa chỉ trực tiếp |
| `app.html` | 5 mục thanh đáy | Xong |
| `ktv.html` | 5 mục, hai chế độ | Xong |
| `center.html` | 14 trang / 5 nhóm | Xong |
| `bd.html` | 6 mục / 3 nhóm | Xong · mới dựng 02/08/2026 |
| `admin.html` | 14 trang / 5 nhóm | Xong |

## Việc còn treo

### Đã bàn và chốt là làm sau

| Việc | Ghi chú |
|---|---|
| **Trung tâm: kho sản phẩm bán ra** | Kho hiện chỉ có vật tư tiêu hao nội bộ |
| **Trung tâm: thu chi & công nợ** | |
| **Trung tâm: báo cáo lợi nhuận** | Giá vốn mỗi buổi đã có, đủ nền để tính. Hiện cố ý gọi *"Trung tâm còn lại"* chứ không gọi lợi nhuận vì chưa trừ thuê nhà, điện nước, lương lễ tân |
| **POS** | **Đã bỏ theo yêu cầu chủ dự án** — không làm |

### Đã nêu, chủ dự án chưa quyết

| Việc | Câu hỏi để mở |
|---|---|
| **Bộ chọn vai trò chi phối cả portal** | Hiện chỉ ảnh hưởng trang *Lương khoán KTV*. Muốn lễ tân không thấy Doanh thu, Social Media không vào Cấu hình thì phải gài quyền ở mọi trang. Chủ dự án nói *"chưa cần làm việc đó"* |
| **`demo.html` để làm gì tiếp** | Ba lựa chọn đã nêu: giữ nguyên làm link riêng · xoá hẳn · để một link nhỏ ở chân trang Portal |
| **ANWELL tổng hợp tranh chấp giữa trung tâm và KTV** | Nếu một trung tâm liên tục xử bất lợi cho KTV thì nền tảng có biết không? Trang *Cần xử lý → Khiếu nại leo thang* đã nhận từng vụ, chưa có thống kê theo trung tâm |
| **Ghi chú "cho KTV sau" thuộc về ai khi KTV chuyển trung tâm** | Hiện ghi chú chỉ chạy trong phạm vi một trung tâm |

## Những quyết định đã chốt — đừng làm lại

Ghi ở đây để phiên sau không đề xuất ngược.

| Quyết định | Chốt là |
|---|---|
| Đánh giá khách hai chiều | **Khách không thấy điểm mình bị chấm.** KTV dám ghi thật, và số sao thì vô nghĩa còn lý do thì dùng được |
| KTV rời trung tâm | **Cắt sạch, và nói rõ ngay trong app** từ đầu, không để tới lúc nghỉ mới biết |
| Lý lịch tư pháp KTV | **Chỉ yêu cầu với ca tại nhà**, không yêu cầu với người chỉ làm tại cơ sở |
| Chi phí thưởng điểm ANP | **Chia tỷ lệ**, hiện thành một dòng riêng trong Đối soát nền tảng |
| Lương KTV | **Tỷ lệ 30–45% trên giá niêm yết sau thuế, chưa trừ ưu đãi.** Nền tảng chặn cứng hai đầu. Chỉ Giám đốc sửa được |
| Nơi đặt quy định lương | **Chỉ một chỗ:** `center.html` → Dịch vụ & bảng giá → Lương khoán KTV. Trang *Lương & hoa hồng* chỉ hiển thị |
| Chế độ hưởng hoa hồng GĐKD | **Là lựa chọn ADMIN đặt**, không ghi cứng — Hội đồng quản trị sẽ bỏ phiếu sau |
| Mô hình gói nền tảng | **Nhiều gói thuê bao + chiết khấu khác nhau**, ba cho trung tâm ba cho KTV |
| Quyền dữ liệu cá nhân | **Có làm**, một tab trong trang Khách hàng của `admin.html` |

## Số liệu phải khớp giữa các trang

Đây là những con số **cố ý** giống nhau ở nhiều nơi. Sửa một chỗ thì phải sửa hết.

| Con số | Xuất hiện ở |
|---|---|
| Trị liệu cổ vai gáy 60′ = **450k** | Bảng giá `center` · màn xác nhận đặt lịch `app` · ví dụ tính lương · lịch sử buổi trong hồ sơ khách |
| KTV Trần Hải Yến nhận **11,20tr** từ trung tâm | Bảng lương `center` · mục Tài chính `ktv` |
| Gói Phục hồi sau đột quỵ **còn 14/20 buổi** | Ví & gói `app` · Liệu trình & gói `center` |
| Mã xác minh buổi **4729** | Màn buổi làm việc `app` · ô nhập khi check-in `ktv` |
| Đổi sang Vật lý trị liệu 45′ = **hoàn 70k** | Đề xuất `ktv` · màn chờ đồng ý `app` |
| Điểm ANP của Minh Trần = **1.240** | Hạng thành viên `app` · hồ sơ khách `center` |
| Chống chỉ định (huyết áp cao, loãng xương…) | `app` · `ktv` · Danh mục chuẩn `admin` |

**Bảng chống chỉ định từng có hai bản riêng và đã gây lỗi thật** — khách khai
huyết áp cao mà không dịch vụ nào cảnh báo. Giờ `admin.html` → Danh mục chuẩn là
nguồn được coi là chuẩn, nhưng `app.html` và `ktv.html` vẫn giữ bản sao trong mã.
Sửa thì phải sửa cả ba.

## Ba lỗi đã mắc — cách tránh

| Lỗi | Cách tránh |
|---|---|
| Thẻ `sc-if` bọc nhầm khi gộp mục → 6 trang trắng | Sau mỗi thay đổi cấu trúc, chạy đoạn đếm `sc-if` mở/đóng và duyệt từng trang bằng trình duyệt |
| Đổi menu mà quên thanh nav dưới → trang trắng | `bIds` ở cuối `renderVals` phải trỏ vào id trang có thật |
| Thay thế theo mốc quá rộng → mất khối logic | Sửa từng đoạn nhỏ, chạy `build.py` sau mỗi bước |

Chi tiết ở [Quản lý & cập nhật](04-quan-ly-va-cap-nhat.md).
