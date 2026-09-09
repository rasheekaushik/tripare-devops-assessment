#!/bin/bash

set -euo pipefail

CONTAINER_NAME="tripare-postgres"
DB_NAME="tripare"
DB_USER="tripare_user"

BACKUP_DIR="$(cd "$(dirname "$0")" && pwd)/backups"
TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
BACKUP_FILE="${BACKUP_DIR}/tripare_${TIMESTAMP}.sql"

mkdir -p "$BACKUP_DIR"

echo "Starting PostgreSQL backup..."
echo "Database: $DB_NAME"
echo "Backup file: $BACKUP_FILE"

docker exec "$CONTAINER_NAME" \
    pg_dump \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    --format=plain \
    --file="/tmp/tripare_backup.sql"

docker cp \
    "$CONTAINER_NAME:/tmp/tripare_backup.sql" \
    "$BACKUP_FILE"

docker exec "$CONTAINER_NAME" \
    rm -f /tmp/tripare_backup.sql

echo "Backup completed successfully."
echo "Backup saved to: $BACKUP_FILE"
