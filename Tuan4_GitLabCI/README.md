# Tuần 4: GitLab CI Pipeline

**Thời gian:** 20/07 - 24/07

## 🎯 Mục tiêu
- Hiểu nguyên lý CI (Continuous Integration), tại sao phải test và build tự động ngay sau khi có code mới.
- Thành thạo cú pháp cấu hình pipeline (GitLab CI `.gitlab-ci.yml` hoặc GitHub Actions).
- Tích hợp công cụ **Kaniko** để build Docker image trong môi trường CI không có quyền root (Rootless / Docker-in-Docker).
- Biết cách cấu hình Environment Variables bảo mật và tối ưu hóa thời gian chạy CI bằng cơ chế caching.

## 📝 Nhiệm vụ thực hành

**Bước 1: Chuẩn bị thư mục cá nhân**
1. Tạo nhánh mới:
```bash
git checkout -b <ten-cua-ban>/tuan4-ci
```
2. **BẮT BUỘC:** Tạo thư mục có tên bạn (ví dụ: `yen/`) trong `Tuan4_GitLabCI`.

**Bước 2: Hiểu cơ chế Runner & Setup Repository**
1. Cấu hình CI Variables trên giao diện GitLab / GitHub: Thêm các biến như `HARBOR_USERNAME`, `HARBOR_PASSWORD`, `REGISTRY_URL`. Đánh dấu chúng là "Masked" và "Protected" để không bị lộ trên log.
2. Kiểm tra xem dự án đã có CI Runner (Shared hoặc Specific) sẵn sàng chưa.

**Bước 3: Cấu hình Pipeline cá nhân hóa**
Tạo file `my-pipeline.yml` trong thư mục cá nhân của bạn. Cấu trúc gồm 4 stages:
1. **Stage `lint`:** Sử dụng image `hadolint/hadolint` để scan lỗi syntax của `Dockerfile` mà bạn đã làm ở Tuần 2.
2. **Stage `test`:** Chạy script giả lập unit test. Mở rộng: cấu hình `coverage` hoặc lưu report qua block `artifacts:`.
```bash
echo "Chạy Unit Test thành công!"
```
3. **Stage `security` (Tùy chọn):** Sử dụng image `aquasec/trivy` để quét lỗ hổng bảo mật của một image bất kỳ hoặc của source code.
4. **Stage `build-and-push`:**
   - Image: `gcr.io/kaniko-project/executor:debug`
   - Khởi tạo script cấu hình file `config.json` cho Docker auth.
   - Chạy lệnh kaniko: 
   ```bash
   /kaniko/executor --context $CI_PROJECT_DIR --dockerfile $CI_PROJECT_DIR/Dockerfile --destination $REGISTRY_URL/project/<ten-cua-ban>-app:$CI_COMMIT_SHORT_SHA
   ```

**Bước 4: Điều kiện & Tối ưu**
- Sử dụng block `rules` để quy định: Stage `build-and-push` chỉ chạy khi commit vào nhánh `main` hoặc khi có Tag, còn các nhánh phụ chỉ chạy `lint` và `test`.
- Thử nghiệm tính năng `cache:` để lưu lại các dependencies (vd thư mục `node_modules` hoặc `.m2`) giúp các lần chạy sau nhanh hơn.

**Bước 5: Thảo luận và Nộp bài**
- Tự trigger pipeline trên branch của bạn. Tải log chạy pipeline (file text) bỏ vào thư mục cá nhân.
- Ghi lại các cấu trúc đã áp dụng vào file `ci-notes.md`.
- Commit và tạo PR. Nhóm sẽ chọn ra 1 bản CI tốt nhất làm nền tảng cho Tuần 6.
