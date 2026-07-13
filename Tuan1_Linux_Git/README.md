# Tuần 1: Tìm hiểu tổng quan về DevOps, Linux, Bash Shell, Git

*Điều hướng nhanh:* [🏠 Trang chủ Repo](../README.md) | [Tuần 2: Docker & Harbor ➡️](../Tuan2_Docker_Harbor/README.md)

**Thời gian:** 29/06 - 03/07

## 🎯 Mục tiêu

- Hiểu được vòng đời phát triển phần mềm và phương pháp DevOps.
- Cài đặt và cấu hình thành công môi trường máy ảo VMWare.
- Làm quen với hệ điều hành Linux, thành thạo các câu lệnh điều hướng và xử lý file cơ bản (CLI).
- Biết cách viết các script tự động hóa cơ bản bằng Bash Shell.
- Nắm vững Git Workflow, quy trình phân nhánh (branching), xử lý xung đột (conflict), và làm việc nhóm qua Pull Request trên GitHub.

## 📝 Nhiệm vụ thực hành

Để làm quen với quy trình Git và lệnh Linux, mỗi thành viên phải thực hiện các bài tập sau trong thư mục cá nhân của mình.

**Bước 1: Chuẩn bị môi trường & Git Workspace**

1. Khuyến khích cài đặt hệ điều hành Linux Server như **Ubuntu Server 22.04 (Recommend)** trên máy ảo VMWare.
2. Thiết lập kết nối SSH vào máy ảo. Bạn có thể sử dụng bất kỳ công cụ môi trường CLI nào để SSH vào như: Terminal, CMD, PowerShell, VSCode, Antigravity, PuTTY, MobaXterm.
3. Cài đặt Git và Clone repository này về máy ảo của bạn.
4. Tạo nhánh cá nhân từ `main` với cú pháp:

```bash
git checkout -b <ten-cua-ban>/tuan1-linux-git
```

5. **BẮT BUỘC:** Tạo một thư mục con mang tên bạn ngay trong thư mục `Tuan1_Linux_Git` này và di chuyển vào đó. Mọi file thực hành phải nằm trong thư mục cá nhân này:

```bash
mkdir <ten-cua-ban>
cd <ten-cua-ban>
```

**Bước 2: Thực hành Lệnh Linux (CLI)**
Trước khi viết script, hãy làm quen với các câu lệnh Linux cơ bản. Trong thư mục cá nhân của bạn:

1. Thao tác thư mục và đường dẫn: Tạo thư mục `linux-practice` và di chuyển vào đó:

```bash
mkdir linux-practice
cd linux-practice
```

Dùng lệnh `pwd` để in ra đường dẫn tuyệt đối, dùng `ls -la` để xem các file ẩn.
2. Thao tác với file: Dùng lệnh sau để tạo file rỗng:

```bash
touch file_moi.txt
```

Sau đó copy, đổi tên/di chuyển, và cuối cùng xóa file:

```bash
cp file_moi.txt file_copy.txt
mv file_copy.txt file_rename.txt
rm file_moi.txt
```

3. Chỉnh sửa và Đọc file:
   Sử dụng `echo` để đẩy dữ liệu trực tiếp vào file:

```bash
echo "Chao mung den voi lop hoc DevOps" > text.txt
```

Dùng trình soạn thảo văn bản `nano` để mở và chỉnh sửa trực tiếp trên Terminal:

```bash
nano text.txt
```

*(Trong nano: Gõ văn bản tùy ý, sau đó nhấn `Ctrl + O` -> `Enter` để lưu, và `Ctrl + X` để thoát).*

Dùng lệnh `cat text.txt` hoặc `less text.txt` để đọc nhanh nội dung file.
4. Tìm kiếm chuỗi ký tự trong file:

```bash
grep "DevOps" text.txt
```

