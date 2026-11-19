WITH versions AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY hk_customer ORDER BY load_period DESC) AS rn
    FROM {{ ref('sat_customer') }}
)
SELECT hk_customer, load_period, customer_key, name, address, nation_key, phone, account_balance, market_segment, comments_text
FROM versions WHERE rn=1
