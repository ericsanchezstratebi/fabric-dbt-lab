{{ config(materialized='incremental', incremental_strategy='merge', unique_key='sat_row_hk') }}
WITH base AS (
    SELECT hk_partsupp, load_period, part_key, supplier_key, available_qty, supply_cost, comments_text,
           {{ dv_hash(['part_key', 'supplier_key', 'available_qty', 'supply_cost', 'comments_text']) }} AS hashdiff
    FROM {{ ref('stg_partsupp') }}
), sequenced AS (
    SELECT *, LAG(hashdiff) OVER (PARTITION BY hk_partsupp ORDER BY load_period) AS previous_hashdiff
    FROM base
)
SELECT {{ dv_hash(['CAST(hk_partsupp AS VARCHAR(100))', 'CAST(load_period AS VARCHAR(100))']) }} AS sat_row_hk,
       hk_partsupp, load_period, hashdiff,
       part_key, supplier_key, available_qty, supply_cost, comments_text,
       'TPCH_LAB' AS record_source
FROM sequenced
WHERE previous_hashdiff IS NULL OR previous_hashdiff <> hashdiff
