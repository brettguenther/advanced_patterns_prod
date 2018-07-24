explore: orders_only {
  join: users_only {
    sql_on: ${orders_only.user_id} = ${users_only.id} ;;
    relationship: many_to_one
  }
  join: users_orders {
    sql:  ;;
    relationship: one_to_one
  }
}

view: users_only {
  sql_table_name: demo_db.users ;;
  dimension: id {
    primary_key: yes
  }
  dimension: order_id {}
  measure: count {
    type: count
  }
  dimension: state {}
}

view: orders_only {
  sql_table_name: demo_db.orders ;;
  dimension: user_id {}
  dimension: id {
    primary_key: yes
  }
  measure: count {type:count}
}

view: users_orders {
  dimension: id {
    primary_key: yes
  }
  measure: orders_per_user {
    sql: ${orders_only.count}/${users_only.count} ;;
  }
}
