#!/bin/bash
set -e

# Configuration - UPDATE THESE VALUES
SOURCE_HOST="multiplex.c1gou6ower9g.ap-south-1.rds.amazonaws.com"
SOURCE_DB="multiplex"
SOURCE_USER="your_username"  # UPDATE THIS

TARGET_HOST=""  # Will be filled from Terraform output
TARGET_DB="multiplex"
TARGET_USER="your_username"  # UPDATE THIS

BACKUP_FILE="multiplex_backup_$(date +%Y%m%d_%H%M%S).dump"

echo "=== PostgreSQL Database Migration Script ==="
echo ""

# Check for required tools
if ! command -v pg_dump &> /dev/null; then
    echo "ERROR: pg_dump not found. Install PostgreSQL client tools."
    exit 1
fi

if ! command -v pg_restore &> /dev/null; then
    echo "ERROR: pg_restore not found. Install PostgreSQL client tools."
    exit 1
fi

# Get target host from Terraform if not set
if [ -z "$TARGET_HOST" ]; then
    echo "Fetching target database endpoint from Terraform..."
    cd "$(dirname "$0")/.."
    TARGET_HOST=$(terraform output -raw db_address 2>/dev/null || echo "")
    cd - > /dev/null

    if [ -z "$TARGET_HOST" ]; then
        echo "ERROR: Could not get target host. Run 'terraform apply' first or set TARGET_HOST manually."
        exit 1
    fi
fi

echo "Source: $SOURCE_HOST"
echo "Target: $TARGET_HOST"
echo "Backup file: $BACKUP_FILE"
echo ""

# Prompt for passwords
echo "Enter source database password:"
read -s SOURCE_PASSWORD
echo ""

echo "Enter target database password:"
read -s TARGET_PASSWORD
echo ""

# Export from source
echo "=== Step 1: Exporting from source database ==="
echo "This may take a while depending on database size..."
PGPASSWORD=$SOURCE_PASSWORD pg_dump \
    -h $SOURCE_HOST \
    -U $SOURCE_USER \
    -d $SOURCE_DB \
    -F c \
    -v \
    -f $BACKUP_FILE

echo ""
echo "Backup created: $BACKUP_FILE"
echo "Size: $(ls -lh $BACKUP_FILE | awk '{print $5}')"
echo ""

# Import to target
echo "=== Step 2: Importing to target database ==="
echo "This may take a while depending on database size..."
PGPASSWORD=$TARGET_PASSWORD pg_restore \
    -h $TARGET_HOST \
    -U $TARGET_USER \
    -d $TARGET_DB \
    -v \
    --no-owner \
    --no-privileges \
    $BACKUP_FILE

echo ""
echo "=== Database migration complete! ==="
echo ""
echo "Backup file retained at: $BACKUP_FILE"
echo ""
echo "Next steps:"
echo "1. Verify data in target database"
echo "2. Test application connectivity"
echo "3. Update DNS when ready for cutover"
echo "4. Delete backup file when no longer needed"
