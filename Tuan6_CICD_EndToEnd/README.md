# Tuần 6: Hoàn thiện quy trình CI/CD End-to-End (Capstone Deep Dive)

*Điều hướng nhanh:* [⬅️ Tuần 5: GitOps](../Tuan5_GitOps_ArgoCD/README.md) | [🏠 Trang chủ Repo](../README.md)

**Thời gian:** 03/08 - 07/08

## 🎯 Mục tiêu (Checklist Phase 6 - Capstone)
Ghép toàn bộ các phase trước thành một quy trình thật: từ lúc dev push code tới khi chạy ở môi trường Production.

- **Luồng đầy đủ (End-to-End):** Cấu hình tự động: Push code → GitLab CI Build & Test → Build image bằng Kaniko → Push lên Harbor → Cập nhật Manifest Repo → ArgoCD detect & sync → Deploy lên môi trường Staging.
- **Production Gate:** Thiết lập bước Approve thủ công (hoặc gate) trước khi cho phép mã nguồn được đẩy lên môi trường Production.
- **Rollback Strategy:** Xây dựng chiến lược ứng cứu: Khi deploy bị lỗi thì xử lý thế nào (Rollback bằng nút bấm trên giao diện ArgoCD hay dùng lệnh `git revert` commit trên GitHub).
- **Tài liệu hóa:** Viết file README tổng kết, mô tả lại toàn bộ luồng kiến trúc cho project demo.

## 📚 Lý thuyết Cốt lõi (Under the Hood)
1. **Bức tranh lớn (The Big Picture):**
   - Sự vĩ đại của DevOps không nằm ở một công cụ đơn lẻ, mà nằm ở **Đường ống (Pipeline)**. Ở Tuần 6, chúng ta không tạo ra công nghệ mới, mà thiết lập "dây chuyền lắp ráp" tự động.
   - Code của Dev (App Repo) -> Pipeline "nấu" thành Docker Image -> Vứt vào "kho" Harbor -> Bot CI chạy ra "kho cấu hình" (Manifest Repo) sửa dòng tag -> ArgoCD ngồi trong cụm K8s nhìn thấy YAML thay đổi liền kéo về áp dụng -> K8s tạo Pod mới chứa code mới.
2. **Chiến lược Cập nhật Tag tự động (Automated Manifest Update):**
   - Đây là mắc xích mỏng manh nhất của GitOps. Khi Kaniko đẩy image `v2.0` lên Harbor, làm sao Manifest Repo biết để sửa `image: myapp:v1.0` thành `v2.0`?
   - *Cách 1:* Dùng Bot CI. Trong stage cuối của GitLab CI, ta checkout Manifest Repo, dùng lệnh `sed` hoặc thư viện `yq` sửa file YAML, rồi thực hiện `git push` tự động.
   - *Cách 2:* Dùng ArgoCD Image Updater (Nâng cao). Cài thêm một con Bot trong K8s. Bot này liên tục ping hỏi Harbor "Có image nào mới không?". Nếu có, nó tự sửa Manifest Repo hộ mình.
3. **Rolling Update & Zero-Downtime Deployment:**
   - Khi ArgoCD đè cấu hình mới xuống K8s, ứng dụng của bạn không bị sập (downtime). Thay vào đó, K8s áp dụng thuật toán **Rolling Update** (Cập nhật cuốn chiếu).
   - Nó sẽ tạo 1 Pod mới (v2.0). Chờ đến khi ReadinessProbe của Pod v2.0 báo "Sẵn sàng nhận traffic", nó mới từ từ tắt 1 Pod cũ (v1.0) đi. Lặp lại quá trình cho đến khi thay máu toàn bộ hệ thống. Người dùng cuối hoàn toàn không cảm nhận được quá trình update.

## 📝 Nhiệm vụ thực hành chuyên sâu (Capstone Project)

**Bước 1: Phân bổ Workspace & Vai trò (Roleplay)**
Đây là dự án cuối khóa. Khuyến khích làm theo nhóm trên một dự án chung.
1. Nhánh làm việc chung: `tuan6-e2e`.
2. **Phân vai trò (Roleplay):**
   - **Developer:** Đóng vai người viết code. Thường xuyên push thay đổi giao diện/API lặt vặt.
   - **DevOps Engineer:** Đóng vai người thiết lập toàn bộ file `.gitlab-ci.yml`, quản trị ArgoCD và xử lý lỗi khi Pipeline đỏ.

