# Tuần 2: Docker, Kaniko và Harbor (Deep Dive)

*Điều hướng nhanh:* [⬅️ Tuần 1: Linux & Git](../Tuan1_Linux_Git/README.md) | [🏠 Trang chủ Repo](../README.md) | [Tuần 3: Kubernetes ➡️](../Tuan3_Kubernetes/README.md)

**Thời gian:** 06/07 - 10/07

## 🎯 Mục tiêu (Checklist Phase 2)
Tự tay container hóa một ứng dụng thật từ số 0, thay vì chỉ gõ lệnh copy/paste. Nắm vững bản chất của việc đóng gói.

- **Khái niệm cơ bản:** Hiểu sâu về Container Engine, Image vs Container, và cách Union File System (Overlay2) hoạt động.
- **Dockerfile:** Nắm vững các chỉ thị (`FROM`, `RUN`, `CMD`, `ENTRYPOINT`, `COPY`, `ADD`) và kỹ thuật **Multi-stage build** để tối ưu hóa kích thước image.
- **Docker Compose:** Cách gom nhóm nhiều container (ví dụ: Frontend + Backend + Database) chạy chung trong một mạng cục bộ (Docker Bridge Network).
- **Docker Daemon:** Hiểu khái niệm socket `/var/run/docker.sock`, rủi ro bảo mật của Docker-in-Docker (DinD).
- **Kaniko:** Cơ chế build image Rootless (không cần Docker Daemon), giải pháp lý tưởng cho môi trường Kubernetes/CI.
- **Harbor:** Quản trị Private Container Registry, phân quyền dự án (RBAC), quét lỗ hổng bảo mật (Vulnerability Scanning).

## 📚 Lý thuyết Cốt lõi (Under the Hood)
1. **Docker Daemon là gì?** 
   - Docker Daemon (`dockerd`) là một background service chạy với quyền `root` trên host. Nó chịu trách nhiệm giao tiếp với nhân Linux (Namespaces, cgroups) để tạo cách ly cho container. Khi bạn gõ `docker run`, Docker CLI thực chất chỉ gọi API đến Daemon qua Unix Socket (`/var/run/docker.sock`).
   - Rủi ro: Nếu mount socket này vào một container, container đó có thể kiểm soát toàn bộ host. Đây là lý do chúng ta cần Kaniko trong môi trường CI/CD.
2. **Layer Caching:**
   - Mỗi lệnh `RUN`, `COPY`, `ADD` trong Dockerfile tạo ra một layer đọc-chỉ-đọc (Read-only). Docker sẽ cache các layer này. Nếu mã nguồn thay đổi, lệnh `COPY . .` bị vô hiệu hóa cache, kéo theo toàn bộ các lệnh bên dưới phải build lại.
   - *Best Practice:* Luôn `COPY package.json` hoặc `pom.xml` và cài đặt thư viện trước khi `COPY` toàn bộ mã nguồn.
3. **Kaniko hoạt động thế nào?**
   - Kaniko bung trực tiếp Base Image ra file system (user space), chạy các lệnh trong Dockerfile, chụp lại ảnh (snapshot) sự thay đổi file system sau mỗi lệnh, rồi nén lại thành các layer đẩy thẳng lên Harbor mà không cần giao tiếp với Kernel thông qua Daemon.

## 📝 Nhiệm vụ thực hành chuyên sâu

**Bước 1: Chuẩn bị thư mục cá nhân & Workspace**
1. Nhánh làm việc: `git checkout -b <ten-cua-ban>/tuan2-docker`
2. **BẮT BUỘC:** Tạo thư mục có tên bạn (ví dụ: `xuan/`) trong `Tuan2_Docker_Harbor`. Chuyển vào thư mục này để thực hành.
3. Lựa chọn 1 ứng dụng trong thư mục `Sample_WebApps` ở thư mục gốc (Khuyến khích chọn các ứng dụng Framework như React hoặc Spring Boot để thực hành Multi-stage) và copy toàn bộ thư mục đó vào thư mục cá nhân của bạn.

**Bước 2: Viết Dockerfile Multi-stage chuẩn công nghiệp**
Bên trong thư mục mã nguồn vừa copy, tiến hành tạo file `Dockerfile`.
*Yêu cầu khắt khe:* 
- Image cuối cùng phải có kích thước dưới 50MB (đối với Frontend) hoặc dưới 250MB (đối với Backend).
- Phải có ít nhất 2 stage: `builder` (chứa tool nặng như Node/Maven) và `production` (chỉ chứa Nginx/JRE).
- Phải áp dụng Layer Caching (chỉ `npm install` hoặc `mvn dependency:go-offline` trước).

**Cẩm nang Lệnh Docker Build & Run cơ bản:**
Sau khi viết xong Dockerfile, hãy build thử trên máy local:
```bash
docker build -t my-app:v1.0 .
```
*(Giải thích cờ lệnh: `-t` dùng để đặt tên và tag cho image. Dấu `.` ở cuối mang ý nghĩa "Build image dựa trên Dockerfile nằm ở thư mục hiện hành context").*

