# Tuần 3: Kubernetes và YAML Manifest (Deep Dive)

*Điều hướng nhanh:* [⬅️ Tuần 2: Docker](../Tuan2_Docker_Harbor/README.md) | [🏠 Trang chủ Repo](../README.md) | [Tuần 4: GitLab CI ➡️](../Tuan4_GitLabCI/README.md)

**Thời gian:** 13/07 - 17/07

## 🎯 Mục tiêu (Checklist Phase 3)
Hiểu rõ các resource cốt lõi của Kubernetes trước khi học GitOps, vì ArgoCD chỉ là công cụ deploy các resource này theo cách tự động.

- **Kiến trúc cluster:** Nắm được khái niệm Control Plane, Node, Kubelet, etcd (mức hiểu, không cần tự build cluster).
- **Workloads:** Khái niệm và cách dùng Pod, ReplicaSet, Deployment.
- **Networking:** Cấu hình Service (ClusterIP, NodePort, LoadBalancer) và Ingress.
- **Configuration:** Sử dụng ConfigMap & Secret.
- **Quản lý tài nguyên:** Hiểu khái niệm Namespace, giới hạn tài nguyên bằng Resource Quota cơ bản.
- **Lưu trữ:** Sử dụng Volume & PersistentVolume (mức cơ bản).
- **CLI (`kubectl`):** Sử dụng thành thạo các lệnh apply, get, describe, logs, exec.
- **Thực hành:** Tự tay viết và apply manifest YAML hoàn toàn thủ công.

## 📚 Lý thuyết Cốt lõi (Under the Hood)
1. **Kiến trúc Kubernetes (Control Plane vs Worker Nodes):**
   - **Control Plane (Master Node):** Chứa các component nòng cốt. `kube-apiserver` là cửa ngõ duy nhất tiếp nhận mọi yêu cầu REST (bao gồm lệnh `kubectl`). `kube-scheduler` quyết định Pod sẽ chạy ở Node nào dựa trên tài nguyên. `kube-controller-manager` chạy các vòng lặp (Control Loop) liên tục so sánh trạng thái hiện tại (Current State) với trạng thái mong muốn (Desired State trong file YAML) để điều chỉnh hệ thống.
   - **etcd:** Cơ sở dữ liệu phân tán lưu trữ toàn bộ Cluster State dưới dạng Key-Value. Nếu etcd sập, toàn bộ K8s mất khả năng nhận diện hệ thống.
   - **Worker Node:** Chạy các payload thực tế. `kubelet` là agent giao tiếp với Master và ra lệnh cho Container Runtime (Docker/containerd) khởi tạo Pod.
2. **Quy trình sống của một Pod (Pod Lifecycle):**
   - Khi bạn apply Deployment, Deployment tạo ra ReplicaSet. ReplicaSet yêu cầu API Server tạo Pod. Pod lúc này ở trạng thái `Pending` do chưa có Node nào nhận. Scheduler gán Pod vào 1 Node. `kubelet` trên Node đó kéo image và chạy container. Lúc này Pod chuyển sang `Running`.
3. **Requests, Limits và QoS (Quality of Service):**
   - `requests`: Lượng CPU/RAM tối thiểu K8s bảo đảm cấp cho Pod. Dùng để Scheduler xếp chỗ.
   - `limits`: Lượng CPU/RAM tối đa Pod được phép dùng. Vượt RAM limit, container bị OOMKilled. Vượt CPU limit, container bị Throttling (chạy chậm đi chứ không bị giết).

## 📝 Nhiệm vụ thực hành chuyên sâu

**Bước 1: Khởi tạo thư mục cá nhân & Workspace**
1. Nhánh làm việc: `git checkout -b <ten-cua-ban>/tuan3-k8s`
2. **BẮT BUỘC:** Tạo thư mục có tên bạn (ví dụ: `xuan/`) trong `Tuan3_Kubernetes`. Chuyển vào thư mục này để thực hành.
3. Khởi tạo K8s cục bộ (minikube) hoặc truy cập cluster của nhóm.

