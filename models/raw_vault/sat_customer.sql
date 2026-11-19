{{ config(materialized='incremental', incremental_strategy='merge', unique_key='sat_row_hk') }}
WITH base AS (
    SELECT hk_customer, load_period, customer_key, name, address, nation_key, phone, account_balance, market_segment, comments_text,
           {{ dv_hash(['customer_key', 'name', 'address', 'nation_key', 'phone', 'account_balance', 'market_segment', 'comments_text']) }} AS hashdiff
    FROM {{ ref('stg_customer') }}
), sequenced AS (
    SELECT *, LAG(hashdiff) OVER (PARTITION BY hk_customer ORDER BY load_period) AS previous_hashdiff
    FROM base
)
SELECT {{ dv_hash(['CAST(hk_customer AS VARCHAR(100))', 'CAST(load_period AS VARCHAR(100))']) }} AS sat_row_hk,
       hk_customer, load_period, hashdiff,
       customer_key, name, address, nation_key, phone, account_balance, market_segment, comments_text,
       'TPCH_LAB' AS record_source
FROM sequenced
WHERE previous_hashdiff IS NULL OR previous_hashdiff <> hashdiff
