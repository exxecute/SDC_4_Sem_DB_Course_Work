-- Order summ
CREATE OR REPLACE VIEW v_customer_order_totals AS
SELECT 
    c.customer_email,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.orders_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_email, customer_name;

SELECT * FROM v_customer_order_totals;