**Bước 2: Thực hành lệnh `kubectl` (Imperative vs Declarative)**
Thay vì tạo tài nguyên ngay bằng YAML (Declarative), hãy thử cách gõ lệnh trực tiếp (Imperative) để debug:
```bash
# Tạo nhanh một Pod thử nghiệm
kubectl run my-debug-pod --image=nginx:alpine
# Lấy file YAML nháp từ một tài nguyên có sẵn
kubectl get pod my-debug-pod -o yaml > draft.yaml
# Truy cập trực tiếp vào Pod để xem lỗi mạng
kubectl exec -it my-debug-pod -- sh
```

**Bước 3: Xây dựng bộ Manifest hoàn chỉnh (Infrastructure as Code)**
Bạn cần dịch mọi cấu hình thành mã YAML. Viết các file sau trong thư mục cá nhân:
1. `01-namespace-quota.yaml`: Khai báo `Namespace` và `ResourceQuota` cơ bản để giới hạn tổng lượng CPU/RAM (Ví dụ: Giới hạn Namespace này chỉ dùng tối đa 2CPU và 4GB RAM).
2. `02-storage.yaml`: Khai báo `PersistentVolume` (PV) và `PersistentVolumeClaim` (PVC) ở mức cơ bản để cấp phát ổ đĩa lưu trữ (Tạo PersistentVolume giúp dữ liệu không mất đi khi Pod chết).
3. `03-config.yaml`: Bao gồm khai báo `ConfigMap` (chứa tên app, môi trường dev) và `Secret` (chứa password ảo mã hóa base64 - *Lưu ý Secret trong K8s chỉ là base64 encoded, không mã hóa hoàn toàn an toàn*).
4. `04-deployment.yaml`: 
   - Viết Deployment quản lý 3 `replicas`.
   - Bắt buộc khai báo **Resources (Requests & Limits)** để tránh phá hoại node (Noisy Neighbor).
   - Bắt buộc khai báo **LivenessProbe** (để K8s tự restart Pod nếu app treo) và **ReadinessProbe** (để K8s dừng gửi traffic nếu app chưa khởi động xong).
   - Cấu hình mount ConfigMap, Secret và **Volume** (sử dụng PVC ở bước 2) vào bên trong môi trường Pod.
5. `05-service.yaml`: Tạo một Service kiểu `NodePort` hoặc `ClusterIP` để load balancer traffic cho các Pods có nhãn tương ứng.
6. `06-ingress.yaml`: Định tuyến HTTP hostname (vd: `app.local`) vào Service thay vì dùng NodePort.

**Bước 4: Thực thi và Xử lý sự cố (Troubleshooting)**
1. Áp dụng tuần tự các manifest vào cluster:
```bash
kubectl apply -f .
```
*(Giải thích cờ lệnh: `-f .` (file) mang ý nghĩa đọc toàn bộ các file `.yaml` trong thư mục hiện tại và tạo tài nguyên trên Cluster).*

2. Theo dõi tiến trình khởi tạo Pod theo thời gian thực (Real-time watch):
```bash
kubectl get pods -w
```
*(Giải thích cờ lệnh: `-w` (watch) giữ Terminal không bị tắt, tự động in ra màn hình mỗi khi trạng thái Pod thay đổi: Pending -> ContainerCreating -> Running).*

3. "Bẻ khóa mạng" để test Web ngay lập tức từ máy thật:
```bash
kubectl port-forward svc/<ten-service> 8080:80
```
*(Giải thích: Mượn đường hầm (tunnel) nối cổng 80 của Service bên trong cụm K8s ra cổng 8080 trên trình duyệt máy tính của bạn. Rất tiện để debug).*

4. **Kịch bản Lỗi 1 (ImagePullBackOff):** Cố tình sửa file deployment thành image không tồn tại (`nginx:999`). Apply lại và quan sát trạng thái.
5. **Kịch bản Lỗi 2 (CrashLoopBackOff):** Pod chết liên tục. Dùng lệnh `kubectl logs <ten-pod> -f` (`-f` để bám theo log) hoặc `kubectl logs <ten-pod> --previous` để xem log của container vừa sập lúc nãy.

