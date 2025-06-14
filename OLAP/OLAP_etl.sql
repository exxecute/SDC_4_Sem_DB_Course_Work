CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER IF NOT EXISTS coursework_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', dbname 'OLTP', port '5432');

CREATE USER MAPPING IF NOT EXISTS FOR CURRENT_USER
SERVER coursework_server
OPTIONS (user 'postgres', password '7585');

IMPORT FOREIGN SCHEMA public
FROM SERVER coursework_server
INTO public;

-- 1. DimDate
INSERT INTO DimDate (date_key, day, month, month_name, year)
SELECT DISTINCT
    o.order_date::date,
    EXTRACT(DAY FROM o.order_date)::INT,
    EXTRACT(MONTH FROM o.order_date)::INT,
    TO_CHAR(o.order_date, 'Month'),
    EXTRACT(YEAR FROM o.order_date)::INT
FROM orders o
WHERE o.order_date IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM DimDate d WHERE d.date_key = o.order_date::date
  );

-- 2. DimCustomer
INSERT INTO DimCustomer (customer_email, first_name, last_name)
SELECT DISTINCT
    c.customer_email,
    c.first_name,
    c.last_name
FROM customers c
ON CONFLICT (customer_email) DO NOTHING;

-- 3. DimAdministrator
INSERT INTO DimAdministrator (username, first_name, last_name)
SELECT DISTINCT
    a.username,
    a.first_name,
    a.last_name
FROM administrators a
ON CONFLICT (username) DO NOTHING;

-- 4. DimProduct (SCD Type 2-lite, insert only if not existing model/price/date combo)
INSERT INTO DimProduct (product_name, model_number, category_name, price, start_date, end_date, is_current)
SELECT DISTINCT
    p.product_name,
    p.model_number,
    c.category_name,
    p.price,
    p.manufactured_date,
    NULL::date,
    TRUE
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE NOT EXISTS (
    SELECT 1 FROM DimProduct dp
    WHERE dp.model_number = p.model_number AND dp.start_date = p.manufactured_date
);

-- 5. DimItem
INSERT INTO DimItem (serial_number)
SELECT DISTINCT
    i.serial_number
FROM items i
ON CONFLICT (serial_number) DO NOTHING;

-- 6. Bridge: ItemProductBridge
INSERT INTO ItemProductBridge (product_key, item_key)
SELECT DISTINCT
    dp.product_key,
    di.item_key
FROM items i
JOIN products p ON i.product_id = p.product_id
JOIN DimProduct dp ON dp.model_number = p.model_number
JOIN DimItem di ON di.serial_number = i.serial_number
WHERE NOT EXISTS (
    SELECT 1 FROM ItemProductBridge b
    JOIN DimProduct dp2 ON b.product_key = dp2.product_key
    JOIN DimItem di2 ON b.item_key = di2.item_key
    WHERE dp2.model_number = p.model_number AND di2.serial_number = i.serial_number
);

-- 7. FactSales
INSERT INTO FactSales (
    date_key, customer_key, admin_key, item_key, address, status
)
SELECT
    o.order_date::date,
    dc.customer_key,
    da.admin_key,
    di.item_key,
    o.shipping_address,
    s.status_name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN DimCustomer dc ON dc.customer_email = c.customer_email
LEFT JOIN administrators a ON o.admin_id = a.admin_id
LEFT JOIN DimAdministrator da ON da.username = a.username
JOIN status s ON o.status_id = s.status_id
JOIN order_items oi ON o.orders_id = oi.orders_id
JOIN items i ON oi.item_id = i.item_id
JOIN DimItem di ON di.serial_number = i.serial_number
WHERE da.admin_key IS NOT NULL 
AND NOT EXISTS (
    SELECT 1 FROM FactSales fs
    JOIN DimItem di2 ON fs.item_key = di2.item_key
    WHERE di2.serial_number = i.serial_number AND fs.date_key = o.order_date::date
);

-- 8. FactInventory
INSERT INTO FactInventory (item_key, address)
SELECT
    di.item_key,
    inv.location
FROM inventory inv
JOIN items i ON inv.item_id = i.item_id
JOIN DimItem di ON di.serial_number = i.serial_number
WHERE NOT EXISTS (
    SELECT 1 FROM FactInventory fi
    JOIN DimItem di2 ON fi.item_key = di2.item_key
    WHERE di2.serial_number = i.serial_number
);
