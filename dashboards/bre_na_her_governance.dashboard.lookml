# NA HER 7a: data_studio_files/bre_na_her_implementation.md
---
- layout: newspaper
  preferred_viewer: dashboards-next
  crossfilter_enabled: false
  dashboard: bre_na_her_governance
  title: BRE NA — HER Data Governance
  description: NA HER 7a Data Governance. All seven tiles implemented; native Looker and original-report validation
    pending.
  elements:
  - col: 0
    explore: bre_dashboard
    fields:
    - bre_dashboard.active_users_uuid_summary
    - bre_dashboard.active_users_total_uuid_sum
    filters:
      bre_dashboard.source_family: activeusers
      bre_dashboard.reporting_date: 7 days ago for 7 days
    height: 3
    hidden_fields:
    - bre_dashboard.active_users_total_uuid_sum
    limit: 1
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.reporting_date
    model: bre_na
    name: na_7a_t01
    note_display: hover
    note_state: collapsed
    note_text: NA-7A-T01. Existing latest active-user snapshot, then reporting-date filtering.
    row: 0
    show_comparison: false
    show_single_value_title: false
    show_view_names: false
    title: Active Users out of Total
    type: single_value
    width: 24
  - name: na_7a_t02
    title: 'HER Expected vs Generation # - Expected Gen #'
    model: bre_na
    explore: bre_na_her_schedules
    type: single_value
    fields:
    - bre_na_her_schedules.total_eligible_users_sum
    filters:
      bre_na_her_schedules.date_range: 7 days ago for 7 days
    listen:
      Time Period: bre_na_her_schedules.date_range
      Pilot ID: bre_na_her_schedules.pilot_id
      Pilot Name: bre_na_her_schedules.pilot_name
      Fuel Type: bre_na_her_schedules.fuel_type
      Cluster IDs: bre_na_her_schedules.cluster_id
    row: 3
    col: 0
    width: 12
    height: 4
    limit: 1
    show_view_names: false
    note_display: hover
    note_state: collapsed
    show_comparison: false
    single_value_title: 'Expected Gen #'
    note_text: NA-7A-T02. Preserve latest schedule/quarter selection and full join to revoked users before applying
      dashboard analysis-date, fuel, and cluster filters.
  - name: na_7a_t03
    title: 'HER Expected vs Generation # - Total Actual Gen #'
    model: bre_na
    explore: bre_na_her_schedules
    type: single_value
    fields:
    - bre_na_her_schedules.total_generated_notification_id_sum
    filters:
      bre_na_her_schedules.date_range: 7 days ago for 7 days
    listen:
      Time Period: bre_na_her_schedules.date_range
      Pilot ID: bre_na_her_schedules.pilot_id
      Pilot Name: bre_na_her_schedules.pilot_name
      Fuel Type: bre_na_her_schedules.fuel_type
      Cluster IDs: bre_na_her_schedules.cluster_id
    row: 3
    col: 12
    width: 12
    height: 4
    limit: 1
    show_view_names: false
    note_display: hover
    note_state: collapsed
    show_comparison: false
    single_value_title: 'Total Actual Gen #'
    note_text: NA-7A-T03. Preserve latest schedule/quarter selection and full join to revoked users before applying
      dashboard analysis-date, fuel, and cluster filters.
  - name: na_7a_t04
    title: HER Schedule(s)
    model: bre_na
    explore: bre_na_her_schedules
    type: looker_grid
    fields:
    - bre_na_her_schedules.schedule_start
    - bre_na_her_schedules.schedule_end
    - bre_na_her_schedules.total_eligible_users_sum
    - bre_na_her_schedules.total_generated_notification_id_sum
    - bre_na_her_schedules.total_failed_notification_id_sum
    - bre_na_her_schedules.total_scheduled_notification_id_sum
    - bre_na_her_schedules.total_swept_notification_id_sum
    - bre_na_her_schedules.total_queued_notification_id_sum
    - bre_na_her_schedules.total_printed_notification_id_sum
    - bre_na_her_schedules.total_mailed_notification_id_sum
    - bre_na_her_schedules.total_revoked_notification_id_sum
    filters:
      bre_na_her_schedules.date_range: 7 days ago for 7 days
    listen:
      Time Period: bre_na_her_schedules.date_range
      Pilot ID: bre_na_her_schedules.pilot_id
      Pilot Name: bre_na_her_schedules.pilot_name
      Fuel Type: bre_na_her_schedules.fuel_type
      Cluster IDs: bre_na_her_schedules.cluster_id
    row: 7
    col: 0
    width: 24
    height: 8
    limit: 5000
    show_view_names: false
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_her_schedules.schedule_start
    - bre_na_her_schedules.schedule_end
    show_row_numbers: false
    note_text: NA-7A-T04. Preserve latest schedule/quarter selection and full join to revoked users before applying
      dashboard analysis-date, fuel, and cluster filters.
    series_labels:
      bre_na_her_schedules.schedule_start: Start
      bre_na_her_schedules.schedule_end: End
      bre_na_her_schedules.total_eligible_users_sum: 'Expt Gen #'
      bre_na_her_schedules.total_generated_notification_id_sum: 'Actual Gen #'
      bre_na_her_schedules.total_failed_notification_id_sum: 'Failed Gen #'
      bre_na_her_schedules.total_scheduled_notification_id_sum: 'Schld #'
      bre_na_her_schedules.total_swept_notification_id_sum: 'Swept #'
      bre_na_her_schedules.total_queued_notification_id_sum: 'Queued #'
      bre_na_her_schedules.total_printed_notification_id_sum: 'Printed #'
      bre_na_her_schedules.total_mailed_notification_id_sum: 'Mailed #'
      bre_na_her_schedules.total_revoked_notification_id_sum: 'Revoked #'
  - name: na_7a_t05
    title: HER Generation Daily Stats
    model: bre_na
    explore: bre_na_her_generation
    type: looker_column
    fields:
    - bre_na_her_generation.analysis_date
    - bre_na_her_generation.expected_eligible_users_sum
    - bre_na_her_generation.actual_eligible_users_sum
    - bre_na_her_generation.actual_generation_count_sum
    - bre_na_her_generation.success_pct
    filters:
      bre_na_her_generation.date_range: 7 days ago for 7 days
      bre_na_her_generation.period: Daily
    listen:
      Time Period: bre_na_her_generation.date_range
      Pilot ID: bre_na_her_generation.pilot_id
      Pilot Name: bre_na_her_generation.pilot_name
      Period: bre_na_her_generation.period
      Fuel Type: bre_na_her_generation.fuel_type
      Cluster IDs: bre_na_her_generation.cluster_id
    row: 15
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_her_generation.analysis_date
    show_view_names: false
    show_value_labels: false
    show_null_points: true
    x_axis_scale: time
    legend_position: center
    stacking: ''
    series_labels:
      bre_na_her_generation.expected_eligible_users_sum: Expected Generation Count
      bre_na_her_generation.actual_eligible_users_sum: Eligible Generation Count
      bre_na_her_generation.actual_generation_count_sum: Actual Generation Count
      bre_na_her_generation.success_pct: Success %
    series_types:
      bre_na_her_generation.success_pct: line
    note_display: hover
    note_state: collapsed
    note_text: NA-7A-T05. SRC-34 source-period count sums and user-confirmed ratio of summed actual generation to
      actual eligibility. Filters apply after source aggregation; weekly/monthly eligibility uses source MAX before
      chart SUM.
    y_axes:
    - label: Reports
      orientation: left
      series:
      - id: bre_na_her_generation.expected_eligible_users_sum
        axisId: bre_na_her_generation.expected_eligible_users_sum
        name: Expected Generation Count
      - id: bre_na_her_generation.actual_eligible_users_sum
        axisId: bre_na_her_generation.actual_eligible_users_sum
        name: Eligible Generation Count
      - id: bre_na_her_generation.actual_generation_count_sum
        axisId: bre_na_her_generation.actual_generation_count_sum
        name: Actual Generation Count
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
    - label: Success %
      orientation: right
      series:
      - id: bre_na_her_generation.success_pct
        axisId: bre_na_her_generation.success_pct
        name: Success %
      showLabels: true
      showValues: true
      type: linear
      unpinAxis: false
  - name: na_7a_t06
    title: Daily HER Quality Report (Only for HER 2.0**)
    model: bre_na
    explore: bre_na_her_quality
    type: looker_line
    fields:
    - bre_na_her_quality.analysis_date
    - bre_na_her_quality.low_bc_duration_cnt_sum
    - bre_na_her_quality.high_bc_duration_cnt_sum
    - bre_na_her_quality.staleness_cnt_sum
    - bre_na_her_quality.solar_template_cnt_sum
    - bre_na_her_quality.solar_consistency_cnt_sum
    - bre_na_her_quality.solar_generation_cnt_sum
    - bre_na_her_quality.report_consistency_cnt_sum
    - bre_na_her_quality.itemization_cnt_sum
    - bre_na_her_quality.bill_change_consistency_cnt_sum
    - bre_na_her_quality.ev_itemization_cnt_sum
    - bre_na_her_quality.tou_template_cnt_sum
    - bre_na_her_quality.nbi_occurence_cnt_sum
    - bre_na_her_quality.nbi_value_cnt_sum
    - bre_na_her_quality.nbi_appliance_itemization_cnt_sum
    - bre_na_her_quality.nbi_non_null_insight_cnt_sum
    - bre_na_her_quality.nbi_unicode_cnt_sum
    - bre_na_her_quality.nbi_extreme_insight_cnt_sum
    - bre_na_her_quality.nbi_seasonal_appliance_cnt_sum
    - bre_na_her_quality.overall_report_count_sum
    filters:
      bre_na_her_quality.date_range: 7 days ago for 7 days
      bre_na_her_quality.period: Daily
    listen:
      Time Period: bre_na_her_quality.date_range
      Pilot ID: bre_na_her_quality.pilot_id
      Pilot Name: bre_na_her_quality.pilot_name
      Period: bre_na_her_quality.period
    row: 23
    col: 0
    width: 24
    height: 11
    limit: 5000
    show_view_names: false
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_her_quality.analysis_date
    legend_position: center
    show_value_labels: false
    show_null_points: true
    series_labels:
      bre_na_her_quality.high_bc_duration_cnt_sum: 'BC > 70 days #'
      bre_na_her_quality.staleness_cnt_sum: 'Stale BC #'
      bre_na_her_quality.solar_template_cnt_sum: 'Solar Reports with Cost-based Section #'
      bre_na_her_quality.solar_consistency_cnt_sum: 'Solar Report for Non-Solar #'
      bre_na_her_quality.solar_generation_cnt_sum: 'Solar Estimation 0 or Null #'
      bre_na_her_quality.report_consistency_cnt_sum: 'Inconsistency Between Cost & Consumption Across Sections #'
      bre_na_her_quality.low_bc_duration_cnt_sum: 'BC < 23 days #'
      bre_na_her_quality.itemization_cnt_sum: 'Itemisation Mismatch #'
      bre_na_her_quality.bill_change_consistency_cnt_sum: 'Invalid Bill Change / Billing Data Cost Mismatch #'
      bre_na_her_quality.ev_itemization_cnt_sum: 'EV Report for EV Undetected in Itemisation #'
      bre_na_her_quality.tou_template_cnt_sum: 'TOU Report for Non-TOU BC #'
      bre_na_her_quality.nbi_occurence_cnt_sum: 'Missing NBI Unit/Format Token #'
      bre_na_her_quality.nbi_value_cnt_sum: 'Inconsistency in Insight Calculations (>10%) #'
      bre_na_her_quality.nbi_appliance_itemization_cnt_sum: 'Missing Appliances Referenced by NBI #'
      bre_na_her_quality.nbi_non_null_insight_cnt_sum: 'Missing or Invalid Numeric NBI Insight Value #'
      bre_na_her_quality.nbi_unicode_cnt_sum: 'Unicode in NBI Insights #'
      bre_na_her_quality.nbi_extreme_insight_cnt_sum: 'Extreme Insight Values #'
      bre_na_her_quality.nbi_seasonal_appliance_cnt_sum: 'Season-based Blocked Appliances in NBI #'
      bre_na_her_quality.overall_report_count_sum: 'Overall Report #'
    note_text: NA-7A-T06. Reporting-date filtering and source Period selection. No fuel/cluster fields exist in
      SRC-48. The inventory repeats bill_change_consistency_cnt under two labels; it appears once here. Source overall_report_count
      counts report_type = bad, as supplied.
  - name: na_7a_t07
    title: Daily HER Generation Failure Reasons
    model: bre_na
    explore: bre_na_her_failures
    type: looker_column
    fields:
    - bre_na_her_failures.analysis_date
    - bre_na_her_failures.calc_failure_reason
    - bre_na_her_failures.metric_toggle
    filters:
      bre_na_her_failures.date_range: 7 days ago for 7 days
      bre_na_her_failures.period: Daily
      bre_na_her_failures.metric: percentage
    listen:
      Time Period: bre_na_her_failures.date_range
      Pilot ID: bre_na_her_failures.pilot_id
      Pilot Name: bre_na_her_failures.pilot_name
      Fuel Type: bre_na_her_failures.fuel_type
      Cluster IDs: bre_na_her_failures.cluster_id
      Period: bre_na_her_failures.period
      Failure Metric: bre_na_her_failures.metric
    row: 34
    col: 0
    width: 24
    height: 8
    limit: 5000
    show_view_names: false
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_her_failures.analysis_date
    legend_position: center
    show_value_labels: false
    show_null_points: true
    pivots:
    - bre_na_her_failures.calc_failure_reason
    stacking: normal
    note_text: NA-7A-T07. Confirmed failure ratio of sums or count; NULL reasons become UNKNOWN. Source period buckets
      and repeated denominators retained; no top-N cutoff supplied.
  filters:
  - allow_multiple_values: false
    default_value: 7 days ago for 7 days
    explore: bre_na_her_failures
    field: bre_na_her_failures.date_range
    model: bre_na
    name: Time Period
    required: true
    title: Time Period
    type: field_filter
    ui_config:
      display: popover
      type: advanced
  - allow_multiple_values: false
    default_value: Daily
    explore: bre_na_her_failures
    field: bre_na_her_failures.period
    model: bre_na
    name: Period
    required: true
    title: Period
    type: field_filter
    ui_config:
      display: popover
      type: button_toggles
  - allow_multiple_values: true
    default_value: '10037'
    explore: bre_pilot_filters
    field: bre_pilots.pilot_id
    model: bre_na
    name: Pilot ID
    required: false
    title: Pilot ID
    type: field_filter
    ui_config:
      display: inline
      type: dropdown_menu
  - allow_multiple_values: true
    default_value: PSEG
    explore: bre_pilot_filters
    field: bre_pilots.pilot_name
    model: bre_na
    name: Pilot Name
    required: false
    title: Pilot Name
    type: field_filter
    ui_config:
      display: inline
      type: dropdown_menu
  - name: Fuel Type
    title: Fuel Type
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_her_failures
    field: bre_na_her_failures.fuel_type
    ui_config:
      type: tag_list
      display: popover
  - name: Cluster IDs
    title: Cluster IDs
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_her_failures
    field: bre_na_her_failures.cluster_id
    ui_config:
      type: tag_list
      display: popover
  - name: Failure Metric
    title: Failure Metric
    type: field_filter
    default_value: percentage
    allow_multiple_values: false
    required: true
    model: bre_na
    explore: bre_na_her_failures
    field: bre_na_her_failures.metric
    ui_config:
      type: button_toggles
      display: popover
