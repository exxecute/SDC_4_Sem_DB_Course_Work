-- Current Inventory
CREATE OR REPLACE VIEW v_inventory_view AS
SELECT 
    i.serial_number,
    p.product_name,
    p.model_number,
    inv.location,
    inv.last_updated
FROM inventory inv
JOIN items i ON inv.item_id = i.item_id
JOIN products p ON i.product_id = p.product_id
ORDER BY inv.last_updated DESC;

SELECT * FROM v_inventory_view;