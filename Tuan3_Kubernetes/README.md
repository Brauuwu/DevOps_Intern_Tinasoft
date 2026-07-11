# Tuần 3: Kubernetes và YAML Manifest

**Thời gian:** 13/07 - 17/07

## 🎯 Mục tiêu
- Hiểu kiến trúc Master - Worker của cụm Kubernetes (K8s).
- Nắm vững lifecycle của Pod, cơ chế tự phục hồi (Self-healing), lập lịch (Scheduling).
- Viết thành thạo file YAML cho các tài nguyên: Namespace, Pod, Deployment, Service, Ingress, ConfigMap, Secret.
- Thành thạo công cụ dòng lệnh `kubectl` để debug và vận hành cụm.

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

**Bước 2: Thực hành lệnh `kubectl`**
Trước khi viết YAML, hãy làm quen với `kubectl` thông qua CLI:
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
Bây giờ, bạn cần khai báo các tài nguyên trên vào file YAML (thay vì gõ lệnh trực tiếp). Viết 4 file sau trong thư mục cá nhân:
1. `01-config.yaml`: Bao gồm khai báo `Namespace`, `ConfigMap` (chứa tên app, môi trường dev), `Secret` (chứa password ảo mã hóa base64).
2. `02-deployment.yaml`: 
   - Viết Deployment quản lý 3 `replicas` sử dụng image backend của bạn.
   - Bắt buộc khai báo **Resources (Requests & Limits)** để giới hạn CPU/RAM.
   - Bắt buộc khai báo **LivenessProbe** và **ReadinessProbe**.
   - Cấu hình mount ConfigMap và Secret vào môi trường (env).
3. `03-service.yaml`: Tạo một Service kiểu `NodePort` hoặc `ClusterIP` để load balancer cho 3 Pods.
4. `04-ingress.yaml` (Tùy chọn/Nâng cao): Định tuyến HTTP hostname (vd: `app.local`) vào Service.

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

**Bước 5: Nộp bài**
- Commit 4 file YAML và file text kết quả `k8s-status.txt` vào thư mục cá nhân.
- Tạo Pull Request để các bạn khác check chéo lỗi thụt lề YAML.
