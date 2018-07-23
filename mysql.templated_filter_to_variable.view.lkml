explore: temp_filter_variable {
  always_filter: {
    filters: {
      field: contains_CNN
    }
  }
}
view: temp_filter_variable {
  sql_table_name: demo_db.orders ;;

  # filter: site_filter {
  #   suggestions: ["Adult Swim","BR","Cartoon Network","CNN","Money","CNNi","ELEAGUE","HLN","NBA","NCAA","PGA","TBS","TruTv","TNTDrama","TBS"]
  # }
  # dimension: site_filter_value {
  #   type: string
  #   sql: {% parameter site_filter %} ;;
  # }

  filter: contains_CNN {
    group_label: "liquid"
  }
  dimension: contains_CNN_templated_filter {
    hidden: yes
    sql:  {% condition contains_CNN %}''{% endcondition %};;
  }
  dimension: vertical {
    group_label: "liquid"
    sql:
    {% assign tf = contains_CNN_templated_filter._value %}
    {% if tf contains "CNN" %}
    'News'
    {% else %}
    'Not News'
    {% endif %};;
  }

# filter: contains_CNN {
#   group_label: "liquid"
# }
# dimension: contains_CNN_templated_filter {
#   sql:  {% condition contains_CNN %}''{% endcondition %};;
# }
#   dimension: vertical {
#     group_label: "liquid"
#     sql:

#     {% assign tf = contains_CNN_templated_filter._sql %}
#     {% if tf == nil %} 'Not News'
#     {% elsif tf contains "CNN" %}
#     'News'
#     {% else %}
#     'Not News'
#     {% endif %};;
#   }

  dimension: contains_CNN_templated_filter_sql {
    type: string
    sql: {{ contains_CNN_templated_filter._sql }} ;;
  }

  dimension: contains_CNN_templated_filter_value {
    type: string
    sql: {{ contains_CNN_templated_filter._value }} ;;
  }

  #   dimension: vertical {
  #   group_label: "liquid"
  #   sql:
  #   {% assign tf = contains_CNN_templated_filter._value %}
  #   {% if tf contains "CNN" %}
  #   'News'
  #   {% else %}
  #   'Not News'
  #   {% endif %};;
  # }

  # dimension: vertical {
  #   group_label: "liquid"
  #   sql:
  #   {% assign tf = contains_CNN_templated_filter._value %}
  #   {% if tf == '' %} 'Not News'
  #   {% elsif tf contains "CNN" %}
  #   'News'
  #   {% else %}
  #   'Not News'
  #   {% endif %}

  #   ;;
  # }



    # {% unless tf contains "cnn" %} 'Not News' {% endunless %}

# dimension: contains_CNN_parameter {
#   type: string
#   sql: {% parameter contains_CNN %} ;;
# }



#   dimension: contains_CNN_parameter_sql {
#     type: string
#     sql: {{  contains_CNN_parameter._sql }} ;;
#   }

#   dimension: contains_CNN_parameter_value {
#     type: string
#     sql: {{  contains_CNN_parameter._value }} ;;
#   }

#   dimension: contains_CNN_templated_filter_sql {
#     type: string
#     sql: {{ contains_CNN_templated_filter._sql }} ;;
#   }

#   dimension: contains_CNN_templated_filter_value {
#     type: string
#     sql: {{ contains_CNN_templated_filter._value }} ;;
#   }

}
