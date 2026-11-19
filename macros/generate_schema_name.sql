{# SOLO laboratorio aislado: crea exactamente stg/rv/bv/mart.
   En entornos compartidos, usar esquemas por usuario o workspace separados. #}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
