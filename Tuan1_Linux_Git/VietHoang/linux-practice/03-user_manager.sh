#!/bin/bash
read -p "Nhập tên user cần kiểm tra: " USERNAME
if grep -q "^$USERNAME:" /etc/passwd; then
    echo "User '$USERNAME' TỒN TẠI trên hệ thống."
else
    echo "User '$USERNAME' KHÔNG tồn tại."
fi
