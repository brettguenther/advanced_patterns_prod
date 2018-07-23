view: merge_simple {
  sql_table_name: (SELECT 1 UNION ALL SELECT 2) ;;
  dimension: name_attribute {
    primary_key: yes
    sql: "{{ _user_attributes['test_name'] }}" ;;
  }
}

# Creates a view that references the underlying 'orders' table in the database
view: orders_merge {
  sql_table_name: orders ;;
  # The 'fields' section includes dimensions and measures for the view
  ### DIMENSIONS ###

  # A dimension is an attribute of the view entity - each dimension will tell us something
  # about a unique 'inventory_item'. Dimensions can be direct references to fields in the underlying table or
  # be custom defined using SQL and references to other dimensions in the model

  dimension: id {
    # 'primary_key' must be defined for the foreign_key declaration to join
    primary_key: yes
    # '${TABLE}' refers to the underlying SQL table ('orders')
    sql: ${TABLE}.id ;;
  }

  dimension: user_id {
    type: number
    hidden: yes
  }

  dimension: converted_tz {
    hidden: yes
    sql: CONVERT_TZ(${TABLE}.created_at,'UTC','America/Los_Angeles') ;;
  }

  dimension: is_before_today {
    type: yesno
    sql: (EXTRACT(DAY FROM ${converted_tz}) < EXTRACT(DAY FROM CURRENT_TIMESTAMP)
        OR
        (
          EXTRACT(DAY FROM ${converted_tz}) = EXTRACT(DAY FROM CURRENT_TIMESTAMP)
        AND
          EXTRACT(HOUR FROM ${converted_tz}) < EXTRACT(HOUR FROM CURRENT_TIMESTAMP)
        )
        OR
        (
          EXTRACT(DAY FROM ${converted_tz}) = EXTRACT(DAY FROM CURRENT_TIMESTAMP)
        AND
          (
            EXTRACT(HOUR FROM ${converted_tz}) <= EXTRACT(HOUR FROM CURRENT_TIMESTAMP)
          )
        AND
          (
            EXTRACT(MINUTE FROM ${converted_tz}) < EXTRACT(MINUTE FROM CURRENT_TIMESTAMP)
          )
        )
      )
       ;;
  }

  # 'dimension_group' allows the creation of multiple dimensions off of a single SQL field
  dimension_group: created {
    # Several built in dimensions are available for 'type: time'
    type: time
    label: ""
    group_label: "test"
    # For complete list see the reference guide: http://docs.looker.com/documentation/reference/reference.html#timeframes
    sql: ${TABLE}.created_at ;;
  }

  dimension: until_this_week {
    type: yesno
    sql: ${created_day_of_week_index} < WEEKDAY(NOW()) AND ${created_day_of_week_index} >= 0;;
  }

  #   - dimension: created_tiered
  #     type: tier
  #     sql: ${days_to_process}
  #     tiers: [0,30,60,90]

  dimension: days_since_order {
    type: number
    sql: DATEDIFF(CURDATE(),${created_date}) ;;
  }

  dimension: days_since_order_tier {
    type: tier
    tiers: [0, 30, 60, 90]
    style: integer
    sql: ${days_since_order} ;;
  }

  dimension_group: created_randomized {
    description: "Hour has been randomized for variation"
    type: time
    timeframes: [
      time,
      date,
      day_of_month,
      hour_of_day,
      week,
      week_of_year,
      month,
      month_num,
      day_of_week,
      day_of_week_index,
      year
    ]
    sql: date_add(${created_raw}, INTERVAL (ROUND((RAND() * (100)))) HOUR) ;;
  }

#   dimension: days_since_first_purchase {
#     hidden: yes
#     type: number
#     sql: DATEDIFF(${created_date}, ${user_order_facts.first_order_date}) ;;
#   }

#   measure: sum_30 {
#     type: sum
#     sql: ${days_since_first_purchase};;
#     filters: {
#       field: created_time
#       value: "30 days ago for 30 days"
#     }
#   }
#
#   measure: days_since_first_purchase_sum {
#     type: sum
#     hidden: yes
#     sql: ${days_since_first_purchase} ;;
#   }
#
#   dimension: months_since_first_purchase {
#     type: number
#     sql: CEILING(${days_since_first_purchase}/(30)) ;;
#   }
#
#   dimension: weeks_since_first_purchase {
#     type: number
#     sql: CEILING(${days_since_first_purchase}/(7)) ;;
#   }

#   dimension: test_2 {
#     type: number
#     sql: (
#       SELECT count(*)
#       FROM ${SQL_TABLE_NAME} ) ;;
#   }

  # Default week settings (Monday to Sunday) can be adjusted
  dimension: week_starting_tuesday {
    sql: DATE_ADD(DATE(CONVERT_TZ(orders.created_at,'UTC','America/Los_Angeles')),INTERVAL (0-(DAYOFWEEK(CONVERT_TZ(orders.created_at,'UTC','America/Los_Angeles'))+4)%7) DAY)
      ;;
  }

  dimension: user_order_sequence_number {
    type: number
    sql: (
        SELECT COUNT(*)
        FROM orders o
        WHERE o.id <= ${TABLE}.id
          AND o.user_id = ${TABLE}.user_id
      )
       ;;
  }

  dimension: is_first_purchase {
    type: yesno
    sql: ${user_order_sequence_number} = 1 ;;
  }

  #   - dimension: has_ordered_more_than_once
  #     type: yesno
  #     sql: ${count} > 1

  dimension: total_amount_of_order_usd {
    type: number
    value_format_name: decimal_2
    sql: (SELECT SUM(order_items.sale_price)
      FROM order_items
      WHERE order_items.order_id = orders.id)
       ;;
    html: <p style="padding-top:15px;font-size:30px">{{value}}</p> ;;
  }

  dimension: total_amount_of_order_usd_tier {
    type: tier
    sql: ${total_amount_of_order_usd} ;;
    tiers: [
      0,
      10,
      50,
      150,
      500,
      1000
    ]
  }

  dimension: total_cost_of_order {
    type: number
    value_format_name: decimal_2
    sql: (SELECT SUM(inventory_items.cost)
      FROM order_items
      LEFT JOIN inventory_items ON order_items.inventory_item_id = inventory_items.id
      WHERE order_items.order_id = orders.id)
       ;;
  }

  dimension: order_profit {
    type: number
    value_format: "$0.00"
    sql: ${total_amount_of_order_usd} - ${total_cost_of_order} ;;
  }

  dimension: test_case {
    type: string

    case: {
      when: {
        sql: ${TABLE}.id = 1 ;;
        label: "Stuff"
      }

      when: {
        sql: true ;;
        label: "Stuff, extra"
      }
    }
  }

  # needs testing
  #   - dimension: months_from_user_signup
  #     type: number
  #     sql: DATEDIFF(${created_date}, ${users.created_date}) / 30


  ### MEASURES ###

  # Measures are aggregate functions that can count rows, aggregate over values of dimensions,
  # count only rows that satisfy certain filter values, or create calculated measures referencing other measures.

  measure: count {
    type: count_distinct
    sql: ${TABLE}.id ;;
    drill_fields: [orders_drill_set_1*]
  }

  dimension: dim_test {
    type: number
    sql: ${TABLE}.id ;;
    html: {% if value == 26788 %}
        {{ linked_value | replace: '<a', '<a style=font-weight:bold' }}
      {% else %}
        {{ linked_value }}
      {% endif %}
      ;;
  }

  measure: measure_test {
    type: number
    sql: ${TABLE}.id ;;
    html: {% if value == 26788 %}
        <span style="font-weight:bold">{{ rendered_value }}</span>
      {% else %}
        {{ rendered_value }}
      {% endif %}
      ;;
  }

  measure: another_test {
    type: number
    sql: ${TABLE}.id ;;
    html: {% if value == 26788 %}
        <div style="text-align:center;font-weight: bold">{{ rendered_value }}</div>
      {% else %}
        {{ rendered_value }}
      {% endif %}
      ;;
  }

  measure: first_purchase_count {
    type: count
    drill_fields: [orders_drill_set_1*]

    filters: {
      field: is_first_purchase
      value: "yes"
    }
  }

  measure: average_amount_of_order_usd {
    type: average
    value_format_name: decimal_2
    sql: ${total_amount_of_order_usd} ;;
  }

  measure: count_percent_change {
    label: "Count (Percent Change)"
    type: percent_of_previous
    value_format_name: decimal_1
    sql: ${count} ;;
  }

  measure: count_percent_of_total {
    label: "Count (Percent of Total)"
    type: percent_of_total
    value_format_name: decimal_1
    sql: ${count} ;;
  }

  measure: new_customer_revenue {
    type: sum
    sql: ${total_amount_of_order_usd} ;;
    value_format_name: decimal_2

    filters: {
      field: is_first_purchase
      value: "yes"
    }
  }

  measure: new_customer_orders {
    type: count
    drill_fields: [orders_drill_set_1*]

    filters: {
      field: is_first_purchase
      value: "yes"
    }
  }

  measure: repeat_customer_revenue {
    type: sum
    sql: ${total_amount_of_order_usd} ;;
    value_format_name: decimal_2

    filters: {
      field: is_first_purchase
      value: "no"
    }
  }

  measure: repeat_customer_orders {
    type: count
    drill_fields: [orders_drill_set_1*]

    filters: {
      field: is_first_purchase
      value: "no"
    }
  }

  measure: total_profit {
    type: sum
    sql: ${order_profit} ;;
    value_format_name: decimal_2
    html: ${{ rendered_value }};;
  }

  measure: total_revenue {
    type: sum
    sql: ${total_amount_of_order_usd} ;;
    value_format_name: decimal_2
    html: ${{ rendered_value }};;
  }

  measure: cumulative_total_profit {
    type: running_total
    direction: "column"
    sql: ${total_profit} ;;
    value_format_name: usd
  }

  measure: average_order_profit {
    type: average
    sql: ${order_profit} ;;
  }

  measure: avg_time {
    type: string
    sql: DATE_FORMAT(SEC_TO_TIME(AVG(TIME_TO_SEC(TIME(${created_time})))), '%H:%i:%s') ;;
  }

  measure: ncr_over_tr {
    type: number
    sql: ${new_customer_revenue}/${total_revenue} ;;
    value_format: "#.##"
  }

  ### SETS ###

  # Sets are a list of dimensions and measures that can be referenced collectively as a set, for functions like drill down.
  # You reference a set with the set name, like 'export_set' or 'orders_drill_set_1' below.

  # Set names are explicitly defined by the user and included looker fields are tabbed below
  set: orders_drill_set_1 {
    fields: [
      id,
      created_time,

      # This is a looker view.field pair from a joined table ('orders'), this is not SQL
      users.name,
      users.history,
      total_cost_of_order,
      order_items.count,
      products.list
    ]
  }
}
view: users_merge {
  sql_table_name: users ;;
  # DIMENSIONS #
  # Attributes of the data (the 'users' view)

  dimension: id {
    type: number
    # 'primary_key' must be defined for the foreign_key declaration to join
    primary_key: yes
    # '${TABLE}' refers to the underlying SQL table ('users')
    sql: ${TABLE}.id ;;
  }

  # By default, looker will assume fields without 'sql:' have the same name in the database as the dimension name
  dimension: age {
    # In this case, 'users.age' is the implied column
    type: number
  }



  dimension: age_tier {
    # 'type: tier' groups values of a numeric dimension into buckets
    type: tier
    # '${age}' references the Looker dimension 'age' rather than the underlying SQL field 'age'
    sql: ${age} ;;
    # 'style: integer' will express the buckets as easy to read numbers, instead of showing the notation below
    style: integer
    # 'tiers:' defines the range for each bucket, i.e. [-inf, 0), [0, 10), [10, 20), ..., [80, inf)
    tiers: [
      0,
      10,
      20,
      30,
      40,
      50,
      60,
      70,
      80
    ]
  }

  dimension: city {}
  dimension: country {}
  # 'dimension_group' allows the creation of multiple dimensions off of a single SQL field
  dimension_group: created {
    # Several built in dimensions are available for 'type: time'
    type: time
    # For complete list see the reference guide: http://docs.looker.com/documentation/reference/reference.html#timeframes
    #timeframes: [time, date, week, month, year, month_name]
    sql: ${TABLE}.created_at ;;
    # Timezone conversion can be controlled by the user, the default is true
    convert_tz: yes
  }

  dimension: created_week_sunday {
    type: date
    sql: DATE_ADD(${created_date},INTERVAL (0-(DAYOFWEEK(${created_date})+6)%7) DAY) ;;
    convert_tz: no
  }

  dimension: test_friday {
    type: date
    sql: DATE_ADD(${created_week}, INTERVAL 5 DAY) ;;
  }

  dimension_group: created_add_30_min {
    type: time
    timeframes: [time, date, week, month, year]
    sql: DATEADD(${TABLE}.created_at, INTERVAL '30 minutes') ;;
    convert_tz: yes
  }

  dimension: email {}
  dimension: gender {}
  # The 'name' field is a simple concatenation of two SQL fields

  dimension: name {
    sql: CONCAT(${TABLE}.first_name,' ', ${TABLE}.last_name) ;;
    link: {
      label: "Average Order Profit"
      url: "https://oldlearn.looker.com/looks/249?&f[users.state]={{ _filters['users.state'] | url_encode }}"
    }
    link: {
      label: "Business Pulse Dasboard"
      url: "https://oldlearn.looker.com/dashboards/73?Date=90%20days&State%20%2F%20Region={{ _filters['users.state'] | url_encode }}&Brand=&Category=&City="
    }
    link: {
      label: "User Facts Explore"
      url: "https://oldlearn.looker.com/explore/ecommerce/users?fields=users.name,user_order_facts.days_as_customer,user_order_facts.days_since_purchase,user_order_facts.lifetime_orders&f[users.state]={{ _filters['users.state'] | url_encode }}"
    }
  }

  dimension: history {
    # 'html' can be used to format dimensions or measures into links, add currency symbols, color formating, images, etc
    sql: ${TABLE}.id ;;
    html: <a href="/explore/ecommerce/orders?fields=orders.orders_drill_set_1*&f[users.id]={{ value }}">Orders</a>
      | <a href="/explore/ecommerce/order_items?fields=order_items.order_items_drill_set_1*&f[users.id]={{ value }}">Items</a>
      ;;
  }

  dimension: state {}

  dimension: coast {
    type: string
    sql:
      CASE WHEN ${state} IN ('California', 'Washington', 'Oregon') THEN 'West Coast'
           WHEN ${state} IN ('New York', 'New Jersey', 'Delaware') THEN 'East Coast'
           ELSE NULL END;;
  }

  dimension: zip {
    type: zipcode
  }

  dimension: zipcode {
    type: zipcode
    # 'hidden: true' dimensions are hidden from the Explore tab but can be referred to elsewhere in the view
    hidden: yes
    sql: ${zip} ;;
  }

  dimension: first_name_filter {
    hidden: yes
    sql: case when first_name= {% parameter first_name_filter %} then first_name else last_name end ;;
  }

  ### MEASURES ###

  # Measures are aggregate functions that can count rows, aggregate over values of dimensions,
  # count only rows that satisfy certain filter values, or create calculated measures referencing other measures.

  # The SQL generated by 'type: count' uses a simple COUNT(*) when counting in the base_view ('users')
  measure: count {
    # If 'users' is joined from another view, the generated SQL uses 'COUNT(DISTINCT user.id)'
    type: count
    # 'detail' allows drill-down to a list of dimensions and measures
    # Rather than listing dimensions or measures for a drill path, you can call a set (defined at the bottom of this view file)
    # To call a set, use a star after the set name (ie. 'users_drill_set_1*')
    drill_fields: [users_drill_set_1*]
    link: {
      label: "Google"
      url: "www.google.com"
    }
  }

  # When a query using USERS count is from the USERS base view it results in a count(*). If the query originates
  # in a base view that USERS has been joined to it will result ina  COUNT(DISTINCT user.id) - Looker
  # will count disctinct the primary key of the view that has been joined.

  measure: count_percent_of_total {
    # 'label' allows renaming of dimensions or measures into more readable formats, in this case adding parentheses
    label: "Count (Percent of Total)"
    # 'percent_of_total' is a 'type' that is computed as a percentage of the underlying measure ('count')
    type: percent_of_total
    # A bracketed array allows drilldown to specific dimensions or measures, rather than a pre-defined set
    drill_fields: [id, name, email, city]
    # The number of decimals rendered can be explicitly defined (default is 0)
    value_format_name: decimal_1
    sql: ${count} ;;
  }

  ### SETS ###

  # Sets are a list of dimensions and measures that can be referenced collectively as a set, for functions like drill down.
  # You reference a set with the set name, like 'export' or 'users_drill_set_1' below.

  # Set names are explicitly defined by the user and included looker fields are tabbed below
  set: users_drill_set_1 {
    fields: [
      id,
      name,
      email,
      city,
      state,
      country,
      zip,
      gender,
      age,
      history,

      # This is a looker view.field pair from a joined view ('orders'), this is not SQL
      orders.count,
      order_items.count
    ]
  }

  # This is another set that can be called in the view
  set: user_drill_set_2 {
    fields: [id, name]
  }
}

