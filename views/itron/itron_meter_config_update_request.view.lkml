view: itron_meter_config_update_request {
  derived_table: {
    sql:
      WITH filtered_requests AS (
        SELECT *
        FROM public.meter_config_update_request
        WHERE {%condition itron_enrollment_files.pilot_id%} pilot_id {%endcondition%}
      ),
      last_event AS (
        SELECT
          request_id,
          status,
          ROW_NUMBER() OVER (PARTITION BY request_id ORDER BY last_updated_timestamp DESC) AS rn
        FROM filtered_requests
      )
      SELECT
        m.request_id,
        MAX(m.uuid) AS uuid,
        MAX(m.esn_list) AS meter_esn,
        MAX(m.pilot_id) AS pilot_id,
        MAX(m.partner_id) AS partner_id,
        MAX(m.feature) AS feature,
        MAX(m.hardware_version) AS hardware_version,
        MAX(m.country_code) AS country_code,
        MAX(m.retry_count) AS retry_count,
        MAX(le.status) AS final_status,
        MAX(CASE WHEN m.status = 'CONFIG_GENERATED' THEN 1 ELSE 0 END) AS has_config_generated,
        COALESCE(
          MIN(CASE WHEN m.status = 'CONFIG_GENERATED' THEN m.last_updated_timestamp END),
          MIN(m.last_updated_timestamp)
        ) AS issued_at_ms,
        MAX(CASE WHEN m.status IN ('INITIALIZING','PREPARING','REQUEST_SENT','COMPLETED','FAILED')
                 THEN 1 ELSE 0 END) AS is_confirmed_sent,
        MIN(CASE WHEN m.status IN ('INITIALIZING','PREPARING','REQUEST_SENT','COMPLETED','FAILED')
                 THEN m.last_updated_timestamp END) AS confirmed_at_ms,
        MAX(CASE WHEN m.status = 'FAILED' THEN 1 ELSE 0 END) AS is_failed,
        MAX(CASE
              WHEN m.status = 'FAILED' AND m.remarks LIKE 'Patch request time out%' THEN 'api_timeout'
              WHEN m.status = 'FAILED' AND m.remarks LIKE 'Config confirmation message not received%' THEN 'no_confirmation_received'
              WHEN m.status = 'FAILED' THEN 'other'
            END) AS failure_reason,
        MAX(CASE WHEN m.status = 'COMPLETED' THEN 1 ELSE 0 END) AS is_completed,
        MIN(CASE WHEN m.status = 'COMPLETED' THEN m.last_updated_timestamp END) AS completed_at_ms
      FROM filtered_requests m
      JOIN last_event le ON le.request_id = m.request_id AND le.rn = 1
      GROUP BY m.request_id
     ;;
  }

  dimension: request_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.request_id ;;
  }

  dimension: uuid {
    type: string
    sql: ${TABLE}.uuid ;;
  }

  dimension: meter_esn {
    label: "Meter ESN"
    type: string
    sql: ${TABLE}.meter_esn ;;
  }

  dimension: pilot_id {
    type: number
    sql: ${TABLE}.pilot_id ;;
  }

  dimension: partner_id {
    type: string
    sql: ${TABLE}.partner_id ;;
  }

  dimension: feature {
    type: string
    sql: ${TABLE}.feature ;;
  }

  dimension: hardware_version {
    type: string
    sql: ${TABLE}.hardware_version ;;
  }

  dimension: country_code {
    type: string
    sql: ${TABLE}.country_code ;;
  }

  dimension: retry_count {
    label: "Retry Count"
    description: "Attempt number for this meter's configuration process; constant per request_id. A handful of meters climb into the high teens/thirties — a persistent fail/retry loop worth monitoring."
    type: number
    sql: ${TABLE}.retry_count ;;
  }

  dimension: is_retry {
    label: "Is Retry"
    description: "True if this request is itself a retry attempt (retry_count > 0)"
    type: yesno
    sql: ${TABLE}.retry_count > 0 ;;
  }

  dimension: final_status {
    label: "Final Status"
    description: "The last status this request reached, by most recent event timestamp — e.g. COMPLETED, FAILED, REQUEST_SENT, CONFIG_GENERATED, PENDING"
    type: string
    sql: ${TABLE}.final_status ;;
  }

  dimension: has_config_generated {
    label: "Has Config Generated Step"
    description: "True if this request ever reached CONFIG_GENERATED status; false if it skipped straight to a later status"
    type: yesno
    sql: ${TABLE}.has_config_generated = 1 ;;
  }

  dimension: is_confirmed_sent {
    label: "Is Confirmed Sent"
    description: "True if this request ever reached a status confirming the configuration was sent to the meter (INITIALIZING/PREPARING/REQUEST_SENT/COMPLETED/FAILED)"
    type: yesno
    sql: ${TABLE}.is_confirmed_sent = 1 ;;
  }

  dimension: is_failed {
    label: "Is Failed"
    description: "True if this request's status ever reached FAILED"
    type: yesno
    sql: ${TABLE}.is_failed = 1 ;;
  }

  dimension: failure_reason {
    label: "Failure Reason"
    description: "Only populated when the request ultimately failed. api_timeout = 'Patch request time out'; no_confirmation_received = 'Config confirmation message not received after 10 days.'; other = rare edge cases."
    type: string
    sql: ${TABLE}.failure_reason ;;
  }

  dimension: is_completed {
    label: "Is Successfully Completed"
    description: "True if this request's status ever reached COMPLETED"
    type: yesno
    sql: ${TABLE}.is_completed = 1 ;;
  }

  dimension_group: issued {
    label: "Issued"
    description: "First CONFIG_GENERATED event for this request, or its first event overall if CONFIG_GENERATED never occurred"
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: from_unixtime(${TABLE}.issued_at_ms / 1000) ;;
  }

  dimension_group: confirmed {
    label: "Confirmed Sent"
    description: "First event confirming the configuration was sent to the meter (null if never confirmed)"
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: from_unixtime(${TABLE}.confirmed_at_ms / 1000) ;;
  }

  dimension_group: completed {
    label: "Completed"
    description: "First event where the request reached COMPLETED (null if never completed)"
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: from_unixtime(${TABLE}.completed_at_ms / 1000) ;;
  }

  dimension: confirmation_duration_hours {
    label: "Confirmation Duration (Hours)"
    description: "Hours between issued and confirmed-sent; null if never confirmed"
    type: number
    sql: CASE WHEN ${TABLE}.confirmed_at_ms IS NOT NULL
           THEN (${TABLE}.confirmed_at_ms - ${TABLE}.issued_at_ms) / 1000.0 / 3600.0
         END ;;
  }

  dimension: successful_configuration_duration_hours {
    label: "Successful Configuration Duration (Hours)"
    description: "Hours between issued and COMPLETED; null unless the request actually completed successfully"
    type: number
    sql: CASE WHEN ${TABLE}.completed_at_ms IS NOT NULL
           THEN (${TABLE}.completed_at_ms - ${TABLE}.issued_at_ms) / 1000.0 / 3600.0
         END ;;
  }

  measure: count_configuration_requests_issued {
    label: "Configuration Requests Issued"
    description: "Every request_id counts once, regardless of status"
    type: count
  }

  measure: count_configuration_confirmations_received {
    label: "Configuration Confirmations Received"
    description: "Requests that reached a status confirming the config was sent to the meter"
    type: count
    filters: [is_confirmed_sent: "yes"]
  }

  measure: count_distinct_meters {
    label: "Distinct Meters"
    type: count_distinct
    sql: ${meter_esn} ;;
  }

  measure: max_retry_count {
    label: "Max Retry Count"
    description: "Highest attempt number seen in the current filter context — use to surface meters stuck in a fail/retry loop"
    type: max
    sql: ${retry_count} ;;
  }

  measure: average_confirmation_time_hours {
    label: "Average Confirmation Time (Hours)"
    description: "Average hours from issued to confirmed, across confirmed requests only"
    type: average
    sql: ${confirmation_duration_hours} ;;
    value_format_name: decimal_1
  }

  measure: confirmation_rate {
    label: "Confirmation Rate"
    description: "Share of issued requests that were eventually confirmed sent"
    type: number
    sql: 1.0 * ${count_configuration_confirmations_received} / NULLIF(${count_configuration_requests_issued}, 0) ;;
    value_format_name: percent_1
  }

  measure: count_retries {
    label: "Retries"
    description: "Requests that are themselves a retry attempt (retry_count > 0)"
    type: count
    filters: [is_retry: "yes"]
  }

  measure: retry_rate {
    label: "Retry Rate"
    description: "Share of issued requests that are retry attempts"
    type: number
    sql: 1.0 * ${count_retries} / NULLIF(${count_configuration_requests_issued}, 0) ;;
    value_format_name: percent_1
  }

  measure: count_failures {
    label: "Failures"
    description: "Requests whose status ever reached FAILED"
    type: count
    filters: [is_failed: "yes"]
  }

  measure: failure_rate {
    label: "Failure Rate"
    description: "Share of issued requests that ultimately failed"
    type: number
    sql: 1.0 * ${count_failures} / NULLIF(${count_configuration_requests_issued}, 0) ;;
    value_format_name: percent_1
  }

  measure: count_successful_configurations {
    label: "Successful Configurations"
    description: "Requests whose status ever reached COMPLETED"
    type: count
    filters: [is_completed: "yes"]
  }

  measure: success_rate {
    label: "Success Rate"
    description: "Share of issued requests that completed successfully"
    type: number
    sql: 1.0 * ${count_successful_configurations} / NULLIF(${count_configuration_requests_issued}, 0) ;;
    value_format_name: percent_1
  }

  measure: average_successful_configuration_time_hours {
    label: "Average Successful Configuration Time (Hours)"
    description: "Average hours from issued to COMPLETED, across successfully completed requests only"
    type: average
    sql: ${successful_configuration_duration_hours} ;;
    value_format_name: decimal_1
  }
}
