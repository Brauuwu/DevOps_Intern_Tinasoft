# Tuần 7: Hoàn thiện báo cáo thực tập

**Thời gian:** 10/08 - 14/08

## 🎯 Mục tiêu

- Hệ thống hóa toàn bộ kiến thức, quá trình thực hành và kinh nghiệm xử lý lỗi trong suốt 6 tuần.
- Rèn luyện kỹ năng viết tài liệu chuyên ngành, trình bày kiến trúc hệ thống bằng sơ đồ theo tiêu chuẩn công nghiệp (Sử dụng Draw.io / PlantUML).
- Chuẩn bị slide PowerPoint, kịch bản thuyết trình bảo vệ trước hội đồng/công ty.

## 📝 Nhiệm vụ thực hành

**Bước 1: Chuẩn bị cấu trúc**

1. Tạo nhánh cuối cùng:

```bash
git checkout -b <ten-cua-ban>/tuan7-baocao
```

2. **BẮT BUỘC:** Tạo thư mục cá nhân mang tên bạn (vd: `xuan/`) trong `Tuan7_BaoCao`.

**Bước 2: Viết phần báo cáo cá nhân (Module hóa)**
Để tránh conflict vào phút chót và giúp tài liệu chuyên sâu hơn, mỗi bạn viết báo cáo về công nghệ mình phụ trách nhiều nhất. Trong thư mục cá nhân tạo file `<chude-cua-ban>.md`.
Yêu cầu bắt buộc trong báo cáo con:

1. **Lý thuyết:** Giải thích khái niệm (vd: Tại sao dùng Docker mà không dùng VM?).
2. **Sơ đồ:** Bắt buộc vẽ 1 sơ đồ cấu trúc/luồng hoạt động của công nghệ đó. Xuất ra dạng PNG bỏ vào thư mục cá nhân.
3. **Thực hành:** Trình bày tóm tắt cấu hình YAML/Dockerfile điển hình.
4. **Pain-points (Sự cố):** Đưa ra ít nhất 2 lỗi (Bug) bạn đã gặp và cách bạn fix nó. (Điều này rất được các hội đồng đánh giá cao).

**Bước 3: Đóng góp vào Báo cáo tổng thể**

1. Người Leader sử dụng file `template-bao-cao.md` ở thư mục gốc Tuần 7 để làm "Sườn chính".
2. Ghép nội dung từ các thư mục con thành file `BaoCao_DevOps_ThucTap.md` thống nhất.
3. Căn chỉnh format, rà soát chính tả, kiểm tra liên kết hình ảnh có bị gãy không.
4. Export tài liệu Markdown ra định dạng PDF (Sử dụng extension trên VSCode hoặc công cụ Pandoc).

**Bước 4: Chuẩn bị Thuyết trình (Presentation)**

- Tạo Slide PowerPoint / Google Slides và phân công từng người nói phần nào.
- Export Slide ra dạng PDF và để chung vào thư mục Tuần 7.
- (Khuyến khích) Quay một đoạn Video Demo khoảng 5 phút màn hình luồng chạy End-to-End từ thay đổi mã nguồn -> CI -> ArgoCD Deploy. Up lên YouTube và gắn link vào Báo cáo. Đây là minh chứng rõ ràng nhất cho năng lực thực hành của nhóm.
