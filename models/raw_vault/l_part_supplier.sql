{{ config(materialized='incremental', incremental_strategy='merge', unique_key='hk_l_part_supplier') }}
SELECT {{ dv_hash(['CAST(part_key AS VARCHAR(100))', 'CAST(supplier_key AS VARCHAR(100))']) }} AS hk_l_part_supplier,
       hk_part, hk_supplier,
       MIN(load_period) AS first_seen_period,
       'TPCH_LAB' AS record_source
FROM {{ ref('stg_partsupp') }}
GROUP BY part_key, supplier_key, hk_part, hk_supplier
