{{ config(materialized='incremental', incremental_strategy='merge', unique_key='sat_row_hk') }}
WITH base AS (
    SELECT hk_order, load_period, order_key, customer_key, order_status, total_price, order_date, order_priority, comments_text,
           {{ dv_hash(['order_key', 'customer_key', 'order_status', 'total_price', 'order_date', 'order_priority', 'comments_text']) }} AS hashdiff
    FROM {{ ref('stg_orders') }}
), sequenced AS (
    SELECT *, LAG(hashdiff) OVER (PARTITION BY hk_order ORDER BY load_period) AS previous_hashdiff
    FROM base
)
SELECT {{ dv_hash(['CAST(hk_order AS VARCHAR(100))', 'CAST(load_period AS VARCHAR(100))']) }} AS sat_row_hk,
       hk_order, load_period, hashdiff,
       order_key, customer_key, order_status, total_price, order_date, order_priority, comments_text,
       'TPCH_LAB' AS record_source
FROM sequenced
WHERE previous_hashdiff IS NULL OR previous_hashdiff <> hashdiff
