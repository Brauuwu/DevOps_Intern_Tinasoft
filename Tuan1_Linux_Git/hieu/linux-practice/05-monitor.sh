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
