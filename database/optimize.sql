-- Query optimization demonstration
-- Required assessment query:
-- Filter by city and the last 30 days, then aggregate by org and status.

\echo '============================================================'
\echo 'BEFORE INDEX'
\echo '============================================================'

DROP INDEX IF EXISTS idx_hotel_bookings_city_created_at;

ANALYZE hotel_bookings;

EXPLAIN ANALYZE
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;


\echo '============================================================'
\echo 'CREATE OPTIMIZATION INDEX'
\echo '============================================================'

CREATE INDEX idx_hotel_bookings_city_created_at
    ON hotel_bookings(city, created_at);

ANALYZE hotel_bookings;


\echo '============================================================'
\echo 'AFTER INDEX'
\echo '============================================================'

EXPLAIN ANALYZE
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