Chạy thử image vừa build thành một container độc lập:
```bash
docker run -d -p 8080:80 --name my-running-app my-app:v1.0
```
*(Giải thích cờ lệnh: `-d` (detach) chạy ngầm không chiếm Terminal. `-p 8080:80` bẻ khóa cổng mạng, lấy cổng 8080 của máy tính bạn nối vào cổng 80 của container. `--name` đặt tên cho dễ nhớ).*

**Bước 3: Thực hành Local với Docker Compose**
Tạo file `docker-compose.yml` để chạy ứng dụng vừa build cùng với một service giả lập (vd: Redis hoặc Nginx Load Balancer).
```yaml
version: '3.8'
services:
  myapp:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:80"
    restart: always
```
Chạy thử: `docker-compose up -d --build` và truy cập trình duyệt. Dùng `docker-compose logs -f` để theo dõi.

**Bước 4: Trải nghiệm Kaniko (Giả lập CI)**
Thay vì dùng `docker build`, hãy tập build bằng Kaniko để quen với môi trường CI/CD:
```bash
docker run -v $(pwd):/workspace \
  gcr.io/kaniko-project/executor:latest \
  --context /workspace \
  --dockerfile /workspace/Dockerfile \
  --destination harbor.mycompany.com/myproject/myapp:1.0.0 \
  --no-push # (Dùng flag này để test local nếu chưa có Harbor)
```
*Giải thích:* Lệnh này mount thư mục code hiện tại vào container Kaniko, chỉ định nơi chứa Dockerfile và URL của Registry đích.

**Bước 5: Vận hành Harbor Private Registry**
1. Đăng nhập vào giao diện web Harbor do Leader cung cấp. Tạo một Project mới.
2. Đăng nhập Docker CLI vào Harbor: `docker login harbor.mycompany.com`.
3. Tag và push image của bạn lên Harbor:
```bash
docker tag myapp:latest harbor.mycompany.com/myproject/myapp:v1
docker push harbor.mycompany.com/myproject/myapp:v1
```
4. Kích hoạt tính năng **Vulnerability Scanning** trên Harbor để quét lỗ hổng bảo mật của image bạn vừa push.

## 🛠️ Xử lý sự cố thường gặp (Troubleshooting)
- **Lỗi `no space left on device`**: Chạy lệnh `docker system prune -a` để dọn dẹp các image/container không sử dụng (Cẩn thận lệnh này sẽ xóa sạch cache của Docker).
- **Lỗi `denied: requested access to the resource is denied` khi push lên Harbor**: Bạn chưa cấu hình đúng tên miền Harbor trong tag image, hoặc chưa `docker login`.
- **Lỗi Permission Denied trong Dockerfile**: Đảm bảo sử dụng chỉ thị `USER` trong Dockerfile để không chạy ứng dụng bằng quyền root (Security Best Practice).

**Bước 6: Docker Networking Deep Dive**

Hiểu mạng Docker là bước đệm quan trọng trước khi bước vào Kubernetes Networking.

1. **Tạo Custom Bridge Network:** Mặc định Docker dùng mạng `bridge` có tên `docker0`. Nhưng trong thực tế, bạn nên tạo network riêng để các container giao tiếp qua tên DNS thay vì IP:

```bash
# Tạo mạng tùy chỉnh
docker network create --driver bridge my-app-network

# Chạy 2 container trên cùng mạng
docker run -d --name web --network my-app-network nginx:alpine
docker run -d --name api --network my-app-network nginx:alpine
```
*(Giải thích: Khi 2 container nằm chung 1 custom network, chúng có thể gọi nhau bằng tên container. Ví dụ: container `web` có thể `ping api` mà không cần biết IP. Đây là cơ chế DNS nội bộ của Docker, tương tự Service DNS trong Kubernetes).*

2. **Kiểm tra kết nối mạng giữa các container:**

```bash
# Truy cập vào container web và ping container api
docker exec -it web sh
ping api -c 3
wget -qO- http://api:80
exit
```

3. **Phân tích cấu trúc mạng:**

```bash
# Xem chi tiết mạng (subnet, gateway, container nào đang tham gia)
docker network inspect my-app-network

# Liệt kê tất cả mạng Docker
docker network ls
```
*(Giải thích: `inspect` trả về JSON chứa toàn bộ metadata của mạng, bao gồm danh sách container đang kết nối và dải IP được cấp phát. Kỹ năng đọc JSON output rất quan trọng khi debug).*

4. **Thử nghiệm cô lập mạng (Network Isolation):** Tạo container trên mạng `bridge` mặc định và thử `ping` sang container trên `my-app-network`. Bạn sẽ thấy nó KHÔNG thể kết nối — đây chính là cơ chế **cô lập mạng** (Network Segmentation), một best practice về bảo mật.

Dọn dẹp:
```bash
docker rm -f web api
docker network rm my-app-network
```

**Bước 7: Docker Volume & Data Persistence**

Container là **Ephemeral** (tạm thời) — khi container bị xóa, dữ liệu bên trong cũng mất. Volume giải quyết vấn đề này.

1. **Named Volume vs Bind Mount:**

