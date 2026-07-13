# Tuần 5: GitOps và ArgoCD (Deep Dive)

*Điều hướng nhanh:* [⬅️ Tuần 4: GitLab CI](../Tuan4_GitLabCI/README.md) | [🏠 Trang chủ Repo](../README.md) | [Tuần 6: CI/CD End-to-End ➡️](../Tuan6_CICD_EndToEnd/README.md)

**Thời gian:** 27/07 - 31/07

## 🎯 Mục tiêu (Checklist Phase 5)
Thay đổi cách nghĩ về deploy: không push trực tiếp lên cluster, mà khai báo trạng thái mong muốn trong Git và để công cụ tự đồng bộ.

- **Lý thuyết:** Nắm vững khái niệm GitOps, phân biệt rõ sự khác biệt giữa CI/CD truyền thống (Push-based) và GitOps (Pull-based deploy).
- **Cấu trúc Git:** Hiểu nguyên lý phân tách kho lưu trữ: App Repo (chứa Source Code) và Manifest/Config Repo (chứa cấu hình YAML).
- **ArgoCD Cơ bản:** Cài đặt, nắm vững khái niệm Application, cấu hình Sync policy (Manual vs Auto).
- **Vận hành:** Theo dõi trạng thái đồng bộ (sync), xử lý lỗi và thực hiện Rollback thông qua giao diện ArgoCD.
- **Nâng cao (Tùy chọn):** Tìm hiểu và cấu hình ArgoCD Image Updater — công cụ tự động cập nhật tag image mới vào Git.

## 📚 Lý thuyết Cốt lõi (Under the Hood)
1. **Tại sao ra đời GitOps (Pull-based vs Push-based)?**
   - **Kiểu cũ (Push-based CI/CD):** GitLab CI chạy lệnh `kubectl apply -f .` để đẩy code vào K8s. Nghĩa là máy chủ GitLab phải có "chìa khóa" (kubeconfig) của K8s. Đây là rủi ro bảo mật khổng lồ. Chưa kể nếu có người lén lút sửa cluster bằng tay (`kubectl edit`), GitLab CI sẽ không hề hay biết, dẫn đến sai lệch cấu hình (Configuration Drift).
   - **Kiểu mới (GitOps / Pull-based):** Không ai được chọc vào cụm K8s từ bên ngoài. Có một phần mềm cài ngay BÊN TRONG K8s (như ArgoCD) đứng làm gián điệp. ArgoCD liên tục chĩa ống nhòm ra ngoài nhìn vào Git Repository. Hễ thấy trên Git có YAML mới, ArgoCD tự kéo (Pull) về và áp dụng lên K8s. An toàn tuyệt đối, vì kết nối là chiều từ trong cụm ra ngoài.
2. **Khai báo là nguồn chân lý duy nhất (Single Source of Truth):**
   - Trong GitOps, Git không chỉ là nơi chứa code, mà nó là "Chúa Tể". Mọi trạng thái mong muốn (Desired State) của hệ thống nằm trên Git.
   - Nếu bạn dùng tay gõ `kubectl delete pod` hoặc scale số pod, ArgoCD sẽ phát hiện trạng thái thực tế (Live State) không giống trạng thái mong muốn (Git State) và báo lỗi **Out of Sync**. Nếu bật tính năng `Self Heal`, ArgoCD tự động tạo lại pod để y xì như Git. Mọi can thiệp tay chân của con người đều bị vô hiệu hóa!
3. **Phân tách 2 Repo:**
   - Bắt buộc phải có 2 Repo. 1 cái là **App Repo** (Chứa mã nguồn Java/Node, CI chạy để sinh ra Docker Image). 1 cái là **Manifest Repo** (Chứa toàn file YAML). Nếu gộp chung, mỗi lần CI bot commit thay đổi tag image, CI lại kích hoạt một vòng lặp build code liên hoàn vô tận (Infinite Loop).

## 📝 Nhiệm vụ thực hành chuyên sâu

