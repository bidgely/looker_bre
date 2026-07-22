view: date_series {
  derived_table: {
    sql_trigger_value: select current_date ;;
    sql: WITH numbers AS (
                    SELECT ROW_NUMBER() OVER () - 1 AS n
                    FROM user_meta_data
                    LIMIT 5000
                  ),
                  spine AS (
                    SELECT date_add('day', -n, current_date) AS date_series
                    FROM numbers
                  )
         SELECT date_series
         FROM spine
         WHERE date_series >= DATE '2023-06-01'
         ORDER BY date_series ;;
  }

  dimension_group: continous {
    type: time
    sql: ${TABLE}.date_series ;;
  }

  parameter: timestamp_parameter {
    label: "Date Granularity"
    type: string

    allowed_value: {
      value: "date"
    }
    allowed_value: {
      value: "week"
    }
    allowed_value: {
      value: "month"
    }
    default_value: "week"
  }

  dimension: dynamic_date {
    type: string
    sql: case when {% parameter timestamp_parameter %} = 'date' then date_format(${continous_date}, '%Y-%m-%d')
               when {% parameter timestamp_parameter %} = 'week' then ${continous_week}
               when {% parameter timestamp_parameter %} = 'month' then ${continous_month}
               END ;;
  }

}
