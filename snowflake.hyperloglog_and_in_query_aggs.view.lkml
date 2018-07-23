explore: tweets {}

view: dynamic_tweets {
  sql_table_name:
  {% if created_time._in_query %}
  ${tweets.SQL_TABLE_NAME}
  {% else  %}
  ${tweets_agg.SQL_TABLE_NAME}
  {% endif %} ;;

  dimension_group: created {
    type: time
    timeframes: [time,date,week]
    sql: ${TABLE}.created_at ;;
  }
  dimension: user_hll {}
  measure: user_count {
    type: number
    sql:hll_estimate(hll_combine(${user_hll}));;
  }
}

view: tweets_daily {
  derived_table: {
    sql: select tweets.hll_accumulate(to_number(tweets.raw:user:id)) from SNOW_TWITTER.PUBLIC.TWEETS as tweets ;;
    persist_for: "24 hours"
  }
}

# view: tweets {
#   derived_table: {
#     sql: select tweets.raw:contributors as contributors, hll_accumulate(to_number(tweets.raw:user:id)) from PUBLIC.TWEETS as tweets  ;;
#     persist_for: "24 hours"
#   }
#   dimension: contributors {
#     type: string
#     sql: ${TABLE}.raw:contributors ;;
#   }
# }


view: tweets_agg {
  derived_table: {
    explore_source: tweets {
      column: created_date {}
      column: user_hll {}
    }
    persist_for: "24 hours"
  }
  dimension: created_date {type: date}
  dimension: user_hll {}
  measure: user_count {
    type: number
    sql: hll_estimate(hll_combine(${user_hll}));;
  }
}

