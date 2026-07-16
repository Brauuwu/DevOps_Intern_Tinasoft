#!/bin/bash

# Nhập tên user
read -p "Nhập tên user cần kiểm tra: " username

# Kiểm tra user có tồn tại trong /etc/passwd hay không
if grep -q "^${username}:" /etc/passwd; then
    echo "User '$username' tồn tại."
else
    echo "User '$username' không tồn tại."
fi
