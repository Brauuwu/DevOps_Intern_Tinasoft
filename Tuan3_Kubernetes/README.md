# Tuần 3: Kubernetes và YAML Manifest

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

## 📝 Nhiệm vụ thực hành

**Bước 1: Khởi tạo thư mục cá nhân & Workspace**
1. Tạo nhánh:
```bash
git checkout -b <ten-cua-ban>/tuan3-k8s
```
2. **BẮT BUỘC:** Tạo thư mục có tên bạn (ví dụ: `xuan/`) trong `Tuan3_Kubernetes`. Chuyển vào thư mục này để thực hành.
3. Khởi tạo K8s cục bộ bằng Minikube hoặc dùng cụm thật của nhóm:
```bash
minikube start
```

**Bước 2: Lý thuyết Kiến trúc & Thực hành lệnh `kubectl`**
1. **Kiến trúc Cluster (Lý thuyết cần nắm vững):**
   - **Control Plane (Master):** "Bộ não" quản lý toàn bộ cluster. Bao gồm API Server (tiếp nhận mọi lệnh kubectl), Scheduler (quyết định Pod chạy ở Node nào), và Controller Manager (đảm bảo số lượng Pod thực tế khớp với file YAML).
   - **etcd:** Cơ sở dữ liệu Key-Value cực kỳ an toàn, lưu trữ toàn bộ cấu hình và trạng thái của cluster.
   - **Node (Worker):** Máy chủ chạy workload thực tế. Chứa **Kubelet** (agent thường trực nhận lệnh từ Master để quản lý Pod) và Container Runtime (như containerd, Docker).
   
2. **Thực hành CLI:** Trước khi viết YAML, hãy làm quen với `kubectl`:
1. Xem thông tin cụm:
```bash
kubectl cluster-info
kubectl get nodes -o wide
```
2. Tạo namespace cá nhân:
```bash
kubectl create namespace <ten-cua-ban>-ns
```
3. Chạy một pod tạm nghiệm:
```bash
kubectl run my-nginx --image=nginx:alpine -n <ten-cua-ban>-ns
```
4. Xem log của Pod:
```bash
kubectl logs my-nginx -n <ten-cua-ban>-ns
```
5. Truy cập vào bên trong Pod:
```bash
kubectl exec -it my-nginx -n <ten-cua-ban>-ns -- /bin/sh
```
6. Mở port tạm thời để test:
```bash
kubectl port-forward pod/my-nginx 8080:80 -n <ten-cua-ban>-ns
```

**Bước 3: Xây dựng bộ Manifest hoàn chỉnh (Infrastructure as Code)**
Bây giờ, bạn cần khai báo các tài nguyên trên vào file YAML (thay vì gõ lệnh trực tiếp). Viết các file sau trong thư mục cá nhân:
1. `01-namespace-quota.yaml`: Khai báo `Namespace` và `ResourceQuota` cơ bản để giới hạn tổng lượng CPU/RAM được phép sử dụng trong namespace của bạn.
2. `02-storage.yaml`: Khai báo `PersistentVolume` (PV) và `PersistentVolumeClaim` (PVC) ở mức cơ bản để cấp phát ổ đĩa lưu trữ.
3. `03-config.yaml`: Bao gồm khai báo `ConfigMap` (chứa tên app, môi trường dev) và `Secret` (chứa password ảo mã hóa base64).
4. `04-deployment.yaml`: 
   - Viết Deployment quản lý 3 `replicas` sử dụng image ứng dụng web của bạn.
   - Bắt buộc khai báo **Resources (Requests & Limits)** để giới hạn CPU/RAM.
   - Bắt buộc khai báo **LivenessProbe** và **ReadinessProbe**.
   - Cấu hình mount ConfigMap, Secret và **Volume** (sử dụng PVC ở bước 2) vào bên trong môi trường Pod.
5. `05-service.yaml`: Tạo một Service kiểu `NodePort` hoặc `ClusterIP` để load balancer traffic cho 3 Pods.
6. `06-ingress.yaml`: Định tuyến HTTP hostname (vd: `app.local`) vào Service.

**Bước 4: Thực thi và Xử lý sự cố (Troubleshooting)**
1. Áp dụng tuần tự các manifest vào cluster:
```bash
kubectl apply -f .
```
2. Kiểm tra trạng thái:
```bash
kubectl get all -n <ten-cua-ban>-ns
```
3. **Kịch bản Lỗi:** Cố tình sửa file deployment thành một image không tồn tại (vd: `nginx:999`). Apply lại. Quan sát lỗi `ImagePullBackOff` qua lệnh:
```bash
kubectl describe pod <ten-pod> -n <ten-cua-ban>-ns
```
Sau đó sửa lại cho đúng.
4. Xuất kết quả cuối cùng:
```bash
kubectl get all -n <ten-cua-ban>-ns -o wide > k8s-status.txt
```

> [!TIP]
> **Tương tác Mạng (Host - K8s Cluster):** 
> - Nếu Service của bạn là `NodePort`, bạn có thể truy cập ứng dụng từ trình duyệt trên **máy thật** (Windows/Mac) bằng địa chỉ `http://<IP-may-ao-Worker>:<Port-từ-30000-32767>`.
> - Cách nhanh nhất để debug từ máy thật thẳng vào Pod/Service trong mạng K8s là dùng lệnh: `kubectl port-forward svc/<ten-service> 8080:80 -n <ten-cua-ban>-ns --address 0.0.0.0`. Sau đó truy cập `http://<IP-may-ao>:8080` trên máy thật.

**Bước 5: Nộp bài (Output đánh giá)**

> [!IMPORTANT]
> **Yêu cầu bắt buộc để qua bài:** Bạn phải viết được bộ manifest tối thiểu gồm Deployment + Service + Ingress cho 1 app cụ thể (có thể lấy app ở phần Sample_WebApps), tự apply thành công lên cluster test và phải truy cập được ứng dụng từ trình duyệt bên ngoài.

- Commit tất cả các file YAML và file text kết quả `k8s-status.txt` vào thư mục cá nhân.
- Tạo Pull Request để các bạn khác check chéo lỗi thụt lề YAML.
