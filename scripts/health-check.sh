#!/bin/bash

set -euo pipefail

CONTAINER_NAME="tripare-postgres"
DB_NAME="tripare"
DB_USER="tripare_user"

echo "======================================"
echo "Tripare PostgreSQL Health Check"
echo "======================================"

echo
echo "1. Checking Docker container..."

if docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    echo "PASS: PostgreSQL container exists."
else
    echo "FAIL: PostgreSQL container does not exist."
    exit 1
fi

echo
echo "2. Checking container status..."

STATUS=$(docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME")

if [ "$STATUS" = "running" ]; then
    echo "PASS: Container is running."
else
    echo "FAIL: Container status is $STATUS."
    exit 1
fi

echo
echo "3. Checking PostgreSQL readiness..."

if docker exec "$CONTAINER_NAME" \
    pg_isready -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; then
    echo "PASS: PostgreSQL is accepting connections."
else
    echo "FAIL: PostgreSQL is not ready."
    exit 1
fi

echo
echo "4. Checking database..."

TABLE_COUNT=$(docker exec "$CONTAINER_NAME" \
    psql -U "$DB_USER" -d "$DB_NAME" -tAc \
    "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';")

if [ "$TABLE_COUNT" -ge 4 ]; then
    echo "PASS: Database contains $TABLE_COUNT tables."
else
    echo "FAIL: Expected at least 4 tables, found $TABLE_COUNT."
    exit 1
fi

echo
echo "5. Checking orders..."

ORDER_COUNT=$(docker exec "$CONTAINER_NAME" \
    psql -U "$DB_USER" -d "$DB_NAME" -tAc \
    "SELECT COUNT(*) FROM orders;")

if [ "$ORDER_COUNT" -gt 0 ]; then
    echo "PASS: Orders table contains $ORDER_COUNT rows."
else
    echo "FAIL: Orders table is empty."
    exit 1
fi

echo
echo "======================================"
echo "HEALTH CHECK PASSED"
echo "======================================"
