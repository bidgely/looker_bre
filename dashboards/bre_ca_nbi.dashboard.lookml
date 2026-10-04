# CA-only NBI dashboard; additional tiles will be defined with the user.
---
- dashboard: bre_ca_nbi
  title: BRE CA — NBI
  description: CA NBI monitoring.
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
  - name: insight_generation_average
    title: '# of NBI Insight Generation — On Average'
    model: bre_ca
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.nbi_generation_users_selected_average
    - bre_dashboard.nbi_generation_users_average_change
    - bre_dashboard.nbi_generation_users_previous_average
    filters:
      bre_dashboard.source_family: nbigeneration
      bre_dashboard.nbi_in_comparison_window: 'Yes'
      bre_dashboard.nbi_comparison_date_range: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.nbi_comparison_date_range
    row: 3
    col: 0
    width: 12
    height: 4
    hidden_fields:
    - bre_dashboard.nbi_generation_users_previous_average
    show_single_value_title: true
    single_value_title: On Average
    show_comparison: true
    comparison_type: change
    comparison_label: vs previous equal-length period
    show_comparison_label: true
    note_text: Source-row average. Comparison is percentage change versus the preceding equal-length date range;
      absent or zero previous values have no percentage change.
    note_display: hover
    note_state: collapsed
  - name: insight_generation_median
    title: '# of NBI Insight Generation — Median'
    model: bre_ca
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.nbi_generation_users_selected_median
    - bre_dashboard.nbi_generation_users_median_change
    - bre_dashboard.nbi_generation_users_previous_median
    filters:
      bre_dashboard.source_family: nbigeneration
      bre_dashboard.nbi_in_comparison_window: 'Yes'
      bre_dashboard.nbi_comparison_date_range: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.nbi_comparison_date_range
    row: 3
    col: 12
    width: 12
    height: 4
    hidden_fields:
    - bre_dashboard.nbi_generation_users_previous_median
    show_single_value_title: true
    single_value_title: Median
    show_comparison: true
    comparison_type: change
    comparison_label: vs previous equal-length period
    show_comparison_label: true
    note_text: Source-row median. Comparison is percentage change versus the preceding equal-length date range;
      absent or zero previous values have no percentage change.
    note_display: hover
    note_state: collapsed
  - name: format_error
    title: Failure Distribution — Format Error
    model: bre_ca
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.nbi_generation_nbi_200_error_pct_average
    filters:
      bre_dashboard.source_family: nbigeneration
      bre_dashboard.analysis_date: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Time Period: bre_dashboard.analysis_date
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
    row: 7
    col: 0
    width: 12
    height: 4
    show_single_value_title: true
    single_value_title: Format Error
    show_comparison: false
    value_format: '0.00%'
    note_text: Average of each source row's 200-error count divided by its combined 200/300-error count.
      Rows with zero or NULL total failures are omitted. Time Period filters analysis_date.
    note_display: hover
    note_state: collapsed
  - name: value_error
    title: Failure Distribution — Value Error
    model: bre_ca
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.nbi_generation_nbi_300_error_pct_average
    filters:
      bre_dashboard.source_family: nbigeneration
      bre_dashboard.analysis_date: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Time Period: bre_dashboard.analysis_date
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
    row: 7
    col: 12
    width: 12
    height: 4
    show_single_value_title: true
    single_value_title: Value Error
    show_comparison: false
    value_format: '0.00%'
    note_text: Average of each source row's 300-error count divided by its combined 200/300-error count.
      Rows with zero or NULL total failures are omitted. Time Period filters analysis_date.
    note_display: hover
    note_state: collapsed
  - name: daily_nbi_generation_statistics
    title: Daily NBI Generation Statistics
    model: bre_ca
    explore: bre_dashboard
    type: looker_column
    fields:
    - bre_dashboard.nbi_period_date
    - bre_dashboard.nbi_generation_total_users_nbi_generated_average
    - bre_dashboard.nbi_generation_total_users_successful_average
    - bre_dashboard.nbi_generation_nbi_success_pc_average
    filters:
      bre_dashboard.source_family: nbigeneration
      bre_dashboard.period: Daily
      bre_dashboard.analysis_date: 7 days ago for 7 days
    sorts:
    - bre_dashboard.nbi_period_date
    limit: 5000
    show_view_names: false
    listen:
      Time Period: bre_dashboard.analysis_date
      Period: bre_dashboard.period
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
    row: 11
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
      bre_dashboard.nbi_generation_total_users_nbi_generated_average: 'Total Users NBI Generated'
      bre_dashboard.nbi_generation_total_users_successful_average: 'Successful Generation #'
      bre_dashboard.nbi_generation_nbi_success_pc_average: Success %
    series_types:
      bre_dashboard.nbi_generation_nbi_success_pc_average: line
    y_axes:
    - label: Count
      orientation: left
      series:
      - id: bre_dashboard.nbi_generation_total_users_nbi_generated_average
        name: 'Total Users NBI Generated'
        axisId: bre_dashboard.nbi_generation_total_users_nbi_generated_average
      - id: bre_dashboard.nbi_generation_total_users_successful_average
        name: 'Successful Generation #'
        axisId: bre_dashboard.nbi_generation_total_users_successful_average
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    - label: Success %
      orientation: right
      series:
      - id: bre_dashboard.nbi_generation_nbi_success_pc_average
        name: Success %
        axisId: bre_dashboard.nbi_generation_nbi_success_pc_average
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    series_value_format:
      bre_dashboard.nbi_generation_nbi_success_pc_average: 0.00"%"
    note_text: Time Period filters analysis_date before Daily/Weekly/Monthly grouping; weeks begin Sunday.
      All series are source-row averages. Total Users NBI Generated is successful users plus 200/300-error users;
      Success % is 100 minus source nbi_error_pct. Source NULLs are preserved.
    note_display: hover
    note_state: collapsed
  - name: daily_nbi_users_count_with_generic_tag
    title: Daily NBI Users Count With Generic Tag
    model: bre_ca
    explore: bre_dashboard
    type: looker_column
    fields:
    - bre_dashboard.nbi_period_date
    - bre_dashboard.nbi_generic_tags_total_nbi_users_with_generic_tag_sum
    filters:
      bre_dashboard.source_family: nbigenerictags
      bre_dashboard.period: Daily
      bre_dashboard.analysis_date: 7 days ago for 7 days
    sorts:
    - bre_dashboard.nbi_period_date
    limit: 5000
    show_view_names: false
    listen:
      Time Period: bre_dashboard.analysis_date
      Period: bre_dashboard.period
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
    row: 19
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
      bre_dashboard.nbi_generic_tags_total_nbi_users_with_generic_tag_sum: 'NBI Users# with Generic Tag'
    value_format: '#,##0'
    note_text: Sum of total_nbi_users_with_generic_tag from SRE NBI Gen Quality Generic tag.
      Time Period filters analysis_date before Daily/Weekly/Monthly grouping; weeks begin Sunday.
    note_display: hover
    note_state: collapsed
  - name: daily_top_nbi_failure_reasons_statistics
    title: Daily Top NBI Failure Reasons Statistics
    model: bre_ca
    explore: bre_dashboard
    type: looker_column
    fields:
    - bre_dashboard.nbi_period_date
    - bre_dashboard.nbi_generation_total_users_with_200_errorcode_average
    - bre_dashboard.nbi_generation_total_users_with_300_errorcode_average
    filters:
      bre_dashboard.source_family: nbigeneration
      bre_dashboard.period: Daily
      bre_dashboard.analysis_date: 7 days ago for 7 days
    sorts:
    - bre_dashboard.nbi_period_date
    limit: 5000
    show_view_names: false
    listen:
      Time Period: bre_dashboard.analysis_date
      Period: bre_dashboard.period
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
    row: 27
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
      bre_dashboard.nbi_generation_total_users_with_200_errorcode_average: 'NBI_FORMAT_ERROR (200)'
      bre_dashboard.nbi_generation_total_users_with_300_errorcode_average: 'NBI_VALUE_ERROR (300)'
    value_format: '#,##0.00'
    note_text: Average source-row 200 and 300 error counts, stacked by error category.
      Time Period filters analysis_date before Daily/Weekly/Monthly grouping; weeks begin Sunday.
      No rank restriction is applied.
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
    model: bre_ca
    explore: bre_dashboard
    field: bre_dashboard.period
  - name: Pilot ID
    title: Pilot ID
    type: field_filter
    default_value: '40001'
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    model: bre_ca
    explore: bre_pilot_filters
    field: bre_pilots.pilot_id
  - name: Pilot Name
    title: Pilot Name
    type: field_filter
    default_value: 'HONI'
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    model: bre_ca
    explore: bre_pilot_filters
    field: bre_pilots.pilot_name
