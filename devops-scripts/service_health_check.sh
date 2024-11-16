#!/bin/bash

# Service Health Check Script
# This script monitors the health of various services and endpoints

# Configuration
CONFIG_FILE="services.conf"
LOG_FILE="health_check.log"
SLACK_WEBHOOK_URL="your_slack_webhook_url"
EMAIL_TO="admin@example.com"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check HTTP endpoint
check_http() {
    local url=$1
    local expected_code=${2:-200}
    local timeout=${3:-10}
    
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$timeout" "$url")
    
    if [ "$response" = "$expected_code" ]; then
        echo 0  # Success
    else
        echo 1  # Failure
    fi
}

# Function to check TCP port
check_tcp() {
    local host=$1
    local port=$2
    local timeout=${3:-5}
    
    nc -z -w "$timeout" "$host" "$port" > /dev/null 2>&1
    echo $?
}

# Function to check process
check_process() {
    local process=$1
    pgrep -f "$process" > /dev/null
    echo $?
}

# Function to send Slack notification
send_slack_notification() {
    local message=$1
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        curl -s -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$message\"}" \
            "$SLACK_WEBHOOK_URL"
    fi
}

# Function to send email notification
send_email_notification() {
    local subject="Service Health Check Alert"
    local body=$1
    
    if command -v mail &> /dev/null; then
        echo "$body" | mail -s "$subject" "$EMAIL_TO"
    else
        log "${YELLOW}Warning: 'mail' command not found. Could not send email notification${NC}"
    fi
}

# Create example config if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << EOF
# Service configuration file
# Format: TYPE|NAME|TARGET|EXPECTED_RESULT|TIMEOUT
# Types: http, tcp, process
http|Website|https://example.com|200|10
tcp|Database|localhost|5432|5
process|Nginx|nginx|running|
EOF
    log "Created example config file: $CONFIG_FILE"
fi

# Main health check function
perform_health_check() {
    local type=$1
    local name=$2
    local target=$3
    local expected=$4
    local timeout=$5
    local status
    
    case $type in
        "http")
            status=$(check_http "$target" "$expected" "$timeout")
            ;;
        "tcp")
            status=$(check_tcp "$target" "$expected" "$timeout")
            ;;
        "process")
            status=$(check_process "$target")
            ;;
        *)
            log "${RED}Unknown check type: $type${NC}"
            return 1
            ;;
    esac
    
    if [ "$status" -eq 0 ]; then
        log "${GREEN}[OK] $name is healthy${NC}"
        return 0
    else
        log "${RED}[FAIL] $name is not responding${NC}"
        return 1
    fi
}

# Main script
log "=== Starting Service Health Check ==="

# Array to store failed services
declare -a failed_services

# Read and process config file
while IFS='|' read -r type name target expected timeout || [ -n "$type" ]; do
    # Skip comments and empty lines
    [[ -z "$type" || "$type" =~ ^[[:space:]]*# ]] && continue
    
    log "Checking $name..."
    if ! perform_health_check "$type" "$name" "$target" "$expected" "$timeout"; then
        failed_services+=("$name")
    fi
done < "$CONFIG_FILE"

# Send notifications if there are failures
if [ ${#failed_services[@]} -gt 0 ]; then
    notification="❌ Service Health Check Alert!\n\nThe following services are down:\n"
    for service in "${failed_services[@]}"; do
        notification+="- $service\n"
    done
    
    send_slack_notification "$notification"
    send_email_notification "$notification"
fi

log "=== Service Health Check Completed ==="

# Exit with status 1 if any service failed
[ ${#failed_services[@]} -gt 0 ] && exit 1 || exit 0
