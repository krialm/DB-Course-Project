-- Online Store Database Project (PostgreSQL version)
-- This script can be run in psql or pgAdmin.
-- Adjust the database name if you want a dedicated DB.

-- Optional: create and connect to a separate database
-- CREATE DATABASE online_store_db;
-- \c online_store_db;

------------------------------------------------------------
-- 1. TABLES AND CONSTRAINTS
------------------------------------------------------------

-- Drop tables in dependency order if they already exist
DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;

-- Customers
CREATE TABLE customers (
    customer_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) UNIQUE,
    phone           VARCHAR(20),
    address         VARCHAR(200),
    city            VARCHAR(50),
    country         VARCHAR(50)
);

CREATE INDEX idx_customers_city ON customers(city);

-- Categories
CREATE TABLE categories (
    category_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name   VARCHAR(50) NOT NULL,
    description     VARCHAR(255)
);

-- Suppliers
CREATE TABLE suppliers (
    supplier_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_name   VARCHAR(100) NOT NULL,
    contact_name    VARCHAR(100),
    phone           VARCHAR(20),
    city            VARCHAR(50),
    country         VARCHAR(50)
);

CREATE INDEX idx_suppliers_country ON suppliers(country);

-- Products
CREATE TABLE products (
    product_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    supplier_id     INT NOT NULL,
    category_id     INT NOT NULL,
    unit_price      NUMERIC(10,2) NOT NULL,
    units_in_stock  INT NOT NULL,
    units_on_order  INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_products_supplier
        FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE UNIQUE INDEX ux_products_product_name ON products(product_name);
CREATE INDEX idx_products_category ON products(category_id);

-- Orders
CREATE TABLE orders (
    order_id        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id     INT NOT NULL,
    order_date      TIMESTAMP NOT NULL,
    required_date   TIMESTAMP,
    shipped_date    TIMESTAMP,
    freight         NUMERIC(10,2),
    order_status    VARCHAR(20) DEFAULT 'Pending',
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE INDEX idx_orders_order_date ON orders(order_date);

-- OrderDetails (junction table for many-to-many relationship)
CREATE TABLE order_details (
    order_detail_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id        INT NOT NULL,
    product_id      INT NOT NULL,
    quantity        INT NOT NULL,
    unit_price      NUMERIC(10,2) NOT NULL,
    discount        NUMERIC(4,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_order_details_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_order_details_product
        FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT uq_order_details_order_product
        UNIQUE (order_id, product_id)
);

CREATE INDEX idx_order_details_product_id ON order_details(product_id);

------------------------------------------------------------
-- 2. SAMPLE DATA (INSERTS)
------------------------------------------------------------

-- Categories
INSERT INTO categories (category_name, description) VALUES
    ('Electronics', 'Electronic devices and gadgets'),
    ('Books',       'Printed and digital books'),
    ('Clothing',    'Men and women clothing');

-- Suppliers
INSERT INTO suppliers (supplier_name, contact_name, phone, city, country) VALUES
    ('Tech Corp',   'Alice Johnson',      '123-456-7890', 'Vilnius', 'Lithuania'),
    ('BookWorld',   'Jonas Petrauskas',   '987-654-3210', 'Kaunas',  'Lithuania'),
    ('FashionHub',  'Egle Misiunaite',    '555-123-4567', 'Riga',    'Latvia');

-- Customers
INSERT INTO customers (first_name, last_name, email, phone, address, city, country) VALUES
    ('Martynas', 'Kazlauskas',  'martynas.k@example.com', '860000001', 'Gedimino pr. 1', 'Vilnius', 'Lithuania'),
    ('Egle',     'Jankauskaite','egle.j@example.com',     '860000002', 'Laisves al. 10', 'Kaunas',  'Lithuania'),
    ('Tomas',    'Petrauskas',  'tomas.p@example.com',    '860000003', 'Savanoriu pr. 5','Vilnius', 'Lithuania'),
    ('Rasa',     'Bacauskiene', 'rasa.b@example.com',     '860000004', 'Jogailos g. 8',  'Klaipeda','Lithuania'),
    ('Ona',      'Novakaite',   'ona.n@example.com',      '860000005', 'Didzioji g. 12', 'Vilnius', 'Lithuania');

-- Products
INSERT INTO products (product_name, supplier_id, category_id, unit_price, units_in_stock) VALUES
    ('Smartphone X', 1, 1,  799.99, 50),
    ('Laptop Pro',   1, 1, 1299.50, 30),
    ('E-book Reader',2, 1,  149.00, 60),
    ('History Book', 2, 2,   29.99,100),
    ('Novel Classic',2, 2,   19.95, 80),
    ('T-Shirt',      3, 3,   14.99,150),
    ('Jeans',        3, 3,   39.99,120),
    ('Jacket',       3, 3,   89.90, 70),
    ('Headphones',   1, 1,   59.99,200),
    ('Camera',       1, 1,  499.00, 25);

-- Orders
INSERT INTO orders (customer_id, order_date, required_date, shipped_date, freight, order_status) VALUES
    (1, '2025-09-01', '2025-09-05', '2025-09-03', 15.00, 'Shipped'),
    (2, '2025-09-02', '2025-09-06', '2025-09-04', 12.50, 'Shipped'),
    (3, '2025-09-10', '2025-09-14', NULL,         10.00, 'Pending'),
    (1, '2025-09-12', '2025-09-16', NULL,          8.00, 'Pending'),
    (4, '2025-09-15', '2025-09-19', '2025-09-18', 20.00, 'Shipped'),
    (5, '2025-09-20', '2025-09-24', NULL,          5.00, 'Pending');

-- Order details
INSERT INTO order_details (order_id, product_id, quantity, unit_price, discount) VALUES
    -- Order 1
    (1, 1, 1,  799.99, 0.00),
    (1, 9, 2,   59.99, 0.05),
    -- Order 2
    (2, 6, 3,   14.99, 0.00),
    (2, 7, 2,   39.99, 0.10),
    -- Order 3
    (3, 4, 1,   29.99, 0.00),
    (3, 5, 2,   19.95, 0.00),
    -- Order 4
    (4, 2, 1, 1299.50, 0.00),
    (4, 9, 1,   59.99, 0.00),
    -- Order 5
    (5, 7, 2,   39.99, 0.05),
    (5, 8, 1,   89.90, 0.00),
    -- Order 6
    (6, 3, 1,  149.00, 0.00),
    (6,10, 1,  499.00, 0.00);

------------------------------------------------------------
-- 3. EXAMPLE UPDATE & DELETE OPERATIONS
------------------------------------------------------------

-- Increase the price of the "Laptop Pro" by 10%
UPDATE products
SET unit_price = unit_price * 1.10
WHERE product_name = 'Laptop Pro';

-- Change city for customer "Tomas Petrauskas" from Vilnius to Trakai
UPDATE customers
SET city = 'Trakai'
WHERE first_name = 'Tomas' AND last_name = 'Petrauskas';

-- Delete a product ("Jacket") and its order details
DELETE FROM order_details
WHERE product_id = (SELECT product_id FROM products WHERE product_name = 'Jacket');

DELETE FROM products
WHERE product_name = 'Jacket';

------------------------------------------------------------
-- 4. SELECT QUERIES (AGGREGATES, GROUP BY, ORDER BY, PAGINATION)
------------------------------------------------------------

-- 4.1 Aggregate functions: orders and totals per customer
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.order_id) AS order_count,
    SUM(od.quantity * od.unit_price * (1 - od.discount)) AS total_amount,
    AVG(od.unit_price) AS avg_item_price
FROM customers AS c
JOIN orders    AS o  ON c.customer_id = o.customer_id
JOIN order_details AS od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_amount DESC;

-- 4.2 Pagination using LIMIT/OFFSET
SELECT order_id, customer_id, order_date, order_status
FROM orders
ORDER BY order_date
OFFSET 0 LIMIT 5;

-- 4.3 Aggregate: total quantity ordered per product
SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(od.quantity), 0) AS total_units_ordered
FROM products AS p
LEFT JOIN order_details AS od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_units_ordered DESC;

-- 4.4 Top 3 most expensive products
SELECT product_name, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 3;

------------------------------------------------------------
-- 5. JOINS AND VIEW
------------------------------------------------------------

-- 5.1 Inner join: orders and customers
SELECT
    o.order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name AS customer_name
FROM orders AS o
JOIN customers AS c ON o.customer_id = c.customer_id;

-- 5.2 Left join: all customers and their orders (if any)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_id,
    o.order_date
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- 5.3 Right join: all orders and matching customers (if available)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_id,
    o.order_date
FROM customers AS c
RIGHT JOIN orders AS o ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- 5.4 Join three tables: orders, order_details, products
SELECT
    o.order_id,
    o.order_date,
    p.product_name,
    od.quantity,
    od.unit_price,
    (od.quantity * od.unit_price * (1 - od.discount)) AS line_total
FROM orders AS o
JOIN order_details AS od ON o.order_id = od.order_id
JOIN products AS p       ON od.product_id = p.product_id
ORDER BY o.order_id, p.product_name;

-- 5.5 View combining orders, customers, and products
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    o.order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_name,
    od.quantity,
    od.unit_price,
    (od.quantity * od.unit_price * (1 - od.discount)) AS line_total
FROM orders AS o
JOIN customers AS c      ON o.customer_id = c.customer_id
JOIN order_details AS od ON o.order_id   = od.order_id
JOIN products AS p       ON od.product_id = p.product_id;

------------------------------------------------------------
-- 6. FUNCTIONS, TRIGGER, MANUAL TRANSACTION
------------------------------------------------------------

-- 6.1 Set-returning function (acts like a stored procedure)
CREATE OR REPLACE FUNCTION usp_get_customer_order_summary(p_customer_id INT)
RETURNS TABLE (
    order_id    INT,
    order_date  TIMESTAMP,
    order_total NUMERIC(18,2)
)
LANGUAGE sql
AS $$
    SELECT
        o.order_id,
        o.order_date,
        SUM(od.quantity * od.unit_price * (1 - od.discount)) AS order_total
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    WHERE o.customer_id = p_customer_id
    GROUP BY o.order_id, o.order_date
    ORDER BY o.order_date;
$$;

-- Example:
-- SELECT * FROM usp_get_customer_order_summary(1);

-- 6.2 Scalar function: total amount for a single order
CREATE OR REPLACE FUNCTION fn_get_order_total(p_order_id INT)
RETURNS NUMERIC(18,2)
LANGUAGE sql
AS $$
    SELECT COALESCE(
        SUM(quantity * unit_price * (1 - discount)),
        0
    )
    FROM order_details
    WHERE order_id = p_order_id;
$$;

-- 6.3 Trigger to update inventory after inserting into order_details
CREATE OR REPLACE FUNCTION trg_update_product_inventory()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE products
    SET
        units_in_stock = units_in_stock - NEW.quantity,
        units_on_order = units_on_order + NEW.quantity
    WHERE product_id = NEW.product_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_update_product_inventory
AFTER INSERT ON order_details
FOR EACH ROW
EXECUTE FUNCTION trg_update_product_inventory();

-- 6.4 Manual transaction example
-- Run these statements manually in a session to demonstrate BEGIN / COMMIT / ROLLBACK

-- BEGIN;
--
-- UPDATE products
-- SET units_in_stock = units_in_stock - 5
-- WHERE product_name = 'Smartphone X';
--
-- UPDATE products
-- SET units_in_stock = units_in_stock + 5
-- WHERE product_name = 'Headphones';
--
-- -- If everything is fine:
-- COMMIT;
--
-- -- If something went wrong instead:
-- -- ROLLBACK;

