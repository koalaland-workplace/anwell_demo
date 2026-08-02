---
name: anwell-tra-cuu-tai-lieu
description: Dùng khi cần biết một quyết định đã chốt hay chưa, chức năng nào thuộc Phase nào, hoặc câu hỏi nào còn đang treo. Nêu bản đồ sáu tài liệu và bốn file Excel, danh sách quyết định đã chốt để agent không đề xuất ngược.
---

# Tra cứu tài liệu ANWELL

Có bộ tài liệu dày mà không biết đường tra thì vẫn đoán bừa. Skill này là bản đồ.

**Vì sao có skill này:** Dự án đã tích 6 quyển tài liệu, 4 file Excel, 389 chức
năng, 190 đầu việc kỹ thuật, và một danh sách quyết định đã chốt. Agent hỏi lại
thứ đã có câu trả lời là lãng phí, còn agent tự đoán là nguy hiểm hơn.

## Hỏi gì thì mở đâu

| Câu hỏi | Mở |
|---|---|
| Chức năng này làm gì, hiện trạng ra sao? | `Tailieu-noibo/ANWELL-chuc-nang-4-cong.xlsx` |
| Làm ở Phase nào, mức nào, phạm vi tới đâu? | `ANWELL-15-phase-theo-muc-do.xlsx` › *Chức năng theo Phase* |
| Phase này CỐ Ý chưa làm gì? | `ANWELL-15-phase-theo-muc-do.xlsx` › *15 Phase* |
| Ngân sách Phase này bao nhiêu? | `ANWELL-15-phase-theo-muc-do.xlsx` › *Ngân sách theo Phase* |
| Đầu việc kỹ thuật, bảng dữ liệu cần có? | `ANWELL-ho-so-ky-thuat.xlsx` |
| Nhà cung cấp nào, thẩm định mất bao lâu? | `ANWELL-ho-so-ky-thuat.xlsx` › *Dịch vụ bên thứ ba* |
| Việc nào chủ dự án phải lo, hạn tuần nào? | `ANWELL-ho-so-ky-thuat.xlsx` › *Cửa thời gian* |
| Ai làm việc này, cần skill gì? | `ANWELL-ai-team-va-skill.xlsx` |
| Chức năng nào ĐÃ QUYẾT cắt khỏi Phase đầu? | `ANWELL-15-phase-theo-muc-do.xlsx` › *Cắt sẵn theo mốc ngân sách* |
| Mô hình sản phẩm, vì sao thiết kế thế? | `docs/01-tong-quan-san-pham.md` |
| Quyết định nào đã chốt? Còn treo gì? | `docs/05-viec-dang-lam.md` |
| Quy trình sửa và ba lỗi đã mắc | `docs/04-quan-ly-va-cap-nhat.md` |

## Quyết định ĐÃ CHỐT — đừng đề xuất ngược

| Quyết định | Đã chốt là |
|---|---|
| Đánh giá khách hai chiều | Khách **không** thấy điểm mình bị chấm |
| KTV rời trung tâm | Cắt sạch, và nói rõ trong app **từ đầu** |
| Lý lịch tư pháp | Chỉ yêu cầu với ca **tại nhà** |
| Chi phí thưởng ANP | Chia tỷ lệ, thành dòng riêng trong đối soát |
| Nơi đặt quy định lương | **Một chỗ duy nhất**: Dịch vụ & bảng giá → Lương khoán KTV |
| Chế độ hoa hồng GĐKD | Là **lựa chọn ADMIN đặt**, không ghi cứng |
| Mô hình gói nền tảng | Nhiều gói thuê bao, ba cho TT ba cho KTV |
| Quyền dữ liệu cá nhân | Có làm, một tab trong Khách hàng của admin |
| POS | **Đã bỏ** — không làm |
| Bộ giọng đọc | **OmniVoice-Studio** — voicebox đã loại vì không có tiếng Việt |

## Câu hỏi CÒN TREO — phải hỏi, đừng tự quyết

- Mô hình vận hành ví: tự xin giấy phép hay đi qua đối tác có sẵn
- Có đẩy React Native lên sớm cho riêng cổng KTV không
- Chế độ hưởng hoa hồng GĐKD: có thời hạn hay trọn đời
- Ai trả phí lý lịch tư pháp cho KTV
- Tạm hoãn liệu trình có kéo dài hạn dùng gói không
- Có cho KTV hiện số điện thoại trên hồ sơ công khai không
- Chính sách phí vắng mặt
- Ghi chú "cho KTV sau" thuộc về ai khi KTV chuyển trung tâm

## Bảy nhóm số phải khớp nhau giữa các trang

Sửa một chỗ thì phải sửa hết. Xem `docs/05-viec-dang-lam.md` phần *Số liệu phải
khớp*: giá 450k · lương 11,20tr · gói 14/20 buổi · mã xác minh 4729 · hoàn 70k ·
điểm ANP 1.240 · bảng chống chỉ định.

## Không áp dụng khi

- Câu hỏi thuần kỹ thuật không liên quan nghiệp vụ ANWELL
