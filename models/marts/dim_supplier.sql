SELECT s.hk_supplier, s.supplier_key, s.name, s.address, s.phone,
       s.account_balance, s.nation_key, n.nation_name, s.load_period AS last_change_period
FROM {{ ref('bv_supplier_current') }} s
LEFT JOIN {{ ref('dim_nation') }} n ON s.nation_key=n.nation_key
