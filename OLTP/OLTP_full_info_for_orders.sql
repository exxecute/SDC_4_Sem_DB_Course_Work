-- Full info for orders
CREATE OR REPLACE VIEW v_order_details AS
SELECT 
    o.order_number,
    o.order_date,
    o.shipping_address,
    c.first_name || ' ' || c.last_name AS customer_name,
    a.first_name || ' ' || a.last_name AS admin_name,
    s.status_name,
    oi.unit_price,
    i.serial_number,
    p.product_name,
    p.model_number
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN administrators a ON o.admin_id = a.admin_id
JOIN status s ON o.status_id = s.status_id
JOIN order_items oi ON o.orders_id = oi.orders_id
JOIN items i ON oi.item_id = i.item_id
JOIN products p ON i.product_id = p.product_id;

SELECT * FROM v_order_details;