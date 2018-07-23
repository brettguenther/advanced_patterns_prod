explore: parameter_to_variable {}
view: parameter_to_variable {
  # sql_table_name: {% if parameter_to_variable.myparam_value._sql == 1 %} ifeval {% else %} elseeval {% endif %};;
  # sql_table_name: {% myparam_value._sql %} ;;
  sql_table_name: demo_db.orders ;;
#   sql_table_name: {% assign bg = myparam_value._sql %} ;;
  dimension: test{
    sql: 1=1 ;;
  }

  parameter: myparam {
    type: number
  }
  dimension: myparam_value {
    type: number
    sql:{% parameter myparam %};;
  }
  dimension: myparam_value_2 {
    type: number
    sql: {% if parameter_to_variable.myparam_value._sql == "1" %} id {% else %} elseclause {% endif %} ;;
  }
}