5. **Phân quyền file & Quản lý quyền truy cập (Permissions Deep Dive):**

   Phân quyền là nền tảng bảo mật của Linux. Mỗi file/thư mục có 3 nhóm quyền: **Owner** (chủ sở hữu), **Group** (nhóm), **Others** (người khác). Mỗi nhóm có 3 quyền: **r** (read=4), **w** (write=2), **x** (execute=1).

   **a) Thực hành `chmod` — Thay đổi quyền bằng số và ký hiệu:**

   ```bash
   # Chỉ cho phép đọc (r--), thử ghi → Xem lỗi "Permission denied"
   chmod 400 text.txt
   echo "Test" >> text.txt   # Sẽ bị từ chối!
   chmod 644 text.txt         # Đổi lại: Owner đọc+ghi, Group+Others chỉ đọc

   # Cách dùng ký hiệu (dễ nhớ hơn số):
   chmod u+x script.sh        # Thêm quyền thực thi cho Owner (u=user)
   chmod g-w text.txt         # Xóa quyền ghi của Group (g=group)
   chmod o-rwx text.txt       # Xóa toàn bộ quyền của Others (o=others)
   chmod a+r text.txt         # Thêm quyền đọc cho tất cả (a=all)
   ```
   *(Giải thích: `644` = Owner(rw-=6) + Group(r--=4) + Others(r--=4). `755` = Owner(rwx=7) + Group(r-x=5) + Others(r-x=5) — đây là quyền chuẩn cho thư mục và script. Trong DevOps, hiểu sai quyền file là nguyên nhân phổ biến gây lỗi "Permission denied" khi build Docker hoặc chạy CI/CD).*

   **b) Thực hành `chown` — Thay đổi chủ sở hữu:**

   ```bash
   # Xem chủ sở hữu hiện tại
   ls -la text.txt

   # Đổi chủ sở hữu file (cần sudo)
   sudo chown root:root text.txt   # Đổi owner VÀ group thành root
   ls -la text.txt                  # Kiểm tra lại

   # Đổi lại về user của bạn
   sudo chown $(whoami):$(whoami) text.txt
   ```
   *(Giải thích: `chown user:group file` đổi đồng thời owner và group. Lệnh `$(whoami)` tự động lấy tên user hiện tại. Trong Docker, lỗi `chown` là nguyên nhân phổ biến khi container chạy với user khác root).*

   **c) Thực hành `umask` — Quyền mặc định khi tạo file mới:**

   ```bash
   # Xem umask hiện tại
   umask

   # Tạo file với umask mặc định và kiểm tra quyền
   touch file_default.txt
   ls -la file_default.txt

   # Đặt umask chặt hơn: chỉ owner có quyền đọc/ghi
   umask 077
   touch file_strict.txt
   ls -la file_strict.txt    # Sẽ thấy quyền là rw------- (600)

   # Đặt lại umask mặc định
   umask 022
   ```
   *(Giải thích: `umask` là "mặt nạ ngược" — giá trị umask bị TRỪ khỏi quyền tối đa. File tối đa là 666, umask 022 → quyền thực tế là 644. Thư mục tối đa là 777, umask 022 → 755. Server production thường đặt umask 027 để Others không có bất kỳ quyền nào).*

   **d) Kiểm tra quyền sudo & Quản lý user:**

   ```bash
   # Xem user hiện tại có quyền sudo không
   sudo -l

   # Xem user đang đăng nhập thuộc nhóm nào
   groups
   id

   # Thử chuyển sang quyền root rồi quay lại
   sudo su -
   whoami       # Sẽ hiện "root"
   exit         # Quay lại user thường — LUÔN exit khi xong việc!
   ```

   > [!WARNING]
   > **Nguyên tắc vàng của DevOps:** Không bao giờ làm việc thường xuyên bằng quyền `root`. Chỉ dùng `sudo` cho từng lệnh cụ thể. Chạy ứng dụng bằng root trong container là rủi ro bảo mật nghiêm trọng (bạn sẽ học cách khắc phục ở Tuần 2 — Docker non-root user).

   **e) Bài tập tổng hợp quyền:** Tạo một thư mục dự án giả lập và phân quyền đúng chuẩn:

   ```bash
   mkdir -p project/{src,config,logs}
   chmod 755 project/src       # Mọi người đọc được source code
   chmod 750 project/config    # Chỉ owner và group đọc được config
   chmod 700 project/logs      # Chỉ owner đọc log (bảo mật)
   ls -la project/             # Kiểm tra kết quả
   ```

