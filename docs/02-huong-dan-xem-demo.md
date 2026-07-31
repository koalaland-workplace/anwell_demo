# Hướng dẫn xem demo

Tài liệu này viết cho người mở demo lần đầu, không cần biết gì về công nghệ.

## Trước khi bắt đầu — ba điều cần biết

1. **Đây là bản mô phỏng.** Mọi tên người, số điện thoại, số tiền, đánh giá đều
   là dữ liệu giả để minh hoạ. Không có khách hàng thật nào trong này.
2. **Bấm thoải mái, không hỏng gì.** Không có tài khoản, không lưu dữ liệu. Tải
   lại trang là mọi thứ về như cũ.
3. **Xem trên điện thoại hay máy tính đều được.** Giao diện Khách hàng và Kỹ
   thuật viên là ứng dụng điện thoại, hiển thị trong khung máy giả lập. Giao diện
   Trung tâm và Quản trị là bảng điều khiển, xem trên máy tính dễ nhìn hơn.

## Mở demo

Vào **https://koalaland-workplace.github.io/anwell_demo/** — đó là **ANWELL
Portal**, trang giới thiệu. Cuộn tới mục **Nền tảng**, ở đó có năm khối; bốn khối
bấm thẳng vào bản demo tương ứng.

Hoặc mở thẳng:

| Muốn xem | Địa chỉ |
|---|---|
| Trải nghiệm của khách | `.../app.html` |
| Công cụ của trung tâm | `.../center.html` |
| Ứng dụng của kỹ thuật viên | `.../ktv.html` |
| Bảng điều hành ANWELL | `.../admin.html` |
| Trang gom cả bốn cổng | `.../demo.html` |

> **Khối *Giám đốc Kinh doanh* không bấm được** và ghi *đang xây dựng* — cổng đó
> chưa có bản riêng. Muốn xem tạm thì vào `admin.html` → **Giám đốc Kinh doanh**
> → tab *Xem trước màn GĐKD*.

> **Nếu thấy bản cũ:** trình duyệt giữ bản đã tải trước đó. Bấm `Cmd + Shift + R`
> (máy Mac) hoặc `Ctrl + F5` (máy Windows) để tải lại từ đầu.

---

## Giao diện Khách hàng

**Vào đâu:** `app.html`

**Bấm gì trước:** phía trên khung điện thoại có ba nút *An Nhiên · Rừng Thẫm ·
Nhịp Sen* — đó là ba phong cách hiển thị để khách tự chọn. Bấm thử để thấy cả
màu sắc và không khí đổi theo.

**Đường đi đáng xem nhất:**

1. Màn hình chào → bấm qua vài bước giới thiệu
2. **Khám phá** → chọn một cơ sở → xem ảnh, dịch vụ, đánh giá
3. Quay lại → chọn **KTV tại nhà** → xem hồ sơ kỹ thuật viên, đánh giá của khách
4. **Đặt lịch** → chọn dịch vụ, giờ, xác nhận
5. Thanh dưới cùng → **Hành trình An** để xem hạng thành viên và điểm tích luỹ
6. **Tôi** → nhóm gia đình, ví, giới thiệu bạn bè

---

## Giao diện Kỹ thuật viên

**Vào đâu:** `ktv.html`

**Điều quan trọng nhất phải hiểu:** kỹ thuật viên có **hai chế độ làm việc**, và
nút chuyển nằm **bên trong từng mục**, không phải ở đầu màn hình.

- **Tại trung tâm** — làm công cho cơ sở, trung tâm phân ca và chấm điểm
- **Làm tự do** — tự nhận khách riêng, ANWELL thu phí nền tảng

Mỗi mục nhớ riêng lựa chọn của nó: đổi sang "Làm tự do" ở mục Lịch làm thì mục
Khách hàng vẫn giữ chế độ cũ.

**Đường đi đáng xem nhất:**

1. **Tổng quan** → thẻ vàng nhấp nháy ở đầu là việc cần làm ngay, bấm vào
2. **Lịch làm** → lịch tháng, mũi tên đổi tháng, ngày đã qua làm mờ
3. Vẫn ở Lịch làm → tab **Khả dụng** (có số đỏ) → đây là phần hay nhất:
   - Bấm **Đề xuất giờ khác** ở một ca → ca nhảy xuống khối "Tôi đề xuất", số đỏ
     tụt xuống
   - Cuộn xuống cuối → **Báo bận** → vào thẳng trạng thái *đã có hiệu lực*, không
     qua duyệt
4. Trở lại tab **Danh sách** → bấm **Đổi giờ** ở một ca → chọn giờ mới, chọn lý
   do (bắt buộc), gửi
