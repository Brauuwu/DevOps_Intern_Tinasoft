# Tuần 6: Hoàn thiện quy trình CI/CD End-to-End

**Thời gian:** 03/08 - 07/08

## 🎯 Mục tiêu
- Ghép nối tất cả các công cụ (Git, Docker, K8s, CI Pipeline, ArgoCD, Harbor) thành một đường ống (pipeline) xuyên suốt.
- Xây dựng một luồng CI/CD "Zero Touch": Developer push code -> CI Test -> CI Build Image -> CI Push Registry -> CI tự động tạo commit update tag trong Repo Manifest -> ArgoCD nhận diện và Sync xuống K8s.
- Rèn luyện kỹ năng phân tích log liên hoàn và phối hợp xử lý sự cố.

## 📝 Nhiệm vụ thực hành

**Bước 1: Phân bổ Workspace & Vai trò**
1. Nhánh làm việc chung: `tuan6-e2e`.
2. **BẮT BUỘC:** Mỗi bạn vẫn tạo thư mục cá nhân (vd: `hoang/`). Trong thư mục này chuẩn bị sẵn source code web/API hoàn chỉnh của mình.
3. **Phân vai trò cho nhóm:**
   - **Dev (2 người):** Làm nhiệm vụ push code mới.
   - **CI/CD Engineer (2 người):** Đảm bảo Pipeline GitLab/GitHub và ArgoCD hoạt động không bị lỗi.

**Bước 2: Xây dựng Pipeline Chung (Chìa khóa End-to-End)**
Nhóm thống nhất tạo 1 file pipeline chính ở gốc thư mục dự án. Cấu trúc yêu cầu:
1. Lấy source code.
2. Build image với biến `TAG=$CI_COMMIT_SHORT_SHA` (Mã hash commit).
3. Push image lên Harbor.
4. **Bước then chốt (Update Manifest):** Trong Pipeline, cấu hình một script sử dụng công cụ `sed` hoặc `yq` để tự động thay thế dòng `image` trong thư mục YAML manifest thành tag mới nhất.
5. Sau khi đổi tag, CI sử dụng bot-token để thực hiện tự động lưu lại vào git:
```bash
git commit -m "chore: update image tag"
git push origin HEAD:main
```

**Bước 3: Vận hành chiến dịch "Zero Touch Deploy"**
1. Đảm bảo ArgoCD đang chạy và theo dõi thư mục Manifest bằng file `Application` đã chuẩn bị từ tuần trước.
2. Từng thành viên tiến hành sửa đổi dòng chữ giao diện trên Source Code của mình (VD: đổi từ "Version 1" sang "Bản cập nhật End-to-End Siêu Cấp").
3. Chỉ cần gõ lệnh sau. Không được dùng thêm bất kỳ lệnh nào khác:
```bash
git commit -am "feat: cập nhật version 2.0"
git push
```
4. Ngồi theo dõi:
   - GitLab CI báo Pass?
   - Harbor có image mới?
   - Git repository tự động có thêm 1 commit bot sửa đổi file YAML?
   - ArgoCD xoay vòng tròn và Pod K8s được thay mới?
   - Truy cập web để xác nhận phiên bản mới đã hiện lên.

**Bước 4: Báo cáo cá nhân & Troubleshooting**
- Trong thư mục cá nhân của mình, hãy tạo file `e2e-report.md`. 
- Viết lại quy trình theo sơ đồ, ghi chú các lỗi nhóm đã vấp phải ở bước Tự động update Git Manifest.
- Đính kèm ảnh chụp toàn bộ đường ống đang xanh (Pass).
- Tạo PR cuối cùng về mảng kỹ thuật.
