{{ config(materialized='incremental', incremental_strategy='merge', unique_key='hk_customer') }}
SELECT hk_customer, customer_key AS business_key,
       MIN(load_period) AS first_seen_period,
       'TPCH_LAB' AS record_source
FROM {{ ref('stg_customer') }}
WHERE customer_key IS NOT NULL
GROUP BY hk_customer, customer_key
