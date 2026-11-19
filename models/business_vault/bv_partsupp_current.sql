WITH versions AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY hk_partsupp ORDER BY load_period DESC) AS rn
    FROM {{ ref('sat_partsupp') }}
)
SELECT hk_partsupp, load_period, part_key, supplier_key, available_qty, supply_cost, comments_text
FROM versions WHERE rn=1
