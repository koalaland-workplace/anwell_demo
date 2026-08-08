# Audit AI Developing Team ANWELL

**Ngày rà:** 07/08/2026  
**Phạm vi:** Chỉ rà hệ thống AI Developing Team trong kho `ANWELL-demo`  
**Kết luận:** **CHẤP NHẬN CÓ ĐIỀU KIỆN**

---

## 1. Kết luận điều hành

TEAM AI DEV hiện tại tiến bộ rõ rệt so với bản ngày 05/08/2026.

Những lỗi lớn của bản trước đã được xử lý thật trong mã:

- Bắt được tệp chưa `git add`.
- Nhận diện thay đổi chỉ xoá.
- Nhận diện shell, migration, Dockerfile, workflow và cấu hình hạ tầng.
- Cố định mô hình Codex và mức suy luận.
- Quét bí mật trước khi gửi diff.
- Xoá lời nhắc tạm sau khi chạy.
- Phát hiện T7 sửa tệp ngoài `tests/`.
- Không ghi nhật ký chi phí vào Git.
- Đọc token thực tế thay vì ước lượng từ số ký tự.
- Lưu kết quả để tránh gọi mô hình lặp lại trên cùng nội dung.

Đánh giá hiện tại:

| Thành phần | Đánh giá |
|---|---|
| Thiết kế tổ chức | Tốt |
| Ranh giới trách nhiệm | Tốt |
| Tách người viết và người rà | Khá tốt |
| Kiểm soát chi phí | Tốt hơn rõ rệt |
| An toàn khi gửi mã ra AI | Có nền nhưng chưa kín |
| Cưỡng chế quy trình | Trung bình |
| Kiểm thử chính bộ TEAM | Chưa đủ |
| Sẵn sàng dùng cho P00 | Có điều kiện |
| Sẵn sàng làm cổng production | Chưa |

Ước tính:

- Phần thiết kế: **88–90%**.
- Phần cưỡng chế vận hành: **65–70%**.

---

## 2. Những phần đã làm tốt

### 2.1 Giảm đúng từ 26 vai xuống 8 vai chức năng

Cấu trúc hiện tại hợp lý:

- T1 điều phối.
- T2 đặc tả.
- T3 kiến trúc và dữ liệu.
- T4 UX và hệ thống thiết kế.
- T5 backend.
- T5-Tiền là chế độ đặc biệt của T5.
- T6 frontend.
- T7 kiểm thử.
- T8 rà độc lập.

Cách gọi phù hợp là:

> Tám vai chức năng, chín dòng vận hành vì T5 có hai chế độ thực thi.

Không cần thêm agent ở thời điểm này.

### 2.2 Một nguồn quy tắc duy nhất

`docs/quy-tac-doi.md` là nguồn sinh ra:

- `AGENTS.md`.
- `CLAUDE.md`.
- `GEMINI.md`.

Đây là quyết định đúng. Nó tránh ba công cụ hiểu ba quy trình khác nhau.

### 2.3 T5 thường và T5-Tiền có ranh giới rõ

T5 thường được yêu cầu dừng khi gặp:

- thanh toán;
- ví;
- gói;
- lương;
- thuế;
- đối soát;
- hoàn tiền;
- phí nền tảng.

Đây là một trong những ranh giới tốt nhất của TEAM.

### 2.4 T8 Codex được khoá chỉ đọc

`tools/ra-bang-codex.sh` chạy Codex với sandbox `read-only`.

Mô hình và mức suy luận cũng được truyền rõ, không còn phụ thuộc hoàn toàn vào
cấu hình máy.

### 2.5 Đã xử lý tệp chưa theo dõi và thay đổi chỉ xoá

`tools/_nap-skill.sh` đã:

- đọc danh sách tệp chưa theo dõi;
- dựng diff cho tệp mới;
- phân loại phạm vi theo danh sách tệp;
- quét cả dòng thêm và dòng xoá để chọn skill.

Đây là sửa chữa đúng và quan trọng.

### 2.6 Nhận diện mã đã rộng hơn

Bộ nhận diện hiện bao gồm:

- shell;
- Prisma, GraphQL và Proto;
- Terraform;
- Dockerfile và Makefile;
- migration;
- workflow CI;
- vai và skill trong `.claude/`.

### 2.7 T7 có cơ chế phát hiện ghi sai phạm vi

`tools/kiem-thu-bang-codex.sh` chụp hash trước và sau đối với các tệp ngoài
`tests/`.

Nếu T7 sửa mã sản phẩm, script chuyển kết quả thành lỗi. Đây chưa phải sandbox
thư mục tuyệt đối, nhưng là một lớp bảo vệ có giá trị.

