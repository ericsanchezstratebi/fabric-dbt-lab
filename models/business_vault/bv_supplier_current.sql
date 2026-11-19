WITH versions AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY hk_supplier ORDER BY load_period DESC) AS rn
    FROM {{ ref('sat_supplier') }}
)
SELECT hk_supplier, load_period, supplier_key, name, address, nation_key, phone, account_balance, comments_text
FROM versions WHERE rn=1
