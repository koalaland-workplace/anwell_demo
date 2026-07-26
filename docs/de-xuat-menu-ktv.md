# Bố cục menu — Giao diện Kỹ thuật viên

**Đã chốt và đã dựng · 2026-07-27**

Năm ô menu giống hệt nhau ở cả hai chế độ: **Tổng quan · Lịch · Khách · Thu nhập
· Tôi**. Xem bản chạy tại
https://koalaland-workplace.github.io/anwell_demo/ktv.html

## Nguyên tắc

`admin.html` mô tả mô hình hai lớp: *"ANWELL trực tiếp quản lý KTV khi họ làm tự
do. KTV đang làm tại trung tâm do trung tâm điều phối và chấm điểm."*

Đây là **một người với hai quan hệ lao động**, không phải hai người khác nhau:

| | Tại trung tâm | Tự do |
|---|---|---|
| Đối tác | An Nhiên Wellness | ANWELL |
| Vai trò của KTV | Người làm công | Người tự kinh doanh |
| Ai giao việc | Trung tâm phân ca | KTV tự nhận |
| Ai đánh giá | Trung tâm · 94/100 | Khách · 4,9★ + ANWELL xếp bậc |
| Dòng tiền | Lương theo ca · 11,2tr | Doanh thu − phí 15% · 7,4tr |

Công việc thì giống nhau ở cả hai chế độ: hôm nay làm gì → sắp tới làm gì → làm
cho ai → được bao nhiêu → mình đang ở đâu. Vì vậy năm mục menu dùng chung tên;
chỉ nội dung và thao tác đổi theo đối tác.

## 1 · Tổng quan — "Hôm nay tôi làm gì"

| | Tại trung tâm | Tự do |
|---|---|---|
| Thẻ đầu | Ca hôm nay · An Nhiên — 08:00 bắt đầu, 4/6 hoàn tất, 1,2tr | Trạng thái nhận khách + tóm tắt lịch nhận khách |
| Nội dung chính | 6 ca trung tâm phân: giờ, dịch vụ, khách, phòng, trạng thái | 2 yêu cầu mới: giá, khoảng cách, tuổi khách |
| Chỉ số | Trung tâm chấm điểm 94/100 | 11 ca tuần · 4,2tr · 4,9★ · 92% nhận ca |
| Thao tác | Bắt đầu ca · mở buổi làm việc · check-in | Bật/tắt nhận khách · Nhận ca / Bỏ qua · check-in |
| Dữ liệu | Có sẵn | Có sẵn |

Còn thiếu: chế độ trung tâm không nhắc điểm đến kế tiếp dù có ca tại nhà
(`17:00 · Bà Phạm T. Lan · Q.3`). Nên thêm dòng "Điểm kế tiếp" khi ca ngoài cơ sở.

## 2 · Lịch — "Sắp tới, và khi nào tôi rảnh"

Ba tab bên trong, cùng cấu trúc ở cả hai chế độ.

| Tab | Tại trung tâm | Tự do |
|---|---|---|
| Danh sách | 7 ngày + ca trung tâm phân, kèm phòng | 7 ngày + ca đã nhận |
| Bản đồ | Chỉ ca tại nhà — thứ tự điểm, thời gian di chuyển | Đủ 3 điểm, tổng quãng đường, chỉ đường |
| Khả dụng | Hai chiều có duyệt — xem mục riêng bên dưới | Lịch nhận khách công khai · hiệu lực ngay |
| Dữ liệu | Danh sách: có · Bản đồ: chưa nối · Khả dụng: chưa có | Có cả ba |

**Đã chốt 2026-07-27:** "Lộ trình" thành tab Bản đồ trong Lịch, không còn là ô
nav riêng. Nó vốn chỉ là cách xem khác của Lịch — cùng dữ liệu ca hôm nay, vẽ lên
bản đồ. Giữ làm ô nav riêng thì tốn một ô, và chế độ trung tâm không dùng được dù
cũng có ca tại nhà.

### Tab Khả dụng — quy tắc điều phối

**Đã chốt 2026-07-27.** Chế độ tại trung tâm là luồng **hai chiều có phê duyệt**,
không phải bảng cài đặt một chiều:

- Trung tâm phân công → KTV xác nhận
- KTV đề xuất → Trung tâm xác nhận
- Đổi lịch, hoãn lịch → phải được duyệt
- Trừ ốm đau và các trường hợp bất khả kháng → có hiệu lực ngay

