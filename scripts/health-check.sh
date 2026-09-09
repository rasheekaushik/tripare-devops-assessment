#!/usr/bin/env bash

set -euo pipefail

CONTAINER_NAME="${POSTGRES_CONTAINER:-tripare-postgres}"
DB_NAME="${POSTGRES_DB:-tripare}"
DB_USER="${POSTGRES_USER:-tripare_user}"

echo "========================================"
echo "Tripare Database Health Check"
echo "========================================"

echo
echo "1. Checking PostgreSQL readiness..."

docker exec "${CONTAINER_NAME}" \
    pg_isready \
    -U "${DB_USER}" \
    -d "${DB_NAME}" \
    >/dev/null

echo "PASS: PostgreSQL is ready."

echo
echo "2. Checking required tables..."

TABLE_COUNT="$(
    docker exec "${CONTAINER_NAME}" \
    psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
    "SELECT COUNT(*)
     FROM information_schema.tables
     WHERE table_schema = 'public'
       AND table_name IN ('hotel_bookings', 'booking_events');"
)"

if [[ "${TABLE_COUNT}" -ne 2 ]]; then
    echo "FAIL: Required tables are missing."
    exit 1
fi

echo "PASS: Required tables exist."

echo
echo "3. Checking hotel bookings..."

BOOKING_COUNT="$(
    docker exec "${CONTAINER_NAME}" \
    psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
    "SELECT COUNT(*) FROM hotel_bookings;"
)"

echo "hotel_bookings rows: ${BOOKING_COUNT}"

if [[ "${BOOKING_COUNT}" -lt 100 ]]; then
    echo "FAIL: Expected at least 100 hotel bookings."
    exit 1
fi

echo "PASS: hotel_bookings contains at least 100 rows."

echo
echo "4. Checking booking events..."

EVENT_COUNT="$(
    docker exec "${CONTAINER_NAME}" \
    psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
    "SELECT COUNT(*) FROM booking_events;"
)"

echo "booking_events rows: ${EVENT_COUNT}"

if [[ "${EVENT_COUNT}" -lt 1 ]]; then
    echo "FAIL: booking_events is empty."
    exit 1
fi

echo "PASS: booking_events contains data."

echo
echo "5. Checking multiple cities..."

CITY_COUNT="$(
    docker exec "${CONTAINER_NAME}" \
    psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
    "SELECT COUNT(DISTINCT city) FROM hotel_bookings;"
)"

echo "Distinct cities: ${CITY_COUNT}"

if [[ "${CITY_COUNT}" -lt 2 ]]; then
    echo "FAIL: Seed data should contain multiple cities."
    exit 1
fi

echo "PASS: Multiple cities present."

echo
echo "6. Checking multiple organizations..."

ORG_COUNT="$(
    docker exec "${CONTAINER_NAME}" \
    psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
    "SELECT COUNT(DISTINCT org_id) FROM hotel_bookings;"
)"

echo "Distinct organizations: ${ORG_COUNT}"

if [[ "${ORG_COUNT}" -lt 2 ]]; then
    echo "FAIL: Seed data should contain multiple organizations."
    exit 1
fi

echo "PASS: Multiple organizations present."

echo
echo "7. Checking multiple booking statuses..."

STATUS_COUNT="$(
    docker exec "${CONTAINER_NAME}" \
    psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
    "SELECT COUNT(DISTINCT status) FROM hotel_bookings;"
)"

echo "Distinct statuses: ${STATUS_COUNT}"

if [[ "${STATUS_COUNT}" -lt 2 ]]; then
    echo "FAIL: Seed data should contain multiple statuses."
    exit 1
fi

echo "PASS: Multiple statuses present."

echo
echo "8. Checking optimization index..."

INDEX_EXISTS="$(
    docker exec "${CONTAINER_NAME}" \
    psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
    "SELECT COUNT(*)
     FROM pg_indexes
     WHERE schemaname = 'public'
       AND indexname = 'idx_hotel_bookings_city_created_at';"
)"

if [[ "${INDEX_EXISTS}" -ne 1 ]]; then
    echo "FAIL: Optimization index is missing."
    exit 1
fi

echo "PASS: Optimization index exists."

echo
echo "========================================"
echo "ALL DATABASE HEALTH CHECKS PASSED"
echo "========================================"
