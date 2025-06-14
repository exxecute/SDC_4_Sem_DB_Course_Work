DROP TABLE IF EXISTS Inventory CASCADE;
DROP TABLE IF EXISTS Order_Items CASCADE;
DROP TABLE IF EXISTS Items CASCADE;
DROP TABLE IF EXISTS Administrators CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS Categories CASCADE;
DROP TABLE IF EXISTS Roles CASCADE;
DROP TABLE IF EXISTS Products CASCADE;
DROP TABLE IF EXISTS Status CASCADE;

-- 1. Roles
CREATE TABLE Roles (
    role_id SERIAL PRIMARY KEY,
    role_name TEXT NOT NULL UNIQUE
);

-- 2. Status
CREATE TABLE Status (
    status_id SERIAL PRIMARY KEY,
    status_name TEXT NOT NULL UNIQUE
);

-- 3. Categories
CREATE TABLE Categories (
    category_id SERIAL PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE
);

-- 4. Customers
CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    customer_email TEXT NOT NULL UNIQUE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL
);

-- 5. Administrators
CREATE TABLE Administrators (
    admin_id SERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    role_id INT NOT NULL REFERENCES Roles(role_id)
);

-- 6. Products
CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INT NOT NULL REFERENCES Categories(category_id),
    model_number TEXT NOT NULL UNIQUE,
    price NUMERIC NOT NULL,
    manufactured_date DATE NOT NULL
);

-- 7. Items
CREATE TABLE Items (
    item_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES Products(product_id),
    serial_number TEXT NOT NULL UNIQUE
);

-- 8. Orders
CREATE TABLE Orders (
    orders_id SERIAL PRIMARY KEY,
    order_number TEXT NOT NULL UNIQUE,
    order_date TIMESTAMP NOT NULL,
    shipping_address TEXT NOT NULL,
    admin_id INT REFERENCES Administrators(admin_id),
    customer_id INT NOT NULL REFERENCES Customers(customer_id),
    status_id INT NOT NULL REFERENCES Status(status_id)
);

-- 9. Order_Items
CREATE TABLE Order_Items (
    order_item_id SERIAL PRIMARY KEY,
    orders_id INT NOT NULL REFERENCES Orders(orders_id),
    item_id INT NOT NULL REFERENCES Items(item_id),
    unit_price NUMERIC NOT NULL,
    UNIQUE (orders_id, item_id)
);

-- 10. Inventory
CREATE TABLE Inventory (
    inventory_id SERIAL PRIMARY KEY,
    item_id INT NOT NULL UNIQUE REFERENCES Items(item_id),
    last_updated TIMESTAMP NOT NULL,
    location TEXT NOT NULL
);