**Bước 2: Xây dựng cầu nối (The Missing Link)**
Khó khăn lớn nhất là đoạn CI tự động commit YAML. Trong file `.gitlab-ci.yml`, hãy cấu hình một stage cuối:
```yaml
update-manifest:
  stage: deploy-staging
  image: alpine/git
  script:
    - git clone https://oauth2:${GIT_BOT_TOKEN}@github.com/YourOrg/ManifestRepo.git
    - cd ManifestRepo
    - sed -i "s/image: myapp:.*/image: myapp:$CI_COMMIT_SHORT_SHA/g" deployment.yaml
    - git config --global user.email "bot@company.com"
    - git config --global user.name "CI Bot"
    - git commit -am "chore: auto update image tag to $CI_COMMIT_SHORT_SHA"
    - git push origin main
```
*Gợi ý:* Bạn bắt buộc phải tạo Personal Access Token (PAT) trên GitHub và bỏ vào mục CI/CD Variables của GitLab để script trên có quyền đẩy code.

**Bước 3: Vận hành Luồng Staging và Production Gate**
1. Đảm bảo ArgoCD đang theo dõi Manifest Repo.
2. Hãy thiết lập 2 thư mục trong Manifest Repo: `overlays/staging` và `overlays/production`.
3. Script ở **Bước 2** mặc định chỉ sửa YAML ở nhánh `staging`.
4. **Approve Production:** Cấu hình một Job thủ công (`when: manual`) trên GitLab CI. Chỉ khi sếp (Leader) vào bấm nút Play, Job này mới chạy lệnh copy nội dung từ thư mục staging sang production, hoặc hợp nhất (merge request) nhánh staging vào nhánh production.
5. Quan sát ArgoCD có 2 Application: `App-Staging` (Tự động xanh ngay lập tức) và `App-Production` (Chỉ xanh khi có lệnh Approve).

**Bước 4: Thử nghiệm Thảm họa (Disaster Recovery & Rollback)**
1. Dev cố tình viết code lỗi (VD: trả về HTTP 500) và push.
2. Pipeline tự động đẩy lên Staging. Hệ thống Staging sập.
3. **Thực hành Rollback:** 
   - **Cách 1 (GitOps thuần):** Thao tác đảo ngược lịch sử Git bằng lệnh.
     ```bash
     git log --oneline # Tìm mã hash của commit làm lỗi hệ thống (ví dụ: a1b2c3d)
     git revert a1b2c3d # Lệnh này tạo một commit mới đảo ngược nội dung của commit lỗi
     git push origin main
     ```
     *(ArgoCD sẽ thấy YAML quay về phiên bản cũ thông qua commit Revert mới này và tự động lùi K8s về trạng thái ổn định).*
   - **Cách 2 (Lệnh Khẩn cấp):** Nếu cần Rollback ngay lập tức mà không đợi Git thao tác.
     ```bash
     argocd app rollback <ten-app-cua-ban> <id-lich-su>
     ```
     *(Bạn có thể xem ID lịch sử trên giao diện ArgoCD. Lệnh này ép K8s lùi về phiên bản cũ ngay lập tức. Nhớ tắt Auto-Sync trên UI để K8s tạm thời bỏ qua Git cho đến khi Dev sửa xong mã nguồn trên nhánh).*

**Bước 5: Canary Deployment & Blue-Green Strategy (Tùy chọn Nâng cao)**

Rolling Update là chiến lược mặc định của K8s nhưng không phải lúc nào cũng phù hợp. Với ứng dụng quan trọng, bạn cần kiểm soát chặt chẽ hơn.

1. **Canary Deployment (Thả chim Canary):** Chỉ cho một phần nhỏ traffic (ví dụ: 10%) đến phiên bản mới. Nếu ok thì mới tăng dần lên 100%.

Tạo 2 Deployment riêng biệt (stable và canary) cùng chia sẻ 1 Service:

```yaml
# deployment-stable.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-stable
spec:
  replicas: 9   # 90% traffic
  selector:
    matchLabels:
      app: myapp
      track: stable
  template:
    metadata:
      labels:
        app: myapp
        track: stable
    spec:
      containers:
      - name: app
        image: harbor.mycompany.com/myproject/myapp:v1.0  # Phiên bản cũ ổn định
---
# deployment-canary.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-canary
spec:
  replicas: 1   # 10% traffic
  selector:
    matchLabels:
      app: myapp
      track: canary
  template:
    metadata:
      labels:
        app: myapp
        track: canary
    spec:
      containers:
      - name: app
        image: harbor.mycompany.com/myproject/myapp:v2.0  # Phiên bản mới cần thử nghiệm
---
# service.yaml - Chỉ selector theo nhãn "app: myapp" (không có track)
apiVersion: v1
kind: Service
metadata:
  name: myapp-svc
spec:
  selector:
    app: myapp   # Match cả stable lẫn canary!
  ports:
  - port: 80
```
*(Giải thích: Service selector chỉ dùng nhãn `app: myapp`, không phân biệt `track`. Do đó, traffic sẽ được chia theo tỉ lệ số Pod: 9 stable : 1 canary = 90% : 10%. Nếu v2.0 không gây lỗi, tăng canary replicas lên 5, giảm stable xuống 5. Cuối cùng scale stable về 0 và canary lên 10)*.

2. **Blue-Green Deployment:** Chạy song song 2 môi trường (Blue = hiện tại, Green = mới). Chuyển traffic bằng cách sửa Service selector:

```bash
# Chuyển traffic từ Blue sang Green bằng 1 lệnh
kubectl patch svc myapp-svc -p '{"spec":{"selector":{"version":"green"}}}'

# Rollback về Blue nếu Green gặp lỗi
kubectl patch svc myapp-svc -p '{"spec":{"selector":{"version":"blue"}}}'
```
*(Giải thích: `kubectl patch` sửa trực tiếp Service mà không cần sửa file YAML. Traffic chuyển tức thì, không có downtime. Đây là chiến lược rollback nhanh nhất có thể)*.

**Bước 6: Observability & Monitoring Stack**

Bạn không thể quản lý cái bạn không đo lường được. Prometheus + Grafana là bộ đôi giám sát tiêu chuẩn trong hệ sinh thái Kubernetes.

1. **Cài đặt Prometheus + Grafana bằng Helm (Leader thực hiện):**

```bash
# Thêm Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Cài đặt Prometheus Stack (bao gồm Prometheus, Grafana, AlertManager)
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.adminPassword=admin123
```

2. **Truy cập Grafana Dashboard:**

```bash
# Bẻ khóa mạng Grafana
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
```
Mở trình duyệt `http://localhost:3000`. Đăng nhập với `admin / admin123`.

3. **Khám phá các Dashboard có sẵn:** Helm chart `kube-prometheus-stack` cài sẵn hàng chục dashboard:
   - **Kubernetes / Compute Resources / Namespace (Pods)**: Xem CPU/RAM của từng Pod.
   - **Kubernetes / Networking / Cluster**: Xem lưu lượng mạng.
   - **Node Exporter / Nodes**: Giám sát server vật lý.

4. **Tạo Alert Rule cơ bản (Tùy chọn):** Cấu hình Prometheus cảnh báo khi Pod restart quá nhiều:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: pod-restart-alert
  namespace: monitoring
  labels:
    release: monitoring  # Phải khớp với label của Prometheus instance
spec:
  groups:
  - name: pod-alerts
    rules:
    - alert: PodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total[15m]) * 60 * 15 > 3
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Pod {{ $labels.pod }} đang crash liên tục"
        description: "Pod {{ $labels.pod }} trong namespace {{ $labels.namespace }} đã restart hơn 3 lần trong 15 phút gần đây."
