# Tuần 2: Docker, Docker Compose, Dockerfile, Kaniko và Harbor

**Thời gian:** 06/07 - 10/07

## 🎯 Mục tiêu
- Hiểu sâu sắc về kiến trúc Container, sự khác biệt giữa Container và Virtual Machine.
- Đọc hiểu và thành thạo các chỉ thị trong `Dockerfile` (FROM, RUN, CMD, ENTRYPOINT, COPY, ENV, WORKDIR...).
- Nắm vững các khái niệm cốt lõi của Docker: **Images, Containers, Volumes, Networks**.
- Tối ưu hóa kích thước Docker image với kỹ thuật **Multi-stage build**.
- Giới hạn tài nguyên (CPU/RAM) cấp cho Container.
- Sử dụng `docker-compose` để thiết lập môi trường phát triển (Dev Environment) đa dịch vụ với các cấu hình nâng cao.
- Quản lý vòng đời image, push/pull image an toàn, phân quyền với Harbor Container Registry.

## 📝 Nhiệm vụ thực hành chuyên sâu
Nội dung tuần này có rất nhiều khối lượng kiến thức. Mỗi cá nhân cần thực hiện tuần tự qua 8 bước dưới đây trong thư mục riêng của mình để làm chủ hoàn toàn Docker.

**Bước 1: Chuẩn bị Workspace**
1. Checkout nhánh mới:
```bash
git checkout -b <ten-cua-ban>/tuan2-docker
```
2. **BẮT BUỘC:** Tạo một thư mục mang tên bạn (ví dụ: `hoang/`) bên trong thư mục `Tuan2_Docker_Harbor`. Chuyển vào thư mục cá nhân đó để làm việc.

**Bước 2: Thực hành lệnh Docker CLI cơ bản & Quản lý tài nguyên**
1. Kéo một image hệ điều hành:
```bash
docker pull ubuntu:22.04
```
2. Chạy một container tương tác, đồng thời giới hạn tài nguyên (RAM 512MB, CPU 50%) và thử chạy `apt update` bên trong:
```bash
docker run -it --name my-ubuntu --memory="512m" --cpus="0.5" ubuntu:22.04 /bin/bash
```
3. Sau khi `exit` khỏi container, kiểm tra danh sách container và thông tin chi tiết:
```bash
docker ps -a
docker inspect my-ubuntu
```
4. Xem lượng tài nguyên các container đang tiêu thụ theo thời gian thực (nhấn Ctrl+C để thoát):
```bash
docker stats
```
5. Xem log và xóa container:
```bash
docker logs my-ubuntu
docker rm -f my-ubuntu
```

**Bước 3: Quản lý Dữ liệu với Docker Volumes (Persistent Data)**
Mặc định dữ liệu trong container sẽ biến mất khi container bị xóa. Ta dùng Volume để lưu trữ vĩnh viễn.
1. Tạo một Volume có tên (Named Volume):
```bash
docker volume create my-data
```
2. Chạy container Nginx và mount Volume này vào thư mục chứa code web:
```bash
docker run -d -p 8082:80 --name web-volume -v my-data:/usr/share/nginx/html nginx:alpine
```
3. Chui vào container, sửa nội dung web:
```bash
docker exec -it web-volume /bin/sh
echo "<h1>Du lieu nay se khong bi mat!</h1>" > /usr/share/nginx/html/index.html
exit
```
4. Xóa container `web-volume` và tạo một container mới (vd: `web-volume-2`), vẫn sử dụng lại volume `my-data`. Mở trình duyệt xem trang web, bạn sẽ thấy dòng chữ vừa tạo vẫn còn nguyên!
5. **Thực hành Bind Mount:** Mount trực tiếp thư mục code hiện tại ở máy ảo của bạn vào container. Bất cứ khi nào bạn sửa code trên máy ảo, web sẽ cập nhật ngay lập tức:
```bash
docker run -d -p 8083:80 -v $(pwd):/usr/share/nginx/html nginx:alpine
```