### 2.8 Đã có cổng quét bí mật

`tools/quet-bi-mat.py` nhận diện nhiều loại dữ liệu nhạy cảm:

- khoá OpenAI, Anthropic, AWS, GitHub, Slack và Google;
- JWT;
- private key;
- URL có mật khẩu;
- biến có tên secret, password hoặc token;
- CCCD/CMND;
- `.env`, key, certificate và credential.

### 2.9 Đo chi phí thực tế hơn

`tools/doc-token.py` đọc token từ phiên Codex thay vì lấy `số ký tự / 3`.

Nhật ký chi phí đã được đưa vào `.gitignore`, nên reviewer không tự làm bẩn cây
làm việc.

### 2.10 Chưa dùng codegraph, n8n và OpenClaw là quyết định đúng

Với quy mô hiện tại, TEAM đã đủ phức tạp. Thêm một lớp điều phối mới dễ tăng
điểm hỏng hơn tăng năng suất.

---

## 3. Những vấn đề bắt buộc nên sửa

### 3.1 Nguồn điều khiển TEAM bị phân loại là tài liệu mức Thấp

`tools/_nap-skill.sh` đang coi toàn bộ `docs/` là tài liệu thuần.

Nhưng hai tệp sau điều khiển trực tiếp hành vi TEAM:

- `docs/quy-tac-doi.md`.
- `docs/vai/t7-qa-kiem-thu.md`.

Nếu ai đó sửa quy trình T1–T8 hoặc nới quyền T7 trong các tệp này, T7/T8 có thể
bỏ qua vì cho rằng không có mã.

#### Đề xuất

Tạo nhóm **control code** gồm:

```text
docs/quy-tac-doi.md
docs/vai/**
.claude/agents/**
.claude/skills/**
tools/*codex*
tools/_nap-skill.sh
tools/quet-bi-mat.py
tools/tra-san.py
tools/doc-token.py
tools/sinh-lenh-doi.py
```

Thay đổi trong nhóm này phải được coi tối thiểu là mức Trung bình.

### 3.2 Secret scan chỉ quét dòng thêm nhưng toàn bộ diff được gửi

`tools/quet-bi-mat.py` mới soi dòng bắt đầu bằng `+`.

Trong khi đó, lời nhắc gửi cho Codex chứa:

- dòng thêm;
- dòng xoá;
- dòng ngữ cảnh.

Một bí mật đang được xoá vẫn có thể nằm trong dòng `-...` và bị gửi ra ngoài.
Dòng ngữ cảnh cũng có thể chứa dữ liệu nhạy cảm đã tồn tại từ trước.

#### Đề xuất

Quét đúng toàn bộ payload sẽ gửi. Có thể bỏ metadata của Git, nhưng phải soi nội
dung dòng thêm, dòng xoá và dòng ngữ cảnh.

### 3.3 Cache không hết hạn khi vai, skill hoặc đặc tả thay đổi

Khoá cache hiện dựa chủ yếu vào:

- diff;
- tên vai;
- mô hình;
- mức suy luận;
- danh sách tên skill.

Chưa thấy nội dung sau tham gia vào khoá:

- nội dung tệp vai;
- nội dung skill;
- nội dung đặc tả;
- phiên bản script;
- quy tắc nguồn của TEAM.

Hậu quả: cùng một diff có thể nhận lại kết quả cũ dù tiêu chí nghiệm thu hoặc
quy tắc đã đổi.

#### Đề xuất

Khoá cache nên gồm:

```text
diff mã
+ nội dung vai
+ nội dung các skill đã nạp
+ nội dung đặc tả
+ phiên bản _nap-skill.sh
+ phiên bản script T7/T8
```

Riêng T7, trước khi dùng cache phải xác minh các tệp kiểm thử lần trước vẫn còn
và chưa thay đổi.

### 3.4 Mức rủi ro đang được suy từ từ khoá

Quy trình nói T1 phải phân mức trước khi bắt đầu. Nhưng script lại suy mức từ
skill được chọn.

Một thay đổi xoá kiểm tra quyền có thể không chứa từ khoá đủ rõ và bị chạy với
mức suy luận thấp.

#### Đề xuất

Thêm tham số:

```bash
--muc thap|trung-binh|cao|dac-biet
--nguoi-viet claude|codex|human|gemini
```

Mức do T1 khai là nguồn chính. Heuristic chỉ được nâng mức hoặc cảnh báo, không
được tự hạ mức.

### 3.5 Lời nhắc luôn tuyên bố mã do Claude viết

T7 và T8 Codex đều mặc định nói mã do Claude viết. Điều này không phải lúc nào
cũng đúng.