`center.html` đã có sẵn phía đối ứng: thẻ yêu cầu với ba nút (xác nhận / "Đề xuất
giờ khác" / "Từ chối"), mục "Cần xử lý — Việc tồn đọng cần quyết định", và trạng
thái KTV *"Tại cơ sở / Tại nhà khách / Nghỉ · bận"*. Phía KTV chưa có chỗ đề xuất
và xác nhận — đó là phần phải dựng.

#### Bốn khối, xếp theo mức cần hành động

**① Chờ tôi xác nhận** — trung tâm vừa phân xuống

> `T4 · 14:00–15:00 · Trị liệu cổ vai gáy · Phòng 3`
> [Xác nhận] · [Đề xuất giờ khác] · [Từ chối — kèm lý do]

**② Tôi đề xuất — chờ trung tâm duyệt**

> `T6 · xin đổi 09:00 → 15:00 · lý do: trùng lịch khám`
> `Chờ An Nhiên duyệt · gửi 2 giờ trước` · [Huỷ đề xuất]

**③ Khung giờ rảnh hằng tuần** — KTV khai trước, trung tâm dùng làm căn cứ phân ca

> `T2–T6 · 08:00–18:00` · `T7 · 08:00–12:00` · `CN · không nhận`
>
> Ghi rõ trên giao diện: *"Đây là đề xuất. Trung tâm vẫn có thể phân ca ngoài
> khung này, bạn xác nhận hoặc từ chối ở mục ①."*

**④ Báo bận khẩn cấp** — ốm đau, bất khả kháng

> Có hiệu lực ngay, không chờ duyệt. Bắt buộc ghi lý do, tự động báo trung tâm
> điều phối lại. Hiển thị kèm `Đã dùng 2 lần trong 90 ngày` vì ảnh hưởng chỉ số
> Tuân thủ quy trình 88% trong hồ sơ.

#### Chế độ tự do — một chiều, hiệu lực ngay

Không ai duyệt. Nhưng không phải không có hậu quả: huỷ ca đã nhận thì ảnh hưởng
`Tỷ lệ nhận ca 92%`, mà chỉ số đó *"ảnh hưởng thứ hạng"* hiển thị với khách.

Đối xứng: tại trung tâm chặn bằng **cửa duyệt**, tự do chặn bằng **hậu quả thị
trường**. Cùng một hành vi, hai cơ chế kiểm soát — phản ánh đúng hai quan hệ lao
động.

## 3 · Khách — "Tôi đang chăm ai"

| | Tại trung tâm | Tự do |
|---|---|---|
| Danh sách | Khách mình đang phụ trách, lấy từ ca được phân | CRM riêng: 38 khách · 12 định kỳ |
| Mỗi dòng | Tên · liệu trình `buổi 7/20` · buổi gần nhất · ghi chú chuyên môn | Thêm nhãn `Định kỳ` / `Nên nhắc` / `Chăm mới` · doanh thu theo khách |
| Xem được | Lịch sử buổi mình làm, tiến triển, dặn dò | Toàn bộ hồ sơ và liên hệ |
| Không xem được | Số điện thoại, giá, hồ sơ đầy đủ — thuộc trung tâm | — |
| Thao tác | Ghi chú buổi · nhắn qua trung tâm | Nhắn trực tiếp · đặt lại lịch · nhắc khách · đặt giá riêng |
| Dữ liệu | **Đang là thẻ trống** | Có sẵn |

Đây là ô hỏng nặng nhất hiện nay. Chế độ trung tâm bấm vào chỉ thấy một thẻ ghi
"khách thuộc An Nhiên, chuyển sang chế độ tự do". Nhưng KTV có khách — sáu người
trong ca hôm nay. Họ chỉ không sở hữu quan hệ đó. Giới hạn đúng là ẩn thông tin
thương mại, không phải ẩn cả trang.

## 4 · Thu nhập — "Được bao nhiêu, từ ai, khi nào nhận"

| | Tại trung tâm | Tự do |
|---|---|---|
| Số lớn | Lương từ An Nhiên 11,2tr · kỳ đối soát tới | Doanh thu tự do 7,4tr · sau phí 15% |
| Bóc tách | Theo ca đã phân · thưởng chất lượng | Tổng thu − phí nền tảng − thuế = thực nhận |
| Chờ nhận | Ca tuần 30 · chờ chốt bảng lương · 2,60tr · chuyển 05/08 | Khách chưa thanh toán 0,26tr · quá 2 ngày |
| Thao tác | Xem bảng lương · khiếu nại ca | Nhắc khách trả · rút tiền · xuất kê khai thuế |
| Chung | Nút "Xem tổng cả hai nguồn" → trang gộp 18,6tr hiện có | Như bên trái |
| Dữ liệu | Có, cần tách theo chế độ | Có, nhưng chưa có ô nav để vào |

## 5 · Tôi — "Tôi là ai, tốt đến đâu, đi tiếp thế nào"

**Giống nhau 100% ở cả hai chế độ** — chốt bởi chủ dự án 2026-07-27.

Lý do: bốn mục trước đổi theo *đối tác* (An Nhiên hay ANWELL), nhưng mục Tôi nói
về *con người*, mà con người thì chỉ có một. Trần Hải Yến có một mã KTV, một
chứng nhận, một bậc, một lộ trình thăng tiến — dù đang xem ở chế độ nào.

Hệ quả: hồ sơ phải chứa **cả hai** nguồn đánh giá, vì cùng một người được hai bên
chấm theo hai cách.

| Khối | Nội dung (không đổi theo chế độ) |
|---|---|
| Danh tính | `HY` · Trần Hải Yến · Mã KTV `AW-KTV-0316` · tham gia 03/2024 · `Bậc 2 · Trị liệu` · `✓ Xác minh` |
| Chất lượng | Trung tâm An Nhiên chấm **94/100** — đúng giờ 96% · tuân thủ quy trình 88%<br>Khách đánh giá **4,9★** — 38 lượt · 92% cải thiện<br>Tỷ lệ nhận ca 92% |
| Thăng tiến | Lộ trình lên Bậc 3 · 68% — bốn điều kiện, hai đã xong |
| Chế độ & liên kết | Liên kết trung tâm · Giá dịch vụ riêng · Khung giờ nhận khách · Đánh giá của khách · Tin nhắn với gia đình · Chứng nhận & hồ sơ · Đào tạo & nâng bậc · Cài đặt & ngôn ngữ |
| Khẩn cấp | Nút SOS |

Việc này giải quyết luôn hai chỗ đặt nhầm: `scoreBars` (94/100) đang nằm ở Tổng
quan và `myReviews` đang chôn sâu hai lớp — cả hai về đúng chỗ là Tôi.

### Ba mục đề xuất thêm — chờ duyệt

| Mục | Vì sao |
|---|---|
| Khu vực phục vụ | Hiện chỉ khai lẻ trong từng khung giờ, chưa có chỗ khai tổng thể |
| Phương thức nhận tiền | Có ba nguồn tiền (trung tâm, nền tảng, khách trả trực tiếp) mà không có chỗ khai tài khoản |
| Hồ sơ công khai với khách | Xem trước khách nhìn thấy mình thế nào; `app.html` đã có màn hình hồ sơ KTV nên dữ liệu sẵn |

## Việc phải dựng nếu chốt phương án này

| Mức | Việc | Vì sao |
|---|---|---|
| Nặng | Trang Khách cho chế độ trung tâm | Đang là thẻ trống |
| Nặng | Tab Khả dụng cho chế độ trung tâm (đăng ký giờ rảnh + xin nghỉ) | Chưa có; trung tâm đang cần |
| Vừa | Tách Thu nhập theo chế độ + nút xem tổng | Dữ liệu có, chỉ cần lọc và thêm nav |
| Vừa | Gộp Lộ trình thành tab Bản đồ trong Lịch | Chuyển chỗ, không viết lại |
| Nhẹ | Đưa `scoreBars` và `myReviews` vào Tôi, hiện ở cả hai chế độ | Chuyển chỗ |
| Nhẹ | Đổi ô 4 nav chế độ tự do: Lộ trình → Thu nhập | Đổi nhãn |

## Trạng thái chốt

| Mục | Trạng thái |
|---|---|
| 1 · Tổng quan | Đã dựng — bỏ khối chấm điểm (chuyển sang Tôi) |
| 2 · Lịch | Đã dựng — ba tab; Lộ trình thành tab Bản đồ; Khả dụng hai chiều có duyệt |
| 3 · Khách | Đã dựng — chế độ trung tâm có màn hình thật, ranh giới chuyên môn/thương mại |
| 4 · Thu nhập | Đã dựng — vào được từ cả hai chế độ, tách nội dung, có nút xem tổng |
| 5 · Tôi | Đã dựng — giống nhau 100%, gộp cả hai nguồn đánh giá |

Tên ba tab trong Lịch cũng giống nhau ở hai chế độ (Danh sách · Bản đồ · Khả
dụng), theo cùng nguyên tắc với điều hướng chính.

## Còn dang dở

| Việc | Ghi chú |
|---|---|
| Nút "Sửa" và "+ Thêm" của khung giờ rảnh hằng tuần | Chưa nối biểu mẫu; hiện chỉ có nút Xoá chạy thật |
| Hình minh hoạ bản đồ | Vẫn vẽ ba chấm cố định dù chế độ trung tâm chỉ có một điểm dừng — là hình trang trí, chưa vẽ theo dữ liệu |
| Ba mục đề xuất thêm vào Tôi | Khu vực phục vụ · Phương thức nhận tiền · Hồ sơ công khai với khách — chưa dựng, chờ chủ dự án duyệt |
| Dòng "Điểm kế tiếp" ở Tổng quan chế độ trung tâm | Đề xuất ở mục 1, chưa dựng |