**Bước 1: Chuẩn bị Manifest Repo cá nhân**
1. Nhánh làm việc: `git checkout -b <ten-cua-ban>/tuan5-gitops`
2. **BẮT BUỘC:** Tạo thư mục cá nhân (vd: `hoang-manifest/`) trong `Tuan5_GitOps_ArgoCD`.
3. Copy toàn bộ các file YAML chuẩn xác ở Tuần 3 (Deployment, Service, ConfigMap) vào đây. Đây sẽ là Manifest Repo giả lập.

**Bước 2: Cài đặt ArgoCD và khám phá Kubernetes CRD**
Khi leader chạy script cài đặt ArgoCD, bản chất là đang cài đặt các **CRD (Custom Resource Definition)**. K8s mặc định chỉ hiểu Pod, Service... Nhưng nhờ cài ArgoCD, K8s được dạy thêm từ vựng mới tên là `Application`.
Người Leader cài đặt:
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

**Cẩm nang Lệnh Truy cập giao diện ArgoCD:**
Mặc định ArgoCD không mở port ra ngoài. Bạn cần bẻ khóa mạng (port-forward) và lấy mật khẩu mặc định (được mã hóa trong Secret).
1. Bẻ khóa mạng giao diện UI:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
*(Lưu ý: ArgoCD chạy trên cổng HTTPS (443) nên khi truy cập `https://localhost:8080` trình duyệt có thể cảnh báo "Not Secure", hãy bấm Advanced -> Proceed).*

2. Lấy mật khẩu đăng nhập tài khoản `admin`:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
*(Giải thích: Lệnh `-o jsonpath` lọc lấy chuỗi mã hóa. Dấu `|` (pipe) chuyển chuỗi đó sang lệnh `base64 -d` để giải mã (decode) thành text có thể đọc được).*

**Bước 3: Khai báo ArgoCD Application**
Thay vì gõ lệnh hay bấm giao diện GUI, GitOps chuẩn yêu cầu phải tạo file `Application` bằng code (ArgoCD App of Apps pattern). Tạo file `my-argocd-app.yaml` nằm BÊN NGOÀI folder manifest của bạn:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-cua-hoang # Đổi tên
  namespace: argocd   # App quản lý thì để ở namespace argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/YourOrg/GitHub_Lab.git' # Link repo chung
    path: 'Tuan5_GitOps_ArgoCD/hoang-manifest' # Trỏ đúng thư mục con
    targetRevision: main # Theo dõi nhánh nào
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: hoang-ns # Cài ứng dụng thực tế vào namespace nào
  syncPolicy:
    automated:
      prune: true     # Xóa tài nguyên cũ nếu trên Git không còn
      selfHeal: true  # Tự chống lại can thiệp thủ công (Drift prevention)
```
Apply file này vào cluster `kubectl apply -f my-argocd-app.yaml`.

**Bước 4: Chaos Engineering (Phá hoại & Tự phục hồi)**
Chúng ta sẽ test sự bá đạo của ArgoCD.
1. **Kịch bản Drift:** Mở terminal gõ `kubectl edit deployment <ten-app> -n hoang-ns`. Cố tình thay đổi image thành `nginx:alpine`. Quan sát giao diện ArgoCD. Trạng thái sẽ vàng khè (`Out of Sync`), và ngay lặp tức (nhờ có SelfHeal), nó đè cấu hình cũ trên Git xuống lại. Bạn không thể phá được.
2. **Kịch bản Auto-Sync:** Sửa số `replicas: 5` ở file Deployment trong thư mục `hoang-manifest` và `git push`. Không cần gõ lệnh gì thêm, vài chục giây sau, 5 Pod mới sẽ xuất hiện trên K8s.
3. **Kịch bản Mất kết nối:** Cố tình đưa link `repoURL` sai. ArgoCD sẽ báo lỗi `Unknown` hoặc `Degraded`.

**Bước 5: ArgoCD Multi-Environment (Kustomize Overlays)**

Trong thực tế, bạn không thể dùng cùng một file YAML cho cả Staging và Production. Kustomize giúp bạn tái sử dụng cấu hình cơ sở và chỉ ghi đè những gì khác biệt.

1. **Tạo cấu trúc thư mục Kustomize:**

```bash
mkdir -p kustomize/{base,overlays/staging,overlays/production}
```

Cấu trúc mục tiêu:
```
kustomize/
├── base/                  # Cấu hình chung cho mọi môi trường
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── overlays/
│   ├── staging/           # Chỉ ghi đè những gì khác biệt cho staging
│   │   ├── kustomization.yaml
│   │   └── replica-patch.yaml
│   └── production/        # Ghi đè cho production
│       ├── kustomization.yaml
│       └── replica-patch.yaml
```

2. **Viết file `base/kustomization.yaml`:**

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
```

