#!/bin/bash
{
  echo "=== THÔNG TIN Ổ CỨNG ==="
  df -h
  echo -e "\n=== THÔNG TIN RAM ==="
  free -m
  echo -e "\n=== PHIÊN BẢN HỆ ĐIỀU HÀNH ==="
  uname -a
} > ../system_report.txt
echo "Đã lưu báo cáo vào system_report.txt"
