{{ config(materialized='incremental', incremental_strategy='merge', unique_key='hk_part') }}
SELECT hk_part, part_key AS business_key,
       MIN(load_period) AS first_seen_period,
       'TPCH_LAB' AS record_source
FROM {{ ref('stg_part') }}
WHERE part_key IS NOT NULL
GROUP BY hk_part, part_key
