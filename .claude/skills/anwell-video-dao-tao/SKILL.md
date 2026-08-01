---
name: anwell-video-dao-tao
description: Dùng khi dựng bất kỳ video nào cho ANWELL — đào tạo kỹ thuật viên, bài tập tại nhà, hướng dẫn dùng phần mềm, hoặc nội dung mạng xã hội. Nêu quy cách video, ba ràng buộc nội dung, và vì sao dựng bằng HTML thay vì quay.
---

# Video đào tạo và nội dung

Video đào tạo gắn với việc **nâng bậc kỹ thuật viên**, nên nó là **tài liệu
chuyên môn**, không phải nội dung tiếp thị.

**Vì sao có skill này:** Video hướng dẫn dùng phần mềm quay bằng máy quay thì
giao diện đổi là phải quay lại toàn bộ. Với 32 tuần và 15 Phase liên tục đổi
giao diện, đó là cách chắc chắn để bỏ dở. Dựng bằng HTML thì đổi token rồi
dựng lại hàng loạt.

## Khi nào dùng

- Dựng video đào tạo KTV theo ba bậc chứng nhận
- Dựng video bài tập tại nhà cho khách
- Dựng video hướng dẫn dùng phần mềm cho trung tâm và KTV
- Làm nội dung ngắn cho mạng xã hội

## Công cụ

| Việc | Dùng | Ở đâu |
|---|---|---|
| Dựng video từ HTML | **hyperframes** (19 skill sẵn) | `ANWELL-DEV-REPO/media/hyperframes` |
| Giọng đọc tiếng Việt | **OmniVoice-Studio** | `ANWELL-DEV-REPO/media/omnivoice` |
| Cắt ghép video quay thật | OpenMontage | `ANWELL-DEV-REPO/media/openmontage` |
| Sinh ảnh minh hoạ | Open-Generative-AI | `ANWELL-DEV-REPO/media/opengen` |
| Kiểm chất lượng video đã dựng | Claude-Video | `ANWELL-DEV-REPO/media/claude-video` |

OmniVoice là bộ giọng **duy nhất** trong 53 repo đã rà đọc được tiếng Việt.
Nó chưa có công cụ MCP — cần một lớp bọc để agent gọi thẳng.

## Quy cách

- **Phụ đề bắt buộc.** Nhiều người xem ở nơi công cộng hoặc trên xe.
- **Độ dài:** bài tập 60–90 giây · hướng dẫn phần mềm 2–3 phút · bài giảng đào
  tạo 5–8 phút chia chương.
- **Nhận diện:** dùng token thiết kế ANWELL, không tự chọn màu.
- **Giọng đọc:** một giọng thống nhất cho cả bộ đào tạo. Đổi giọng giữa chừng
  làm người học mất tập trung.

## Ba ràng buộc nội dung

1. **Video dạy động tác trị liệu phải qua bác sĩ duyệt** — như mọi nội dung y
   khoa. Xem `anwell-suc-khoe-chong-chi-dinh`. Agent dựng nháp, bác sĩ ký duyệt.

2. **Không hứa hiệu quả điều trị.** Ràng buộc pháp lý với ngành sức khoẻ, áp
   cho cả nội dung mạng xã hội.

3. **Ghi rõ nguồn nếu dùng tư liệu bên ngoài.** Bản demo đang dùng video và
   nhạc từ archive.org, Wikimedia và kho ảnh miễn phí chưa rà bản quyền —
   **phải thay hết** trước khi phát hành.

## Dựng lại hàng loạt khi giao diện đổi

Video hướng dẫn phần mềm nên tách thành hai phần:
- **Kịch bản** (`script-tokens.json`) — lời thoại và mốc thời gian
- **Cảnh** (HTML) — ảnh chụp màn hình sinh từ chính ứng dụng

Giao diện đổi thì chạy lại bộ dựng, không phải quay lại. Ghi rõ trong mỗi dự án
video: phiên bản ứng dụng nào đã dùng để dựng.

## Dấu hiệu đang làm sai

| Nếu anh thấy | Nghĩa là | Sửa thế nào |
|---|---|---|
| Video hướng dẫn quay bằng máy quay màn hình | Giao diện đổi là phải quay lại | Dựng bằng hyperframes |
| Video dạy động tác chưa có bác sĩ duyệt | Rủi ro hại người thật | Dừng, chờ duyệt |
| Không có phụ đề | Loại bỏ người xem nơi công cộng | Thêm phụ đề |
| Dùng nhạc hoặc video từ nguồn chưa rà | Rủi ro bản quyền | Thay bằng nguồn tự sản xuất |
| Mỗi video một giọng đọc khác | Người học mất tập trung | Thống nhất một giọng |

## Không áp dụng khi

- Ảnh tĩnh và biểu đồ trong tài liệu
- Video nội bộ không phát hành cho người dùng
