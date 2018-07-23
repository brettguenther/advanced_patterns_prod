connection: "snowflake_looker"

include: "snowflake*.view.lkml"         # include all views in this project
# include: "*.dashboard.lookml"  # include all dashboards in this project

explore: tweets_agg {}

explore: tweets_base {
  view_label: "Dynamic Joins"
  join:  tweets_agg {
    sql: {% if tweets_agg._in_query and tweet_cluster_by._in_query %} join tweets_agg on ${tweets_agg.created_date} = ${tweets_agg.created_date}
    {% else%} join tweets_agg ON FALSE {% endif %}
    ;;
    relationship: many_to_one
  }
  join: tweet_cluster_by {
    sql: FULL OUTER JOIN ON FALSE ;;
    relationship: many_to_one
  }
}

# explore: events {
#   view_label: "Dynamic Joins"
#   join: events_aggs {
#     sql: {% if event_agg_sampled._in_query and event_agg_unsampled._in_query %}
#     join tweets_agg on ${tweets_agg.timestamp_converted_hour} = ${tweets.timestamp_converted_hour}
#     and
#     {% elsif event_agg_sampled._in_query %}
#     join tweets_agg on ${tweets_agg.timestamp_converted_hour} = ${tweets.timestamp_converted_hour}
#
#     {% else %}
#
#     {% endif %}
#     ;;
#   }
#   }
#
#   explore: base_events {
#   view_label: "Dynamic Joins"
#   join: events_aggs {
#     sql: {% if event_agg_sampled._in_query and event_agg_unsampled._in_query %}
#             join event_agg_sampled on ${event_agg_sampled.timestamp_converted_hour} = ${event_agg_sampled.timestamp_converted_hour}
#             and event_agg_sampled on ${event_agg_unsampled.timestamp_converted_hour} = ${event_agg_unsampled.timestamp_converted_hour}
#           {% elsif event_agg_sampled._in_query %}
#     ;;
#   }
#   }
