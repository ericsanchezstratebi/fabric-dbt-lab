WITH versions AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY hk_part ORDER BY load_period DESC) AS rn
    FROM {{ ref('sat_part') }}
)
SELECT hk_part, load_period, part_key, name, manufacturer, brand, part_type, size, container, retail_price, comments_text
FROM versions WHERE rn=1
