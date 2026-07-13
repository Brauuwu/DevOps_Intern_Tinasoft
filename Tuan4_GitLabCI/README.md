# Tuần 4: GitLab CI Pipeline (Deep Dive)

*Điều hướng nhanh:* [⬅️ Tuần 3: Kubernetes](../Tuan3_Kubernetes/README.md) | [🏠 Trang chủ Repo](../README.md) | [Tuần 5: GitOps ➡️](../Tuan5_GitOps_ArgoCD/README.md)

**Thời gian:** 20/07 - 24/07

## 🎯 Mục tiêu (Checklist Phase 4)
Tự động hóa bước build, test, và đóng gói image — bước nối giữa code và registry.

- **Khái niệm:** Nắm vững CI (Continuous Integration), khái niệm Pipeline, Stage, Job.
- **Cấu hình:** Thành thạo cú pháp cấu trúc file `.gitlab-ci.yml`.
- **Hạ tầng:** Hiểu cách hoạt động của GitLab Runner và các khái niệm Executor.
- **Workflow:** Cấu hình chuẩn một Pipeline tự động: build → test → build image bằng Kaniko → push lên Harbor.
- **Bảo mật:** Biết cách cấu hình Biến môi trường (Environment Variables), Secret/Variable trong GitLab CI.
- **Tối ưu:** Cấu hình Cache và truyền dữ liệu (Artifact) giữa các job.

## 📚 Lý thuyết Cốt lõi (Under the Hood)
1. **GitLab Runner & Executor là gì?**
   - **GitLab Runner** là một tiến trình (process) chạy độc lập với GitLab Server. Khi có code push lên, GitLab Server báo cho Runner biết có Job cần chạy. Runner sẽ nhận lệnh và thực thi.
   - **Executor:** Quyết định môi trường chạy lệnh. Thông dụng nhất là **Docker Executor**. Mỗi khi có một Job mới, Runner sẽ khởi tạo một container hoàn toàn trống (dựa trên tham số `image:` mà bạn truyền vào file yaml), ném toàn bộ mã nguồn của bạn vào đó, chạy các script `script:`, và hủy container đi ngay khi chạy xong. Môi trường cực kỳ sạch sẽ và vô trùng (Stateless).
2. **Sự khác biệt sống còn giữa `cache` và `artifacts`:**
   - `cache`: Dùng để lưu các thư viện phụ thuộc (ví dụ `node_modules` hoặc `.m2` của Maven) nhằm tăng tốc độ các lần build SAU ĐÓ. Khái niệm này chỉ giúp chạy nhanh hơn, nếu mất cache thì CI tự tải lại từ internet.
   - `artifacts`: Dùng để truyền kết quả ĐẦU RA từ Job trước sang Job sau trong CÙNG MỘT pipeline. (Ví dụ: Stage `build` sinh ra file `app.jar`, stage `test` cần dùng file `app.jar` này. Do mỗi Job chạy trên 1 container độc lập và bị hủy ngay lập tức, nên bắt buộc phải dùng `artifacts` để ném file jar này cho GitLab Server giữ, rồi Job sau lấy về xài).
3. **Tại sao lại dùng Kaniko trong CI? (Docker in Docker Problem)**
   - Ngày xưa, để dùng lệnh `docker build` bên trong một container CI, người ta phải mount `/var/run/docker.sock` từ máy host vào. Nếu có hacker cài mã độc vào CI, hacker đó có thể leo thang đặc quyền (Privilege Escalation) chiếm trọn máy host.
   - Kaniko ra đời để build image hoàn toàn trong User Space, không cần quyền root và không cần Docker Daemon. An toàn tuyệt đối cho môi trường Shared Runner (Runner dùng chung).

## 📝 Nhiệm vụ thực hành chuyên sâu

**Bước 1: Khởi tạo và thiết lập Repo**
1. Nhánh làm việc: `git checkout -b <ten-cua-ban>/tuan4-ci`
2. Tạo thư mục cá nhân. Khởi tạo một file `.gitlab-ci.yml` trong gốc của repo.
3. Thiết lập **CI/CD Variables** trên giao diện dự án: 
   - Truy cập *Settings -> CI/CD -> Variables*.
   - Tạo các biến `HARBOR_USERNAME`, `HARBOR_PASSWORD`, `REGISTRY_URL`. Bắt buộc tick chọn **Masked** (để che giấu password trên màn hình log đen) và **Protected** (chỉ cho phép chạy trên nhánh main/protected).

**Bước 2: Viết Pipeline Cơ bản (Test & Cache)**
1. Định nghĩa các `stages`: `lint`, `test`, `build-image`.
2. Trong job `test` (VD: dùng cho React), cấu hình block `cache` như sau:
```yaml
cache:
  key:
    files:
      - package-lock.json # Chỉ update cache khi file này đổi
  paths:
    - node_modules/ # Lưu lại nguyên thư mục này
```
3. Job `lint` có thể dùng image `hadolint/hadolint` để kiểm tra độ sạch và chuẩn của Dockerfile.