Copy file `deployment.yaml` và `service.yaml` của bạn vào `base/`.

3. **Viết file `overlays/staging/kustomization.yaml`:**

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base     # Kế thừa từ base
namePrefix: staging-  # Thêm tiền tố tên cho mọi resource
namespace: staging-ns
patches:
  - path: replica-patch.yaml
```

File `overlays/staging/replica-patch.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app   # Phải khớp tên trong base
spec:
  replicas: 2    # Staging chỉ cần 2 replica
```

4. **Viết file `overlays/production/kustomization.yaml`:**

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
namePrefix: prod-
namespace: production-ns
patches:
  - path: replica-patch.yaml
```

File `overlays/production/replica-patch.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 5    # Production cần 5 replica
```

5. **Kiểm tra kết quả Kustomize trước khi apply:**

```bash
# Preview YAML sẽ được sinh ra cho Staging
kubectl kustomize overlays/staging/

# Preview cho Production
kubectl kustomize overlays/production/
```
*(Giải thích: `kubectl kustomize` chỉ in ra màn hình YAML đã được merge mà không apply. Bạn sẽ thấy Staging có prefix `staging-` và 2 replica, còn Production có prefix `prod-` và 5 replica. Cùng base code nhưng khác cấu hình!)*

6. **Tạo 2 ArgoCD Application cho 2 môi trường:** Tạo 2 file Application YAML, mỗi file trỏ `spec.source.path` tới `overlays/staging` hoặc `overlays/production`. Apply cả hai lên cluster và quan sát giao diện ArgoCD hiển thị 2 Application độc lập.

**Bước 6: ArgoCD Notifications & Health Checks**

ArgoCD sẽ không có nghĩa nếu không ai biết khi nào nó sync thành công hay thất bại.

1. **Cài đặt ArgoCD Notifications (bởi Leader):**

```bash
kubectl apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/manifests/install.yaml
```

2. **Cấu hình gửi thông báo Webhook khi Sync thành công/thất bại:**

Tạo ConfigMap chứa cấu hình notification:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
  namespace: argocd
data:
  service.webhook.discord: |
    url: $discord-webhook-url
    headers:
    - name: Content-Type
      value: application/json
  template.app-sync-succeeded: |
    webhook:
      discord:
        method: POST
        body: |
          {"content": "\u2705 ArgoCD: App **{{.app.metadata.name}}** synced successfully!\nRevision: {{.app.status.sync.revision}}"}
  template.app-sync-failed: |
    webhook:
      discord:
        method: POST
        body: |
          {"content": "\u274c ArgoCD: App **{{.app.metadata.name}}** sync FAILED!\nStatus: {{.app.status.operationState.phase}}"}
  trigger.on-sync-succeeded: |
    - when: app.status.operationState.phase in ['Succeeded']
      send: [app-sync-succeeded]
  trigger.on-sync-failed: |
    - when: app.status.operationState.phase in ['Error', 'Failed']
      send: [app-sync-failed]
