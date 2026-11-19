{{ config(materialized='incremental', incremental_strategy='merge', unique_key='hk_order') }}
SELECT hk_order, order_key AS business_key,
       MIN(load_period) AS first_seen_period,
       'TPCH_LAB' AS record_source
FROM {{ ref('stg_orders') }}
WHERE order_key IS NOT NULL
GROUP BY hk_order, order_key
