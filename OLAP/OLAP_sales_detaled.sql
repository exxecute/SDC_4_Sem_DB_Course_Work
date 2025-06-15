DROP VIEW IF EXISTS vw_sales_detailed CASCADE;

CREATE VIEW vw_sales_detailed AS
SELECT
    fs.fact_sales_key,
    fs.date_key,
    dd.day,
    dd.month,
    dd.month_name,
    dd.year,
    fs.customer_key,
    dc.customer_email,
    dc.first_name AS customer_first_name,
    dc.last_name AS customer_last_name,
    fs.admin_key,
    da.username AS admin_username,
    da.first_name AS admin_first_name,
    da.last_name AS admin_last_name,
    fs.item_key,
    di.serial_number,
    ipb.product_key,
    dp.product_name,
    dp.model_number,
    dp.category_name,
    dp.price,
    fs.address,
    fs.status
FROM FactSales fs
JOIN DimDate dd ON fs.date_key = dd.date_key
JOIN DimCustomer dc ON fs.customer_key = dc.customer_key
LEFT JOIN DimAdministrator da ON fs.admin_key = da.admin_key
JOIN DimItem di ON fs.item_key = di.item_key
JOIN ItemProductBridge ipb ON di.item_key = ipb.item_key
JOIN DimProduct dp ON ipb.product_key = dp.product_key;

SELECT * FROM vw_sales_detailed;