```
*(Giải thích: `trigger` định nghĩa điều kiện kích hoạt. `template` định nghĩa nội dung gửi đi. Cú pháp `{{.app.metadata.name}}` là Go Template dùng để lấy thông tin động từ Application)*.

3. **Thực hành ArgoCD CLI:**

Thêm CLI vào kỹ năng của bạn thay vì chỉ dùng giao diện GUI:
```bash
# Đăng nhập CLI
argocd login localhost:8080 --username admin --password <mat-khau>

# Xem danh sách Application
argocd app list

# Xem trạng thái chi tiết một app
argocd app get app-cua-ban

# Ép sync thủ công
argocd app sync app-cua-ban

# Xem lịch sử deploy
argocd app history app-cua-ban
```
*(Giải thích: CLI hữu ích hơn GUI khi bạn cần tự động hóa hoặc debug nhanh. Lệnh `argocd app get` hiển thị chi tiết trạng thái từng resource (Pod, Service, Ingress) mà GUI không thể hiện hết)*.

4. **Custom Health Check:** Tìm hiểu cách ArgoCD đánh giá "sức khỏe" của resource. Mặc định ArgoCD biết Deployment healthy khi tất cả Pod đang Running. Tuy nhiên, với CRD tùy chỉnh, bạn có thể cần định nghĩa Health Check riêng bằng Lua script.

**Bước 7: App of Apps Pattern & Declarative Setup (Tùy chọn Nâng cao)**

Khi số lượng Application tăng lên (5-10 app), việc quản lý bằng tay trở nên bất khả thi. **App of Apps** giải quyết vấn đề này.

1. **Khái niệm:** Tạo một Application "cha" (Root App). Application cha này trỏ tới một thư mục Git chứa nhiều file Application YAML "con". Khi ArgoCD sync Root App, nó sẽ tự động tạo và quản lý tất cả Application con.

2. **Tạo thư mục `argocd-apps/`:** Chứa các file Application con:

```
argocd-apps/
├── app-staging.yaml      # Application cho Staging
├── app-production.yaml   # Application cho Production
└── app-monitoring.yaml   # Application cho Monitoring stack
```

3. **Tạo Root Application:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/YourOrg/GitHub_Lab.git'
    path: 'Tuan5_GitOps_ArgoCD/argocd-apps'   # Trỏ tới thư mục chứa các Application con
    targetRevision: main
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```
*(Giải thích: Khi bạn thêm một file Application YAML mới vào `argocd-apps/` và push lên Git, Root App sẽ tự động detect và tạo Application mới trên ArgoCD. Muốn xóa app? Chỉ cần xóa file YAML khỏi Git. Mọi thứ được quản lý bằng Git, 100% GitOps)*.

4. **Khai báo Repository Credentials bằng YAML:**

Thay vì nhập tay trên giao diện ArgoCD, hãy khai báo Secret chứa thông tin xác thực repo:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/YourOrg/GitHub_Lab.git
  username: git
  password: <personal-access-token>
```

> [!WARNING]
> TUYỆT ĐỐI KHÔNG commit file Secret chứa token/password lên Git! Hãy apply trực tiếp bằng `kubectl apply -f` hoặc dùng Sealed Secrets/SOPS để mã hóa.

**Bước 8: Nộp bài (Output đánh giá)**

> [!IMPORTANT]
> **Yêu cầu bắt buộc để qua bài:** Khởi tạo thành công 1 `Application` trên ArgoCD trỏ tới nhánh Manifest repository cá nhân. Tiến hành sửa đổi (vd: thay đổi tag image, số lượng replica) trong file YAML trên GitHub, và chụp màn hình chứng minh ArgoCD đã tự động dò tìm (sync) và apply thay đổi đó lên cluster thực tế.

- Chụp ảnh màn hình quá trình "Chaos Engineering" thành công (Hiển thị các thông báo Sync của ArgoCD).
- Lưu các cấu hình Application YAML vào thư mục, tạo Pull Request để review.
