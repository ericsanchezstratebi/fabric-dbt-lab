WITH latest AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY region_key ORDER BY load_period DESC) AS rn
  FROM {{ ref('stg_region') }}
)
SELECT region_key, name AS region_name FROM latest WHERE rn=1
