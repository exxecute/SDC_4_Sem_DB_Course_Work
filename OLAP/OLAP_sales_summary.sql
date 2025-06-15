DROP VIEW IF EXISTS vw_SalesSummaryByDateProduct CASCADE;

CREATE OR REPLACE VIEW vw_SalesSummaryByDateProduct AS
SELECT
    dd.date_key,
    dd.year,
    dd.month,
    dd.month_name,

    dp.product_key,
    dp.product_name,
    dp.category_name,

    COUNT(DISTINCT fs.fact_sales_key) AS total_sales,
    COUNT(DISTINCT di.item_key) AS items_sold,
    SUM(dp.price) AS total_revenue

FROM FactSales fs
JOIN DimDate dd ON fs.date_key = dd.date_key
JOIN DimItem di ON fs.item_key = di.item_key
LEFT JOIN ItemProductBridge ipb ON di.item_key = ipb.item_key
LEFT JOIN DimProduct dp ON ipb.product_key = dp.product_key

GROUP BY
    dd.date_key, dd.year, dd.month, dd.month_name,
    dp.product_key, dp.product_name, dp.category_name;
	
SELECT * FROM vw_SalesSummaryByDateProduct;