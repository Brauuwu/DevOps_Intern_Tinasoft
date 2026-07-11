# Tuần 6: Hoàn thiện quy trình CI/CD End-to-End

**Thời gian:** 03/08 - 07/08

## 🎯 Mục tiêu (Checklist Phase 6 - Capstone)
Ghép toàn bộ các phase trước thành một quy trình thật: từ lúc dev push code tới khi chạy ở môi trường Production.

- **Luồng đầy đủ (End-to-End):** Cấu hình tự động: Push code → GitLab CI Build & Test → Build image bằng Kaniko → Push lên Harbor → Cập nhật Manifest Repo → ArgoCD detect & sync → Deploy lên môi trường Staging.
- **Production Gate:** Thiết lập bước Approve thủ công (hoặc gate) trước khi cho phép mã nguồn được đẩy lên môi trường Production.
- **Rollback Strategy:** Xây dựng chiến lược ứng cứu: Khi deploy bị lỗi thì xử lý thế nào (Rollback bằng nút bấm trên giao diện ArgoCD hay dùng lệnh `git revert` commit trên GitHub).
- **Tài liệu hóa:** Viết file README tổng kết, mô tả lại toàn bộ luồng kiến trúc cho project demo.

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

**Bước 3: Vận hành Luồng Staging và Production Gate**
1. Đảm bảo ArgoCD đang chạy và theo dõi thư mục Manifest.
2. Cấu hình **2 môi trường** (Staging và Production). Staging sẽ auto-sync, Production sẽ yêu cầu manual sync (hoặc thêm job `when: manual` trên GitLab CI).
3. Tiến hành sửa đổi code giao diện (VD: đổi "Version 1" sang "Version 2") và push:
```bash
git commit -am "feat: cập nhật version 2.0"
git push
```
4. Quan sát luồng CI/CD chạy xuyên suốt:
   - GitLab CI Pass -> Image được đẩy lên Harbor.
   - Bot tự động đẩy commit sửa tag image trong file YAML của môi trường Staging.
   - ArgoCD lập tức Sync và hiển thị phiên bản 2.0 trên trang Web Staging.
5. **Approve Production:** Sau khi test Staging ổn định, Leader/DevOps bấm nút Approve thủ công để cập nhật YAML cho nhánh Production. Quan sát ArgoCD đồng bộ ứng dụng lên cụm Production.
6. **Thử nghiệm Rollback:** Cố tình push code chứa lỗi. Sau đó thực hành chiến lược Rollback (ấn nút Rollback trên giao diện ArgoCD hoặc gõ `git revert HEAD` để khôi phục code trạng thái cũ).

**Bước 4: Báo cáo (Output đánh giá)**

> [!IMPORTANT]
> **Yêu cầu bắt buộc để qua bài (Capstone Demo):** Nhóm phải tiến hành Demo trực tiếp trên 1 project duy nhất. 
> Hành động Demo: Từ lúc gõ `git push` một dòng code thay đổi, quan sát hệ thống tự chạy qua luồng CI/CD và apply lên môi trường **Staging**. Sau đó thực hiện hành động Approve (bấm nút thủ công) để hệ thống promote phiên bản đó lên môi trường **Production**.

- Viết một file `README.md` tổng kết kiến trúc luồng CI/CD cho project này.
- Ghi lại các lệnh và mô tả chiến lược Rollback vào file `e2e-report.md`.
- Tạo PR cuối cùng để kết thúc khóa đào tạo chuyên môn kỹ thuật.
