DROP TABLE IF EXISTS DimDate CASCADE;
DROP TABLE IF EXISTS DimCustomer CASCADE;
DROP TABLE IF EXISTS DimAdministrator CASCADE;
DROP TABLE IF EXISTS DimProduct CASCADE;
DROP TABLE IF EXISTS DimItem CASCADE;
DROP TABLE IF EXISTS FactSales CASCADE;
DROP TABLE IF EXISTS FactInventory CASCADE;
DROP TABLE IF EXISTS ItemProductBridge CASCADE;

-- (Dimensions)

CREATE TABLE DimDate (
    date_key DATE PRIMARY KEY,
    day INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    year INT NOT NULL
);

CREATE TABLE DimCustomer (
    customer_key SERIAL PRIMARY KEY,
    customer_email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL
);

CREATE TABLE DimAdministrator (
    admin_key SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL
);

CREATE TABLE DimProduct (
    product_key SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    model_number VARCHAR(100) NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN NOT NULL
);

CREATE TABLE DimItem (
    item_key SERIAL PRIMARY KEY,
    serial_number VARCHAR(255) UNIQUE NOT NULL
);

-- (Fact table)

CREATE TABLE FactSales (
    fact_sales_key SERIAL PRIMARY KEY,
    date_key DATE NOT NULL REFERENCES DimDate(date_key) ON DELETE CASCADE,
    customer_key INT NOT NULL REFERENCES DimCustomer(customer_key) ON DELETE CASCADE,
    admin_key INT REFERENCES DimAdministrator(admin_key) ON DELETE CASCADE,
    item_key INT NOT NULL REFERENCES DimItem(item_key) ON DELETE CASCADE,
    address VARCHAR(255) NOT NULL,
    status VARCHAR(100) NOT NULL
);

-- (Fact table)

CREATE TABLE FactInventory (
    fact_inventory_key SERIAL PRIMARY KEY,
    item_key INT NOT NULL REFERENCES DimItem(item_key) ON DELETE CASCADE,
    address VARCHAR(255) NOT NULL
);

-- Bridge 

CREATE TABLE ItemProductBridge (
    item_product_page_key SERIAL PRIMARY KEY,
    product_key INT NOT NULL REFERENCES DimProduct(product_key) ON DELETE CASCADE,
    item_key INT NOT NULL REFERENCES DimItem(item_key) ON DELETE CASCADE
);