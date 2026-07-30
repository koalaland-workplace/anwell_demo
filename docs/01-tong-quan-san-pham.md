# Tổng quan sản phẩm ANWELL

> Tài liệu này mô tả **mô hình và chức năng** đã dựng trong bản demo.
> Mọi con số trong demo là **dữ liệu giả lập để minh hoạ**, không phải kết quả
> kinh doanh. Đừng trích số từ demo ra làm số liệu thật.

## 1. Vấn đề

Khi một người xuất viện sau đột quỵ hay sau mổ khớp, việc phục hồi mới bắt đầu —
và phần lớn gánh nặng rơi vào gia đình. Người nhà được giao tập vận động nhiều
lần mỗi ngày, kéo dài hàng tháng, mà không được đào tạo để làm những việc đó.

Cùng một mẫu vấn đề lặp lại ở người cao tuổi suy yếu dần và phụ nữ sau sinh: nhu
cầu có thật, liệu trình dài, nhưng không có ai theo sát.

Ở phía cung, kỹ thuật viên trị liệu giỏi thì phân tán — người làm công ăn lương
ở trung tâm, người nhận khách lẻ qua mạng xã hội. Không có nơi nào chuẩn hoá tay
nghề, theo dõi chất lượng và kết nối họ với người thật sự cần.

## 2. Bốn vai trò trong hệ sinh thái

```mermaid
flowchart LR
    KH["Khách hàng<br/>và gia đình"]
    TT["Trung tâm<br/>đối tác"]
    KTV["Kỹ thuật viên"]
    AW["ANWELL<br/>nền tảng"]

    KH -->|đặt lịch, đánh giá| TT
    KH -->|đặt trực tiếp| KTV
    TT -->|phân ca, chấm điểm| KTV
    KTV -->|đề xuất, xác nhận| TT
    AW -->|xác minh, xếp bậc| KTV
    AW -->|thẩm định, giám sát| TT
    TT -->|phí nền tảng| AW
```

| Vai trò | Làm gì |
|---|---|
| **Khách hàng** | Chọn cơ sở hoặc KTV tại nhà, theo dõi tiến triển, đánh giá, tích điểm |
| **Trung tâm** | Điều phối ca, quản lý KTV và khách, đối soát doanh thu, giữ chất lượng |
| **Kỹ thuật viên** | Nhận ca từ trung tâm, hoặc tự nhận khách riêng; ghi chép buổi làm việc |
| **ANWELL** | Thẩm định trung tâm, xác minh và xếp bậc KTV, đặt chính sách, giám sát chất lượng |

## 3. Mô hình hai lớp — điểm cốt lõi

Đây là điều làm ANWELL khác một sàn đặt lịch thông thường. Một kỹ thuật viên có
thể đồng thời có **hai quan hệ lao động**:

| | Làm tại trung tâm | Làm tự do |
|---|---|---|
| Đối tác | Trung tâm (ví dụ An Nhiên Wellness) | ANWELL |
| Ai giao việc | Trung tâm phân ca | KTV tự nhận yêu cầu |
| Ai đánh giá | Trung tâm chấm theo quy trình | Khách chấm sau mỗi buổi |
| Vai trò của KTV | Người làm công | Người tự kinh doanh |
| Dòng tiền | Lương theo ca | Doanh thu trừ phí nền tảng |
| Cơ chế kiểm soát | **Cửa phê duyệt** — đổi giờ, huỷ ca đều phải trung tâm duyệt | **Hậu quả thị trường** — huỷ ca ảnh hưởng thứ hạng hiển thị |

Nguyên tắc nền tảng, trích từ giao diện quản trị:

> *ANWELL trực tiếp quản lý KTV khi họ làm tự do. KTV đang làm tại trung tâm do
> trung tâm điều phối và chấm điểm.*