Nếu mã do Codex viết mà vẫn được Codex rà, nguyên tắc người rà khác mô hình đã
mất.

#### Đề xuất

Bắt buộc khai tác giả hoặc mô hình viết mã. Nếu không xác định được ở mức Cao
hoặc Đặc biệt, phải dừng hoặc ghi rõ chưa chứng minh được tính độc lập.

### 3.6 T7 chỉ phát hiện vi phạm sau khi tệp đã bị sửa

Hash trước và sau giúp phát hiện, nhưng không ngăn T7 ghi ra ngoài `tests/`.

Nếu đồng thời có thay đổi hợp lệ của người dùng, việc hoàn nguyên có thể làm mất
dữ liệu.

#### Đề xuất

Ưu tiên chạy T7 trong:

1. worktree tạm;
2. bản sao tạm chỉ nhận output kiểm thử;
3. môi trường chỉ mount `tests/` với quyền ghi.

Nếu vẫn chạy trực tiếp trong workspace, chỉ báo patch vi phạm. Không tự hoàn
nguyên và không hướng dẫn lệnh có thể ghi đè thay đổi hợp lệ.

### 3.7 Snapshot của T7 không nhìn thấy tệp bị Git bỏ qua

Cơ chế chụp cây dùng danh sách Git và loại tệp ignored. T7 có thể tạo hoặc sửa
một tệp ignored ngoài `tests/` mà snapshot không phát hiện.

Ví dụ:

- `.env`;
- log;
- output chứa dữ liệu;
- credential tạm;
- cấu hình máy cá nhân.

#### Đề xuất

Snapshot tệp thực tế trong workspace và chỉ loại trừ danh sách an toàn rõ ràng,
hoặc chạy T7 trong môi trường chỉ cho phép ghi `tests/`.

---

## 4. Những điểm nên cải thiện

### 4.1 Bộ mồi mới có bằng chứng của T8 Codex

Theo `tools/moi/BO-MOI.md`:

- M1–M7 chưa có kết quả được ghi.
- M8 Codex đã đạt 5/5.
- T8 Opus chưa chạy.

TEAM mới có bằng chứng hành vi của một đường rà, chưa có bằng chứng cho cả đội.

#### Thứ tự nên chạy

1. M2 — dữ liệu bất biến.
2. M4 — T5 biết chuyển phần tiền.
3. M5 — T5-Tiền.
4. M6 — frontend không tự tính nghiệp vụ.
5. M7 — QA xử lý đúng khi thiếu đặc tả.
6. M8 — cả Codex và Opus.

Nên bổ sung các mồi kiểm chính control plane:

- tệp chưa theo dõi;
- diff chỉ xoá;
- tệp shell;
- bí mật ở dòng xoá;
- cache hết hạn khi skill đổi;
- T7 ghi tệp ignored ngoài `tests/`.

### 4.2 Cần kiểm thử tự động cho chính TEAM

Nên có:

```text
tests/team/
  test-phan-loai-tep.sh
  test-pham-vi-git.sh
  test-chon-skill.sh
  test-quet-bi-mat.py
  test-cache-key.sh
  test-sinh-lenh-doi.py
  test-doc-token.py
```

Các hàm cần được kiểm trực tiếp:

- `la_tep_ma`;
- `lay_pham_vi`;
- `chon_skill`;
- `quet_bi_mat`;
- `bam_pham_vi`;
- `muc_suy_luan`;
- đọc token;
- sinh ba tệp lệnh;
- sinh dashboard.

### 4.3 `tra_san` chưa tra được mọi loại trùng lặp

`tools/tra-san.py` chủ yếu tìm định danh khai báo mới. Nó chưa tìm tốt:

- endpoint;
- tên bảng;
- event;
- permission;
- route;
- queue;
- khoá cấu hình;
- SQL constraint;
- quy tắc không có khai báo riêng.

Nên mô tả đúng là:

> Đã tra các định danh khai báo mới có thể nhận diện.

Không nên coi kết quả này là bằng chứng đã rà toàn bộ kho.

### 4.4 Dashboard mới chứng minh cấu hình tồn tại

Dashboard hiện kiểm được:

- tệp vai tồn tại;
- frontmatter có model và công cụ;
- skill tồn tại;
- bộ mồi có ghi kết quả;
- nhật ký token.

Nó chưa chứng minh một đầu việc đã đi qua:

- đặc tả;
- thiết kế kỹ thuật;
- QA;
- rà độc lập;
- staging;
- phương án hoàn tác.

Dashboard nên tách rõ:

- cấu hình tồn tại;
- đã qua mồi;
- đã dùng trong đầu việc thật;
- kết quả gần nhất;
- tỷ lệ đạt;
- mô hình thực tế;
- ngày kiểm lại.

### 4.5 Thiếu manifest liên kết mười bước

Mỗi đầu việc nên có một manifest máy đọc được:

```yaml
id: APP-B05
phase: P01
level: 1
risk: medium
owner: T6
author_model: claude-sonnet
spec: docs/specifications/APP-B05.md
architecture: null
tests:
  - tests/e2e/app-b05.spec.ts
review:
  model: gpt-5.6-sol
  result: accepted
staging:
  build: null
rollback: null
```

Manifest biến mười bước từ lời dặn thành dữ liệu kiểm tra được.

---

## 5. Rủi ro chiến lược

TEAM đang mô tả một nền tảng production có:

- monorepo;
- API;
- gói nghiệp vụ dùng chung;
- phân quyền;
- cơ sở dữ liệu và migration;
- unit test, API test và E2E;
- staging;
- deployment.

Nhưng repository hiện vẫn chủ yếu là prototype HTML tĩnh.

Điều đó không sai. Tuy nhiên phải gọi đúng hiện trạng:

> TEAM AI hiện là control plane được thiết kế cho P00. Nó chưa phải bằng chứng
> rằng nền tảng production đã tồn tại.

Không nên để dashboard tạo cảm giác đội đã sẵn sàng đầy đủ khi chưa có:

- khung sản phẩm production;
- test runner ba tầng;
- staging;
- CI cưỡng chế;
- manifest đầu việc;
- kết quả đầy đủ của bộ mồi.

---

## 6. Thứ tự xử lý đề xuất

### Trước P00

1. Coi `docs/quy-tac-doi.md` và `docs/vai/**` là control code.
2. Quét bí mật trên toàn bộ payload gửi đi.
3. Đưa nội dung vai, skill và đặc tả vào cache key.
4. Thêm `--muc` và `--nguoi-viet`.
5. Viết unit test cho `_nap-skill.sh` và `quet-bi-mat.py`.
6. Chạy đủ M1–M8.

### Trong P00

7. Tạo manifest đầu việc.
8. Thiết lập CI kiểm tệp sinh tự động khớp nguồn.
9. CI kiểm thay đổi Trung bình trở lên có đặc tả.
10. CI kiểm thay đổi Cao hoặc Đặc biệt có kết quả T8.
11. Dựng test runner thật.
12. Dựng staging tối thiểu.

### Trước production

13. Chạy T7 trong worktree hoặc sandbox giới hạn quyền ghi.
14. Gắn kết quả review với commit hash.
15. Làm cache hết hạn khi commit, đặc tả, skill hoặc vai đổi.
16. Cho dashboard hiển thị bằng chứng thực thi, không chỉ file tồn tại.

---

## 7. Khuyến nghị cuối

Giữ nguyên cơ cấu tám vai. Không thêm agent và không thêm công cụ điều phối.

Vòng cải tiến tiếp theo nên tập trung vào:

- kiểm thử control plane;
- cache đúng phiên bản;
- khai báo mức rủi ro và mô hình tác giả;
- bảo vệ payload gửi ra ngoài;
- CI cưỡng chế quy trình;
- manifest đầu việc;
- bằng chứng thực thi trên dashboard.

Mục tiêu tiếp theo không phải làm TEAM đông hơn. Mục tiêu là biến các quy tắc
đang viết bằng văn bản thành cổng kỹ thuật có thể kiểm chứng và không dễ bị bỏ
qua.

---

## 8. Các tệp chính đã rà

- `docs/quy-tac-doi.md`.
- `AGENTS.md`.
- `CLAUDE.md`.
- `GEMINI.md`.
- `.claude/agents/anwell-t2-dac-ta.md`.
- `.claude/agents/anwell-t3-kien-truc-du-lieu.md`.
- `.claude/agents/anwell-t4-ux-design-system.md`.
- `.claude/agents/anwell-t5-backend.md`.
- `.claude/agents/anwell-t5-backend-tien.md`.
- `.claude/agents/anwell-t6-frontend.md`.
- `.claude/agents/anwell-t8-ra-doc-lap.md`.
- `docs/vai/t7-qa-kiem-thu.md`.
- `tools/_nap-skill.sh`.
- `tools/kiem-thu-bang-codex.sh`.
- `tools/ra-bang-codex.sh`.
- `tools/quet-bi-mat.py`.
- `tools/tra-san.py`.
- `tools/doc-token.py`.
- `tools/sinh-lenh-doi.py`.
- `tools/dashboard-doi.py`.
- `tools/moi/BO-MOI.md`.
- `.gitignore`.

