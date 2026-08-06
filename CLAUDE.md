<!-- TỆP NÀY ĐƯỢC SINH TỰ ĐỘNG — ĐỪNG SỬA TAY.
     Nguồn: docs/quy-tac-doi.md
     Sinh lại: python3 tools/sinh-lenh-doi.py -->

# ANWELL — Lệnh thường trực

Bạn đang làm việc trong kho mã ANWELL. Skill nghiệp vụ nạp tự động từ `.claude/skills/` — xem bảng ở mục 5 để biết việc nào cần skill nào.

---

# Quy tắc làm việc · ANWELL Developing Team

> **Đây là nguồn duy nhất.** `CLAUDE.md`, `AGENTS.md` và `GEMINI.md` ở gốc kho mã
> được **sinh ra** từ tệp này bằng `tools/sinh-lenh-doi.py`. Sửa ba tệp đó bằng
> tay là vô ích — lần sinh sau sẽ đè mất. Sửa ở đây.

Cập nhật 03/08/2026.

---

## 1 · Sản phẩm này là gì

ANWELL là nền tảng kết nối khách hàng cần phục hồi chức năng với trung tâm trị
liệu và kỹ thuật viên. Có ca tại cơ sở và **ca tại nhà** — nhóm sau là chỗ lỗi
phần mềm biến thành rủi ro cho người thật.

Năm vai người dùng: Khách hàng · Trung tâm · Kỹ thuật viên · Giám đốc Kinh doanh ·
Quản trị ANWELL.

**Tra tài liệu ở đâu:**

| Cần biết | Mở |
|---|---|
| Mô hình sản phẩm, ba nhóm khách, các màn hình | `docs/01-tong-quan-san-pham.md` |
| Quyết định đã chốt · việc còn treo · số liệu phải khớp | `docs/05-viec-dang-lam.md` |
| Chức năng thuộc Phase nào, mức nào | `Tailieu-noibo/ANWELL-15-phase-theo-muc-do.xlsx` |
| Ràng buộc nghiệp vụ chi tiết | `.claude/skills/anwell-*/SKILL.md` |

Không chắc thì tra, đừng đoán. Đoán sai ở dự án này tốn tiền thật của người thật.

---

## 2 · Bốn nguyên tắc không được đổi

**① Không có đặc tả thì không viết mã.** Đây là van duy nhất chặn việc làm quá
mức của Phase.

**② Người rà phải khác mô hình người viết.** Cùng một mô hình vừa viết vừa tự chấm
sẽ bỏ sót đúng chỗ nó không nhìn thấy.

**③ Bốn chỗ agent không được quyết cuối:** nội dung y khoa · tiền và thuế · tuân
thủ pháp lý · rà bảo mật cuối. Không có ngoại lệ vì tiến độ.

**④ ANWELL dựng cơ chế, không đặt chính sách.** Mọi tỷ lệ, ngưỡng, thời hạn là
**tham số có chủ sở hữu và ngày hiệu lực**, không phải hằng số trong mã.

---

## 3 · Tám vai và khi nào gọi

| Mã | Vai | Mô hình | Gọi bằng | Gọi khi |
|---|---|---|---|---|
| **T1** | AI Lead · Điều phối | Claude Opus | *phiên chính* | Nhận việc, phân mức rủi ro, chọn Owner, giao việc, gom kết quả |
| **T2** | Đặc tả sản phẩm | Claude Opus | `anwell-t2-dac-ta` | Trước mọi việc mức Trung bình trở lên chưa có đặc tả |
| **T3** | Kiến trúc & Dữ liệu | Claude Opus | `anwell-t3-kien-truc-du-lieu` | Đụng lược đồ, API dùng chung, ranh giới gói, migration |
| **T4** | UX & Design System | Claude Opus | `anwell-t4-ux-design-system` | Dựng token, thành phần dùng chung, luồng sử dụng, nhãn nút |
| **T5** | Backend & Tích hợp | Claude Sonnet | `anwell-t5-backend` | Viết API, quy tắc nghiệp vụ, tích hợp bên thứ ba |
| **T5₫** | Backend phần tiền | **Claude Opus** | `anwell-t5-backend-tien` | **Mọi việc chạm tiền.** Không hạ cấp mô hình ở đây |
| **T6** | Frontend | Claude Sonnet | `anwell-t6-frontend` | Dựng màn hình từ thư viện thành phần |
| **T7** | QA & Kiểm thử | **GPT-Codex** | `tools/kiem-thu-bang-codex.sh` | Sinh và chạy ba tầng kiểm thử |
| **T8** | Rà độc lập | **ngược người viết** | xem dưới | Bắt buộc ở mức Cao và Đặc biệt |