## 🛠️ Cẩm nang xử lý lỗi K8s
- Khi Pod bị `Pending`: Hãy chạy `kubectl describe pod <tên-pod>`. Lỗi thường nằm ở cuối (Events). Dấu hiệu phổ biến là "Insufficient CPU" (không đủ CPU trên Node để đáp ứng `requests`).
- Khi Pod `Running` nhưng không truy cập được: Kiểm tra xem Lable Selector trong file `Service` có khớp chính xác 100% với nhãn `labels` của Pod không. Bạn có thể dùng `kubectl get endpoints` để kiểm tra Service có tìm thấy IP của Pod chưa.

**Bước 5: Horizontal Pod Autoscaler (HPA) — Tự động Scale Ứng dụng**

Một trong những sức mạnh lớn nhất của Kubernetes là khả năng tự động tăng/giảm số lượng Pod dựa trên mức sử dụng tài nguyên thực tế.

1. **Điều kiện tiên quyết:** Đảm bảo Metrics Server đã được cài đặt trong cluster (minikube thường có sẵn):

```bash
# Kiểm tra Metrics Server
kubectl top nodes
kubectl top pods
```
*(Nếu lệnh trên báo lỗi "Metrics API not available", hãy cài đặt: `minikube addons enable metrics-server` hoặc nhờ Leader cài)*.

2. **Viết file `07-hpa.yaml`:** HPA tự động tăng số Pod khi CPU vượt ngưỡng:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app  # Tên Deployment của bạn ở bước 4
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50  # Khi CPU trung bình vượt 50%, HPA sẽ scale up
```
*(Giải thích: `minReplicas` và `maxReplicas` quy định biên độ scale. `averageUtilization: 50` nghĩa là khi mức sử dụng CPU trung bình của tất cả Pod vượt 50% của `requests`, HPA sẽ tạo thêm Pod. Khi tải giảm, nó tự giảm Pod về `minReplicas`)*.

3. **Stress Test — Đánh tải để xem HPA hoạt động:**

```bash
# Apply HPA
kubectl apply -f 07-hpa.yaml

# Mở 1 terminal theo dõi HPA real-time
kubectl get hpa -w

# Mở terminal khác, tạo tải giả bằng vòng lặp vô hạn
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c \
    "while sleep 0.01; do wget -q -O- http://<ten-service>; done"
```
*(Giải thích: Lệnh `kubectl run` khởi tạo một Pod tạm (flag `--rm` tự xóa khi thoát) gọi HTTP liên tục vào Service. Quan sát terminal HPA: cột `TARGETS` sẽ tăng dần, và cột `REPLICAS` sẽ nhảy từ 2 lên 3, 4, 5... Dừng vòng lặp (Ctrl+C), chờ 5 phút và xem HPA tự scale xuống)*.

**Bước 6: Network Policies & Pod Security**

Mặc định, tất cả Pod trong K8s có thể giao tiếp với nhau không giới hạn — điều này cực kỳ nguy hiểm trong môi trường production.

1. **Viết file `08-network-policy.yaml`:** Chỉ cho phép traffic từ Pod có nhãn `role: frontend` truy cập vào Pod có nhãn `role: backend`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
spec:
  podSelector:
    matchLabels:
      role: backend      # Áp dụng cho các Pod có nhãn này
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend  # Chỉ chấp nhận traffic từ Pod mang nhãn này
    ports:
    - protocol: TCP
      port: 80
```
*(Giải thích: `podSelector` chọn Pod mục tiêu. `ingress.from` định nghĩa nguồn được phép gửi traffic đến. Bất kỳ Pod nào không có nhãn `role: frontend` sẽ bị chặn hoàn toàn. Đây là Zero Trust Networking)*.

> [!TIP]
> NetworkPolicy chỉ hoạt động nếu cluster sử dụng CNI hỗ trợ (ví dụ: Calico, Cilium). Minikube mặc định dùng `kindnet` không hỗ trợ NetworkPolicy. Hãy kích hoạt Calico: `minikube start --cni=calico`.