6. **Tương tác với Mạng — Kỹ năng Networking cho DevOps:**

   Networking là kỹ năng **sống còn** cho DevOps Engineer. Nếu không hiểu mạng, bạn sẽ không thể debug Docker Networking, Kubernetes Service, hay Ingress Controller.

   **a) Kiểm tra cấu hình mạng của máy ảo:**

   ```bash
   # Xem tất cả interface mạng và địa chỉ IP
   ip a

   # Chỉ xem địa chỉ IPv4 (lọc gọn hơn)
   ip -4 addr show

   # Xem bảng định tuyến (routing table) — Biết traffic đi đường nào
   ip route show
   ```
   *(Giải thích: `ip a` hiển thị các interface mạng (eth0, ens33...) cùng địa chỉ IP. `ip route` cho biết Default Gateway — cổng ra internet. Trong K8s, mỗi Pod có một interface mạng ảo riêng, hiểu routing giúp bạn debug mạng Pod).*

   **b) Kiểm tra kết nối mạng (Connectivity Test):**

   ```bash
   # Ping Google DNS — Kiểm tra kết nối internet cơ bản
   ping -c 4 8.8.8.8
   ```
   *(Giải thích: `-c 4` chỉ gửi 4 gói tin rồi dừng (không ping vô hạn). Nếu ping thất bại → kiểm tra NAT/Bridged mode trong VMWare).*

   ```bash
   # Traceroute — Xem traffic đi qua bao nhiêu hop (router) để tới đích
   traceroute 8.8.8.8
   # Hoặc dùng mtr (kết hợp ping + traceroute, real-time):
   mtr -c 10 8.8.8.8
   ```
   *(Giải thích: `traceroute` liệt kê từng router trên đường đi. Nếu traffic bị "kẹt" ở hop nào đó, đó là nơi bạn cần kiểm tra firewall/routing. `mtr` trực quan hơn với thống kê packet loss theo thời gian thực).*

   **c) Phân giải tên miền (DNS Resolution):**

   ```bash
   # Tra cứu IP của một tên miền
   nslookup google.com

   # Dùng dig (chi tiết hơn, hiển thị cả DNS server đang dùng)
   dig google.com

   # Kiểm tra DNS server nào đang được cấu hình
   cat /etc/resolv.conf
   ```
   *(Giải thích: DNS biến tên miền thành IP. Trong Kubernetes, Service DNS là cách các Pod gọi nhau (vd: `http://my-service.my-namespace.svc.cluster.local`). Hiểu DNS giúp bạn debug lỗi "could not resolve host" rất phổ biến trong container).*

   **d) Kiểm tra cổng mạng đang mở (Port Scanning):**

   ```bash
   # Xem tất cả cổng TCP đang lắng nghe (listen) trên máy
   ss -tlnp
   ```
   *(Giải thích cờ lệnh: `-t` chỉ TCP. `-l` chỉ cổng đang listen. `-n` hiện số cổng thay vì tên dịch vụ. `-p` hiện tiến trình nào đang giữ cổng. Đây là lệnh đầu tiên bạn chạy khi debug "ứng dụng không truy cập được" — kiểm tra xem app đã listen trên đúng cổng chưa).*

   ```bash
   # Kiểm tra một cổng cụ thể có đang mở không
   ss -tlnp | grep 8080

   # Hoặc dùng netstat (cũ hơn nhưng vẫn phổ biến)
   sudo netstat -tlnp
   ```

   **e) Gọi HTTP và kiểm tra Web Service:**

   ```bash
   # Lấy header HTTP (kiểm tra nhanh web có sống không)
   curl -I https://google.com

   # Tải nội dung trang web
   curl -s https://api.github.com | head -20

   # Gọi API với timeout (rất quan trọng trong script CI/CD)
   curl -s --connect-timeout 5 --max-time 10 http://localhost:8080/health

   # Kiểm tra kết nối TCP tới một host:port cụ thể (không cần HTTP)
   nc -zv google.com 443
   ```
   *(Giải thích: `curl -I` chỉ lấy header không tải body — nhanh hơn nhiều. `-s` (silent) tắt progress bar. `--connect-timeout` giới hạn thời gian kết nối. `nc -zv` (netcat) kiểm tra cổng TCP có mở không mà không gửi HTTP — rất hữu ích để test database port, Redis port...).*

   **f) Tường lửa cơ bản (`ufw` — Uncomplicated Firewall):**

   ```bash
   # Xem trạng thái tường lửa
   sudo ufw status verbose

   # Mở cổng SSH (22) và HTTP (80)
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp

   # Mở cổng cho ứng dụng web đang dev (8080)
   sudo ufw allow 8080/tcp

   # Xem danh sách rules đã thêm
   sudo ufw status numbered

   # Xóa một rule theo số thứ tự
   sudo ufw delete 3

   # Bật tường lửa (CẨN THẬN: đảm bảo đã allow SSH trước!)
   sudo ufw enable
   ```
   *(Giải thích: `ufw` là front-end đơn giản cho `iptables`. Trong môi trường DevOps, bạn cần mở đúng cổng cho Docker (2375/2376), Kubernetes API (6443), NodePort range (30000-32767), và Harbor (443). Nếu quên mở cổng SSH trước khi enable ufw, bạn sẽ bị lock khỏi server!).*

   > [!CAUTION]
   > Luôn chạy `sudo ufw allow 22/tcp` **TRƯỚC** khi `sudo ufw enable`. Nếu không, bạn sẽ tự khóa mình khỏi máy ảo và phải truy cập qua VMWare Console để sửa.

   **g) Bài tập tổng hợp Mạng:** Lưu lại toàn bộ thông tin mạng vào file báo cáo:

   ```bash
   {
     echo "=== NETWORK INTERFACES ==="
     ip -4 addr show
     echo ""
     echo "=== ROUTING TABLE ==="
     ip route show
     echo ""
     echo "=== DNS CONFIG ==="
     cat /etc/resolv.conf
     echo ""
     echo "=== LISTENING PORTS ==="
     ss -tlnp
     echo ""
     echo "=== FIREWALL STATUS ==="
     sudo ufw status verbose 2>/dev/null || echo "UFW not installed"
   } > ../network_report.txt
   cat ../network_report.txt
   ```

