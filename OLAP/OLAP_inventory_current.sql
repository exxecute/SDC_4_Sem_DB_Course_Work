DROP VIEW IF EXISTS vw_FactSalesDetails CASCADE;

CREATE OR REPLACE VIEW vw_FactSalesDetails AS
SELECT
    fi.fact_inventory_key,
    fi.item_key,
    di.serial_number,
    ipb.product_key,
    dp.product_name,
    dp.model_number,
    dp.category_name,
    dp.price,
    fi.address
FROM FactInventory fi
JOIN DimItem di ON fi.item_key = di.item_key
JOIN ItemProductBridge ipb ON di.item_key = ipb.item_key
JOIN DimProduct dp ON ipb.product_key = dp.product_key
WHERE dp.is_current = TRUE;

SELECT * FROM vw_inventory_current;