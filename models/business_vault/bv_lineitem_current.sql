WITH versions AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY hk_lineitem ORDER BY load_period DESC) AS rn
    FROM {{ ref('sat_lineitem') }}
)
SELECT hk_lineitem, load_period, order_key, line_number, part_key, supplier_key, quantity, extended_price, discount, ship_date, comments_text
FROM versions WHERE rn=1