Mô hình này được ANWELL cho phép nhưng **có ràng buộc** — trung tâm giữ quan hệ
thương mại với khách của mình, KTV chỉ thấy nội dung chuyên môn cần để làm việc.

### Ràng buộc cụ thể: ba nhóm khách, ba mức quyền

Không phải hai nhóm mà ba, và chúng khác nhau ở **quyền** chứ không chỉ ở nhãn:

| | Khách tại trung tâm | Khách tại nhà · TT phân công | Khách riêng của KTV |
|---|---|---|---|
| Hồ sơ sức khoẻ | Xem trong ca | Xem trong ca | Xem đầy đủ |
| Số điện thoại | Che, gọi qua tổng đài | Che, gọi qua tổng đài | Hiện, gọi thẳng |
| Địa chỉ | Không cần | **Chỉ mở vào ngày có ca** | Xem đầy đủ |
| Nhắn tin | Qua trung tâm | Qua trung tâm | Trực tiếp |
| Đổi/huỷ lịch | TT duyệt | TT duyệt | KTV tự quyết |
| Giá | TT đặt | TT đặt | KTV đặt |
| Tiền về | Qua trung tâm | Qua trung tâm | Khách trả thẳng, nền tảng thu phí |
| **Khi KTV rời TT** | Mất quyền xem | Mất quyền xem | Giữ nguyên |

Số điện thoại hiển thị dạng `0903 ••• ••12` — đủ để KTV nhận ra đúng người khi
trung tâm nhắc, không đủ để gọi thẳng. Cuộc gọi đi qua tổng đài ANWELL che số.

Lý do: KTV **cần** thông tin chuyên môn để làm việc an toàn và đúng liệu trình —
giấu đi thì buổi trị liệu kém chất lượng. Nhưng thông tin thương mại và liên hệ
là tài sản của trung tâm.

Dòng cuối bảng được **nói thẳng trong app** ở màn Khách hàng, không để KTV tự
đoán: thôi liên kết là mất toàn bộ khách được giao, khách tự tìm thì giữ nguyên.
Nói trước để KTV tính đường dài, và để trung tâm yên tâm giao khách.

## 4. Bốn giao diện đã dựng

### 4.1 Khách hàng — 5 mục ở thanh đáy

| Mục | Nội dung |
|---|---|
| **Đặt lịch** | Mở app là vào thẳng đây. Hình thức · đặt cho ai · loại hình · phục hồi · phương pháp · khu vực · khung giờ · ưu đãi |
| **Lịch hẹn** | Lịch sắp tới, quản lý lịch (đổi/hoãn/huỷ), nhắn tin với KTV, nhắc buổi hẹn |
| **Khám phá** | Chỉ icon, ở giữa. Cơ sở, kỹ thuật viên, nội dung dưỡng sinh |
| **Tiến triển** | Lịch chăm sóc người thân nổi lên đầu nếu có, bài tập tại nhà, báo cáo, nhóm gia đình, nhắc bài tập |
| **Tôi** | Thanh tiến độ hồ sơ, hạng thành viên, hồ sơ sức khoẻ, ví & gói, phong cách giao diện |

Các màn phụ: buổi làm việc (ba giai đoạn) · đánh giá · giới thiệu bạn · chính
sách · chứng nhận KTV · thực đơn gợi ý · xác minh · làm quen sau đăng ký.

Mọi màn phụ đều có nút `<` trả về **màn trước đó**, không phải một tab cố định.

Ba phong cách hiển thị (An Nhiên · Rừng Thẫm · Nhịp Sen) để khách tự chọn, song
ngữ Việt/Anh.

**Hồ sơ sức khoẻ** là thứ đáng chú ý nhất: khách khai tình trạng một lần, hệ
thống tự cảnh báo dịch vụ cần tránh ngay lúc đặt lịch, và KTV đọc lại đúng cảnh
báo đó ở thẻ chuẩn bị trước ca.

### 4.2 Kỹ thuật viên — 5 mục, hai chế độ

