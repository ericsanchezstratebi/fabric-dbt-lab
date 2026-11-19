SELECT p.hk_part, p.part_key, p.name, p.manufacturer, p.brand, p.part_type,
       p.size, p.container, p.retail_price, p.load_period AS last_change_period
FROM {{ ref('bv_part_current') }} p
