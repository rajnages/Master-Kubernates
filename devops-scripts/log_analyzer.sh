#!/bin/bash

# Log Analyzer Script
# This script analyzes log files for patterns and potential issues

# Configuration
LOG_FILE="/var/log/syslog"  # Default log file to analyze
REPORT_FILE="log_analysis_report.txt"
ERROR_PATTERNS=("error" "failed" "critical" "exception" "warning")
DATE=$(date +%Y-%m-%d)

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Help function
show_help() {
    echo "Usage: $0 [-f log_file] [-o output_file]"
    echo "Options:"
    echo "  -f    Specify input log file (default: /var/log/syslog)"
    echo "  -o    Specify output report file (default: log_analysis_report.txt)"
    echo "  -h    Show this help message"
    exit 0
}

# Parse command line arguments
while getopts "f:o:h" opt; do
    case $opt in
        f) LOG_FILE="$OPTARG";;
        o) REPORT_FILE="$OPTARG";;
        h) show_help;;
        \?) echo "Invalid option -$OPTARG" >&2; exit 1;;
    esac
done

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo -e "${RED}Error: Log file $LOG_FILE not found${NC}"
    exit 1
fi

# Create report header
echo "Log Analysis Report - $DATE" > "$REPORT_FILE"
echo "Analyzed file: $LOG_FILE" >> "$REPORT_FILE"
echo "----------------------------------------" >> "$REPORT_FILE"

# Function to count occurrences of a pattern
count_pattern() {
    local pattern=$1
    local count=$(grep -i "$pattern" "$LOG_FILE" | wc -l)
    echo "$count"
}

# Analyze error patterns
echo -e "\nAnalyzing error patterns..."
echo -e "\nError Pattern Analysis:" >> "$REPORT_FILE"
for pattern in "${ERROR_PATTERNS[@]}"; do
    count=$(count_pattern "$pattern")
    echo -e "${YELLOW}Found $count occurrences of '$pattern'${NC}"
    echo "- $pattern: $count occurrences" >> "$REPORT_FILE"
    
    if [ $count -gt 0 ]; then
        echo -e "\nLast 3 occurrences of '$pattern':" >> "$REPORT_FILE"
        grep -i "$pattern" "$LOG_FILE" | tail -n 3 >> "$REPORT_FILE"
        echo "----------------------------------------" >> "$REPORT_FILE"
    fi
done

# Get top IP addresses (if any)
echo -e "\nAnalyzing IP addresses..."
echo -e "\nTop 10 IP Addresses:" >> "$REPORT_FILE"
grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 10 >> "$REPORT_FILE"

# Get hourly activity distribution
echo -e "\nAnalyzing hourly distribution..."
echo -e "\nHourly Activity Distribution:" >> "$REPORT_FILE"
awk '{print $3}' "$LOG_FILE" | cut -c 1-2 | sort | uniq -c >> "$REPORT_FILE"

# Get total log size
log_size=$(du -h "$LOG_FILE" | cut -f1)
echo -e "\nLog File Statistics:" >> "$REPORT_FILE"
echo "- Total Size: $log_size" >> "$REPORT_FILE"
echo "- Total Lines: $(wc -l < "$LOG_FILE")" >> "$REPORT_FILE"

# Get today's entries
echo -e "\nToday's Log Entries:" >> "$REPORT_FILE"
today=$(date +%b" "%d)
grep "$today" "$LOG_FILE" | wc -l >> "$REPORT_FILE"

echo -e "\nLog analysis completed. Report saved to $REPORT_FILE"
