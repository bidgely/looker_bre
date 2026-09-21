# Email dashboard built tile by tile using shared views.
---
- dashboard: bre_eu_email
  title: BRE EU — Email
  description: EU email monitoring.
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
    listen: {}
    row: 0
    col: 0
    width: 24
    height: 3
    hidden_fields:
    - bre_dashboard.active_users_total_uuid_sum
    show_single_value_title: false
    show_comparison: false
    note_text: Latest reporting-date snapshot per pilot across all pilots. Dashboard controls do not affect this tile.
    note_display: hover
    note_state: collapsed
  - name: emails_average
    title: '# of Emails Sent Per Week — Average'
    model: bre_eu
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.email_statistics_emails_selected_average
    - bre_dashboard.email_statistics_emails_average_change
    - bre_dashboard.email_statistics_emails_previous_average
    filters:
      bre_dashboard.email_comparison_date_range: 7 days ago for 7 days
      bre_dashboard.email_in_comparison_window: 'Yes'
      bre_dashboard.source_family: emailstatistics
    limit: 1
    show_view_names: false
    listen:
      Email Type: bre_dashboard.email_type
      BC End Week#: bre_dashboard.bc_end_week_number
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.email_comparison_date_range
    row: 3
    col: 0
    width: 6
    height: 4
    hidden_fields:
    - bre_dashboard.email_statistics_emails_previous_average
    show_single_value_title: true
    single_value_title: Average emails sent
    show_comparison: true
    comparison_type: change
    comparison_label: vs previous equal-length period
    show_comparison_label: true
    note_text: Source-row average of cnt_bills_emails_sent, filtered by reporting_date. Comparison is percentage
      change versus the preceding equal-length date range; absent or zero previous values have no percentage change.
    note_display: hover
    note_state: collapsed
  - name: emails_median
    title: '# of Emails Sent Per Week — Median'
    model: bre_eu
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.email_statistics_emails_selected_median
    - bre_dashboard.email_statistics_emails_median_change
    - bre_dashboard.email_statistics_emails_previous_median
    filters:
      bre_dashboard.email_comparison_date_range: 7 days ago for 7 days
      bre_dashboard.email_in_comparison_window: 'Yes'
      bre_dashboard.source_family: emailstatistics
    limit: 1
    show_view_names: false
    listen:
      Email Type: bre_dashboard.email_type
      BC End Week#: bre_dashboard.bc_end_week_number
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.email_comparison_date_range
    row: 3
    col: 6
    width: 6
    height: 4
    hidden_fields:
    - bre_dashboard.email_statistics_emails_previous_median
    show_single_value_title: true
    single_value_title: Median emails sent
    show_comparison: true
    comparison_type: change
    comparison_label: vs previous equal-length period
    show_comparison_label: true
    note_text: Source-row median of cnt_bills_emails_sent, filtered by reporting_date. Comparison is percentage
      change versus the preceding equal-length date range; absent or zero previous values have no percentage change.
    note_display: hover
    note_state: collapsed
  - name: sent_pct_vs_expected
    title: 'Averages Sent % — vs Expected #'
    model: bre_eu
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.email_statistics_email_sent_pct_vs_expected_average
    filters:
      bre_dashboard.source_family: emailstatistics
      bre_dashboard.reporting_date: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Email Type: bre_dashboard.email_type
      BC End Week#: bre_dashboard.bc_end_week_number
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.reporting_date
    row: 3
    col: 12
    width: 6
    height: 4
    show_single_value_title: true
    single_value_title: 'vs Expected #'
    show_comparison: false
    value_format: 0.00"%"
    note_text: Average of row-level cnt_bills_emails_sent / cnt_expected_invoices * 100, filtered by reporting_date.
      Zero or NULL expected counts produce NULL ratios and are omitted from the average.
    note_display: hover
    note_state: collapsed
  - name: sent_pct_vs_eligible
    title: 'Averages Sent % — vs Eligible #'
    model: bre_eu
    explore: bre_dashboard
    type: single_value
    fields:
    - bre_dashboard.email_statistics_email_sent_pct_average
    filters:
      bre_dashboard.source_family: emailstatistics
      bre_dashboard.reporting_date: 7 days ago for 7 days
    limit: 1
    show_view_names: false
    listen:
      Email Type: bre_dashboard.email_type
      BC End Week#: bre_dashboard.bc_end_week_number
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.reporting_date
    row: 3
    col: 18
    width: 6
    height: 4
    show_single_value_title: true
    single_value_title: 'vs Eligible #'
    show_comparison: false
    value_format: 0.00"%"
    note_text: Average of source email_sent_pct, filtered by reporting_date. Source percentages are displayed without
      rescaling or weighting.
    note_display: hover
    note_state: collapsed
  - name: email_delivery_statistics
    title: Email Delivery Statistics
    model: bre_eu
    explore: bre_email_delivery
    type: looker_column
    fields:
    - bre_email_delivery.email_period_date
    - bre_email_delivery.daily_eligible
    - bre_email_delivery.daily_generated
    - bre_email_delivery.daily_sent
    - bre_email_delivery.weekly_expected
    - bre_email_delivery.weekly_eligible
    - bre_email_delivery.weekly_sent
    - bre_email_delivery.weekly_sent_vs_eligible
    - bre_email_delivery.weekly_sent_vs_expected
    filters:
      bre_email_delivery.blend_date_range: 7 days ago for 7 days
      bre_email_delivery.period: Daily
    limit: 5000
    show_view_names: false
    listen:
      Email Type: bre_email_delivery.email_type
      BC End Week#: bre_email_delivery.blend_bc_end_week_number
      Pilot ID: bre_email_delivery.blend_pilot_id
      Pilot Name: bre_email_delivery.blend_pilot_name
      Time Period: bre_email_delivery.blend_date_range
      Period: bre_email_delivery.period
    row: 7
    col: 0
    width: 24
    height: 8
    sorts:
    - bre_email_delivery.email_period_date
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
      bre_email_delivery.daily_eligible: 'Daily Eligible Invoices #'
      bre_email_delivery.daily_generated: 'Daily Email Generation #'
      bre_email_delivery.daily_sent: 'Daily Email Sent #'
      bre_email_delivery.weekly_expected: 'Weekly Expected Email #'
      bre_email_delivery.weekly_eligible: 'Weekly Eligible User #'
      bre_email_delivery.weekly_sent: 'Weekly Email Sent #'
      bre_email_delivery.weekly_sent_vs_eligible: Weekly Tracker Email Sent vs Eligible %
      bre_email_delivery.weekly_sent_vs_expected: Weekly Tracker Email Sent vs Expected %
    series_types:
      bre_email_delivery.daily_eligible: line
      bre_email_delivery.daily_generated: line
      bre_email_delivery.weekly_sent: line
    y_axes:
    - label: Count
      orientation: left
      series:
      - id: bre_email_delivery.daily_eligible
        name: 'Daily Eligible Invoices #'
        axisId: bre_email_delivery.daily_eligible
      - id: bre_email_delivery.daily_generated
        name: 'Daily Email Generation #'
        axisId: bre_email_delivery.daily_generated
      - id: bre_email_delivery.daily_sent
        name: 'Daily Email Sent #'
        axisId: bre_email_delivery.daily_sent
      - id: bre_email_delivery.weekly_expected
        name: 'Weekly Expected Email #'
        axisId: bre_email_delivery.weekly_expected
      - id: bre_email_delivery.weekly_eligible
        name: 'Weekly Eligible User #'
        axisId: bre_email_delivery.weekly_eligible
      - id: bre_email_delivery.weekly_sent
        name: 'Weekly Email Sent #'
        axisId: bre_email_delivery.weekly_sent
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    - label: Sent %
      orientation: right
      series:
      - id: bre_email_delivery.weekly_sent_vs_eligible
        name: Weekly Tracker Email Sent vs Eligible %
        axisId: bre_email_delivery.weekly_sent_vs_eligible
      - id: bre_email_delivery.weekly_sent_vs_expected
        name: Weekly Tracker Email Sent vs Expected %
        axisId: bre_email_delivery.weekly_sent_vs_expected
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    series_value_format:
      bre_email_delivery.weekly_sent_vs_eligible: 0.00"%"
      bre_email_delivery.weekly_sent_vs_expected: 0.00"%"
    note_text: Full outer blend on email type and analysis date. Time Period filters analysis_date in both sources.
      Daily counts are sums; weekly metrics are source-row averages across the selected Period. Dates from either
      source are retained. BC End Week# filters only the five Statistics series; the three Daily Tracker
      series do not have a billing-week field and remain unaffected by that control.
    note_display: hover
    note_state: collapsed
  - name: weekly_email_reco_quality
    title: Weekly Email Reco Quality Report
    model: bre_eu
    explore: bre_dashboard
    type: looker_column
    fields:
    - bre_dashboard.email_period_date
    - bre_dashboard.metric_name
    - bre_dashboard.email_recommendations_notification_pct_average
    pivots:
    - bre_dashboard.metric_name
    filters:
      bre_dashboard.source_family: emailrecommendations
      bre_dashboard.reporting_date: 7 days ago for 7 days
      bre_dashboard.period: Daily
    limit: 5000
    column_limit: 200
    show_view_names: false
    listen:
      Email Type: bre_dashboard.email_type
      BC End Week#: bre_dashboard.bc_end_week_number
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.reporting_date
      Period: bre_dashboard.period
    row: 15
    col: 0
    width: 24
    height: 8
    sorts:
    - bre_dashboard.email_period_date
    - bre_dashboard.metric_name
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
      bre_dashboard.email_recommendations_notification_pct_average: '% Emails'
    value_format: '0.00"%"'
    note_text: Average source notification_pct by metric_name. Time Period filters reporting_date;
      Analysis Date follows Daily, Weekly (Sunday start), or Monthly Period selection. Source percentages
      are displayed without rescaling or weighting.
    note_display: hover
    note_state: collapsed
  - name: weekly_email_failure_reasons
    title: Weekly Top Email Failure Reasons
    model: bre_eu
    explore: bre_dashboard
    type: looker_column
    fields:
    - bre_dashboard.email_period_date
    - bre_dashboard.failure_reason
    - bre_dashboard.email_failures_failure_count_average
    pivots:
    - bre_dashboard.failure_reason
    filters:
      bre_dashboard.source_family: emailfailures
      bre_dashboard.source_rank: '<=3'
      bre_dashboard.reporting_date: 7 days ago for 7 days
      bre_dashboard.period: Daily
    limit: 5000
    column_limit: 200
    show_view_names: false
    listen:
      Email Type: bre_dashboard.email_type
      BC End Week#: bre_dashboard.bc_end_week_number
      Pilot ID: bre_dashboard.pilot_id
      Pilot Name: bre_dashboard.pilot_name
      Time Period: bre_dashboard.reporting_date
      Period: bre_dashboard.period
    row: 23
    col: 0
    width: 24
    height: 8
    sorts:
    - bre_dashboard.email_period_date
    - bre_dashboard.failure_reason
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
      bre_dashboard.email_failures_failure_count_average: Failure Count
    note_text: Average failure_count by failure_reason, filtered by reporting_date and source rank <= 3.
      Ranking is per original analysis date, pilot and email type before Daily/Weekly/Monthly grouping;
      more than three reasons can appear across selected dates, pilots and email types.
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
    field: bre_dashboard.reporting_date
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
  - name: Email Type
    title: Email Type
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: bre_eu
    explore: bre_email_type_filters
    field: bre_email_tracker.email_type
  - name: BC End Week#
    title: BC End Week#
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: bre_eu
    explore: bre_email_week_filters
    field: bre_email_statistics.bc_end_week_number
