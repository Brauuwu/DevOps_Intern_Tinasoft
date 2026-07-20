#!/bin/bash
echo "=== Đang build C/C++ ==="
gcc main.c -o app_c
./app_c
g++ main.cpp -o app_cpp
./app_cpp

echo "=== Đang chạy Python ==="
python3 script.py
