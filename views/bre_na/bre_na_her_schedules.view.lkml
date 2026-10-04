include: "/views/bre_na/bre_na_her_fields.view.lkml"

# SRC-22; preserve source joins, windows, and source period grains.
view: bre_na_her_schedules {
  extends: [bre_na_her_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
        select
        m.pilot_name, m.pilot_id, CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,s.cluster_id,s.fuel_type,s.schedule_start,s.schedule_end,
        s.total_eligible_users,s.total_generated_notification_id,s.total_scheduled_notification_id,s.total_queued_notification_id,s.total_printed_notification_id,
        s.total_mailed_notification_id,s.total_failed_notification_id,s.total_swept_notification_id,s.total_revoked_notification_id,
        s.reporting_date,s.analysis_date,s.last_updated_timestamp
        from
        (
            with generated_her as
            (
                select s.pilot_id,s.cluster_id,s.measurement_type as fuel_type,s.schedule_start,s.schedule_end,
                s.total_eligible_users,s.total_generated_notification_id,s.total_scheduled_notification_id,s.total_queued_notification_id,s.total_printed_notification_id,
                s.total_mailed_notification_id,s.total_failed_notification_id,s.reporting_date,
                s.last_updated_timestamp ,s.analysis_date,s.total_swept_notification_id
                FROM
                (
                    select pilot_id,schedule_start,schedule_end,measurement_type,cluster_id,
                    sum(total_eligible_users) as total_eligible_users,
                    sum(total_generated_notification_id) as total_generated_notification_id,
                    sum(total_scheduled_notification_id) as total_scheduled_notification_id,
                    sum(total_swept_notification_id) as total_swept_notification_id,
                    sum(total_queued_notification_id) as total_queued_notification_id,
                    sum(total_printed_notification_id) as total_printed_notification_id,
                    sum(total_mailed_notification_id) as total_mailed_notification_id,
                    sum(total_failed_notification_id) as total_failed_notification_id,
                    max(analysis_date) as analysis_date,
                    max(reporting_date) as reporting_date,
                    max(last_updated_timestamp) as last_updated_timestamp
                    from
                    (
                        Select pilot_id,cluster_id,measurement_type,
                        case when schedule_quarter_start < schedule_start then schedule_start else schedule_quarter_start end schedule_start ,
                        CAST(date_add('day', -1, date_add('quarter', 1, schedule_quarter_start)) AS DATE) as schedule_end,
                        total_eligible_users,total_generated_notification_id,total_scheduled_notification_id,total_swept_notification_id,total_queued_notification_id,total_printed_notification_id,total_mailed_notification_id,total_failed_notification_id,
                        reporting_date,analysis_date,last_updated_timestamp
                        from
                        (
                            Select *,CAST(date_trunc('quarter', analysis_date) AS DATE) as schedule_quarter_start,
                            row_number()over(partition by pilot_id,cluster_id,measurement_type,schedule_start,schedule_end,date_trunc('quarter',analysis_date) order by reporting_date desc) as rk
                            from delta_prodna.reporting.sre_daily_her_tracker
                            where pilot_id='10037'
                        )x where rk=1
                        union
                        Select pilot_id,cluster_id,measurement_type,schedule_start,schedule_end,
                        total_eligible_users,total_generated_notification_id,total_scheduled_notification_id,total_swept_notification_id,total_queued_notification_id,total_printed_notification_id,total_mailed_notification_id,total_failed_notification_id,
                        reporting_date,analysis_date,last_updated_timestamp
                        from
                        (
                            Select *,
                            row_number()over(partition by pilot_id,cluster_id,measurement_type,schedule_start,schedule_end order by reporting_date desc) as rk
                            from delta_prodna.reporting.sre_daily_her_tracker
                            where pilot_id<>'10037'
                        )x where rk=1
                    )
                    group by pilot_id,schedule_start,schedule_end,measurement_type,cluster_id
                )s
        ),
        revoked_her as
        (
            select pilot_id,cluster_id,fuel_type,
            case when schedule_quarter_start < schedule_start then schedule_start else schedule_quarter_start end schedule_start,
            CAST(date_add('day', -1, date_add('quarter', 1, schedule_quarter_start)) AS DATE) as schedule_end,total_revoked_users,last_updated_timestamp,reporting_date,analysis_date
            from
            (
                select *,CAST(date_trunc('quarter', analysis_date) AS DATE) as schedule_quarter_start,
                row_number()over(partition by pilot_id,cluster_id,fuel_type,schedule_start,schedule_end,date_trunc('quarter',analysis_date) order by reporting_date desc) as rk

                from delta_prodna.reporting.sre_her_revoked_users
                where pilot_id=10037
            )x where x.rk=1
            union
            select pilot_id,cluster_id,fuel_type,
            schedule_start,schedule_end,total_revoked_users,last_updated_timestamp,reporting_date,analysis_date
            from
            (
                select *,row_number()over(partition by pilot_id,cluster_id,schedule_start,schedule_end,fuel_type order by reporting_date desc) as rn
                from delta_prodna.reporting.sre_her_revoked_users
                where pilot_id<>10037
            )x where x.rn=1
        )
        select
        COALESCE(a.pilot_id, CAST(b.pilot_id AS VARCHAR)) pilot_id,
        coalesce(a.cluster_id,b.cluster_id) cluster_id,
        coalesce(a.fuel_type,b.fuel_type) fuel_type,
        coalesce(a.schedule_start,b.schedule_start) schedule_start,
        coalesce(a.schedule_end,b.schedule_end) schedule_end,
        COALESCE(a.total_eligible_users,0) total_eligible_users,
        COALESCE(a.total_generated_notification_id,0) total_generated_notification_id,
        COALESCE(a.total_scheduled_notification_id,0) total_scheduled_notification_id,
        COALESCE(a.total_queued_notification_id,0) total_queued_notification_id,
        COALESCE(a.total_printed_notification_id,0) total_printed_notification_id,
        COALESCE(a.total_mailed_notification_id,0) total_mailed_notification_id,
        COALESCE(a.total_failed_notification_id,0) total_failed_notification_id,
        COALESCE(a.total_swept_notification_id,0) total_swept_notification_id,
        COALESCE(b.total_revoked_users,0) as total_revoked_notification_id,
        coalesce(a.analysis_date,b.analysis_date) analysis_date,
        coalesce(a.reporting_date,b.reporting_date) reporting_date,
        coalesce(a.last_updated_timestamp,b.last_updated_timestamp) last_updated_timestamp
        from generated_her a
        full join revoked_her b on a.pilot_id=CAST(b.pilot_id AS VARCHAR)
        and a.cluster_id=b.cluster_id
        and a.fuel_type=b.fuel_type
        and a.schedule_start=b.schedule_start
        and a.schedule_end=b.schedule_end
        )s
        JOIN
        (
            SELECT
                CASE
                    WHEN POSITION('(' IN pilot_name) > 0
                    THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                    ELSE pilot_name
                END AS pilot_name,
                pilot_id
            FROM delta_prodna.reporting.pilot_consolidated_product_type_events
        ) m ON CAST(m.pilot_id AS VARCHAR) = s.pilot_id
      ) q
      WHERE {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% condition fuel_type %} q.fuel_type {% endcondition %}
        AND {% condition cluster_id %} q.cluster_id {% endcondition %}
        AND {% condition date_range %} q.analysis_date {% endcondition %}
    ;;
  }
  dimension: fuel_type {
    type: string
    description: "Source fuel_type; Cluster IDs control selects cluster_id values."
    sql: ${TABLE}.fuel_type ;;
  }
  dimension: cluster_id {
    type: string
    description: "Source cluster_id; Cluster IDs control selects cluster_id values."
    sql: ${TABLE}.cluster_id ;;
  }
  dimension: schedule_start {
    type: date
    convert_tz: no
    description: "Source schedule_start, including the supplied PSEG quarterly schedule adjustment."
    sql: ${TABLE}.schedule_start ;;
  }
  dimension: schedule_end {
    type: date
    convert_tz: no
    description: "Source schedule_end, including the supplied PSEG quarterly schedule adjustment."
    sql: ${TABLE}.schedule_end ;;
  }
  dimension: total_eligible_users {
    type: number
    hidden: yes
    description: "Source total_eligible_users; source grain and NULL handling retained."
    sql: ${TABLE}.total_eligible_users ;;
  }
  measure: total_eligible_users_sum {
    type: sum
    description: "Sum of source total_eligible_users."
    value_format: "#,##0"
    sql: ${total_eligible_users} ;;
  }
  dimension: total_generated_notification_id {
    type: number
    hidden: yes
    description: "Source total_generated_notification_id; source grain and NULL handling retained."
    sql: ${TABLE}.total_generated_notification_id ;;
  }
  measure: total_generated_notification_id_sum {
    type: sum
    description: "Sum of source total_generated_notification_id."
    value_format: "#,##0"
    sql: ${total_generated_notification_id} ;;
  }
  dimension: total_failed_notification_id {
    type: number
    hidden: yes
    description: "Source total_failed_notification_id; source grain and NULL handling retained."
    sql: ${TABLE}.total_failed_notification_id ;;
  }
  measure: total_failed_notification_id_sum {
    type: sum
    description: "Sum of source total_failed_notification_id."
    value_format: "#,##0"
    sql: ${total_failed_notification_id} ;;
  }
  dimension: total_scheduled_notification_id {
    type: number
    hidden: yes
    description: "Source total_scheduled_notification_id; source grain and NULL handling retained."
    sql: ${TABLE}.total_scheduled_notification_id ;;
  }
  measure: total_scheduled_notification_id_sum {
    type: sum
    description: "Sum of source total_scheduled_notification_id."
    value_format: "#,##0"
    sql: ${total_scheduled_notification_id} ;;
  }
  dimension: total_swept_notification_id {
    type: number
    hidden: yes
    description: "Source total_swept_notification_id; source grain and NULL handling retained."
    sql: ${TABLE}.total_swept_notification_id ;;
  }
  measure: total_swept_notification_id_sum {
    type: sum
    description: "Sum of source total_swept_notification_id."
    value_format: "#,##0"
    sql: ${total_swept_notification_id} ;;
  }
  dimension: total_queued_notification_id {
    type: number
    hidden: yes
    description: "Source total_queued_notification_id; source grain and NULL handling retained."
    sql: ${TABLE}.total_queued_notification_id ;;
  }
  measure: total_queued_notification_id_sum {
    type: sum
    description: "Sum of source total_queued_notification_id."
    value_format: "#,##0"
    sql: ${total_queued_notification_id} ;;
  }
  dimension: total_printed_notification_id {
    type: number
    hidden: yes
    description: "Source total_printed_notification_id; source grain and NULL handling retained."
    sql: ${TABLE}.total_printed_notification_id ;;
  }
  measure: total_printed_notification_id_sum {
    type: sum
    description: "Sum of source total_printed_notification_id."
    value_format: "#,##0"
    sql: ${total_printed_notification_id} ;;
  }
  dimension: total_mailed_notification_id {
    type: number
    hidden: yes
    description: "Source total_mailed_notification_id; source grain and NULL handling retained."
    sql: ${TABLE}.total_mailed_notification_id ;;
  }
  measure: total_mailed_notification_id_sum {
    type: sum
    description: "Sum of source total_mailed_notification_id."
    value_format: "#,##0"
    sql: ${total_mailed_notification_id} ;;
  }
  dimension: total_revoked_notification_id {
    type: number
    hidden: yes
    description: "Source total_revoked_notification_id; source grain and NULL handling retained."
    sql: ${TABLE}.total_revoked_notification_id ;;
  }
  measure: total_revoked_notification_id_sum {
    type: sum
    description: "Sum of source total_revoked_notification_id."
    value_format: "#,##0"
    sql: ${total_revoked_notification_id} ;;
  }
}