view: tweet_cluster_by {
  derived_table: {
    sql: SELECT
        to_number(tweets.raw:user:id)  AS user_id,
        COUNT(DISTINCT (to_number(tweets.raw:user:id)) ) AS number_of_users,
        COUNT(*) AS record_count

      FROM SNOW_TWITTER.PUBLIC.TWEETS  AS tweets
      GROUP BY 1
      order by 1 desc
      CLUSTER BY (user_id);;

      persist_for: "24 hours"
    }
    dimension: user_id {}
    dimension: number_of_users {}
  }


  view: tweets_base {
    sql_table_name: SNOW_TWITTER.PUBLIC.TWEETS ;;
    dimension: contributors {
      type: string
      sql: ${TABLE}.raw:contributors ;;
    }
    dimension: contributors_enabled {
      type: string
      sql: ${TABLE}.raw:user:contributors_enabled ;;
    }
    dimension: coordinates {
      type: string
      sql: ${TABLE}.raw:coordinates ;;
    }
    dimension: created_at {
      type: string
      sql: ${TABLE}.raw:created_at ;;
    }
    dimension: default_profile {
      type: string
      sql: ${TABLE}.raw:user:default_profile ;;
    }
    dimension: default_profile_image {
      type: string
      sql: ${TABLE}.raw:user:default_profile_image ;;
    }
    dimension: description {
      type: string
      sql: ${TABLE}.raw:user:description ;;
    }
    dimension: entities {
      type: string
      sql: ${TABLE}.raw:entities ;;
    }
    dimension: favorite_count {
      type: string
      sql: ${TABLE}.raw:favorite_count ;;
    }
    dimension: favorited {
      type: string
      sql: ${TABLE}.raw:favorited ;;
    }
    dimension: favourites_count {
      type: string
      sql: ${TABLE}.raw:user:favourites_count ;;
    }
    dimension: filter_level {
      type: string
      sql: ${TABLE}.raw:filter_level ;;
    }
    dimension: follow_request_sent {
      type: string
      sql: ${TABLE}.raw:user:follow_request_sent ;;
    }
    dimension: followers_count {
      type: string
      sql: ${TABLE}.raw:user:followers_count ;;
    }
    dimension: following {
      type: string
      sql: ${TABLE}.raw:user:following ;;
    }
    dimension: friends_count {
      type: string
      sql: ${TABLE}.raw:user:friends_count ;;
    }
    dimension: geo {
      type: string
      sql: ${TABLE}.raw:geo ;;
    }
    dimension: geo_enabled {
      type: string
      sql: ${TABLE}.raw:user:geo_enabled ;;
    }
    dimension: hashtags {
      type: string
      sql: ${TABLE}.raw:entities:hashtags ;;
    }
    dimension: user_id {
      type: number
      sql: to_number(${TABLE}.raw:user:id) ;;
    }
    measure: record_count {
      type: count
    }
    measure: number_of_users {
      type: count_distinct
      sql: ${user_id} ;;
    }
    measure: user_hll {
      sql: hll_accumulate(${user_id}) ;;
    }

    dimension: id_str {
      type: string
      sql: ${TABLE}.raw:user:id_str ;;
    }
    dimension: in_reply_to_screen_name {
      type: string
      sql: ${TABLE}.raw:in_reply_to_screen_name ;;
    }
    dimension: in_reply_to_status_id {
      type: string
      sql: ${TABLE}.raw:in_reply_to_status_id ;;
    }
    dimension: in_reply_to_status_id_str {
      type: string
      sql: ${TABLE}.raw:in_reply_to_status_id_str ;;
    }
    dimension: in_reply_to_user_id {
      type: string
      sql: ${TABLE}.raw:in_reply_to_user_id ;;
    }
    dimension: in_reply_to_user_id_str {
      type: string
      sql: ${TABLE}.raw:in_reply_to_user_id_str ;;
    }
    dimension: is_quote_status {
      type: string
      sql: ${TABLE}.raw:is_quote_status ;;
    }
    dimension: is_translator {
      type: string
      sql: ${TABLE}.raw:user:is_translator ;;
    }
    dimension: lang {
      type: string
      sql: ${TABLE}.raw:lang ;;
    }
    dimension: listed_count {
      type: string
      sql: ${TABLE}.raw:user:listed_count ;;
    }
    dimension: location {
      type: string
      sql: ${TABLE}.raw:user:location ;;
    }
    dimension: name {
      type: string
      sql: ${TABLE}.raw:user:name ;;
    }
    dimension: notifications {
      type: string
      sql: ${TABLE}.raw:user:notifications ;;
    }
    dimension: place {
      type: string
      sql: ${TABLE}.raw:place ;;
    }
    dimension: profile_background_color {
      type: string
      sql: ${TABLE}.raw:user:profile_background_color ;;
    }
    dimension: profile_background_image_url {
      type: string
      sql: ${TABLE}.raw:user:profile_background_image_url ;;
    }
    dimension: profile_background_image_url_https {
      type: string
      sql: ${TABLE}.raw:user:profile_background_image_url_https ;;
    }
    dimension: profile_background_tile {
      type: string
      sql: ${TABLE}.raw:user:profile_background_tile ;;
    }
    dimension: profile_banner_url {
      type: string
      sql: ${TABLE}.raw:user:profile_banner_url ;;
    }
    dimension: profile_image_url {
      type: string
      sql: ${TABLE}.raw:user:profile_image_url ;;
    }
    dimension: profile_image_url_https {
      type: string
      sql: ${TABLE}.raw:user:profile_image_url_https ;;
    }
    dimension: profile_link_color {
      type: string
      sql: ${TABLE}.raw:user:profile_link_color ;;
    }
    dimension: profile_sidebar_border_color {
      type: string
      sql: ${TABLE}.raw:user:profile_sidebar_border_color ;;
    }
    dimension: profile_sidebar_fill_color {
      type: string
      sql: ${TABLE}.raw:user:profile_sidebar_fill_color ;;
    }
    dimension: profile_text_color {
      type: string
      sql: ${TABLE}.raw:user:profile_text_color ;;
    }
    dimension: profile_use_background_image {
      type: string
      sql: ${TABLE}.raw:user:profile_use_background_image ;;
    }
    dimension: protected {
      type: string
      sql: ${TABLE}.raw:user:protected ;;
    }
    dimension: retweet_count {
      type: string
      sql: ${TABLE}.raw:retweet_count ;;
    }
    dimension: retweeted {
      type: string
      sql: ${TABLE}.raw:retweeted ;;
    }
    dimension: screen_name {
      type: string
      sql: ${TABLE}.raw:user:screen_name ;;
    }
    dimension: source {
      type: string
      sql: ${TABLE}.raw:source ;;
    }
    dimension: statuses_count {
      type: string
      sql: ${TABLE}.raw:user:statuses_count ;;
    }
    dimension: symbols {
      type: string
      sql: ${TABLE}.raw:entities:symbols ;;
    }
    dimension: text {
      type: string
      sql: ${TABLE}.raw:text ;;
    }
    dimension: time_zone {
      type: string
      sql: ${TABLE}.raw:user:time_zone ;;
    }
    dimension: timestamp_ms {
      type: string
      sql: ${TABLE}.raw:timestamp_ms ;;
    }
    dimension_group: created {
      datatype: timestamp
      type: time
      sql: TO_TIMESTAMP(cAST(${TABLE}.raw:timestamp_ms AS integer),3) ;;
    }
    dimension: truncated {
      type: string
      sql: ${TABLE}.raw:truncated ;;
    }
    dimension: url {
      type: string
      sql: ${TABLE}.raw:user:url ;;
    }
    dimension: urls {
      type: string
      sql: ${TABLE}.raw:entities:urls ;;
    }
    dimension: user {
      type: string
      sql: ${TABLE}.raw:user ;;
    }
    dimension: user_mentions {
      type: string
      sql: ${TABLE}.raw:entities:user_mentions ;;
    }
    dimension: utc_offset {
      type: string
      sql: ${TABLE}.raw:user:utc_offset ;;
    }
    dimension: verified {
      type: string
      sql: ${TABLE}.raw:user:verified ;;
    }
  }

