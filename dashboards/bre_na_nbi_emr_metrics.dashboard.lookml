# NA NBI: data_studio_files/bre_na_nbi_implementation.md
---
- layout: newspaper
  preferred_viewer: dashboards-next
  crossfilter_enabled: false
  dashboard: bre_na_nbi_emr_metrics
  title: BRE NA — NBI EMR Metrics
  description: NA NBI EMR metrics. All eight tiles implemented; native Looker and original-report validation pending.
  elements:
  - name: na_8b_t01
    title: Key KPIs - Total Jobs
    model: bre_na
    explore: bre_na_nbi_emr
    type: single_value
    fields:
    - bre_na_nbi_emr.cluster_id_count
    filters:
      bre_na_nbi_emr.date_range: 7 days ago for 7 days
    listen:
      Time Period: bre_na_nbi_emr.date_range
      Pilot ID: bre_na_nbi_emr.pilot_id
      Pilot Name: bre_na_nbi_emr.pilot_name
    row: 0
    col: 0
    width: 6
    height: 4
    limit: 1
    show_view_names: false
    show_comparison: false
    show_single_value_title: true
    single_value_title: Total Jobs
    note_display: hover
    note_state: collapsed
    note_text: NA-8B-T01. COUNT(cluster_id), as documented; counts repeated cluster IDs and omits NULL IDs.
  - name: na_8b_t02
    title: Key KPIs - Success Rate
    model: bre_na
    explore: bre_na_nbi_emr
    type: single_value
    fields:
    - bre_na_nbi_emr.success_rate_perc
    filters:
      bre_na_nbi_emr.date_range: 7 days ago for 7 days
    listen:
      Time Period: bre_na_nbi_emr.date_range
      Pilot ID: bre_na_nbi_emr.pilot_id
      Pilot Name: bre_na_nbi_emr.pilot_name
    row: 0
    col: 6
    width: 6
    height: 4
    limit: 1
    show_view_names: false
    show_comparison: false
    show_single_value_title: true
    single_value_title: Success Rate
    note_display: hover
    note_state: collapsed
    note_text: NA-8B-T02. Source success_rate_perc includes RUNNING and TERMINATED with ALL_STEPS_COMPLETED. It
      is a status-row rate, not the proportion of complete three-stage pipelines. Source aggregate formula evaluated
      at the tile grain; no nested AVG applied.
  - name: na_8b_t03
    title: Key KPIs - Failure Rate
    model: bre_na
    explore: bre_na_nbi_emr
    type: single_value
    fields:
    - bre_na_nbi_emr.failure_rate_perc
    filters:
      bre_na_nbi_emr.date_range: 7 days ago for 7 days
    listen:
      Time Period: bre_na_nbi_emr.date_range
      Pilot ID: bre_na_nbi_emr.pilot_id
      Pilot Name: bre_na_nbi_emr.pilot_name
    row: 0
    col: 12
    width: 6
    height: 4
    limit: 1
    show_view_names: false
    show_comparison: false
    show_single_value_title: true
    single_value_title: Failure Rate
    note_display: hover
    note_state: collapsed
    note_text: NA-8B-T03. Source failure_rate_perc counts FAILED, TERMINATED_WITH_ERRORS, CANCELLED, INTERRUPTED
      over non-NULL statuses. Missing stages are only evaluated by SRC-18. Source aggregate formula evaluated at
      the tile grain; no nested AVG applied.
  - name: na_8b_t04
    title: Key KPIs - Average Job Duration
    model: bre_na
    explore: bre_na_nbi_emr
    type: single_value
    fields:
    - bre_na_nbi_emr.duration_hh_mm_ss
    filters:
      bre_na_nbi_emr.date_range: 7 days ago for 7 days
    listen:
      Time Period: bre_na_nbi_emr.date_range
      Pilot ID: bre_na_nbi_emr.pilot_id
      Pilot Name: bre_na_nbi_emr.pilot_name
    row: 0
    col: 18
    width: 6
    height: 4
    limit: 1
    show_view_names: false
    show_comparison: false
    show_single_value_title: true
    single_value_title: Average duration (hh:mm:ss)
    note_display: hover
    note_state: collapsed
    note_text: NA-8B-T04. AVG(duration_seconds), rounded to whole seconds and displayed as hh:mm:ss; hours do not
      wrap after 24.
  - model: bre_na
    explore: bre_na_nbi_emr_blend
    type: looker_column
    filters:
      bre_na_nbi_emr_blend.date_range: 7 days ago for 7 days
      bre_na_nbi_emr_blend.period: Daily
    listen:
      Time Period: bre_na_nbi_emr_blend.date_range
      Pilot ID: bre_na_nbi_emr_blend.pilot_id
      Pilot Name: bre_na_nbi_emr_blend.pilot_name
      Period: bre_na_nbi_emr_blend.period
    col: 0
    width: 24
    height: 8
    limit: 5000
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    note_display: hover
    note_state: collapsed
    name: na_8b_t05
    title: Trends - Job Execution Overview
    row: 4
    fields:
    - bre_na_nbi_emr_blend.period_date
    - bre_na_nbi_emr_blend.cluster_type
    - bre_na_nbi_emr_blend.duration_seconds_average
    pivots:
    - bre_na_nbi_emr_blend.cluster_type
    sorts:
    - bre_na_nbi_emr_blend.period_date
    - bre_na_nbi_emr_blend.cluster_type
    stacking: ''
    y_axis_labels:
    - Duration (seconds)
    note_text: NA-8B-T05. Average of input-group average durations, by period and cluster type. Only rows matched
      across all three sources are included.
  - model: bre_na
    explore: bre_na_nbi_emr_blend
    type: looker_column
    filters:
      bre_na_nbi_emr_blend.date_range: 7 days ago for 7 days
      bre_na_nbi_emr_blend.period: Daily
    listen:
      Time Period: bre_na_nbi_emr_blend.date_range
      Pilot ID: bre_na_nbi_emr_blend.pilot_id
      Pilot Name: bre_na_nbi_emr_blend.pilot_name
      Period: bre_na_nbi_emr_blend.period
    col: 0
    width: 24
    height: 8
    limit: 5000
    show_view_names: false
    show_null_points: true
    show_value_labels: false
    legend_position: center
    x_axis_scale: time
    note_display: hover
    note_state: collapsed
    name: na_8b_t06
    title: Trends - NBI Failure Statistics Correlation
    row: 12
    fields:
    - bre_na_nbi_emr_blend.analysis_date
    - bre_na_nbi_emr_blend.failure_count_sum
    - bre_na_nbi_emr_blend.nbi_error_pct_average
    - bre_na_nbi_emr_blend.is_failed_sum
    - bre_na_nbi_emr_blend.failure_rate_perc_average
    sorts:
    - bre_na_nbi_emr_blend.analysis_date
    stacking: ''
    series_types:
      bre_na_nbi_emr_blend.nbi_error_pct_average: line
      bre_na_nbi_emr_blend.failure_rate_perc_average: line
    series_colors:
      bre_na_nbi_emr_blend.failure_count_sum: '#5B8FF9'
      bre_na_nbi_emr_blend.is_failed_sum: '#DC2626'
      bre_na_nbi_emr_blend.nbi_error_pct_average: '#F6BD16'
      bre_na_nbi_emr_blend.failure_rate_perc_average: '#945FB9'
    note_text: NA-8B-T06. Daily failures and rates from the confirmed blend. Daily generation and failed-job counts
      repeat across matching EMR groups, matching the report. The duplicated inventory entry for NBI error percentage
      is shown once.
    y_axes:
    - label: Count
      orientation: left
      showLabels: true
      showValues: true
      series:
      - id: bre_na_nbi_emr_blend.failure_count_sum
        name: 'Failed Generation #'
      - id: bre_na_nbi_emr_blend.is_failed_sum
        name: 'EMR Failed Jobs #'
    - label: Failure %
      orientation: right
      showLabels: true
      showValues: true
      series:
      - id: bre_na_nbi_emr_blend.nbi_error_pct_average
        name: Failed Generation %
      - id: bre_na_nbi_emr_blend.failure_rate_perc_average
        name: EMR Job Failure %
  - name: na_8b_t07
    title: Trends - Failed Jobs vs Total Runs
    model: bre_na
    explore: bre_na_nbi_emr_scatter
    type: looker_scatter
    fields:
    - bre_na_nbi_emr_scatter.analysis_date
    - bre_na_nbi_emr_scatter.failed_jobs
    - bre_na_nbi_emr_scatter.total_runs_value
    - bre_na_nbi_emr_scatter.nbi_error_pct_value
    hidden_fields:
    - bre_na_nbi_emr_scatter.analysis_date
    filters:
      bre_na_nbi_emr_scatter.date_range: 7 days ago for 7 days
    listen:
      Time Period: bre_na_nbi_emr_scatter.date_range
      Pilot ID: bre_na_nbi_emr_scatter.pilot_id
      Pilot Name: bre_na_nbi_emr_scatter.pilot_name
    row: 20
    col: 0
    width: 24
    height: 8
    limit: 5000
    sorts:
    - bre_na_nbi_emr_scatter.analysis_date
    size_by_field: bre_na_nbi_emr_scatter.nbi_error_pct_value
    plot_size_by_field: false
    x_axis_scale: linear
    x_axis_label: 'Failed Jobs #'
    y_axis_labels:
    - 'Total Jobs Run #'
    point_style: circle
    show_view_names: false
    show_null_points: false
    cluster_points: false
    note_display: hover
    note_state: collapsed
    note_text: NA-8B-T07. One point per analysis date. X = SUM(is_failed), Y = SUM(stages_present), bubble size
      = AVG(nbi_error_pct), after the confirmed blend. Repeated counts across EMR groups are retained. Period does
      not rebucket this date-level chart.
  - name: na_8b_t08
    title: Trends - Details
    model: bre_na
    explore: bre_na_nbi_emr
    type: looker_grid
    fields:
    - bre_na_nbi_emr.module_name
    - bre_na_nbi_emr.cluster_id
    - bre_na_nbi_emr.creation_time
    - bre_na_nbi_emr.end_time
    - bre_na_nbi_emr.cluster_type
    - bre_na_nbi_emr.metric_value
    - bre_na_nbi_emr.reason_code
    - bre_na_nbi_emr.steps_status
    - bre_na_nbi_emr.duration_seconds_sum
    filters:
      bre_na_nbi_emr.date_range: 7 days ago for 7 days
      bre_na_nbi_emr.metric_value: -RUNNING
    listen:
      Time Period: bre_na_nbi_emr.date_range
      Pilot ID: bre_na_nbi_emr.pilot_id
      Pilot Name: bre_na_nbi_emr.pilot_name
    row: 28
    col: 0
    width: 24
    height: 10
    limit: 5000
    sorts:
    - bre_na_nbi_emr.creation_time desc
    show_view_names: false
    show_row_numbers: true
    note_display: hover
    note_state: collapsed
    note_text: NA-8B-T08. Source timestamps displayed in UTC with time retained; SUM(duration_seconds). Excludes
      RUNNING; the documented RUNNNIG is interpreted as a typo, pending confirmation.
    series_labels:
      bre_na_nbi_emr.module_name: Module
      bre_na_nbi_emr.cluster_id: 'Cluster #'
      bre_na_nbi_emr.creation_time: Creation Time (UTC)
      bre_na_nbi_emr.end_time: End Time (UTC)
      bre_na_nbi_emr.cluster_type: 'Stage #'
      bre_na_nbi_emr.metric_value: Status
      bre_na_nbi_emr.reason_code: Reason
      bre_na_nbi_emr.steps_status: Step Status
      bre_na_nbi_emr.duration_seconds_sum: Duration (seconds)
  filters:
  - allow_multiple_values: false
    default_value: 7 days ago for 7 days
    explore: bre_na_nbi_emr
    field: bre_na_nbi_emr.date_range
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
    explore: bre_na_nbi_emr_blend
    field: bre_na_nbi_emr_blend.period
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
