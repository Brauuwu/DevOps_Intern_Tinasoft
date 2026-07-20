#!/bin/bash


FILE_NAME="$HOME/system_report.txt"

touch $FILE_NAME
df -h >> $FILE_NAME
echo "\n" >> $FILE_NAME
free -m >> $FILE_NAME
echo "\n" >> $FILE_NAME
uname -a >> $FILE_NAME


