# DevOps Practice Lab - Thực tập tốt nghiệp

Chào mừng đến với không gian thực hành DevOps của nhóm. Repository này được tạo ra để lưu trữ mã nguồn, tài liệu và theo dõi quá trình thực hành các công cụ và quy trình DevOps trong suốt kỳ thực tập.

## 👥 Danh sách thành viên

- Vi Minh Hiếu
- Đoàn Viết Hoàng
- Nguyễn Hữu Xuân
- Đỗ Thị Thu Yến

## 📁 Kho Tài nguyên Hỗ trợ (Resources)

Dự án cung cấp sẵn 2 thư mục tài nguyên đặc biệt để hỗ trợ nhóm trong quá trình thực hành:
- **`Sample_WebApps/`**: Kho chứa các ứng dụng Web động (Dashboard, TaskBoard, Monitor,...) với giao diện hiện đại để mang đi đóng gói Docker thay vì dùng code "Hello World" nhàm chán. *(Lưu ý: Không sửa trực tiếp file trong này, hãy copy ra ngoài khi thực hành).*
- **`Examples_References/`**: Kho chứa mã nguồn cấu hình mẫu chuẩn (Dockerfile, Kubernetes Manifests, GitLab CI, ArgoCD...). Dùng để tham khảo khi bí ý tưởng.

## 🗓️ Lộ trình thực hành

Repository được chia thành các thư mục tương ứng với từng tuần thực tập:

| Thời gian | Chủ đề | Mục tiêu / Hoạt động chính |
| :--- | :--- | :--- |
| **Tuần 1** (29/06 - 03/07) | `Tuan1_Linux_Git` | Tìm hiểu tổng quan DevOps, Linux, Bash Shell, Git. Cài đặt môi trường phát triển trên máy ảo sử dụng VMWare và làm quen quy trình Git. |
| **Tuần 2** (06/07 - 10/07) | `Tuan2_Docker_Harbor` | Nghiên cứu Docker, Docker Compose, Dockerfile, Kaniko, Harbor. Thực hành container hóa và quản lý image. |
| **Tuần 3** (13/07 - 17/07) | `Tuan3_Kubernetes` | Tìm hiểu Kubernetes (Pod, Deployment, Service, Ingress, ConfigMap, Secret). Triển khai app bằng YAML Manifest. |
| **Tuần 4** (20/07 - 24/07) | `Tuan4_GitLabCI` | Xây dựng GitLab CI Pipeline tự động build, test, đóng gói bằng Kaniko và đẩy lên Harbor. |
| **Tuần 5** (27/07 - 31/07) | `Tuan5_GitOps_ArgoCD` | Tìm hiểu GitOps, ArgoCD. Triển khai ứng dụng, đồng bộ manifest từ Git lên K8s. |
| **Tuần 6** (03/08 - 07/08) | `Tuan6_CICD_EndToEnd` | Hoàn thiện quy trình CI/CD End-to-End. Tích hợp, kiểm thử toàn bộ hệ thống. |
| **Tuần 7** (10/08 - 14/08) | `Tuan7_BaoCao` | Hoàn thiện báo cáo thực tập, thảo luận nhóm và chuẩn bị thuyết trình. |

---

## 🛠️ Hướng dẫn quy trình làm việc trên GitHub (Git Workflow)

Để đảm bảo code không bị conflict và quá trình làm việc nhóm trơn tru, tất cả thành viên vui lòng tuân thủ quy trình sau:

### 1. Phân nhánh (Branching)

- **`main`**: Nhánh chính, chứa code ổn định nhất. **KHÔNG PUSH TRỰC TIẾP LÊN NHÁNH NÀY**.
- **Nhánh tính năng (Feature/Task Branch)**: Mỗi khi làm một task mới hoặc thực hành một bài mới, hãy tạo nhánh từ `main`.
  - Cú pháp đặt tên: `<tên-người-dùng>/<tên-task-ngắn-gọn>`
  - Ví dụ: `hieu/setup-dockerfile`, `hoang/k8s-manifest`, `xuan/gitlab-ci`, `yen/argocd-setup`

**Cách tạo nhánh mới:**
```bash
# Cập nhật code mới nhất từ main trước
git checkout main
git pull origin main

# Tạo và chuyển sang nhánh mới
git checkout -b ten-nhanh-cua-ban
```

### 2. Quá trình làm việc và Commit (Committing)

- Viết code/tài liệu trong thư mục tương ứng của tuần.
- Commit thường xuyên với message rõ ràng.

**Cú pháp Commit Message (Quy ước Conventional Commits):**
- `feat: ...` : Thêm tính năng/bài thực hành mới.
- `fix: ...` : Sửa lỗi.
- `docs: ...` : Thêm/sửa tài liệu, README.
- `chore: ...` : Các tác vụ nhỏ khác (cấu hình, format...).

**Ví dụ:**
```bash
git add .
git commit -m "feat: thêm Dockerfile cho ứng dụng web"
```

### 3. Đẩy code lên GitHub (Push)

```bash
git push origin ten-nhanh-cua-ban
```

### 4. Tạo Pull Request (PR)

1. Lên trang GitHub của repository.
2. Bạn sẽ thấy nút **Compare & pull request** màu xanh lá. Bấm vào đó.
3. Tiêu đề PR cần ngắn gọn, rõ ràng.
4. Ở phần mô tả PR:
   - Ghi rõ PR này giải quyết vấn đề gì / nội dung thực hành là gì.
   - Tag các thành viên khác vào review (nếu cần).
5. Bấm **Create pull request**.

### 5. Review Code và Merge

- Các thành viên khác có thể vào đọc code, góp ý (comment) hoặc thả tim (Approve).
- Nếu có yêu cầu chỉnh sửa (Request changes), người tạo PR cần sửa ở máy local, sau đó `git commit` và `git push` lên lại nhánh đó. PR sẽ tự động cập nhật.
- Khi PR đã được Approve và pass các check (nếu có), tiến hành **Squash and merge** hoặc **Merge pull request** vào `main`.
- Xóa nhánh sau khi đã merge để repo gọn gàng.

### 6. Cập nhật nhánh Local

Sau khi PR của ai đó được merge vào `main`, các thành viên khác đang làm việc trên nhánh của mình cần cập nhật code mới nhất từ `main` về:

```bash
# Đang đứng ở nhánh của bạn
git fetch origin
git rebase origin/main
# Hoặc nếu không rành rebase, bạn có thể dùng merge:
# git merge origin/main
```

---

## 🤝 Các quy tắc chung

- **Tôn trọng thư mục làm việc**: Mỗi người có thể tạo thư mục con mang tên mình trong từng tuần để thực hành (ví dụ: `Tuan2_Docker_Harbor/hieu/`, `Tuan2_Docker_Harbor/hoang/`), hoặc cùng thống nhất sửa chung các file project.
- **Hỗ trợ nhau**: Mọi người chủ động báo cáo tiến độ và nhờ hỗ trợ trên nhóm chat nếu gặp khó khăn (lỗi cài đặt, lỗi build, ...).
- **Tránh commit file không cần thiết**: Chú ý tạo file `.gitignore` để bỏ qua các thư mục sinh ra khi build hoặc file cấu hình cá nhân của IDE.
