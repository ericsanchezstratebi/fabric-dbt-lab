WITH latest AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY nation_key ORDER BY load_period DESC) AS rn
  FROM {{ ref('stg_nation') }}
)
SELECT n.nation_key, n.name AS nation_name, n.region_key, r.region_name
FROM latest n LEFT JOIN {{ ref('dim_region') }} r ON n.region_key=r.region_key
WHERE n.rn=1
