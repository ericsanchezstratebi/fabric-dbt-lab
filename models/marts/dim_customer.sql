SELECT c.hk_customer, c.customer_key, c.name, c.address, c.phone,
       c.account_balance, c.market_segment, c.nation_key, n.nation_name,
       n.region_key, n.region_name, c.load_period AS last_change_period
FROM {{ ref('bv_customer_current') }} c
LEFT JOIN {{ ref('dim_nation') }} n ON c.nation_key=n.nation_key
