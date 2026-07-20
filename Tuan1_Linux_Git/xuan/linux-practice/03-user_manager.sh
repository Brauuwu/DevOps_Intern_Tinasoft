#!/bin/bash

read -p "Nhap ten user can check: " USERNAME

if [ -z "USERNAME" ]; then
	echo "Khong duoc de trong ten"
	exit 1
fi

if cat /etc/passwd | grep -w -q "$USERNAME"; then
	echo "User $USERNAME co ton tai tren he thong "
else 
	echo "User $USERNAME khong ton tai tren he thong"
fi



