WITH typed AS (
    SELECT
        TRY_CAST(o_orderkey AS BIGINT) AS order_key,
        TRY_CAST(o_custkey AS BIGINT) AS customer_key,
        NULLIF(LTRIM(RTRIM(o_orderstatus)), '') AS order_status,
        TRY_CAST(o_totalprice AS DECIMAL(18, 2)) AS total_price,
        TRY_CAST(o_orderdate AS DATE) AS order_date,
        NULLIF(LTRIM(RTRIM(o_orderpriority)), '') AS order_priority,
        NULLIF(LTRIM(RTRIM(o_comment)), '') AS comments_text,
        CAST(load_period AS VARCHAR(6)) AS load_period
    FROM {{ source('raw', 'orders') }}
),
enriched AS (
    SELECT
        order_key,
        customer_key,
        order_status,
        total_price,
        order_date,
        order_priority,
        comments_text,
        load_period,
        {{ dv_hash(['CAST(order_key AS VARCHAR(100))']) }} AS hk_order,
        {{ dv_hash(['CAST(customer_key AS VARCHAR(100))']) }} AS hk_customer
    FROM typed
),
numbered AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY order_key, load_period ORDER BY load_period) AS rn
    FROM enriched
)
SELECT
    order_key,
    customer_key,
    order_status,
    total_price,
    order_date,
    order_priority,
    comments_text,
    load_period,
    hk_order,
    hk_customer
FROM numbered WHERE rn = 1
