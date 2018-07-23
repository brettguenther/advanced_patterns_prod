include: "mysql.parameters_use_cases.view.lkml"
explore: products {
  view_name: products_with_brand_comparitor
  from: products_with_brand_comparitor
  label: "Products: Templated Filters"
}

view: products_with_brand_comparitor {
  sql_table_name: demo_db.products ;;
  dimension: sku {
    type: number value_format_name: id
    sql: ${TABLE}.sku ;;
  }
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  filter: brand_selector {
    type: string
    description: "Use this in conjunction with the population comparison dimension to do dynamic brand vs population logic"
#     suggest_explore: orders
#     suggest_dimension: brand
  }
  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: item_name {
    type: string
    sql: ${TABLE}.item_name ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}.retail_price ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: rank {
    type: number
    sql: ${TABLE}.rank ;;
  }
  dimension: population_comparison {
    sql: CASE WHEN {% condition brand_selector %} ${brand} {% endcondition %}
        THEN ${brand}
      ELSE 'Rest of Population'
    END;;
  }
  filter: department_filter {
    description: "Use in Conjunction with products in department measure and will not restrict results"
    suggestions: ["Men","Women"]
  }
  measure: products_in_department {
    label: "{% if _filters['department_filter']  == blank %}Products Count{% else %}Products for {{ _filters['department_filter'] }}{% endif %}"
    description: "Use this measure in conjunction with the department filter to get a department level count without restricting the results to a specific department"
    sql: case when {% condition department_filter %} ${department} {% endcondition %} THEN 1 ELSE 0 END  ;;
    type: sum
  }

  measure: count {
    type: count
    drill_fields: [id, inventory_items.count]
  }
  measure: count_of_mens_products {
    type: count
    filters: {
      field: department
      value: "Men"
    }
  }
}

explore: orders_cohorts {
  from: orders
  view_name: orders
  join: order_items {
    sql_on: ${orders.id} = ${order_items.order_id} ;;
    relationship: one_to_many
  }
  join: users {
    sql_on: ${users.id} = ${orders.user_id} ;;
    relationship: many_to_one
  }
  join: inventory_items {
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }
  join: products_with_brand_comparitor {
    sql_on: ${products_with_brand_comparitor.id} = ${inventory_items.product_id} ;;
    relationship: many_to_one
  }
  join: user_cohorts {
    type: inner
    sql_on: ${users.id} = ${user_cohorts.user_id} ;;
    relationship: one_to_one
  }
}

view: inventory_items {
  sql_table_name: demo_db.inventory_items ;;
  measure: count {
    type: count
    drill_fields: [detail*]
  }
  dimension: id {
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: sold_at {
    type: time
    sql: ${TABLE}.sold_at ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}.cost ;;
  }
  set: detail {
    fields: [id, product_id, created_at_time, sold_at_time, cost]
  }
}


view: user_cohorts {
  derived_table: {
    sql: SELECT users.id  AS user_id
          FROM order_items
          LEFT JOIN orders ON order_items.order_id = orders.id
          LEFT JOIN inventory_items ON order_items.inventory_item_id = inventory_items.id
          LEFT JOIN products ON inventory_items.product_id = products.id
          LEFT JOIN users ON orders.user_id = users.id
          WHERE ({% condition cohort_filter_item_name %} products.item_name {% endcondition %})
          AND ({% condition cohort_filter_brand_name %} products.brand {% endcondition %} )
          GROUP BY 1 ;;
  }
  filter: cohort_filter_item_name {
    type: string
  }
  filter:cohort_filter_brand_name {
    type: string
    suggestions: ["Calvin Klein"]
  }
  dimension: user_id {
    hidden: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }
}

view: users {
sql_table_name: demo_db.users ;;
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: id {
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}.created_at ;;
  }

  dimension: zip {
    type: number
    sql: ${TABLE}.zip ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  set: detail {
    fields: [
      id,
      email,
      first_name,
      last_name,
      gender,
      created_at_time,
      zip,
      country,
      state,
      city,
      age
    ]
  }
}
