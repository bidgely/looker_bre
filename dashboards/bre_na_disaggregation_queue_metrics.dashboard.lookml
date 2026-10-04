# NA 3b Queue Metrics Disaggregation
---
- crossfilter_enabled: false
  dashboard: bre_na_disaggregation_queue_metrics
  description: NA queue metrics for Disaggregation, Aggregation, and UploadEventSplitter. Draft pending Looker and
    source-report validation.
  elements:
  - name: na_3b_t01
    title: Key KPIs - Environment Health Score
    model: bre_na
    explore: bre_na_disaggregation_queue_health
    type: single_value
    fields:
    - bre_na_disaggregation_queue_health.health_score_average
    filters:
      bre_na_disaggregation_queue_health.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_disaggregation_queue_health.module_name
      Queue Name: bre_na_disaggregation_queue_health.queue_name
      Queue Type: bre_na_disaggregation_queue_health.queue_type
      Environment: bre_na_disaggregation_queue_health.environment
      Time Period: bre_na_disaggregation_queue_health.date_range
    row: 0
    col: 0
    width: 8
    height: 4
    limit: 1
    show_view_names: false
    note_text: NA-3B-T01. Fixed module_name IN (Disaggregation, Aggregation, UploadEventSplitter). UTC date, environment,
      module, and queue filters apply before source aggregation.
    note_display: hover
    note_state: collapsed
  - name: na_3b_t02
    title: Key KPIs - Total Message Volume
    model: bre_na
    explore: bre_na_disaggregation_queue_hourly
    type: looker_line
    fields:
    - bre_na_disaggregation_queue_hourly.bucket_hour
    - bre_na_disaggregation_queue_hourly.total_messages_received_sum
    filters:
      bre_na_disaggregation_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_disaggregation_queue_hourly.module_name
      Queue Name: bre_na_disaggregation_queue_hourly.queue_name
      Queue Type: bre_na_disaggregation_queue_hourly.queue_type
      Environment: bre_na_disaggregation_queue_hourly.environment
      Time Period: bre_na_disaggregation_queue_hourly.date_range
    row: 0
    col: 8
    width: 16
    height: 4
    limit: 5000
    show_view_names: false
    note_text: NA-3B-T02. Fixed module_name IN (Disaggregation, Aggregation, UploadEventSplitter). UTC date, environment,
      module, and queue filters apply before source aggregation. SRC-01 retains its rolling seven-day history limit.
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_disaggregation_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_3b_t03
    title: Key KPIs - Disagg Success Rate
    model: bre_na
    explore: bre_na_disaggregation_queue_hourly
    type: single_value
    fields:
    - bre_na_disaggregation_queue_hourly.success_rate_average
    filters:
      bre_na_disaggregation_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_disaggregation_queue_hourly.module_name
      Queue Name: bre_na_disaggregation_queue_hourly.queue_name
      Queue Type: bre_na_disaggregation_queue_hourly.queue_type
      Environment: bre_na_disaggregation_queue_hourly.environment
      Time Period: bre_na_disaggregation_queue_hourly.date_range
    row: 4
    col: 0
    width: 12
    height: 4
    limit: 1
    show_view_names: false
    note_text: NA-3B-T03. Fixed module_name IN (Disaggregation, Aggregation, UploadEventSplitter). UTC date, environment,
      module, and queue filters apply before source aggregation. SRC-01 retains its rolling seven-day history limit.
      Uses AVG of source success_rate, consistent with Ingestion; original chart aggregation is not specified.
    note_display: hover
    note_state: collapsed
  - name: na_3b_t04
    title: Key KPIs - Queue Backlog Volume
    model: bre_na
    explore: bre_na_disaggregation_queue_hourly
    type: single_value
    fields:
    - bre_na_disaggregation_queue_hourly.avg_queue_backlog_average
    filters:
      bre_na_disaggregation_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_disaggregation_queue_hourly.module_name
      Queue Name: bre_na_disaggregation_queue_hourly.queue_name
      Queue Type: bre_na_disaggregation_queue_hourly.queue_type
      Environment: bre_na_disaggregation_queue_hourly.environment
      Time Period: bre_na_disaggregation_queue_hourly.date_range
    row: 4
    col: 12
    width: 12
    height: 4
    limit: 1
    show_view_names: false
    note_text: NA-3B-T04. Fixed module_name IN (Disaggregation, Aggregation, UploadEventSplitter). UTC date, environment,
      module, and queue filters apply before source aggregation. SRC-01 retains its rolling seven-day history limit.
    note_display: hover
    note_state: collapsed
  - name: na_3b_t05
    title: Trends - Message Volume Over Time
    model: bre_na
    explore: bre_na_disaggregation_queue_hourly
    type: looker_line
    fields:
    - bre_na_disaggregation_queue_hourly.bucket_hour
    - bre_na_disaggregation_queue_hourly.total_messages_received_sum
    filters:
      bre_na_disaggregation_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_disaggregation_queue_hourly.module_name
      Queue Name: bre_na_disaggregation_queue_hourly.queue_name
      Queue Type: bre_na_disaggregation_queue_hourly.queue_type
      Environment: bre_na_disaggregation_queue_hourly.environment
      Time Period: bre_na_disaggregation_queue_hourly.date_range
    row: 8
    col: 0
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: NA-3B-T05. Fixed module_name IN (Disaggregation, Aggregation, UploadEventSplitter). UTC date, environment,
      module, and queue filters apply before source aggregation. SRC-01 retains its rolling seven-day history limit.
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_disaggregation_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_3b_t06
    title: 'Trends - Queue Size: Backlog Volume Over Time'
    model: bre_na
    explore: bre_na_disaggregation_queue_hourly
    type: looker_line
    fields:
    - bre_na_disaggregation_queue_hourly.bucket_hour
    - bre_na_disaggregation_queue_hourly.avg_queue_backlog_average
    filters:
      bre_na_disaggregation_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_disaggregation_queue_hourly.module_name
      Queue Name: bre_na_disaggregation_queue_hourly.queue_name
      Queue Type: bre_na_disaggregation_queue_hourly.queue_type
      Environment: bre_na_disaggregation_queue_hourly.environment
      Time Period: bre_na_disaggregation_queue_hourly.date_range
    row: 8
    col: 12
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: NA-3B-T06. Fixed module_name IN (Disaggregation, Aggregation, UploadEventSplitter). UTC date, environment,
      module, and queue filters apply before source aggregation. SRC-01 retains its rolling seven-day history limit.
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_disaggregation_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_3b_t07
    title: Trends - Oldest Messages Over Time
    model: bre_na
    explore: bre_na_disaggregation_queue_hourly
    type: looker_line
    fields:
    - bre_na_disaggregation_queue_hourly.bucket_hour
    - bre_na_disaggregation_queue_hourly.max_latency_days_max
    filters:
      bre_na_disaggregation_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_disaggregation_queue_hourly.module_name
      Queue Name: bre_na_disaggregation_queue_hourly.queue_name
      Queue Type: bre_na_disaggregation_queue_hourly.queue_type
      Environment: bre_na_disaggregation_queue_hourly.environment
      Time Period: bre_na_disaggregation_queue_hourly.date_range
    row: 15
    col: 0
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: NA-3B-T07. Fixed module_name IN (Disaggregation, Aggregation, UploadEventSplitter). UTC date, environment,
      module, and queue filters apply before source aggregation. SRC-01 retains its rolling seven-day history limit.
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_disaggregation_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_3b_t08
    title: Trends - Health Score by Queue Name
    model: bre_na
    explore: bre_na_disaggregation_queue_health
    type: looker_column
    fields:
    - bre_na_disaggregation_queue_health.bucket_date
    - bre_na_disaggregation_queue_health.queue_name
    - bre_na_disaggregation_queue_health.health_score_average
    filters:
      bre_na_disaggregation_queue_health.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_disaggregation_queue_health.module_name
      Queue Name: bre_na_disaggregation_queue_health.queue_name
      Queue Type: bre_na_disaggregation_queue_health.queue_type
      Environment: bre_na_disaggregation_queue_health.environment
      Time Period: bre_na_disaggregation_queue_health.date_range
    row: 15
    col: 12
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: NA-3B-T08. Fixed module_name IN (Disaggregation, Aggregation, UploadEventSplitter). UTC date, environment,
      module, and queue filters apply before source aggregation.
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_disaggregation_queue_health.bucket_date
    show_null_points: true
    legend_position: center
    x_axis_scale: time
    pivots:
    - bre_na_disaggregation_queue_health.queue_name
    stacking: normal
    column_limit: 50
  - name: na_3b_t09
    title: Trends - Processing Efficiency
    model: bre_na
    explore: bre_na_disaggregation_queue_daily
    type: looker_line
    fields:
    - bre_na_disaggregation_queue_daily.bucket_date
    - bre_na_disaggregation_queue_daily.empty_receives_ratio_average
    filters:
      bre_na_disaggregation_queue_daily.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_disaggregation_queue_daily.module_name
      Queue Name: bre_na_disaggregation_queue_daily.queue_name
      Queue Type: bre_na_disaggregation_queue_daily.queue_type
      Environment: bre_na_disaggregation_queue_daily.environment
      Time Period: bre_na_disaggregation_queue_daily.date_range
    row: 22
    col: 0
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: NA-3B-T09. Fixed module_name IN (Disaggregation, Aggregation, UploadEventSplitter). UTC date, environment,
      module, and queue filters apply before source aggregation. AVG of source daily empty_receives_ratio, in percent.
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_disaggregation_queue_daily.bucket_date
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_3b_t10
    title: Trends - Oldest Message Age Over Time
    model: bre_na
    explore: bre_na_disaggregation_queue_hourly
    type: looker_line
    fields:
    - bre_na_disaggregation_queue_hourly.bucket_hour
    - bre_na_disaggregation_queue_hourly.delayed_messages_sum
    filters:
      bre_na_disaggregation_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Module Name: bre_na_disaggregation_queue_hourly.module_name
      Queue Name: bre_na_disaggregation_queue_hourly.queue_name
      Queue Type: bre_na_disaggregation_queue_hourly.queue_type
      Environment: bre_na_disaggregation_queue_hourly.environment
      Time Period: bre_na_disaggregation_queue_hourly.date_range
    row: 22
    col: 12
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: NA-3B-T10. Fixed module_name IN (Disaggregation, Aggregation, UploadEventSplitter). UTC date, environment,
      module, and queue filters apply before source aggregation. SRC-01 retains its rolling seven-day history limit.
      Title retained from the specification; the metric is delayed message count, not message age.
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_disaggregation_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  filters:
  - name: Time Period
    title: Time Period
    type: field_filter
    default_value: 7 days ago for 7 days
    allow_multiple_values: false
    required: false
    model: bre_na
    explore: bre_na_disaggregation_queue_hourly
    field: bre_na_disaggregation_queue_hourly.date_range
    ui_config:
      type: advanced
      display: popover
  - name: Environment
    title: Environment
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_disaggregation_queue_hourly
    field: bre_na_disaggregation_queue_hourly.environment
    ui_config:
      type: tag_list
      display: popover
  - name: Module Name
    title: Module Name
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_disaggregation_queue_hourly
    field: bre_na_disaggregation_queue_hourly.module_name
    ui_config:
      type: tag_list
      display: popover
  - name: Queue Name
    title: Queue Name
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_disaggregation_queue_hourly
    field: bre_na_disaggregation_queue_hourly.queue_name
    ui_config:
      type: tag_list
      display: popover
  - name: Queue Type
    title: Queue Type
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_disaggregation_queue_hourly
    field: bre_na_disaggregation_queue_hourly.queue_type
    ui_config:
      type: tag_list
      display: popover
  layout: newspaper
  preferred_viewer: dashboards-next
  title: BRE NA — Queue Metrics Disaggregation