5. Đổi sang chế độ **Làm tự do** → chú ý màn hình **không nhảy đi đâu**, chỉ nội
   dung bên dưới đổi
6. **Tôi** → cuộn xuống xem chứng chỉ, cấu hình hiển thị, và mục **Thuế & hoá
   đơn** — thử bấm *Tự kê khai* để thấy các con số đổi theo

---

## Giao diện Trung tâm

**Vào đâu:** `center.html` · **14 trang / 5 nhóm**

Đây là phía đối ứng: những gì khách và kỹ thuật viên gửi lên sẽ hiện ở đây.

**Đường đi đáng xem nhất:**

1. **Quầy lễ tân → Đang diễn ra** → ảnh chụp lúc 15:20, phòng nào đang chạy còn
   mấy phút, phòng nào trống
2. **Quầy lễ tân → Khách đến hôm nay** → bấm *Đã đến* hoặc *Vắng mặt*; khách quá
   giờ 15 phút tự được đánh dấu **Trễ**
3. **Cần duyệt → Từ khách** → yêu cầu cuối của *Phạm Thị Lan* có cảnh báo: chưa
   có khung trống nên nút "Chấp nhận" bị mờ
4. **Cần duyệt → Từ kỹ thuật viên** → cuộn xuống hai khối **Sự cố tại ca** và
   **Phân xử giờ**. Đọc nhãn nút: *"Tính công KTV · thu 50% phí khách"* — không
   phải "Duyệt / Từ chối" chung chung
5. **Dịch vụ & bảng giá → Lương khoán KTV** → bốn tiêu chí quyết định lương; bấm
   `+` ở *Bậc 2* sẽ thấy nền tảng chặn cứng ở 45%
6. **Doanh thu → Kết quả theo dịch vụ** → tổng thu từng gói trừ dần tới phần
   trung tâm giữ lại
7. **Cấu hình → Vai trò & quyền** → ma trận 13 đầu việc × 5 vai trò, bấm từng ô

> **Chỗ đáng dừng lâu nhất:** *Dịch vụ & bảng giá → Định mức vật tư*. Dịch vụ
> đang chạy ưu đãi 15% thì sau thuế, lương và vật tư trung tâm còn bao nhiêu —
> con số tự nói ra điều mà ít chủ cơ sở tính ngược lại.

---

## Giao diện Quản trị nền tảng

**Vào đâu:** `admin.html` · **14 trang / 5 nhóm**

**Đường đi đáng xem nhất:**

1. **Bảng điều hành** → bức tranh toàn nền tảng
2. **Cần xử lý → Duyệt hồ sơ** → *Thảo Mộc Wellness* đủ giấy tờ, bấm **Phê
   duyệt** thì số đỏ tụt xuống
3. **Trung tâm → Hồ sơ đăng ký** → hồ sơ *Hoà Mộc Center*. Khối giấy tờ có
   **Giấy phép hành nghề trị liệu** hiện lên **vì hồ sơ khai có Vật lý trị
   liệu** — khai không có nhóm đó thì mục ấy không xuất hiện. Thiếu giấy tờ bắt
   buộc nên nút Phê duyệt bị khoá
4. **Kỹ thuật viên → Hồ sơ đăng ký** → bậc do ANWELL chốt, không phải trung tâm
5. **Danh mục chuẩn → Sức khoẻ & chống chỉ định** → nguồn duy nhất của cảnh báo
   mà khách thấy lúc đặt và KTV đọc lại trước ca
6. **Gói nền tảng & tiện ích** → ba gói trung tâm, ba gói KTV, mỗi gói có nút
   *Điều chỉnh*
7. **Giám đốc Kinh doanh → Chính sách hoa hồng** → bấm *Trọn đời* để thấy cảnh
   báo về chi phí tích luỹ
8. **Cần xử lý → Khiếu nại leo thang** → việc trung tâm xử mà một bên không chịu

---

## Câu hỏi hay gặp

**Bấm nút mà không thấy gì xảy ra?**
Một số nút phụ (tạo mới, xuất file) chưa nối luồng vì bản demo tập trung vào các
luồng chính. Các nút quan trọng đều chạy thật.

**Số liệu có đúng không?**
Không. Toàn bộ là dữ liệu giả để minh hoạ giao diện.

**Xem trên điện thoại được không?**
Được. Giao diện Khách hàng và KTV thiết kế cho điện thoại. Hai giao diện quản trị
xem được nhưng máy tính dễ nhìn hơn.

**Gửi link cho người khác được không?**
Được, đây là trang công khai. Gửi thẳng địa chỉ ở trên.
