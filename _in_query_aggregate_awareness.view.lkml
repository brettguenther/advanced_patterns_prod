

# explore: _in_query_aggregate_awareness {
#   from: rollup_1
#   view_name: rollup_1
#   join: rollup_2 {
#     sql_on: 1=1 ;;
#     relationship: one_to_one
#   }
# }

# view: rollup_1 {
#   sql_table_name:
#   {% if rollup_1._in_query %}
#   {% unless rollup_2._in_query %}
#     rollup_1
#   {% endunless %}
#   {% else %}
#   rollup_3
#   {% endif %} ;;


#   dimension: a {}
#   dimension: b {}
# }

# view: rollup_2 {
#   dimension: c {}
#   dimension: d {}
# }


# # explore: _in_query_aggregate_awareness {
# #   from: rollup_1
# #   view_name: rollup_1
# #   join: rollup_2 {
# #     sql_on: 1=1 ;;
# #   }
# # }

# explore: highest_grain_agg  {
#   join: mid_grain_agg {
#     sql: (SELECT NULL) ON FALSE ;;
#     relationship: one_to_one
#   }
#   join: lowest_grain_agg {
#     sql: (SELECT NULL) ON FALSE ;;
#     relationship: one_to_one
#   }
# }
# view: highest_grain_agg {
#   sql_table_name:
#   {% if highest_grain_agg._in_query %}
#   highest_grain_agg
#   {% elsif mid_grain_agg._in_query %}
#     mid_grain_agg
#   {% else %}
#     lowest_grain_agg
#   {% endif %}
#   ;;


# # if a && b && !c
# #   # ...
# # end
# # then you can do this in Liquid:
# #
# # {% if a and b %}
# #   {% unless c %}
# #     ...
# #   {% endunless %}
# # {% endif %}

#     dimension: a {}
#     dimension: b {}
#   }

#   view: lowest_grain_agg {
#     dimension: c {}
#     dimension: d {}
#   }

# view: mid_grain_agg {
#   dimension: c {}
#   dimension: d {}
# }