**T5 tách làm hai không phải thủ tục.** Quy tắc là không hạ cấp mô hình ở phần
tiền. Tách thành hai tệp vai biến quy tắc đó thành ràng buộc cấu hình, thay vì
trông chờ ai đó nhớ nâng cấp.

**T7 và T8 chạy bằng Codex nên không nằm trong `.claude/agents/`** — gọi bằng
script. Chỉ dẫn vai của T7 ở `docs/vai/t7-qa-kiem-thu.md`.

**T1 không phải tệp agent** — T1 là phiên hội thoại chính, vì chỉ phiên chính mới
giao việc được cho agent con.

**T8 có hai bản chạy — chọn theo người viết, không theo thói quen:**

| Mã do ai viết | Rà bằng |
|---|---|
| Claude (T2 · T3 · T4 · T5 · T5₫ · T6) — **phần lớn mã** | `tools/ra-bang-codex.sh` |
| Codex (T7 sinh kiểm thử · P15 di cư React Native) | agent `anwell-t8-ra-doc-lap` |

Chọn sai bản là mất nguyên tắc ② trong khi vẫn báo "đã rà".

**Sáu vai chuyên gia tạm thời**, chỉ bật khi Phase cần, không thường trực:
DevOps & Reliability · Database · Security Engineering · Mobile · Data & AI ·
Content Tooling.

---

## 4 · Phân mức rủi ro — quyết định quy trình

Xếp mức **trước khi bắt đầu**. Mức quyết định phải qua bao nhiêu bước.

| Mức | Ví dụ | Quy trình |
|---|---|---|
| **Thấp** | Sửa chữ · icon · khoảng cách · màu theo token · tài liệu | thực hiện → kiểm tra tự động → QA nhanh |
| **Trung bình** | Thêm màn hình · bộ lọc · form · báo cáo · đổi điều hướng | đặc tả → thực hiện → QA → rà mã |
| **Cao** | Đổi phân quyền · CSDL · API dùng chung · định vị · tải giấy tờ · cấu hình quản trị · webhook · tính toán tài chính | đặc tả → thiết kế kỹ thuật → thực hiện → QA đầy đủ → **rà độc lập** → staging |
| **Đặc biệt** | Thanh toán · ví · đối soát · bảng lương · xoá dữ liệu · đổi quyền quản trị cao nhất · migration lớn · hạ tầng production | như mức Cao, cộng threat modeling → kiểm thử chuyên biệt → kế hoạch hoàn tác → **người thật ký duyệt production** |

Hai lưu ý:

- **Nhãn nút trong luồng có hệ quả tiền bạc hoặc an toàn là mức Trung bình**, không
  phải Thấp. Nhãn sai thì người dùng quyết định sai.
- **Mức Đặc biệt: người ký duyệt production là người thật, không phải agent.**
  Bảng lương và thuế bắt buộc kế toán rà. Nội dung y khoa bắt buộc bác sĩ ký.

### Quy tắc mô hình theo mức

| Mức | Ràng buộc người rà |
|---|---|
| Thấp | Không cần rà độc lập |
| Trung bình | **Ưu tiên** khác mô hình |
| Cao · Đặc biệt | **Bắt buộc** khác mô hình người viết |

---

## 5 · Nạp skill theo thứ mã đang chạm

Ràng buộc nghiệp vụ ANWELL nằm ở skill, không nằm trong tệp này. Nạp **trước khi
viết dòng đầu tiên**.

