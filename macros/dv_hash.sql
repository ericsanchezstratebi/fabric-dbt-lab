{% macro dv_hash(columns) -%}
CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', CONCAT(
{%- for c in columns %}
    {%- if not loop.first %}, '|', {% endif -%}
    COALESCE(CONVERT(VARCHAR(500), {{ c }}), '<NULL>')
{%- endfor %}
, '')), 2)
{%- endmacro %}