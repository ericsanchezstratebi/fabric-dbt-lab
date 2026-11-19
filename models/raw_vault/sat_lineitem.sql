{{ config(materialized='incremental', incremental_strategy='merge', unique_key='sat_row_hk') }}
WITH base AS (
    SELECT hk_lineitem, load_period, order_key, line_number, part_key, supplier_key, quantity, extended_price, discount, ship_date, comments_text,
           {{ dv_hash(['order_key', 'line_number', 'part_key', 'supplier_key', 'quantity', 'extended_price', 'discount', 'ship_date', 'comments_text']) }} AS hashdiff
    FROM {{ ref('stg_lineitem') }}
), sequenced AS (
    SELECT *, LAG(hashdiff) OVER (PARTITION BY hk_lineitem ORDER BY load_period) AS previous_hashdiff
    FROM base
)
SELECT {{ dv_hash(['CAST(hk_lineitem AS VARCHAR(100))', 'CAST(load_period AS VARCHAR(100))']) }} AS sat_row_hk,
       hk_lineitem, load_period, hashdiff,
       order_key, line_number, part_key, supplier_key, quantity, extended_price, discount, ship_date, comments_text,
       'TPCH_LAB' AS record_source
FROM sequenced
WHERE previous_hashdiff IS NULL OR previous_hashdiff <> hashdiff
