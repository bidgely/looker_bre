# EU Ingestion migration. All tiles use query-time shared fields; no PDTs.
---
- dashboard: bre_eu_ingestion
  title: BRE EU — Ingestion
  description: EU ingestion monitoring. Defaults to the last 7 completed days; weekly grouping starts Sunday.
  layout: newspaper
  preferred_viewer: dashboards-next
  crossfilter_enabled: false
  elements:
  - name: active_uuid
    title: Active UUID out of Total UUID
    model: bre_eu
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.active_users_uuid_summary
    - bre_dashboard.active_users_total_uuid_sum
    filters:
      bre_dashboard.source_family: activeusers
    limit: 1
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
    row: 0
    col: 0
    width: 24
    height: 3
    hidden_fields:
    - bre_dashboard.active_users_total_uuid_sum
    show_single_value_title: false
    show_comparison: false
    note_text: Latest reporting-date snapshot per pilot. Date, Period and File Type controls do not affect this
      tile.
    note_display: hover
    note_state: collapsed
  - name: files_average
    title: '# of Files Per Day — Average'
    model: bre_eu
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.ingestion_audit_files_selected_average
    - bre_dashboard.ingestion_audit_files_average_change
    - bre_dashboard.ingestion_audit_files_previous_average
    filters:
      bre_dashboard.source_family: ingestionaudit
      bre_dashboard.ingestion_in_comparison_window: 'Yes'
      bre_dashboard.ingestion_comparison_date_range: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.ingestion_comparison_date_range
      File Type: bre_dashboard.ingestion_file_type
    row: 3
    col: 0
    width: 6
    height: 4
    hidden_fields:
    - bre_dashboard.ingestion_audit_files_previous_average
    show_single_value_title: true
    single_value_title: Average files
    show_comparison: true
    comparison_type: change
    comparison_label: vs previous equal-length period
    show_comparison_label: true
    note_text: Source-row average. Comparison is percentage change versus the preceding equal-length date range;
      absent or zero previous values have no percentage change.
    note_display: hover
    note_state: collapsed
  - name: files_median
    title: '# of Files Per Day — Median'
    model: bre_eu
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.ingestion_audit_files_selected_median
    - bre_dashboard.ingestion_audit_files_median_change
    - bre_dashboard.ingestion_audit_files_previous_median
    filters:
      bre_dashboard.source_family: ingestionaudit
      bre_dashboard.ingestion_in_comparison_window: 'Yes'
      bre_dashboard.ingestion_comparison_date_range: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.ingestion_comparison_date_range
      File Type: bre_dashboard.ingestion_file_type
    row: 3
    col: 6
    width: 6
    height: 4
    hidden_fields:
    - bre_dashboard.ingestion_audit_files_previous_median
    show_single_value_title: true
    single_value_title: Median files
    show_comparison: true
    comparison_type: change
    comparison_label: vs previous equal-length period
    show_comparison_label: true
    note_text: Source-row median. Comparison is percentage change versus the preceding equal-length date range;
      absent or zero previous values have no percentage change.
    note_display: hover
    note_state: collapsed
  - name: daily_users
    title: Daily Average — Users (M)/day
    model: bre_eu
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.post_ingestion_users_per_day_millions_average
    filters:
      bre_dashboard.source_family: postingestion
      bre_dashboard.analysis_date: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.analysis_date
      File Type: bre_dashboard.ingestion_file_type
    row: 3
    col: 12
    width: 6
    height: 4
    show_single_value_title: true
    single_value_title: Users (M)/day
    show_comparison: false
  - name: daily_success
    title: Daily Average — Success %
    model: bre_eu
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.ingestion_audit_success_percentage_average
    filters:
      bre_dashboard.source_family: ingestionaudit
      bre_dashboard.analysis_date: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.analysis_date
      File Type: bre_dashboard.ingestion_file_type
    row: 3
    col: 18
    width: 6
    height: 4
    show_single_value_title: true
    single_value_title: Success %
    show_comparison: false
    value_format: 0.00"%"
  - name: daily_ingestion_statistics
    title: Daily Ingestion Statistics
    model: bre_eu
    explore: bre_dashboard
    type: looker_column
    fields:
    - bre_dashboard.ingestion_period_date
    - bre_dashboard.ingestion_audit_total_files_processed_sum
    - bre_dashboard.ingestion_audit_total_chunks_processed_sum
    - bre_dashboard.ingestion_audit_total_records_count_sum
    - bre_dashboard.ingestion_audit_success_percentage_average
    filters:
      bre_dashboard.source_family: ingestionaudit
      bre_dashboard.analysis_date: 7 days ago for 7 days
      bre_dashboard.period: Daily
    limit: 5000
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.analysis_date
      File Type: bre_dashboard.ingestion_file_type
      Period: bre_dashboard.period
    row: 7
    col: 0
    width: 24
    height: 8
    sorts:
    - bre_dashboard.ingestion_period_date
    x_axis_scale: time
    x_axis_label: Period
    legend_position: center
    show_null_points: true
    show_value_labels: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_x_axis_label: true
    show_y_axis_labels: true
    stacking: normal
    series_labels:
      bre_dashboard.ingestion_audit_total_files_processed_sum: 'Files #'
      bre_dashboard.ingestion_audit_total_chunks_processed_sum: 'Chunks #'
      bre_dashboard.ingestion_audit_total_records_count_sum: 'Records #'
      bre_dashboard.ingestion_audit_success_percentage_average: Success %
    series_types:
      bre_dashboard.ingestion_audit_success_percentage_average: line
    y_axes:
    - label: Count
      orientation: left
      series:
      - id: bre_dashboard.ingestion_audit_total_files_processed_sum
        name: 'Files #'
        axisId: bre_dashboard.ingestion_audit_total_files_processed_sum
      - id: bre_dashboard.ingestion_audit_total_chunks_processed_sum
        name: 'Chunks #'
        axisId: bre_dashboard.ingestion_audit_total_chunks_processed_sum
      - id: bre_dashboard.ingestion_audit_total_records_count_sum
        name: 'Records #'
        axisId: bre_dashboard.ingestion_audit_total_records_count_sum
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    - label: Success %
      orientation: right
      series:
      - id: bre_dashboard.ingestion_audit_success_percentage_average
        name: Success %
        axisId: bre_dashboard.ingestion_audit_success_percentage_average
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    series_value_format:
      bre_dashboard.ingestion_audit_success_percentage_average: 0.00"%"
  - name: post_ingestion_quality
    title: Daily Post-Ingestion Data Quality Report (Only for Elec/Gas AMI)
    model: bre_eu
    explore: bre_dashboard
    type: looker_line
    fields:
    - bre_dashboard.ingestion_period_date
    - bre_dashboard.post_ingestion_users_receiving_raw_sum
    - bre_dashboard.post_ingestion_user_raw_with_delay_0_3_sum
    - bre_dashboard.post_ingestion_user_raw_with_delay_4_7_sum
    - bre_dashboard.post_ingestion_user_raw_with_delay_8_15_sum
    - bre_dashboard.post_ingestion_user_raw_with_delay_gt_15_sum
    - bre_dashboard.post_ingestion_users_receiving_invoice_sum
    - bre_dashboard.post_ingestion_user_invoice_with_delay_0_7_sum
    - bre_dashboard.post_ingestion_user_invoice_with_delay_7_15_sum
    - bre_dashboard.post_ingestion_user_invoice_with_delay_15_30_sum
    - bre_dashboard.post_ingestion_user_invoice_with_delay_gt_30_sum
    filters:
      bre_dashboard.source_family: postingestion
      bre_dashboard.analysis_date: 7 days ago for 7 days
      bre_dashboard.period: Daily
    limit: 5000
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.analysis_date
      File Type: bre_dashboard.ingestion_file_type
      Period: bre_dashboard.period
    row: 15
    col: 0
    width: 24
    height: 10
    sorts:
    - bre_dashboard.ingestion_period_date
    x_axis_scale: time
    x_axis_label: Period
    legend_position: center
    show_null_points: true
    show_value_labels: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_x_axis_label: true
    show_y_axis_labels: true
    stacking: ''
    interpolation: linear
    series_labels:
      bre_dashboard.post_ingestion_users_receiving_raw_sum: Total Users Receiving Raw Data
      bre_dashboard.post_ingestion_user_raw_with_delay_0_3_sum: Users’ Raw Data Age Btw 0 to 3 days
      bre_dashboard.post_ingestion_user_raw_with_delay_4_7_sum: Users’ Raw Data Age Btw 4 to 7 days
      bre_dashboard.post_ingestion_user_raw_with_delay_8_15_sum: Users’ Raw Data Age Btw 8 to 15 days
      bre_dashboard.post_ingestion_user_raw_with_delay_gt_15_sum: Users’ Raw Data Age > 15 days
      bre_dashboard.post_ingestion_users_receiving_invoice_sum: Total Users Receiving Invoice Data
      bre_dashboard.post_ingestion_user_invoice_with_delay_0_7_sum: Users’ Invoice Data Age Btw 0 to 7 days
      bre_dashboard.post_ingestion_user_invoice_with_delay_7_15_sum: Users’ Invoice Data Age Btw 8 to 15 days
      bre_dashboard.post_ingestion_user_invoice_with_delay_15_30_sum: Users’ Invoice Data Age Btw 16 to 30 days
      bre_dashboard.post_ingestion_user_invoice_with_delay_gt_30_sum: Users’ Invoice Data Age > 30 days
    note_text: All series are sums. Calculated totals retain the source NULLIF formulas, so they can differ from
      the sum of the displayed buckets. Counts across dates are not distinct users.
    note_display: hover
    note_state: collapsed
  - name: ingestion_failure_reasons
    title: Daily Top Ingestion Failure Reasons
    model: bre_eu
    explore: bre_dashboard
    type: looker_column
    fields:
    - bre_dashboard.ingestion_period_date
    - bre_dashboard.application_error_code
    - bre_dashboard.ingestion_failures_failure_percentage_average
    filters:
      bre_dashboard.source_family: ingestionfailures
      bre_dashboard.source_rank: <=20
      bre_dashboard.analysis_date: 7 days ago for 7 days
      bre_dashboard.period: Daily
    limit: 5000
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.analysis_date
      File Type: bre_dashboard.ingestion_file_type
      Period: bre_dashboard.period
    row: 25
    col: 0
    width: 24
    height: 9
    sorts:
    - bre_dashboard.ingestion_period_date
    - bre_dashboard.application_error_code
    x_axis_scale: time
    x_axis_label: Period
    legend_position: center
    show_null_points: true
    show_value_labels: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_x_axis_label: true
    show_y_axis_labels: true
    stacking: normal
    pivots:
    - bre_dashboard.application_error_code
    column_limit: 200
    note_text: Average failure percentage by error code. Retains source rank ≤ 20 per day, pilot and ingestion type
      before period grouping; the chart can have more than 20 series.
    note_display: hover
    note_state: collapsed
  filters:
  - name: Time Period
    title: Time Period
    type: field_filter
    default_value: 7 days ago for 7 days
    allow_multiple_values: false
    required: true
    ui_config:
      type: advanced
      display: popover
    model: bre_eu
    explore: bre_dashboard
    field: bre_dashboard.analysis_date
  - name: Period
    title: Period
    type: field_filter
    default_value: Daily
    allow_multiple_values: false
    required: true
    ui_config:
      type: button_toggles
      display: popover
    model: bre_eu
    explore: bre_dashboard
    field: bre_dashboard.period
  - name: Pilot ID
    title: Pilot ID
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: bre_eu
    explore: bre_dashboard
    field: bre_dashboard.pilot_id
  - name: Pilot Name
    title: Pilot Name
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: bre_eu
    explore: bre_dashboard
    field: bre_dashboard.pilot_name
  - name: File Type
    title: File Type
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: bre_eu
    explore: bre_dashboard
    field: bre_dashboard.ingestion_file_type
