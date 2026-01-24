#!/bin/bash

# ==============================================================================
# NAS Backup Script using rsync
# ==============================================================================
#
# This script synchronizes specified files and folders to a destination,
# typically a NAS (Network Attached Storage) device.
#
#
# HOW TO USE:
#
# 1. CONFIGURE THE VARIABLES:
#    - SOURCES: An array of absolute paths for the files and folders you
#               want to back up.
#    - DESTINATION: The absolute path to the backup folder on your mounted NAS.
#    - LOG_FILE: The path to the log file for recording backup operations.
#
# 2. SET PERMISSIONS:
#    Make the script executable:
#    chmod +x backup_rsync.sh
#
# 3. PERFORM A MANUAL TEST:
#    Run the script from your terminal to ensure it works as expected:
#    ./backup_rsync.sh
#
# 4. SCHEDULE WITH CRON:
#    - Open your crontab for editing:
#      crontab -e
#    - Add a line to schedule the script. For example, to run it daily at
#      2:00 AM, add the following:
#      0 2 * * * /path/to/your/backup_rsync.sh
#
# ==============================================================================

# --- CONFIGURATION ---

# Add the full paths of the files and folders you want to back up.
# Separate each entry with a space.
# Example: SOURCES=("/home/user/documents" "/home/user/photos" "/etc/hosts")
SOURCES=(
    "/folder/home"
)

# The destination folder on your NAS.
# IMPORTANT: This directory must be mounted and accessible.
# Example: DESTINATION="/mnt/nas/my_backups"
DESTINATION="/mnt/nas/backup"

# The log file for recording backup activity.
LOG_FILE="/var/log/nas_backup.log"


# --- SCRIPT LOGIC (Do not edit below this line) ---

# Function for logging messages with a timestamp.
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

# --- Begin Execution ---

log "===== NAS Backup Started ====="

# 1. Check if the destination is a mounted directory.
# This is a crucial safety check to prevent rsync from creating a new
# folder on your root filesystem if the NAS is not connected.
if ! mountpoint -q -- "$DESTINATION"; then
    log "ERROR: The destination '$DESTINATION' is not a mountpoint. Is the NAS connected?"
    log "Aborting backup to prevent data loss."
    log "===== NAS Backup Failed ====="
    exit 1
fi

# 2. Check if there are sources to back up.
if [ ${#SOURCES[@]} -eq 0 ]; then
    log "WARNING: No source files or folders are defined in the SOURCES array."
    log "===== NAS Backup Finished (with warnings) ====="
    exit 0
fi

# 3. Create subfolder with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$DESTINATION/backup_$TIMESTAMP"

mkdir -p "$BACKUP_DIR"
if [ $? -ne 0 ]; then
    log "ERROR: Failed to create backup directory '$BACKUP_DIR'. Aborting."
    exit 1
fi

log "Backup directory created: $BACKUP_DIR"

# 4. Loop through each source and synchronize it to the destination.
for SOURCE in "${SOURCES[@]}"; do
    if [ -e "$SOURCE" ]; then
        log "Syncing '$SOURCE' to '$DESTINATION'..."
        # The -a option is for archive mode (preserves permissions, ownership, etc.).
        rsync -a "$SOURCE" "$BACKUP_DIR" >> "$LOG_FILE" 2>&1
        
        if [ $? -eq 0 ]; then
            log "SUCCESS: '$SOURCE' synchronized successfully."
        else
            log "ERROR: Failed to synchronize '$SOURCE'. Check the log for details."
        fi
    else
        log "WARNING: Source '$SOURCE' does not exist. Skipping."
    fi
done

log "===== NAS Backup Finished ====="

exit 0
