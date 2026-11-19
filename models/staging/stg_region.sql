WITH typed AS (
    SELECT
        TRY_CAST(r_regionkey AS BIGINT) AS region_key,
        NULLIF(LTRIM(RTRIM(r_name)), '') AS name,
        NULLIF(LTRIM(RTRIM(r_comment)), '') AS comments_text,
        CAST(load_period AS VARCHAR(6)) AS load_period
    FROM {{ source('raw', 'region') }}
),
enriched AS (
    SELECT
        region_key,
        name,
        comments_text,
        load_period
    FROM typed
),
numbered AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY region_key, load_period ORDER BY load_period) AS rn
    FROM enriched
)
SELECT
    region_key,
    name,
    comments_text,
    load_period
FROM numbered WHERE rn = 1