view: tweets {
  sql_table_name: SNOW_TWITTER.PUBLIC.TWEETS ;;
  dimension: contributors {
    type: string
    sql: ${TABLE}.raw:contributors ;;
  }
  dimension: contributors_enabled {
    type: string
    sql: ${TABLE}.raw:user:contributors_enabled ;;
  }
  dimension: coordinates {
    type: string
    sql: ${TABLE}.raw:coordinates ;;
  }
  dimension: created_at {
    type: string
    sql: ${TABLE}.raw:created_at ;;
  }
  dimension: default_profile {
    type: string
    sql: ${TABLE}.raw:user:default_profile ;;
  }
  dimension: default_profile_image {
    type: string
    sql: ${TABLE}.raw:user:default_profile_image ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}.raw:user:description ;;
  }
  dimension: entities {
    type: string
    sql: ${TABLE}.raw:entities ;;
  }
  dimension: favorite_count {
    type: string
    sql: ${TABLE}.raw:favorite_count ;;
  }
  dimension: favorited {
    type: string
    sql: ${TABLE}.raw:favorited ;;
  }
  dimension: favourites_count {
    type: string
    sql: ${TABLE}.raw:user:favourites_count ;;
  }
  dimension: filter_level {
    type: string
    sql: ${TABLE}.raw:filter_level ;;
  }
  dimension: follow_request_sent {
    type: string
    sql: ${TABLE}.raw:user:follow_request_sent ;;
  }
  dimension: followers_count {
    type: string
    sql: ${TABLE}.raw:user:followers_count ;;
  }
  dimension: following {
    type: string
    sql: ${TABLE}.raw:user:following ;;
  }
  dimension: friends_count {
    type: string
    sql: ${TABLE}.raw:user:friends_count ;;
  }
  dimension: geo {
    type: string
    sql: ${TABLE}.raw:geo ;;
  }
  dimension: geo_enabled {
    type: string
    sql: ${TABLE}.raw:user:geo_enabled ;;
  }
  dimension: hashtags {
    type: string
    sql: ${TABLE}.raw:entities:hashtags ;;
  }
  dimension: user_id {
    type: number
    sql: to_number(${TABLE}.raw:user:id) ;;
  }
  measure: record_count {
    type: count
  }
  measure: number_of_users {
    type: count_distinct
    sql: ${user_id} ;;
  }
  measure: user_hll {
    sql: hll_accumulate(${user_id}) ;;
  }

  dimension: id_str {
    type: string
    sql: ${TABLE}.raw:user:id_str ;;
  }
  dimension: in_reply_to_screen_name {
    type: string
    sql: ${TABLE}.raw:in_reply_to_screen_name ;;
  }
  dimension: in_reply_to_status_id {
    type: string
    sql: ${TABLE}.raw:in_reply_to_status_id ;;
  }
  dimension: in_reply_to_status_id_str {
    type: string
    sql: ${TABLE}.raw:in_reply_to_status_id_str ;;
  }
  dimension: in_reply_to_user_id {
    type: string
    sql: ${TABLE}.raw:in_reply_to_user_id ;;
  }
  dimension: in_reply_to_user_id_str {
    type: string
    sql: ${TABLE}.raw:in_reply_to_user_id_str ;;
  }
  dimension: is_quote_status {
    type: string
    sql: ${TABLE}.raw:is_quote_status ;;
  }
  dimension: is_translator {
    type: string
    sql: ${TABLE}.raw:user:is_translator ;;
  }
  dimension: lang {
    type: string
    sql: ${TABLE}.raw:lang ;;
  }
  dimension: listed_count {
    type: string
    sql: ${TABLE}.raw:user:listed_count ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}.raw:user:location ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}.raw:user:name ;;
  }
  dimension: notifications {
    type: string
    sql: ${TABLE}.raw:user:notifications ;;
  }
  dimension: place {
    type: string
    sql: ${TABLE}.raw:place ;;
  }
  dimension: profile_background_color {
    type: string
    sql: ${TABLE}.raw:user:profile_background_color ;;
  }
  dimension: profile_background_image_url {
    type: string
    sql: ${TABLE}.raw:user:profile_background_image_url ;;
  }
  dimension: profile_background_image_url_https {
    type: string
    sql: ${TABLE}.raw:user:profile_background_image_url_https ;;
  }
  dimension: profile_background_tile {
    type: string
    sql: ${TABLE}.raw:user:profile_background_tile ;;
  }
  dimension: profile_banner_url {
    type: string
    sql: ${TABLE}.raw:user:profile_banner_url ;;
  }
  dimension: profile_image_url {
    type: string
    sql: ${TABLE}.raw:user:profile_image_url ;;
  }
  dimension: profile_image_url_https {
    type: string
    sql: ${TABLE}.raw:user:profile_image_url_https ;;
  }
  dimension: profile_link_color {
    type: string
    sql: ${TABLE}.raw:user:profile_link_color ;;
  }
  dimension: profile_sidebar_border_color {
    type: string
    sql: ${TABLE}.raw:user:profile_sidebar_border_color ;;
  }
  dimension: profile_sidebar_fill_color {
    type: string
    sql: ${TABLE}.raw:user:profile_sidebar_fill_color ;;
  }
  dimension: profile_text_color {
    type: string
    sql: ${TABLE}.raw:user:profile_text_color ;;
  }
  dimension: profile_use_background_image {
    type: string
    sql: ${TABLE}.raw:user:profile_use_background_image ;;
  }
  dimension: protected {
    type: string
    sql: ${TABLE}.raw:user:protected ;;
  }
  dimension: retweet_count {
    type: string
    sql: ${TABLE}.raw:retweet_count ;;
  }
  dimension: retweeted {
    type: string
    sql: ${TABLE}.raw:retweeted ;;
  }
  dimension: screen_name {
    type: string
    sql: ${TABLE}.raw:user:screen_name ;;
  }
  dimension: source {
    type: string
    sql: ${TABLE}.raw:source ;;
  }
  dimension: statuses_count {
    type: string
    sql: ${TABLE}.raw:user:statuses_count ;;
  }
  dimension: symbols {
    type: string
    sql: ${TABLE}.raw:entities:symbols ;;
  }
  dimension: text {
    type: string
    sql: ${TABLE}.raw:text ;;
  }
  dimension: time_zone {
    type: string
    sql: ${TABLE}.raw:user:time_zone ;;
  }
  dimension: timestamp_ms {
    type: string
    sql: ${TABLE}.raw:timestamp_ms ;;
  }
  dimension_group: created {
    datatype: timestamp
    type: time
    sql: TO_TIMESTAMP(cAST(${TABLE}.raw:timestamp_ms AS integer),3) ;;
  }
  dimension: truncated {
    type: string
    sql: ${TABLE}.raw:truncated ;;
  }
  dimension: url {
    type: string
    sql: ${TABLE}.raw:user:url ;;
  }
  dimension: urls {
    type: string
    sql: ${TABLE}.raw:entities:urls ;;
  }
  dimension: user {
    type: string
    sql: ${TABLE}.raw:user ;;
  }
  dimension: user_mentions {
    type: string
    sql: ${TABLE}.raw:entities:user_mentions ;;
  }
  dimension: utc_offset {
    type: string
    sql: ${TABLE}.raw:user:utc_offset ;;
  }
  dimension: verified {
    type: string
    sql: ${TABLE}.raw:user:verified ;;
  }
}