**Bước 3: Viết Pipeline Build Image bằng Kaniko**
Đây là block cấu hình mẫu cực chuẩn dùng cho Kaniko trong GitLab CI:
```yaml
build-kaniko:
  stage: build-image
  image:
    name: gcr.io/kaniko-project/executor:debug # Bắt buộc dùng tag debug có chứa shell
    entrypoint: [""] # Ghi đè entrypoint mặc định của image
  script:
    # 1. Tạo file xác thực cho Harbor bằng biến môi trường
    - echo "{\"auths\":{\"$REGISTRY_URL\":{\"username\":\"$HARBOR_USERNAME\",\"password\":\"$HARBOR_PASSWORD\"}}}" > /kaniko/.docker/config.json
    # 2. Chạy kaniko build & push
    - /kaniko/executor
      --context $CI_PROJECT_DIR
      --dockerfile $CI_PROJECT_DIR/Dockerfile
      --destination $REGISTRY_URL/project/my-app:$CI_COMMIT_SHORT_SHA
```
*Phân tích:* Biến `$CI_COMMIT_SHORT_SHA` là hash của commit hiện tại. Việc dùng hash làm tag (thay vì tag `latest` vô tri) là **tiêu chuẩn bắt buộc** trong hệ thống CI/CD chuyên nghiệp để đảm bảo tính truy xuất nguồn gốc (Traceability). Biết rõ image này được sinh ra từ đoạn code nào.

**Bước 4: Điều khiển dòng chảy Pipeline (Rules & Conditions)**
Không phải lúc nào push code cũng phải build image. 
- Sử dụng block `rules` để giới hạn job `build-kaniko` chỉ chạy khi ta push code lên nhánh `main`, còn các nhánh dev thì chỉ chạy job `test`.
```yaml
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

**Bước 5: Pipeline Nâng cao — Multi-environment & Dynamic Environments**

Trong thực tế, một Pipeline không chỉ build mà phải deploy sang nhiều môi trường khác nhau (dev, staging, production).

1. **Cấu hình nhiều môi trường bằng `environment:`:**

```yaml
deploy-staging:
  stage: deploy
  environment:
    name: staging
    url: https://staging.myapp.com  # Link truy cập môi trường
  script:
    - echo "Deploying to Staging..."
    - kubectl apply -f k8s/staging/
  rules:
    - if: $CI_COMMIT_BRANCH == "develop"

deploy-production:
  stage: deploy
  environment:
    name: production
    url: https://myapp.com
  script:
    - echo "Deploying to Production..."
    - kubectl apply -f k8s/production/
  when: manual  # Chỉ chạy khi Leader nhấn nút Play
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```
*(Giải thích: `environment:` khai báo môi trường deploy. GitLab sẽ tạo mục Operations > Environments trên giao diện, cho bạn xem lần deploy gần nhất của mỗi môi trường. `when: manual` biến job thành nút bấm thủ công — đây chính là Production Gate)*.

2. **Dynamic Environment cho mỗi Merge Request (Tùy chọn nâng cao):**

Mỗi MR tự động tạo một môi trường preview riêng biệt:
```yaml
deploy-review:
  stage: deploy
  environment:
    name: review/$CI_COMMIT_REF_SLUG   # Tên môi trường dựa trên tên nhánh
    url: https://$CI_COMMIT_REF_SLUG.review.myapp.com
    on_stop: stop-review              # Job dọn dẹp khi MR đóng
  script:
    - echo "Deploying review environment for MR..."
  rules:
    - if: $CI_MERGE_REQUEST_ID

stop-review:
  stage: deploy
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    action: stop
  script:
    - echo "Cleaning up review environment..."
  when: manual
  rules:
    - if: $CI_MERGE_REQUEST_ID
```
*(Giải thích: `$CI_COMMIT_REF_SLUG` là tên nhánh đã được "làm sạch" (bỏ ký tự đặc biệt). `on_stop` liên kết với job dọn dẹp. Khi Merge Request được merge hoặc đóng, môi trường review sẽ bị xóa tự động)*.

**Bước 6: CI Security & Quality Gates**

Một Pipeline chuyên nghiệp không chỉ build mà còn phải kiểm tra chất lượng và bảo mật của mã nguồn.

1. **SAST (Static Application Security Testing) cơ bản:** Quét mã nguồn tìm lỗ hổng bảo mật trước khi build:

```yaml
sast-scan:
  stage: lint
  image: returntocorp/semgrep  # Công cụ SAST miễn phí
  script:
    - semgrep --config=auto --json --output=sast-report.json .
  artifacts:
    paths:
      - sast-report.json
    when: always  # Lưu report kể cả khi job fail
  allow_failure: true  # Không chặn pipeline nếu phát hiện lỗi