**Bước 4: Mạng trong Docker (Docker Network)**
Để các container kết nối được với nhau, chúng cần chung một mạng.
1. Tạo mạng riêng (Bridge network):
```bash
docker network create my-network
```
2. Chạy một container Database (Redis) trong mạng đó:
```bash
docker run -d --name my-redis --network my-network redis:alpine
```
3. Chạy một container hệ điều hành Alpine khác cùng mạng, và dùng lệnh `ping` gọi trực tiếp tên của container Redis thay vì gọi IP:
```bash
docker run -it --network my-network alpine /bin/sh
ping my-redis
# Chú ý kết quả ping thành công nhờ cơ chế DNS nội bộ của Docker!
exit
```

**Bước 5: Tự đóng gói ứng dụng (Multi-stage build Dockerfile)**
1. **Bài tập 1 (Web tĩnh):** Tạo folder `static-web`. Tự viết một trang `index.html`. Viết một `Dockerfile` đơn giản sử dụng `FROM nginx:alpine` và lệnh `COPY` để copy thư mục vào Nginx.
2. **Bài tập 2 (Ứng dụng động & Multi-stage):** Tạo folder `app-nodejs`.
   - Lên mạng tìm một đoạn code ExpressJS siêu ngắn tạo API trả về JSON (có dùng package.json).
   - Viết `Dockerfile` chia làm 2 giai đoạn (stage):
     - **Stage 1 (Build):** Dùng `node:18` làm base. Copy code, chạy `npm install` để tải thư viện.
     - **Stage 2 (Production):** Dùng `node:18-alpine` siêu nhẹ làm base. Chỉ `COPY --from=0` thư mục code và node_modules từ stage 1 sang. Thiết lập `ENV PORT=3000` và `CMD ["node", "server.js"]`.
   - Build image: 
   ```bash
   docker build -t <ten-cua-ban>-api:v1 .
   ```

**Bước 6: Cấu trúc hệ thống hoàn chỉnh với Docker Compose**
Trong thư mục cá nhân, tạo file `docker-compose.yml`. Khai báo cấu trúc hệ thống gồm 3 services liên kết với nhau:
- `frontend`: Dùng lệnh `build:` trỏ vào thư mục `static-web`. Mở port 80.
- `backend`: Dùng lệnh `build:` trỏ vào thư mục `app-nodejs`. Cấu hình biến môi trường (`environment`).
- `database`: Sử dụng image có sẵn `redis:alpine`.
**Yêu cầu nâng cao trong file Compose:**
- Thêm `depends_on` cho `backend` để nó chỉ khởi chạy sau khi `database` chạy xong.
- Thêm `restart: always` để container tự bật lại nếu bị crash.
- Khai báo rõ ràng block `networks` và `volumes`.
Chạy toàn bộ hệ thống ngầm và xem log:
```bash
docker-compose up -d --build
docker-compose logs -f
```

> [!TIP]
> **Tương tác Mạng (Host - Container):** Sau khi `docker-compose` chạy thành công, port của container `frontend` (VD: port 80) đã được map ra ngoài máy ảo (VD: port 8080). 
> Lúc này, bạn hãy mở trình duyệt web trên **máy thật** (Windows/Mac) và truy cập vào `http://<IP-may-ao>:8080`. Docker đã thực hiện port-forwarding (NAT) giúp traffic từ trình duyệt đâm xuyên vào tận container bên trong VM!

**Bước 7: Quản trị Image với Harbor Registry**
- Đăng nhập Harbor (Thay địa chỉ bằng URL Harbor của nhóm):
```bash
docker login <dia-chi-harbor> -u <username> -p <password>
```
- Đổi tên tag image theo đúng chuẩn format của Registry:
```bash
docker tag <ten-cua-ban>-api:v1 <dia-chi-harbor>/<project-name>/<ten-cua-ban>-api:v1
```
- Đẩy image lên kho lưu trữ:
```bash
docker push <dia-chi-harbor>/<project-name>/<ten-cua-ban>-api:v1
```

**Bước 8: Nộp bài**
- Lưu tất cả các lệnh nháp bạn gõ thành công vào file `docker-notes.md`.
- Commit toàn bộ folder cá nhân bao gồm mã nguồn ứng dụng, `Dockerfile`, `docker-compose.yml`, `docker-notes.md`.
- Chụp 2 bức ảnh: (1) Trình duyệt hiển thị web chạy từ docker-compose, (2) Giao diện Harbor hiển thị image bạn vừa push lên. Lưu ảnh vào Git.
- Push lên nhánh cá nhân và tạo Pull Request (PR) chờ Review.
