WITH typed AS (
    SELECT
        TRY_CAST(n_nationkey AS BIGINT) AS nation_key,
        NULLIF(LTRIM(RTRIM(n_name)), '') AS name,
        TRY_CAST(n_regionkey AS BIGINT) AS region_key,
        NULLIF(LTRIM(RTRIM(n_comment)), '') AS comments_text,
        CAST(load_period AS VARCHAR(6)) AS load_period
    FROM {{ source('raw', 'nation') }}
),
enriched AS (
    SELECT
        nation_key,
        name,
        region_key,
        comments_text,
        load_period
    FROM typed
),
numbered AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY nation_key, load_period ORDER BY load_period) AS rn
    FROM enriched
)
SELECT
    nation_key,
    name,
    region_key,
    comments_text,
    load_period
FROM numbered WHERE rn = 1