Năm mục dùng chung tên ở cả hai chế độ, chỉ đổi nội dung theo đối tác:

| Mục | Tại trung tâm | Làm tự do |
|---|---|---|
| **Tổng quan** | Ca hôm nay do trung tâm phân, điểm kế tiếp nếu có ca ngoài cơ sở | Trạng thái nhận khách, yêu cầu mới |
| **Lịch làm** | Ba tab: Danh sách · Bản đồ · Khả dụng | Như bên trái |
| **Khách hàng** | Khách đang phụ trách, chỉ nội dung chuyên môn | CRM khách riêng đầy đủ |
| **Tài chính** | Lương từ trung tâm, kỳ đối soát | Doanh thu sau phí nền tảng, khách nợ |
| **Tôi** | Giống hệt nhau — hồ sơ là của một người | Như bên trái |

Điểm đáng chú ý ở tab **Khả dụng**, chế độ tại trung tâm — luồng điều phối hai
chiều có phê duyệt:

- Trung tâm phân công → KTV xác nhận
- KTV đề xuất → trung tâm xác nhận
- Đổi lịch, hoãn lịch → phải được duyệt, bắt buộc kèm lý do
- Ốm đau và bất khả kháng → **có hiệu lực ngay**, không chờ duyệt, nhưng có đếm
  số lần vì ảnh hưởng chỉ số tuân thủ quy trình

Mục **Tôi** giống nhau tuyệt đối ở hai chế độ, chứa cả hai nguồn đánh giá (trung
tâm chấm và khách chấm), hồ sơ, chứng chỉ, thông tin liên hệ, cấu hình hiển thị
và khai báo thuế cá nhân.

#### Màn Buổi làm việc — nơi KTV ở suốt ca

Ba giai đoạn, và phần lớn công cụ nằm ở đây chứ không rải ra menu:

| Giai đoạn | Có gì |
|---|---|
| **Chờ** | Thẻ chuẩn bị: điều cần tránh theo hồ sơ khách × dịch vụ của ca, buổi trước làm gì, gia đình dặn gì, ghi chú KTV ca trước để lại. Ai đang theo dõi buổi. **Ô nhập mã xác minh** — gõ đúng bốn số khách đọc mới check-in được |
| **Đang chạy** | Tick nội dung đã làm · đề xuất đổi/thêm dịch vụ · chia sẻ vị trí trực tiếp · ghi chú · **Báo sự cố** và **SOS** (hai nút tách hẳn nhau) |
| **Xong** | Trạng thái khách xác nhận giờ, đường xử lý khi khách báo sai lệch · giao bài tập về nhà · ghi lại cho KTV ca sau |

Ba chỗ tách bạc rõ ràng, và đây là chủ ý thiết kế chứ không phải ngẫu nhiên:

- **SOS ≠ Báo sự cố.** SOS là "tôi thấy không an toàn" — gọi ngay, không hỏi
  lại. Báo sự cố là "ca gặp trục trặc nhưng tôi vẫn ổn". Gộp chung thì KTV ngại
  bấm SOS vì sợ làm to chuyện, đúng lúc cần bấm nhất.
- **Chia sẻ vị trí ≠ SOS.** Bật từ đầu ca, chạy nền, điều phối viên thấy. SOS là
  lúc đã muộn; đây là phòng ngừa.
- **Ghi chú về khách ≠ chấm sao.** Khách không xem được, nên KTV dám ghi thật.
  Nhãn chỉ ghi việc đã xảy ra ("Hay đổi giờ phút chót", "Nhà có bậc thang hẹp"),
  không có "khó tính" hay "dễ chịu" — số sao thì vô nghĩa, lý do mới dùng được.
  Nó hiện lại ở thẻ chuẩn bị của người nhận ca sau, kèm tên và ngày.

Mọi màn phụ đều có nút `<` trả về màn trước đó, giống app khách.

### 4.3 Trung tâm — 11 trang

