-- ETL: Load data via staging tables and merge

-- 1. Roles
DROP TABLE IF EXISTS tmp_roles CASCADE;
CREATE TEMP TABLE tmp_roles(role_name TEXT);
COPY tmp_roles FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\roles.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Roles(role_name)
SELECT DISTINCT role_name FROM tmp_roles
ON CONFLICT (role_name) DO NOTHING;

-- 2. Status
DROP TABLE IF EXISTS tmp_status CASCADE;
CREATE TEMP TABLE tmp_status(status_name TEXT);
COPY tmp_status FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\status.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Status(status_name)
SELECT DISTINCT status_name FROM tmp_status
ON CONFLICT (status_name) DO NOTHING;

-- 3. Categories
DROP TABLE IF EXISTS tmp_categories CASCADE;
CREATE TEMP TABLE tmp_categories(category_name TEXT);
COPY tmp_categories FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\categories.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Categories(category_name)
SELECT DISTINCT category_name FROM tmp_categories
ON CONFLICT (category_name) DO NOTHING;

-- 4. Customers
DROP TABLE IF EXISTS tmp_customers CASCADE;
CREATE TEMP TABLE tmp_customers(customer_email TEXT, first_name TEXT, last_name TEXT);
COPY tmp_customers FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\customers.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Customers(customer_email, first_name, last_name)
SELECT DISTINCT customer_email, first_name, last_name FROM tmp_customers
ON CONFLICT (customer_email) DO NOTHING;

-- 5. Administrators
DROP TABLE IF EXISTS tmp_admins CASCADE;
CREATE TEMP TABLE tmp_admins(username TEXT, password TEXT, admin_email TEXT, first_name TEXT, last_name TEXT, role_name TEXT);
COPY tmp_admins FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\administrators.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Administrators(username, password, first_name, last_name, role_id)
SELECT DISTINCT a.username, a.password, a.first_name, a.last_name, r.role_id
FROM tmp_admins a
JOIN Roles r ON r.role_name = a.role_name
ON CONFLICT (username) DO NOTHING;

-- 6. Products
DROP TABLE IF EXISTS tmp_products CASCADE;
CREATE TEMP TABLE tmp_products(product_name TEXT, category_name TEXT, model_number TEXT, price NUMERIC, manufactured_date DATE);
COPY tmp_products FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\products.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Products(product_name, category_id, model_number, price, manufactured_date)
SELECT DISTINCT p.product_name, c.category_id, p.model_number, p.price, p.manufactured_date
FROM tmp_products p
JOIN Categories c ON c.category_name = p.category_name
ON CONFLICT (model_number) DO NOTHING;

-- 7. Items
DROP TABLE IF EXISTS tmp_items CASCADE;
CREATE TEMP TABLE tmp_items(serial_number TEXT, model_number TEXT);
COPY tmp_items FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\items.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Items(serial_number, product_id)
SELECT DISTINCT i.serial_number, p.product_id
FROM tmp_items i
JOIN Products p ON p.model_number = i.model_number
ON CONFLICT (serial_number) DO NOTHING;

-- 8. Orders
DROP TABLE IF EXISTS tmp_orders CASCADE;
CREATE TEMP TABLE tmp_orders(order_number TEXT, customer_email TEXT, username TEXT, order_date TIMESTAMP, shipping_address TEXT, total_amount NUMERIC, order_status TEXT);
COPY tmp_orders FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\orders.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Orders(order_number, customer_id, admin_id, order_date, shipping_address, status_id)
SELECT DISTINCT o.order_number, c.customer_id, a.admin_id, o.order_date, o.shipping_address, s.status_id
FROM tmp_orders o
JOIN Customers c ON c.customer_email = o.customer_email
LEFT JOIN Administrators a ON a.username = o.username
JOIN Status s ON s.status_name = o.order_status
ON CONFLICT (order_number) DO NOTHING;

-- 9. Order Items
DROP TABLE IF EXISTS tmp_order_items CASCADE;
CREATE TEMP TABLE tmp_order_items(order_number TEXT, serial_number TEXT, unit_price NUMERIC);
COPY tmp_order_items FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\order_items.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Order_Items(orders_id, item_id, unit_price)
SELECT o.orders_id, i.item_id, t.unit_price
FROM tmp_order_items t
JOIN Orders o ON o.order_number = t.order_number
JOIN Items i ON i.serial_number = t.serial_number
ON CONFLICT (orders_id, item_id) DO NOTHING;

-- 10. Inventory
DROP TABLE IF EXISTS tmp_inventory CASCADE;
CREATE TEMP TABLE tmp_inventory(serial_number TEXT, last_updated TIMESTAMP, location TEXT);
COPY tmp_inventory FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\inventory.csv' DELIMITER ',' CSV HEADER;
INSERT INTO Inventory(item_id, last_updated, location)
SELECT i.item_id, t.last_updated, t.location
FROM tmp_inventory t
JOIN Items i ON i.serial_number = t.serial_number
ON CONFLICT (item_id) DO NOTHING;