7. Quản lý tiến trình: Gõ lệnh `top` hoặc `htop` để xem các tiến trình đang chạy. Ấn `q` để thoát.
8. Lưu lại lịch sử các lệnh bạn vừa gõ để chuẩn bị commit:

```bash
history > ../command_history.txt
```

**Bước 3: Thực hành Bash Script**
Trong thư mục cá nhân của bạn, hãy tạo 3 file script:

1. `01-hello.sh`: Script in ra thông tin cá nhân của bạn (Tên, Mã SV, Định hướng thực tập) và ngày giờ hiện tại của hệ thống.
2. `02-sysinfo.sh`: Script thu thập thông tin máy ảo (sử dụng lệnh `df -h` xem ổ cứng, `free -m` xem RAM, `uname -a` xem phiên bản OS) và lưu kết quả vào file `system_report.txt`.
3. `03-user_manager.sh`: Một script nhỏ yêu cầu người dùng nhập tên một user, script sẽ kiểm tra user đó có tồn tại trong `/etc/passwd` hay không.
   *Đừng quên cấp quyền thực thi cho các file này:*

```bash
chmod +x *.sh
```

**Bước 4: Biên dịch và Thực thi Code (C/C++, Python)**

Để làm quen với quy trình build ứng dụng trên Linux (rất quan trọng cho CI/CD sau này), hãy thử cài đặt trình biên dịch và thực thi code.

1. Cài đặt các công cụ cần thiết trên Ubuntu:

```bash
sudo apt update
sudo apt install build-essential python3
```

2. **Thực thi C/C++ (Sử dụng Compiler):** Dùng lệnh `touch main.c` hoặc `touch main.cpp` để tạo file, dùng `nano main.c` viết đoạn code in ra "Hello World". Sau đó dùng trình biên dịch `gcc` hoặc `g++` để build thành mã máy và chạy:

```bash
# Đối với ngôn ngữ C
gcc main.c -o app_c
./app_c

# Đối với ngôn ngữ C++
g++ main.cpp -o app_cpp
./app_cpp
```

3. **Thực thi Python (Sử dụng Interpreter):** Tạo file `script.py` và viết code đơn giản. Với các ngôn ngữ thông dịch như Python, bạn không cần build ra mã máy mà gọi trực tiếp:

```bash
python3 script.py
```

4. **Tự động hóa với Bash Script:** Thay vì gõ lại các lệnh build và chạy thủ công nhiều lần, hãy tạo một file `run.sh` để gom nhóm (automate) quá trình thực thi:

```bash
nano run.sh
```

