-- ============================================================
-- Tripare AI DevOps Assessment
-- PostgreSQL Query Optimization
-- ============================================================

-- Check the current execution plan
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 3
AND status = 'completed';

-- Composite index to optimize the query
CREATE INDEX IF NOT EXISTS idx_orders_customer_status
ON orders(customer_id, status);

-- Verify the optimized execution plan
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 3
AND status = 'completed';

-- Verify index usage
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'orders';
