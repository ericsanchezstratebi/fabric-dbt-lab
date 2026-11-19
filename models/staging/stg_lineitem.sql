WITH typed AS (
    SELECT
        TRY_CAST(l_orderkey AS BIGINT) AS order_key,
        TRY_CAST(l_linenumber AS BIGINT) AS line_number,
        TRY_CAST(l_partkey AS BIGINT) AS part_key,
        TRY_CAST(l_suppkey AS BIGINT) AS supplier_key,
        TRY_CAST(l_quantity AS BIGINT) AS quantity,
        TRY_CAST(l_extendedprice AS DECIMAL(18, 2)) AS extended_price,
        TRY_CAST(l_discount AS DECIMAL(18, 2)) AS discount,
        TRY_CAST(l_shipdate AS DATE) AS ship_date,
        NULLIF(LTRIM(RTRIM(l_comment)), '') AS comments_text,
        CAST(load_period AS VARCHAR(6)) AS load_period
    FROM {{ source('raw', 'lineitem') }}
),
enriched AS (
    SELECT
        order_key,
        line_number,
        part_key,
        supplier_key,
        quantity,
        extended_price,
        discount,
        ship_date,
        comments_text,
        load_period,
        {{ dv_hash(['CAST(order_key AS VARCHAR(100))', 'CAST(line_number AS VARCHAR(100))']) }} AS hk_lineitem,
        {{ dv_hash(['CAST(order_key AS VARCHAR(100))']) }} AS hk_order,
        {{ dv_hash(['CAST(part_key AS VARCHAR(100))']) }} AS hk_part,
        {{ dv_hash(['CAST(supplier_key AS VARCHAR(100))']) }} AS hk_supplier
    FROM typed
),
numbered AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY order_key, line_number, load_period ORDER BY load_period) AS rn
    FROM enriched
)
SELECT
    order_key,
    line_number,
    part_key,
    supplier_key,
    quantity,
    extended_price,
    discount,
    ship_date,
    comments_text,
    load_period,
    hk_lineitem,
    hk_order,
    hk_part,
    hk_supplier
FROM numbered WHERE rn = 1
