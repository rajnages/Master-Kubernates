#!/bin/bash

# Backup Script
# This script creates backups of specified directories and databases

# Configuration
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/var/log/backup.log"
MAX_BACKUPS=7  # Keep last 7 backups

# Directories to backup (space-separated)
BACKUP_DIRS="/etc /var/www /home"

# MySQL database credentials
DB_USER="root"
DB_PASS="your_password"
DB_NAME="your_database"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# Cleanup old backups
cleanup_old_backups() {
    log "Cleaning up old backups..."
    cd $BACKUP_DIR
    ls -t | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm -rf
}

# Backup directories
backup_directories() {
    log "Starting directory backup..."
    
    for dir in $BACKUP_DIRS; do
        if [ -d "$dir" ]; then
            log "Backing up directory: $dir"
            tar -czf "$BACKUP_DIR/dir_backup_${DATE}_$(basename $dir).tar.gz" "$dir" 2>/dev/null
            if [ $? -eq 0 ]; then
                log "Successfully backed up $dir"
            else
                log "Error backing up $dir"
            fi
        else
            log "Directory $dir does not exist"
        fi
    done
}

# Backup MySQL database
backup_mysql() {
    log "Starting MySQL backup..."
    if command -v mysqldump &> /dev/null; then
        mysqldump -u$DB_USER -p$DB_PASS $DB_NAME > "$BACKUP_DIR/db_backup_${DATE}.sql" 2>/dev/null
        if [ $? -eq 0 ]; then
            log "Successfully backed up MySQL database"
            # Compress the database dump
            gzip "$BACKUP_DIR/db_backup_${DATE}.sql"
        else
            log "Error backing up MySQL database"
        fi
    else
        log "mysqldump command not found"
    fi
}

# Calculate total size of backup
calculate_backup_size() {
    total_size=$(du -sh "$BACKUP_DIR" | cut -f1)
    log "Total backup size: $total_size"
}

# Main backup process
log "=== Starting backup process ==="

# Create daily backup directory
DAILY_BACKUP_DIR="$BACKUP_DIR/backup_$DATE"
mkdir -p "$DAILY_BACKUP_DIR"

# Perform backups
backup_directories
backup_mysql

# Calculate and log backup size
calculate_backup_size

# Cleanup old backups
cleanup_old_backups

log "=== Backup process completed ==="

# Check backup success
if [ $? -eq 0 ]; then
    log "Backup completed successfully"
else
    log "Backup completed with errors"
fi
