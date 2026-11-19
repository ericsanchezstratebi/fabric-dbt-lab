WITH typed AS (
    SELECT
        TRY_CAST(p_partkey AS BIGINT) AS part_key,
        NULLIF(LTRIM(RTRIM(p_name)), '') AS name,
        NULLIF(LTRIM(RTRIM(p_mfgr)), '') AS manufacturer,
        NULLIF(LTRIM(RTRIM(p_brand)), '') AS brand,
        NULLIF(LTRIM(RTRIM(p_type)), '') AS part_type,
        TRY_CAST(p_size AS BIGINT) AS size,
        NULLIF(LTRIM(RTRIM(p_container)), '') AS container,
        TRY_CAST(p_retailprice AS DECIMAL(18, 2)) AS retail_price,
        NULLIF(LTRIM(RTRIM(p_comment)), '') AS comments_text,
        CAST(load_period AS VARCHAR(6)) AS load_period
    FROM {{ source('raw', 'part') }}
),
enriched AS (
    SELECT
        part_key,
        name,
        manufacturer,
        brand,
        part_type,
        size,
        container,
        retail_price,
        comments_text,
        load_period,
        {{ dv_hash(['CAST(part_key AS VARCHAR(100))']) }} AS hk_part
    FROM typed
),
numbered AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY part_key, load_period ORDER BY load_period) AS rn
    FROM enriched
)
SELECT
    part_key,
    name,
    manufacturer,
    brand,
    part_type,
    size,
    container,
    retail_price,
    comments_text,
    load_period,
    hk_part
FROM numbered WHERE rn = 1
