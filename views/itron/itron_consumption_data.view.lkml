view: itron_consumption_data{
  derived_table: {
    sql: SELECT
              uuid,
              data_date,
              COUNT(uuid) AS total_15_min_entries,
              CASE
                  WHEN COUNT(uuid) < 96 THEN 'incomplete_data'
                  WHEN COUNT(uuid) = 96 THEN 'complete_data'
                  WHEN COUNT(uuid) > 96 THEN 'more_than_96_entries'
              END AS data_category_15_min
      FROM (  SELECT *
              FROM public.raw_consumption_data
              WHERE pilot_id in (
                10112, 10014, 10117, 10118, 10126, 10223,
                {% if _model._name == 'bre_itron_uat' %} 10015 {% else %} 10224 {% endif %}
              )
              AND {%condition itron_enrollment_files.pilot_id%} pilot_id {%endcondition%}
              AND {%condition date_series.continous_date%} data_date {%endcondition%}
               -- AND uuid = 'b3a92fbc-6693-45ce-9995-9fce40759e8a' AND data_month = '2025-06-01'
            ) raw_data
      GROUP BY uuid, data_date
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: consumption_key {
    primary_key: yes
    hidden: yes
    description: "Unique consumption summary for a user and data date."
    type: string
    sql: ${uuid} || '|' || CAST(${data_date} AS varchar) ;;
  }

  dimension: uuid {
    type: string
    sql: ${TABLE}.uuid ;;
  }

  dimension: data_date {
    type: date
    sql: ${TABLE}.data_date ;;
  }

  dimension: total_15_min_entries {
    type: number
    sql: ${TABLE}.total_15_min_entries ;;
  }

  dimension: data_category_15_min {
    type: string
    sql: ${TABLE}.data_category_15_min ;;
  }

  set: detail {
    fields: [
      uuid,
      data_date,
      total_15_min_entries,
      data_category_15_min
    ]
  }

}
