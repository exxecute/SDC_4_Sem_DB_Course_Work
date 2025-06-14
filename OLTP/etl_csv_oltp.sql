DROP TABLE IF EXISTS staging_products CASCADE;

-- 1. Roles
COPY Roles(role_name)
FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\roles.csv'
DELIMITER ','
CSV HEADER;

-- 2. Categories
COPY Categories(category_name)
FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\categories.csv'
DELIMITER ','
CSV HEADER;

-- 3. Status
COPY Status(status_name)
FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\status.csv'
DELIMITER ','
CSV HEADER;

-- 4. Customers
COPY Customers(customer_email, first_name, last_name)
FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\customers.csv'
DELIMITER ','
CSV HEADER;

-- 5. Products: используем staging-таблицу для связывания category_name → category_id
CREATE TEMP TABLE staging_products (
    product_name TEXT,
    category_name TEXT,
    model_number TEXT,
    price NUMERIC,
    manufactured_date DATE
);

COPY staging_products
FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\products.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO Products (product_name, category_id, model_number, price, manufactured_date)
SELECT
    sp.product_name,
    c.category_id,
    sp.model_number,
    sp.price,
    sp.manufactured_date
FROM staging_products sp
JOIN Categories c ON sp.category_name = c.category_name
ON CONFLICT (model_number) DO NOTHING;

CREATE TEMP TABLE staging_admins (
    username TEXT,
    password TEXT,
    admin_email TEXT,
    first_name TEXT,
    last_name TEXT,
    role_name TEXT
);

COPY staging_admins
FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\administrators.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO Administrators (username, password, first_name, last_name, role_id)
SELECT
    s.username,
    s.password,
    s.first_name,
    s.last_name,
    r.role_id
FROM staging_admins s
JOIN Roles r ON s.role_name = r.role_name
ON CONFLICT (username) DO NOTHING;

CREATE TEMP TABLE staging_items (
    serial_number TEXT,
    model_number TEXT
);

COPY staging_items
FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\items.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO Items (product_id, serial_number)
SELECT
    p.product_id,
    s.serial_number
FROM staging_items s
JOIN Products p ON s.model_number = p.model_number
ON CONFLICT (serial_number) DO NOTHING;

CREATE TEMP TABLE staging_orders (
    order_number TEXT,
    customer_email TEXT,
    username TEXT,
    order_date TIMESTAMP,
    shipping_address TEXT,
    total_amount NUMERIC,
    order_status TEXT
);

COPY staging_orders
FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\orders.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO Orders (order_number, order_date, shipping_address, admin_id, customer_id, status_id)
SELECT
    s.order_number,
    s.order_date,
    s.shipping_address,
    a.admin_id,
    c.customer_id,
    st.status_id
FROM staging_orders s
LEFT JOIN Administrators a ON s.username = a.username
JOIN Customers c ON s.customer_email = c.customer_email
JOIN Status st ON s.order_status = st.status_name
ON CONFLICT (order_number) DO NOTHING;

CREATE TEMP TABLE staging_order_items (
    order_number TEXT,
    serial_number TEXT,
    unit_price NUMERIC
);

COPY staging_order_items
FROM 'A:\Study\SDC\4sem\SDC_4_Sem_DB_Course_Work\CSV\order_items.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO Order_Items (orders_id, item_id, unit_price)
SELECT
    o.orders_id,
    i.item_id,
    s.unit_price
FROM staging_order_items s
JOIN Orders o ON s.order_number = o.order_number
JOIN Items i ON s.serial_number = i.serial_number
ON CONFLICT DO NOTHING;