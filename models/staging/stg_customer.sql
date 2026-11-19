WITH typed AS (
    SELECT
        TRY_CAST(c_custkey AS BIGINT) AS customer_key,
        NULLIF(LTRIM(RTRIM(c_name)), '') AS name,
        NULLIF(LTRIM(RTRIM(c_address)), '') AS address,
        TRY_CAST(c_nationkey AS BIGINT) AS nation_key,
        NULLIF(LTRIM(RTRIM(c_phone)), '') AS phone,
        TRY_CAST(c_acctbal AS DECIMAL(18, 2)) AS account_balance,
        NULLIF(LTRIM(RTRIM(c_mktsegment)), '') AS market_segment,
        NULLIF(LTRIM(RTRIM(c_comment)), '') AS comments_text,
        CAST(load_period AS VARCHAR(6)) AS load_period
    FROM {{ source('raw', 'customer') }}
),
enriched AS (
    SELECT
        customer_key,
        name,
        address,
        nation_key,
        phone,
        account_balance,
        market_segment,
        comments_text,
        load_period,
        {{ dv_hash(['CAST(customer_key AS VARCHAR(100))']) }} AS hk_customer
    FROM typed
),
numbered AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_key, load_period ORDER BY load_period) AS rn
    FROM enriched
)
SELECT
    customer_key,
    name,
    address,
    nation_key,
    phone,
    account_balance,
    market_segment,
    comments_text,
    load_period,
    hk_customer
FROM numbered WHERE rn = 1