| Việc chạm tới | Skill |
|---|---|
| Tệp mới, gói mới, đổi ranh giới gói | `anwell-kien-truc` |
| Bất kỳ con số nghiệp vụ nào — tỷ lệ, ngưỡng, thời hạn, mức phí, số buổi | `anwell-tham-so-chinh-sach` |
| Danh mục — dịch vụ, chứng chỉ, bậc, thiết bị, sức khoẻ, địa giới | `anwell-danh-muc-chuan` |
| Tiền — thanh toán, ví, gói, lương, thuế, đối soát, hoàn tiền, phí | `anwell-quy-tac-tien` |
| Nhật ký thao tác, check-in/out định vị, biến động ví | `anwell-du-lieu-bat-bien` |
| CCCD, hồ sơ sức khoẻ, giấy tờ, số điện thoại, địa chỉ | `anwell-du-lieu-ca-nhan` |
| Trả dữ liệu khách cho KTV, màn KTV hiện thông tin khách | `anwell-ba-nhom-khach` |
| Ca tại nhà — mã xác minh, check-in, định vị, SOS, chia sẻ vị trí, che số | `anwell-an-toan-ca-tai-nha` |
| Hồ sơ sức khoẻ, cảnh báo chống chỉ định, thẻ chuẩn bị, bậc năng lực | `anwell-suc-khoe-chong-chi-dinh` |
| Chữ người dùng đọc — nhãn nút, thông báo lỗi, email, tin nhắn | `anwell-viet-tieng-viet` |
| Dựng video đào tạo, bài tập, hướng dẫn dùng phần mềm | `anwell-video-dao-tao` |
| Cần biết quyết định đã chốt chưa, chức năng thuộc Phase nào | `anwell-tra-cuu-tai-lieu` |
| **Mọi việc** | `anwell-muc-do-phase` |

Không chắc chạm gì thì nạp thừa còn hơn nạp thiếu.

> **Dành cho công cụ không có cơ chế skill tự động** (Codex, Gemini): skill là tệp
> văn bản thường ở `.claude/skills/<tên>/SKILL.md`. Đọc thẳng tệp đó.

---

## 6 · Mười bước xử lý một đầu việc

1. **Tiếp nhận** — T1 ghi: yêu cầu · mục tiêu · mức ưu tiên · người quyết định · cổng liên quan
2. **Tra cứu** — T2 xác định: mã chức năng · Phase · mức độ · quyết định đã có · phần đã cắt
3. **Đặc tả** — T2 viết tiêu chí nghiệm thu và phần **cố ý chưa làm**. Thiếu quyết định làm đổi bản chất sản phẩm thì **dừng và hỏi chủ dự án**
4. **Thiết kế kỹ thuật** — T3 xác định module · API · dữ liệu · quyền · migration · tác động
5. **Thực thi** — T5 · T6 hoặc chuyên gia. Mã đi kèm kiểm thử tương ứng
6. **Kiểm thử** — T7 chạy ba tầng, cộng đối chiếu xuyên cổng
7. **Rà độc lập** — T8, bắt buộc ở mức Cao và Đặc biệt
8. **Triển khai staging** — QA kiểm trên bản dựng thật, không chỉ trên máy phát triển
9. **Duyệt production** — cần một hành động phê duyệt rõ ràng. **Không tự động lên production chỉ vì test xanh**
10. **Đóng đầu việc** — chỉ khi đủ tiêu chuẩn ở mục 8

Mỗi đầu việc có **một Owner** chịu trách nhiệm xuyên suốt mười bước. Nhiều vai
phối hợp được, nhưng chỉ một người chịu trách nhiệm.

---

## 7 · Quy tắc mã nguồn bắt buộc

1. Không ghi cứng danh mục dùng chung
2. Không ghi cứng tỷ lệ, ngưỡng hoặc thời hạn nghiệp vụ
3. Không đặt logic nghiệp vụ trong thành phần giao diện
4. Không coi ẩn nút là phân quyền — quyền phải kiểm ở máy chủ
5. Không dùng số thực cho tiền. Tiền là số nguyên, đơn vị đồng
6. Không tạo giao dịch nếu thiếu khoá chống trùng sinh từ nghiệp vụ
7. Webhook là nguồn sự thật cho giao dịch, không phải trang trả về
8. Không cập nhật hoặc xoá trên bảng thuộc nhóm chỉ ghi thêm
9. Không sửa trực tiếp tệp được sinh tự động
10. Không triển khai production nếu chưa có kiểm thử và phương án hoàn tác
11. Không đưa dữ liệu thật vào staging
12. Không commit bí mật. Không ghi log mật khẩu, OTP, token hay dữ liệu nhạy cảm
12b. **Không gửi bí mật hay dữ liệu cá nhân thật ra dịch vụ AI bên ngoài.** Commit
    nhầm thì còn gỡ được khỏi lịch sử; gửi đi rồi thì không thu hồi được. Hai
    script gọi Codex quét trước khi gửi và dừng khi thấy dấu hiệu — đừng vô hiệu
    hoá cổng đó cho tiện
