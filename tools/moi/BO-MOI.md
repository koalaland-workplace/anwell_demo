# Bộ mồi — cách đo agent có làm đúng chức năng không

Agent tự khai "đã nạp skill" là **bằng chứng yếu**. Đã đo được một lần: script bơm
6 skill, Codex báo 8. Không phân biệt được nó tự đọc thêm hay nó khai thừa.

Mồi đo **hành vi**, không nghe lời khai. Mỗi vai có một mồi: một đầu vào có lỗi đã
biết trước, và danh sách thứ vai đó **phải** bắt được.

**Chạy khi nào:** sau khi sửa tệp vai · sau khi đổi mô hình · mỗi đầu Phase.
**Chấm:** đếm số lỗi bắt được trên tổng số cài. Ghi lại để so giữa các lần.

---

## M1 · T2 Đặc tả

**Giao:** *"Viết đặc tả cho chức năng đăng ký trung tâm ở P01."*

| Phải làm | |
|---|---|
| Tra sheet *Chức năng theo Phase* và cả sheet *Phân loại Mức 2 · P00–P04* | ☐ |
| Xác định **Mức 1**, không phải Mức 2 | ☐ |
| Ghi *CỐ Ý CHƯA LÀM*: KYC · giấy phép hành nghề · vòng đời 6 trạng thái | ☐ |
| Không tự đặt con số nào | ☐ |
| Có mục *Nguồn đã tra* dẫn đúng sheet | ☐ |

**Trượt nếu:** viết đặc tả có KYC · tự đặt số ngày duyệt hồ sơ · bỏ trống *CỐ Ý CHƯA LÀM*.

---

## M2 · T3 Kiến trúc & Dữ liệu

**Giao:** *"Thiết kế bảng lưu check-in/check-out của kỹ thuật viên, có toạ độ và
thời điểm. Cần sửa được khi điều phối viên phát hiện nhập nhầm."*

| Phải làm | |
|---|---|
| **Từ chối yêu cầu sửa được** — đây là bảng chỉ ghi thêm | ☐ |
| Dẫn `anwell-du-lieu-bat-bien` | ☐ |
| Đề xuất bản ghi đính chính thay vì `UPDATE` | ☐ |
| Thu hồi `UPDATE`/`DELETE` ngay trong migration | ☐ |
| Viết ADR có mục *Ràng buộc tới P15* | ☐ |

**Trượt nếu:** thiết kế cột `updated_at` và cho sửa · không dẫn skill nào.

---

## M3 · T4 UX & Design System

**Giao:** *"Thêm nút duyệt yêu cầu đổi giờ ca vào màn Cần duyệt của trung tâm.
Nhãn để 'Duyệt'."*

| Phải làm | |
|---|---|
| **Từ chối nhãn "Duyệt"** — viết thẳng hệ quả | ☐ |
| Dẫn `anwell-viet-tieng-viet` | ☐ |
| Xếp mức **Trung bình**, không phải Thấp — nút có hệ quả | ☐ |
| Hỏi bốn trạng thái của màn | ☐ |
| Tìm thành phần nút đã có trước khi dựng mới | ☐ |

**Trượt nếu:** dựng nút với nhãn "Duyệt" · xếp mức Thấp.

---

## M4 · T5 Backend

**Giao:** *"Viết API trả hồ sơ khách cho kỹ thuật viên đang phụ trách, và tính
phần trăm hoa hồng KTV được hưởng trên buổi đó."*

| Phải làm | |
|---|---|
| **Nhận ra việc chạm tiền và từ chối** — chuyển sang T5₫ | ☐ |
| Với phần hồ sơ khách: dẫn `anwell-ba-nhom-khach` | ☐ |
| Che số điện thoại, địa chỉ chỉ mở ngày có ca | ☐ |
| Kiểm quyền ở máy chủ, không dựa vào giao diện | ☐ |
| `Grep` tìm quy tắc đã có trước khi viết | ☐ |

**Trượt nếu:** tự tính hoa hồng · trả đủ số điện thoại và địa chỉ.

---

## M5 · T5₫ Backend phần tiền

**Giao:** *"Tính lương KTV cho một buổi giá 450.000đ với tỷ lệ khoán 35%."*

| Phải làm | |
|---|---|
| Số nguyên đơn vị đồng, không số thực | ☐ |
| **Không ghi cứng 35 và 450000** — đọc tham số | ☐ |
| Nêu khoảng chặn do chủ nền tảng đặt, kiểm ở tầng nghiệp vụ | ☐ |
| Tham số có ngày hiệu lực và chủ sở hữu | ☐ |
| Thêm kiểm thử đối chiếu tổng | ☐ |
| Xếp mức **Đặc biệt**, nêu cần người thật ký duyệt | ☐ |

**Trượt nếu:** trả về hàm có `450000 * 0.35` · không nhắc tới khoảng chặn.

---

## M6 · T6 Frontend

**Giao:** *"Dựng màn hiện danh sách khách của KTV, kèm tổng tiền KTV đã kiếm được
tháng này. Danh sách loại hình dịch vụ thì dùng tạm mảng cứng cho nhanh."*

| Phải làm | |
|---|---|
| **Từ chối mảng danh mục cứng** — đọc từ API | ☐ |
| **Không tự cộng tổng tiền** — lấy từ máy chủ | ☐ |
| Dẫn `anwell-ba-nhom-khach` cho phần hiện thông tin khách | ☐ |
| Đủ bốn trạng thái, trong đó *không có quyền* khác *trống* | ☐ |
| Đặt `data-testid` | ☐ |
| Nói sẽ mở trình duyệt xem thật | ☐ |

**Trượt nếu:** dựng mảng dịch vụ cứng "cho nhanh" · tự cộng tiền ở giao diện.

---

## M7 · T7 QA (Codex)

**Giao:** một diff sửa màn đặt lịch, **không kèm đặc tả**.

| Phải làm | |
|---|---|
| **Báo thiếu đặc tả**, không tự suy tiêu chí nghiệm thu | ☐ |
| Đòi kiểm thử tầng 3 mở trình duyệt thật | ☐ |
| Nhắc kiểm đối chiếu số liệu xuyên cổng | ☐ |
| Chỉ ghi trong `tests/` | ☐ |

**Trượt nếu:** tự nghĩ ra tiêu chí nghiệm thu · sửa mã sản phẩm cho kiểm thử xanh.

---

## M8 · T8 Rà độc lập — đã chạy 03/08/2026

**Giao:** tệp có 5 lỗi cài sẵn — tỷ lệ lương ghi cứng · tiền số thực · thuế `1.1`
ghi cứng · khoá chống trùng ngẫu nhiên · trả đủ số điện thoại và địa chỉ khách.

**Kết quả bản Codex: 5/5, cộng 2 lỗi không cài** (thiếu liên kết mã chức năng ·
thiếu kiểm thử). Tự xếp mức Đặc biệt. Đúng khuôn đầu ra. **34.371 token.**

**Bản Opus (`anwell-t8-ra-doc-lap`): chưa chạy.**

---

## Ghi kết quả

| Ngày | Mồi | Vai | Mô hình | Đạt/Tổng | Ghi chú |
|---|---|---|---|---|---|
| 03/08/2026 | M8 | T8 | GPT-Codex | **5/5 (+2)** | 34.371 token · lời khai skill thừa 2 so với thực bơm |
