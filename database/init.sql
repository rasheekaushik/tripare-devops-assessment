-- ============================================================
-- Tripare AI DevOps Assessment
-- PostgreSQL database initialization
-- ============================================================

-- Customers
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    city VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(30) NOT NULL
);

-- Products
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    price NUMERIC(10, 2) NOT NULL
);

-- Order items
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id),
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0)
);

-- ============================================================
-- Sample customers
-- ============================================================

INSERT INTO customers (name, email, city) VALUES
('Aarav Sharma', 'aarav@example.com', 'Delhi'),
('Priya Mehta', 'priya@example.com', 'Mumbai'),
('Rahul Verma', 'rahul@example.com', 'Bangalore'),
('Ananya Singh', 'ananya@example.com', 'Pune'),
('Karan Gupta', 'karan@example.com', 'Gurgaon');

-- ============================================================
-- Sample products
-- ============================================================

INSERT INTO products (product_name, category, price) VALUES
('Laptop', 'Electronics', 75000.00),
('Keyboard', 'Electronics', 2500.00),
('Mouse', 'Electronics', 1200.00),
('Monitor', 'Electronics', 18000.00),
('Headphones', 'Accessories', 5000.00),
('USB Cable', 'Accessories', 500.00);

-- ============================================================
-- Sample orders
-- ============================================================

INSERT INTO orders (customer_id, order_date, amount, status) VALUES
(1, CURRENT_TIMESTAMP - INTERVAL '10 days', 77500.00, 'completed'),
(2, CURRENT_TIMESTAMP - INTERVAL '8 days', 18000.00, 'completed'),
(3, CURRENT_TIMESTAMP - INTERVAL '5 days', 6200.00, 'pending'),
(4, CURRENT_TIMESTAMP - INTERVAL '3 days', 75000.00, 'completed'),
(5, CURRENT_TIMESTAMP - INTERVAL '1 day', 5000.00, 'cancelled');

-- ============================================================
-- Sample order items
-- ============================================================

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 2, 1),
(2, 4, 1),
(3, 5, 1),
(3, 6, 2),
(4, 1, 1),
(5, 5, 1);

-- ============================================================
-- Useful initial indexes
-- ============================================================

CREATE INDEX idx_orders_customer_id
ON orders(customer_id);

CREATE INDEX idx_orders_order_date
ON orders(order_date);

CREATE INDEX idx_order_items_order_id
ON order_items(order_id);

CREATE INDEX idx_order_items_product_id
ON order_items(product_id);
