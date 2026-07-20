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

