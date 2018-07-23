explore: orders_order_items {
  label: "orders"
  view_label: "snowflake nesting"
  join: order_items {
  sql: ,lateral flatten(input=>order_items) order_items ;;
  relationship: one_to_many
}
}
view: orders_order_items {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: select orders.id as order_id,array_agg(object_construct('item_id',order_items.id,'sale_price',order_items.sale_price)) as order_items from thelook_old.public.orders left join thelook_old.public.order_items on orders.id = order_items.order_id group by 1;;
    persist_for: "24 hours"
  }
dimension: order_id {
  type: number
}
}

view: order_items {

  dimension: order_item_id {
    sql: ${TABLE}.value:item_id ;;
    primary_key: yes
    type: number
  }
  dimension: sale_price {
    sql: ${TABLE}.value:sale_price ;;
    type: number
  }
  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
  }

}
