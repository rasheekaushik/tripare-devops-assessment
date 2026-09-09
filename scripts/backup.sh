#!/usr/bin/env bash

set -euo pipefail

CONTAINER_NAME="${POSTGRES_CONTAINER:-tripare-postgres}"
DB_NAME="${POSTGRES_DB:-tripare}"
DB_USER="${POSTGRES_USER:-tripare_user}"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${PROJECT_ROOT}/database/backups"

mkdir -p "${BACKUP_DIR}"

TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.sql"

echo "Checking PostgreSQL container..."

if ! docker inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
    echo "ERROR: Container ${CONTAINER_NAME} does not exist."
    echo "Start PostgreSQL with: docker compose -f database/docker-compose.yml up -d"
    exit 1
fi

if ! docker exec "${CONTAINER_NAME}" pg_isready -U "${DB_USER}" -d "${DB_NAME}" >/dev/null 2>&1; then
    echo "ERROR: PostgreSQL is not ready."
    exit 1
fi

echo "Creating backup..."

docker exec "${CONTAINER_NAME}" \
    pg_dump \
    -U "${DB_USER}" \
    -d "${DB_NAME}" \
    --no-owner \
    --no-privileges \
    > "${BACKUP_FILE}"

if [[ ! -s "${BACKUP_FILE}" ]]; then
    echo "ERROR: Backup file is empty."
    rm -f "${BACKUP_FILE}"
    exit 1
fi

echo "Backup created successfully:"
echo "${BACKUP_FILE}"

echo
echo "Backup size:"
du -h "${BACKUP_FILE}"
