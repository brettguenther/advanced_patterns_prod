explore: orders_dynamic_table {}
view: orders_dynamic_table {
  extends: [orders_common_fields]
  sql_table_name:
  {% if orders_dynamic_table.created_time._in_query or orders_dynamic_table.id._in_query %}
  ${orders_highest_grain.SQL_TABLE_NAME}
  {% else  %}
  ${orders_daily.SQL_TABLE_NAME}
  {% endif %} ;;
}

view: orders_daily {
  derived_table: {
    # persist_for: "24 hours"
    sql: SELECT DATE(orders.created_at) as created_at,
         orders.user_id,orders.status,
         (COALESCE(SUM(order_items.sale_price ), 0)) as sale_price
         FROM demo_db.orders as orders
         LEFT JOIN order_items as order_items ON orders.id = order_items.order_id
         GROUP BY 1,2,3  ;;
  }
}

view: orders_highest_grain {
  derived_table: {
    # persist_for: "24 hours"
    sql:  SELECT orders.created_at,
          orders.user_id,orders.id,
          orders.status,
          COALESCE(order_items.sale_price,0) as sale_price
          FROM demo_db.orders as orders
          LEFT JOIN order_items as order_items ON orders.id = order_items.order_id
          group by 1,2,3,4  ;;
  }
}

view: orders_common_fields {
  measure: count {
    type: count
  }

  dimension: id {
    type: string
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [time,date,week,month,year]
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
  measure: total_sale_price {
    type: sum
    sql: ${TABLE}.sale_price ;;
  }
}
