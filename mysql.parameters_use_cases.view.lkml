explore: orders {
  label: "Orders: Dynamic Dates with Parameters"
  join: order_items {
    sql_on: ${orders.id} = ${order_items.order_id} ;;
    relationship: one_to_many
  }
}


view: orders {
  sql_table_name: demo_db.orders ;;

  dimension: filtered_link_to_look {
    sql: 1=1 ;;
    html: <a href="https://localhost:9999/looks/1?f[orders.created_date]={{_filters['orders.created_date']}}">
    <img src="https://localhost:9999/images/3.0/header/looker_logo@2x-7d7d64ea.png"" />
    </a> ;;
  }
    dimension: filtered_link_to_dashboard {
    sql: 1=1 ;;
    html: <a href="https://localhost:9999/dashboards/2?Date={{_filters['orders.created_date']}}">
          <img src="https://localhost:9999/images/3.0/header/looker_logo@2x-7d7d64ea.png"" />
          </a> ;;
  }


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: id {
    type: string
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension_group: created {
    type: time
    datatype: datetime
    sql: ${TABLE}.created_at ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }


  parameter: date_granularity {
    type: string
    allowed_value: { value: "Day" }
    allowed_value: { value: "Month" }
    allowed_value: { value: "Quarter" }
    allowed_value: { value: "Year" }
  }

  dimension: date {
    label_from_parameter: date_granularity
    sql:
       CASE
         WHEN {% parameter date_granularity %} = 'Day' THEN
           ${created_date}
         WHEN {% parameter date_granularity %} = 'Month' THEN
           ${created_month}
         WHEN {% parameter date_granularity %} = 'Quarter' THEN
           ${created_quarter}
         WHEN {% parameter date_granularity %} = 'Year' THEN
           ${created_year}
         ELSE
           NULL
       END ;;
  }

  dimension: date_with_case_elimination {
    label_from_parameter: date_granularity
    sql:
       {% if orders.date_granularity._parameter_value == "'Day'" %}
           ${created_date}
       {% elsif orders.date_granularity._parameter_value == "'Month'" %}
           ${created_month}
        {% elsif orders.date_granularity._parameter_value == "'Quarter'" %}
           ${created_quarter}
        {% elsif orders.date_granularity._parameter_value == "'Year'" %}
          ${created_year}
      {% else %}
           NULL
       {% endif %};;
  }

  set: detail {
    fields: [id, created_time, user_id, status]
  }
}

view: order_items {
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: id {
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension_group: returned_at {
    type: time
    sql: ${TABLE}.returned_at ;;
  }

  measure: sum_sale_price {
    type: sum
    hidden: yes
    sql: ${sale_price} ;;
  }
  measure: average_sale_price {
    type: average
    hidden: yes
    sql: ${sale_price} ;;
  }
  measure: median_sale_price  {
    type: median
    hidden: yes
    sql: ${sale_price} ;;
  }
  parameter: sale_price_metric_selector {
    type: string
    allowed_value: {
      label: "Sum Sale Price"
      value: "sum_sale_price"
    }
    allowed_value: {
      label: "Average Sale Price"
      value: "average_sale_price"
    }
    allowed_value: {
      label: "Median Sale Price"
      value: "median_sale_price"
    }
  }
  measure: sale_price_metrics {
    label_from_parameter: sale_price_metric_selector
    type: number
    sql:
      {% if sale_price_metric_selector._parameter_value == "'sum_sale_price'" %}
          ${sum_sale_price}
      {% elsif sale_price_metric_selector._parameter_value == "'average_sale_price'" %}
          ${average_sale_price}
      {% elsif sale_price_metric_selector._parameter_value == "'median_sale_price'" %}
          ${median_sale_price}
      {% else %}
           NULL
       {% endif %}
          ;;
  }

  set: detail {
    fields: [id, order_id, sale_price, inventory_item_id, returned_at_time]
  }
}

view: orders_brand_rank {
  derived_table: {
    sql: select b.brand, @row_number:=@row_number+1 AS rank, orders from (select brand, count(*) as orders  from demo_db.order_items
          LEFT JOIN inventory_items on order_items.inventory_item_id = inventory_items.id
          LEFT JOIN products ON products.id = inventory_items.product_id
          group by 1
          ORDER by count(*) desc) as b
     ,(SELECT @row_number:=0) as t;;
  }
  dimension: brand {}

  dimension: rank_full {
    sql: ${TABLE}.rank ;;
  }
  parameter: max_brands {
    type: number
  }

  dimension: rank {
    type: string
    label: "{% if max_brands._parameter_value == 'NULL' %}Rank{% else %}Top {{ max_brands._parameter_value }}{% endif %}"
    sql:
    CASE WHEN ${rank_full} <= {% parameter max_brands %} THEN CONCAT('0',CAST(${rank_full} AS CHAR(50)),'-',${brand}) ELSE 'Other' END;;
  }

  measure: orders {
    type: sum
    sql: ${TABLE}.orders ;;
  }
}
