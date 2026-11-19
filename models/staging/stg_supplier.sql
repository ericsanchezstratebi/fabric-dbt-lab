WITH typed AS (
    SELECT
        TRY_CAST(s_suppkey AS BIGINT) AS supplier_key,
        NULLIF(LTRIM(RTRIM(s_name)), '') AS name,
        NULLIF(LTRIM(RTRIM(s_address)), '') AS address,
        TRY_CAST(s_nationkey AS BIGINT) AS nation_key,
        NULLIF(LTRIM(RTRIM(s_phone)), '') AS phone,
        TRY_CAST(s_acctbal AS DECIMAL(18, 2)) AS account_balance,
        NULLIF(LTRIM(RTRIM(s_comment)), '') AS comments_text,
        CAST(load_period AS VARCHAR(6)) AS load_period
    FROM {{ source('raw', 'supplier') }}
),
enriched AS (
    SELECT
        supplier_key,
        name,
        address,
        nation_key,
        phone,
        account_balance,
        comments_text,
        load_period,
        {{ dv_hash(['CAST(supplier_key AS VARCHAR(100))']) }} AS hk_supplier
    FROM typed
),
numbered AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY supplier_key, load_period ORDER BY load_period) AS rn
    FROM enriched
)
SELECT
    supplier_key,
    name,
    address,
    nation_key,
    phone,
    account_balance,
    comments_text,
    load_period,
    hk_supplier
FROM numbered WHERE rn = 1
