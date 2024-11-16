#!/bin/bash

# System Resource Monitoring Script
# This script monitors CPU, Memory, and Disk usage

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

echo "=== System Resource Monitor ==="
date

# CPU Usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
echo -e "\nCPU Usage: $cpu_usage%"
if [ $cpu_usage -gt $CPU_THRESHOLD ]; then
    echo -e "${RED}[ALERT] High CPU usage detected!${NC}"
fi

# Memory Usage
memory_usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
echo -e "\nMemory Usage: $memory_usage%"
if [ $memory_usage -gt $MEMORY_THRESHOLD ]; then
    echo -e "${RED}[ALERT] High memory usage detected!${NC}"
fi

# Disk Usage
echo -e "\nDisk Usage:"
df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
do
    usage=$(echo $output | awk '{print $1}' | cut -d'%' -f1)
    partition=$(echo $output | awk '{print $2}')
    
    if [ $usage -gt $DISK_THRESHOLD ]; then
        echo -e "${RED}[ALERT] Partition $partition is ${usage}% full!${NC}"
    else
        echo -e "${GREEN}Partition $partition is ${usage}% full${NC}"
    fi
done

# System Load
load_average=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1)
echo -e "\nSystem Load Average: $load_average"

# List Top 5 CPU-consuming processes
echo -e "\nTop 5 CPU-consuming processes:"
ps aux | sort -nr -k 3 | head -5

# List Top 5 Memory-consuming processes
echo -e "\nTop 5 Memory-consuming processes:"
ps aux | sort -nr -k 4 | head -5