```bash
# Cách 1: Named Volume (Docker quản lý, dữ liệu nằm trong /var/lib/docker/volumes/)
docker volume create my-data
docker run -d --name db -v my-data:/var/lib/mysql mysql:8.0

# Cách 2: Bind Mount (Gắn thư mục cụ thể từ máy host vào container)
docker run -d --name web -v $(pwd)/html:/usr/share/nginx/html:ro nginx:alpine
```
*(Giải thích: Named Volume phù hợp cho database — Docker quản lý lifecycle. Bind Mount phù hợp cho dev — bạn sửa code trên host, container cập nhật ngay. Flag `:ro` (read-only) ngăn container ghi ngược vào host, tăng bảo mật).*

2. **Backup và Restore dữ liệu Volume:**

Đây là kỹ năng thiết yếu trong vận hành Production:
```bash
# Backup: Mount volume cần backup vào 1 container tạm, nén và copy ra host
docker run --rm -v my-data:/source -v $(pwd):/backup alpine \
    tar czf /backup/my-data-backup.tar.gz -C /source .

# Restore: Giải nén ngược lại vào volume
docker run --rm -v my-data-restored:/target -v $(pwd):/backup alpine \
    tar xzf /backup/my-data-backup.tar.gz -C /target
```
*(Giải thích: Kỹ thuật này sử dụng một container Alpine tạm (flag `--rm` tự xóa sau khi chạy xong) như một "công nhân" trung gian để truy cập dữ liệu trong volume. Đây là pattern chuẩn trong Docker).*

3. **Kiểm tra và quản lý Volume:**

```bash
# Liệt kê tất cả volume
docker volume ls

# Xem thông tin chi tiết (vị trí lưu trữ trên host)
docker volume inspect my-data

# Dọn dẹp volume không sử dụng
docker volume prune
```

**Bước 8: Tối ưu hóa Docker Image & Security Best Practices**

Image nhẹ = build nhanh hơn, pull nhanh hơn, ít lỗ hổng bảo mật hơn.

1. **Tạo file `.dockerignore`:** Giống `.gitignore`, file này ngăn Docker copy các file không cần thiết vào build context (giảm thời gian build đáng kể):

```
# .dockerignore
node_modules/
.git/
*.md
*.log
.env
dist/
coverage/
```

2. **Phân tích Layer bằng `docker history`:**

```bash
# Xem từng layer và kích thước
docker history my-app:v1.0

# Xem đầy đủ lệnh tạo ra mỗi layer (không bị cắt ngắn)
docker history --no-trunc my-app:v1.0
```
*(Giải thích: Mỗi dòng trong output tương ứng với 1 layer. Layer nào quá lớn, bạn nên tìm cách tối ưu lệnh RUN tương ứng trong Dockerfile. Tip: Gộp nhiều lệnh RUN thành 1 bằng `&&` để giảm số layer).*

3. **Phân tích sâu Image bằng công cụ `dive` (Tùy chọn nâng cao):**

```bash
# Cài đặt dive (công cụ phân tích layer trực quan)
# Trên Ubuntu:
wget https://github.com/wagoodman/dive/releases/latest/download/dive_0.12.0_linux_amd64.deb
sudo dpkg -i dive_0.12.0_linux_amd64.deb

# Phân tích image
dive my-app:v1.0
```
*(Công cụ `dive` hiển thị giao diện TUI cho bạn duyệt từng layer, xem file nào được thêm/sửa/xóa, và tính điểm hiệu quả (Efficiency Score) cho image).*

4. **Chạy Container với Non-Root User (Security Hardening):**

Việc chạy app bằng quyền `root` trong container là rủi ro bảo mật lớn. Thêm các dòng sau vào cuối Dockerfile:

```dockerfile
# Tạo user và group mới
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Chuyển quyền sở hữu thư mục app
CHOWN appuser:appgroup /app

# Đổi sang user không có quyền root
USER appuser
```

5. **Healthcheck trong Dockerfile:** Cho Docker tự kiểm tra sức khỏe container:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1
```
*(Giải thích: `--interval` kiểm tra mỗi 30 giây. `--timeout` chờ tối đa 3 giây. `--retries` thử 3 lần liên tiếp trước khi đánh dấu `unhealthy`. Container unhealthy sẽ được Docker Compose hoặc K8s tự động restart).*

Sau khi thực hành xong, cập nhật Dockerfile của bạn ở Bước 2 để áp dụng các kỹ thuật tối ưu này.

**Bước 9: Nộp bài (Output đánh giá)**

> [!IMPORTANT]
> **Yêu cầu bắt buộc để qua bài:** Bạn phải viết được `Dockerfile multi-stage` cho 1 app thật, build thành công image (kích thước tối ưu) và push thành công lên dự án của bạn trên Harbor. Giao diện Harbor phải hiển thị image của bạn kèm kết quả quét bảo mật (Scanning).

- Commit `Dockerfile` và file `docker-compose.yml` lên nhánh cá nhân.
- Tạo Pull Request và nhờ mentor/leader review cấu trúc Dockerfile của bạn.