```
*(Giải thích: `expr` là PromQL (Prometheus Query Language) — ngôn ngữ truy vấn của Prometheus. `rate()` tính tỉ lệ tăng của metric trong khoảng thời gian. `for: 5m` chỉ kích hoạt alert nếu điều kiện đúng liên tục 5 phút — tránh false alarm)*.

5. **Chụp ảnh màn hình** Grafana Dashboard hiển thị metrics của ứng dụng nhóm và lưu vào thư mục `e2e-report/`.

**Bước 7: Tổng kết Kiến trúc & Vẽ Sơ đồ Hệ thống**

Đây là bước quan trọng nhất cho báo cáo tốt nghiệp.

1. **Vẽ Sơ đồ Kiến trúc End-to-End:** Sử dụng Mermaid (render trực tiếp trong Markdown trên GitHub) hoặc công cụ draw.io để vẽ sơ đồ luồng hoàn chỉnh:

```mermaid
flowchart LR
    A["\U0001f468\u200d\U0001f4bb Developer\ngit push"] --> B["\U0001f4e6 GitLab CI\nBuild & Test"]
    B --> C["\U0001f433 Kaniko\nBuild Image"]
    C --> D["\U0001f3e2 Harbor Registry\nStore & Scan"]
    D --> E["\U0001f916 CI Bot\nUpdate Manifest"]
    E --> F["\U0001f4c4 Manifest Repo\nYAML + Kustomize"]
    F --> G["\U0001f50d ArgoCD\nDetect & Sync"]
    G --> H["\u2699\ufe0f K8s Staging\nAuto Deploy"]
    H --> I{"\U0001f6a6 Approve Gate"}
    I -->|"S\u1ebfp b\u1ea5m n\u00fat"| J["\U0001f3ed K8s Production\nRolling Update"]
    J --> K["\U0001f4ca Prometheus\n+ Grafana"]
```

2. **Viết tài liệu SOP (Standard Operating Procedure):** Tạo file `SOP.md` mô tả quy trình vận hành cho những người tiếp quản sau bạn:

   - **Quy trình Deploy mới:** Các bước Developer cần làm khi muốn release phiên bản mới.
   - **Quy trình Rollback:** Hướng dẫn từng bước khi phát hiện lỗi trên Staging/Production.
   - **Quy trình Xử lý sự cố:** Khi nhận được cảnh báo từ Prometheus/Grafana, cần làm gì trước?
   - **Danh sách Credentials đang sử dụng:** Ghi chú các biến CI/CD, Token, Webhook URL (đánh dấu vị trí lưu, KHÔNG ghi giá trị thật).

3. **Checklist tự đánh giá cuối khóa:** Mỗi thành viên tự đánh giá các kỹ năng đã đạt được:

| Kỹ năng | Mức độ |
| :--- | :---: |
| Linux CLI & Bash Script | ⭐⭐⭐⭐⭐ |
| Docker Multi-stage Build | ⭐⭐⭐⭐⭐ |
| Kubernetes Manifest YAML | ⭐⭐⭐⭐⭐ |
| GitLab CI Pipeline | ⭐⭐⭐⭐⭐ |
| GitOps / ArgoCD | ⭐⭐⭐⭐⭐ |
| E2E CI/CD Flow | ⭐⭐⭐⭐⭐ |
| Monitoring (Prometheus/Grafana) | ⭐⭐⭐⭐⭐ |

**Bước 8: Báo cáo (Output đánh giá)**

> [!IMPORTANT]
> **Yêu cầu bắt buộc để qua bài (Capstone Demo):** Nhóm phải tiến hành Demo trực tiếp trên 1 project duy nhất. 
> Hành động Demo: Từ lúc gõ `git push` một dòng code thay đổi, quan sát hệ thống tự chạy qua luồng CI/CD và apply lên môi trường **Staging**. Sau đó thực hiện hành động Approve (bấm nút thủ công) để hệ thống promote phiên bản đó lên môi trường **Production**. Quá trình diễn ra hoàn toàn tự động, người thuyết trình không cần gõ lệnh `docker` hay `kubectl` nào.

- Viết một file `README.md` tổng kết kiến trúc luồng CI/CD cho project này (Kèm sơ đồ luồng hệ thống).
- Lưu lại video Demo hoặc tài liệu ghi chú báo cáo lỗi vào thư mục `e2e-report`.
- Tạo PR cuối cùng để kết thúc khóa đào tạo chuyên môn kỹ thuật. Chúc mừng các bạn chuẩn bị tốt nghiệp!
