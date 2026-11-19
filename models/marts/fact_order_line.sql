SELECT l.hk_lineitem, l.order_key, l.line_number,
       o.customer_key, l.part_key, l.supplier_key, o.order_date, l.ship_date,
       o.order_status, l.quantity, l.extended_price, l.discount,
       CAST(l.extended_price * (1 - l.discount) AS DECIMAL(18,2)) AS net_revenue,
       l.load_period AS last_change_period
FROM {{ ref('bv_lineitem_current') }} l
LEFT JOIN {{ ref('dim_orders') }} o ON l.order_key = o.order_key
