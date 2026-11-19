{{ config(materialized='incremental', incremental_strategy='merge', unique_key='hk_l_order_customer') }}
SELECT {{ dv_hash(['CAST(order_key AS VARCHAR(100))', 'CAST(customer_key AS VARCHAR(100))']) }} AS hk_l_order_customer,
       hk_order, hk_customer,
       MIN(load_period) AS first_seen_period,
       'TPCH_LAB' AS record_source
FROM {{ ref('stg_orders') }}
GROUP BY order_key, customer_key, hk_order, hk_customer
