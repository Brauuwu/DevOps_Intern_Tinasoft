#!/bin/bash
BACKUP_DIR="/tmp/backups"
SOURCE_DIR="${1:-.}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="backup_${TIMESTAMP}.tar.gz"

mkdir -p "$BACKUP_DIR"
tar -czf "${BACKUP_DIR}/${FILENAME}" "$SOURCE_DIR"
echo "[OK] Backup thành công: ${BACKUP_DIR}/${FILENAME}"
echo "[INFO] Kích thước: $(du -h ${BACKUP_DIR}/${FILENAME} | cut -f1)"