# Creates a view that references the underlying 'orderinventory_items' table in the database
# sql_table_name: ulgy_name_order_items   # The 'view' parameter does not need to match the underlying table name
# If the 'view' parameter does not match the underlying table name, 'sql_table_name' should refer to
# the underlying table (e.g. view: 'order_items', 'sql_table_name: ulgy_name_order_items')
view: order_items_merge {
  # The 'fields' section includes dimensions and measures for the view
  filter: date_filter {
    label: "Apply Created Date filter to Returned Date filter?"
    type: yesno
    sql: {% condition orders.created_date %} ${order_items.return_date} {% endcondition %} AND
      {% condition order_items.return_date %} ${orders.created_date} {% endcondition %}
       ;;
    hidden: yes
  }

  ### DIMENSIONS ###

  # A dimension is an attribute of the view entity - each dimension will tell us something
  # about a unique 'order_item'. Dimensions can be direct references to fields in the underlying table or
  # be custom defined using SQL and references to other dimensions in the model


  dimension: id {
    # Casts dimension to type 'int'
    type: number
    # 'primary_key' must be defined for the foreign_key declaration to join
    primary_key: yes
    # ${TABLE} refers to the underlying SQL table ('order_items')
    sql: ${TABLE}.id ;;
  }

  dimension: inventory_item_id {
    type: number
    # 'hidden: true' dimensions are hidden from the Explore tab but can be referred to elsewhere in the view
    hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  # 'return_date' is an alias for the underlying attribute 'returned_at'
  dimension: return_date {
    # Casts dimension to type 'date'
    type: date
    sql: ${TABLE}.returned_at ;;
  }

  dimension: returned {
    # Casts dimension to a binary 'yes or no'
    type: yesno
    # ${DIMENSION} references the Looker dimension rather than the underlying SQL fields
    # This is best practice in Looker because it is a more re-usable approach (see http://looker.com/news/blog/reusability-paradigm-lookml)
    sql: ${return_date} ;;
  }

  dimension: order_id {
    type: number
    hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: sale_price {
    # Displays description when hovering over the dimension in the Explore section
    description: "Customer's price."
    # Casts dimension to type number
    type: number
    # The number of decimals rendered can be explicitly defined (default is 0)
    value_format_name: gbp
    sql: ${TABLE}.sale_price ;;
  }

  # 'gross_margin' is a calculated dimension that is not representative of a field in the underlying SQL table
  dimension: gross_margin {
    # The dimension is calculated on-the-fly at runtime
    type: number
    value_format_name: decimal_2
    # '${inventory_items.cost} scopes to the 'cost' dimension in the 'inventory_items' view
    # When referencing a dimension from another view, add the view name followed by a period (e.g. 'inventory_items.')
    # The scoped view, 'intentory_items', must be joined to the base_view, 'order_items', in the model file
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

  dimension: gross_margin_tier {
    type: tier
    sql: ${gross_margin} ;;
    tiers: [0, 50, 100, 200, 400]
  }

  measure: percent_total_gm {
    type: percent_of_total
    sql: ${total_gross_margin} ;;
  }

  dimension: item_gross_margin_percentage {
    # Raw SQL, e.g. 'NULLIF', and arithmetic, e.g. '100.0 *', can be used in the 'sql' parameter
    type: number
    sql: 100.0 * ${gross_margin}/NULLIF(${sale_price}, 0) ;;
  }

  dimension: item_gross_margin_percentage_tier {
    # 'type: tier' groups values of a numeric dimension into buckets
    type: tier
    # Defines the dimension to apply the tiers to
    sql: ${item_gross_margin_percentage} ;;
    # 'tiers:' defines the range for each bucket, i.e. [-inf, 0), [0, 10), [10, 20), ..., [90, inf)
    tiers: [
      0,
      10,
      20,
      30,
      40,
      50,
      60,
      70,
      80,
      90
    ]
  }

  ### MEASURES ###

  # Measures are aggregate functions that can count rows, aggregate over values of dimensions,
  # count only rows that satisfy certain filter values, or create calculated measures referencing other measures.

  # The SQL generated by 'type: count' uses a COUNT(*) when counting in the base_view ('order_items')
  measure: count {
    # If 'order_items' is joined from another view, the generated SQL uses 'COUNT(DISTINCT user.id)'
    type: count
    # 'detail' allows drill-down to a list of dimensions and measures
    # Rather than listing dimensions or measures for a drill path, you can call a set (defined at the bottom of this view file)
    # To call a set, use a star after the set name (ie. 'order_items_drill_set_1*')
    drill_fields: [order_items_drill_set_1*]
  }

  measure: count_drill {
    type: count
    drill_fields: [order_items_drill_set_2*]
  }

  measure: total_gross_margin {
    type: sum
    value_format_name: decimal_2
    sql: ${gross_margin} ;;
    html: {{ rendered_value }} || {{ percent_total_gm._rendered_value }} of total
      ;;
  }

  measure: total_sale_price {
    # HTML can be embedded into Looker dimensions or measures to format, include links, add currency symbols, format colors, add images, etc...
    type: sum
    # ${{ rendered_value }} places a '$' symbol in front of the cost value. Looker uses Liquid templating to reference the value of the 'cost' dimension
    sql: ${sale_price} ;;
    value_format_name: usd
    html: ${{ rendered_value }}
      ;;
  }

  measure: cumulative_total_revenue {
    type: running_total
    sql: ${total_sale_price} ;;
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format_name: gbp
    html: ${{ rendered_value }}
      ;;
  }

  measure: sale_price_median {
    type: median
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: average_gross_margin {
    type: average
    sql: ${gross_margin} ;;
    value_format_name: decimal_2
  }


  #   - measure: gross_margin_percentage
  #     type: number
  #     sql: 100.0 * ${total_gross_margin}/${total_sale_price}      # postgres does integer division by default, so multiply by 100.
  #     value_format_name: decimal_2                                                 # to force real numbers


  ### SETS ###

  # Sets are a list of dimensions and measures that can be referenced collectively as a set, for functions like drill down.
  # You reference a set with the set name, like 'order_items_drill_set_1' below.

  # Set names are explicitly defined by the user and included Looker fields are tabbed below
  set: order_items_drill_set_1 {
    fields: [

      # This is a Looker VIEW.FIELD pair from a joined view ('orders'), this is not SQL
      orders.created_date,
      id,
      orders.id,
      users.name,
      users.history,
      products.item_name,
      products.brand,
      products.category,
      products.department,
      total_sale_price
    ]
  }
  set: order_items_drill_set_2 {
    fields: [
      orders.created_date,
      total_sale_price
    ]
  }
}
