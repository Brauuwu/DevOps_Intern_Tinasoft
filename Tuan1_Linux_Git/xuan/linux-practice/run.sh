#!/bin/bash
echo "=== Đang build C/C++ ==="
g++ main.cpp -o app_cpp
./app_cpp

echo "=== Đang chạy Python ==="
python3 script.py