Viết nội dung sau vào file `run.sh`:

```bash
#!/bin/bash
echo "=== Đang build C/C++ ==="
gcc main.c -o app_c
./app_c

echo "=== Đang chạy Python ==="
python3 script.py
```

Đừng quên cấp quyền thực thi và chạy thử script:

```bash
chmod +x run.sh
./run.sh
```

5. **Tương tác Mạng (Host - VM):** Một kỹ năng DevOps cực kỳ quan trọng là hiểu về mạng. Hãy thử mở một Web Server cực nhanh bằng Python ngay tại thư mục hiện tại (cổng 8000):

```bash
python3 -m http.server 8000
```

> [!TIP]
> - Mở trình duyệt web **trên máy tính thật (Windows/Mac của bạn)**, gõ vào thanh địa chỉ IP của máy ảo kèm theo cổng. Ví dụ: `http://192.168.x.x:8000`.
> - Bạn sẽ thấy toàn bộ file trong thư mục hiện tại hiện lên trình duyệt! Điều này chứng minh máy thật của bạn đã gọi API thành công xuyên qua mạng ảo hóa (NAT/Bridged) vào tận dịch vụ đang chạy trên VM.
> - Quay lại Terminal máy ảo, nhấn `Ctrl + C` để tắt server.

**Bước 6: Quản trị Hệ thống Linux Nâng cao**

Sau khi đã nắm vững CLI cơ bản, hãy tìm hiểu các kỹ năng quản trị hệ thống — nền tảng bắt buộc cho mọi DevOps Engineer.

1. **Quản lý dịch vụ với `systemd`:** Đây là hệ thống quản lý tiến trình cốt lõi của Linux hiện đại. Hãy thực hành kiểm soát các dịch vụ:

```bash
# Xem trạng thái dịch vụ SSH
systemctl status sshd

# Khởi động lại dịch vụ (nếu bạn sửa cấu hình)
sudo systemctl restart sshd

# Xem danh sách tất cả dịch vụ đang chạy
systemctl list-units --type=service --state=running
```
*(Giải thích: `systemctl` là công cụ điều khiển `systemd`. Lệnh `status` cho bạn biết dịch vụ đang chạy hay đã chết, `restart` khởi động lại dịch vụ. Đây là kỹ năng bắt buộc khi vận hành server thật).*

2. **Lập lịch tự động với Crontab:** Crontab cho phép bạn hẹn giờ chạy script tự động (rất giống CI/CD scheduling). Tạo một cronjob ghi log mỗi phút:

```bash
# Mở trình soạn crontab
crontab -e
```

Thêm dòng sau vào cuối file:
```
* * * * * echo "Heartbeat $(date)" >> /tmp/heartbeat.log
```
*(Giải thích cú pháp `* * * * *`: 5 dấu sao tương ứng Phút - Giờ - Ngày - Tháng - Thứ. Tất cả là `*` nghĩa là "mỗi phút". Lệnh `>>` ghi nối thêm vào file log. Sau 5 phút, dùng `cat /tmp/heartbeat.log` để kiểm chứng).*

Sau khi kiểm tra xong, nhớ xóa cronjob để tránh ghi log vô hạn:
```bash
crontab -r  # Xóa toàn bộ crontab
```

3. **Giám sát Log hệ thống:** Log là "hộp đen" của server. Khi hệ thống gặp sự cố, log là nơi đầu tiên bạn phải kiểm tra:

```bash
# Xem log hệ thống theo thời gian thực (giống tail -f)
sudo journalctl -f

# Lọc log của một dịch vụ cụ thể (ví dụ: SSH)
sudo journalctl -u sshd --since "10 minutes ago"

# Xem 50 dòng log cuối cùng của syslog
sudo tail -n 50 /var/log/syslog
```
*(Giải thích: `journalctl` là công cụ đọc log của systemd. Cờ `-f` (follow) theo dõi log real-time. Cờ `-u` (unit) lọc theo tên dịch vụ. Cờ `--since` lọc theo thời gian. Kỹ năng đọc log cực kỳ quan trọng khi debug container và Kubernetes pod về sau).*

4. **Quản lý ổ đĩa cơ bản:** Hiểu cách hệ thống file hoạt động:

