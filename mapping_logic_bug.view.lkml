explore: test_mapping {}
view: test_mapping {
  sql_table_name: `sound-octagon-112005.clinical_trials.clinical_investigators` ;;

  filter: letter {
    suggestions: ["A","B","C","D"]
  }
  dimension: letter_tf {
    type: string
    sql: {% condition letter %}''{% endcondition %};;
  }
  dimension: letter_tf_sql {
    sql: {{ letter_tf._sql }} ;;
  }
  dimension: map_logic_split {
    type: string
    sql: {% assign tf = letter_tf._sql %}
        {% if (tf contains "A" and tf contains "B")
          or (tf contains "A" and tf contains "C")
          or (tf contains "A" and tf contains "D") %}
          'Contains Two'
          {% elsif (tf contains "B" and tf contains "C")
          or (tf contains "B" and tf contains "D") %}
          'Contains Two'
          {% elsif (tf contains "C" and tf contains "D") %}
          'Contains Two'
    {% else %}
    'Contains One'
    {% endif %};;
    }
  dimension: map_logic_full {
    type: string
  sql: {% assign tf = letter_tf._sql %}
        {% if (tf contains "A" and tf contains "B")
          or (tf contains "A" and tf contains "C")
          or (tf contains "A" and tf contains "D")
          or (tf contains "B" and tf contains "C")
          or (tf contains "B" and tf contains "D")
          or (tf contains "C" and tf contains "D") %}
          'Contains Two'
    {% else %}
    'Contains One'
    {% endif %};;
}
}
