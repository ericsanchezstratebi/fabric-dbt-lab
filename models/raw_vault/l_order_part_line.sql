{{ config(materialized='incremental', incremental_strategy='merge', unique_key='hk_l_order_part_line') }}
SELECT {{ dv_hash(['CAST(order_key AS VARCHAR(100))', 'CAST(line_number AS VARCHAR(100))', 'CAST(part_key AS VARCHAR(100))']) }} AS hk_l_order_part_line,
       hk_lineitem, hk_order, hk_part,
       MIN(load_period) AS first_seen_period,
       'TPCH_LAB' AS record_source
FROM {{ ref('stg_lineitem') }}
GROUP BY order_key, line_number, part_key, hk_lineitem, hk_order, hk_part
