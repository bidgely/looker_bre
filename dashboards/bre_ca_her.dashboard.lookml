# CA-only HER dashboard using shared source views and the confirmed tile/filter definitions.
---
- dashboard: bre_ca_her
  title: BRE CA — HER
  description: CA Home Energy Report monitoring.
  layout: newspaper
  preferred_viewer: dashboards-next
  crossfilter_enabled: false
  elements:
  - name: active_uuid
    title: Active UUID out of Total UUID
    model: bre_ca
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
    note_text: Latest reporting-date snapshot per pilot. Only Pilot ID and Pilot Name controls affect this tile.
    note_display: hover
    note_state: collapsed
  - name: expected_generation
    title: 'HER Expected vs Generation — Expected Gen #'
    model: bre_ca
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.her_schedules_total_eligible_users_sum
    filters:
      bre_dashboard.source_family: herschedules
      bre_dashboard.schedule_start: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Time Period: bre_dashboard.schedule_start
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Fuel Type: bre_dashboard.fuel_type
      Cluster IDs: bre_dashboard.cluster_id
    row: 3
    col: 0
    width: 12
    height: 4
    show_single_value_title: true
    single_value_title: 'Expected Gen #'
    show_comparison: false
    value_format: '#,##0'
    note_text: Sum across selected HER schedule snapshots. Time Period filters schedule_start.
    note_display: hover
    note_state: collapsed
  - name: actual_generation
    title: 'HER Expected vs Generation — Total Actual Gen #'
    model: bre_ca
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.her_schedules_total_generated_notification_id_sum
    filters:
      bre_dashboard.source_family: herschedules
      bre_dashboard.schedule_start: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Time Period: bre_dashboard.schedule_start
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Fuel Type: bre_dashboard.fuel_type
      Cluster IDs: bre_dashboard.cluster_id
    row: 3
    col: 12
    width: 12
    height: 4
    show_single_value_title: true
    single_value_title: 'Total Actual Gen #'
    show_comparison: false
    value_format: '#,##0'
    note_text: Sum across selected HER schedule snapshots. Time Period filters schedule_start.
    note_display: hover
    note_state: collapsed
  - name: her_schedules
    title: HER Schedule(s)
    model: bre_ca
    explore: bre_dashboard
    type: looker_grid
    fields:
    - bre_dashboard.schedule_start
    - bre_dashboard.schedule_end
    - bre_dashboard.her_schedules_total_eligible_users_sum
    - bre_dashboard.her_schedules_total_generated_notification_id_sum
    - bre_dashboard.her_schedules_total_failed_notification_id_sum
    - bre_dashboard.her_schedules_total_scheduled_notification_id_sum
    - bre_dashboard.her_schedules_total_swept_notification_id_sum
    - bre_dashboard.her_schedules_total_queued_notification_id_sum
    - bre_dashboard.her_schedules_total_printed_notification_id_sum
    - bre_dashboard.her_schedules_total_mailed_notification_id_sum
    filters:
      bre_dashboard.source_family: herschedules
      bre_dashboard.analysis_date: 7 days ago for 7 days
    sorts:
    - bre_dashboard.schedule_start desc
    - bre_dashboard.schedule_end desc
    limit: 5000
    show_view_names: false
    listen:
      Time Period: bre_dashboard.analysis_date
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Fuel Type: bre_dashboard.fuel_type
      Cluster IDs: bre_dashboard.cluster_id
    row: 7
    col: 0
    width: 24
    height: 8
    series_labels:
      bre_dashboard.schedule_start: Start
      bre_dashboard.schedule_end: End
      bre_dashboard.her_schedules_total_eligible_users_sum: Expt Gen#
      bre_dashboard.her_schedules_total_generated_notification_id_sum: Actual Gen#
      bre_dashboard.her_schedules_total_failed_notification_id_sum: Failed Gen#
      bre_dashboard.her_schedules_total_scheduled_notification_id_sum: 'Schld #'
      bre_dashboard.her_schedules_total_swept_notification_id_sum: 'Swept #'
      bre_dashboard.her_schedules_total_queued_notification_id_sum: 'Queued #'
      bre_dashboard.her_schedules_total_printed_notification_id_sum: 'Printed #'
      bre_dashboard.her_schedules_total_mailed_notification_id_sum: 'Mailed #'
    show_row_numbers: false
    transpose: false
    truncate_text: false
    table_theme: white
    note_text: Schedule totals grouped by Start and End dates. Time Period filters analysis_date from the selected
      source snapshots.
    note_display: hover
    note_state: collapsed
  - name: her_generation_daily_stats
    title: HER Generation Daily Stats
    model: bre_ca
    explore: bre_dashboard
    type: looker_column
    fields:
    - bre_dashboard.her_generation_chart_date
    - bre_dashboard.her_generation_expected_eligible_users_sum
    - bre_dashboard.her_generation_actual_eligible_users_sum
    - bre_dashboard.her_generation_actual_generation_count_sum
    - bre_dashboard.her_generation_success_pct_average
    filters:
      bre_dashboard.source_family: hergeneration
      bre_dashboard.period: Daily
      bre_dashboard.her_generation_chart_period: Daily
      bre_dashboard.analysis_date: 7 days ago for 7 days
    sorts:
    - bre_dashboard.her_generation_chart_date
    limit: 5000
    show_view_names: false
    listen:
      Time Period: bre_dashboard.analysis_date
      Period: bre_dashboard.her_generation_chart_period
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Fuel Type: bre_dashboard.fuel_type
      Cluster IDs: bre_dashboard.cluster_id
    row: 15
    col: 0
    width: 24
    height: 8
    x_axis_scale: time
    x_axis_label: Analysis Date
    legend_position: center
    show_null_points: true
    show_value_labels: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_x_axis_label: true
    show_y_axis_labels: true
    stacking: ''
    series_labels:
      bre_dashboard.her_generation_expected_eligible_users_sum: 'Expected Eligible #'
      bre_dashboard.her_generation_actual_eligible_users_sum: 'Actual Eligible #'
      bre_dashboard.her_generation_actual_generation_count_sum: 'Actual Generation #'
      bre_dashboard.her_generation_success_pct_average: Success %
    series_types:
      bre_dashboard.her_generation_success_pct_average: line
    y_axes:
    - label: Count
      orientation: left
      series:
      - id: bre_dashboard.her_generation_expected_eligible_users_sum
        name: 'Expected Eligible #'
        axisId: bre_dashboard.her_generation_expected_eligible_users_sum
      - id: bre_dashboard.her_generation_actual_eligible_users_sum
        name: 'Actual Eligible #'
        axisId: bre_dashboard.her_generation_actual_eligible_users_sum
      - id: bre_dashboard.her_generation_actual_generation_count_sum
        name: 'Actual Generation #'
        axisId: bre_dashboard.her_generation_actual_generation_count_sum
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    - label: Success %
      orientation: right
      series:
      - id: bre_dashboard.her_generation_success_pct_average
        name: Success %
        axisId: bre_dashboard.her_generation_success_pct_average
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    series_value_format:
      bre_dashboard.her_generation_success_pct_average: 0.00"%"
    note_text: Daily source rows only. Time Period filters analysis_date before Daily/Weekly/Monthly grouping; weeks
      begin Sunday. Counts are sums; Success % is the average of 100 × actual_generation_count / actual_eligible_users
      across daily source rows. Zero eligibility produces NULL percentages.
    note_display: hover
    note_state: collapsed
  - name: daily_her_quality_report
    title: Daily HER Quality Report (Only for HER 2.0**)
    model: bre_ca
    explore: bre_dashboard
    type: looker_line
    fields:
    - bre_dashboard.her_quality_chart_date
    - bre_dashboard.her_automation_quality_high_bc_duration_cnt_sum
    - bre_dashboard.her_automation_quality_staleness_cnt_sum
    - bre_dashboard.her_automation_quality_solar_template_cnt_sum
    - bre_dashboard.her_automation_quality_solar_consistency_cnt_sum
    - bre_dashboard.her_automation_quality_solar_generation_cnt_sum
    - bre_dashboard.her_automation_quality_report_consistency_cnt_sum
    - bre_dashboard.her_automation_quality_low_bc_duration_cnt_sum
    - bre_dashboard.her_automation_quality_itemization_cnt_sum
    - bre_dashboard.her_automation_quality_bill_change_consistency_cnt_sum
    - bre_dashboard.her_automation_quality_ev_itemization_cnt_sum
    - bre_dashboard.her_automation_quality_tou_template_cnt_sum
    - bre_dashboard.her_automation_quality_nbi_occurence_cnt_sum
    - bre_dashboard.her_automation_quality_nbi_value_cnt_sum
    - bre_dashboard.her_automation_quality_nbi_appliance_itemization_cnt_sum
    - bre_dashboard.her_automation_quality_nbi_non_null_insight_cnt_sum
    - bre_dashboard.her_automation_quality_nbi_unicode_cnt_sum
    - bre_dashboard.her_automation_quality_nbi_extreme_insight_cnt_sum
    - bre_dashboard.her_automation_quality_nbi_seasonal_appliance_cnt_sum
    - bre_dashboard.her_automation_quality_overall_report_count_sum
    filters:
      bre_dashboard.source_family: herautomationquality
      bre_dashboard.period: Daily
      bre_dashboard.her_generation_chart_period: Daily
      bre_dashboard.reporting_date: 7 days ago for 7 days
    sorts:
    - bre_dashboard.her_quality_chart_date
    limit: 5000
    show_view_names: false
    listen:
      Time Period: bre_dashboard.reporting_date
      Period: bre_dashboard.her_generation_chart_period
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
    row: 23
    col: 0
    width: 24
    height: 10
    x_axis_scale: time
    x_axis_label: Analysis Date
    legend_position: center
    show_null_points: true
    show_value_labels: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_x_axis_label: true
    show_y_axis_labels: true
    stacking: ''
    series_labels:
      bre_dashboard.her_automation_quality_high_bc_duration_cnt_sum: 'BC > 70 days #'
      bre_dashboard.her_automation_quality_staleness_cnt_sum: 'Stale BC #'
      bre_dashboard.her_automation_quality_solar_template_cnt_sum: 'Solar Reports with Cost-based Section #'
      bre_dashboard.her_automation_quality_solar_consistency_cnt_sum: Solar Report for Non-Solar
      bre_dashboard.her_automation_quality_solar_generation_cnt_sum: Solar Estimation 0 or Null
      bre_dashboard.her_automation_quality_report_consistency_cnt_sum: Inconsistency Between Cost & Consumption
        Across Sections
      bre_dashboard.her_automation_quality_low_bc_duration_cnt_sum: BC < 23 days
      bre_dashboard.her_automation_quality_itemization_cnt_sum: 'Itemisation Mismatch #'
      bre_dashboard.her_automation_quality_bill_change_consistency_cnt_sum: Invalid Bill Change Calculations
      bre_dashboard.her_automation_quality_ev_itemization_cnt_sum: EV Report for EV undetected in Itemisation
      bre_dashboard.her_automation_quality_tou_template_cnt_sum: 'TOU Report for Non-TOU BC #'
      bre_dashboard.her_automation_quality_nbi_occurence_cnt_sum: Missing NBI Unit/Format Token (e.g. "%", "$",
        "kWh")
      bre_dashboard.her_automation_quality_nbi_value_cnt_sum: Inconsistency in Insight Calculations (>10%)
      bre_dashboard.her_automation_quality_nbi_appliance_itemization_cnt_sum: Missing Appliances in Itemisation
        Referenced by NBI Insights
      bre_dashboard.her_automation_quality_nbi_non_null_insight_cnt_sum: Missing or Invalid Numeric NBI Insight
        Value
      bre_dashboard.her_automation_quality_nbi_unicode_cnt_sum: 'Unicode in the NBI Insights #'
      bre_dashboard.her_automation_quality_nbi_extreme_insight_cnt_sum: Extreme Insight Values
      bre_dashboard.her_automation_quality_nbi_seasonal_appliance_cnt_sum: 'Season-based Blocked Appliances in NBI
        Insights #'
      bre_dashboard.her_automation_quality_overall_report_count_sum: 'Overall Report #'
    value_format: '#,##0'
    y_axes:
    - label: Count
      orientation: left
      series:
      - id: bre_dashboard.her_automation_quality_high_bc_duration_cnt_sum
        name: 'BC > 70 days #'
        axisId: bre_dashboard.her_automation_quality_high_bc_duration_cnt_sum
      - id: bre_dashboard.her_automation_quality_staleness_cnt_sum
        name: 'Stale BC #'
        axisId: bre_dashboard.her_automation_quality_staleness_cnt_sum
      - id: bre_dashboard.her_automation_quality_solar_template_cnt_sum
        name: 'Solar Reports with Cost-based Section #'
        axisId: bre_dashboard.her_automation_quality_solar_template_cnt_sum
      - id: bre_dashboard.her_automation_quality_solar_consistency_cnt_sum
        name: Solar Report for Non-Solar
        axisId: bre_dashboard.her_automation_quality_solar_consistency_cnt_sum
      - id: bre_dashboard.her_automation_quality_solar_generation_cnt_sum
        name: Solar Estimation 0 or Null
        axisId: bre_dashboard.her_automation_quality_solar_generation_cnt_sum
      - id: bre_dashboard.her_automation_quality_report_consistency_cnt_sum
        name: Inconsistency Between Cost & Consumption Across Sections
        axisId: bre_dashboard.her_automation_quality_report_consistency_cnt_sum
      - id: bre_dashboard.her_automation_quality_low_bc_duration_cnt_sum
        name: BC < 23 days
        axisId: bre_dashboard.her_automation_quality_low_bc_duration_cnt_sum
      - id: bre_dashboard.her_automation_quality_itemization_cnt_sum
        name: 'Itemisation Mismatch #'
        axisId: bre_dashboard.her_automation_quality_itemization_cnt_sum
      - id: bre_dashboard.her_automation_quality_bill_change_consistency_cnt_sum
        name: Invalid Bill Change Calculations
        axisId: bre_dashboard.her_automation_quality_bill_change_consistency_cnt_sum
      - id: bre_dashboard.her_automation_quality_ev_itemization_cnt_sum
        name: EV Report for EV undetected in Itemisation
        axisId: bre_dashboard.her_automation_quality_ev_itemization_cnt_sum
      - id: bre_dashboard.her_automation_quality_tou_template_cnt_sum
        name: 'TOU Report for Non-TOU BC #'
        axisId: bre_dashboard.her_automation_quality_tou_template_cnt_sum
      - id: bre_dashboard.her_automation_quality_nbi_occurence_cnt_sum
        name: Missing NBI Unit/Format Token (e.g. "%", "$", "kWh")
        axisId: bre_dashboard.her_automation_quality_nbi_occurence_cnt_sum
      - id: bre_dashboard.her_automation_quality_nbi_value_cnt_sum
        name: Inconsistency in Insight Calculations (>10%)
        axisId: bre_dashboard.her_automation_quality_nbi_value_cnt_sum
      - id: bre_dashboard.her_automation_quality_nbi_appliance_itemization_cnt_sum
        name: Missing Appliances in Itemisation Referenced by NBI Insights
        axisId: bre_dashboard.her_automation_quality_nbi_appliance_itemization_cnt_sum
      - id: bre_dashboard.her_automation_quality_nbi_non_null_insight_cnt_sum
        name: Missing or Invalid Numeric NBI Insight Value
        axisId: bre_dashboard.her_automation_quality_nbi_non_null_insight_cnt_sum
      - id: bre_dashboard.her_automation_quality_nbi_unicode_cnt_sum
        name: 'Unicode in the NBI Insights #'
        axisId: bre_dashboard.her_automation_quality_nbi_unicode_cnt_sum
      - id: bre_dashboard.her_automation_quality_nbi_extreme_insight_cnt_sum
        name: Extreme Insight Values
        axisId: bre_dashboard.her_automation_quality_nbi_extreme_insight_cnt_sum
      - id: bre_dashboard.her_automation_quality_nbi_seasonal_appliance_cnt_sum
        name: 'Season-based Blocked Appliances in NBI Insights #'
        axisId: bre_dashboard.her_automation_quality_nbi_seasonal_appliance_cnt_sum
      - id: bre_dashboard.her_automation_quality_overall_report_count_sum
        name: 'Overall Report #'
        axisId: bre_dashboard.her_automation_quality_overall_report_count_sum
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    note_text: 'Sum of Daily source counts, filtered by reporting_date and grouped by analysis date using the selected
      Period; weeks begin Sunday. Overall Report # counts rows where report_type is bad. Invalid Bill Change Calculations
      appears once.'
    note_display: hover
    note_state: collapsed
  - name: daily_her_generation_failure_reasons
    title: Daily HER Generation Failure Reasons
    model: bre_ca
    explore: bre_dashboard
    type: looker_column
    fields:
    - bre_dashboard.her_failures_chart_date
    - bre_dashboard.failure_reason
    - bre_dashboard.her_failures_failure_count_sum
    pivots:
    - bre_dashboard.failure_reason
    filters:
      bre_dashboard.source_family: herfailures
      bre_dashboard.period: Daily
      bre_dashboard.her_generation_chart_period: Daily
      bre_dashboard.analysis_date: 7 days ago for 7 days
    sorts:
    - bre_dashboard.her_failures_chart_date
    - bre_dashboard.failure_reason
    limit: 5000
    column_limit: 200
    show_view_names: false
    listen:
      Time Period: bre_dashboard.analysis_date
      Period: bre_dashboard.her_generation_chart_period
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Fuel Type: bre_dashboard.fuel_type
      Cluster IDs: bre_dashboard.cluster_id
    row: 33
    col: 0
    width: 24
    height: 8
    x_axis_scale: time
    x_axis_label: Analysis Date
    legend_position: center
    show_null_points: true
    show_value_labels: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_x_axis_label: true
    show_y_axis_labels: true
    stacking: normal
    series_labels:
      bre_dashboard.her_failures_failure_count_sum: Failure Count
    value_format: '#,##0'
    note_text: Sum of failure_count by failure_reason from Daily source rows, filtered by analysis_date before Daily/Weekly/Monthly
      grouping; weeks begin Sunday. No rank restriction.
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
    model: bre_ca
    explore: bre_dashboard
    field: bre_dashboard.schedule_start
  - name: Period
    title: Period
    type: field_filter
    default_value: Daily
    allow_multiple_values: false
    required: true
    ui_config:
      type: button_toggles
      display: popover
    model: bre_ca
    explore: bre_dashboard
    field: bre_dashboard.her_generation_chart_period
  - name: Pilot ID
    title: Pilot ID
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: bre_ca
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
    model: bre_ca
    explore: bre_dashboard
    field: bre_dashboard.pilot_name
  - name: Fuel Type
    title: Fuel Type
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: bre_ca
    explore: bre_her_filters
    field: bre_her_generation.fuel_type
  - name: Cluster IDs
    title: Cluster IDs
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: bre_ca
    explore: bre_her_filters
    field: bre_her_generation.cluster_id
