-- Tripare AI DevOps Assessment
-- Seed data for local development/testing

INSERT INTO customers (name, email)
VALUES
    ('Aarav Sharma', 'aarav@example.com'),
    ('Diya Patel', 'diya@example.com'),
    ('Arjun Mehta', 'arjun@example.com'),
    ('Ananya Singh', 'ananya@example.com'),
    ('Kabir Verma', 'kabir@example.com')
ON CONFLICT (email) DO NOTHING;

INSERT INTO products (name, price)
VALUES
    ('Laptop', 75000.00),
    ('Keyboard', 2500.00),
    ('Mouse', 1200.00),
    ('Monitor', 18000.00),
    ('Headphones', 5000.00),
    ('Webcam', 3500.00)
ON CONFLICT DO NOTHING;

INSERT INTO orders (customer_id, amount, status)
VALUES
    (1, 77500.00, 'completed'),
    (2, 18000.00, 'completed'),
    (3, 6200.00, 'pending'),
    (4, 5000.00, 'completed'),
    (5, 3500.00, 'pending');

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES
    (1, 1, 1, 75000.00),
    (1, 2, 1, 2500.00),
    (2, 4, 1, 18000.00),
    (3, 2, 1, 2500.00),
    (3, 3, 1, 1200.00),
    (3, 6, 1, 3500.00),
    (4, 5, 1, 5000.00);