```bash
# Liệt kê tất cả ổ đĩa và phân vùng
lsblk

# Kiểm tra dung lượng ổ đĩa (human-readable)
df -h

# Kiểm tra dung lượng thư mục hiện tại
du -sh *
```

Lưu kết quả vào file báo cáo:
```bash
{ echo "=== DISK INFO ==="; lsblk; echo "=== USAGE ==="; df -h; } > ../disk_report.txt
```

**Bước 7: Bash Script Nâng cao**

Nâng cấp kỹ năng viết script để chuẩn bị cho việc tự động hóa CI/CD pipeline.

1. `04-backup.sh`: Viết script backup tự động. Script nhận đường dẫn thư mục cần backup, nén bằng `tar`, đặt tên file theo ngày giờ, và lưu vào thư mục `/tmp/backups/`:

```bash
#!/bin/bash
# Script backup tự động với timestamp
BACKUP_DIR="/tmp/backups"
SOURCE_DIR="${1:-.}"  # Nhận tham số dòng lệnh, mặc định là thư mục hiện tại
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="backup_${TIMESTAMP}.tar.gz"

mkdir -p "$BACKUP_DIR"
tar -czf "${BACKUP_DIR}/${FILENAME}" "$SOURCE_DIR"
echo "[OK] Backup thành công: ${BACKUP_DIR}/${FILENAME}"
echo "[INFO] Kích thước: $(du -h ${BACKUP_DIR}/${FILENAME} | cut -f1)"
```
*(Giải thích: `${1:-.}` là cú pháp Bash lấy tham số thứ nhất, nếu không có thì dùng giá trị mặc định `.`. Lệnh `tar -czf` tạo file nén gzip. Đây là pattern cơ bản bạn sẽ gặp lại khi viết script CI/CD)*.

2. `05-monitor.sh`: Script giám sát tài nguyên hệ thống, cảnh báo khi CPU hoặc RAM vượt ngưỡng:

```bash
#!/bin/bash
# Script giám sát tài nguyên và cảnh báo
THRESHOLD_CPU=80
THRESHOLD_MEM=80

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
MEM_USAGE=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')

echo "=== System Monitor Report ==="
echo "Thời gian: $(date)"
echo "CPU Usage: ${CPU_USAGE}%"
echo "RAM Usage: ${MEM_USAGE}%"

if [ "$CPU_USAGE" -gt "$THRESHOLD_CPU" ]; then
    echo "[CẢNH BÁO] CPU vượt ngưỡng ${THRESHOLD_CPU}%!"
fi

if [ "$MEM_USAGE" -gt "$THRESHOLD_MEM" ]; then
    echo "[CẢNH BÁO] RAM vượt ngưỡng ${THRESHOLD_MEM}%!"
fi
```

3. `06-menu.sh`: Script menu tương tác sử dụng cấu trúc `select` và `case` — kỹ năng rất hữu ích khi viết tool CLI:

```bash
#!/bin/bash
# Menu quản lý hệ thống tương tác
echo "===== SYSTEM ADMIN TOOL ====="
PS3="Chọn chức năng (nhập số): "

select opt in "Xem thông tin hệ thống" "Xem ổ đĩa" "Xem tiến trình" "Kiểm tra mạng" "Thoát"; do
    case $opt in
        "Xem thông tin hệ thống") uname -a; free -m ;;
        "Xem ổ đĩa") df -h ;;
        "Xem tiến trình") ps aux --sort=-%mem | head -10 ;;
        "Kiểm tra mạng") ip a; ping -c 3 8.8.8.8 ;;
        "Thoát") echo "Tạm biệt!"; break ;;
        *) echo "Lựa chọn không hợp lệ!" ;;
    esac
    echo "" # Dòng trống cho dễ đọc
done
```
*(Giải thích: `select` là built-in của Bash tạo menu có đánh số tự động. `PS3` là biến đặc biệt quy định dòng nhắc của select. `case` kiểm tra giá trị biến và thực thi lệnh tương ứng. `;;` kết thúc mỗi nhánh case).*

Đừng quên cấp quyền và chạy thử:
```bash
chmod +x 04-backup.sh 05-monitor.sh 06-menu.sh
./06-menu.sh
```

**Bước 8: Git Nâng cao & Xử lý Conflict**

Đây là kỹ năng sống còn khi làm việc nhóm. Bạn CHẮC CHẮN sẽ gặp conflict, và phải biết xử lý chúng.

