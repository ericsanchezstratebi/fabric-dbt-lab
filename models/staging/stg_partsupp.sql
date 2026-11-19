WITH typed AS (
    SELECT
        TRY_CAST(ps_partkey AS BIGINT) AS part_key,
        TRY_CAST(ps_suppkey AS BIGINT) AS supplier_key,
        TRY_CAST(ps_availqty AS BIGINT) AS available_qty,
        TRY_CAST(ps_supplycost AS DECIMAL(18, 2)) AS supply_cost,
        NULLIF(LTRIM(RTRIM(ps_comment)), '') AS comments_text,
        CAST(load_period AS VARCHAR(6)) AS load_period
    FROM {{ source('raw', 'partsupp') }}
),
enriched AS (
    SELECT
        part_key,
        supplier_key,
        available_qty,
        supply_cost,
        comments_text,
        load_period,
        {{ dv_hash(['CAST(part_key AS VARCHAR(100))', 'CAST(supplier_key AS VARCHAR(100))']) }} AS hk_partsupp,
        {{ dv_hash(['CAST(part_key AS VARCHAR(100))']) }} AS hk_part,
        {{ dv_hash(['CAST(supplier_key AS VARCHAR(100))']) }} AS hk_supplier
    FROM typed
),
numbered AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY part_key, supplier_key, load_period ORDER BY load_period) AS rn
    FROM enriched
)
SELECT
    part_key,
    supplier_key,
    available_qty,
    supply_cost,
    comments_text,
    load_period,
    hk_partsupp,
    hk_part,
    hk_supplier
FROM numbered WHERE rn = 1
