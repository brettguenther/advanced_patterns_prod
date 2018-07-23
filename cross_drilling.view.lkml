explore: _net_sale_dynamic_agg {
  join: _negative_sale_dynamic_agg {
    type: full_outer
    sql_on:
    {% if _net_sale_dynamic_agg.currency._is_filtered OR _net_sale_dynamic_agg.currency._in_query %}
     {% if _net_sale_dynamic_agg.brand._is_filtered OR _net_sale_dynamic_agg.brand._in_query %}
        ${_net_sale_dynamic_agg.currency_roll} = ${_negative_sale_dynamic_agg.currency_roll} and
        ${_net_sale_dynamic_agg.brand_roll} = ${_negative_sale_dynamic_agg.brand_roll}
        {% else %}
        ${_net_sale_dynamic_agg.currency_roll} = ${_negative_sale_dynamic_agg.currency_roll}
      {% endif %}
    {% elsif _net_sale_dynamic_agg.brand._is_filtered OR _net_sale_dynamic_agg.brand._in_query %}
        ${_net_sale_dynamic_agg.brand_roll} = ${_negative_sale_dynamic_agg.brand_roll}
    {% else %}
      -- need some default mapping here - likely a time based mapping which would be the grain of the rollup
    {% endif %}  ;;
  }
}

view: common_dims {
  extension: required
  dimension: currency { sql: coalesce(${_net_sale_dynamic_agg.currency_roll},${_negative_sale_dynamic_agg.currency_roll});; view_label: "Common dimensions"}
  dimension: brand {sql: coalesce(${_net_sale_dynamic_agg.brand_roll},${_negative_sale_dynamic_agg.brand_roll}) ;; view_label: "Common dimensions"}
}

view: _net_sale_dynamic_agg {
  extends: [common_dims]
  derived_table: {
    sql: SELECT SUM(amount * quantity) as sales,
       {% if _net_sale_dynamic_agg.currency._in_query OR _net_sale_dynamic_agg.currency._is_filtered %} currency {% else %} 'all_currencies' {% endif %} as currency_roll,
       {% if _net_sale_dynamic_agg.brand._in_query OR _net_sale_dynamic_agg.brand._is_filtered %} brand {% else %} 'all_brands' {% endif %} as brand_roll
       FROM fact_sale
      LEFT JOIN dim_sku ON dim_sku.id = fact_sale.sku_id
      WHERE created_at::date = '2017-05-02' GROUP BY 2,3 ;;
  }

  measure: total_sales {
    type: sum
    sql: ${sales} ;;
  }

  dimension: sales {
    sql: ${TABLE}.sales ;;
  }

  dimension: currency_roll {
    hidden: yes
    sql: ${TABLE}.currency_roll ;;
  }

  dimension: brand_roll {
    hidden: yes
    sql: ${TABLE}.brand_roll ;;
  }
}

view: _negative_sale_dynamic_agg {
  derived_table: {
    sql: SELECT SUM(amount * quantity) as sales,
       {% if _net_sale_dynamic_agg.currency._in_query OR _net_sale_dynamic_agg.currency._is_filtered %} currency {% else %} 'all_currencies' {% endif %} as currency_roll,
       {% if _net_sale_dynamic_agg.brand._in_query OR _net_sale_dynamic_agg.brand._is_filtered %} brand {% else %} 'all_brands' {% endif %} as brand_roll       FROM fact_return
      LEFT JOIN dim_sku ON dim_sku.id = fact_return.sku_id
      WHERE created_at::date = '2017-05-02' GROUP BY 2,3  ;;
  }

  dimension: neg_sales {
    sql: ${TABLE}.sales ;;
  }

  measure: total_neg_sales {
    type: sum
    sql: ${neg_sales} ;;
  }

  dimension: currency_roll {
    hidden: yes
    sql: ${TABLE}.currency_roll ;;
  }
  dimension: brand_roll {
    hidden: yes
    sql: ${TABLE}.brand_roll ;;
  }

  dimension: pkey {
    primary_key: yes
    hidden: yes
    sql: ${brand_roll} || ${currency_roll} ;;
  }
}
