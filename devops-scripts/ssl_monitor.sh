#!/bin/bash

# SSL Certificate Monitor Script
# This script monitors SSL certificate expiration dates for specified domains

# Configuration
DOMAINS_FILE="domains.txt"  # One domain per line
DAYS_WARNING=30  # Warning threshold in days
EMAIL_TO="admin@example.com"
LOG_FILE="ssl_check.log"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check if openssl is installed
if ! command -v openssl &> /dev/null; then
    log "${RED}Error: OpenSSL is not installed${NC}"
    exit 1
fi

# Function to check certificate expiration
check_certificate() {
    local domain=$1
    local exp_date
    local days_remaining
    
    # Get certificate expiration date
    exp_date=$(echo | openssl s_client -servername "$domain" -connect "$domain":443 2>/dev/null | \
               openssl x509 -noout -enddate 2>/dev/null | \
               cut -d= -f2)
    
    if [ -z "$exp_date" ]; then
        log "${RED}Error: Could not get certificate for $domain${NC}"
        return 1
    }
    
    # Convert dates to seconds since epoch
    exp_seconds=$(date -d "$exp_date" +%s)
    now_seconds=$(date +%s)
    
    # Calculate days remaining
    days_remaining=$(( (exp_seconds - now_seconds) / 86400 ))
    
    # Output results
    if [ $days_remaining -lt 0 ]; then
        log "${RED}[EXPIRED] $domain - Certificate expired $((days_remaining * -1)) days ago${NC}"
        return 2
    elif [ $days_remaining -lt $DAYS_WARNING ]; then
        log "${YELLOW}[WARNING] $domain - Certificate will expire in $days_remaining days${NC}"
        return 3
    else
        log "${GREEN}[OK] $domain - Certificate will expire in $days_remaining days${NC}"
        return 0
    fi
}

# Function to send email notification
send_notification() {
    local subject="SSL Certificate Status Alert"
    local body="$1"
    
    if command -v mail &> /dev/null; then
        echo "$body" | mail -s "$subject" "$EMAIL_TO"
        log "Notification email sent to $EMAIL_TO"
    else
        log "${YELLOW}Warning: 'mail' command not found. Could not send notification${NC}"
    fi
}

# Main script
log "=== Starting SSL Certificate Check ==="

# Create results array
declare -a results

# Check if domains file exists
if [ ! -f "$DOMAINS_FILE" ]; then
    log "${YELLOW}Warning: $DOMAINS_FILE not found. Creating example file...${NC}"
    echo "example.com
www.example.com" > "$DOMAINS_FILE"
fi

# Process each domain
while IFS= read -r domain || [ -n "$domain" ]; do
    # Skip empty lines and comments
    [[ -z "$domain" || "$domain" =~ ^[[:space:]]*# ]] && continue
    
    log "Checking certificate for $domain..."
    check_certificate "$domain"
    status=$?
    
    case $status in
        0) results+=("✓ $domain - OK");;
        1) results+=("✗ $domain - Error getting certificate");;
        2) results+=("! $domain - Certificate expired");;
        3) results+=("⚠ $domain - Certificate expiring soon");;
    esac
done < "$DOMAINS_FILE"

# Generate report
report="SSL Certificate Status Report - $(date '+%Y-%m-%d %H:%M:%S')\n\n"
for result in "${results[@]}"; do
    report+="$result\n"
done

# Send notification if there are any warnings or errors
if echo "$report" | grep -q -E "Error|expired|expiring"; then
    send_notification "$report"
fi

log "=== SSL Certificate Check Completed ==="
echo -e "\nDetailed results have been saved to $LOG_FILE"