```
*(Giải thích: `semgrep` là công cụ SAST mã nguồn mở, quét các pattern lỗ hổng phổ biến (SQL Injection, XSS, Hardcoded Secrets...). `allow_failure: true` để pipeline không bị chặn — bạn vẫn muốn biết lỗi nhưng không bắt buộc phải sửa ngay)*.

2. **Dependency Scanning — Quét thư viện bên thứ 3:**

```yaml
dependency-check:
  stage: lint
  image: node:20-alpine
  script:
    - npm audit --json > dependency-report.json || true
    - echo "=== Dependency Audit Summary ==="
    - npm audit --summary
  artifacts:
    paths:
      - dependency-report.json
  allow_failure: true
```
*(Giải thích: `npm audit` kiểm tra các thư viện có lỗ hổng đã biết (CVE). `|| true` ngăn lệnh trả về exit code khác 0 khi có lỗi (vì `npm audit` exit 1 khi tìm thấy vulnerability))*.

3. **Thiết lập Pipeline Badges:** Lên giao diện GitLab: *Settings -> CI/CD -> General pipelines -> Pipeline status*. Sao chép mã Markdown và dán vào `README.md` của repo để hiển thị trạng thái Pipeline (xanh/đỏ) trực tiếp trên trang chủ.

**Bước 7: Notification & Monitoring Pipeline**

Pipeline chạy xong mà không ai biết thì vô nghĩa. Hãy cấu hình thông báo tự động.

1. **Gửi Webhook tới Discord/Telegram khi Pipeline kết thúc:**

Tạo một job cuối pipeline:
```yaml
notify-success:
  stage: notify
  image: alpine:latest
  script:
    - apk add --no-cache curl
    - |
      curl -X POST "$DISCORD_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{
          \"content\": \"\u2705 **Pipeline #${CI_PIPELINE_ID}** thành công!\\nBranch: ${CI_COMMIT_BRANCH}\\nCommit: ${CI_COMMIT_SHORT_SHA}\\nBy: ${GITLAB_USER_NAME}\"
        }"
  when: on_success  # Chỉ chạy khi tất cả job trước đó thành công

notify-failure:
  stage: notify
  image: alpine:latest
  script:
    - apk add --no-cache curl
    - |
      curl -X POST "$DISCORD_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{
          \"content\": \"\u274c **Pipeline #${CI_PIPELINE_ID}** THẤT BẠI!\\nBranch: ${CI_COMMIT_BRANCH}\\nCommit: ${CI_COMMIT_SHORT_SHA}\\nBy: ${GITLAB_USER_NAME}\\nLink: ${CI_PIPELINE_URL}\"
        }"
  when: on_failure  # Chỉ chạy khi có ít nhất 1 job bị fail
```
*(Giải thích: Tạo Webhook URL trên Discord (Server Settings > Integrations > Webhooks) hoặc Telegram Bot, rồi lưu vào CI/CD Variable `$DISCORD_WEBHOOK_URL`. `when: on_success/on_failure` điều khiển job chỉ chạy theo kết quả pipeline)*.

2. **Phân tích Pipeline Analytics:** Truy cập *CI/CD -> Analytics* trên giao diện GitLab để xem:
   - Thời gian trung bình của mỗi stage (bước nào chạy chậm nhất?)
   - Tỷ lệ Pipeline thành công/thất bại theo tuần
   - Ghi chép lại các số liệu này vào file `ci-analytics.md` trong thư mục cá nhân.

> [!TIP]
> Nếu stage `build-image` chạy chậm, hãy kiểm tra lại Dockerfile xem đã áp dụng Layer Caching đúng chưa (Bước 2 của Tuần 2).

**Bước 8: Kích hoạt Pipeline & Nộp bài (Output đánh giá)**

**Cẩm nang Lệnh Git kích hoạt CI:**
Sau khi viết xong file `.gitlab-ci.yml`, bạn cần push code lên server để GitLab Runner bắt đầu bắt job:
```bash
git add .gitlab-ci.yml
git commit -m "ci: cấu hình pipeline build kaniko"
git push origin <ten-cua-ban>/tuan4-ci
```

> [!IMPORTANT]
> **Yêu cầu bắt buộc để qua bài:** Viết pipeline CI hoàn chỉnh cho 1 project thực tế (như các app ở `Sample_WebApps`): tự động chạy test, build image bằng **Kaniko**, và push image lên Harbor với image tag tự sinh theo commit/branch (sử dụng biến `$CI_COMMIT_SHORT_SHA` hoặc biến môi trường tương tự).

- Lên giao diện GitLab -> CI/CD -> Pipelines để xem luồng chạy trực tiếp. Tải file raw log chạy pipeline (để chứng minh Kaniko hoạt động) bỏ vào thư mục cá nhân.
- Ghi chú các lỗi (đặc biệt là lỗi syntax YAML hoặc lỗi xác thực Harbor 401 Unauthorized) vào file `ci-notes.md`.
- Commit và tạo PR. Nhóm sẽ đánh giá và chọn ra 1 bản CI tốt nhất làm nền tảng cho quy trình End-to-End ở Tuần 6.
