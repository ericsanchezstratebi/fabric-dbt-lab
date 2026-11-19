{{ config(materialized='incremental', incremental_strategy='merge', unique_key='sat_row_hk') }}
WITH base AS (
    SELECT hk_supplier, load_period, supplier_key, name, address, nation_key, phone, account_balance, comments_text,
           {{ dv_hash(['supplier_key', 'name', 'address', 'nation_key', 'phone', 'account_balance', 'comments_text']) }} AS hashdiff
    FROM {{ ref('stg_supplier') }}
), sequenced AS (
    SELECT *, LAG(hashdiff) OVER (PARTITION BY hk_supplier ORDER BY load_period) AS previous_hashdiff
    FROM base
)
SELECT {{ dv_hash(['CAST(hk_supplier AS VARCHAR(100))', 'CAST(load_period AS VARCHAR(100))']) }} AS sat_row_hk,
       hk_supplier, load_period, hashdiff,
       supplier_key, name, address, nation_key, phone, account_balance, comments_text,
       'TPCH_LAB' AS record_source
FROM sequenced
WHERE previous_hashdiff IS NULL OR previous_hashdiff <> hashdiff