1. **Thực hành Merge Conflict có kiểm soát:** Tạo tình huống conflict giả lập để học cách giải quyết:

```bash
# Tạo file test
echo "Dòng gốc ban đầu" > conflict_test.txt
git add conflict_test.txt
git commit -m "chore: tạo file test conflict"

# Tạo nhánh phụ và sửa file
git checkout -b test-conflict
echo "Nội dung từ nhánh test-conflict" > conflict_test.txt
git commit -am "feat: sửa file từ nhánh phụ"

# Quay lại nhánh chính và sửa cùng file
git checkout -
echo "Nội dung từ nhánh chính" > conflict_test.txt
git commit -am "feat: sửa file từ nhánh chính"

# Merge — LÚC NÀY SẼ BỊ CONFLICT!
git merge test-conflict
```

Khi thấy `CONFLICT`, mở file bằng `nano conflict_test.txt`. Bạn sẽ thấy:
```
<<<<<<< HEAD
Nội dung từ nhánh chính
=======
Nội dung từ nhánh test-conflict
>>>>>>> test-conflict
```
Xóa các dấu `<<<<<<<`, `=======`, `>>>>>>>` và giữ lại nội dung bạn muốn. Sau đó:
```bash
git add conflict_test.txt
git commit -m "fix: giải quyết conflict test"
```

2. **Git Stash — Cất tạm công việc:** Khi đang code dở mà cần chuyển nhánh gấp:

```bash
# Cất tạm các thay đổi chưa commit
git stash

# Chuyển nhánh làm việc khác
git checkout main
# ... làm gì đó ...
git checkout -  # Quay lại nhánh cũ

# Lấy lại công việc đã cất
git stash pop
```
*(Giải thích: `git stash` hoạt động như một "ngăn kéo tạm". `pop` lấy ra và xóa khỏi stash. Dùng `git stash list` để xem danh sách các stash).*

3. **Interactive Rebase — Dọn dẹp lịch sử commit:** Trước khi tạo PR, bạn nên gộp các commit lặt vặt lại cho gọn gàng:

```bash
# Gộp 3 commit gần nhất thành 1
git rebase -i HEAD~3
```
Trình soạn thảo sẽ hiện danh sách commit. Đổi `pick` thành `squash` (hoặc `s`) ở các commit muốn gộp. Lưu và thoát.

> [!WARNING]
> **Không bao giờ** rebase các commit đã push lên remote mà người khác đang dùng. Chỉ rebase commit local chưa push hoặc commit trên nhánh cá nhân của bạn.

4. **Cherry-pick — Hái commit từ nhánh khác:**

```bash
# Lấy 1 commit cụ thể từ nhánh khác về nhánh hiện tại
git log --oneline test-conflict  # Tìm hash commit cần lấy
git cherry-pick <hash-commit>
```
*(Giải thích: `cherry-pick` copy một commit vào nhánh hiện tại mà không cần merge toàn bộ nhánh. Rất hữu ích khi cần lấy một hotfix cụ thể).*

**Bước 9: Thực hành Git & GitHub**

1. **Tạo file `.gitignore`:** Để ngăn Git vô tình theo dõi (track) các file nhị phân thực thi (như `app_c`, `app_cpp`) hoặc các file rác, hãy tạo một file `.gitignore` trong thư mục cá nhân của bạn:

```bash
nano .gitignore
```
*(Gõ vào tên các file bạn muốn bỏ qua như `app_c`, `app_cpp`, `*.log`, `__pycache__` rồi lưu lại).*

2. Add và commit các file của bạn (bao gồm `.sh`, `.c`, `.cpp`, `.py`, `command_history.txt` và `.gitignore`. Các file nhị phân sẽ tự động bị bỏ qua nhờ `.gitignore`!):

```bash
git add .
git commit -m "feat(<ten-cua-ban>): Hoàn thành thực hành Linux commands và Bash scripts tuần 1"
```

3. Push nhánh của bạn lên remote repository:

```bash
git push origin <ten-cua-ban>/tuan1-linux-git
```

4. Lên GitHub, tạo Pull Request (PR). Tag ít nhất 1 thành viên khác vào Review Code.
5. Sau khi được Approve, tiến hành Merge vào `main` và xóa nhánh local.