13. Không gọi dịch vụ bên thứ ba nếu thiếu timeout
14. Không thử lại mù với thao tác tạo giao dịch
15. Không đóng đầu việc khi tài liệu và mã còn lệch nhau
16. Không để nút chết trong luồng nghiệp vụ chính
17. **Không lấy số liệu trong bản demo làm nguồn sự thật** — đó là số mồi minh hoạ
18. Không tạo gói mới nếu gói hiện có đã đúng trách nhiệm
19. Không tối ưu sớm khi chưa có số đo
20. Không đưa AI vào bài toán chưa có mục tiêu và tiêu chí đánh giá

---

## 8 · Khi nào được coi là "xong"

Đủ **tất cả**, thiếu một là chưa xong:

- Có mã chức năng · có đặc tả · đúng phạm vi Phase · có Owner
- Có thiết kế kỹ thuật nếu mức Cao trở lên
- Mã chạy đúng · có kiểm thử đơn vị cho quy tắc nghiệp vụ
- Có kiểm thử API hoặc tích hợp nếu liên quan máy chủ
- Có kiểm thử đầu–cuối nếu là luồng người dùng quan trọng
- Đã kiểm phân quyền · đã kiểm trạng thái lỗi
- **Đã mở trình duyệt xem thật** trên màn hình mục tiêu
- Không làm sai các cổng liên quan · tài liệu đã cập nhật
- Đã triển khai staging thành công · không còn lỗi chặn
- Có phương án hoàn tác nếu đổi production

> **Công cụ kiểm cấu trúc báo đạt KHÔNG có nghĩa là trang hiện được.**
> `tools/verify.py` không chạy JavaScript. Bản demo đã ba lần trắng hoàn toàn mà
> công cụ vẫn báo đạt.

---

## 9 · Cấm

- Sửa `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` bằng tay — chúng được sinh ra từ tệp này
- Gỡ dòng `Tailieu-noibo/` khỏi `.gitignore`
- Đưa lên kho mã công khai: hồ sơ mời đầu tư · định giá · dự toán · nhận diện
  người sáng lập · phân tích đối thủ · đánh giá rủi ro nội bộ · dữ liệu cá nhân thật
- Quyết thay chủ dự án các con số chính sách — dựng cơ chế, để người có quyền quyết

---

## 10 · Công cụ ngoài — dùng gì và không dùng gì

**superpowers** đang chạy sẵn dưới dạng plugin ở mức người dùng. **Không chép vào
`.claude/skills/`** — chép là tạo bản thứ hai lệch dần với bản chính thức.

Ranh giới: superpowers dùng cho **kỹ thuật** — cách gỡ lỗi, cách viết kiểm thử,
cách dùng git worktree. Không dùng cho **quy trình** — ai làm gì, qua cổng nào,
khi nào coi là xong. Chỗ nào chồng nhau thì **tệp này thắng**.

**codegraph** — hoãn. Bật khi chạm một trong ba điều kiện, không bật theo lịch:

1. Kho mã sản phẩm vượt ~20.000 dòng thật
2. Nhật ký chi phí cho thấy agent tốn nhiều lượt chỉ để tìm chỗ sửa
3. Có vai than "không biết quy tắc này đã có ở gói nào"

Lưu ý: codegraph phục vụ qua MCP nên chỉ giúp các vai Claude. **T7 và T8 chạy
bằng Codex không được lợi gì** — mà đó lại là hai vai tốn token nhất.

**n8n và OpenClaw** — chưa dùng cho đội phát triển. n8n có thể hợp với đội vận
hành sau này, nhưng không được dùng để chạy chức năng sản phẩm mà khách phụ
thuộc. Lý do chung: đội đã có bộ điều phối rồi, thêm cái thứ hai là luồng việc
định nghĩa hai chỗ.

---

## 11 · Viết tiếng Việt

Mọi chữ người dùng đọc và mọi tài liệu đều viết tiếng Việt. Câu ngắn. Giải thích
hệ quả trước khi người dùng bấm. Nhãn nút viết thẳng việc sẽ xảy ra — *"Tính công
KTV · thu 50% phí khách"* thay vì *"Duyệt"*.

Chi tiết ở `anwell-viet-tieng-viet`.

