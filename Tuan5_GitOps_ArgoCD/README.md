# Tuần 5: GitOps và ArgoCD

**Thời gian:** 27/07 - 31/07

## 🎯 Mục tiêu (Checklist Phase 5)
Thay đổi cách nghĩ về deploy: không push trực tiếp lên cluster, mà khai báo trạng thái mong muốn trong Git và để công cụ tự đồng bộ.

- **Lý thuyết:** Nắm vững khái niệm GitOps, phân biệt rõ sự khác biệt giữa CI/CD truyền thống (Push-based) và GitOps (Pull-based deploy).
- **Cấu trúc Git:** Hiểu nguyên lý phân tách kho lưu trữ: App Repo (chứa Source Code) và Manifest/Config Repo (chứa cấu hình YAML).
- **ArgoCD Cơ bản:** Cài đặt, nắm vững khái niệm Application, cấu hình Sync policy (Manual vs Auto).
- **Vận hành:** Theo dõi trạng thái đồng bộ (sync), xử lý lỗi và thực hiện Rollback thông qua giao diện ArgoCD.
- **Nâng cao (Tùy chọn):** Tìm hiểu và cấu hình ArgoCD Image Updater — công cụ tự động cập nhật tag image mới vào Git.

## 📝 Nhiệm vụ thực hành

**Bước 1: Chuẩn bị thư mục cá nhân**
1. Nhánh làm việc:
```bash
git checkout -b <ten-cua-ban>/tuan5-gitops
```
2. **BẮT BUỘC:** Tạo thư mục cá nhân (vd: `hieu/`) trong `Tuan5_GitOps_ArgoCD`.

**Bước 2: Cài đặt và làm quen ArgoCD CLI/Web**
- Người Leader cài đặt ArgoCD lên cluster:
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
- Các thành viên truy cập Web UI của ArgoCD, đăng nhập bằng mật khẩu mặc định (lấy qua secret `argocd-initial-admin-secret`).
- (Tùy chọn) Cài đặt ArgoCD CLI trên máy cá nhân để thao tác bằng lệnh.

**Bước 3: Cấu hình Manifest riêng để GitOps triển khai**
Trong thư mục cá nhân, tạo folder `my-k8s-app/`.
1. Copy các file YAML bạn đã viết chuẩn ở Tuần 3 vào đây.
2. Đổi tên ứng dụng (vd: `name: app-cua-hieu`).

**Bước 4: Viết khai báo ArgoCD Application**
Bên ngoài folder `my-k8s-app`, tạo file `my-argocd-app.yaml`.
1. Khai báo `kind: Application`.
2. `repoURL`: trỏ về GitHub repository của nhóm.
3. `path`: trỏ đường dẫn chính xác `Tuan5_GitOps_ArgoCD/<ten-cua-ban>/my-k8s-app`.
4. `destination`: trỏ vào cluster `https://kubernetes.default.svc` và chỉ định `namespace` cá nhân của bạn.
5. Kích hoạt Auto-sync:
```yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

**Bước 5: Kịch bản Vận hành & Phá hoại (Chaos Testing)**
1. Mọi người tự apply file `my-argocd-app.yaml` của mình:
```bash
kubectl apply -f my-argocd-app.yaml
```
2. **Kịch bản 1 (Self Heal):** Cố tình xóa app để kiểm tra ArgoCD tự động tạo lại:
```bash
kubectl delete deployment <tên-deploy>
```
3. **Kịch bản 2 (Drift Detection):** Dùng lệnh sửa file trực tiếp trên cụm (thay đổi image). ArgoCD sẽ báo trạng thái `OutOfSync` và tự chữa lành:
```bash
kubectl edit deployment <tên-deploy>
```
4. **Kịch bản 3 (Cập nhật phiên bản):** Sửa số `replicas: 5` trong file `deployment.yaml` trên Github, commit. ArgoCD sẽ phát hiện thay đổi và Scale Up tự động.
5. **Kịch bản 4 (Rollback):** Nếu phiên bản lỗi, thao tác tính năng Rollback bằng giao diện ArgoCD hoặc bằng lệnh `git revert` trên mã nguồn.

**Bước 6: Nộp bài (Output đánh giá)**

> [!IMPORTANT]
> **Yêu cầu bắt buộc để qua bài:** Khởi tạo thành công 1 `Application` trên ArgoCD trỏ tới nhánh Manifest repository cá nhân. Tiến hành sửa đổi (vd: thay đổi tag image, số lượng replica) trong file YAML trên GitHub, và chụp màn hình chứng minh ArgoCD đã tự động dò tìm (sync) và apply thay đổi đó lên cluster thực tế.

- Chụp các ảnh màn hình chứng minh quá trình tạo ArgoCD Application, các kịch bản phá hoại và quá trình tự chữa lành (sync).
- Lưu các file cấu hình và hình ảnh vào thư mục cá nhân. Commit và tạo PR.