**Vận hành:** Tổng quan hôm nay · Điều phối lịch · Yêu cầu từ khách · Yêu cầu từ
KTV · Kỹ thuật viên
**Kinh doanh:** Khách hàng · Dịch vụ & bảng giá · Doanh thu & đối soát
**Chất lượng:** Đánh giá & chất lượng · Vật tư & thiết bị
**Hệ thống:** Cấu hình trung tâm

Hai trang xử lý yêu cầu là phía đối ứng của những gì khách và KTV gửi lên. Trang
Cấu hình có khai báo thuế doanh nghiệp và tuỳ chọn khấu trừ hộ KTV.

Trang **Yêu cầu từ KTV** gộp ba loại việc khác bản chất, huy hiệu ở menu đếm cả
ba nên trung tâm không tưởng nhầm là đã xong:

1. **Duyệt lịch** — đổi giờ, huỷ ca, xin thêm việc. Câu hỏi là cho hay không cho.
2. **Sự cố tại ca** — việc đã xảy ra rồi. Câu hỏi là *ai chịu phí*. Nên nhãn nút
   viết thẳng hệ quả tiền bạc: "Tính công KTV · thu 50% phí khách" thay vì
   "Duyệt". Nút chung chung khiến điều phối viên bấm mà không biết vừa quyết gì.
3. **Phân xử giờ** — khách khai một đằng, ứng dụng ghi một nẻo. Bản ghi định vị
   check-in/check-out đặt lên trước và ghi rõ *bên thứ ba · không ai sửa được*,
   nên đây không phải chuyện tin ai hơn ai. Có đường thứ ba là chia đôi.

### 4.4 Quản trị nền tảng — 8 trang

**Tổng quan:** Bảng điều hành
**Đối tượng:** Quản lý trung tâm · Phê duyệt hồ sơ · KTV tự do
**Khách hàng:** Loyalty ANP · Đối tác liên kết
**Nền tảng:** Chính sách & cấu hình · Dữ liệu & AI

Trang **Phê duyệt hồ sơ** có một quy tắc đáng chú ý: hồ sơ thiếu giấy tờ bắt
buộc thì **không phê duyệt thẳng được** — nút phê duyệt bị vô hiệu và hệ thống
chuyển hành động chính sang "Yêu cầu bổ sung". Duyệt một cơ sở trị liệu chưa có
PCCC hay chứng nhận vệ sinh là rủi ro pháp lý và an toàn cho khách.

## 5. Cơ chế doanh thu và thuế

- Trung tâm trả **phí nền tảng theo tỷ lệ chiết khấu** trên doanh thu, có hoá
  đơn GTGT
- KTV làm tự do chịu phí nền tảng trên ca tự do; ca do trung tâm phân thì nhận
  lương từ trung tâm
- KTV chọn một trong hai hình thức nộp thuế:
  - **Uỷ quyền khấu trừ tại nguồn** — trung tâm và ANWELL khấu trừ trước khi trả
  - **Tự kê khai theo diện hộ kinh doanh** — nhận đủ tiền, tự nộp
- Trung tâm khai phương pháp tính GTGT, kỳ kê khai, hoá đơn điện tử, và bật/tắt
  khấu trừ hộ cho KTV đã uỷ quyền

> Mức thuế, ngưỡng chịu thuế và kỳ kê khai thay đổi theo quy định từng thời kỳ.
> Phần này trong demo chỉ minh hoạ luồng khai báo; bản chạy thật cần kế toán rà
> soát.

## 6. Chương trình khách hàng — Hành trình An

Hạng thành viên theo điểm ANP, tích luỹ qua các buổi trị liệu. Nền tảng vận hành
song song hai lớp điểm: **hạng ANP toàn nền tảng** và **điểm riêng của từng
trung tâm** — trung tâm được giữ chương trình riêng nhưng trong khuôn khổ chính
sách chung.
