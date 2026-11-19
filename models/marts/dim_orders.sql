SELECT o.hk_order, o.order_key, o.customer_key, o.order_status, o.total_price,
       o.order_date, o.order_priority, o.load_period AS last_change_period
FROM {{ ref('bv_orders_current') }} o
