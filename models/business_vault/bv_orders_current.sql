WITH versions AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY hk_order ORDER BY load_period DESC) AS rn
    FROM {{ ref('sat_orders') }}
)
SELECT hk_order, load_period, order_key, customer_key, order_status, total_price, order_date, order_priority, comments_text
FROM versions WHERE rn=1
