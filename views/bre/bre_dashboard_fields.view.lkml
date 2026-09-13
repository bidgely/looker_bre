# Shared field contract. Regional views provide the SQL and allowed families.
# Measures aggregate exactly one selected family; no fact-to-fact joins are used.
view: bre_dashboard_fields {
  extension: required
  dimension: row_id {
    primary_key: yes
    hidden: yes
    type: number
    description: "Query-local row identifier for the selected family; not a cross-query business key."
    sql: ${TABLE}.row_id ;;
  }
  parameter: source_family {
    type: string
    label: "Source Family"
    group_label: "Controls"
    description: "Choose one source family per query. Tiles must explicitly save this selection."
  }
  parameter: period {
    type: string
    label: "Period"
    group_label: "Controls"
    description: "Daily, Weekly or Monthly. HER period sources use their original aggregation; other sources use this to group Period Date."
    default_value: "Daily"
    allowed_value: { label: "Daily" value: "Daily" }
    allowed_value: { label: "Weekly" value: "Weekly" }
    allowed_value: { label: "Monthly" value: "Monthly" }
  }
  parameter: failure_scope {
    type: string
    label: "Processing Failure Scope"
    group_label: "Controls"
    description: "Processing Failures only: All preserves the unfiltered ranked source; Top Three retains source rank <= 3 before other filters."
    allowed_value: { label: "All" value: "All" }
    allowed_value: { label: "Top Three" value: "Top Three" }
  }
  dimension: pilot_id {
    type: string
    label: "Pilot Id"
    group_label: "Common"
    description: "Pilot Id for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.pilot_id ;;
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_id
  }
  dimension: pilot_name {
    type: string
    label: "Pilot Name"
    group_label: "Common"
    description: "Pilot Name for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.pilot_name ;;
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_name
  }
  dimension: pilot_id_name {
    type: string
    label: "Pilot Id Name"
    group_label: "Common"
    description: "Pilot ID and cleaned pilot name, preserving source inner/left join behavior."
    sql: ${TABLE}.pilot_id_name ;;
  }
  dimension: time_zone {
    type: string
    label: "Time Zone"
    group_label: "Common"
    description: "Pilot time zone metadata; date-only reporting fields are not converted between time zones."
    sql: ${TABLE}.time_zone ;;
  }
  dimension: analysis_date {
    type: date
    label: "Analysis Date"
    group_label: "Common"
    description: "Analysis date normalized to DATE. Filtering does not change the original latest-row or ranking partitions."
    convert_tz: no
    sql: ${TABLE}.analysis_date ;;
  }
  dimension: reporting_date {
    type: date
    label: "Reporting Date"
    group_label: "Common"
    description: "Reporting date normalized to DATE; distinct from analysis date."
    convert_tz: no
    sql: ${TABLE}.reporting_date ;;
  }
  dimension: last_updated_timestamp {
    type: date_time
    label: "Last Updated Timestamp"
    group_label: "Common"
    description: "Source last-update timestamp. Email tracker maps the original last_updated_timestap spelling."
    convert_tz: no
    sql: ${TABLE}.last_updated_timestamp ;;
  }
  dimension: source_analysis_value {
    type: string
    label: "Source Analysis Value"
    group_label: "Common"
    description: "Original source analysis date/timestamp represented as text, before DATE normalization."
    sql: ${TABLE}.source_analysis_value ;;
  }
  dimension: source_reporting_value {
    type: string
    label: "Source Reporting Value"
    group_label: "Common"
    description: "Original source reporting date/timestamp represented as text, before DATE normalization."
    sql: ${TABLE}.source_reporting_value ;;
  }
  dimension: source_pilot_name {
    type: string
    label: "Source Pilot Name"
    group_label: "Common"
    description: "Original pilot_name from the fact source, when present; separate from the cleaned pilot dimension name."
    sql: ${TABLE}.source_pilot_name ;;
  }
  dimension: source_period {
    type: string
    label: "Source Period"
    group_label: "Common"
    hidden: yes
    description: "Original HER preaggregation period. Other source families return NULL."
    sql: ${TABLE}.source_period ;;
  }
  dimension: source_rank {
    type: number
    label: "Source Rank"
    group_label: "Common"
    description: "Original ROW_NUMBER result. Failure ranking uses the source partitions and descending NULLS FIRST ordering."
    sql: ${TABLE}.source_rank ;;
  }
  dimension: ingestion_type {
    type: string
    label: "Ingestion Type"
    group_label: "Common"
    description: "Ingestion Type for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.ingestion_type ;;
  }
  dimension: meter_type {
    type: string
    label: "Meter Type"
    group_label: "Common"
    description: "Meter Type for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.meter_type ;;
  }
  dimension: fuel_type {
    type: string
    label: "Fuel Type"
    group_label: "Common"
    description: "Fuel Type for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.fuel_type ;;
  }
  dimension: module_name {
    type: string
    label: "Module Name"
    group_label: "Common"
    description: "Module Name for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.module_name ;;
  }
  dimension: email_type {
    type: string
    label: "Email Type"
    group_label: "Common"
    description: "Email Type for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.email_type ;;
  }
  dimension: bc_end_week_number {
    type: string
    label: "BC End Week Number"
    group_label: "Common"
    description: "BC End Week Number for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.bc_end_week_number ;;
  }
  dimension: cluster_id {
    type: string
    label: "Cluster Id"
    group_label: "Common"
    description: "Cluster Id for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.cluster_id ;;
  }
  dimension: schedule_start {
    type: date
    label: "Schedule Start"
    group_label: "Common"
    description: "Schedule Start for the selected family; NULL when not supplied by that source."
    convert_tz: no
    sql: ${TABLE}.schedule_start ;;
  }
  dimension: schedule_end {
    type: date
    label: "Schedule End"
    group_label: "Common"
    description: "Schedule End for the selected family; NULL when not supplied by that source."
    convert_tz: no
    sql: ${TABLE}.schedule_end ;;
  }
  dimension: appliance_name {
    type: string
    label: "Appliance Name"
    group_label: "Common"
    description: "Appliance Name for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.appliance_name ;;
  }
  dimension: metric_name {
    type: string
    label: "Metric Name"
    group_label: "Common"
    description: "Metric Name for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.metric_name ;;
  }
  dimension: application_error_code {
    type: string
    label: "Application Error Code"
    group_label: "Common"
    description: "Application Error Code for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.application_error_code ;;
  }
  dimension: failure_reason {
    type: string
    label: "Failure Reason"
    group_label: "Common"
    description: "Failure Reason for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.failure_reason ;;
  }
  dimension: reporting_frequency {
    type: string
    label: "Reporting Frequency"
    group_label: "Common"
    description: "Reporting Frequency for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.reporting_frequency ;;
  }
  dimension: trigger_flag {
    type: string
    label: "Trigger Flag"
    group_label: "Common"
    description: "Trigger Flag for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.trigger_flag ;;
  }
  dimension: delivery_mode {
    type: string
    label: "Delivery Mode"
    group_label: "Common"
    description: "Delivery Mode for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.delivery_mode ;;
  }
  dimension: event_type {
    type: string
    label: "Event Type"
    group_label: "Common"
    description: "Event Type for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.event_type ;;
  }
  dimension: delay_in_days {
    type: number
    label: "Delay In Days"
    group_label: "Common"
    description: "Delay In Days for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.delay_in_days ;;
  }
  dimension: istou {
    type: yesno
    label: "Istou"
    group_label: "Common"
    description: "Istou for the selected family; NULL when not supplied by that source."
    sql: ${TABLE}.istou ;;
  }
  # Typed references prevent Looker from passing formatted VARCHAR dates into Trino date functions.
  dimension: period_date {
    type: date
    label: "Period Date"
    group_label: "Common"
    description: "Analysis date grouped to the selected period. Week starts on Monday."
    convert_tz: no
    sql:
      {% if period._parameter_value == "'Weekly'" %} CAST(date_trunc('week', ${analysis_date::date}) AS DATE)
      {% elsif period._parameter_value == "'Monthly'" %} CAST(date_trunc('month', ${analysis_date::date}) AS DATE)
      {% else %} ${analysis_date::date}
      {% endif %} ;;
  }
  measure: source_row_count {
    type: number
    label: "Source Row Count"
    group_label: "Common"
    description: "Rows from the selected source after filters. This is not a distinct-user count."
    sql: COUNT(${row_id}) ;;
    value_format: "#,##0"
  }
  dimension: active_users_total_uuid {
    type: number
    label: "Total UUID"
    group_label: "Active Users"
    description: "Active Users: source field total_uuid. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql: ${TABLE}.active_users_total_uuid ;;
  }
  measure: active_users_total_uuid_sum {
    type: number
    label: "Total UUID (Sum)"
    group_label: "Active Users"
    description: "Sum of total_uuid over selected source rows. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'activeusers'" %}
        SUM(${active_users_total_uuid})
      {% else %} CAST(NULL AS INTEGER)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: active_users_enabled_uuid {
    type: number
    label: "Enabled UUID"
    group_label: "Active Users"
    description: "Active Users: source field enabled_uuid. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql: ${TABLE}.active_users_enabled_uuid ;;
  }
  measure: active_users_enabled_uuid_sum {
    type: number
    label: "Enabled UUID (Sum)"
    group_label: "Active Users"
    description: "Sum of enabled_uuid over selected source rows. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'activeusers'" %}
        SUM(${active_users_enabled_uuid})
      {% else %} CAST(NULL AS INTEGER)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: active_users_disabled_uuid {
    type: number
    label: "Disabled UUID"
    group_label: "Active Users"
    description: "Active Users: source field disabled_uuid. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql: ${TABLE}.active_users_disabled_uuid ;;
  }
  measure: active_users_disabled_uuid_sum {
    type: number
    label: "Disabled UUID (Sum)"
    group_label: "Active Users"
    description: "Sum of disabled_uuid over selected source rows. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'activeusers'" %}
        SUM(${active_users_disabled_uuid})
      {% else %} CAST(NULL AS INTEGER)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: active_users_active_uuid {
    type: number
    label: "Active UUID"
    group_label: "Active Users"
    description: "Active Users: source field active_uuid. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql: ${TABLE}.active_users_active_uuid ;;
  }
  measure: active_users_active_uuid_sum {
    type: number
    label: "Active UUID (Sum)"
    group_label: "Active Users"
    description: "Sum of active_uuid over selected source rows. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'activeusers'" %}
        SUM(${active_users_active_uuid})
      {% else %} CAST(NULL AS INTEGER)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: active_users_total_active_electric_uuid {
    type: number
    label: "Total Active Electric UUID"
    group_label: "Active Users"
    description: "Active Users: source field total_active_electric_uuid. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql: ${TABLE}.active_users_total_active_electric_uuid ;;
  }
  measure: active_users_total_active_electric_uuid_sum {
    type: number
    label: "Total Active Electric UUID (Sum)"
    group_label: "Active Users"
    description: "Sum of total_active_electric_uuid over selected source rows. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'activeusers'" %}
        SUM(${active_users_total_active_electric_uuid})
      {% else %} CAST(NULL AS INTEGER)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: active_users_total_active_gas_uuid {
    type: number
    label: "Total Active Gas UUID"
    group_label: "Active Users"
    description: "Active Users: source field total_active_gas_uuid. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql: ${TABLE}.active_users_total_active_gas_uuid ;;
  }
  measure: active_users_total_active_gas_uuid_sum {
    type: number
    label: "Total Active Gas UUID (Sum)"
    group_label: "Active Users"
    description: "Sum of total_active_gas_uuid over selected source rows. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'activeusers'" %}
        SUM(${active_users_total_active_gas_uuid})
      {% else %} CAST(NULL AS INTEGER)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: active_users_total_active_uuid {
    type: number
    label: "Total Active UUID"
    group_label: "Active Users"
    description: "Active Users: source field total_active_uuid. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql: ${TABLE}.active_users_total_active_uuid ;;
  }
  measure: active_users_total_active_uuid_sum {
    type: number
    label: "Total Active UUID (Sum)"
    group_label: "Active Users"
    description: "Sum of total_active_uuid over selected source rows. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'activeusers'" %}
        SUM(${active_users_total_active_uuid})
      {% else %} CAST(NULL AS INTEGER)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: active_users_total_active_user_meters {
    type: number
    label: "Total Active User Meters"
    group_label: "Active Users"
    description: "Active Users: source field total_active_user_meters. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql: ${TABLE}.active_users_total_active_user_meters ;;
  }
  measure: active_users_total_active_user_meters_sum {
    type: number
    label: "Total Active User Meters (Sum)"
    group_label: "Active Users"
    description: "Sum of total_active_user_meters over selected source rows. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'activeusers'" %}
        SUM(${active_users_total_active_user_meters})
      {% else %} CAST(NULL AS INTEGER)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: active_users_total_active_electric_meters {
    type: number
    label: "Total Active Electric Meters"
    group_label: "Active Users"
    description: "Active Users: source field total_active_electric_meters. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql: ${TABLE}.active_users_total_active_electric_meters ;;
  }
  measure: active_users_total_active_electric_meters_sum {
    type: number
    label: "Total Active Electric Meters (Sum)"
    group_label: "Active Users"
    description: "Sum of total_active_electric_meters over selected source rows. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'activeusers'" %}
        SUM(${active_users_total_active_electric_meters})
      {% else %} CAST(NULL AS INTEGER)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: active_users_total_active_gas_meters {
    type: number
    label: "Total Active Gas Meters"
    group_label: "Active Users"
    description: "Active Users: source field total_active_gas_meters. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql: ${TABLE}.active_users_total_active_gas_meters ;;
  }
  measure: active_users_total_active_gas_meters_sum {
    type: number
    label: "Total Active Gas Meters (Sum)"
    group_label: "Active Users"
    description: "Sum of total_active_gas_meters over selected source rows. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'activeusers'" %}
        SUM(${active_users_total_active_gas_meters})
      {% else %} CAST(NULL AS INTEGER)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: ingestion_audit_total_files_processed {
    type: number
    label: "Total Files Processed"
    group_label: "Ingestion Audit"
    description: "Ingestion Audit: source field total_files_processed. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. NULL for other families."
    sql: ${TABLE}.ingestion_audit_total_files_processed ;;
  }
  measure: ingestion_audit_total_files_processed_sum {
    type: number
    label: "Total Files Processed (Sum)"
    group_label: "Ingestion Audit"
    description: "Sum of total_files_processed over selected source rows. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'ingestionaudit'" %}
        SUM(${ingestion_audit_total_files_processed})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: ingestion_audit_total_chunks_processed {
    type: number
    label: "Total Chunks Processed"
    group_label: "Ingestion Audit"
    description: "Ingestion Audit: source field total_chunks_processed. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. NULL for other families."
    sql: ${TABLE}.ingestion_audit_total_chunks_processed ;;
  }
  measure: ingestion_audit_total_chunks_processed_sum {
    type: number
    label: "Total Chunks Processed (Sum)"
    group_label: "Ingestion Audit"
    description: "Sum of total_chunks_processed over selected source rows. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'ingestionaudit'" %}
        SUM(${ingestion_audit_total_chunks_processed})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: ingestion_audit_total_records_count {
    type: number
    label: "Total Records Count"
    group_label: "Ingestion Audit"
    description: "Ingestion Audit: source field total_records_count. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. NULL for other families."
    sql: ${TABLE}.ingestion_audit_total_records_count ;;
  }
  measure: ingestion_audit_total_records_count_sum {
    type: number
    label: "Total Records Count (Sum)"
    group_label: "Ingestion Audit"
    description: "Sum of total_records_count over selected source rows. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'ingestionaudit'" %}
        SUM(${ingestion_audit_total_records_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: ingestion_audit_total_success_record_count {
    type: number
    label: "Total Success Record Count"
    group_label: "Ingestion Audit"
    description: "Ingestion Audit: source field total_success_record_count. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. NULL for other families."
    sql: ${TABLE}.ingestion_audit_total_success_record_count ;;
  }
  measure: ingestion_audit_total_success_record_count_sum {
    type: number
    label: "Total Success Record Count (Sum)"
    group_label: "Ingestion Audit"
    description: "Sum of total_success_record_count over selected source rows. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'ingestionaudit'" %}
        SUM(${ingestion_audit_total_success_record_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: ingestion_audit_total_failure_record_count {
    type: number
    label: "Total Failure Record Count"
    group_label: "Ingestion Audit"
    description: "Ingestion Audit: source field total_failure_record_count. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. NULL for other families."
    sql: ${TABLE}.ingestion_audit_total_failure_record_count ;;
  }
  measure: ingestion_audit_total_failure_record_count_sum {
    type: number
    label: "Total Failure Record Count (Sum)"
    group_label: "Ingestion Audit"
    description: "Sum of total_failure_record_count over selected source rows. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'ingestionaudit'" %}
        SUM(${ingestion_audit_total_failure_record_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: ingestion_audit_success_percentage {
    type: number
    label: "Success Percentage"
    group_label: "Ingestion Audit"
    description: "Ingestion Audit: source field success_percentage. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. NULL for other families."
    sql: ${TABLE}.ingestion_audit_success_percentage ;;
  }
  measure: ingestion_audit_success_percentage_average {
    type: number
    label: "Success Percentage (Average)"
    group_label: "Ingestion Audit"
    description: "Arithmetic average of the source-provided success_percentage; displayed without rescaling or weighting. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'ingestionaudit'" %}
        AVG(${ingestion_audit_success_percentage})
      {% else %} CAST(NULL AS DECIMAL(26, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: ingestion_audit_failure_percentage {
    type: number
    label: "Failure Percentage"
    group_label: "Ingestion Audit"
    description: "Ingestion Audit: source field failure_percentage. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. NULL for other families."
    sql: ${TABLE}.ingestion_audit_failure_percentage ;;
  }
  measure: ingestion_audit_failure_percentage_average {
    type: number
    label: "Failure Percentage (Average)"
    group_label: "Ingestion Audit"
    description: "Arithmetic average of the source-provided failure_percentage; displayed without rescaling or weighting. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'ingestionaudit'" %}
        AVG(${ingestion_audit_failure_percentage})
      {% else %} CAST(NULL AS DECIMAL(26, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: ingestion_failures_failed_record_count {
    type: number
    label: "Failed Record Count"
    group_label: "Ingestion Failures"
    description: "Ingestion Failures: source field failed_record_count. Original error-code rows; rank within analysis date, pilot and ingestion type. NULL for other families."
    sql: ${TABLE}.ingestion_failures_failed_record_count ;;
  }
  measure: ingestion_failures_failed_record_count_sum {
    type: number
    label: "Failed Record Count (Sum)"
    group_label: "Ingestion Failures"
    description: "Sum of failed_record_count over selected source rows. Original error-code rows; rank within analysis date, pilot and ingestion type. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'ingestionfailures'" %}
        SUM(${ingestion_failures_failed_record_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: ingestion_failures_total_failed_record_count {
    type: number
    label: "Total Failed Record Count"
    group_label: "Ingestion Failures"
    description: "Ingestion Failures: source field total_failed_record_count. Original error-code rows; rank within analysis date, pilot and ingestion type. NULL for other families."
    sql: ${TABLE}.ingestion_failures_total_failed_record_count ;;
  }
  dimension: ingestion_failures_failure_percentage {
    type: number
    label: "Failure Percentage"
    group_label: "Ingestion Failures"
    description: "Ingestion Failures: source field failure_percentage. Original error-code rows; rank within analysis date, pilot and ingestion type. NULL for other families."
    sql: ${TABLE}.ingestion_failures_failure_percentage ;;
  }
  measure: ingestion_failures_failure_percentage_average {
    type: number
    label: "Failure Percentage (Average)"
    group_label: "Ingestion Failures"
    description: "Arithmetic average of the source-provided failure_percentage; displayed without rescaling or weighting. Original error-code rows; rank within analysis date, pilot and ingestion type. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'ingestionfailures'" %}
        AVG(${ingestion_failures_failure_percentage})
      {% else %} CAST(NULL AS DECIMAL(26, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: post_ingestion_user_raw_with_delay_0_3 {
    type: number
    label: "User Raw With Delay 0 3"
    group_label: "Post-Ingestion Quality"
    description: "Post-Ingestion Quality: source field user_raw_with_delay_0_3. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql: ${TABLE}.post_ingestion_user_raw_with_delay_0_3 ;;
  }
  measure: post_ingestion_user_raw_with_delay_0_3_sum {
    type: number
    label: "User Raw With Delay 0 3 (Sum)"
    group_label: "Post-Ingestion Quality"
    description: "Sum of user_raw_with_delay_0_3 over selected source rows. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'postingestion'" %}
        SUM(${post_ingestion_user_raw_with_delay_0_3})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: post_ingestion_user_raw_with_delay_4_7 {
    type: number
    label: "User Raw With Delay 4 7"
    group_label: "Post-Ingestion Quality"
    description: "Post-Ingestion Quality: source field user_raw_with_delay_4_7. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql: ${TABLE}.post_ingestion_user_raw_with_delay_4_7 ;;
  }
  measure: post_ingestion_user_raw_with_delay_4_7_sum {
    type: number
    label: "User Raw With Delay 4 7 (Sum)"
    group_label: "Post-Ingestion Quality"
    description: "Sum of user_raw_with_delay_4_7 over selected source rows. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'postingestion'" %}
        SUM(${post_ingestion_user_raw_with_delay_4_7})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: post_ingestion_user_raw_with_delay_8_15 {
    type: number
    label: "User Raw With Delay 8 15"
    group_label: "Post-Ingestion Quality"
    description: "Post-Ingestion Quality: source field user_raw_with_delay_8_15. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql: ${TABLE}.post_ingestion_user_raw_with_delay_8_15 ;;
  }
  measure: post_ingestion_user_raw_with_delay_8_15_sum {
    type: number
    label: "User Raw With Delay 8 15 (Sum)"
    group_label: "Post-Ingestion Quality"
    description: "Sum of user_raw_with_delay_8_15 over selected source rows. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'postingestion'" %}
        SUM(${post_ingestion_user_raw_with_delay_8_15})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: post_ingestion_user_raw_with_delay_gt_15 {
    type: number
    label: "User Raw With Delay Gt 15"
    group_label: "Post-Ingestion Quality"
    description: "Post-Ingestion Quality: source field user_raw_with_delay_gt_15. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql: ${TABLE}.post_ingestion_user_raw_with_delay_gt_15 ;;
  }
  measure: post_ingestion_user_raw_with_delay_gt_15_sum {
    type: number
    label: "User Raw With Delay Gt 15 (Sum)"
    group_label: "Post-Ingestion Quality"
    description: "Sum of user_raw_with_delay_gt_15 over selected source rows. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'postingestion'" %}
        SUM(${post_ingestion_user_raw_with_delay_gt_15})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: post_ingestion_user_invoice_with_delay_0_7 {
    type: number
    label: "User Invoice With Delay 0 7"
    group_label: "Post-Ingestion Quality"
    description: "Post-Ingestion Quality: source field user_invoice_with_delay_0_7. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql: ${TABLE}.post_ingestion_user_invoice_with_delay_0_7 ;;
  }
  measure: post_ingestion_user_invoice_with_delay_0_7_sum {
    type: number
    label: "User Invoice With Delay 0 7 (Sum)"
    group_label: "Post-Ingestion Quality"
    description: "Sum of user_invoice_with_delay_0_7 over selected source rows. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'postingestion'" %}
        SUM(${post_ingestion_user_invoice_with_delay_0_7})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: post_ingestion_user_invoice_with_delay_7_15 {
    type: number
    label: "User Invoice With Delay 7 15"
    group_label: "Post-Ingestion Quality"
    description: "Post-Ingestion Quality: source field user_invoice_with_delay_7_15. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql: ${TABLE}.post_ingestion_user_invoice_with_delay_7_15 ;;
  }
  measure: post_ingestion_user_invoice_with_delay_7_15_sum {
    type: number
    label: "User Invoice With Delay 7 15 (Sum)"
    group_label: "Post-Ingestion Quality"
    description: "Sum of user_invoice_with_delay_7_15 over selected source rows. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'postingestion'" %}
        SUM(${post_ingestion_user_invoice_with_delay_7_15})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: post_ingestion_user_invoice_with_delay_15_30 {
    type: number
    label: "User Invoice With Delay 15 30"
    group_label: "Post-Ingestion Quality"
    description: "Post-Ingestion Quality: source field user_invoice_with_delay_15_30. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql: ${TABLE}.post_ingestion_user_invoice_with_delay_15_30 ;;
  }
  measure: post_ingestion_user_invoice_with_delay_15_30_sum {
    type: number
    label: "User Invoice With Delay 15 30 (Sum)"
    group_label: "Post-Ingestion Quality"
    description: "Sum of user_invoice_with_delay_15_30 over selected source rows. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'postingestion'" %}
        SUM(${post_ingestion_user_invoice_with_delay_15_30})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: post_ingestion_user_invoice_with_delay_gt_30 {
    type: number
    label: "User Invoice With Delay Gt 30"
    group_label: "Post-Ingestion Quality"
    description: "Post-Ingestion Quality: source field user_invoice_with_delay_gt_30. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql: ${TABLE}.post_ingestion_user_invoice_with_delay_gt_30 ;;
  }
  measure: post_ingestion_user_invoice_with_delay_gt_30_sum {
    type: number
    label: "User Invoice With Delay Gt 30 (Sum)"
    group_label: "Post-Ingestion Quality"
    description: "Sum of user_invoice_with_delay_gt_30 over selected source rows. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'postingestion'" %}
        SUM(${post_ingestion_user_invoice_with_delay_gt_30})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: post_ingestion_overlapping_bc_count {
    type: number
    label: "Overlapping BC Count"
    group_label: "Post-Ingestion Quality"
    description: "Post-Ingestion Quality: source field overlapping_bc_count. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. NULL for other families."
    sql: ${TABLE}.post_ingestion_overlapping_bc_count ;;
  }
  dimension: invoice_statistics_total_invoices {
    type: number
    label: "Total Invoices"
    group_label: "Invoice Statistics"
    description: "Invoice Statistics: source field total_invoices. Latest update per pilot, meter, fuel, module, analysis date and trigger; SCHEDULED additionally partitions by delay. NULL for other families."
    sql: ${TABLE}.invoice_statistics_total_invoices ;;
  }
  measure: invoice_statistics_total_invoices_sum {
    type: number
    label: "Total Invoices (Sum)"
    group_label: "Invoice Statistics"
    description: "Sum of total_invoices over selected source rows. Latest update per pilot, meter, fuel, module, analysis date and trigger; SCHEDULED additionally partitions by delay. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'invoicestatistics'" %}
        SUM(${invoice_statistics_total_invoices})
      {% else %} CAST(NULL AS INTEGER)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: invoice_statistics_failed_itemisation_pct {
    type: number
    label: "Failed Itemisation Percentage"
    group_label: "Invoice Statistics"
    description: "Invoice Statistics: source field failed_itemisation_pct. Latest update per pilot, meter, fuel, module, analysis date and trigger; SCHEDULED additionally partitions by delay. NULL for other families."
    sql: ${TABLE}.invoice_statistics_failed_itemisation_pct ;;
  }
  measure: invoice_statistics_failed_itemisation_pct_average {
    type: number
    label: "Failed Itemisation Percentage (Average)"
    group_label: "Invoice Statistics"
    description: "Arithmetic average of the source-provided failed_itemisation_pct; displayed without rescaling or weighting. Latest update per pilot, meter, fuel, module, analysis date and trigger; SCHEDULED additionally partitions by delay. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'invoicestatistics'" %}
        AVG(${invoice_statistics_failed_itemisation_pct})
      {% else %} CAST(NULL AS DECIMAL(5, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: invoice_statistics_successful_itemisation_pct {
    type: number
    label: "Successful Itemisation Percentage"
    group_label: "Invoice Statistics"
    description: "Invoice Statistics: source field successful_itemisation_pct. Latest update per pilot, meter, fuel, module, analysis date and trigger; SCHEDULED additionally partitions by delay. NULL for other families."
    sql: ${TABLE}.invoice_statistics_successful_itemisation_pct ;;
  }
  measure: invoice_statistics_successful_itemisation_pct_average {
    type: number
    label: "Successful Itemisation Percentage (Average)"
    group_label: "Invoice Statistics"
    description: "Arithmetic average of the source-provided successful_itemisation_pct; displayed without rescaling or weighting. Latest update per pilot, meter, fuel, module, analysis date and trigger; SCHEDULED additionally partitions by delay. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'invoicestatistics'" %}
        AVG(${invoice_statistics_successful_itemisation_pct})
      {% else %} CAST(NULL AS DECIMAL(5, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: invoice_statistics_successful_itemisation_t_7_pct {
    type: number
    hidden: yes
    group_label: "Disagg Dashboard"
    description: "Source success percentage for SCHEDULED rows with delay_in_days = 7; all other rows are NULL. T-7 denotes source delay, not a shifted date filter."
    sql: CASE WHEN ${delay_in_days} = 7 AND ${trigger_flag} = 'SCHEDULED' THEN ${invoice_statistics_successful_itemisation_pct} ELSE NULL END ;;
  }
  measure: invoice_statistics_successful_itemisation_t_7_pct_average {
    type: number
    label: "Success % — T-7 Day"
    group_label: "Disagg Dashboard"
    description: "Unweighted average of success percentages for SCHEDULED T-7 rows within the selected reporting-date range. Retains source percentage scale and zero values."
    sql:
      {% if source_family._parameter_value == "'invoicestatistics'" %}
        AVG(${invoice_statistics_successful_itemisation_t_7_pct})
      {% else %} CAST(NULL AS DECIMAL(5, 2))
      {% endif %} ;;
    value_format: "0.00\"%\""
  }
  dimension: invoice_statistics_successful_itemisation_t_2_pct {
    type: number
    hidden: yes
    group_label: "Disagg Dashboard"
    description: "Source success percentage for SCHEDULED rows with delay_in_days = 2; all other rows are NULL. T-2 denotes source delay, not a shifted date filter."
    sql: CASE WHEN ${delay_in_days} = 2 AND ${trigger_flag} = 'SCHEDULED' THEN ${invoice_statistics_successful_itemisation_pct} ELSE NULL END ;;
  }
  measure: invoice_statistics_successful_itemisation_t_2_pct_average {
    type: number
    label: "Success % — T-2 Day"
    group_label: "Disagg Dashboard"
    description: "Unweighted average of success percentages for SCHEDULED T-2 rows within the selected reporting-date range. Retains source percentage scale and zero values."
    sql:
      {% if source_family._parameter_value == "'invoicestatistics'" %}
        AVG(${invoice_statistics_successful_itemisation_t_2_pct})
      {% else %} CAST(NULL AS DECIMAL(5, 2))
      {% endif %} ;;
    value_format: "0.00\"%\""
  }
  measure: invoice_statistics_daily_total_invoices {
    type: number
    label: "Daily Total Invoices"
    group_label: "Disagg Dashboard"
    description: "Per displayed group: average total_invoices when exactly one distinct analysis_date is present; otherwise sum total_invoices. Reporting-date filtering is applied independently."
    sql:
      {% if source_family._parameter_value == "'invoicestatistics'" %}
        CASE WHEN COUNT(DISTINCT ${analysis_date::date}) = 1
          THEN AVG(${invoice_statistics_total_invoices})
          ELSE SUM(${invoice_statistics_total_invoices}) END
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: invoice_statistics_successful_itemisation_correction_pct {
    type: number
    hidden: yes
    group_label: "Disagg Dashboard"
    description: "Source success percentage for ADHOC rows; all other rows are NULL."
    sql: CASE WHEN ${trigger_flag} = 'ADHOC' THEN ${invoice_statistics_successful_itemisation_pct} ELSE NULL END ;;
  }
  measure: invoice_statistics_successful_itemisation_correction_pct_max {
    type: number
    label: "Correction Line"
    group_label: "Disagg Dashboard"
    description: "Maximum source success percentage among ADHOC rows in each displayed group. Retains source percentage scale."
    sql:
      {% if source_family._parameter_value == "'invoicestatistics'" %}
        MAX(${invoice_statistics_successful_itemisation_correction_pct})
      {% else %} CAST(NULL AS DECIMAL(5, 2))
      {% endif %} ;;
    value_format: "0.00\"%\""
  }
  dimension: disagg_quality_appliances_kwh_variance_pct_1 {
    type: number
    label: "Appliances Kwh Variance Percentage 1"
    group_label: "Disagg Quality"
    description: "Disagg Quality: source field appliances_kwh_variance_pct_1. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql: ${TABLE}.disagg_quality_appliances_kwh_variance_pct_1 ;;
  }
  measure: disagg_quality_appliances_kwh_variance_pct_1_average {
    type: number
    label: "Appliances Kwh Variance Percentage 1 (Average)"
    group_label: "Disagg Quality"
    description: "Arithmetic average of the source-provided appliances_kwh_variance_pct_1; displayed without rescaling or weighting. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'disaggquality'" %}
        AVG(${disagg_quality_appliances_kwh_variance_pct_1})
      {% else %} CAST(NULL AS DECIMAL(10, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: disagg_quality_appliances_kwh_variance_pct_2 {
    type: number
    label: "Appliances Kwh Variance Percentage 2"
    group_label: "Disagg Quality"
    description: "Disagg Quality: source field appliances_kwh_variance_pct_2. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql: ${TABLE}.disagg_quality_appliances_kwh_variance_pct_2 ;;
  }
  measure: disagg_quality_appliances_kwh_variance_pct_2_average {
    type: number
    label: "Appliances Kwh Variance Percentage 2 (Average)"
    group_label: "Disagg Quality"
    description: "Arithmetic average of the source-provided appliances_kwh_variance_pct_2; displayed without rescaling or weighting. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'disaggquality'" %}
        AVG(${disagg_quality_appliances_kwh_variance_pct_2})
      {% else %} CAST(NULL AS DECIMAL(10, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: disagg_quality_total_cost_deviation_pct_1 {
    type: number
    label: "Total Cost Deviation Percentage 1"
    group_label: "Disagg Quality"
    description: "Disagg Quality: source field total_cost_deviation_pct_1. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql: ${TABLE}.disagg_quality_total_cost_deviation_pct_1 ;;
  }
  measure: disagg_quality_total_cost_deviation_pct_1_average {
    type: number
    label: "Total Cost Deviation Percentage 1 (Average)"
    group_label: "Disagg Quality"
    description: "Arithmetic average of the source-provided total_cost_deviation_pct_1; displayed without rescaling or weighting. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'disaggquality'" %}
        AVG(${disagg_quality_total_cost_deviation_pct_1})
      {% else %} CAST(NULL AS DECIMAL(10, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: disagg_quality_total_cost_deviation_pct_2 {
    type: number
    label: "Total Cost Deviation Percentage 2"
    group_label: "Disagg Quality"
    description: "Disagg Quality: source field total_cost_deviation_pct_2. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql: ${TABLE}.disagg_quality_total_cost_deviation_pct_2 ;;
  }
  measure: disagg_quality_total_cost_deviation_pct_2_average {
    type: number
    label: "Total Cost Deviation Percentage 2 (Average)"
    group_label: "Disagg Quality"
    description: "Arithmetic average of the source-provided total_cost_deviation_pct_2; displayed without rescaling or weighting. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'disaggquality'" %}
        AVG(${disagg_quality_total_cost_deviation_pct_2})
      {% else %} CAST(NULL AS DECIMAL(10, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: disagg_quality_cost_per_kwh_deviation_pct {
    type: number
    label: "Cost Per Kwh Deviation Percentage"
    group_label: "Disagg Quality"
    description: "Disagg Quality: source field cost_per_kwh_deviation_pct. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql: ${TABLE}.disagg_quality_cost_per_kwh_deviation_pct ;;
  }
  measure: disagg_quality_cost_per_kwh_deviation_pct_average {
    type: number
    label: "Cost Per Kwh Deviation Percentage (Average)"
    group_label: "Disagg Quality"
    description: "Arithmetic average of the source-provided cost_per_kwh_deviation_pct; displayed without rescaling or weighting. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'disaggquality'" %}
        AVG(${disagg_quality_cost_per_kwh_deviation_pct})
      {% else %} CAST(NULL AS DECIMAL(10, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: disagg_quality_seasonal_appliance_usage_deviation_pct {
    type: number
    label: "Seasonal Appliance Usage Deviation Percentage"
    group_label: "Disagg Quality"
    description: "Disagg Quality: source field seasonal_appliance_usage_deviation_pct. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql: ${TABLE}.disagg_quality_seasonal_appliance_usage_deviation_pct ;;
  }
  measure: disagg_quality_seasonal_appliance_usage_deviation_pct_average {
    type: number
    label: "Seasonal Appliance Usage Deviation Percentage (Average)"
    group_label: "Disagg Quality"
    description: "Arithmetic average of the source-provided seasonal_appliance_usage_deviation_pct; displayed without rescaling or weighting. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'disaggquality'" %}
        AVG(${disagg_quality_seasonal_appliance_usage_deviation_pct})
      {% else %} CAST(NULL AS DECIMAL(10, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: disagg_quality_single_appliance_domination_deviation_pct {
    type: number
    label: "Single Appliance Domination Deviation Percentage"
    group_label: "Disagg Quality"
    description: "Disagg Quality: source field single_appliance_domination_deviation_pct. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql: ${TABLE}.disagg_quality_single_appliance_domination_deviation_pct ;;
  }
  measure: disagg_quality_single_appliance_domination_deviation_pct_average {
    type: number
    label: "Single Appliance Domination Deviation Percentage (Average)"
    group_label: "Disagg Quality"
    description: "Arithmetic average of the source-provided single_appliance_domination_deviation_pct; displayed without rescaling or weighting. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'disaggquality'" %}
        AVG(${disagg_quality_single_appliance_domination_deviation_pct})
      {% else %} CAST(NULL AS DECIMAL(10, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: disagg_quality_missing_dwelliing_pct {
    type: number
    label: "Missing Dwelliing Percentage"
    group_label: "Disagg Quality"
    description: "Disagg Quality: source field missing_dwelliing_pct. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql: ${TABLE}.disagg_quality_missing_dwelliing_pct ;;
  }
  measure: disagg_quality_missing_dwelliing_pct_average {
    type: number
    label: "Missing Dwelliing Percentage (Average)"
    group_label: "Disagg Quality"
    description: "Arithmetic average of the source-provided missing_dwelliing_pct; displayed without rescaling or weighting. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'disaggquality'" %}
        AVG(${disagg_quality_missing_dwelliing_pct})
      {% else %} CAST(NULL AS DECIMAL(10, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: disagg_quality_ao_pct_non_tou {
    type: number
    label: "Ao Percentage Non Tou"
    group_label: "Disagg Quality"
    description: "Disagg Quality: source field ao_pct_non_tou. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql: ${TABLE}.disagg_quality_ao_pct_non_tou ;;
  }
  measure: disagg_quality_ao_pct_non_tou_average {
    type: number
    label: "Ao Percentage Non Tou (Average)"
    group_label: "Disagg Quality"
    description: "Arithmetic average of the source-provided ao_pct_non_tou; displayed without rescaling or weighting. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'disaggquality'" %}
        AVG(${disagg_quality_ao_pct_non_tou})
      {% else %} CAST(NULL AS DECIMAL(10, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: disagg_quality_ac_pct_non_tou {
    type: number
    label: "Ac Percentage Non Tou"
    group_label: "Disagg Quality"
    description: "Disagg Quality: source field ac_pct_non_tou. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql: ${TABLE}.disagg_quality_ac_pct_non_tou ;;
  }
  measure: disagg_quality_ac_pct_non_tou_average {
    type: number
    label: "Ac Percentage Non Tou (Average)"
    group_label: "Disagg Quality"
    description: "Arithmetic average of the source-provided ac_pct_non_tou; displayed without rescaling or weighting. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'disaggquality'" %}
        AVG(${disagg_quality_ac_pct_non_tou})
      {% else %} CAST(NULL AS DECIMAL(10, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: disagg_quality_sh_pct_non_tou {
    type: number
    label: "Sh Percentage Non Tou"
    group_label: "Disagg Quality"
    description: "Disagg Quality: source field sh_pct_non_tou. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql: ${TABLE}.disagg_quality_sh_pct_non_tou ;;
  }
  measure: disagg_quality_sh_pct_non_tou_average {
    type: number
    label: "Sh Percentage Non Tou (Average)"
    group_label: "Disagg Quality"
    description: "Arithmetic average of the source-provided sh_pct_non_tou; displayed without rescaling or weighting. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'disaggquality'" %}
        AVG(${disagg_quality_sh_pct_non_tou})
      {% else %} CAST(NULL AS DECIMAL(10, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: disagg_quality_other_pct_non_tou {
    type: number
    label: "Other Percentage Non Tou"
    group_label: "Disagg Quality"
    description: "Disagg Quality: source field other_pct_non_tou. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql: ${TABLE}.disagg_quality_other_pct_non_tou ;;
  }
  measure: disagg_quality_other_pct_non_tou_average {
    type: number
    label: "Other Percentage Non Tou (Average)"
    group_label: "Disagg Quality"
    description: "Arithmetic average of the source-provided other_pct_non_tou; displayed without rescaling or weighting. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'disaggquality'" %}
        AVG(${disagg_quality_other_pct_non_tou})
      {% else %} CAST(NULL AS DECIMAL(10, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: disagg_quality_solar_pct_non_tou {
    type: number
    label: "Solar Percentage Non Tou"
    group_label: "Disagg Quality"
    description: "Disagg Quality: source field solar_pct_non_tou. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql: ${TABLE}.disagg_quality_solar_pct_non_tou ;;
  }
  measure: disagg_quality_solar_pct_non_tou_average {
    type: number
    label: "Solar Percentage Non Tou (Average)"
    group_label: "Disagg Quality"
    description: "Arithmetic average of the source-provided solar_pct_non_tou; displayed without rescaling or weighting. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'disaggquality'" %}
        AVG(${disagg_quality_solar_pct_non_tou})
      {% else %} CAST(NULL AS DECIMAL(10, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: disagg_quality_missing_solar_pct_non_tou {
    type: number
    label: "Missing Solar Percentage Non Tou"
    group_label: "Disagg Quality"
    description: "Disagg Quality: source field missing_solar_pct_non_tou. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql: ${TABLE}.disagg_quality_missing_solar_pct_non_tou ;;
  }
  measure: disagg_quality_missing_solar_pct_non_tou_average {
    type: number
    label: "Missing Solar Percentage Non Tou (Average)"
    group_label: "Disagg Quality"
    description: "Arithmetic average of the source-provided missing_solar_pct_non_tou; displayed without rescaling or weighting. Original quality rows by pilot, dates, meter, fuel and TOU status. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'disaggquality'" %}
        AVG(${disagg_quality_missing_solar_pct_non_tou})
      {% else %} CAST(NULL AS DECIMAL(10, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: processing_failures_failure_percentage {
    type: number
    label: "Failure Percentage"
    group_label: "Processing Failures"
    description: "Processing Failures: source field failure_percentage. Original failure-detail rows; rank by percentage within analysis date, pilot and module, before optional top-three filtering. NULL for other families."
    sql: ${TABLE}.processing_failures_failure_percentage ;;
  }
  measure: processing_failures_failure_percentage_average {
    type: number
    label: "Failure Percentage (Average)"
    group_label: "Processing Failures"
    description: "Arithmetic average of the source-provided failure_percentage; displayed without rescaling or weighting. Original failure-detail rows; rank by percentage within analysis date, pilot and module, before optional top-three filtering. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'processingfailures'" %}
        AVG(${processing_failures_failure_percentage})
      {% else %} CAST(NULL AS DECIMAL(5, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: processing_failures_failure_count {
    type: number
    label: "Failure Count"
    group_label: "Processing Failures"
    description: "Processing Failures: source field failure_count. Original failure-detail rows; rank by percentage within analysis date, pilot and module, before optional top-three filtering. NULL for other families."
    sql: ${TABLE}.processing_failures_failure_count ;;
  }
  measure: processing_failures_failure_count_sum {
    type: number
    label: "Failure Count (Sum)"
    group_label: "Processing Failures"
    description: "Sum of failure_count over selected source rows. Original failure-detail rows; rank by percentage within analysis date, pilot and module, before optional top-three filtering. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'processingfailures'" %}
        SUM(${processing_failures_failure_count})
      {% else %} CAST(NULL AS INTEGER)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: processing_failures_total_failure_count {
    type: number
    label: "Total Failure Count"
    group_label: "Processing Failures"
    description: "Processing Failures: source field total_failure_count. Original failure-detail rows; rank by percentage within analysis date, pilot and module, before optional top-three filtering. NULL for other families."
    sql: ${TABLE}.processing_failures_total_failure_count ;;
  }
  dimension: email_statistics_cnt_bills_ingested {
    type: number
    label: "Count Bills Ingested"
    group_label: "Email Statistics"
    description: "Email Statistics: source field cnt_bills_ingested. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql: ${TABLE}.email_statistics_cnt_bills_ingested ;;
  }
  measure: email_statistics_cnt_bills_ingested_sum {
    type: number
    label: "Count Bills Ingested (Sum)"
    group_label: "Email Statistics"
    description: "Sum of cnt_bills_ingested over selected source rows. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        SUM(${email_statistics_cnt_bills_ingested})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: email_statistics_cnt_bills_emails_sent {
    type: number
    label: "Count Bills Emails Sent"
    group_label: "Email Statistics"
    description: "Email Statistics: source field cnt_bills_emails_sent. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql: ${TABLE}.email_statistics_cnt_bills_emails_sent ;;
  }
  measure: email_statistics_cnt_bills_emails_sent_sum {
    type: number
    label: "Count Bills Emails Sent (Sum)"
    group_label: "Email Statistics"
    description: "Sum of cnt_bills_emails_sent over selected source rows. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        SUM(${email_statistics_cnt_bills_emails_sent})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: email_statistics_cnt_bills_emails_delivered {
    type: number
    label: "Count Bills Emails Delivered"
    group_label: "Email Statistics"
    description: "Email Statistics: source field cnt_bills_emails_delivered. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql: ${TABLE}.email_statistics_cnt_bills_emails_delivered ;;
  }
  measure: email_statistics_cnt_bills_emails_delivered_sum {
    type: number
    label: "Count Bills Emails Delivered (Sum)"
    group_label: "Email Statistics"
    description: "Sum of cnt_bills_emails_delivered over selected source rows. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        SUM(${email_statistics_cnt_bills_emails_delivered})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: email_statistics_email_sent_pct {
    type: number
    label: "Email Sent Percentage"
    group_label: "Email Statistics"
    description: "Email Statistics: source field email_sent_pct. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql: ${TABLE}.email_statistics_email_sent_pct ;;
  }
  measure: email_statistics_email_sent_pct_average {
    type: number
    label: "Email Sent Percentage (Average)"
    group_label: "Email Statistics"
    description: "Arithmetic average of the source-provided email_sent_pct; displayed without rescaling or weighting. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        AVG(${email_statistics_email_sent_pct})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: email_statistics_email_sent_pct_vs_expected {
    type: number
    hidden: yes
    label: "Email Sent Percentage vs Expected"
    group_label: "Email Statistics"
    description: "Row-level cnt_bills_emails_sent / cnt_expected_invoices * 100. Floating-point division preserves fractions; zero or NULL expected counts produce NULL."
    sql: CAST(${email_statistics_cnt_bills_emails_sent} AS DOUBLE) / NULLIF(${email_statistics_cnt_expected_invoices}, 0) * 100.0 ;;
  }
  measure: email_statistics_email_sent_pct_vs_expected_average {
    type: number
    label: "Email Sent Percentage vs Expected (Average)"
    group_label: "Email Statistics"
    description: "Unweighted average of row-level sent percentages versus expected invoices. NULL ratios are omitted; zero sent counts are retained when the denominator is nonzero. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        AVG(${email_statistics_email_sent_pct_vs_expected})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "0.00\"%\""
  }
  dimension: email_statistics_email_not_sent_pct {
    type: number
    label: "Email Not Sent Percentage"
    group_label: "Email Statistics"
    description: "Email Statistics: source field email_not_sent_pct. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql: ${TABLE}.email_statistics_email_not_sent_pct ;;
  }
  measure: email_statistics_email_not_sent_pct_average {
    type: number
    label: "Email Not Sent Percentage (Average)"
    group_label: "Email Statistics"
    description: "Arithmetic average of the source-provided email_not_sent_pct; displayed without rescaling or weighting. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        AVG(${email_statistics_email_not_sent_pct})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: email_statistics_cnt_expected_invoices {
    type: number
    label: "Count Expected Invoices"
    group_label: "Email Statistics"
    description: "Email Statistics: source field cnt_expected_invoices. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql: ${TABLE}.email_statistics_cnt_expected_invoices ;;
  }
  measure: email_statistics_cnt_expected_invoices_sum {
    type: number
    label: "Count Expected Invoices (Sum)"
    group_label: "Email Statistics"
    description: "Sum of cnt_expected_invoices over selected source rows. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        SUM(${email_statistics_cnt_expected_invoices})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: email_statistics_cnt_bills_item_available {
    type: number
    label: "Count Bills Item Available"
    group_label: "Email Statistics"
    description: "Email Statistics: source field cnt_bills_item_available. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql: ${TABLE}.email_statistics_cnt_bills_item_available ;;
  }
  measure: email_statistics_cnt_bills_item_available_sum {
    type: number
    label: "Count Bills Item Available (Sum)"
    group_label: "Email Statistics"
    description: "Sum of cnt_bills_item_available over selected source rows. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        SUM(${email_statistics_cnt_bills_item_available})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: email_statistics_cnt_bills_ingested_source_text {
    type: string
    label: "Count Bills Ingested Source Text"
    group_label: "Email Statistics"
    description: "Email Statistics: source field cnt_bills_ingested_source_text. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql: ${TABLE}.email_statistics_cnt_bills_ingested_source_text ;;
  }
  dimension: email_statistics_cnt_bills_emails_sent_source_text {
    type: string
    label: "Count Bills Emails Sent Source Text"
    group_label: "Email Statistics"
    description: "Email Statistics: source field cnt_bills_emails_sent_source_text. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql: ${TABLE}.email_statistics_cnt_bills_emails_sent_source_text ;;
  }
  dimension: email_statistics_cnt_bills_emails_delivered_source_text {
    type: string
    label: "Count Bills Emails Delivered Source Text"
    group_label: "Email Statistics"
    description: "Email Statistics: source field cnt_bills_emails_delivered_source_text. Original email-quality rows by pilot, dates, email type and billing-cycle end week. NULL for other families."
    sql: ${TABLE}.email_statistics_cnt_bills_emails_delivered_source_text ;;
  }
  measure: email_statistics_cnt_expected_invoices_average {
    type: number
    label: "Expected Invoices (Average)"
    group_label: "Email Statistics"
    description: "Unweighted arithmetic average of source cnt_expected_invoices rows. NULLs omitted and zeros retained; no preliminary weekly aggregation. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        AVG(${email_statistics_cnt_expected_invoices})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  measure: email_statistics_cnt_bills_item_available_average {
    type: number
    label: "Eligible Users (Average)"
    group_label: "Email Statistics"
    description: "Unweighted arithmetic average of source cnt_bills_item_available rows. NULLs omitted and zeros retained; no preliminary weekly aggregation. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        AVG(${email_statistics_cnt_bills_item_available})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  measure: email_statistics_cnt_bills_emails_sent_average {
    type: number
    label: "Emails Sent (Average)"
    group_label: "Email Statistics"
    description: "Unweighted arithmetic average of source cnt_bills_emails_sent rows. NULLs omitted and zeros retained; no preliminary weekly aggregation. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        AVG(${email_statistics_cnt_bills_emails_sent})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: email_tracker_delivered_notification_id {
    type: number
    label: "Delivered Notification Id"
    group_label: "Email Daily Tracker"
    description: "Email Daily Tracker: source field delivered_notification_id. Original daily rows by pilot, email type and delivery mode. NULL for other families."
    sql: ${TABLE}.email_tracker_delivered_notification_id ;;
  }
  measure: email_tracker_delivered_notification_id_sum {
    type: number
    label: "Delivered Notification Id (Sum)"
    group_label: "Email Daily Tracker"
    description: "Sum of delivered_notification_id over selected source rows. Original daily rows by pilot, email type and delivery mode. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailtracker'" %}
        SUM(${email_tracker_delivered_notification_id})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: email_tracker_generated_notification_id {
    type: number
    label: "Generated Notification Id"
    group_label: "Email Daily Tracker"
    description: "Email Daily Tracker: source field generated_notification_id. Original daily rows by pilot, email type and delivery mode. NULL for other families."
    sql: ${TABLE}.email_tracker_generated_notification_id ;;
  }
  measure: email_tracker_generated_notification_id_sum {
    type: number
    label: "Generated Notification Id (Sum)"
    group_label: "Email Daily Tracker"
    description: "Sum of generated_notification_id over selected source rows. Original daily rows by pilot, email type and delivery mode. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailtracker'" %}
        SUM(${email_tracker_generated_notification_id})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: email_tracker_invoice_ingested {
    type: number
    label: "Invoice Ingested"
    group_label: "Email Daily Tracker"
    description: "Email Daily Tracker: source field invoice_ingested. Original daily rows by pilot, email type and delivery mode. NULL for other families."
    sql: ${TABLE}.email_tracker_invoice_ingested ;;
  }
  measure: email_tracker_invoice_ingested_sum {
    type: number
    label: "Invoice Ingested (Sum)"
    group_label: "Email Daily Tracker"
    description: "Sum of invoice_ingested over selected source rows. Original daily rows by pilot, email type and delivery mode. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailtracker'" %}
        SUM(${email_tracker_invoice_ingested})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: email_recommendations_metric_notification_count {
    type: number
    label: "Metric Notification Count"
    group_label: "Email Recommendation Quality"
    description: "Email Recommendation Quality: source field metric_notification_count. Original rows by pilot, dates, billing week, appliance, fuel, email type and metric; denominators repeat across detail rows. NULL for other families."
    sql: ${TABLE}.email_recommendations_metric_notification_count ;;
  }
  measure: email_recommendations_metric_notification_count_sum {
    type: number
    label: "Metric Notification Count (Sum)"
    group_label: "Email Recommendation Quality"
    description: "Sum of metric_notification_count over selected source rows. Original rows by pilot, dates, billing week, appliance, fuel, email type and metric; denominators repeat across detail rows. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailrecommendations'" %}
        SUM(${email_recommendations_metric_notification_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: email_recommendations_total_notification_count {
    type: number
    label: "Total Notification Count"
    group_label: "Email Recommendation Quality"
    description: "Email Recommendation Quality: source field total_notification_count. Original rows by pilot, dates, billing week, appliance, fuel, email type and metric; denominators repeat across detail rows. NULL for other families."
    sql: ${TABLE}.email_recommendations_total_notification_count ;;
  }
  dimension: email_recommendations_notification_pct {
    type: number
    label: "Notification Percentage"
    group_label: "Email Recommendation Quality"
    description: "Email Recommendation Quality: source field notification_pct. Original rows by pilot, dates, billing week, appliance, fuel, email type and metric; denominators repeat across detail rows. NULL for other families."
    sql: ${TABLE}.email_recommendations_notification_pct ;;
  }
  measure: email_recommendations_notification_pct_average {
    type: number
    label: "Notification Percentage (Average)"
    group_label: "Email Recommendation Quality"
    description: "Arithmetic average of the source-provided notification_pct; displayed without rescaling or weighting. Original rows by pilot, dates, billing week, appliance, fuel, email type and metric; denominators repeat across detail rows. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailrecommendations'" %}
        AVG(${email_recommendations_notification_pct})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: email_recommendations_user_count {
    type: number
    label: "User Count"
    group_label: "Email Recommendation Quality"
    description: "Email Recommendation Quality: source field user_count. Original rows by pilot, dates, billing week, appliance, fuel, email type and metric; denominators repeat across detail rows. NULL for other families."
    sql: ${TABLE}.email_recommendations_user_count ;;
  }
  measure: email_recommendations_user_count_sum {
    type: number
    label: "User Count (Sum)"
    group_label: "Email Recommendation Quality"
    description: "Sum of user_count over selected source rows. Original rows by pilot, dates, billing week, appliance, fuel, email type and metric; denominators repeat across detail rows. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailrecommendations'" %}
        SUM(${email_recommendations_user_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: email_recommendations_total_user_count {
    type: number
    label: "Total User Count"
    group_label: "Email Recommendation Quality"
    description: "Email Recommendation Quality: source field total_user_count. Original rows by pilot, dates, billing week, appliance, fuel, email type and metric; denominators repeat across detail rows. NULL for other families."
    sql: ${TABLE}.email_recommendations_total_user_count ;;
  }
  dimension: email_recommendations_user_pct {
    type: number
    label: "User Percentage"
    group_label: "Email Recommendation Quality"
    description: "Email Recommendation Quality: source field user_pct. Original rows by pilot, dates, billing week, appliance, fuel, email type and metric; denominators repeat across detail rows. NULL for other families."
    sql: ${TABLE}.email_recommendations_user_pct ;;
  }
  measure: email_recommendations_user_pct_average {
    type: number
    label: "User Percentage (Average)"
    group_label: "Email Recommendation Quality"
    description: "Arithmetic average of the source-provided user_pct; displayed without rescaling or weighting. Original rows by pilot, dates, billing week, appliance, fuel, email type and metric; denominators repeat across detail rows. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailrecommendations'" %}
        AVG(${email_recommendations_user_pct})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: email_failures_failure_count {
    type: number
    label: "Failure Count"
    group_label: "Email Failures"
    description: "Email Failures: source field failure_count. Original failure-reason rows; rank by count within original analysis date, pilot and email type. NULL for other families."
    sql: ${TABLE}.email_failures_failure_count ;;
  }
  measure: email_failures_failure_count_sum {
    type: number
    label: "Failure Count (Sum)"
    group_label: "Email Failures"
    description: "Sum of failure_count over selected source rows. Original failure-reason rows; rank by count within original analysis date, pilot and email type. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailfailures'" %}
        SUM(${email_failures_failure_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  measure: email_failures_failure_count_average {
    type: number
    label: "Failure Count (Average)"
    group_label: "Email Failures"
    description: "Arithmetic average of source failure_count over selected Email Failures rows. Rank filters retain the source ranking by analysis date, pilot and email type before Period grouping. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailfailures'" %}
        AVG(${email_failures_failure_count})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: email_failures_total_failure_count {
    type: number
    label: "Total Failure Count"
    group_label: "Email Failures"
    description: "Email Failures: source field total_failure_count. Original failure-reason rows; rank by count within original analysis date, pilot and email type. NULL for other families."
    sql: ${TABLE}.email_failures_total_failure_count ;;
  }
  dimension: email_failures_failure_pct {
    type: number
    label: "Failure Percentage"
    group_label: "Email Failures"
    description: "Email Failures: source field failure_pct. Original failure-reason rows; rank by count within original analysis date, pilot and email type. NULL for other families."
    sql: ${TABLE}.email_failures_failure_pct ;;
  }
  measure: email_failures_failure_pct_average {
    type: number
    label: "Failure Percentage (Average)"
    group_label: "Email Failures"
    description: "Arithmetic average of the source-provided failure_pct; displayed without rescaling or weighting. Original failure-reason rows; rank by count within original analysis date, pilot and email type. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'emailfailures'" %}
        AVG(${email_failures_failure_pct})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: her_generation_expected_eligible_users {
    type: number
    label: "Expected Eligible Users"
    group_label: "HER Generation"
    description: "HER Generation: source field expected_eligible_users. Pilot, cluster, fuel, schedule and selected period; period eligibility uses MAX, generation uses SUM. NULL for other families."
    sql: ${TABLE}.her_generation_expected_eligible_users ;;
  }
  measure: her_generation_expected_eligible_users_sum {
    type: number
    label: "Expected Eligible Users (Sum)"
    group_label: "HER Generation"
    description: "Sum of expected_eligible_users over selected source rows. Pilot, cluster, fuel, schedule and selected period; period eligibility uses MAX, generation uses SUM. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hergeneration'" %}
        SUM(${her_generation_expected_eligible_users})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_generation_actual_eligible_users {
    type: number
    label: "Actual Eligible Users"
    group_label: "HER Generation"
    description: "HER Generation: source field actual_eligible_users. Pilot, cluster, fuel, schedule and selected period; period eligibility uses MAX, generation uses SUM. NULL for other families."
    sql: ${TABLE}.her_generation_actual_eligible_users ;;
  }
  measure: her_generation_actual_eligible_users_sum {
    type: number
    label: "Actual Eligible Users (Sum)"
    group_label: "HER Generation"
    description: "Sum of actual_eligible_users over selected source rows. Pilot, cluster, fuel, schedule and selected period; period eligibility uses MAX, generation uses SUM. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hergeneration'" %}
        SUM(${her_generation_actual_eligible_users})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_generation_actual_generation_count {
    type: number
    label: "Actual Generation Count"
    group_label: "HER Generation"
    description: "HER Generation: source field actual_generation_count. Pilot, cluster, fuel, schedule and selected period; period eligibility uses MAX, generation uses SUM. NULL for other families."
    sql: ${TABLE}.her_generation_actual_generation_count ;;
  }
  measure: her_generation_actual_generation_count_sum {
    type: number
    label: "Actual Generation Count (Sum)"
    group_label: "HER Generation"
    description: "Sum of actual_generation_count over selected source rows. Pilot, cluster, fuel, schedule and selected period; period eligibility uses MAX, generation uses SUM. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hergeneration'" %}
        SUM(${her_generation_actual_generation_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_generation_weekly_actual_failure_count {
    type: number
    label: "Weekly Actual Failure Count"
    group_label: "HER Generation"
    description: "HER Generation: source field weekly_actual_failure_count. Pilot, cluster, fuel, schedule and selected period; period eligibility uses MAX, generation uses SUM. NULL for other families."
    sql: ${TABLE}.her_generation_weekly_actual_failure_count ;;
  }
  measure: her_generation_weekly_actual_failure_count_sum {
    type: number
    label: "Weekly Actual Failure Count (Sum)"
    group_label: "HER Generation"
    description: "Sum of weekly_actual_failure_count over selected source rows. Pilot, cluster, fuel, schedule and selected period; period eligibility uses MAX, generation uses SUM. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hergeneration'" %}
        SUM(${her_generation_weekly_actual_failure_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_schedules_total_eligible_users {
    type: number
    label: "Total Eligible Users"
    group_label: "HER Schedule Status"
    description: "HER Schedule Status: source field total_eligible_users. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql: ${TABLE}.her_schedules_total_eligible_users ;;
  }
  measure: her_schedules_total_eligible_users_sum {
    type: number
    label: "Total Eligible Users (Sum)"
    group_label: "HER Schedule Status"
    description: "Sum of total_eligible_users over selected source rows. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herschedules'" %}
        SUM(${her_schedules_total_eligible_users})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_schedules_total_generated_notification_id {
    type: number
    label: "Total Generated Notification Id"
    group_label: "HER Schedule Status"
    description: "HER Schedule Status: source field total_generated_notification_id. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql: ${TABLE}.her_schedules_total_generated_notification_id ;;
  }
  measure: her_schedules_total_generated_notification_id_sum {
    type: number
    label: "Total Generated Notification Id (Sum)"
    group_label: "HER Schedule Status"
    description: "Sum of total_generated_notification_id over selected source rows. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herschedules'" %}
        SUM(${her_schedules_total_generated_notification_id})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_schedules_total_scheduled_notification_id {
    type: number
    label: "Total Scheduled Notification Id"
    group_label: "HER Schedule Status"
    description: "HER Schedule Status: source field total_scheduled_notification_id. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql: ${TABLE}.her_schedules_total_scheduled_notification_id ;;
  }
  measure: her_schedules_total_scheduled_notification_id_sum {
    type: number
    label: "Total Scheduled Notification Id (Sum)"
    group_label: "HER Schedule Status"
    description: "Sum of total_scheduled_notification_id over selected source rows. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herschedules'" %}
        SUM(${her_schedules_total_scheduled_notification_id})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_schedules_total_queued_notification_id {
    type: number
    label: "Total Queued Notification Id"
    group_label: "HER Schedule Status"
    description: "HER Schedule Status: source field total_queued_notification_id. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql: ${TABLE}.her_schedules_total_queued_notification_id ;;
  }
  measure: her_schedules_total_queued_notification_id_sum {
    type: number
    label: "Total Queued Notification Id (Sum)"
    group_label: "HER Schedule Status"
    description: "Sum of total_queued_notification_id over selected source rows. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herschedules'" %}
        SUM(${her_schedules_total_queued_notification_id})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_schedules_total_printed_notification_id {
    type: number
    label: "Total Printed Notification Id"
    group_label: "HER Schedule Status"
    description: "HER Schedule Status: source field total_printed_notification_id. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql: ${TABLE}.her_schedules_total_printed_notification_id ;;
  }
  measure: her_schedules_total_printed_notification_id_sum {
    type: number
    label: "Total Printed Notification Id (Sum)"
    group_label: "HER Schedule Status"
    description: "Sum of total_printed_notification_id over selected source rows. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herschedules'" %}
        SUM(${her_schedules_total_printed_notification_id})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_schedules_total_mailed_notification_id {
    type: number
    label: "Total Mailed Notification Id"
    group_label: "HER Schedule Status"
    description: "HER Schedule Status: source field total_mailed_notification_id. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql: ${TABLE}.her_schedules_total_mailed_notification_id ;;
  }
  measure: her_schedules_total_mailed_notification_id_sum {
    type: number
    label: "Total Mailed Notification Id (Sum)"
    group_label: "HER Schedule Status"
    description: "Sum of total_mailed_notification_id over selected source rows. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herschedules'" %}
        SUM(${her_schedules_total_mailed_notification_id})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_schedules_total_failed_notification_id {
    type: number
    label: "Total Failed Notification Id"
    group_label: "HER Schedule Status"
    description: "HER Schedule Status: source field total_failed_notification_id. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql: ${TABLE}.her_schedules_total_failed_notification_id ;;
  }
  measure: her_schedules_total_failed_notification_id_sum {
    type: number
    label: "Total Failed Notification Id (Sum)"
    group_label: "HER Schedule Status"
    description: "Sum of total_failed_notification_id over selected source rows. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herschedules'" %}
        SUM(${her_schedules_total_failed_notification_id})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_schedules_total_swept_notification_id {
    type: number
    label: "Total Swept Notification Id"
    group_label: "HER Schedule Status"
    description: "HER Schedule Status: source field total_swept_notification_id. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql: ${TABLE}.her_schedules_total_swept_notification_id ;;
  }
  measure: her_schedules_total_swept_notification_id_sum {
    type: number
    label: "Total Swept Notification Id (Sum)"
    group_label: "HER Schedule Status"
    description: "Sum of total_swept_notification_id over selected source rows. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herschedules'" %}
        SUM(${her_schedules_total_swept_notification_id})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_failures_failure_count {
    type: number
    label: "Failure Count"
    group_label: "HER Generation Failures"
    description: "HER Generation Failures: source field failure_count. Pilot, cluster, schedule, fuel, reason and both analysis/reporting periods; ranking retains the original partition. NULL for other families."
    sql: ${TABLE}.her_failures_failure_count ;;
  }
  measure: her_failures_failure_count_sum {
    type: number
    label: "Failure Count (Sum)"
    group_label: "HER Generation Failures"
    description: "Sum of failure_count over selected source rows. Pilot, cluster, schedule, fuel, reason and both analysis/reporting periods; ranking retains the original partition. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herfailures'" %}
        SUM(${her_failures_failure_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_failures_total_failure_count {
    type: number
    label: "Total Failure Count"
    group_label: "HER Generation Failures"
    description: "HER Generation Failures: source field total_failure_count. Pilot, cluster, schedule, fuel, reason and both analysis/reporting periods; ranking retains the original partition. NULL for other families."
    sql: ${TABLE}.her_failures_total_failure_count ;;
  }
  dimension: her_failures_failure_percentage {
    type: number
    label: "Failure Percentage"
    group_label: "HER Generation Failures"
    description: "HER Generation Failures: source field failure_percentage. Pilot, cluster, schedule, fuel, reason and both analysis/reporting periods; ranking retains the original partition. NULL for other families."
    sql: ${TABLE}.her_failures_failure_percentage ;;
  }
  measure: her_failures_failure_percentage_average {
    type: number
    label: "Failure Percentage (Average)"
    group_label: "HER Generation Failures"
    description: "Arithmetic average of the source-provided failure_percentage; displayed without rescaling or weighting. Pilot, cluster, schedule, fuel, reason and both analysis/reporting periods; ranking retains the original partition. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herfailures'" %}
        AVG(${her_failures_failure_percentage})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: her_non_pseg_quality_low_bc_duration_count {
    type: number
    label: "Low BC Duration Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field low_bc_duration_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_low_bc_duration_count ;;
  }
  measure: her_non_pseg_quality_low_bc_duration_count_sum {
    type: number
    label: "Low BC Duration Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of low_bc_duration_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_low_bc_duration_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_high_bc_duration_count {
    type: number
    label: "High BC Duration Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field high_bc_duration_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_high_bc_duration_count ;;
  }
  measure: her_non_pseg_quality_high_bc_duration_count_sum {
    type: number
    label: "High BC Duration Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of high_bc_duration_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_high_bc_duration_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_staleness_count {
    type: number
    label: "Staleness Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field staleness_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_staleness_count ;;
  }
  measure: her_non_pseg_quality_staleness_count_sum {
    type: number
    label: "Staleness Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of staleness_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_staleness_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_solar_template_count {
    type: number
    label: "Solar Template Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field solar_template_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_solar_template_count ;;
  }
  measure: her_non_pseg_quality_solar_template_count_sum {
    type: number
    label: "Solar Template Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of solar_template_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_solar_template_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_solar_consistency_count {
    type: number
    label: "Solar Consistency Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field solar_consistency_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_solar_consistency_count ;;
  }
  measure: her_non_pseg_quality_solar_consistency_count_sum {
    type: number
    label: "Solar Consistency Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of solar_consistency_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_solar_consistency_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_solar_generation_count {
    type: number
    label: "Solar Generation Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field solar_generation_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_solar_generation_count ;;
  }
  measure: her_non_pseg_quality_solar_generation_count_sum {
    type: number
    label: "Solar Generation Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of solar_generation_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_solar_generation_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_report_consistency_count {
    type: number
    label: "Report Consistency Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field report_consistency_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_report_consistency_count ;;
  }
  measure: her_non_pseg_quality_report_consistency_count_sum {
    type: number
    label: "Report Consistency Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of report_consistency_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_report_consistency_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_itemization_count {
    type: number
    label: "Itemization Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field itemization_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_itemization_count ;;
  }
  measure: her_non_pseg_quality_itemization_count_sum {
    type: number
    label: "Itemization Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of itemization_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_itemization_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_bill_change_consistency_count {
    type: number
    label: "Bill Change Consistency Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field bill_change_consistency_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_bill_change_consistency_count ;;
  }
  measure: her_non_pseg_quality_bill_change_consistency_count_sum {
    type: number
    label: "Bill Change Consistency Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of bill_change_consistency_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_bill_change_consistency_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_ev_itemization_count {
    type: number
    label: "Ev Itemization Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field ev_itemization_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_ev_itemization_count ;;
  }
  measure: her_non_pseg_quality_ev_itemization_count_sum {
    type: number
    label: "Ev Itemization Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of ev_itemization_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_ev_itemization_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_tou_template_count {
    type: number
    label: "Tou Template Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field tou_template_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_tou_template_count ;;
  }
  measure: her_non_pseg_quality_tou_template_count_sum {
    type: number
    label: "Tou Template Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of tou_template_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_tou_template_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_nbi_occurance_count {
    type: number
    label: "NBI Occurance Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field nbi_occurance_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_nbi_occurance_count ;;
  }
  measure: her_non_pseg_quality_nbi_occurance_count_sum {
    type: number
    label: "NBI Occurance Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of nbi_occurance_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_nbi_occurance_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_nbi_value_count {
    type: number
    label: "NBI Value Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field nbi_value_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_nbi_value_count ;;
  }
  measure: her_non_pseg_quality_nbi_value_count_sum {
    type: number
    label: "NBI Value Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of nbi_value_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_nbi_value_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_nbi_appliance_itemisation_count {
    type: number
    label: "NBI Appliance Itemisation Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field nbi_appliance_itemisation_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_nbi_appliance_itemisation_count ;;
  }
  measure: her_non_pseg_quality_nbi_appliance_itemisation_count_sum {
    type: number
    label: "NBI Appliance Itemisation Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of nbi_appliance_itemisation_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_nbi_appliance_itemisation_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_nbi_non_null_insight_count {
    type: number
    label: "NBI Non Null Insight Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field nbi_non_null_insight_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_nbi_non_null_insight_count ;;
  }
  measure: her_non_pseg_quality_nbi_non_null_insight_count_sum {
    type: number
    label: "NBI Non Null Insight Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of nbi_non_null_insight_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_nbi_non_null_insight_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_nbi_unicode_count {
    type: number
    label: "NBI Unicode Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field nbi_unicode_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_nbi_unicode_count ;;
  }
  measure: her_non_pseg_quality_nbi_unicode_count_sum {
    type: number
    label: "NBI Unicode Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of nbi_unicode_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_nbi_unicode_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_non_pseg_quality_nbi_extreme_insight_count {
    type: number
    label: "NBI Extreme Insight Count"
    group_label: "HER Non-PSEG Quality"
    description: "HER Non-PSEG Quality: source field nbi_extreme_insight_count. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql: ${TABLE}.her_non_pseg_quality_nbi_extreme_insight_count ;;
  }
  measure: her_non_pseg_quality_nbi_extreme_insight_count_sum {
    type: number
    label: "NBI Extreme Insight Count (Sum)"
    group_label: "HER Non-PSEG Quality"
    description: "Sum of nbi_extreme_insight_count over selected source rows. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'hernonpsegquality'" %}
        SUM(${her_non_pseg_quality_nbi_extreme_insight_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_low_bc_duration_cnt {
    type: number
    label: "Low BC Duration Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field low_bc_duration_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_low_bc_duration_cnt ;;
  }
  measure: her_automation_quality_low_bc_duration_cnt_sum {
    type: number
    label: "Low BC Duration Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of low_bc_duration_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_low_bc_duration_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_high_bc_duration_cnt {
    type: number
    label: "High BC Duration Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field high_bc_duration_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_high_bc_duration_cnt ;;
  }
  measure: her_automation_quality_high_bc_duration_cnt_sum {
    type: number
    label: "High BC Duration Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of high_bc_duration_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_high_bc_duration_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_staleness_cnt {
    type: number
    label: "Staleness Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field staleness_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_staleness_cnt ;;
  }
  measure: her_automation_quality_staleness_cnt_sum {
    type: number
    label: "Staleness Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of staleness_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_staleness_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_solar_template_cnt {
    type: number
    label: "Solar Template Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field solar_template_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_solar_template_cnt ;;
  }
  measure: her_automation_quality_solar_template_cnt_sum {
    type: number
    label: "Solar Template Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of solar_template_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_solar_template_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_solar_consistency_cnt {
    type: number
    label: "Solar Consistency Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field solar_consistency_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_solar_consistency_cnt ;;
  }
  measure: her_automation_quality_solar_consistency_cnt_sum {
    type: number
    label: "Solar Consistency Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of solar_consistency_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_solar_consistency_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_solar_generation_cnt {
    type: number
    label: "Solar Generation Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field solar_generation_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_solar_generation_cnt ;;
  }
  measure: her_automation_quality_solar_generation_cnt_sum {
    type: number
    label: "Solar Generation Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of solar_generation_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_solar_generation_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_report_consistency_cnt {
    type: number
    label: "Report Consistency Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field report_consistency_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_report_consistency_cnt ;;
  }
  measure: her_automation_quality_report_consistency_cnt_sum {
    type: number
    label: "Report Consistency Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of report_consistency_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_report_consistency_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_itemization_cnt {
    type: number
    label: "Itemization Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field itemization_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_itemization_cnt ;;
  }
  measure: her_automation_quality_itemization_cnt_sum {
    type: number
    label: "Itemization Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of itemization_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_itemization_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_bill_change_consistency_cnt {
    type: number
    label: "Bill Change Consistency Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field bill_change_consistency_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_bill_change_consistency_cnt ;;
  }
  measure: her_automation_quality_bill_change_consistency_cnt_sum {
    type: number
    label: "Bill Change Consistency Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of bill_change_consistency_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_bill_change_consistency_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_ev_itemization_cnt {
    type: number
    label: "Ev Itemization Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field ev_itemization_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_ev_itemization_cnt ;;
  }
  measure: her_automation_quality_ev_itemization_cnt_sum {
    type: number
    label: "Ev Itemization Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of ev_itemization_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_ev_itemization_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_tou_template_cnt {
    type: number
    label: "Tou Template Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field tou_template_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_tou_template_cnt ;;
  }
  measure: her_automation_quality_tou_template_cnt_sum {
    type: number
    label: "Tou Template Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of tou_template_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_tou_template_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_nbi_occurence_cnt {
    type: number
    label: "NBI Occurence Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field nbi_occurence_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_nbi_occurence_cnt ;;
  }
  measure: her_automation_quality_nbi_occurence_cnt_sum {
    type: number
    label: "NBI Occurence Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of nbi_occurence_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_nbi_occurence_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_nbi_value_cnt {
    type: number
    label: "NBI Value Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field nbi_value_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_nbi_value_cnt ;;
  }
  measure: her_automation_quality_nbi_value_cnt_sum {
    type: number
    label: "NBI Value Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of nbi_value_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_nbi_value_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_nbi_appliance_itemization_cnt {
    type: number
    label: "NBI Appliance Itemization Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field nbi_appliance_itemization_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_nbi_appliance_itemization_cnt ;;
  }
  measure: her_automation_quality_nbi_appliance_itemization_cnt_sum {
    type: number
    label: "NBI Appliance Itemization Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of nbi_appliance_itemization_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_nbi_appliance_itemization_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_nbi_non_null_insight_cnt {
    type: number
    label: "NBI Non Null Insight Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field nbi_non_null_insight_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_nbi_non_null_insight_cnt ;;
  }
  measure: her_automation_quality_nbi_non_null_insight_cnt_sum {
    type: number
    label: "NBI Non Null Insight Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of nbi_non_null_insight_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_nbi_non_null_insight_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_nbi_unicode_cnt {
    type: number
    label: "NBI Unicode Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field nbi_unicode_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_nbi_unicode_cnt ;;
  }
  measure: her_automation_quality_nbi_unicode_cnt_sum {
    type: number
    label: "NBI Unicode Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of nbi_unicode_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_nbi_unicode_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_nbi_extreme_insight_cnt {
    type: number
    label: "NBI Extreme Insight Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field nbi_extreme_insight_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_nbi_extreme_insight_cnt ;;
  }
  measure: her_automation_quality_nbi_extreme_insight_cnt_sum {
    type: number
    label: "NBI Extreme Insight Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of nbi_extreme_insight_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_nbi_extreme_insight_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_nbi_seasonal_appliance_cnt {
    type: number
    label: "NBI Seasonal Appliance Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field nbi_seasonal_appliance_cnt. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_nbi_seasonal_appliance_cnt ;;
  }
  measure: her_automation_quality_nbi_seasonal_appliance_cnt_sum {
    type: number
    label: "NBI Seasonal Appliance Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of nbi_seasonal_appliance_cnt over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_nbi_seasonal_appliance_cnt})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: her_automation_quality_overall_report_count {
    type: number
    label: "Overall Report Count"
    group_label: "HER Automation Quality"
    description: "HER Automation Quality: source field overall_report_count. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql: ${TABLE}.her_automation_quality_overall_report_count ;;
  }
  measure: her_automation_quality_overall_report_count_sum {
    type: number
    label: "Overall Report Count (Sum)"
    group_label: "HER Automation Quality"
    description: "Sum of overall_report_count over selected source rows. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'herautomationquality'" %}
        SUM(${her_automation_quality_overall_report_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: nbi_generation_total_users_successful {
    type: number
    label: "Total Users Successful"
    group_label: "NBI Generation"
    description: "NBI Generation: source field total_users_successful. Original pilot and analysis/reporting date rows with generation and error counts. NULL for other families."
    sql: ${TABLE}.nbi_generation_total_users_successful ;;
  }
  measure: nbi_generation_total_users_successful_sum {
    type: number
    label: "Total Users Successful (Sum)"
    group_label: "NBI Generation"
    description: "Sum of total_users_successful over selected source rows. Original pilot and analysis/reporting date rows with generation and error counts. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'nbigeneration'" %}
        SUM(${nbi_generation_total_users_successful})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: nbi_generation_total_users_with_200_errorcode {
    type: number
    label: "Total Users With 200 Errorcode"
    group_label: "NBI Generation"
    description: "NBI Generation: source field total_users_with_200_errorcode. Original pilot and analysis/reporting date rows with generation and error counts. NULL for other families."
    sql: ${TABLE}.nbi_generation_total_users_with_200_errorcode ;;
  }
  measure: nbi_generation_total_users_with_200_errorcode_sum {
    type: number
    label: "Total Users With 200 Errorcode (Sum)"
    group_label: "NBI Generation"
    description: "Sum of total_users_with_200_errorcode over selected source rows. Original pilot and analysis/reporting date rows with generation and error counts. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'nbigeneration'" %}
        SUM(${nbi_generation_total_users_with_200_errorcode})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: nbi_generation_total_users_with_300_errorcode {
    type: number
    label: "Total Users With 300 Errorcode"
    group_label: "NBI Generation"
    description: "NBI Generation: source field total_users_with_300_errorcode. Original pilot and analysis/reporting date rows with generation and error counts. NULL for other families."
    sql: ${TABLE}.nbi_generation_total_users_with_300_errorcode ;;
  }
  measure: nbi_generation_total_users_with_300_errorcode_sum {
    type: number
    label: "Total Users With 300 Errorcode (Sum)"
    group_label: "NBI Generation"
    description: "Sum of total_users_with_300_errorcode over selected source rows. Original pilot and analysis/reporting date rows with generation and error counts. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'nbigeneration'" %}
        SUM(${nbi_generation_total_users_with_300_errorcode})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: nbi_generation_nbi_error_pct {
    type: number
    label: "NBI Error Percentage"
    group_label: "NBI Generation"
    description: "NBI Generation: source field nbi_error_pct. Original pilot and analysis/reporting date rows with generation and error counts. NULL for other families."
    sql: ${TABLE}.nbi_generation_nbi_error_pct ;;
  }
  measure: nbi_generation_nbi_error_pct_average {
    type: number
    label: "NBI Error Percentage (Average)"
    group_label: "NBI Generation"
    description: "Arithmetic average of the source-provided nbi_error_pct; displayed without rescaling or weighting. Original pilot and analysis/reporting date rows with generation and error counts. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'nbigeneration'" %}
        AVG(${nbi_generation_nbi_error_pct})
      {% else %} CAST(NULL AS DECIMAL(26, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: nbi_generic_tags_total_nbi_users {
    type: number
    label: "Total NBI Users"
    group_label: "NBI Generic Tags"
    description: "NBI Generic Tags: source field total_nbi_users. Original pilot and analysis/reporting date rows with generic-tag counts and supplied percentage. NULL for other families."
    sql: ${TABLE}.nbi_generic_tags_total_nbi_users ;;
  }
  measure: nbi_generic_tags_total_nbi_users_sum {
    type: number
    label: "Total NBI Users (Sum)"
    group_label: "NBI Generic Tags"
    description: "Sum of total_nbi_users over selected source rows. Original pilot and analysis/reporting date rows with generic-tag counts and supplied percentage. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'nbigenerictags'" %}
        SUM(${nbi_generic_tags_total_nbi_users})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: nbi_generic_tags_total_nbi_users_with_generic_tag {
    type: number
    label: "Total NBI Users With Generic Tag"
    group_label: "NBI Generic Tags"
    description: "NBI Generic Tags: source field total_nbi_users_with_generic_tag. Original pilot and analysis/reporting date rows with generic-tag counts and supplied percentage. NULL for other families."
    sql: ${TABLE}.nbi_generic_tags_total_nbi_users_with_generic_tag ;;
  }
  measure: nbi_generic_tags_total_nbi_users_with_generic_tag_sum {
    type: number
    label: "Total NBI Users With Generic Tag (Sum)"
    group_label: "NBI Generic Tags"
    description: "Sum of total_nbi_users_with_generic_tag over selected source rows. Original pilot and analysis/reporting date rows with generic-tag counts and supplied percentage. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'nbigenerictags'" %}
        SUM(${nbi_generic_tags_total_nbi_users_with_generic_tag})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: nbi_generic_tags_pct_users_with_generic_tag {
    type: number
    label: "Percentage Users With Generic Tag"
    group_label: "NBI Generic Tags"
    description: "NBI Generic Tags: source field pct_users_with_generic_tag. Original pilot and analysis/reporting date rows with generic-tag counts and supplied percentage. NULL for other families."
    sql: ${TABLE}.nbi_generic_tags_pct_users_with_generic_tag ;;
  }
  measure: nbi_generic_tags_pct_users_with_generic_tag_average {
    type: number
    label: "Percentage Users With Generic Tag (Average)"
    group_label: "NBI Generic Tags"
    description: "Arithmetic average of the source-provided pct_users_with_generic_tag; displayed without rescaling or weighting. Original pilot and analysis/reporting date rows with generic-tag counts and supplied percentage. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'nbigenerictags'" %}
        AVG(${nbi_generic_tags_pct_users_with_generic_tag})
      {% else %} CAST(NULL AS DECIMAL(26, 2))
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: billing_length_bc_1_15_count {
    type: number
    label: "BC 1 15 Count"
    group_label: "Billing-Cycle Length"
    description: "Billing-Cycle Length: source field bc_1_15_count. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. NULL for other families."
    sql: ${TABLE}.billing_length_bc_1_15_count ;;
  }
  measure: billing_length_bc_1_15_count_sum {
    type: number
    label: "BC 1 15 Count (Sum)"
    group_label: "Billing-Cycle Length"
    description: "Sum of bc_1_15_count over selected source rows. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'billinglength'" %}
        SUM(${billing_length_bc_1_15_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: billing_length_bc_15_30_count {
    type: number
    label: "BC 15 30 Count"
    group_label: "Billing-Cycle Length"
    description: "Billing-Cycle Length: source field bc_15_30_count. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. NULL for other families."
    sql: ${TABLE}.billing_length_bc_15_30_count ;;
  }
  measure: billing_length_bc_15_30_count_sum {
    type: number
    label: "BC 15 30 Count (Sum)"
    group_label: "Billing-Cycle Length"
    description: "Sum of bc_15_30_count over selected source rows. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'billinglength'" %}
        SUM(${billing_length_bc_15_30_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: billing_length_bc_31_45_count {
    type: number
    label: "BC 31 45 Count"
    group_label: "Billing-Cycle Length"
    description: "Billing-Cycle Length: source field bc_31_45_count. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. NULL for other families."
    sql: ${TABLE}.billing_length_bc_31_45_count ;;
  }
  measure: billing_length_bc_31_45_count_sum {
    type: number
    label: "BC 31 45 Count (Sum)"
    group_label: "Billing-Cycle Length"
    description: "Sum of bc_31_45_count over selected source rows. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'billinglength'" %}
        SUM(${billing_length_bc_31_45_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: billing_length_bc_45_60_count {
    type: number
    label: "BC 45 60 Count"
    group_label: "Billing-Cycle Length"
    description: "Billing-Cycle Length: source field bc_45_60_count. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. NULL for other families."
    sql: ${TABLE}.billing_length_bc_45_60_count ;;
  }
  measure: billing_length_bc_45_60_count_sum {
    type: number
    label: "BC 45 60 Count (Sum)"
    group_label: "Billing-Cycle Length"
    description: "Sum of bc_45_60_count over selected source rows. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'billinglength'" %}
        SUM(${billing_length_bc_45_60_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: billing_length_bc_61_75_count {
    type: number
    label: "BC 61 75 Count"
    group_label: "Billing-Cycle Length"
    description: "Billing-Cycle Length: source field bc_61_75_count. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. NULL for other families."
    sql: ${TABLE}.billing_length_bc_61_75_count ;;
  }
  measure: billing_length_bc_61_75_count_sum {
    type: number
    label: "BC 61 75 Count (Sum)"
    group_label: "Billing-Cycle Length"
    description: "Sum of bc_61_75_count over selected source rows. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'billinglength'" %}
        SUM(${billing_length_bc_61_75_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: billing_length_bc_76_90_count {
    type: number
    label: "BC 76 90 Count"
    group_label: "Billing-Cycle Length"
    description: "Billing-Cycle Length: source field bc_76_90_count. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. NULL for other families."
    sql: ${TABLE}.billing_length_bc_76_90_count ;;
  }
  measure: billing_length_bc_76_90_count_sum {
    type: number
    label: "BC 76 90 Count (Sum)"
    group_label: "Billing-Cycle Length"
    description: "Sum of bc_76_90_count over selected source rows. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'billinglength'" %}
        SUM(${billing_length_bc_76_90_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: billing_length_bc_gt_90_count {
    type: number
    label: "BC Gt 90 Count"
    group_label: "Billing-Cycle Length"
    description: "Billing-Cycle Length: source field bc_gt_90_count. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. NULL for other families."
    sql: ${TABLE}.billing_length_bc_gt_90_count ;;
  }
  measure: billing_length_bc_gt_90_count_sum {
    type: number
    label: "BC Gt 90 Count (Sum)"
    group_label: "Billing-Cycle Length"
    description: "Sum of bc_gt_90_count over selected source rows. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. NULL for other families."
    sql:
      {% if source_family._parameter_value == "'billinglength'" %}
        SUM(${billing_length_bc_gt_90_count})
      {% else %} CAST(NULL AS BIGINT)
      {% endif %} ;;
    value_format: "#,##0"
  }

  # Ingestion dashboard calculations. All are evaluated at query time.
  dimension: ingestion_file_type {
    type: string
    description: "Dashboard File Type: Billing includes BILLING and OPOWER; other source values remain available."
    group_label: "Ingestion Dashboard"
    label: "File Type"
    suggest_explore: bre_ingestion_filter_values
    suggest_dimension: bre_ingestion_filter_values.file_type
    sql: CASE WHEN ${ingestion_type} IN ('BILLING', 'OPOWER') THEN 'Billing' WHEN ${ingestion_type} = 'CONSUMPTION' THEN 'Consumption' WHEN ${ingestion_type} = 'USER_META' THEN 'User_Meta' ELSE ${ingestion_type} END ;;
  }
  dimension: ingestion_period_date {
    type: date
    description: "Analysis date grouped by Period for Ingestion. Weeks begin Sunday; legacy source period logic is unchanged."
    group_label: "Ingestion Dashboard"
    label: "Period"
    convert_tz: no
    sql: {% if period._parameter_value == "'Weekly'" %}
        CAST(date_add('day', -1, CAST(date_trunc('week', date_add('day', 1, ${analysis_date::date})) AS DATE)) AS DATE)
      {% elsif period._parameter_value == "'Monthly'" %}
        CAST(date_trunc('month', ${analysis_date::date}) AS DATE)
      {% else %} ${analysis_date::date}
      {% endif %} ;;
  }
  dimension: disagg_period_date {
    type: date
    label: "Analysis Date"
    group_label: "Disagg Dashboard"
    description: "Analysis date grouped by the Daily, Weekly or Monthly Period selection. Reuses the shared Sunday-start calendar; reporting-date filtering is independent."
    convert_tz: no
    sql: ${ingestion_period_date::date} ;;
  }
  dimension: email_period_date {
    type: date
    label: "Analysis Date"
    group_label: "Email Dashboard"
    description: "Analysis date grouped by the selected Daily, Weekly or Monthly Period. Reuses the shared Sunday-start calendar."
    convert_tz: no
    sql: ${ingestion_period_date::date} ;;
  }
  filter: ingestion_comparison_date_range {
    type: date
    label: "Files Comparison Date Range"
    description: "Selected calendar-date range. Files measures retain the preceding equal-length range. Open-ended ranges have no previous-period comparison."
  }
  dimension: ingestion_comparison_start {
    type: date
    description: "Inclusive selected range start; NULL for an unbounded start."
    group_label: "Ingestion Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_start ingestion_comparison_date_range %} AS DATE) ;;
  }
  dimension: ingestion_comparison_end {
    type: date
    description: "Exclusive selected range end; NULL for an unbounded end."
    group_label: "Ingestion Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_end ingestion_comparison_date_range %} AS DATE) ;;
  }
  # A templated date condition must compare DATE/TIMESTAMP values, not display strings.
  dimension: ingestion_is_selected_period {
    type: yesno
    description: "Matches the selected date filter, without removing prior rows from comparison queries."
    group_label: "Ingestion Dashboard"
    hidden: yes
    sql: {% condition ingestion_comparison_date_range %} ${analysis_date::date} {% endcondition %} ;;
  }
  dimension: ingestion_is_previous_period {
    type: yesno
    description: "Immediately preceding equal-length calendar range; false if either boundary is absent."
    group_label: "Ingestion Dashboard"
    hidden: yes
    sql: COALESCE(
      ${ingestion_comparison_end::date} > ${ingestion_comparison_start::date}
      AND ${analysis_date::date} >= date_add('day', -date_diff('day', ${ingestion_comparison_start::date}, ${ingestion_comparison_end::date}), ${ingestion_comparison_start::date})
      AND ${analysis_date::date} < ${ingestion_comparison_start::date}, FALSE) ;;
  }
  dimension: ingestion_in_comparison_window {
    type: yesno
    description: "Keep current and previous rows before calculating the two file statistics."
    group_label: "Ingestion Dashboard"
    hidden: yes
    sql: ${ingestion_is_selected_period} OR ${ingestion_is_previous_period} ;;
  }
  dimension: ingestion_audit_files_selected {
    type: number
    description: "File count for the selected comparison period; other rows are NULL."
    group_label: "Ingestion Dashboard"
    hidden: yes
    sql: CASE WHEN ${ingestion_is_selected_period} THEN ${ingestion_audit_total_files_processed} END ;;
  }
  measure: ingestion_audit_files_selected_average {
    type: number
    label: "Files — Selected Average"
    group_label: "Ingestion Dashboard"
    description: "Unweighted average of source total_files_processed within this comparison range."
    sql:
      {% if source_family._parameter_value == "'ingestionaudit'" %}
        AVG(${ingestion_audit_files_selected})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  measure: ingestion_audit_files_selected_median {
    type: number
    label: "Files — Selected Median"
    group_label: "Ingestion Dashboard"
    description: "Exact median of source file counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      {% if source_family._parameter_value == "'ingestionaudit'" %}
        CASE WHEN COUNT(${ingestion_audit_files_selected}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${ingestion_audit_files_selected} AS DOUBLE)) FILTER (WHERE ${ingestion_audit_files_selected} IS NOT NULL)), CAST(floor((COUNT(${ingestion_audit_files_selected}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${ingestion_audit_files_selected} AS DOUBLE)) FILTER (WHERE ${ingestion_audit_files_selected} IS NOT NULL)), CAST(floor((COUNT(${ingestion_audit_files_selected}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: ingestion_audit_files_previous {
    type: number
    description: "File count for the previous comparison period; other rows are NULL."
    group_label: "Ingestion Dashboard"
    hidden: yes
    sql: CASE WHEN ${ingestion_is_previous_period} THEN ${ingestion_audit_total_files_processed} END ;;
  }
  measure: ingestion_audit_files_previous_average {
    type: number
    label: "Files — Previous Average"
    group_label: "Ingestion Dashboard"
    description: "Unweighted average of source total_files_processed within this comparison range."
    sql:
      {% if source_family._parameter_value == "'ingestionaudit'" %}
        AVG(${ingestion_audit_files_previous})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  measure: ingestion_audit_files_previous_median {
    type: number
    label: "Files — Previous Median"
    group_label: "Ingestion Dashboard"
    description: "Exact median of source file counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      {% if source_family._parameter_value == "'ingestionaudit'" %}
        CASE WHEN COUNT(${ingestion_audit_files_previous}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${ingestion_audit_files_previous} AS DOUBLE)) FILTER (WHERE ${ingestion_audit_files_previous} IS NOT NULL)), CAST(floor((COUNT(${ingestion_audit_files_previous}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${ingestion_audit_files_previous} AS DOUBLE)) FILTER (WHERE ${ingestion_audit_files_previous} IS NOT NULL)), CAST(floor((COUNT(${ingestion_audit_files_previous}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  measure: ingestion_audit_files_average_change {
    type: number
    label: "Files Average Change"
    group_label: "Ingestion Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      {% if source_family._parameter_value == "'ingestionaudit'" %}
        (${ingestion_audit_files_selected_average} - ${ingestion_audit_files_previous_average}) / NULLIF(${ingestion_audit_files_previous_average}, 0)
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "0.0%"
  }
  measure: ingestion_audit_files_median_change {
    type: number
    label: "Files Median Change"
    group_label: "Ingestion Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      {% if source_family._parameter_value == "'ingestionaudit'" %}
        (${ingestion_audit_files_selected_median} - ${ingestion_audit_files_previous_median}) / NULLIF(${ingestion_audit_files_previous_median}, 0)
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "0.0%"
  }
  filter: invoice_comparison_date_range {
    type: date
    label: "Invoices Comparison Date Range"
    description: "Selected calendar-date range. Invoices measures retain the preceding equal-length range. Open-ended ranges have no previous-period comparison."
  }
  dimension: invoice_comparison_start {
    type: date
    description: "Inclusive selected range start; NULL for an unbounded start."
    group_label: "Disagg Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_start invoice_comparison_date_range %} AS DATE) ;;
  }
  dimension: invoice_comparison_end {
    type: date
    description: "Exclusive selected range end; NULL for an unbounded end."
    group_label: "Disagg Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_end invoice_comparison_date_range %} AS DATE) ;;
  }
  # A templated date condition must compare DATE/TIMESTAMP values, not display strings.
  dimension: invoice_is_selected_period {
    type: yesno
    description: "Matches the selected date filter, without removing prior rows from comparison queries."
    group_label: "Disagg Dashboard"
    hidden: yes
    sql: {% condition invoice_comparison_date_range %} ${reporting_date::date} {% endcondition %} ;;
  }
  dimension: invoice_is_previous_period {
    type: yesno
    description: "Immediately preceding equal-length calendar range; false if either boundary is absent."
    group_label: "Disagg Dashboard"
    hidden: yes
    sql: COALESCE(
      ${invoice_comparison_end::date} > ${invoice_comparison_start::date}
      AND ${reporting_date::date} >= date_add('day', -date_diff('day', ${invoice_comparison_start::date}, ${invoice_comparison_end::date}), ${invoice_comparison_start::date})
      AND ${reporting_date::date} < ${invoice_comparison_start::date}, FALSE) ;;
  }
  dimension: invoice_in_comparison_window {
    type: yesno
    description: "Keep current and previous rows before calculating the two invoice statistics."
    group_label: "Disagg Dashboard"
    hidden: yes
    sql: ${invoice_is_selected_period} OR ${invoice_is_previous_period} ;;
  }
  dimension: invoice_statistics_invoices_selected {
    type: number
    description: "Invoice count for the selected comparison period; other rows are NULL."
    group_label: "Disagg Dashboard"
    hidden: yes
    sql: CASE WHEN ${invoice_is_selected_period} THEN ${invoice_statistics_total_invoices} END ;;
  }
  measure: invoice_statistics_invoices_selected_average {
    type: number
    label: "Invoices — Selected Average"
    group_label: "Disagg Dashboard"
    description: "Unweighted average of source total_invoices within this comparison range."
    sql:
      {% if source_family._parameter_value == "'invoicestatistics'" %}
        AVG(${invoice_statistics_invoices_selected})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  measure: invoice_statistics_invoices_selected_median {
    type: number
    label: "Invoices — Selected Median"
    group_label: "Disagg Dashboard"
    description: "Exact median of source invoice counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      {% if source_family._parameter_value == "'invoicestatistics'" %}
        CASE WHEN COUNT(${invoice_statistics_invoices_selected}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${invoice_statistics_invoices_selected} AS DOUBLE)) FILTER (WHERE ${invoice_statistics_invoices_selected} IS NOT NULL)), CAST(floor((COUNT(${invoice_statistics_invoices_selected}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${invoice_statistics_invoices_selected} AS DOUBLE)) FILTER (WHERE ${invoice_statistics_invoices_selected} IS NOT NULL)), CAST(floor((COUNT(${invoice_statistics_invoices_selected}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: invoice_statistics_invoices_previous {
    type: number
    description: "Invoice count for the previous comparison period; other rows are NULL."
    group_label: "Disagg Dashboard"
    hidden: yes
    sql: CASE WHEN ${invoice_is_previous_period} THEN ${invoice_statistics_total_invoices} END ;;
  }
  measure: invoice_statistics_invoices_previous_average {
    type: number
    label: "Invoices — Previous Average"
    group_label: "Disagg Dashboard"
    description: "Unweighted average of source total_invoices within this comparison range."
    sql:
      {% if source_family._parameter_value == "'invoicestatistics'" %}
        AVG(${invoice_statistics_invoices_previous})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  measure: invoice_statistics_invoices_previous_median {
    type: number
    label: "Invoices — Previous Median"
    group_label: "Disagg Dashboard"
    description: "Exact median of source invoice counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      {% if source_family._parameter_value == "'invoicestatistics'" %}
        CASE WHEN COUNT(${invoice_statistics_invoices_previous}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${invoice_statistics_invoices_previous} AS DOUBLE)) FILTER (WHERE ${invoice_statistics_invoices_previous} IS NOT NULL)), CAST(floor((COUNT(${invoice_statistics_invoices_previous}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${invoice_statistics_invoices_previous} AS DOUBLE)) FILTER (WHERE ${invoice_statistics_invoices_previous} IS NOT NULL)), CAST(floor((COUNT(${invoice_statistics_invoices_previous}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  measure: invoice_statistics_invoices_average_change {
    type: number
    label: "Invoices Average Change"
    group_label: "Disagg Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      {% if source_family._parameter_value == "'invoicestatistics'" %}
        (${invoice_statistics_invoices_selected_average} - ${invoice_statistics_invoices_previous_average}) / NULLIF(${invoice_statistics_invoices_previous_average}, 0)
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "0.0%"
  }
  measure: invoice_statistics_invoices_median_change {
    type: number
    label: "Invoices Median Change"
    group_label: "Disagg Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      {% if source_family._parameter_value == "'invoicestatistics'" %}
        (${invoice_statistics_invoices_selected_median} - ${invoice_statistics_invoices_previous_median}) / NULLIF(${invoice_statistics_invoices_previous_median}, 0)
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "0.0%"
  }
  filter: email_comparison_date_range {
    type: date
    label: "Emails Sent Comparison Date Range"
    description: "Selected calendar-date range. Emails Sent measures retain the preceding equal-length range. Open-ended ranges have no previous-period comparison."
  }
  dimension: email_comparison_start {
    type: date
    description: "Inclusive selected range start; NULL for an unbounded start."
    group_label: "Email Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_start email_comparison_date_range %} AS DATE) ;;
  }
  dimension: email_comparison_end {
    type: date
    description: "Exclusive selected range end; NULL for an unbounded end."
    group_label: "Email Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_end email_comparison_date_range %} AS DATE) ;;
  }
  # A templated date condition must compare DATE/TIMESTAMP values, not display strings.
  dimension: email_is_selected_period {
    type: yesno
    description: "Matches the selected date filter, without removing prior rows from comparison queries."
    group_label: "Email Dashboard"
    hidden: yes
    sql: {% condition email_comparison_date_range %} ${reporting_date::date} {% endcondition %} ;;
  }
  dimension: email_is_previous_period {
    type: yesno
    description: "Immediately preceding equal-length calendar range; false if either boundary is absent."
    group_label: "Email Dashboard"
    hidden: yes
    sql: COALESCE(
      ${email_comparison_end::date} > ${email_comparison_start::date}
      AND ${reporting_date::date} >= date_add('day', -date_diff('day', ${email_comparison_start::date}, ${email_comparison_end::date}), ${email_comparison_start::date})
      AND ${reporting_date::date} < ${email_comparison_start::date}, FALSE) ;;
  }
  dimension: email_in_comparison_window {
    type: yesno
    description: "Keep current and previous rows before calculating the two email statistics."
    group_label: "Email Dashboard"
    hidden: yes
    sql: ${email_is_selected_period} OR ${email_is_previous_period} ;;
  }
  dimension: email_statistics_emails_selected {
    type: number
    description: "Emails-sent count for the selected comparison period; other rows are NULL."
    group_label: "Email Dashboard"
    hidden: yes
    sql: CASE WHEN ${email_is_selected_period} THEN ${email_statistics_cnt_bills_emails_sent} END ;;
  }
  measure: email_statistics_emails_selected_average {
    type: number
    label: "Emails Sent — Selected Average"
    group_label: "Email Dashboard"
    description: "Unweighted average of source cnt_bills_emails_sent within this comparison range."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        AVG(${email_statistics_emails_selected})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  measure: email_statistics_emails_selected_median {
    type: number
    label: "Emails Sent — Selected Median"
    group_label: "Email Dashboard"
    description: "Exact median of source emails-sent counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        CASE WHEN COUNT(${email_statistics_emails_selected}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${email_statistics_emails_selected} AS DOUBLE)) FILTER (WHERE ${email_statistics_emails_selected} IS NOT NULL)), CAST(floor((COUNT(${email_statistics_emails_selected}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${email_statistics_emails_selected} AS DOUBLE)) FILTER (WHERE ${email_statistics_emails_selected} IS NOT NULL)), CAST(floor((COUNT(${email_statistics_emails_selected}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  dimension: email_statistics_emails_previous {
    type: number
    description: "Emails-sent count for the previous comparison period; other rows are NULL."
    group_label: "Email Dashboard"
    hidden: yes
    sql: CASE WHEN ${email_is_previous_period} THEN ${email_statistics_cnt_bills_emails_sent} END ;;
  }
  measure: email_statistics_emails_previous_average {
    type: number
    label: "Emails Sent — Previous Average"
    group_label: "Email Dashboard"
    description: "Unweighted average of source cnt_bills_emails_sent within this comparison range."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        AVG(${email_statistics_emails_previous})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  measure: email_statistics_emails_previous_median {
    type: number
    label: "Emails Sent — Previous Median"
    group_label: "Email Dashboard"
    description: "Exact median of source emails-sent counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        CASE WHEN COUNT(${email_statistics_emails_previous}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${email_statistics_emails_previous} AS DOUBLE)) FILTER (WHERE ${email_statistics_emails_previous} IS NOT NULL)), CAST(floor((COUNT(${email_statistics_emails_previous}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${email_statistics_emails_previous} AS DOUBLE)) FILTER (WHERE ${email_statistics_emails_previous} IS NOT NULL)), CAST(floor((COUNT(${email_statistics_emails_previous}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0.00"
  }
  measure: email_statistics_emails_average_change {
    type: number
    label: "Emails Sent Average Change"
    group_label: "Email Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        (${email_statistics_emails_selected_average} - ${email_statistics_emails_previous_average}) / NULLIF(${email_statistics_emails_previous_average}, 0)
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "0.0%"
  }
  measure: email_statistics_emails_median_change {
    type: number
    label: "Emails Sent Median Change"
    group_label: "Email Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      {% if source_family._parameter_value == "'emailstatistics'" %}
        (${email_statistics_emails_selected_median} - ${email_statistics_emails_previous_median}) / NULLIF(${email_statistics_emails_previous_median}, 0)
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "0.0%"
  }
  dimension: post_ingestion_users_receiving_raw {
    type: number
    description: "Row-level raw bucket sum. Any zero or NULL bucket makes this total NULL; no day denominator."
    group_label: "Ingestion Dashboard"
    hidden: yes
    sql: NULLIF(${post_ingestion_user_raw_with_delay_0_3}, 0) + NULLIF(${post_ingestion_user_raw_with_delay_4_7}, 0) + NULLIF(${post_ingestion_user_raw_with_delay_8_15}, 0) + NULLIF(${post_ingestion_user_raw_with_delay_gt_15}, 0) ;;
  }
  measure: post_ingestion_users_receiving_raw_sum {
    type: number
    label: "Total Users Receiving Raw Data"
    group_label: "Ingestion Dashboard"
    description: "Sum of the row-level NULLIF bucket calculation; not a distinct-user count over the period."
    sql:
      {% if source_family._parameter_value == "'postingestion'" %}
        SUM(${post_ingestion_users_receiving_raw})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: post_ingestion_users_receiving_invoice {
    type: number
    description: "Row-level invoice bucket sum. Any zero or NULL bucket makes this total NULL; no day denominator."
    group_label: "Ingestion Dashboard"
    hidden: yes
    sql: NULLIF(${post_ingestion_user_invoice_with_delay_0_7}, 0) + NULLIF(${post_ingestion_user_invoice_with_delay_7_15}, 0) + NULLIF(${post_ingestion_user_invoice_with_delay_15_30}, 0) + NULLIF(${post_ingestion_user_invoice_with_delay_gt_30}, 0) ;;
  }
  measure: post_ingestion_users_receiving_invoice_sum {
    type: number
    label: "Total Users Receiving Invoice Data"
    group_label: "Ingestion Dashboard"
    description: "Sum of the row-level NULLIF bucket calculation; not a distinct-user count over the period."
    sql:
      {% if source_family._parameter_value == "'postingestion'" %}
        SUM(${post_ingestion_users_receiving_invoice})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0"
  }
  dimension: post_ingestion_users_per_day_millions {
    type: number
    description: "Row-level raw total for CONSUMPTION or invoice total for BILLING/OPOWER, in millions. Other types return NULL."
    group_label: "Ingestion Dashboard"
    hidden: yes
    sql: CASE WHEN ${ingestion_type} = 'CONSUMPTION' THEN ${post_ingestion_users_receiving_raw} / 1000000.0 WHEN ${ingestion_type} IN ('BILLING', 'OPOWER') THEN ${post_ingestion_users_receiving_invoice} / 1000000.0 END ;;
  }
  measure: post_ingestion_users_per_day_millions_average {
    type: number
    label: "Users (M)/day"
    group_label: "Ingestion Dashboard"
    description: "Unweighted average of the row-level users calculation in millions. Preserves NULLIF omissions; OPOWER uses invoice buckets."
    sql:
      {% if source_family._parameter_value == "'postingestion'" %}
        AVG(${post_ingestion_users_per_day_millions})
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "0.000"
  }
  measure: active_users_uuid_summary {
    type: number
    label: "Active UUID out of Total UUID"
    group_label: "Ingestion Dashboard"
    description: "Latest snapshot active and total UUID counts for selected pilots. Only pilot controls affect this tile."
    sql:
      {% if source_family._parameter_value == "'activeusers'" %}
        ${active_users_active_uuid_sum}
      {% else %} CAST(NULL AS DOUBLE)
      {% endif %} ;;
    value_format: "#,##0"
    html: Active UUID: {{ rendered_value }} out of Total UUID: {{ bre_dashboard.active_users_total_uuid_sum._rendered_value }} ;;
  }

  set: common {
    fields: [
      disagg_period_date,
      email_period_date,
      ingestion_file_type,
      ingestion_period_date,
      ingestion_comparison_date_range,
      ingestion_comparison_start,
      ingestion_comparison_end,
      ingestion_is_selected_period,
      ingestion_is_previous_period,
      ingestion_in_comparison_window,
      pilot_id,
      pilot_name,
      pilot_id_name,
      time_zone,
      analysis_date,
      reporting_date,
      last_updated_timestamp,
      source_analysis_value,
      source_reporting_value,
      source_pilot_name,
      source_period,
      source_rank,
      ingestion_type,
      meter_type,
      fuel_type,
      module_name,
      email_type,
      bc_end_week_number,
      cluster_id,
      schedule_start,
      schedule_end,
      appliance_name,
      metric_name,
      application_error_code,
      failure_reason,
      reporting_frequency,
      trigger_flag,
      delivery_mode,
      event_type,
      delay_in_days,
      istou,
      period_date,
      source_row_count,
      source_family,
      period,
      failure_scope
    ]
  }
  set: active_users {
    fields: [
      active_users_uuid_summary,
      active_users_total_uuid,
      active_users_total_uuid_sum,
      active_users_enabled_uuid,
      active_users_enabled_uuid_sum,
      active_users_disabled_uuid,
      active_users_disabled_uuid_sum,
      active_users_active_uuid,
      active_users_active_uuid_sum,
      active_users_total_active_electric_uuid,
      active_users_total_active_electric_uuid_sum,
      active_users_total_active_gas_uuid,
      active_users_total_active_gas_uuid_sum,
      active_users_total_active_uuid,
      active_users_total_active_uuid_sum,
      active_users_total_active_user_meters,
      active_users_total_active_user_meters_sum,
      active_users_total_active_electric_meters,
      active_users_total_active_electric_meters_sum,
      active_users_total_active_gas_meters,
      active_users_total_active_gas_meters_sum
    ]
  }
  set: pilot_reporting {
    fields: [

    ]
  }
  set: ingestion_audit {
    fields: [
      ingestion_audit_files_selected,
      ingestion_audit_files_selected_average,
      ingestion_audit_files_selected_median,
      ingestion_audit_files_previous,
      ingestion_audit_files_previous_average,
      ingestion_audit_files_previous_median,
      ingestion_audit_files_average_change,
      ingestion_audit_files_median_change,
      ingestion_audit_total_files_processed,
      ingestion_audit_total_files_processed_sum,
      ingestion_audit_total_chunks_processed,
      ingestion_audit_total_chunks_processed_sum,
      ingestion_audit_total_records_count,
      ingestion_audit_total_records_count_sum,
      ingestion_audit_total_success_record_count,
      ingestion_audit_total_success_record_count_sum,
      ingestion_audit_total_failure_record_count,
      ingestion_audit_total_failure_record_count_sum,
      ingestion_audit_success_percentage,
      ingestion_audit_success_percentage_average,
      ingestion_audit_failure_percentage,
      ingestion_audit_failure_percentage_average
    ]
  }
  set: ingestion_failures {
    fields: [
      ingestion_failures_failed_record_count,
      ingestion_failures_failed_record_count_sum,
      ingestion_failures_total_failed_record_count,
      ingestion_failures_failure_percentage,
      ingestion_failures_failure_percentage_average
    ]
  }
  set: post_ingestion {
    fields: [
      post_ingestion_users_receiving_raw,
      post_ingestion_users_receiving_raw_sum,
      post_ingestion_users_receiving_invoice,
      post_ingestion_users_receiving_invoice_sum,
      post_ingestion_users_per_day_millions,
      post_ingestion_users_per_day_millions_average,
      post_ingestion_user_raw_with_delay_0_3,
      post_ingestion_user_raw_with_delay_0_3_sum,
      post_ingestion_user_raw_with_delay_4_7,
      post_ingestion_user_raw_with_delay_4_7_sum,
      post_ingestion_user_raw_with_delay_8_15,
      post_ingestion_user_raw_with_delay_8_15_sum,
      post_ingestion_user_raw_with_delay_gt_15,
      post_ingestion_user_raw_with_delay_gt_15_sum,
      post_ingestion_user_invoice_with_delay_0_7,
      post_ingestion_user_invoice_with_delay_0_7_sum,
      post_ingestion_user_invoice_with_delay_7_15,
      post_ingestion_user_invoice_with_delay_7_15_sum,
      post_ingestion_user_invoice_with_delay_15_30,
      post_ingestion_user_invoice_with_delay_15_30_sum,
      post_ingestion_user_invoice_with_delay_gt_30,
      post_ingestion_user_invoice_with_delay_gt_30_sum,
      post_ingestion_overlapping_bc_count
    ]
  }
  set: invoice_statistics {
    fields: [
      invoice_statistics_daily_total_invoices,
      invoice_statistics_successful_itemisation_correction_pct,
      invoice_statistics_successful_itemisation_correction_pct_max,
      invoice_statistics_successful_itemisation_t_7_pct,
      invoice_statistics_successful_itemisation_t_7_pct_average,
      invoice_statistics_successful_itemisation_t_2_pct,
      invoice_statistics_successful_itemisation_t_2_pct_average,
      invoice_comparison_date_range,
      invoice_comparison_start,
      invoice_comparison_end,
      invoice_is_selected_period,
      invoice_is_previous_period,
      invoice_in_comparison_window,
      invoice_statistics_invoices_selected,
      invoice_statistics_invoices_selected_average,
      invoice_statistics_invoices_selected_median,
      invoice_statistics_invoices_previous,
      invoice_statistics_invoices_previous_average,
      invoice_statistics_invoices_previous_median,
      invoice_statistics_invoices_average_change,
      invoice_statistics_invoices_median_change,

      invoice_statistics_total_invoices,
      invoice_statistics_total_invoices_sum,
      invoice_statistics_failed_itemisation_pct,
      invoice_statistics_failed_itemisation_pct_average,
      invoice_statistics_successful_itemisation_pct,
      invoice_statistics_successful_itemisation_pct_average
    ]
  }
  set: disagg_quality {
    fields: [
      disagg_quality_appliances_kwh_variance_pct_1,
      disagg_quality_appliances_kwh_variance_pct_1_average,
      disagg_quality_appliances_kwh_variance_pct_2,
      disagg_quality_appliances_kwh_variance_pct_2_average,
      disagg_quality_total_cost_deviation_pct_1,
      disagg_quality_total_cost_deviation_pct_1_average,
      disagg_quality_total_cost_deviation_pct_2,
      disagg_quality_total_cost_deviation_pct_2_average,
      disagg_quality_cost_per_kwh_deviation_pct,
      disagg_quality_cost_per_kwh_deviation_pct_average,
      disagg_quality_seasonal_appliance_usage_deviation_pct,
      disagg_quality_seasonal_appliance_usage_deviation_pct_average,
      disagg_quality_single_appliance_domination_deviation_pct,
      disagg_quality_single_appliance_domination_deviation_pct_average,
      disagg_quality_missing_dwelliing_pct,
      disagg_quality_missing_dwelliing_pct_average,
      disagg_quality_ao_pct_non_tou,
      disagg_quality_ao_pct_non_tou_average,
      disagg_quality_ac_pct_non_tou,
      disagg_quality_ac_pct_non_tou_average,
      disagg_quality_sh_pct_non_tou,
      disagg_quality_sh_pct_non_tou_average,
      disagg_quality_other_pct_non_tou,
      disagg_quality_other_pct_non_tou_average,
      disagg_quality_solar_pct_non_tou,
      disagg_quality_solar_pct_non_tou_average,
      disagg_quality_missing_solar_pct_non_tou,
      disagg_quality_missing_solar_pct_non_tou_average
    ]
  }
  set: processing_failures {
    fields: [
      processing_failures_failure_percentage,
      processing_failures_failure_percentage_average,
      processing_failures_failure_count,
      processing_failures_failure_count_sum,
      processing_failures_total_failure_count
    ]
  }
  set: email_statistics {
    fields: [
      email_comparison_date_range,
      email_comparison_start,
      email_comparison_end,
      email_is_selected_period,
      email_is_previous_period,
      email_in_comparison_window,
      email_statistics_emails_selected,
      email_statistics_emails_selected_average,
      email_statistics_emails_selected_median,
      email_statistics_emails_previous,
      email_statistics_emails_previous_average,
      email_statistics_emails_previous_median,
      email_statistics_emails_average_change,
      email_statistics_emails_median_change,
      email_statistics_cnt_bills_ingested,
      email_statistics_cnt_bills_ingested_sum,
      email_statistics_cnt_bills_emails_sent,
      email_statistics_cnt_bills_emails_sent_sum,
      email_statistics_cnt_bills_emails_sent_average,
      email_statistics_cnt_bills_emails_delivered,
      email_statistics_cnt_bills_emails_delivered_sum,
      email_statistics_email_sent_pct,
      email_statistics_email_sent_pct_average,
      email_statistics_email_sent_pct_vs_expected,
      email_statistics_email_sent_pct_vs_expected_average,
      email_statistics_email_not_sent_pct,
      email_statistics_email_not_sent_pct_average,
      email_statistics_cnt_expected_invoices,
      email_statistics_cnt_expected_invoices_sum,
      email_statistics_cnt_expected_invoices_average,
      email_statistics_cnt_bills_item_available,
      email_statistics_cnt_bills_item_available_sum,
      email_statistics_cnt_bills_item_available_average,
      email_statistics_cnt_bills_ingested_source_text,
      email_statistics_cnt_bills_emails_sent_source_text,
      email_statistics_cnt_bills_emails_delivered_source_text
    ]
  }
  set: email_tracker {
    fields: [
      email_tracker_delivered_notification_id,
      email_tracker_delivered_notification_id_sum,
      email_tracker_generated_notification_id,
      email_tracker_generated_notification_id_sum,
      email_tracker_invoice_ingested,
      email_tracker_invoice_ingested_sum
    ]
  }
  set: email_recommendations {
    fields: [
      email_recommendations_metric_notification_count,
      email_recommendations_metric_notification_count_sum,
      email_recommendations_total_notification_count,
      email_recommendations_notification_pct,
      email_recommendations_notification_pct_average,
      email_recommendations_user_count,
      email_recommendations_user_count_sum,
      email_recommendations_total_user_count,
      email_recommendations_user_pct,
      email_recommendations_user_pct_average
    ]
  }
  set: email_failures {
    fields: [
      email_failures_failure_count,
      email_failures_failure_count_sum,
      email_failures_failure_count_average,
      email_failures_total_failure_count,
      email_failures_failure_pct,
      email_failures_failure_pct_average
    ]
  }
  set: her_generation {
    fields: [
      her_generation_expected_eligible_users,
      her_generation_expected_eligible_users_sum,
      her_generation_actual_eligible_users,
      her_generation_actual_eligible_users_sum,
      her_generation_actual_generation_count,
      her_generation_actual_generation_count_sum,
      her_generation_weekly_actual_failure_count,
      her_generation_weekly_actual_failure_count_sum
    ]
  }
  set: her_schedules {
    fields: [
      her_schedules_total_eligible_users,
      her_schedules_total_eligible_users_sum,
      her_schedules_total_generated_notification_id,
      her_schedules_total_generated_notification_id_sum,
      her_schedules_total_scheduled_notification_id,
      her_schedules_total_scheduled_notification_id_sum,
      her_schedules_total_queued_notification_id,
      her_schedules_total_queued_notification_id_sum,
      her_schedules_total_printed_notification_id,
      her_schedules_total_printed_notification_id_sum,
      her_schedules_total_mailed_notification_id,
      her_schedules_total_mailed_notification_id_sum,
      her_schedules_total_failed_notification_id,
      her_schedules_total_failed_notification_id_sum,
      her_schedules_total_swept_notification_id,
      her_schedules_total_swept_notification_id_sum
    ]
  }
  set: her_failures {
    fields: [
      her_failures_failure_count,
      her_failures_failure_count_sum,
      her_failures_total_failure_count,
      her_failures_failure_percentage,
      her_failures_failure_percentage_average
    ]
  }
  set: her_non_pseg_quality {
    fields: [
      her_non_pseg_quality_low_bc_duration_count,
      her_non_pseg_quality_low_bc_duration_count_sum,
      her_non_pseg_quality_high_bc_duration_count,
      her_non_pseg_quality_high_bc_duration_count_sum,
      her_non_pseg_quality_staleness_count,
      her_non_pseg_quality_staleness_count_sum,
      her_non_pseg_quality_solar_template_count,
      her_non_pseg_quality_solar_template_count_sum,
      her_non_pseg_quality_solar_consistency_count,
      her_non_pseg_quality_solar_consistency_count_sum,
      her_non_pseg_quality_solar_generation_count,
      her_non_pseg_quality_solar_generation_count_sum,
      her_non_pseg_quality_report_consistency_count,
      her_non_pseg_quality_report_consistency_count_sum,
      her_non_pseg_quality_itemization_count,
      her_non_pseg_quality_itemization_count_sum,
      her_non_pseg_quality_bill_change_consistency_count,
      her_non_pseg_quality_bill_change_consistency_count_sum,
      her_non_pseg_quality_ev_itemization_count,
      her_non_pseg_quality_ev_itemization_count_sum,
      her_non_pseg_quality_tou_template_count,
      her_non_pseg_quality_tou_template_count_sum,
      her_non_pseg_quality_nbi_occurance_count,
      her_non_pseg_quality_nbi_occurance_count_sum,
      her_non_pseg_quality_nbi_value_count,
      her_non_pseg_quality_nbi_value_count_sum,
      her_non_pseg_quality_nbi_appliance_itemisation_count,
      her_non_pseg_quality_nbi_appliance_itemisation_count_sum,
      her_non_pseg_quality_nbi_non_null_insight_count,
      her_non_pseg_quality_nbi_non_null_insight_count_sum,
      her_non_pseg_quality_nbi_unicode_count,
      her_non_pseg_quality_nbi_unicode_count_sum,
      her_non_pseg_quality_nbi_extreme_insight_count,
      her_non_pseg_quality_nbi_extreme_insight_count_sum
    ]
  }
  set: her_automation_quality {
    fields: [
      her_automation_quality_low_bc_duration_cnt,
      her_automation_quality_low_bc_duration_cnt_sum,
      her_automation_quality_high_bc_duration_cnt,
      her_automation_quality_high_bc_duration_cnt_sum,
      her_automation_quality_staleness_cnt,
      her_automation_quality_staleness_cnt_sum,
      her_automation_quality_solar_template_cnt,
      her_automation_quality_solar_template_cnt_sum,
      her_automation_quality_solar_consistency_cnt,
      her_automation_quality_solar_consistency_cnt_sum,
      her_automation_quality_solar_generation_cnt,
      her_automation_quality_solar_generation_cnt_sum,
      her_automation_quality_report_consistency_cnt,
      her_automation_quality_report_consistency_cnt_sum,
      her_automation_quality_itemization_cnt,
      her_automation_quality_itemization_cnt_sum,
      her_automation_quality_bill_change_consistency_cnt,
      her_automation_quality_bill_change_consistency_cnt_sum,
      her_automation_quality_ev_itemization_cnt,
      her_automation_quality_ev_itemization_cnt_sum,
      her_automation_quality_tou_template_cnt,
      her_automation_quality_tou_template_cnt_sum,
      her_automation_quality_nbi_occurence_cnt,
      her_automation_quality_nbi_occurence_cnt_sum,
      her_automation_quality_nbi_value_cnt,
      her_automation_quality_nbi_value_cnt_sum,
      her_automation_quality_nbi_appliance_itemization_cnt,
      her_automation_quality_nbi_appliance_itemization_cnt_sum,
      her_automation_quality_nbi_non_null_insight_cnt,
      her_automation_quality_nbi_non_null_insight_cnt_sum,
      her_automation_quality_nbi_unicode_cnt,
      her_automation_quality_nbi_unicode_cnt_sum,
      her_automation_quality_nbi_extreme_insight_cnt,
      her_automation_quality_nbi_extreme_insight_cnt_sum,
      her_automation_quality_nbi_seasonal_appliance_cnt,
      her_automation_quality_nbi_seasonal_appliance_cnt_sum,
      her_automation_quality_overall_report_count,
      her_automation_quality_overall_report_count_sum
    ]
  }
  set: nbi_generation {
    fields: [
      nbi_generation_total_users_successful,
      nbi_generation_total_users_successful_sum,
      nbi_generation_total_users_with_200_errorcode,
      nbi_generation_total_users_with_200_errorcode_sum,
      nbi_generation_total_users_with_300_errorcode,
      nbi_generation_total_users_with_300_errorcode_sum,
      nbi_generation_nbi_error_pct,
      nbi_generation_nbi_error_pct_average
    ]
  }
  set: nbi_generic_tags {
    fields: [
      nbi_generic_tags_total_nbi_users,
      nbi_generic_tags_total_nbi_users_sum,
      nbi_generic_tags_total_nbi_users_with_generic_tag,
      nbi_generic_tags_total_nbi_users_with_generic_tag_sum,
      nbi_generic_tags_pct_users_with_generic_tag,
      nbi_generic_tags_pct_users_with_generic_tag_average
    ]
  }
  set: billing_length {
    fields: [
      billing_length_bc_1_15_count,
      billing_length_bc_1_15_count_sum,
      billing_length_bc_15_30_count,
      billing_length_bc_15_30_count_sum,
      billing_length_bc_31_45_count,
      billing_length_bc_31_45_count_sum,
      billing_length_bc_45_60_count,
      billing_length_bc_45_60_count_sum,
      billing_length_bc_61_75_count,
      billing_length_bc_61_75_count_sum,
      billing_length_bc_76_90_count,
      billing_length_bc_76_90_count_sum,
      billing_length_bc_gt_90_count,
      billing_length_bc_gt_90_count_sum
    ]
  }
}
