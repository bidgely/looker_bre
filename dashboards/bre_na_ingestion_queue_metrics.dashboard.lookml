# NA 1b — Queue Metrics Ingestion. See data_studio_files/bre_na_ingestion_implementation.md.
---
- crossfilter_enabled: false
  dashboard: bre_na_ingestion_queue_metrics
  description: NA Ingestion queue KPIs and trends. Draft pending Looker validation and original-report parity review.
  elements:
  - name: na_1b_t01
    title: Key KPIs - Environment Health Score
    model: bre_na
    explore: bre_na_ingestion_queue_health
    type: single_value
    fields:
    - bre_na_ingestion_queue_health.health_score_average
    filters:
      bre_na_ingestion_queue_health.module_name: Ingestion
      bre_na_ingestion_queue_health.date_range: 7 days ago for 7 days
    listen:
      Queue Time Period: bre_na_ingestion_queue_health.date_range
      Event Timestamp (UTC): bre_na_ingestion_queue_health.event_timestamp_str
      Module Name: bre_na_ingestion_queue_health.module_name
      Queue Name: bre_na_ingestion_queue_health.queue_name
      Queue Type: bre_na_ingestion_queue_health.queue_type
    row: 0
    col: 0
    width: 8
    height: 4
    limit: 1
    show_view_names: false
    note_text: NA-1B-T01. Fixed module_name = Ingestion. UTC date and event filters apply before aggregation.
    note_display: hover
    note_state: collapsed
  - name: na_1b_t02
    title: Key KPIs - Total Ingestion Volume
    model: bre_na
    explore: bre_na_ingestion_queue_hourly
    type: looker_line
    fields:
    - bre_na_ingestion_queue_hourly.bucket_hour
    - bre_na_ingestion_queue_hourly.total_messages_received_sum
    filters:
      bre_na_ingestion_queue_hourly.module_name: Ingestion
      bre_na_ingestion_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Queue Time Period: bre_na_ingestion_queue_hourly.date_range
      Event Timestamp (UTC): bre_na_ingestion_queue_hourly.event_timestamp_str
      Module Name: bre_na_ingestion_queue_hourly.module_name
      Queue Name: bre_na_ingestion_queue_hourly.queue_name
      Queue Type: bre_na_ingestion_queue_hourly.queue_type
    row: 0
    col: 8
    width: 16
    height: 4
    limit: 5000
    show_view_names: false
    note_text: NA-1B-T02. Fixed module_name = Ingestion. UTC date and event filters apply before aggregation. SRC-01
      retains its rolling seven-day source history limit.
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_ingestion_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_1b_t03
    title: Key KPIs - Ingestion Success Rate
    model: bre_na
    explore: bre_na_ingestion_queue_hourly
    type: single_value
    fields:
    - bre_na_ingestion_queue_hourly.success_rate_average
    filters:
      bre_na_ingestion_queue_hourly.module_name: Ingestion
      bre_na_ingestion_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Queue Time Period: bre_na_ingestion_queue_hourly.date_range
      Event Timestamp (UTC): bre_na_ingestion_queue_hourly.event_timestamp_str
      Module Name: bre_na_ingestion_queue_hourly.module_name
      Queue Name: bre_na_ingestion_queue_hourly.queue_name
      Queue Type: bre_na_ingestion_queue_hourly.queue_type
    row: 4
    col: 0
    width: 12
    height: 4
    limit: 1
    show_view_names: false
    note_text: NA-1B-T03. Fixed module_name = Ingestion. UTC date and event filters apply before aggregation. SRC-01
      retains its rolling seven-day source history limit. Uses AVG of source success_rate percentages pending confirmation
      of chart aggregation.
    note_display: hover
    note_state: collapsed
  - name: na_1b_t04
    title: Key KPIs - Queue Backlog Volume
    model: bre_na
    explore: bre_na_ingestion_queue_hourly
    type: single_value
    fields:
    - bre_na_ingestion_queue_hourly.avg_queue_backlog_average
    filters:
      bre_na_ingestion_queue_hourly.module_name: Ingestion
      bre_na_ingestion_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Queue Time Period: bre_na_ingestion_queue_hourly.date_range
      Event Timestamp (UTC): bre_na_ingestion_queue_hourly.event_timestamp_str
      Module Name: bre_na_ingestion_queue_hourly.module_name
      Queue Name: bre_na_ingestion_queue_hourly.queue_name
      Queue Type: bre_na_ingestion_queue_hourly.queue_type
    row: 4
    col: 12
    width: 12
    height: 4
    limit: 1
    show_view_names: false
    note_text: NA-1B-T04. Fixed module_name = Ingestion. UTC date and event filters apply before aggregation. SRC-01
      retains its rolling seven-day source history limit. Uses avg_queue_backlog and the hourly bucket date; the
      documented aliases average_queue_backlog and analysis_date are not output by SRC-01.
    note_display: hover
    note_state: collapsed
  - name: na_1b_t05
    title: Trends - Ingestion Volume Over Time
    model: bre_na
    explore: bre_na_ingestion_queue_hourly
    type: looker_line
    fields:
    - bre_na_ingestion_queue_hourly.bucket_hour
    - bre_na_ingestion_queue_hourly.total_messages_received_sum
    filters:
      bre_na_ingestion_queue_hourly.module_name: Ingestion
      bre_na_ingestion_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Queue Time Period: bre_na_ingestion_queue_hourly.date_range
      Event Timestamp (UTC): bre_na_ingestion_queue_hourly.event_timestamp_str
      Module Name: bre_na_ingestion_queue_hourly.module_name
      Queue Name: bre_na_ingestion_queue_hourly.queue_name
      Queue Type: bre_na_ingestion_queue_hourly.queue_type
    row: 8
    col: 0
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: NA-1B-T05. Fixed module_name = Ingestion. UTC date and event filters apply before aggregation. SRC-01
      retains its rolling seven-day source history limit.
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_ingestion_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_1b_t06
    title: 'Trends - Queue Size: Backlog Volume Over Time'
    model: bre_na
    explore: bre_na_ingestion_queue_hourly
    type: looker_line
    fields:
    - bre_na_ingestion_queue_hourly.bucket_hour
    - bre_na_ingestion_queue_hourly.avg_queue_backlog_average
    filters:
      bre_na_ingestion_queue_hourly.module_name: Ingestion
      bre_na_ingestion_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Queue Time Period: bre_na_ingestion_queue_hourly.date_range
      Event Timestamp (UTC): bre_na_ingestion_queue_hourly.event_timestamp_str
      Module Name: bre_na_ingestion_queue_hourly.module_name
      Queue Name: bre_na_ingestion_queue_hourly.queue_name
      Queue Type: bre_na_ingestion_queue_hourly.queue_type
    row: 8
    col: 12
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: NA-1B-T06. Fixed module_name = Ingestion. UTC date and event filters apply before aggregation. SRC-01
      retains its rolling seven-day source history limit.
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_ingestion_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_1b_t07
    title: Trends - Processed Messages Over Time
    model: bre_na
    explore: bre_na_ingestion_queue_hourly
    type: looker_line
    fields:
    - bre_na_ingestion_queue_hourly.bucket_hour
    - bre_na_ingestion_queue_hourly.total_messages_sent_sum
    filters:
      bre_na_ingestion_queue_hourly.module_name: Ingestion
      bre_na_ingestion_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Queue Time Period: bre_na_ingestion_queue_hourly.date_range
      Event Timestamp (UTC): bre_na_ingestion_queue_hourly.event_timestamp_str
      Module Name: bre_na_ingestion_queue_hourly.module_name
      Queue Name: bre_na_ingestion_queue_hourly.queue_name
      Queue Type: bre_na_ingestion_queue_hourly.queue_type
    row: 15
    col: 0
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: NA-1B-T07. Fixed module_name = Ingestion. UTC date and event filters apply before aggregation. SRC-01
      retains its rolling seven-day source history limit.
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_ingestion_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_1b_t08
    title: Trends - Health Score by Queue Name
    model: bre_na
    explore: bre_na_ingestion_queue_health
    type: looker_column
    fields:
    - bre_na_ingestion_queue_health.bucket_date
    - bre_na_ingestion_queue_health.environment
    - bre_na_ingestion_queue_health.health_score_average
    filters:
      bre_na_ingestion_queue_health.module_name: Ingestion
      bre_na_ingestion_queue_health.date_range: 7 days ago for 7 days
    listen:
      Queue Time Period: bre_na_ingestion_queue_health.date_range
      Event Timestamp (UTC): bre_na_ingestion_queue_health.event_timestamp_str
      Module Name: bre_na_ingestion_queue_health.module_name
      Queue Name: bre_na_ingestion_queue_health.queue_name
      Queue Type: bre_na_ingestion_queue_health.queue_type
    row: 15
    col: 12
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: NA-1B-T08. Fixed module_name = Ingestion. UTC date and event filters apply before aggregation. Breakdown
      is environment as documented, despite the title saying Queue Name.
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_ingestion_queue_health.bucket_date
    show_null_points: true
    legend_position: center
    x_axis_scale: time
    pivots:
    - bre_na_ingestion_queue_health.environment
    stacking: normal
    column_limit: 50
  - name: na_1b_t09
    title: Trends - Processing Efficiency
    model: bre_na
    explore: bre_na_ingestion_queue_daily
    type: looker_line
    fields:
    - bre_na_ingestion_queue_daily.bucket_date
    - bre_na_ingestion_queue_daily.total_messages_received_average
    filters:
      bre_na_ingestion_queue_daily.module_name: Ingestion
      bre_na_ingestion_queue_daily.date_range: 7 days ago for 7 days
    listen:
      Queue Time Period: bre_na_ingestion_queue_daily.date_range
      Event Timestamp (UTC): bre_na_ingestion_queue_daily.event_timestamp_str
      Module Name: bre_na_ingestion_queue_daily.module_name
      Queue Name: bre_na_ingestion_queue_daily.queue_name
      Queue Type: bre_na_ingestion_queue_daily.queue_type
    row: 22
    col: 0
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: NA-1B-T09. Fixed module_name = Ingestion. UTC date and event filters apply before aggregation. Processing
      Efficiency is the documented average received-message count, not a ratio.
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_ingestion_queue_daily.bucket_date
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  - name: na_1b_t10
    title: Trends - Oldest Message Age Over Time
    model: bre_na
    explore: bre_na_ingestion_queue_hourly
    type: looker_line
    fields:
    - bre_na_ingestion_queue_hourly.bucket_hour
    - bre_na_ingestion_queue_hourly.max_latency_days_max
    filters:
      bre_na_ingestion_queue_hourly.module_name: Ingestion
      bre_na_ingestion_queue_hourly.date_range: 7 days ago for 7 days
    listen:
      Queue Time Period: bre_na_ingestion_queue_hourly.date_range
      Event Timestamp (UTC): bre_na_ingestion_queue_hourly.event_timestamp_str
      Module Name: bre_na_ingestion_queue_hourly.module_name
      Queue Name: bre_na_ingestion_queue_hourly.queue_name
      Queue Type: bre_na_ingestion_queue_hourly.queue_type
    row: 22
    col: 12
    width: 12
    height: 7
    limit: 5000
    show_view_names: false
    note_text: NA-1B-T10. Fixed module_name = Ingestion. UTC date and event filters apply before aggregation. SRC-01
      retains its rolling seven-day source history limit.
    note_display: hover
    note_state: collapsed
    sorts:
    - bre_na_ingestion_queue_hourly.bucket_hour
    show_null_points: true
    legend_position: center
    x_axis_scale: time
  filters:
  - name: Queue Time Period
    title: Queue Time Period
    type: field_filter
    default_value: 7 days ago for 7 days
    allow_multiple_values: false
    required: false
    model: bre_na
    explore: bre_na_ingestion_queue_hourly
    field: bre_na_ingestion_queue_hourly.date_range
    ui_config:
      type: advanced
      display: popover
  - name: Event Timestamp (UTC)
    title: Event Timestamp (UTC)
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_ingestion_queue_hourly
    field: bre_na_ingestion_queue_hourly.event_timestamp_str
    ui_config:
      type: tag_list
      display: popover
  - name: Module Name
    title: Module Name
    type: field_filter
    default_value: Ingestion
    allow_multiple_values: true
    required: false
    model: bre_na
    explore: bre_na_ingestion_queue_hourly
    field: bre_na_ingestion_queue_hourly.module_name
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
    explore: bre_na_ingestion_queue_hourly
    field: bre_na_ingestion_queue_hourly.queue_name
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
    explore: bre_na_ingestion_queue_hourly
    field: bre_na_ingestion_queue_hourly.queue_type
    ui_config:
      type: tag_list
      display: popover
  layout: newspaper
  preferred_viewer: dashboards-next
  title: BRE NA — 1b — Queue Metrics Ingestion