2. **Viết file `09-security-context.yaml`:** Cấu hình SecurityContext cho Pod để chạy với quyền hạn chế nhất:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      securityContext:
        runAsNonRoot: true       # Bắt buộc không chạy bằng root
        runAsUser: 1000          # Chạy bằng user ID 1000
        fsGroup: 1000            # Group sở hữu file trên Volume
      containers:
      - name: app
        image: nginx:alpine
        securityContext:
          allowPrivilegeEscalation: false  # Không cho phép leo thang đặc quyền
          readOnlyRootFilesystem: true     # Hệ thống file chỉ đọc
          capabilities:
            drop:
              - ALL                        # Xóa toàn bộ Linux Capabilities
        volumeMounts:
        - name: tmp
          mountPath: /tmp                  # Chỉ cho phép ghi vào /tmp
      volumes:
      - name: tmp
        emptyDir: {}
```
*(Giải thích: `readOnlyRootFilesystem` ngăn malware ghi file vào container. `drop: ALL` capabilities là xu hướng bảo mật hiện đại — chỉ cấp những quyền cần thiết. Volume `emptyDir` cung cấp thư mục tạm để ứng dụng ghi cache/log)*.

**Bước 7: Helm Chart Cơ bản (Tùy chọn Nâng cao)**

Helm là "Package Manager" của Kubernetes — giống `apt` của Ubuntu hay `npm` của Node. Thay vì viết 6 file YAML riêng lẻ, bạn gói gọn chúng vào một Helm Chart.

1. **Khởi tạo Helm Chart:**

```bash
# Cài Helm (nếu chưa có)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Tạo Chart mới
helm create my-app-chart
```
*(Lệnh `helm create` sinh ra một thư mục cấu trúc chuẩn chứa sẵn các template)*.

2. **Tìm hiểu cấu trúc thư mục:**

```
my-app-chart/
├── Chart.yaml          # Metadata của chart (tên, phiên bản)
├── values.yaml         # Giá trị mặc định (có thể override khi install)
├── templates/          # Chứa các file YAML template
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
└── .helmignore
```

3. **Tùy chỉnh `values.yaml`:** Sửa file `values.yaml` để dùng image của bạn:

```yaml
replicaCount: 3
image:
  repository: harbor.mycompany.com/myproject/myapp
  tag: "v1.0"
  pullPolicy: IfNotPresent
service:
  type: NodePort
  port: 80
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 250m
    memory: 256Mi
```

4. **Cài đặt, Nâng cấp và Rollback:**

```bash
# Cài đặt chart lên cluster
helm install my-release ./my-app-chart

# Xem trạng thái release
helm list
helm status my-release

# Nâng cấp (thay đổi values và apply)
helm upgrade my-release ./my-app-chart --set replicaCount=5

# Rollback về phiên bản trước
helm rollback my-release 1

# Gỡ cài đặt
helm uninstall my-release
```
*(Giải thích: `install` tạo release mới. `upgrade` cập nhật cấu hình (mỗi lần upgrade tạo revision mới). `rollback` lùi về revision cũ. Flag `--set` cho phép override giá trị trong `values.yaml` từ dòng lệnh mà không cần sửa file. Đây là nền tảng cho ArgoCD Helm deployment ở Tuần 5)*.

**Bước 8: Nộp bài (Output đánh giá)**

> [!IMPORTANT]
> **Yêu cầu bắt buộc để qua bài:** Bạn phải viết được bộ manifest tối thiểu gồm Deployment + Service + Ingress cho 1 app cụ thể (có thể lấy app ở phần Sample_WebApps hoặc app bạn vừa containerize ở tuần 2), tự apply thành công lên cluster test và phải truy cập được ứng dụng từ trình duyệt bên ngoài thông qua địa chỉ của Ingress/NodePort.

- Commit tất cả các file YAML và file text kết quả `k8s-status.txt` (output của lệnh `kubectl get all -o wide`) vào thư mục cá nhân.
- Tạo Pull Request để team kiểm tra kỹ năng cấu trúc file YAML.
