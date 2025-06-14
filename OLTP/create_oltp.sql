DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Roles;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Items;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Status;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Administrators;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Order_Items;

CREATE TABLE Categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL
);

CREATE TABLE Roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(255) NOT NULL
);

CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category_id INT NOT NULL REFERENCES Categories(category_id),
    model_number VARCHAR(255),
    price NUMERIC(10,2),
    manufactured_date DATE
);

CREATE TABLE Items (
    item_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES Products(product_id),
    serial_number VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE Inventory (
    inventory_id SERIAL PRIMARY KEY,
    item_id INT NOT NULL REFERENCES Items(item_id),
    last_updated TIMESTAMP,
    location VARCHAR(255)
);

CREATE TABLE Status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL
);

CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    customer_email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100)
);

CREATE TABLE Administrators (
    admin_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role_id INT NOT NULL REFERENCES Roles(role_id),
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
);

CREATE TABLE Orders (
    orders_id SERIAL PRIMARY KEY,
    order_number VARCHAR(255) NOT NULL,
    order_date DATE,
    shipping_address VARCHAR(255),
    admin_id INT REFERENCES Administrators(admin_id),
    customer_id INT REFERENCES Customers(customer_id),
    status_id INT REFERENCES Status(status_id)
);

CREATE TABLE Order_Items (
    order_item_id SERIAL PRIMARY KEY,
    item_id INT NOT NULL REFERENCES Items(item_id),
    orders_id INT NOT NULL REFERENCES Orders(orders_id),
    unit_price NUMERIC(10,2)
);