#!/usr/bin/env bash

set -euo pipefail

CONTAINER_NAME="${POSTGRES_CONTAINER:-tripare-postgres}"
DB_USER="${POSTGRES_USER:-tripare_user}"
RESTORE_DB="${RESTORE_DB:-tripare_restore_test}"


if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <backup-file>"
    echo
    echo "Example:"
    echo "  $0 database/backups/tripare_YYYYMMDD_HHMMSS.sql"
    exit 1
fi

BACKUP_FILE="$1"

if [[ ! -f "${BACKUP_FILE}" ]]; then
    echo "ERROR: Backup file not found: ${BACKUP_FILE}"
    exit 1
fi

if [[ ! -s "${BACKUP_FILE}" ]]; then
    echo "ERROR: Backup file is empty: ${BACKUP_FILE}"
    exit 1
fi

echo "Checking PostgreSQL..."

if ! docker exec "${CONTAINER_NAME}" pg_isready -U "${DB_USER}" >/dev/null 2>&1; then
    echo "ERROR: PostgreSQL is not ready."
    exit 1
fi

echo "Preparing fresh restore database: ${RESTORE_DB}"

docker exec "${CONTAINER_NAME}" \
    psql -U "${DB_USER}" -d postgres \
    -v ON_ERROR_STOP=1 \
    -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${RESTORE_DB}' AND pid <> pg_backend_pid();" \
    >/dev/null

docker exec "${CONTAINER_NAME}" \
    psql -U "${DB_USER}" -d postgres \
    -v ON_ERROR_STOP=1 \
    -c "DROP DATABASE IF EXISTS ${RESTORE_DB};"

docker exec "${CONTAINER_NAME}" \
    psql -U "${DB_USER}" -d postgres \
    -v ON_ERROR_STOP=1 \
    -c "CREATE DATABASE ${RESTORE_DB};"

echo "Restoring backup..."

docker exec -i "${CONTAINER_NAME}" \
    psql -U "${DB_USER}" -d "${RESTORE_DB}" \
    -v ON_ERROR_STOP=1 \
    < "${BACKUP_FILE}"

echo
echo "Restore completed successfully."

echo
echo "Verifying restored database..."

BOOKING_COUNT="$(
    docker exec "${CONTAINER_NAME}" \
    psql -U "${DB_USER}" -d "${RESTORE_DB}" -tAc \
    "SELECT COUNT(*) FROM hotel_bookings;"
)"

EVENT_COUNT="$(
    docker exec "${CONTAINER_NAME}" \
    psql -U "${DB_USER}" -d "${RESTORE_DB}" -tAc \
    "SELECT COUNT(*) FROM booking_events;"
)"

echo "hotel_bookings rows: ${BOOKING_COUNT}"
echo "booking_events rows: ${EVENT_COUNT}"

if [[ "${BOOKING_COUNT}" -lt 100 ]]; then
    echo "ERROR: Restored hotel_bookings contains fewer than 100 rows."
    exit 1
fi

if [[ "${EVENT_COUNT}" -lt 1 ]]; then
    echo "ERROR: Restored booking_events is empty."
    exit 1
fi

echo
echo "Restore verification PASSED."
echo "Restored database: ${RESTORE_DB}"
