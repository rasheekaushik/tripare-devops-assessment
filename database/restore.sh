#!/bin/bash

set -euo pipefail

CONTAINER_NAME="tripare-postgres"
DB_NAME="tripare"
DB_USER="tripare_user"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <backup_file.sql>"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "Starting PostgreSQL restore..."
echo "Backup file: $BACKUP_FILE"

docker cp \
    "$BACKUP_FILE" \
    "$CONTAINER_NAME:/tmp/tripare_restore.sql"

docker exec "$CONTAINER_NAME" \
    psql \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -v ON_ERROR_STOP=1 \
    -f /tmp/tripare_restore.sql

docker exec "$CONTAINER_NAME" \
    rm -f /tmp/tripare_restore.sql

echo "Restore completed successfully."
