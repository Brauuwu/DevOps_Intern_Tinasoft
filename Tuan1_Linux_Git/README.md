# Tuần 1: Tìm hiểu tổng quan về DevOps, Linux, Bash Shell, Git

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

5. Phân quyền file: Chỉ cho phép đọc, sau đó thử ghi dữ liệu xem hệ thống báo lỗi thế nào, rồi đổi lại quyền cũ:

```bash
chmod 400 text.txt
echo "Test" >> text.txt
chmod 644 text.txt
```

6. Tương tác với mạng: Kiểm tra địa chỉ IP của máy ảo bằng lệnh `ip a` hoặc `ifconfig`. Kiểm tra mạng và gọi HTTP:

```bash
ping 8.8.8.8
curl -I https://google.com
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

**Bước 5: Thực hành Git & GitHub**

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
