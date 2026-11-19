{{ config(materialized='incremental', incremental_strategy='merge', unique_key='hk_supplier') }}
SELECT hk_supplier, supplier_key AS business_key,
       MIN(load_period) AS first_seen_period,
       'TPCH_LAB' AS record_source
FROM {{ ref('stg_supplier') }}
WHERE supplier_key IS NOT NULL
GROUP BY hk_supplier, supplier_key
