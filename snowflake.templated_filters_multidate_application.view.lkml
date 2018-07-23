explore: snowflake_templated_filters_multidate_application {}
view: snowflake_templated_filters_multidate_application {
  filter: event_time_filter {
    type: date_time
    # sql: {% condition event_time_filter %} ${event_time} {% endcondition %} and {% condition %} ${date} {% endcondition %};;
    sql: {% condition event_time_filter %} ${event_raw} {% endcondition %} and (DATE({% date_start event_time_filter %}) < ${date} AND DATE({% date_end event_time_filter %}) > ${date}) ;;
    }
   dimension_group: event {
          type: time
          timeframes: [raw,time]
          datatype: epoch
          sql: ${TABLE}.epoch_timestamp ;;
  }
  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }


}
